% ======================================================================
% READ-ONLY EXPORT of the App Designer source code in simsim.mlapp,
% so the code can be read on GitHub (.mlapp files are binary).
% To run the app, open simsim.mlapp in MATLAB App Designer instead.
% ======================================================================

classdef simsim < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        Button_3                        matlab.ui.control.Button
        Button_2                        matlab.ui.control.Button
        Button                          matlab.ui.control.Button
        Panel                           matlab.ui.container.Panel
        ControlPanel                    matlab.ui.container.Panel
        ClearAllLabel                   matlab.ui.control.Label
        DecodeLabel                     matlab.ui.control.Label
        EncodeLabel                     matlab.ui.control.Label
        Button_11                       matlab.ui.control.Button
        Button_9                        matlab.ui.control.Button
        Button_10                       matlab.ui.control.Button
        DecompositionLevelDropDown      matlab.ui.control.DropDown
        DecompositionLevelDropDownLabel  matlab.ui.control.Label
        WavelengthDropDown              matlab.ui.control.DropDown
        WavelengthDropDownLabel         matlab.ui.control.Label
        ThresholdEditField              matlab.ui.control.NumericEditField
        ThresholdSlider                 matlab.ui.control.Slider
        ThresholdSliderLabel            matlab.ui.control.Label
        KeepCoefficientCheckBox         matlab.ui.control.CheckBox
        ThresholdingMethodsButtonGroup  matlab.ui.container.ButtonGroup
        SoftButton                      matlab.ui.control.RadioButton
        HardButton                      matlab.ui.control.RadioButton
        TabGroup                        matlab.ui.container.TabGroup
        RESULTCOMPRESSEDTab             matlab.ui.container.Tab
        ResultandMetricsPanel           matlab.ui.container.Panel
        MSEEditField                    matlab.ui.control.NumericEditField
        MSEEditFieldLabel               matlab.ui.control.Label
        CompressionRatioEditField       matlab.ui.control.NumericEditField
        CompressionRatioEditFieldLabel  matlab.ui.control.Label
        PSNRValueEditField              matlab.ui.control.NumericEditField
        PSNRValueEditFieldLabel         matlab.ui.control.Label
        UIAxes_3                        matlab.ui.control.UIAxes
        UIAxes_2                        matlab.ui.control.UIAxes
        WAVELETGRAPHTab                 matlab.ui.container.Tab
        ResultandMetricsPanel_2         matlab.ui.container.Panel
        MSEEditField_2                  matlab.ui.control.NumericEditField
        MSEEditField_2Label             matlab.ui.control.Label
        CompressionRatioEditField_2     matlab.ui.control.NumericEditField
        CompressionRatioEditField_2Label  matlab.ui.control.Label
        PSNRValueEditField_2            matlab.ui.control.NumericEditField
        PSNRValueEditField_2Label       matlab.ui.control.Label
        UIAxes_6                        matlab.ui.control.UIAxes
        UIAxes_5                        matlab.ui.control.UIAxes
        ERRORMAPTab                     matlab.ui.container.Tab
        ResultandMetricsPanel_3         matlab.ui.container.Panel
        MSEEditField_3                  matlab.ui.control.NumericEditField
        MSEEditField_3Label             matlab.ui.control.Label
        CompressionRatioEditField_3     matlab.ui.control.NumericEditField
        CompressionRatioEditField_3Label  matlab.ui.control.Label
        PSNRValueEditField_3            matlab.ui.control.NumericEditField
        PSNRValueEditField_3Label       matlab.ui.control.Label
        UIAxes_7                        matlab.ui.control.UIAxes
        InputPanel                      matlab.ui.container.Panel
        ClearImageLabel                 matlab.ui.control.Label
        InputImageLabel                 matlab.ui.control.Label
        StatusEditField                 matlab.ui.control.EditField
        StatusEditFieldLabel            matlab.ui.control.Label
        PathImageEditField              matlab.ui.control.EditField
        PathImageEditFieldLabel         matlab.ui.control.Label
        Button_7                        matlab.ui.control.Button
        Button_8                        matlab.ui.control.Button
        Image                           matlab.ui.control.Image
    end

    properties (Access = private)
    OriginalImage
    GrayImage
    WaveletCoeffs
    ThresholdedCoeffs
    CompressedImage
    WaveletType
    DecompLevel
    WaveletStructure
    end
    
    methods (Access = private)
    % Tambahkan fungsi baru untuk visualisasi koefisien wavelet yang lebih
    
   function processImage(app)
    try
        % Baca gambar dari path
        img = imread(app.PathImageEditField.Value);
        
        % Konversi ke grayscale jika perlu
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = double(img);
        end
        grayImg = double(grayImg);
        
        % Dapatkan parameter dari GUI
        wavelength = app.WavelengthDropDown.Value;
        level = str2double(app.DecompositionLevelDropDown.Value);
        threshold = app.ThresholdEditField.Value;
        
        % Konversi nama wavelet ke format MATLAB
        switch wavelength
            case 'Haar'
                wname = 'haar';
            case 'Daubechies'
                wname = 'db4';
            case 'Symlets'
                wname = 'sym4';
            case 'Coiflets'
                wname = 'coif2';
            case 'Biorthogonal'
                wname = 'bior2.2';
            otherwise
                wname = 'haar';
        end
        
        % Lakukan DWT
        [C, S] = wavedec2(grayImg, level, wname);
        
        % Tampilkan koefisien sebelum thresholding
        coeffImg = wcodemat(C, S, 'mat', 1);
        imshow(coeffImg, [], 'Parent', app.UIAxes_5);
        title(app.UIAxes_5, 'Wavelet Before Threshold');
        
        % Apply thresholding
        if app.HardButton.Value
            % Hard thresholding
            C_thresh = wthresh(C, 'h', threshold);
        else
            % Soft thresholding
            C_thresh = wthresh(C, 's', threshold);
        end
        
        % Tampilkan koefisien setelah thresholding
        coeffImgThresh = wcodemat(C_thresh, S, 'mat', 1);
        imshow(coeffImgThresh, [], 'Parent', app.UIAxes_6);
        title(app.UIAxes_6, 'Wavelet After Threshold');
        
        % Rekonstruksi gambar (IDWT)
        reconstructedImg = waverec2(C_thresh, S, wname);
        
        % Tampilkan hasil kompresi
        imshow(uint8(reconstructedImg), 'Parent', app.UIAxes_2);
        title(app.UIAxes_2, 'Compressed');
        
        % Hitung dan tampilkan error map
        errorMap = abs(grayImg - reconstructedImg);
        imshow(errorMap, [], 'Parent', app.UIAxes_7);
        title(app.UIAxes_7, 'Error Map');
        
        % Hitung metrics
        calculateMetrics(app, grayImg, reconstructedImg, C, C_thresh);
        
    catch ME
        app.StatusEditField.Value = ['Process error: ' ME.message];
    end
