% ---------------------------------------------------------------------.
% Constant values are in Constants.m file, they can be updated there.
Constants.SET_GOP_SIZE(30);
% ---------------------------------------------------------------------.


c_framesUnprocessed       = Utils.ReadFramesUnprocessed(true);
c_framesInMacroBlocks     = Utils.ConvertMacroBlocks(c_framesUnprocessed);
clear c_framesUnprocessed;


c_GOPSCOMPRESSED          = Compression.CompressImproved(c_framesInMacroBlocks);
clear c_GOPSCOMPRESSED;
clear c_framesInMacroBlocks;

