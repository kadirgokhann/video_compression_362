classdef ZigZagScan
    properties (Constant)
         indexOrder = [
         1  2  6  7 15 16 28 29;
         3  5  8 14 17 27 30 43;
         4  9 13 18 26 31 42 44;
        10 12 19 25 32 41 45 54;
        11 20 24 33 40 46 53 55;
        21 23 34 39 47 52 56 61;
        22 35 38 48 51 57 60 62;
        36 37 49 50 58 59 63 64];
    end

    methods (Static)
        function [x, y] = GetCoordinates(val)  
            % This can be calculated once and put it to a map.
            if val > 64 || val < 1
                disp("GetCoordinates:: val is problematic!");
            end
            for i = 1:8
                for j = 1:8
                    if ZigZagScan.indexOrder(i,j) == val
                        x = i;
                        y = j;
                        return;
                    end
                end
            end
        end
% 2.2.3 Zigzag Scan and Run-Length Encoding (RLE)
% After quantization, the 8×8 block is converted into a 1D vector using a zigzag scan. 
% This ordering places low-frequency coefficients (which are typically non-zero) at the 
% beginning and high-frequency coefficients (usually zeros) at the end.
% To further compress the data, Run-Length Encoding (RLE) is applied to the zigzag vector. RLE 
% replaces consecutive zero values with a pair (run length, value), where run length is the number 
% of times value consecutively repeats in the original sequence. This significantly reduces the storage
% needed for sparse coefficient vectors.
% Example:
% Zigzag vector:  [12, -3, 0, 0, 0, 5, 0, 0, 0, 0, -1]
% RLE output:     [(1,12), (1,-3), (3,0), (1,5), (4,0), (1,-1)]
% This combination of DCT, quantization, zigzag scanning, and RLE forms the basis of many image and 
% video compression standards, including JPEG and MPEG.

        function zz = ProcessMB(block)
            zz = zeros(1, Constants.MACROBLOCKSIZE() * Constants.MACROBLOCKSIZE());
       
            for i = 1:Constants.MACROBLOCKSIZE() * Constants.MACROBLOCKSIZE()
                [x, y]  = ZigZagScan.GetCoordinates(i);
                zz(i)   = block(x, y);
            end
        end

        function frameZigZagged = ProcessRGB(frameQuantized)
            frameZigZagged   = struct('R', [], 'G', [], 'B', []);
            frameZigZagged.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameZigZagged.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameZigZagged.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                   frameZigZagged.R{x,y} = ZigZagScan.ProcessMB(frameQuantized.R{x,y});
                   frameZigZagged.G{x,y} = ZigZagScan.ProcessMB(frameQuantized.G{x,y});
                   frameZigZagged.B{x,y} = ZigZagScan.ProcessMB(frameQuantized.B{x,y});
                end
             end
        end
% -------------------------------------------------------------------------
        function block = InvertMB(zz)
            block = zeros(Constants.MACROBLOCKSIZE, Constants.MACROBLOCKSIZE);
        
            for i = 1:Constants.MACROBLOCKSIZE * Constants.MACROBLOCKSIZE
                [x, y]      = ZigZagScan.GetCoordinates(i);
                block(x, y) = zz(i);
            end
        end

        function frameQuantized = InvertRGB(frameZigZagged)
            frameQuantized   = struct('R', [], 'G', [], 'B', []);
            frameQuantized.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameQuantized.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameQuantized.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                   frameQuantized.R{x,y} = ZigZagScan.InvertMB(frameZigZagged.R{x,y});
                   frameQuantized.G{x,y} = ZigZagScan.InvertMB(frameZigZagged.G{x,y});
                   frameQuantized.B{x,y} = ZigZagScan.InvertMB(frameZigZagged.B{x,y});
                end
             end
        end
% -------------------------------------------------------------------------
    end
end
