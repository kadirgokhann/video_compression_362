% ---------------------------------------------------------------------.
% Constant values are in Constants.m file, they can be updated there.
Constants.SET_GOP_SIZE(30);
% ---------------------------------------------------------------------.

d_GOPSREAD      = Utils.ReadFromFile();
d_frames        = Decompression.DecompressImproved(d_GOPSREAD);
clear GOPSREAD;
d_images        = Decompression.ConvertToImg(d_frames);
clear frames;
clear d_images;

