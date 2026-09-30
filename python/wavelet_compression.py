"""
Wavelet image compression — Python port of the MATLAB app's core algorithm.

Mirrors the steps in matlab/simsim.mlapp:
    rgb2gray -> wavedec2 -> wthresh (hard/soft, all coefficients) -> waverec2
    -> MSE, PSNR, compression ratio (non-zero coefficients before / after)

MATLAB  -> PyWavelets
    wavedec2 / waverec2 (default 'sym' mode) -> pywt.wavedec2 / waverec2 (mode='symmetric')
    wthresh(C, 'h'|'s', T)                   -> pywt.threshold(C, T, 'hard'|'soft')
"""

from dataclasses import dataclass

import numpy as np
import pywt

# Same mapping as the dropdown in the MATLAB app
WAVELETS = {
    "Haar": "haar",
    "Daubechies": "db4",
    "Symlets": "sym4",
    "Coiflets": "coif2",
    "Biorthogonal": "bior2.2",
}


@dataclass
class CompressionResult:
    original: np.ndarray        # grayscale input (float64, 0-255)
    reconstructed: np.ndarray   # image after thresholding + inverse DWT
    coeffs: list                # wavelet coefficients before thresholding
    coeffs_thresh: list         # wavelet coefficients after thresholding
    mse: float
    psnr: float
    compression_ratio: float

    @property
    def error_map(self) -> np.ndarray:
        return np.abs(self.original - self.reconstructed)


def rgb2gray(img: np.ndarray) -> np.ndarray:
    """MATLAB rgb2gray: ITU-R BT.601 weights, rounded to uint8."""
    if img.ndim == 2:
        return img.astype(np.float64)
    rgb = img[..., :3].astype(np.float64)
    gray = rgb @ np.array([0.298936021293775, 0.587043074451121, 0.114020904255103])
    return np.round(gray).clip(0, 255)


def compress(img: np.ndarray, wavelet: str = "Haar", level: int = 1,
             threshold: float = 0.0, method: str = "hard") -> CompressionResult:
    """Run the full encode -> threshold -> decode pipeline on one image."""
    if not 1 <= level <= 5:
        raise ValueError("level must be between 1 and 5")
    if method not in ("hard", "soft"):
        raise ValueError("method must be 'hard' or 'soft'")

    wname = WAVELETS.get(wavelet, wavelet)
    gray = rgb2gray(img)

    # Encode: 2-D discrete wavelet transform
    coeffs = pywt.wavedec2(gray, wname, mode="symmetric", level=level)

    # Threshold every coefficient (approximation + details), like wthresh(C, ...) on the full vector
    arr, slices = pywt.coeffs_to_array(coeffs)
    arr_t = arr.copy() if threshold <= 0 else pywt.threshold(arr, threshold, mode=method)
    coeffs_t = pywt.array_to_coeffs(arr_t, slices, output_format="wavedec2")

    # Decode: inverse DWT, cropped to the original size
    rec = pywt.waverec2(coeffs_t, wname, mode="symmetric")[: gray.shape[0], : gray.shape[1]]

    mse = float(np.mean((gray - rec) ** 2))
    psnr = float(10 * np.log10(255.0**2 / mse)) if mse > 0 else float("inf")
    nz_before = np.count_nonzero(arr)
    nz_after = np.count_nonzero(arr_t)
    cr = nz_before / nz_after if nz_after > 0 else float("inf")

    return CompressionResult(gray, rec, coeffs, coeffs_t, mse, psnr, cr)


def coeff_image(coeffs: list) -> np.ndarray:
    """Pyramid layout of the coefficients (like wcodemat), each sub-band scaled to 0-1."""
    norm = [_scale(coeffs[0])]
    for detail in coeffs[1:]:
        norm.append(tuple(_scale(np.abs(d)) for d in detail))
    arr, _ = pywt.coeffs_to_array(norm)
    return arr


def _scale(x: np.ndarray) -> np.ndarray:
    x = np.asarray(x, dtype=np.float64)
    lo, hi = np.percentile(x, 1), np.percentile(x, 99)
    return np.clip((x - lo) / (hi - lo + 1e-12), 0, 1)