end

% Fungsi untuk menghitung metrics
function calculateMetrics(app, original, reconstructed, C_original, C_thresh)
    try
        % Hitung MSE
        mse = mean((original(:) - reconstructed(:)).^2);
        app.MSEEditField.Value = mse;
        app.MSEEditField_2.Value = mse;
        app.MSEEditField_3.Value = mse;
        
        % Hitung PSNR
        if mse > 0
            psnr = 10 * log10(255^2 / mse);
        else
            psnr = Inf;
        end
        app.PSNRValueEditField.Value = psnr;
        app.PSNRValueEditField_2.Value = psnr;
        app.PSNRValueEditField_3.Value = psnr;
        
        % Hitung Compression Ratio
        % Jumlah koefisien non-zero sebelum dan sesudah thresholding
        nonzero_original = sum(C_original ~= 0);
        nonzero_thresh = sum(C_thresh ~= 0);
        
        if nonzero_thresh > 0
            compression_ratio = nonzero_original / nonzero_thresh;
        else
            compression_ratio = Inf;
        end
        app.CompressionRatioEditField.Value = compression_ratio;
        app.CompressionRatioEditField_2.Value = compression_ratio;
        app.CompressionRatioEditField_3.Value = compression_ratio;

    catch ME
        app.StatusEditField.Value = ['Metrics error: ' ME.message];
    end
end
function visualizeWaveletCoeffs(~, C, S, level, wname, axesHandle, titleText)
    try
        % Clear axes terlebih dahulu
        cla(axesHandle);
        
        if level == 1
            % Level 1: Susun 2x2 (LL, LH, HL, HH)
            % Ambil koefisien approximation
            LL1 = wrcoef2('a', C, S, wname, 1);
            % Ambil koefisien detail
            LH1 = wrcoef2('h', C, S, wname, 1);
            HL1 = wrcoef2('v', C, S, wname, 1);
            HH1 = wrcoef2('d', C, S, wname, 1);
            
            % Resize semua ke ukuran yang sama
            targetSize = size(LL1);
            LH1 = imresize(LH1, targetSize);
            HL1 = imresize(HL1, targetSize);
            HH1 = imresize(HH1, targetSize);
            
            % Gabungkan dalam format 2x2
            topRow = [abs(LL1), abs(LH1)];
            bottomRow = [abs(HL1), abs(HH1)];
            compositeImg = [topRow; bottomRow];
            
        elseif level == 2
            % Level 2: LL dipecah jadi 4, sisanya 3 kotak besar
            % Ambil koefisien level 2
            LL2 = wrcoef2('a', C, S, wname, 2);
            LH2 = wrcoef2('h', C, S, wname, 2);
            HL2 = wrcoef2('v', C, S, wname, 2);
            HH2 = wrcoef2('d', C, S, wname, 2);
            
            % Ambil koefisien level 1 (untuk detail yang lebih kasar)
            LH1 = wrcoef2('h', C, S, wname, 1);
            HL1 = wrcoef2('v', C, S, wname, 1);
            HH1 = wrcoef2('d', C, S, wname, 1);
            
            % Resize ke ukuran yang konsisten
            baseSize = size(LL2);
            LH2 = imresize(LH2, baseSize);
            HL2 = imresize(HL2, baseSize);
            HH2 = imresize(HH2, baseSize);
            
            % Untuk level 1, buat lebih besar
            bigSize = baseSize * 2;
            LH1 = imresize(LH1, bigSize);
            HL1 = imresize(HL1, bigSize);
            HH1 = imresize(HH1, bigSize);
            
            % Susun: LL2 kecil di kiri atas, sisanya kotak besar
            topLeft = [abs(LL2), abs(LH2)];
            topRight = abs(LH1);
            bottomLeft = [abs(HL2), abs(HH2)];
            bottomRight = abs(HH1);
            
            % Pastikan dimensi konsisten
            topLeft = imresize(topLeft, [baseSize(1), baseSize(2)*2]);
            bottomLeft = imresize(bottomLeft, [baseSize(1), baseSize(2)*2]);
            topRight = imresize(topRight, [baseSize(1), baseSize(2)*2]);
            bottomRight = imresize(bottomRight, [baseSize(1), baseSize(2)*2]);
            
            compositeImg = [topLeft, topRight; bottomLeft, bottomRight];
            
        else
            % Level 3,4,5: Visualisasi hierarkis
            % Mulai dengan level tertinggi
            compositeImg = abs(wrcoef2('a', C, S, wname, level));
            
            % Tambahkan detail untuk setiap level
            for lev = level:-1:1
                cH = abs(wrcoef2('h', C, S, wname, lev));
                cV = abs(wrcoef2('v', C, S, wname, lev));
                cD = abs(wrcoef2('d', C, S, wname, lev));
                
                % Resize agar konsisten
                [h, w] = size(compositeImg);
                cH = imresize(cH, [h, w]);
                cV = imresize(cV, [h, w]);
                cD = imresize(cD, [h, w]);
                
                % Susun dalam format 2x2 yang nested
                topRow = [compositeImg, cH];
                bottomRow = [cV, cD];
                compositeImg = [topRow; bottomRow];
            end
        end
        
        % Tampilkan hasil
        imagesc(axesHandle, compositeImg);
        colormap(axesHandle, 'gray');
        axis(axesHandle, 'off');
        title(axesHandle, titleText);
        
    catch 
        % Fallback sederhana
        try
            % Coba visualisasi sederhana
            coeffImg = wcodemat(C, S, 'mat', 1);
            imagesc(axesHandle, abs(coeffImg));
            colormap(axesHandle, 'gray');
            axis(axesHandle, 'off');
            title(axesHandle, [titleText ' (Simple)']);
        catch
            % Last resort
            imagesc(axesHandle, reshape(abs(C), [sqrt(length(C)), sqrt(length(C))]));
            colormap(axesHandle, 'gray');
            axis(axesHandle, 'off');
            title(axesHandle, [titleText ' (Fallback)']);
        end
    end
