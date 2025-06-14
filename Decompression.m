classdef Decompression
  methods (Static)

        function FrameInMB = Invert(FrameInRLE)
            D_FrameInZigZagged  = RLE.         InvertRGB(FrameInRLE);
            D_FrameQuantized    = ZigZagScan.  InvertRGB(D_FrameInZigZagged);
            D_FrameInDCT        = Quantization.InvertRGB(D_FrameQuantized, '0');
            FrameInMB           = DCT.         InvertRGB(D_FrameInDCT);
        end
        
        function framesReconstructedInMB = Decompress(GOPSREAD)
            framesReconstructedInMB = cell(1, Constants.FRAMELENGTH);
            frameId                 = 1;
            running                 = true;
            while running
                for i = 1:size(GOPSREAD, 2)
                    currentGop = GOPSREAD{i};
            
                    iFrameProcessed = false;
                    lastFrame       = [];
                    for j = 1:size(currentGop, 2)
                        fprintf("Processing frame %03d of GOP %d\n", frameId, i);
                        currentFrame = currentGop{j};
                        if isempty(currentFrame)
                            running = false;
                            break;
                        end
                        
                        if iFrameProcessed == false
                            framesReconstructedInMB{frameId} = Decompression.Invert(currentFrame);
                            lastFrame                        = framesReconstructedInMB{frameId};
                            frameId                          = frameId + 1;
                            iFrameProcessed                  = true;
                        else
                            if isempty(lastFrame)
                                disp('lastFrame == nullptr');
                            end
                            pFrame                           = Decompression.Invert(currentFrame);
                            framesReconstructedInMB{frameId} = Utils.AccumulateRGB(lastFrame, pFrame);
                            lastFrame                        = framesReconstructedInMB{frameId};
                            frameId                          = frameId + 1;
                        end
            
                    end
                    if running == false
                        break;
                    end
                end
                running = false;
            end
        end
        


        function images = ConvertToImg(frames)
            images = cell(1, Constants.FRAMELENGTH());
            for i = 1:Constants.FRAMELENGTH()
                filename = sprintf('decompressed/frame%03d.jpg', i);
                frameEx  = zeros(Constants.H(), Constants.H(), 3);
            
                for x = 1:Constants.MB_ROWS()
                    xStart = (x - 1) * 8 + 1;
                    xEnd   = xStart + 7;
                    for y = 1:Constants.MB_COLS()
            
                        yStart = (y - 1) * 8 + 1;
                        yEnd   = yStart + 7;
            
                        frameEx(xStart:xEnd, yStart:yEnd, 1) = frames{i}.R{x,y};
                        frameEx(xStart:xEnd, yStart:yEnd, 2) = frames{i}.G{x,y};
                        frameEx(xStart:xEnd, yStart:yEnd, 3) = frames{i}.B{x,y};
                    end
                end
            
                frameEx = uint8(min(max(frameEx, 0), 255));
                imwrite(frameEx, filename);
                images{i} = frameEx;
            end
        end

        function framesReconstructedInMB = DecompressImproved(GOPSREAD)
            Constants.SET_GOP_SIZE(30);
            framesReconstructedInMB = cell(1, Constants.FRAMELENGTH);
            pattern = Utils.GetPattern();
            disp(pattern);
        
            frameId     = 1;
            gopIndex    = 1;
            
            while frameId <= Constants.FRAMELENGTH
                if gopIndex > length(GOPSREAD)
                    break;
                end
                currentGop = GOPSREAD{gopIndex};
                gopLength = length(currentGop);
            
                futureFrames = cell(1, Constants.GOP_SIZE());
            
                for j = 1:gopLength
                    currentType = pattern(j);
                    if isempty(currentGop{j})
                        break;
                    end
                    if frameId ==  Constants.FRAMELENGTH()  && currentType == 'B'
                        currentType = 'P';
                    end
                    if frameId + 1 == Constants.FRAMELENGTH() && currentType == 'B' && pattern(i+1) == 'B'
                        currentType = 'P';
                    end          
            
                    fprintf("Processing frame %03d of GOP %d (%s-frame)\n", frameId, gopIndex, currentType);
                    currentFrame = currentGop{j};
            
                    switch currentType
                        case 'I'
                            decoded            = Decompression.InvertWType(currentFrame, currentType);
                            futureFrames{j}    = decoded;
                            lastIorP           = decoded;
                            lastFrame          = decoded;
                            framesReconstructedInMB{frameId} = decoded;
                            frameId            = frameId + 1;
            
                        case 'P'
                            residual        = Decompression.InvertWType(currentFrame, currentType);
                            decoded         = Utils.AccumulateRGB(lastIorP, residual);
                            futureFrames{j} = decoded;
                            lastIorP        = decoded;
                            lastFrame       = decoded;
                            framesReconstructedInMB{frameId} = decoded;
                            frameId         = frameId + 1;
            
                        case 'B'
                            prevRef = lastIorP;
                            nextRef = [];
            
                            for k = j+1:gopLength
                                if pattern(k) ~= 'B' && ~isempty(currentGop{k})
                                    tempDecoded = futureFrames{k};
                                    if isempty(tempDecoded)
                                        tempDecoded = Decompression.InvertWType(currentGop{k}, currentType);
                                        if pattern(k) == 'P'
                                            tempDecoded = Utils.AccumulateRGB(lastFrame, tempDecoded);
                                        end
                                        futureFrames{k} = tempDecoded;
                                    end
                                    nextRef = tempDecoded;
                                    break;
                                end
                            end
            
                            if isempty(nextRef)
          
                                residual = Decompression.InvertWType(currentFrame, currentType);
                                decoded = Utils.AccumulateRGB(lastFrame, residual);
                                lastIorP = decoded;
                                lastFrame = decoded;
                            else
                                prediction = Utils.GetBidirectionalPredictionRGB(prevRef, nextRef);
                                residual = Decompression.InvertWType(currentFrame, currentType);
                                decoded = Utils.AccumulateRGB(prediction, residual);
                            end
            
                            framesReconstructedInMB{frameId} = decoded;
                            lastFrame = decoded;
                            frameId = frameId + 1;
                    end
                end
                gopIndex = gopIndex + 1;
            end
        end


        function FrameInMB = InvertWType(FrameInRLE, currentType)
            D_FrameInZigZagged  = RLE.         InvertRGB(FrameInRLE);
            D_FrameQuantized    = ZigZagScan.  InvertRGB(D_FrameInZigZagged);
            D_FrameInDCT        = Quantization.InvertRGB(D_FrameQuantized, currentType);
            FrameInMB           = DCT.         InvertRGB(D_FrameInDCT);
        end


  end
end