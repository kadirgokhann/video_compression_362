function y = CreateVideo
    folder      = 'decompressed/';
    filePattern = fullfile(folder, '*.jpg');
    imageFiles  = dir(filePattern);
    
    outputVideo = VideoWriter('videoReconst.mp4', 'MPEG-4');
    outputVideo.FrameRate = 30;
    open(outputVideo);
    
    for i = 1:length(imageFiles)
        filename    = fullfile(folder, imageFiles(i).name);
        img         = imread(filename);
    
        if size(img, 3) == 1
            img = repmat(img, [1 1 3]);
        end
        writeVideo(outputVideo, img);
    end
    
    close(outputVideo);
end

CreateVideo();