end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
     % Setup Wavelength Dropdown
    app.WavelengthDropDown.Items = {'Haar', 'Daubechies', 'Symlets', 'Coiflets', 'Biorthogonal'};
    app.WavelengthDropDown.Value = 'Haar';
    
    % Setup Decomposition Level Dropdown
    app.DecompositionLevelDropDown.Items = {'1', '2', '3', '4', '5'};
    app.DecompositionLevelDropDown.Value = '1';
    
    % Setup Threshold Slider
    app.ThresholdSlider.Limits = [0, 100];
    app.ThresholdSlider.Value = 0;
    app.ThresholdEditField.Value = 0;
    
    % Setup default selections
    app.KeepCoefficientCheckBox.Value = false;
    app.ThresholdingMethodsButtonGroup.SelectedObject = app.HardButton;
    
    % Initialize status
    app.StatusEditField.Value = 'Ready';
    
    % Set initial metrics
    app.PSNRValueEditField.Value = 0;
    app.PSNRValueEditField_2.Value = 0;
    app.PSNRValueEditField_3.Value = 0;
    app.CompressionRatioEditField.Value = 0;
    app.CompressionRatioEditField_2.Value = 0;
    app.CompressionRatioEditField_3.Value = 0;
    app.MSEEditField.Value = 0;
    app.MSEEditField_2.Value = 0;
    app.MSEEditField_3.Value = 0;
        end

        % Button pushed function: Button
        function ButtonPushed(app, event)
            PAGE; 
            app.UIFigure.Visible = 'off';
        end

        % Button pushed function: Button_3
        function Button_3Pushed(app, event)
            GUIDELINE; 
            app.UIFigure.Visible = 'off'; 
        end

        % Button pushed function: Button_2
        function Button_2Pushed(app, event)
            THEORY; 
            app.UIFigure.Visible = 'off'; 
        end

        % Button pushed function: Button_8
        function Button_8Pushed(app, event)
  % Callback untuk Button_8Pushed (Input Image) - Versi Sederhana
    try
        % Dialog untuk memilih file gambar
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Image Files'; '*.*', 'All Files'}, 'Select an Image');
        
        if isequal(filename, 0)
            fprintf('User cancelled selection\n'); % Debug
            app.StatusEditField.Value = 'No file selected';
            return;
        end
        
        fprintf('File selected: %s\n', filename); % Debug
        
        % Gabungkan path dan filename
        fullpath = fullfile(pathname, filename);
        fprintf('Full path: %s\n', fullpath); % Debug
        
        % Update PathImageEditField dengan path lengkap
        app.PathImageEditField.Value = fullpath;
        fprintf('Path field updated\n'); % Debug
        
        % Baca dan tampilkan gambar
        img = imread(fullpath);
        fprintf('Image read successfully, size: %dx%d\n', size(img,1), size(img,2)); % Debug
        
        % Konversi ke grayscale untuk tampilan
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
            fprintf('Converted to grayscale\n'); % Debug
        else
            grayImg = img;
            fprintf('Already grayscale\n'); % Debug
        end
        
        % Tampilkan gambar - sesuaikan dengan nama axes Anda
        imshow(grayImg, 'Parent', app.UIAxes_3);
        fprintf('Image displayed\n'); % Debug
        
        % Update status dengan berbagai cara
        fprintf('Updating status field...\n'); % Debug
        app.StatusEditField.Value = 'Image loaded successfully';
        
        % Force refresh
        drawnow;
        fprintf('Status updated: %s\n', app.StatusEditField.Value); % Debug
        
    catch ME
        fprintf('Error occurred: %s\n', ME.message); % Debug
        % Handle error
        app.StatusEditField.Value = ['Error: ' ME.message];
        app.PathImageEditField.Value = '';
    end
        end

        % Button pushed function: Button_7
        function Button_7Pushed(app, event)
         try
        % Clear semua field
        app.PathImageEditField.Value = '';
        app.StatusEditField.Value = 'Reset success';
        
        % Clear axes - sesuaikan dengan nama axes Anda
        cla(app.UIAxes_3);        % Axes untuk original image
        cla(app.UIAxes_2);      % Axes untuk compressed image (jika ada)
        
    catch ME
        app.StatusEditField.Value = ['Reset error: ' ME.message];
         end
        end

        % Value changed function: ThresholdSlider
        function ThresholdSliderValueChanged(app, event)
% Update nilai di EditField
    app.ThresholdEditField.Value = app.ThresholdSlider.Value;
    
    if app.KeepCoefficientCheckBox.Value
        return;
    end
    
    % Auto-update thresholding jika sudah ada gambar
if ~isempty(app.PathImageEditField.Value)
    % Tidak melakukan apa-apa, user harus tekan encode/decode manual
    app.StatusEditField.Value = 'Threshold updated. Press Encode to apply.';
end
        end

        % Button pushed function: Button_10
        function Button_10Pushed(app, event)
try
        if isempty(app.PathImageEditField.Value)
            app.StatusEditField.Value = 'Please select an image first';
            return;
        end
        
        % Baca gambar dari path
        img = imread(app.PathImageEditField.Value);
        
        % Konversi ke grayscale jika perlu
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = double(img);
        end
        grayImg = double(grayImg);
        
        % Dapatkan parameter dari GUI
        wavelength = app.WavelengthDropDown.Value;
        level = str2double(app.DecompositionLevelDropDown.Value);
        threshold = app.ThresholdEditField.Value;
        
        % Konversi nama wavelet ke format MATLAB
        switch wavelength
            case 'Haar'
                wname = 'haar';
            case 'Daubechies'
                wname = 'db4';
            case 'Symlets'
                wname = 'sym4';
            case 'Coiflets'
                wname = 'coif2';
            case 'Biorthogonal'
                wname = 'bior2.2';
            otherwise
                wname = 'haar';
        end
        
        % Lakukan DWT
        [C, S] = wavedec2(grayImg, level, wname);
        
        % Tampilkan koefisien sebelum thresholding
try
            coeffImg = waverec2(C, S, wname);
            imshow(coeffImg, [], 'Parent', app.UIAxes_5);
            title(app.UIAxes_5, 'Wavelet Before Threshold');
       catch
       % Alternative visualization
       coeffImg = mat2gray(abs(appcoeff2(C, S, wname, level)));
       imshow(coeffImg, 'Parent', app.UIAxes_5);
       title(app.UIAxes_5, 'Wavelet Before Threshold');
end

        % Apply thresholding
if app.HardButton.Value
    C_thresh = wthresh(C, 'h', threshold);
else
    C_thresh = wthresh(C, 's', threshold);
end
        
      % Tampilkan koefisien setelah thresholding
