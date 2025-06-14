classdef Compression
  methods (Static)
% ------------------------------------------------------------------------
    function GOPS = Compress(framesInMacroBlocks)
        
        GOPS        = cell(1, ceil(Constants.FRAMELENGTH/Constants.GOP_SIZE()));
        running     = true;
        frameIndex  = 1;
        gopIndex    = 1;
        
        while running
            iFrameProcessed = false;
            CURRENTGOP      = cell(1, Constants.GOP_SIZE());
            lastFrame       = [];
            for i = 1:Constants.GOP_SIZE()
                if frameIndex > Constants.FRAMELENGTH
                    running = false;
                    break;
                end
                fprintf("Compressing frame %03d of GOP %d\n", frameIndex, gopIndex);
                
                currentFrame    = framesInMacroBlocks{frameIndex};
                frameIndex      = frameIndex + 1;
                processedFrame  = [];
        
                if iFrameProcessed == false
                    % ---- IFrames --------------------------------------------
                    IFrameInDCT             = DCT.          ProcessRGB(currentFrame);
                    IFrameQuantized         = Quantization. ProcessRGB(IFrameInDCT, '0');
                    IFrameZigZagged         = ZigZagScan.   ProcessRGB(IFrameQuantized);
                    IFrameInRLE             = RLE.          ProcessRGB(IFrameZigZagged);
                    % ---------------------------------------------------------
                    processedFrame          = IFrameInRLE;
                    iFrameProcessed         = true;
                else
                    % ---- PFrames --------------------------------------------
                    ResidualFrame           = Utils.GetResidualRGB(currentFrame, lastFrame);
                    ResidualFrameInDCT      = DCT.          ProcessRGB(ResidualFrame);
                    ResidualFrameQuantized  = Quantization. ProcessRGB(ResidualFrameInDCT, '0');
                    ResidualFrameZigZagged  = ZigZagScan.   ProcessRGB(ResidualFrameQuantized);
                    ResidualFrameInRLE      = RLE.          ProcessRGB(ResidualFrameZigZagged);
                    % ---------------------------------------------------------
                    processedFrame          = ResidualFrameInRLE;
                end
                if isempty(processedFrame)
                    disp("ERROR: processedFrame is somehow null!");
                end
                CURRENTGOP{i} = processedFrame;
                lastFrame     = currentFrame;
            end
            GOPS{gopIndex}  = CURRENTGOP;
            gopIndex        = gopIndex + 1;
        end
        lastGop           = GOPS{gopIndex-1};
        GOPS{gopIndex-1}  = lastGop(~cellfun('isempty', lastGop));
        Utils.WriteGopsToFile(GOPS);
    end
 % ------------------------------------------------------------------------
    function GOPS = CompressImproved(c_framesInMacroBlocks)
        
        GOPS        = cell(1, ceil(Constants.FRAMELENGTH()/Constants.GOP_SIZE()));
        frameIndex  = 1;
        gopIndex    = 1;
        pattern     = Utils.GetPattern();
        disp(pattern);
        
        while frameIndex <= Constants.FRAMELENGTH()
            CURRENTGOP        = cell(1, Constants.GOP_SIZE());
            futureFrameBuffer = cell(1, Constants.GOP_SIZE());
        
            for i = 1:Constants.GOP_SIZE()
                index = frameIndex + i - 1;
                if index <= Constants.FRAMELENGTH()
                    futureFrameBuffer{i} = c_framesInMacroBlocks{index};
                end
            end
            %isLeft = false;
            for i = 1:length(pattern)
                currentType = pattern(i);
                if isempty(futureFrameBuffer{i})
                    break;
                end
                if frameIndex ==  Constants.FRAMELENGTH()  && currentType == 'B'
                    currentType = 'P';
                end
                if frameIndex + 1 == Constants.FRAMELENGTH() && currentType == 'B' && pattern(i+1) == 'B'
                    currentType = 'P';
                end                    

        
                fprintf("Compressing frame %03d of GOP %d (%s-frame)\n", frameIndex, gopIndex, currentType);
        
                currentFrame    = futureFrameBuffer{i};
                processedFrame  = [];
        
                switch currentType
                    case 'I'
                        % Intra Frame
                        dct             = DCT.         ProcessRGB(currentFrame);
                        quant           = Quantization.ProcessRGB(dct, currentType);
                        zigzag          = ZigZagScan.  ProcessRGB(quant);
                        processedFrame  = RLE.         ProcessRGB(zigzag);
                        lastIorP        = currentFrame;
        
                    case 'P'
                        % Predicted Frame (forward)
                        residual        = Utils.GetResidualRGB(currentFrame, lastIorP);
                        dct             = DCT.         ProcessRGB(residual);
                        quant           = Quantization.ProcessRGB(dct, currentType);
                        zigzag          = ZigZagScan.  ProcessRGB(quant);
                        processedFrame  = RLE.         ProcessRGB(zigzag);
                        lastIorP        = currentFrame;
                        
                    case 'B'
                        prevRef = lastIorP;
                        nextRef = [];
        
                        for j = i+1:length(pattern)
                            if pattern(j) ~= 'B' && ~isempty(futureFrameBuffer{j})
                                nextRef = futureFrameBuffer{j};
                                break;
                            end
                        end
                        
                        if isempty(nextRef)
                            disp(sprintf("Creating P-frame instead of B-frame at index %d due to missing forward reference", i));
                        end
                        predicted       = Utils.GetBidirectionalPredictionRGB( prevRef, nextRef);
                        residual        = Utils.GetResidualRGB(currentFrame, predicted);
                        dct             = DCT.         ProcessRGB(residual);
                        quant           = Quantization.ProcessRGB(dct, currentType);
                        zigzag          = ZigZagScan.  ProcessRGB(quant);
                        processedFrame  = RLE.         ProcessRGB(zigzag);
                end
                lastFrame       = currentFrame;
                CURRENTGOP{i}   = processedFrame;
                frameIndex      = frameIndex + 1;
            end
        
            % Remove empty frames at end
            CURRENTGOP      = CURRENTGOP(~cellfun('isempty', CURRENTGOP));
            GOPS{gopIndex}  = CURRENTGOP;
        
            gopIndex        = gopIndex + 1;
        end
        
        Utils.WriteGopsToFile(GOPS);
    end
 % ------------------------------------------------------------------------
  end
end