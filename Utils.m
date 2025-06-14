classdef Utils
    methods (Static)
% -------------------------------------------------------------------------
        function frame = mb_to_frame(mb_cells)
            [mb_h, mb_w] = size(mb_cells);
            frame = zeros(mb_h*8, mb_w*8, 3);
        
            for i = 1:mb_h
                for j = 1:mb_w
                    pos_i = (i-1)*8 + 1;
                    pos_j = (j-1)*8 + 1;
                    frame(pos_i:pos_i+7, pos_j:pos_j+7, :) = mb_cells(i, j);
                end
            end  
        end
% -------------------------------------------------------------------------
        % Given a frame (H, W, c)
        % Convert it into macroblock representation
        % returns a structure cell{mb_i, mb_j} = arr(8, 8, 3)
        function mb_cells = frame_to_mb(frame)
            [H, W, c] = size(frame);
            mb_h = H / 8;
            mb_w = W / 8;
            mb_cells = cell(mb_h, mb_w);
            for i = 1:mb_h
                for j = 1:mb_w
                    pos_i = (i-1)*8 + 1;
                    pos_j = (j-1)*8 + 1;
                    mb_cells{i, j} = frame(pos_i:pos_i+7, pos_j:pos_j+7, :);
                end
            end
        end
% -------------------------------------------------------------------------        
        % Calculating Residual
        function res = GetResidual(CurrentFrame, PreviousFrame)
            res = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    res{x, y} = CurrentFrame{x, y} - PreviousFrame{x, y};
                end
            end
        end
        function res = GetResidualRGB(CurrentFrame, PreviousFrame)
            res   = struct('R', [], 'G', [], 'B', []);
            res.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            res.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            res.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    res.R{x, y} = CurrentFrame.R{x, y} - PreviousFrame.R{x, y};
                    res.G{x, y} = CurrentFrame.G{x, y} - PreviousFrame.G{x, y};
                    res.B{x, y} = CurrentFrame.B{x, y} - PreviousFrame.B{x, y};
                end
            end
        end
% -------------------------------------------------------------------------
        function res = Accumulate(CurrentFrame, PreviousFrame)
            res = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    res{x, y} = CurrentFrame{x, y} + PreviousFrame{x, y};
                end
            end
        end

        function res = AccumulateRGB(CurrentFrame, PreviousFrame)
            res   = struct('R', [], 'G', [], 'B', []);
            res.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            res.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            res.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            for x = 1:Constants.MB_ROWS()
                for y = 1:Constants.MB_COLS()
                    res.R{x, y} = CurrentFrame.R{x, y} + PreviousFrame.R{x, y};
                    res.G{x, y} = CurrentFrame.G{x, y} + PreviousFrame.G{x, y};
                    res.B{x, y} = CurrentFrame.B{x, y} + PreviousFrame.B{x, y};
                end
            end
        end
% -------------------------------------------------------------------------
        function frame = mb_to_frame2(mbCells)
            blockSize = Constants.MACROBLOCKSIZE;  
            rows = Constants.MB_ROWS();
            cols = Constants.MB_COLS();
            
            height = rows * blockSize;
            width  = cols * blockSize;
            
            frame = zeros(height, width); 
        
            for x = 1:rows
                for y = 1:cols
                    rowStart = (x-1)*blockSize + 1;
                    colStart = (y-1)*blockSize + 1;
                    frame(rowStart:rowStart+blockSize-1, colStart:colStart+blockSize-1) = ...
                        mbCells{x,y};
                end
            end
            frame = uint8(frame);  
        end
% -------------------------------------------------------------------------
        function y = WriteGopsToFile(GOPS)
            filename = 'result.bin';
            %filename = sprintf('result%2d.bin', Constants.GOP_SIZE);
            fid = fopen(filename, 'w');
            if fid == -1
                error('Cannot open file for writing.');
            end
            
            numGOPs = ceil(Constants.FRAMELENGTH/Constants.GOP_SIZE);
            fwrite(fid, numGOPs, 'int32'); %--- number of GOPs
            
            for g = 1:numGOPs
                gop       = GOPS{g};
                numFrames = length(gop);
                fwrite(fid, numFrames, 'int32'); %--- number of frames in GOP
            
                for f = 1:numFrames
                    frame = gop{f};
                    if isempty(frame)
                        disp('this should not be in the console');
                        continue;
                    end
            
                    channels = {frame.R, frame.G, frame.B};
                    for c = 1:3
                        frameINColor   = channels{c};
            
                        for b = 1:Constants.MB_COLS() * Constants.MB_ROWS()
                            block      = frameINColor{b};
                            blockSize  = numel(block);
                            [h1, w1]   = size(block);
                            fwrite(fid, blockSize,  'uint8');
                            fwrite(fid, h1,         'uint8');
                            %fwrite(fid, w1,         'uint8');
                            %disp(sprintf("The block size is %d, h1 is %d, w1 is %d", blockSize, h1, w1));
                            
                            for d = 1:blockSize
                                fwrite(fid, block(d), 'int8');
                            end
                        end
                    end
                end
            end
            
            fclose(fid);
        end