visualizeWaveletCoeffs(app, C_thresh, S, level, wname, app.UIAxes_6, 'Wavelet After Threshold');
        
        app.StatusEditField.Value = 'Encoding completed';
        
    catch ME
        app.StatusEditField.Value = ['Encode error: ' ME.message];
 end
        end

        % Button pushed function: Button_9
        function Button_9Pushed(app, event)
    try
        if isempty(app.PathImageEditField.Value)
            app.StatusEditField.Value = 'Please encode first';
            return;
        end
        
        % Baca gambar dari path
        img = imread(app.PathImageEditField.Value);
        
        % Konversi ke grayscale jika perlu
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = double(img);
        end
        grayImg = double(grayImg);
        
        % Dapatkan parameter dari GUI
        wavelength = app.WavelengthDropDown.Value;
        level = str2double(app.DecompositionLevelDropDown.Value);
        threshold = app.ThresholdEditField.Value;
        
        % Konversi nama wavelet ke format MATLAB
        switch wavelength
            case 'Haar'
                wname = 'haar';
            case 'Daubechies'
                wname = 'db4';
            case 'Symlets'
                wname = 'sym4';
            case 'Coiflets'
                wname = 'coif2';
            case 'Biorthogonal'
                wname = 'bior2.2';
            otherwise
                wname = 'haar';
        end
        
        % Lakukan DWT
        [C, S] = wavedec2(grayImg, level, wname);
        
        % Apply thresholding
        if app.HardButton.Value
            C_thresh = wthresh(C, 'h', threshold);
        else
            C_thresh = wthresh(C, 's', threshold);
          % Tampilkan koefisien setelah thresholding (tambahkan setelah C_thresh = wthresh...)
        try
            coeffImgThresh = wcodemat(C_thresh, S, 'mat', 0);
            imshow(coeffImgThresh, [], 'Parent', app.UIAxes_6);
            title(app.UIAxes_6, 'Wavelet After Threshold');
        catch
            try
                coeffImgThresh = wcodemat(C_thresh, S, 'mat', 1);
                imshow(coeffImgThresh, [], 'Parent', app.UIAxes_6);
                title(app.UIAxes_6, 'Wavelet After Threshold');
            catch
                cla(app.UIAxes_6);
            end
        end
        end
        
        % Rekonstruksi gambar (IDWT)
        reconstructedImg = waverec2(C_thresh, S, wname);
        
        % Tampilkan hasil kompresi
        imshow(uint8(reconstructedImg), 'Parent', app.UIAxes_2);
        title(app.UIAxes_2, 'Compressed');
        
        % Hitung dan tampilkan error map
        errorMap = abs(grayImg - reconstructedImg);
        imshow(errorMap, [], 'Parent', app.UIAxes_7);
        title(app.UIAxes_7, 'Error Map');
        
        % Hitung MSE
        mse = mean((grayImg(:) - reconstructedImg(:)).^2);
        app.MSEEditField.Value = mse;
        app.MSEEditField_2.Value = mse;
        app.MSEEditField_3.Value = mse;
        
        % Hitung PSNR
        if mse > 0
            psnr = 10 * log10(255^2 / mse);
        else
            psnr = Inf;
        end
        app.PSNRValueEditField.Value = psnr;
        app.PSNRValueEditField_2.Value = psnr;
        app.PSNRValueEditField_3.Value = psnr;
        
        % Hitung Compression Ratio
        nonzero_original = sum(C ~= 0);
        nonzero_thresh = sum(C_thresh ~= 0);
        
        if nonzero_thresh > 0
            compression_ratio = nonzero_original / nonzero_thresh;
        else
            compression_ratio = Inf;
        end
        app.CompressionRatioEditField.Value = compression_ratio;
        app.CompressionRatioEditField_2.Value = compression_ratio;
        app.CompressionRatioEditField_3.Value = compression_ratio;
        
        app.StatusEditField.Value = 'Decoding completed';
        
    catch ME
        app.StatusEditField.Value = ['Decode error: ' ME.message];
     end
        end

        % Button pushed function: Button_11
        function Button_11Pushed(app, event)
             try
        % Reset semua parameter ke default
        app.WavelengthDropDown.Value = 'Haar';
        app.DecompositionLevelDropDown.Value = '1';
        app.ThresholdSlider.Value = 0;
        app.ThresholdEditField.Value = 0;
        app.KeepCoefficientCheckBox.Value = false;
        app.HardButton.Value = true;
        app.SoftButton.Value = false;
        
        % Clear metrics
        app.PSNRValueEditField.Value = 0;
        app.PSNRValueEditField_2.Value = 0;
        app.PSNRValueEditField_3.Value = 0;
        app.CompressionRatioEditField.Value = 0;
        app.CompressionRatioEditField_2.Value = 0;
        app.CompressionRatioEditField_3.Value = 0;
        app.MSEEditField.Value = 0;
        app.MSEEditField_2.Value = 0;
        app.MSEEditField_3.Value = 0;
        
        % Clear axes
        cla(app.UIAxes_2); % Compressed
        cla(app.UIAxes_5); % Wavelet Before Threshold
        cla(app.UIAxes_6); % Wavelet After Threshold
        cla(app.UIAxes_7); % Error Map
        
        app.StatusEditField.Value = 'Parameters reset';
        
    catch ME
        app.StatusEditField.Value = ['Reset error: ' ME.message];
             end
        end

        % Value changed function: WavelengthDropDown
        function WavelengthDropDownValueChanged(app, event)
if app.KeepCoefficientCheckBox.Value
        return; % Tidak melakukan apa-apa jika Keep Coefficient dicentang
end
    % Auto-update jika ada gambar yang sudah di-load
    if ~isempty(app.PathImageEditField.Value)
        % Re-process jika diperlukan (tanpa fungsi terpisah)
        try
            img = imread(app.PathImageEditField.Value);
            if size(img, 3) == 3
                grayImg = rgb2gray(img);
            else
                grayImg = double(img);
            end
            grayImg = double(grayImg);
            
            wavelength = app.WavelengthDropDown.Value;
            level = str2double(app.DecompositionLevelDropDown.Value);
            
            switch wavelength
                case 'Haar'
                    wname = 'haar';
                case 'Daubechies'
                    wname = 'db4';
                case 'Symlets'
                    wname = 'sym4';
                case 'Coiflets'
                    wname = 'coif2';
                case 'Biorthogonal'
                    wname = 'bior2.2';
                otherwise
                    wname = 'haar';
            end
            
