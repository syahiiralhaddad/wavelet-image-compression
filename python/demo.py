"""
Generates the figures and results table in the README.

    pip install -r requirements.txt
    python python/demo.py                 # uses the sample image
    python python/demo.py path/to/img.png # or your own image
"""

import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from skimage import data, io

from wavelet_compression import WAVELETS, coeff_image, compress

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "images"
OUT.mkdir(exist_ok=True)

SURFACE = "#fcfcfb"
INK = "#0b0b0b"
INK_2 = "#5f5e57"
GRID = "#e4e3dd"
SERIES = {"hard": "#2a78d6", "soft": "#eb6834"}

plt.rcParams.update({
    "figure.facecolor": SURFACE,
    "axes.facecolor": SURFACE,
    "savefig.facecolor": SURFACE,
    "text.color": INK,
    "axes.labelcolor": INK_2,
    "xtick.color": INK_2,
    "ytick.color": INK_2,
    "axes.edgecolor": GRID,
    "font.size": 11,
})


def load_image():
    if len(sys.argv) > 1:
        return io.imread(sys.argv[1]), Path(sys.argv[1]).name
    # NASA photo of astronaut Eileen Collins (public domain), bundled with scikit-image
    return data.astronaut(), "astronaut (NASA, public domain)"


def show(ax, img, title, cmap="gray"):
    ax.imshow(img, cmap=cmap)
    ax.set_title(title, fontsize=12, color=INK, pad=8)
    ax.axis("off")


def pipeline_figure(img, wavelet="Daubechies", level=3, threshold=30, method="hard"):
    r = compress(img, wavelet, level, threshold, method)
    fig, axes = plt.subplots(1, 5, figsize=(20, 4.6))
    show(axes[0], r.original, "Original (grayscale)")
    show(axes[1], coeff_image(r.coeffs), "Wavelet coefficients")
    show(axes[2], coeff_image(r.coeffs_thresh), f"After {method} threshold (T={threshold})")
    show(axes[3], np.clip(r.reconstructed, 0, 255), "Reconstructed")
    show(axes[4], r.error_map, "Error map", cmap="magma")
    fig.suptitle(
        f"{wavelet} ({WAVELETS[wavelet]}), level {level}   ·   "
        f"PSNR {r.psnr:.2f} dB   ·   MSE {r.mse:.2f}   ·   compression ratio {r.compression_ratio:.2f}",
        fontsize=13, color=INK, y=0.04,
    )
    fig.tight_layout(rect=(0, 0.09, 1, 1))
    fig.savefig(OUT / "pipeline.png", dpi=110)
    plt.close(fig)
    return r


def threshold_grid(img, wavelet="Daubechies", level=3, thresholds=(10, 40, 80)):
    fig, axes = plt.subplots(2, len(thresholds), figsize=(4.6 * len(thresholds), 10))
    for row, method in enumerate(("hard", "soft")):
        for col, t in enumerate(thresholds):
            r = compress(img, wavelet, level, t, method)
            show(axes[row, col], np.clip(r.reconstructed, 0, 255),
                 f"{method.title()}, T={t}\nPSNR {r.psnr:.1f} dB · CR {r.compression_ratio:.1f}×")
    fig.tight_layout(h_pad=2.5)
    fig.savefig(OUT / "threshold_comparison.png", dpi=100)
    plt.close(fig)


def rate_distortion(img, wavelet="Daubechies", level=3):
    thresholds = np.arange(5, 101, 5)  # T=0 is lossless (PSNR ~ infinite), so it is left out
    fig, ax = plt.subplots(figsize=(8, 5))
    for method in ("hard", "soft"):
        pts = [compress(img, wavelet, level, t, method) for t in thresholds]
        cr = [p.compression_ratio for p in pts]
        ps = [p.psnr for p in pts]
        ax.plot(cr, ps, color=SERIES[method], lw=2, marker="o", ms=5,
                markeredgecolor=SURFACE, markeredgewidth=1.5, label=f"{method} thresholding")
        ax.annotate(method.title(), (cr[-1], ps[-1]), xytext=(8, 7 if method == "hard" else -7),
                    textcoords="offset points", color=INK, fontsize=11, va="center")
    ax.set_xscale("log")
    ax.set_xlabel("Compression ratio (non-zero coefficients before / after, log scale)")
    ax.set_ylabel("PSNR (dB)")
    ax.set_title(f"Quality vs. compression — {wavelet} level {level}, T = 5 → 100",
                 color=INK, loc="left", fontsize=12)
    ax.grid(True, color=GRID, lw=0.8)
    for s in ("top", "right"):
        ax.spines[s].set_visible(False)
    ax.legend(frameon=False, loc="upper right")
    fig.tight_layout()
    fig.savefig(OUT / "rate_distortion.png", dpi=110)
    plt.close(fig)


def wavelet_table(img, level=3, threshold=30, method="hard"):
    rows = []
    for name, wname in WAVELETS.items():
        r = compress(img, name, level, threshold, method)
        rows.append((name, wname, r.psnr, r.mse, r.compression_ratio))
    print(f"\nLevel {level}, threshold {threshold}, {method}:")
    print("| Wavelet | MATLAB name | PSNR (dB) | MSE | Compression ratio |")
    print("|---|---|---|---|---|")
    for name, wname, p, m, c in rows:
        print(f"| {name} | `{wname}` | {p:.2f} | {m:.2f} | {c:.2f}× |")


if __name__ == "__main__":
    img, label = load_image()
    print(f"Image: {label}, shape {img.shape}")
    r = pipeline_figure(img)
    print(f"Pipeline: PSNR {r.psnr:.2f} dB, MSE {r.mse:.2f}, CR {r.compression_ratio:.2f}")
    threshold_grid(img)
    rate_distortion(img)
    wavelet_table(img)
    print(f"\nFigures saved to {OUT}")
