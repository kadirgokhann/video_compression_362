% ---------------------------------------------------------------------.
% Constant values are in Constants.m file, they can be updated there.
Constants.SET_GOP_SIZE(30);
% ---------------------------------------------------------------------.

% 3 System Overview
% 3.1 High-Level Encoding and Decoding Pipeline
% --- • Encoding Pipeline:
% --- 1. Read and preprocess input image frames.
        % function y = ReadFramesUnprocessed()
        %     y = cell(1, Constants.FRAMELENGTH);
        %     for i = 1:Constants.FRAMELENGTH
        %         filename    = sprintf('video_data/frame%03d.jpg', i);
        %         image       = imread(filename);
        %         y{i}        = struct('R', [], 'G', [], 'B', []);
        %         y{i}.R      = double(image(:, :, 1));
        %         y{i}.G      = double(image(:, :, 2));
        %         y{i}.B      = double(image(:, :, 3));
        %     end
        % end

% --- 2. Divide each frame into fixed-size macroblocks (e.g., 8 × 8).
        % function y = ConvertMacroBlocks(framesUnprocessed)
        %     y = cell(1, Constants.FRAMELENGTH);
        %     for i = 1:Constants.FRAMELENGTH
        %         y{i}.R  = Utils.frame_to_mb(framesUnprocessed{i}.R);
        %         y{i}.G  = Utils.frame_to_mb(framesUnprocessed{i}.G);
        %         y{i}.B  = Utils.frame_to_mb(framesUnprocessed{i}.B);
        %     end
        % end


% --- 3. For I-frames, apply DCT, quantization, zigzag scan, and run-length encoding 
% to each macroblock.
    %E_1IFrameInMB          = framesInMacroBlocks{1};
    %E_2IFrameInDCT         = DCT.            ProcessRGB(E_1IFrameInMB);
    %E_3IFrameQuantized     = Quantization.   ProcessRGB(E_2IFrameInDCT);
    %E_4IFrameZigZagged     = ZigZagScan.     ProcessRGB(E_3IFrameQuantized);
    %E_5IFrameInRLE         = RLE.            ProcessRGB(E_4IFrameZigZagged);

% 4. For P-frames, compute the residual with respect to the previous frame, and apply
%     the same compression steps to the residual blocks.
% • Compute the residual by subtracting the corresponding macroblock from the pre- vious frame:
% • Apply DCT to the residual block.
% • Quantize, zigzag, and RLE encode as in the I-frame.

    %E_6PFrame                  = framesInMacroBlocks{2};
    %E_7ResidualFrame           = Utils.GetResidualRGB(E_6PFrame, E_1IFrameInMB);
    %E_8ResidualFrameInDCT      = DCT.         ProcessRGB(E_7ResidualFrame);
    %E_9ResidualFrameQuantized  = Quantization.ProcessRGB(E_8ResidualFrameInDCT);
    %E_ResidualFrameZigZagged   = ZigZagScan.  ProcessRGB(E_9ResidualFrameQuantized);
    %E_ResidualFrameInRLE       = RLE.         ProcessRGB(E_ResidualFrameZigZagged);

%(10 pts) Plot compression ratio] with respect to GOP sizes 1 (all I frames) to 30 
% (I + 29 P frames). Compressed size is the size of your encoded binary. 
% Uncompressed size is 480×360×24×120 bits.
%Report: Include this plot in your report and provide a brief commentary.
%for i = 1:30
%    Constants.SET_GOP_SIZE(i);
%    Compress(framesInMacroBlocks);
%end

c_framesUnprocessed       = Utils.ReadFramesUnprocessed(true);
c_framesInMacroBlocks     = Utils.ConvertMacroBlocks(c_framesUnprocessed);
clear c_framesUnprocessed;

c_GOPSCOMPRESSED          = Compression.Compress(c_framesInMacroBlocks);
clear c_GOPSCOMPRESSED;
clear c_framesInMacroBlocks;