[C, S] = wavedec2(grayImg, level, wname);
            coeffImg = wcodemat(C, S, 'mat', 1);
            imshow(coeffImg, [], 'Parent', app.UIAxes_5);
            title(app.UIAxes_5, 'Wavelet Before Threshold');
        catch       
            % Ignore errors for auto-update
        end
    end
        end

        % Value changed function: DecompositionLevelDropDown
        function DecompositionLevelDropDownValueChanged(app, event)
 if app.KeepCoefficientCheckBox.Value
        return;
 end
    if ~isempty(app.PathImageEditField.Value)
        % Re-process jika diperlukan (tanpa fungsi terpisah)
        try
            img = imread(app.PathImageEditField.Value);
            if size(img, 3) == 3
                grayImg = rgb2gray(img);
            else
                grayImg = double(img);
            end
            grayImg = double(grayImg);
            
            wavelength = app.WavelengthDropDown.Value;
            level = str2double(app.DecompositionLevelDropDown.Value);
            
            switch wavelength
                case 'Haar'
                    wname = 'haar';
                case 'Daubechies'
                    wname = 'db4';
                case 'Symlets'
                    wname = 'sym4';
                case 'Coiflets'
                    wname = 'coif2';
                case 'Biorthogonal'
                    wname = 'bior2.2';
                otherwise
                    wname = 'haar';
            end
            
[C, S] = wavedec2(grayImg, level, wname);
            coeffImg = wcodemat(C, S, 'mat', 1);
            imshow(coeffImg, [], 'Parent', app.UIAxes_5);
            title(app.UIAxes_5, 'Wavelet Before Threshold');
        catch
            % Ignore errors for auto-update
        end
    end
        end

        % Selection changed function: ThresholdingMethodsButtonGroup
        function ThresholdingMethodsButtonGroupSelectionChanged(app, event)
if app.KeepCoefficientCheckBox.Value
        return;
