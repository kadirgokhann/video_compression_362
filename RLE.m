classdef RLE
    methods (Access = private, Static)
% Zigzag vector:  [12, -3, 0, 0, 0, 5, 0, 0, 0, 0, -1]
% RLE output:     [(1,12), (1,-3), (3,0), (1,5), (4,0), (1,-1)]
% Run-Length Encoding (RLE)
        function rle = RLEInternal(input)
            lastElement = 0;
            count       = 0;
            init        = false;
            rle         = [];
            
            for i = 1:length(input)
                if init == false
                    count       = count + 1;
                    init        = true;
                    lastElement = input(i);
                    continue
                end
        
                if input(i) == lastElement
                    count = count + 1;
                end
                if input(i) ~= lastElement
                    rle     = [rle; count, lastElement];
                    count   = 1;
                end
                lastElement = input(i);
            end
        
            if count > 0
                rle         = [rle; count, lastElement];
            end
        end
     end
     methods (Static)
        function frameInRLE = ProcessRGB(frameZigZagged)
             frameInRLE    = struct('R', [], 'G', [], 'B', []);
             frameInRLE.R  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             frameInRLE.G  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             frameInRLE.B  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    frameInRLE.R{x,y} = RLE.RLEInternal(frameZigZagged.R{x,y});
                    frameInRLE.G{x,y} = RLE.RLEInternal(frameZigZagged.G{x,y});
                    frameInRLE.B{x,y} = RLE.RLEInternal(frameZigZagged.B{x,y});
                end
             end
        end

        
% -------------------------------------------------------------------------      
        % Run-Length Encoding (RLE)
        function ZigZagVector = InvertInternal(input)
            % Zigzag vector:  [12, -3, 0, 0, 0, 5, 0, 0, 0, 0, -1]
            % RLE output:     [(1,12), (1,-3), (3,0), (1,5), (4,0), (1,-1)]
        
            ZigZagVector = [];
            for i = 1:size(input,1)
                numberOf        = input(i,1);
                number          = input(i,2);
                ZigZagVector    = [ZigZagVector, repmat(number, 1, numberOf)];
            end
        end
        

        function frameInMBZigZagged = InvertRGB(frameInRLE)
             frameInMBZigZagged    = struct('R', [], 'G', [], 'B', []);
             frameInMBZigZagged.R  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             frameInMBZigZagged.G  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             frameInMBZigZagged.B  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
             for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    frameInMBZigZagged.R{x,y} = RLE.InvertInternal(frameInRLE.R{x,y});
                    frameInMBZigZagged.G{x,y} = RLE.InvertInternal(frameInRLE.G{x,y});
                    frameInMBZigZagged.B{x,y} = RLE.InvertInternal(frameInRLE.B{x,y});
                end
             end
        end

    end
end
