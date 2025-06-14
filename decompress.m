% ---------------------------------------------------------------------.
% Constant values are in Constants.m file, they can be updated there.  | 
% ---------------------------------------------------------------------. 

% 3 System Overview
% 3.1 High-Level Encoding and Decoding Pipeline
% --- • Decoding Pipeline:
% --- 1. Read and parse the bytestream.

% GOPSREAD = Utils.ReadFromFile();

% --- 2. For I-frames, decode each macroblock directly via inverse RLE, inverse zigzag scan, dequantization, 
%        and inverse DCT.
    %D_IFrameInRLE       = GOPSREAD{1}{1};
    %D_IFrameZigZagged   = RLE.         InvertRGB(D_IFrameInRLE);
    %D_IFrameQuantized   = ZigZagScan.  InvertRGB(D_IFrameZigZagged);
    %D_IFrameInDCT       = Quantization.InvertRGB(D_IFrameQuantized);
    %D_IFrameInMB        = DCT.         InvertRGB(D_IFrameInDCT);

% --- 3. For P-frames, reconstruct the residual macroblocks and add them to the pre- vious reconstructed 
%        frame.
    %D_ResidualFrameInRLE       = GOPSREAD{1}{2};
    %D_ResidualFrameZigZagged   = RLE.           InvertRGB(D_ResidualFrameInRLE);
    %D_ResidualFrameQuantized   = ZigZagScan.    InvertRGB(D_ResidualFrameZigZagged);
    %D_ResidualFrameInDCT       = Quantization.  InvertRGB(D_ResidualFrameQuantized);
    %D_ResidualFrame            = DCT.           InvertRGB(D_ResidualFrameInDCT);
    %D_PFrame                   = Utils.AccumulateRGB(D_ResidualFrame, D_IFrameInMB);

% 4. Reassemble macroblocks into full frame images.



d_GOPSREAD      = Utils.ReadFromFile();
d_frames        = Decompression.Decompress(d_GOPSREAD);
clear GOPSREAD;
d_images =       Decompression.ConvertToImg(d_frames);
clear frames;
clear d_images;