end
    if ~isempty(app.PathImageEditField.Value)
        processImage(app);
    end
        end

        % Value changed function: KeepCoefficientCheckBox
        function KeepCoefficientCheckBoxValueChanged(app, event)
 % Tidak perlu aksi khusus, checkbox hanya mengontrol auto-update behavior
    if app.KeepCoefficientCheckBox.Value
        app.StatusEditField.Value = 'Auto-update disabled';
    else
        app.StatusEditField.Value = 'Auto-update enabled';
        % Jika ada perubahan yang pending, apply sekarang
        if ~isempty(app.PathImageEditField.Value)
    app.StatusEditField.Value = 'Threshold updated. Press Encode to apply.';
        end
     end
        end

        % Value changed function: ThresholdEditField
        function ThresholdEditFieldValueChanged(app, event)
 % Update slider value
    app.ThresholdSlider.Value = app.ThresholdEditField.Value;
    
    if app.KeepCoefficientCheckBox.Value
        return;
    end
    
    if ~isempty(app.PathImageEditField.Value)
    app.StatusEditField.Value = 'Threshold updated. Press Encode to apply.';
    end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.WindowState = 'maximized';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [-505 -52 2371 805];
            app.Image.ImageSource = 'BACKGORUNDDDD.png';

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.BackgroundColor = [0.8314 0.7216 1];
            app.Panel.Position = [29 2 1270 507];

            % Create InputPanel
            app.InputPanel = uipanel(app.Panel);
            app.InputPanel.TitlePosition = 'centertop';
            app.InputPanel.Title = 'Input';
            app.InputPanel.BackgroundColor = [0.9216 0.8588 1];
            app.InputPanel.FontName = 'Bell MT';
            app.InputPanel.FontWeight = 'bold';
            app.InputPanel.FontSize = 15;
            app.InputPanel.Position = [49 352 537 138];

            % Create Button_8
            app.Button_8 = uibutton(app.InputPanel, 'push');
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @Button_8Pushed, true);
            app.Button_8.Icon = 'generative-image (1).png';
            app.Button_8.BackgroundColor = [0.9216 0.8588 1];
            app.Button_8.FontName = 'Bell MT';
            app.Button_8.Position = [279 35 100 70];
            app.Button_8.Text = '';

            % Create Button_7
            app.Button_7 = uibutton(app.InputPanel, 'push');
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @Button_7Pushed, true);
            app.Button_7.Icon = 'CLEAR ALL BUTTON.png';
            app.Button_7.BackgroundColor = [0.9216 0.8588 1];
            app.Button_7.Position = [408 35 100 70];
            app.Button_7.Text = '';

            % Create PathImageEditFieldLabel
            app.PathImageEditFieldLabel = uilabel(app.InputPanel);
            app.PathImageEditFieldLabel.HorizontalAlignment = 'right';
            app.PathImageEditFieldLabel.FontName = 'Bell MT';
            app.PathImageEditFieldLabel.Position = [23 79 61 22];
            app.PathImageEditFieldLabel.Text = 'Path Image';

            % Create PathImageEditField
            app.PathImageEditField = uieditfield(app.InputPanel, 'text');
            app.PathImageEditField.Position = [99 79 154 22];

            % Create StatusEditFieldLabel
            app.StatusEditFieldLabel = uilabel(app.InputPanel);
            app.StatusEditFieldLabel.HorizontalAlignment = 'right';
            app.StatusEditFieldLabel.FontName = 'Bell MT';
            app.StatusEditFieldLabel.Position = [48 44 36 22];
            app.StatusEditFieldLabel.Text = 'Status';

            % Create StatusEditField
            app.StatusEditField = uieditfield(app.InputPanel, 'text');
            app.StatusEditField.Position = [99 44 154 22];

            % Create InputImageLabel
            app.InputImageLabel = uilabel(app.InputPanel);
            app.InputImageLabel.FontName = 'Bell MT';
            app.InputImageLabel.FontWeight = 'bold';
            app.InputImageLabel.Position = [292 5 70 22];
            app.InputImageLabel.Text = 'Input Image';

            % Create ClearImageLabel
            app.ClearImageLabel = uilabel(app.InputPanel);
            app.ClearImageLabel.FontName = 'Bell MT';
            app.ClearImageLabel.FontWeight = 'bold';
            app.ClearImageLabel.Position = [425 6 69 22];
            app.ClearImageLabel.Text = 'Clear Image';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.Panel);
            app.TabGroup.Position = [627 16 603 474];

            % Create RESULTCOMPRESSEDTab
            app.RESULTCOMPRESSEDTab = uitab(app.TabGroup);
            app.RESULTCOMPRESSEDTab.Title = 'RESULT COMPRESSED';
            app.RESULTCOMPRESSEDTab.BackgroundColor = [0.9216 0.8588 1];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.RESULTCOMPRESSEDTab);
            title(app.UIAxes_2, 'Compressed')
            app.UIAxes_2.FontName = 'Bell MT';
            app.UIAxes_2.XTick = [];
            app.UIAxes_2.YTick = [];
            app.UIAxes_2.Position = [304 172 278 267];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.RESULTCOMPRESSEDTab);
            title(app.UIAxes_3, 'Original')
            app.UIAxes_3.FontName = 'Bell MT';
            app.UIAxes_3.XTick = [];
            app.UIAxes_3.YTick = [];
            app.UIAxes_3.Position = [15 171 278 267];

            % Create ResultandMetricsPanel
            app.ResultandMetricsPanel = uipanel(app.RESULTCOMPRESSEDTab);
            app.ResultandMetricsPanel.TitlePosition = 'centertop';
            app.ResultandMetricsPanel.Title = 'Result and Metrics Panel';
            app.ResultandMetricsPanel.BackgroundColor = [0.9216 0.8588 1];
            app.ResultandMetricsPanel.FontName = 'Bell MT';
            app.ResultandMetricsPanel.Position = [148 13 260 143];

            % Create PSNRValueEditFieldLabel
            app.PSNRValueEditFieldLabel = uilabel(app.ResultandMetricsPanel);
            app.PSNRValueEditFieldLabel.HorizontalAlignment = 'right';
            app.PSNRValueEditFieldLabel.FontName = 'Bell MT';
            app.PSNRValueEditFieldLabel.Position = [42 91 67 22];
            app.PSNRValueEditFieldLabel.Text = 'PSNR Value';

            % Create PSNRValueEditField
            app.PSNRValueEditField = uieditfield(app.ResultandMetricsPanel, 'numeric');
            app.PSNRValueEditField.HorizontalAlignment = 'center';
            app.PSNRValueEditField.FontName = 'Bell MT';
            app.PSNRValueEditField.Position = [124 91 100 22];

            % Create CompressionRatioEditFieldLabel
            app.CompressionRatioEditFieldLabel = uilabel(app.ResultandMetricsPanel);
            app.CompressionRatioEditFieldLabel.HorizontalAlignment = 'center';
            app.CompressionRatioEditFieldLabel.FontName = 'Bell MT';
            app.CompressionRatioEditFieldLabel.Position = [33 50 72 26];
            app.CompressionRatioEditFieldLabel.Text = {'Compression '; 'Ratio '};

            % Create CompressionRatioEditField
            app.CompressionRatioEditField = uieditfield(app.ResultandMetricsPanel, 'numeric');
            app.CompressionRatioEditField.HorizontalAlignment = 'center';
            app.CompressionRatioEditField.FontName = 'Bell MT';
            app.CompressionRatioEditField.Position = [124 54 100 22];

            % Create MSEEditFieldLabel
            app.MSEEditFieldLabel = uilabel(app.ResultandMetricsPanel);
            app.MSEEditFieldLabel.HorizontalAlignment = 'center';
            app.MSEEditFieldLabel.FontName = 'Bell MT';
            app.MSEEditFieldLabel.Position = [77 16 31 22];
            app.MSEEditFieldLabel.Text = 'MSE';

            % Create MSEEditField
            app.MSEEditField = uieditfield(app.ResultandMetricsPanel, 'numeric');
            app.MSEEditField.HorizontalAlignment = 'center';
            app.MSEEditField.FontName = 'Bell MT';
            app.MSEEditField.Position = [123 16 100 22];

            % Create WAVELETGRAPHTab
            app.WAVELETGRAPHTab = uitab(app.TabGroup);
            app.WAVELETGRAPHTab.Title = 'WAVELET GRAPH';
            app.WAVELETGRAPHTab.BackgroundColor = [0.9216 0.8588 1];

            % Create UIAxes_5
            app.UIAxes_5 = uiaxes(app.WAVELETGRAPHTab);
            title(app.UIAxes_5, {'Wavelet BeforeThreshold '; '(Wavelet Coefficients)'})
            app.UIAxes_5.FontName = 'Bell MT';
            app.UIAxes_5.XTick = [];
            app.UIAxes_5.YTick = [];
            app.UIAxes_5.Position = [15 171 278 267];

            % Create UIAxes_6
            app.UIAxes_6 = uiaxes(app.WAVELETGRAPHTab);
            title(app.UIAxes_6, {'Wavelet After Threshold'; ' (Thresholded Coefficients)'})
            app.UIAxes_6.FontName = 'Bell MT';
            app.UIAxes_6.XTick = [];
            app.UIAxes_6.YTick = [];
            app.UIAxes_6.Position = [299 173 278 267];

            % Create ResultandMetricsPanel_2
            app.ResultandMetricsPanel_2 = uipanel(app.WAVELETGRAPHTab);
            app.ResultandMetricsPanel_2.TitlePosition = 'centertop';
            app.ResultandMetricsPanel_2.Title = 'Result and Metrics Panel';
            app.ResultandMetricsPanel_2.BackgroundColor = [0.9216 0.8588 1];
            app.ResultandMetricsPanel_2.FontName = 'Bell MT';
            app.ResultandMetricsPanel_2.Position = [148 13 260 143];

            % Create PSNRValueEditField_2Label
            app.PSNRValueEditField_2Label = uilabel(app.ResultandMetricsPanel_2);
            app.PSNRValueEditField_2Label.HorizontalAlignment = 'right';
            app.PSNRValueEditField_2Label.FontName = 'Bell MT';
            app.PSNRValueEditField_2Label.Position = [42 91 67 22];
            app.PSNRValueEditField_2Label.Text = 'PSNR Value';

            % Create PSNRValueEditField_2
            app.PSNRValueEditField_2 = uieditfield(app.ResultandMetricsPanel_2, 'numeric');
            app.PSNRValueEditField_2.HorizontalAlignment = 'center';
            app.PSNRValueEditField_2.FontName = 'Bell MT';
            app.PSNRValueEditField_2.Position = [124 91 100 22];

            % Create CompressionRatioEditField_2Label
            app.CompressionRatioEditField_2Label = uilabel(app.ResultandMetricsPanel_2);
            app.CompressionRatioEditField_2Label.HorizontalAlignment = 'center';
            app.CompressionRatioEditField_2Label.FontName = 'Bell MT';
            app.CompressionRatioEditField_2Label.Position = [33 50 72 26];
            app.CompressionRatioEditField_2Label.Text = {'Compression '; 'Ratio '};

            % Create CompressionRatioEditField_2
            app.CompressionRatioEditField_2 = uieditfield(app.ResultandMetricsPanel_2, 'numeric');
            app.CompressionRatioEditField_2.HorizontalAlignment = 'center';
            app.CompressionRatioEditField_2.FontName = 'Bell MT';
            app.CompressionRatioEditField_2.Position = [124 54 100 22];

            % Create MSEEditField_2Label
            app.MSEEditField_2Label = uilabel(app.ResultandMetricsPanel_2);
            app.MSEEditField_2Label.HorizontalAlignment = 'center';
            app.MSEEditField_2Label.FontName = 'Bell MT';
            app.MSEEditField_2Label.Position = [77 16 31 22];
            app.MSEEditField_2Label.Text = 'MSE';

            % Create MSEEditField_2
            app.MSEEditField_2 = uieditfield(app.ResultandMetricsPanel_2, 'numeric');
            app.MSEEditField_2.HorizontalAlignment = 'center';
            app.MSEEditField_2.FontName = 'Bell MT';
            app.MSEEditField_2.Position = [123 16 100 22];

            % Create ERRORMAPTab
            app.ERRORMAPTab = uitab(app.TabGroup);
            app.ERRORMAPTab.Title = 'ERROR MAP';
            app.ERRORMAPTab.BackgroundColor = [0.9216 0.8588 1];

            % Create UIAxes_7
            app.UIAxes_7 = uiaxes(app.ERRORMAPTab);
            title(app.UIAxes_7, 'Error Map')
            app.UIAxes_7.FontName = 'Bell MT';
            app.UIAxes_7.XTick = [];
            app.UIAxes_7.YTick = [];
            app.UIAxes_7.YTickLabel = '';
            app.UIAxes_7.Position = [66 173 453 267];

            % Create ResultandMetricsPanel_3
            app.ResultandMetricsPanel_3 = uipanel(app.ERRORMAPTab);
            app.ResultandMetricsPanel_3.TitlePosition = 'centertop';
            app.ResultandMetricsPanel_3.Title = 'Result and Metrics Panel';
            app.ResultandMetricsPanel_3.BackgroundColor = [0.9216 0.8588 1];
            app.ResultandMetricsPanel_3.FontName = 'Bell MT';
            app.ResultandMetricsPanel_3.Position = [148 8 260 143];

            % Create PSNRValueEditField_3Label
            app.PSNRValueEditField_3Label = uilabel(app.ResultandMetricsPanel_3);
            app.PSNRValueEditField_3Label.HorizontalAlignment = 'right';
            app.PSNRValueEditField_3Label.FontName = 'Bell MT';
            app.PSNRValueEditField_3Label.Position = [42 91 67 22];
            app.PSNRValueEditField_3Label.Text = 'PSNR Value';

            % Create PSNRValueEditField_3
            app.PSNRValueEditField_3 = uieditfield(app.ResultandMetricsPanel_3, 'numeric');
            app.PSNRValueEditField_3.HorizontalAlignment = 'center';
            app.PSNRValueEditField_3.FontName = 'Bell MT';
            app.PSNRValueEditField_3.Position = [124 91 100 22];

            % Create CompressionRatioEditField_3Label
            app.CompressionRatioEditField_3Label = uilabel(app.ResultandMetricsPanel_3);
            app.CompressionRatioEditField_3Label.HorizontalAlignment = 'center';
            app.CompressionRatioEditField_3Label.FontName = 'Bell MT';
            app.CompressionRatioEditField_3Label.Position = [33 50 72 26];
            app.CompressionRatioEditField_3Label.Text = {'Compression '; 'Ratio '};

            % Create CompressionRatioEditField_3
            app.CompressionRatioEditField_3 = uieditfield(app.ResultandMetricsPanel_3, 'numeric');
            app.CompressionRatioEditField_3.HorizontalAlignment = 'center';
            app.CompressionRatioEditField_3.FontName = 'Bell MT';
            app.CompressionRatioEditField_3.Position = [124 54 100 22];

            % Create MSEEditField_3Label
            app.MSEEditField_3Label = uilabel(app.ResultandMetricsPanel_3);
            app.MSEEditField_3Label.HorizontalAlignment = 'center';
            app.MSEEditField_3Label.FontName = 'Bell MT';
            app.MSEEditField_3Label.Position = [77 16 31 22];
            app.MSEEditField_3Label.Text = 'MSE';

            % Create MSEEditField_3
            app.MSEEditField_3 = uieditfield(app.ResultandMetricsPanel_3, 'numeric');
            app.MSEEditField_3.HorizontalAlignment = 'center';
            app.MSEEditField_3.FontName = 'Bell MT';
            app.MSEEditField_3.Position = [123 16 100 22];

            % Create ControlPanel
            app.ControlPanel = uipanel(app.Panel);
            app.ControlPanel.TitlePosition = 'centertop';
            app.ControlPanel.Title = 'Control Panel';
            app.ControlPanel.BackgroundColor = [0.9216 0.8588 1];
            app.ControlPanel.FontName = 'Bell MT';
            app.ControlPanel.FontWeight = 'bold';
            app.ControlPanel.FontSize = 15;
            app.ControlPanel.Position = [77 16 479 318];

            % Create ThresholdingMethodsButtonGroup
            app.ThresholdingMethodsButtonGroup = uibuttongroup(app.ControlPanel);
            app.ThresholdingMethodsButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @ThresholdingMethodsButtonGroupSelectionChanged, true);
            app.ThresholdingMethodsButtonGroup.TitlePosition = 'centertop';
            app.ThresholdingMethodsButtonGroup.Title = 'Thresholding Methods';
            app.ThresholdingMethodsButtonGroup.FontName = 'Bell MT';
            app.ThresholdingMethodsButtonGroup.Position = [41 26 145 74];

            % Create HardButton
            app.HardButton = uiradiobutton(app.ThresholdingMethodsButtonGroup);
            app.HardButton.Text = 'Hard';
            app.HardButton.FontName = 'Bell MT';
            app.HardButton.Position = [44 28 58 22];
            app.HardButton.Value = true;

            % Create SoftButton
            app.SoftButton = uiradiobutton(app.ThresholdingMethodsButtonGroup);
            app.SoftButton.Text = 'Soft';
            app.SoftButton.FontName = 'Bell MT';
            app.SoftButton.Position = [43 7 65 22];

            % Create KeepCoefficientCheckBox
            app.KeepCoefficientCheckBox = uicheckbox(app.ControlPanel);
            app.KeepCoefficientCheckBox.ValueChangedFcn = createCallbackFcn(app, @KeepCoefficientCheckBoxValueChanged, true);
            app.KeepCoefficientCheckBox.Text = 'Keep Coefficient';
            app.KeepCoefficientCheckBox.FontName = 'Bell MT';
            app.KeepCoefficientCheckBox.Position = [59 115 102 22];

            % Create ThresholdSliderLabel
            app.ThresholdSliderLabel = uilabel(app.ControlPanel);
            app.ThresholdSliderLabel.HorizontalAlignment = 'right';
            app.ThresholdSliderLabel.FontName = 'Bell MT';
            app.ThresholdSliderLabel.Position = [16 172 57 22];
            app.ThresholdSliderLabel.Text = 'Threshold';

            % Create ThresholdSlider
            app.ThresholdSlider = uislider(app.ControlPanel);
            app.ThresholdSlider.ValueChangedFcn = createCallbackFcn(app, @ThresholdSliderValueChanged, true);
            app.ThresholdSlider.FontName = 'Bell MT';
            app.ThresholdSlider.Position = [85 182 150 3];

            % Create ThresholdEditField
            app.ThresholdEditField = uieditfield(app.ControlPanel, 'numeric');
            app.ThresholdEditField.ValueChangedFcn = createCallbackFcn(app, @ThresholdEditFieldValueChanged, true);
            app.ThresholdEditField.HorizontalAlignment = 'center';
            app.ThresholdEditField.FontName = 'Bell MT';
            app.ThresholdEditField.Position = [26 150 46 22];

            % Create WavelengthDropDownLabel
            app.WavelengthDropDownLabel = uilabel(app.ControlPanel);
            app.WavelengthDropDownLabel.HorizontalAlignment = 'center';
            app.WavelengthDropDownLabel.FontName = 'Bell MT';
            app.WavelengthDropDownLabel.Position = [20 250 64 22];
            app.WavelengthDropDownLabel.Text = 'Wavelength';

            % Create WavelengthDropDown
            app.WavelengthDropDown = uidropdown(app.ControlPanel);
            app.WavelengthDropDown.Items = {'Haar', 'Daubechies', 'Symlets', 'Coiflets', 'Biorthogonal '};
            app.WavelengthDropDown.ValueChangedFcn = createCallbackFcn(app, @WavelengthDropDownValueChanged, true);
            app.WavelengthDropDown.FontName = 'Bell MT';
            app.WavelengthDropDown.Position = [111 250 100 22];
            app.WavelengthDropDown.Value = 'Symlets';

            % Create DecompositionLevelDropDownLabel
            app.DecompositionLevelDropDownLabel = uilabel(app.ControlPanel);
            app.DecompositionLevelDropDownLabel.HorizontalAlignment = 'center';
            app.DecompositionLevelDropDownLabel.FontName = 'Bell MT';
            app.DecompositionLevelDropDownLabel.Position = [16 208 82 26];
            app.DecompositionLevelDropDownLabel.Text = {'Decomposition '; 'Level'};

            % Create DecompositionLevelDropDown
            app.DecompositionLevelDropDown = uidropdown(app.ControlPanel);
            app.DecompositionLevelDropDown.Items = {'1', '2', '3', '4', '5'};
            app.DecompositionLevelDropDown.ValueChangedFcn = createCallbackFcn(app, @DecompositionLevelDropDownValueChanged, true);
            app.DecompositionLevelDropDown.FontName = 'Bell MT';
            app.DecompositionLevelDropDown.Position = [115 212 100 22];
            app.DecompositionLevelDropDown.Value = '1';

            % Create Button_10
            app.Button_10 = uibutton(app.ControlPanel, 'push');
            app.Button_10.ButtonPushedFcn = createCallbackFcn(app, @Button_10Pushed, true);
            app.Button_10.Icon = 'encoder.png';
            app.Button_10.BackgroundColor = [0.9216 0.8588 1];
            app.Button_10.FontName = 'Bell MT';
            app.Button_10.Position = [279 211 100 70];
            app.Button_10.Text = '';

            % Create Button_9
            app.Button_9 = uibutton(app.ControlPanel, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @Button_9Pushed, true);
            app.Button_9.Icon = 'ocr.png';
            app.Button_9.BackgroundColor = [0.9216 0.8588 1];
            app.Button_9.FontName = 'Bell MT';
            app.Button_9.Position = [279 121 100 70];
            app.Button_9.Text = '';

            % Create Button_11
            app.Button_11 = uibutton(app.ControlPanel, 'push');
            app.Button_11.ButtonPushedFcn = createCallbackFcn(app, @Button_11Pushed, true);
            app.Button_11.Icon = 'CLEAR ALL BUTTON.png';
            app.Button_11.BackgroundColor = [0.9216 0.8588 1];
            app.Button_11.FontName = 'Bell MT';
            app.Button_11.Position = [279 31 100 70];
            app.Button_11.Text = '';

            % Create EncodeLabel
            app.EncodeLabel = uilabel(app.ControlPanel);
            app.EncodeLabel.FontName = 'Bell MT';
            app.EncodeLabel.FontWeight = 'bold';
            app.EncodeLabel.Position = [393 239 44 22];
            app.EncodeLabel.Text = 'Encode';

            % Create DecodeLabel
            app.DecodeLabel = uilabel(app.ControlPanel);
            app.DecodeLabel.FontName = 'Bell MT';
            app.DecodeLabel.FontWeight = 'bold';
            app.DecodeLabel.Position = [393 148 45 22];
            app.DecodeLabel.Text = 'Decode';

            % Create ClearAllLabel
            app.ClearAllLabel = uilabel(app.ControlPanel);
            app.ClearAllLabel.FontName = 'Bell MT';
            app.ClearAllLabel.FontWeight = 'bold';
            app.ClearAllLabel.Position = [393 59 52 22];
            app.ClearAllLabel.Text = 'Clear All';

            % Create Button
            app.Button = uibutton(app.UIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.Icon = 'HOME BUTTON.png';
            app.Button.BackgroundColor = [0.9882 0.9608 0.902];
            app.Button.Position = [1753 557 100 86];
            app.Button.Text = '';

            % Create Button_2
            app.Button_2 = uibutton(app.UIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.Icon = 'THEORY BUTTON.png';
            app.Button_2.BackgroundColor = [0.9882 0.9608 0.902];
            app.Button_2.Position = [1753 694 100 86];
            app.Button_2.Text = '';

            % Create Button_3
            app.Button_3 = uibutton(app.UIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.Icon = 'GUIDELINE BUTTON.png';
            app.Button_3.BackgroundColor = [0.9882 0.9608 0.902];
            app.Button_3.Position = [1766 373 100 86];
            app.Button_3.Text = '';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = simsim

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end