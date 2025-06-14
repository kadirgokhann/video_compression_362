classdef DCT
    methods (Static)
% 2.2.1 Discrete Cosine Transform (DCT) -----------------------------------
% The Discrete Cosine Transform (DCT) is used to convert spatial-domain image data into the frequency 
% domain. For an 8 × 8 image block B, the 2D DCT produces a new matrix C of the same size. The 
% coefficients Cu,v represent the block’s frequency content, where low frequencies are concentrated 
% toward the top-left.
% In practice, most of the visually important information is retained in a few low frequency DCT
% coefficients. High-frequency coefficients can be approximated or discarded.
% In MATLAB, dct2 and idct2 functions can be used to calculate DCT and its inverse transform.
        
        function frameInDCT = ProcessRGB(frameInMB)
            frameInDCT   = struct('R', [], 'G', [], 'B', []);
            frameInDCT.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInDCT.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInDCT.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                 for y = 1:Constants.MB_COLS()
                    mbR                  = frameInMB.R{x,y};
                    frameInDCT.R{x,y}    = dct2(mbR);

                    mbG                  = frameInMB.G{x,y};
                    frameInDCT.G{x,y}    = dct2(mbG);

                    mbB                  = frameInMB.B{x,y};
                    frameInDCT.B{x,y}    = dct2(mbB);
                 end
            end
        end
    
% -------------------------------------------------------------------------
function frameInDCT = ProcessMotionVector(frameInMB)
            frameInDCT   = struct('R', [], 'G', [], 'B', []);
            frameInDCT.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInDCT.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInDCT.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                 for y = 1:Constants.MB_COLS()
                    mbR                  = frameInMB.R{x,y};
                    frameInDCT.R{x,y}    = dct2(mbR);

                    mbG                  = frameInMB.G{x,y};
                    frameInDCT.G{x,y}    = dct2(mbG);

                    mbB                  = frameInMB.B{x,y};
                    frameInDCT.B{x,y}    = dct2(mbB);
                 end
            end
        end
    
% -------------------------------------------------------------------------
        function frameInMB = Invert(frameInDCT)
            frameInMB = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                 for y = 1:Constants.MB_COLS()
                    mb             = frameInDCT{x,y};
                    frameInMB{x,y} = idct2(mb);
                 end
            end
        end
        function frameInMB = InvertRGB(frameInDCT)
            frameInMB   = struct('R', [], 'G', [], 'B', []);
            frameInMB.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInMB.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInMB.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                 for y = 1:Constants.MB_COLS()
                    mbR               = frameInDCT.R{x,y};
                    frameInMB.R{x,y}  = idct2(mbR);

                    mbG               = frameInDCT.G{x,y};
                    frameInMB.G{x,y}  = idct2(mbG);
                    
                    mbB               = frameInDCT.B{x,y};
                    frameInMB.B{x,y}  = idct2(mbB);
                 end
            end
        end
% -------------------------------------------------------------------------
    end
end
