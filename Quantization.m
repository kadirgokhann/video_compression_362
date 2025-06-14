classdef Quantization
  properties (Constant, Access = public)
            Qmat = [ ...
                16 11 10 16 24  40  51  61;
                12 12 14 19 26  58  60  55;
                14 13 16 24 40  57  69  56;
                14 17 22 29 51  87  80  62;
                18 22 37 56 68 109 103  77;
                24 35 55 64 81 104 113  92;
                49 64 78 87 103 121 120 101;
                72 92 95 98 112 100 103  99 ];
            
            Q_I = [ ...
                 8  16  19  22  26  27  29  34;
                16  16  22  24  27  29  34  37;
                19  22  26  27  29  34  34  38;
                22  22  26  27  29  34  37  40;
                22  26  27  29  32  35  40  48;
                26  27  29  32  35  40  48  58;
                26  27  29  34  38  46  56  69;
                27  29  35  38  46  56  69  83
            ];
            Q_P = round(Quantization.Q_I * 1.2);
            Q_B = round(Quantization.Q_I * 1.5);
  end
  methods (Static)
% 2.2.2 Quantization
% Quantization is the process of reducing the precision of the DCT coefficients, introducing 
% controlled loss of information to achieve compression. Each DCT coefficient is divided by a 
% corresponding value from a quantization matrix (element-wise) and rounded
% to the nearest integer.
% Quantization reduces the number of bits needed to represent the DCT coefficients, especially at 
% higher frequencies, where human vision is less sensitive to error. A coarser quantization matrix 
% leads to greater compression at the expense of image quality.


        function frameQuantizated = ProcessRGB(frameInDCT, frameType)
            switch frameType
                case 'I'
                    MATRIX = Quantization.Qmat;
                case 'P'
                    MATRIX = Quantization.Qmat;
                case 'B'
                    MATRIX = Quantization.Qmat;
                case '0'
                    MATRIX = Quantization.Qmat;
            end

            
            frameQuantizated    = struct('R', [], 'G', [], 'B', []);
            frameQuantizated.R  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameQuantizated.G  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameQuantizated.B  = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    mbInDCTR                  = frameInDCT.R{x,y};
                    frameQuantizated.R{x, y}  = round(mbInDCTR ./ MATRIX);
                    
                    mbInDCTG                  = frameInDCT.G{x,y};
                    frameQuantizated.G{x, y}  = round(mbInDCTG ./ MATRIX);
                    
                    mbInDCTB                  = frameInDCT.B{x,y};
                    frameQuantizated.B{x, y}  = round(mbInDCTB ./ MATRIX);
                end
            end
        end
        
% -------------------------------------------------------------------------
        function frameInDCT = InvertRGB(frameQuantizated, frameType)
           switch frameType
                case 'I'
                    MATRIX = Quantization.Qmat;
                case 'P'
                    MATRIX = Quantization.Qmat;
                case 'B'
                    MATRIX = Quantization.Qmat;
                case '0'
                    MATRIX = Quantization.Qmat;
            end



            frameInDCT   = struct('R', [], 'G', [], 'B', []);
            frameInDCT.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInDCT.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            frameInDCT.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    mbInQuantizedR      = double(frameQuantizated.R{x,y});
                    frameInDCT.R{x, y}  = mbInQuantizedR .* MATRIX;
                    
                    mbInQuantizedG      = double(frameQuantizated.G{x,y});
                    frameInDCT.G{x, y}  = mbInQuantizedG .* MATRIX;

                    mbInQuantizedB      = double(frameQuantizated.B{x,y});
                    frameInDCT.B{x, y}  = mbInQuantizedB .* MATRIX;
                end
            end
        end
% -------------------------------------------------------------------------
    end
end