% -------------------------------------------------------------------------
        function y = ReadFromFile()
            fid = fopen('result.bin', 'r');
            if fid == -1
                error('Cannot open file for reading.');
            end
        
            numGOPs       = fread(fid, 1, 'int32'); %--- number of GOPs
            GOPS_restored = cell(1, numGOPs);
            for g = 1:numGOPs
                numFrames        = fread(fid, 1, 'int32'); %--- number of frames in GOP
                GOPS_restored{g} = cell(1, numFrames);
                for f = 1:numFrames
                    GOPS_restored{g}{f}   = struct('R', [], 'G', [], 'B', []);
                    GOPS_restored{g}{f}.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
                    GOPS_restored{g}{f}.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
                    GOPS_restored{g}{f}.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());
                    channels = {GOPS_restored{g}{f}.R, GOPS_restored{g}{f}.G, GOPS_restored{g}{f}.B};
        
                    % ----- R
                    for b = 1:Constants.MB_COLS() * Constants.MB_ROWS()
                        yCoord    = mod(b-1, Constants.MB_ROWS()) + 1;
                        xCoord    = floor((b-1) / Constants.MB_ROWS()) + 1;
                            %disp(sprintf("The xCoord is %d, yCoord is %d for b %d", xCoord, yCoord, b));
                        blockSize = fread(fid, 1, 'uint8');
                        h1        = fread(fid, 1, 'uint8');
                        %w1        = fread(fid, 1, 'uint8');
                        w1         = blockSize / h1;
                        GOPS_restored{g}{f}.R{yCoord, xCoord} = zeros(h1, w1);
                        for d = 1:blockSize
                            yCoordBlock  = mod(d-1, h1) + 1;
                            xCoordBlock  = floor((d-1) / h1) + 1;
                            val          = fread(fid, 1, 'int8');
                            %disp(val);
                            %disp(sprintf("The xCoordBlock is %d, yCoordBlock is %d for d %d", xCoordBlock, yCoordBlock, d));
                            GOPS_restored{g}{f}.R{yCoord, xCoord}(yCoordBlock, xCoordBlock) = val;
                        end
                    end
        
                    % ----- G
                    for b = 1:Constants.MB_COLS() * Constants.MB_ROWS()
                        yCoord    = mod(b-1, Constants.MB_ROWS()) + 1;
                        xCoord    = floor((b-1) / Constants.MB_ROWS()) + 1;
                            %disp(sprintf("The xCoord is %d, yCoord is %d for b %d", xCoord, yCoord, b));
                        blockSize = fread(fid, 1, 'uint8');
                        h1        = fread(fid, 1, 'uint8');
                        %w1        = fread(fid, 1, 'uint8');
                        w1         = blockSize / h1;
                        GOPS_restored{g}{f}.G{yCoord, xCoord} = zeros(h1, w1);
                        for d = 1:blockSize
                            yCoordBlock  = mod(d-1, h1) + 1;
                            xCoordBlock  = floor((d-1) / h1) + 1;
                            val          = fread(fid, 1, 'int8');
                                %disp(val);
                            GOPS_restored{g}{f}.G{yCoord, xCoord}(yCoordBlock, xCoordBlock) = val;
                        end
                    end
                    % ----- B
                    for b = 1:Constants.MB_COLS() * Constants.MB_ROWS()
                        yCoord    = mod(b-1, Constants.MB_ROWS()) + 1;
                        xCoord    = floor((b-1) / Constants.MB_ROWS()) + 1;
                            %disp(sprintf("The xCoord is %d, yCoord is %d for b %d", xCoord, yCoord, b));
                        blockSize = fread(fid, 1, 'uint8');
                        h1        = fread(fid, 1, 'uint8');
                        %w1        = fread(fid, 1, 'uint8');
                        w1         = blockSize / h1;
                        GOPS_restored{g}{f}.B{yCoord, xCoord} = zeros(h1, w1);
                        for d = 1:blockSize
                            yCoordBlock  = mod(d-1, h1) + 1;
                            xCoordBlock  = floor((d-1) / h1) + 1;
                            val          = fread(fid, 1, 'int8');
                                %disp(val);
                            GOPS_restored{g}{f}.B{yCoord, xCoord}(yCoordBlock, xCoordBlock) = val;
                        end
                    end
                end
            end
        
            fclose(fid);
            y = GOPS_restored;
        end
% -------------------------------------------------------------------------
        function y = ReadFramesUnprocessed(isRGB)
            y = cell(1, Constants.FRAMELENGTH);
            for i = 1:Constants.FRAMELENGTH
                filename    = sprintf('video_data/frame%03d.jpg', i);
                image       = imread(filename);
                if isRGB
                    y{i}    = struct('R', [], 'G', [], 'B', []);
                    y{i}.R  = double(image(:, :, 1));
                    y{i}.G  = double(image(:, :, 2));
                    y{i}.B  = double(image(:, :, 3));
                else
                    y{i}    = image;
                end
            end
        end
% -------------------------------------------------------------------------
        function y = ConvertMacroBlocks(framesUnprocessed)
            y = cell(1, Constants.FRAMELENGTH);
            for i = 1:Constants.FRAMELENGTH
                y{i}.R  = Utils.frame_to_mb(framesUnprocessed{i}.R);
                y{i}.G  = Utils.frame_to_mb(framesUnprocessed{i}.G);
                y{i}.B  = Utils.frame_to_mb(framesUnprocessed{i}.B);
            end
        end
% -------------------------------------------------------------------------
        function bestBlock = FindBestMatch(targetBlock, referenceFrame)
            searchRange = 4; 
            [rows, cols] = size(referenceFrame);
            bestError = inf;
            bestBlock = [];
        
            for r = 1:rows
                for c = 1:cols
                    refBlock = referenceFrame{r, c};
        
                    if size(refBlock) ~= size(targetBlock)
                        continue;
                    end
        
                    % Compute Mean Squared Error
                    diff = double(targetBlock) - double(refBlock);
                    mse = mean(diff(:).^2);
        
                    if mse < bestError
                        bestError = mse;
                        bestBlock = refBlock;
                    end
                end
            end
        end
% -------------------------------------------------------------------------
        function predicted = GetBidirectionalPredictionRGB(past, future)
            predicted   = struct('R', [], 'G', [], 'B', []);
            predicted.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            predicted.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            predicted.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());

            isLeft = false;
            if isLeft
                w1 = 0.6;
                w2 = 1 - w1;
            else
                w2 = 0.6;
                w1 = 1 - w2;   
            end
            w1 = 0.5;
            w2 = 0.5;
            
            predicted.R   = cellfun(@(a, b) double(uint8((a * w1 + b * w2))), past.R, future.R, 'UniformOutput', false);
            predicted.G   = cellfun(@(a, b) double(uint8((a * w1 + b * w2))), past.G, future.G, 'UniformOutput', false);
            predicted.B   = cellfun(@(a, b) double(uint8((a * w1 + b * w2))), past.B, future.B, 'UniformOutput', false);
            
        end
% -------------------------------------------------------------------------
        function predicted = GetBidirectionalPredictionRGB2(current, past, future)
            predicted   = struct('R', [], 'G', [], 'B', []);
            predicted.R = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            predicted.G = cell(Constants.MB_ROWS(), Constants.MB_COLS());
            predicted.B = cell(Constants.MB_ROWS(), Constants.MB_COLS());

            w1 = 0.5;
            w2 = 0.5;

            for row = 1:Constants.MB_ROWS()
                for col = 1:Constants.MB_COLS()
                    pause(0.001); 
                    blockPast   = Utils.FindBestMatch(current.R{row, col}, past.R);
                    blockFuture = Utils.FindBestMatch(current.R{row, col}, future.R);
                    predicted.R{row, col} = blockPast * w1 + blockFuture * w2;

                    blockPast   = Utils.FindBestMatch(current.G{row, col}, past.G);
                    blockFuture = Utils.FindBestMatch(current.G{row, col}, future.G);
                    predicted.G{row, col} = blockPast * w1 + blockFuture * w2;

                    blockPast   = Utils.FindBestMatch(current.B{row, col}, past.B);
                    blockFuture = Utils.FindBestMatch(current.B{row, col}, future.B);
                    predicted.B{row, col} = blockPast * w1 + blockFuture * w2;
                end
            end   
        end
% -------------------------------------------------------------------------
    function pattern = GetPattern()
        if Constants.GOP_SIZE() == 2
            pattern = ['I', 'P'];
            return;
        end
        if Constants.GOP_SIZE() == 1
            pattern = ['I'];
            return;
        end
        if Constants.GOP_SIZE() == 3
            pattern = ['I', 'B', 'P'];
            return;
        end
        if Constants.GOP_SIZE() == 4
            pattern = ['I', 'B', 'B', 'P'];
            return;
        end


        pattern = ['I', repmat(['B', 'B', 'P'], 1, ceil((Constants.GOP_SIZE())/3))];
        pattern = pattern(1:Constants.GOP_SIZE()); 
        if mod(Constants.GOP_SIZE() - 1, 3) ~= 0
            for i = 0:mod(Constants.GOP_SIZE() - 1, 3)
                pattern(end -i) = 'P';
            end
        end
    end
% -------------------------------------------------------------------------
    end
end
