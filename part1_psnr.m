

original_frames      = Utils.ReadFramesUnprocessed(false);
framesInMacroBlocks  = Utils.ConvertMacroBlocks(Utils.ReadFramesUnprocessed(true));

Constants.SET_GOP_SIZE(1);
GOPS1_               = Compression.Compress(framesInMacroBlocks);
reconstructed_GOPS1  = Decompression.ConvertToImg(Decompression.Decompress(GOPS1_));

Constants.SET_GOP_SIZE(15);
GOPS15_              = Compression.Compress(framesInMacroBlocks);
reconstructed_GOPS15 = Decompression.ConvertToImg(Decompression.Decompress(GOPS15_));

Constants.SET_GOP_SIZE(30);
GOPS30_              = Compression.Compress(framesInMacroBlocks);
reconstructed_GOPS30 = Decompression.ConvertToImg(Decompression.Decompress(GOPS30_));


%• (10 pts) For GOP sizes 1, 15 and 30. Plot Peak signal-to-noise ratio 
% (PSNR) curves in a single plot (use colors). Compute PSNR based on MSE 
% between the original frame and the ”compressed and decompressed” frame 
% (formula in the link). The x-axis should contain frame number and y-axis 
% should contain PSNR values. Report: Include this plot in your report 
% and provide a brief commentary.


PSNR(original_frames, reconstructed_GOPS1,reconstructed_GOPS15, reconstructed_GOPS30);


function y = PSNR(original_frames,reconstructed_GOP1,reconstructed_GOP15,reconstructed_GOP30)
    psnr_GOP1  = zeros(1, Constants.FRAMELENGTH());
    psnr_GOP15 = zeros(1, Constants.FRAMELENGTH());
    psnr_GOP30 = zeros(1, Constants.FRAMELENGTH());
    
    for i = 1:Constants.FRAMELENGTH()
        mse1          = immse(double(original_frames{i}), double(reconstructed_GOP1{i}));
        mse15         = immse(double(original_frames{i}), double(reconstructed_GOP15{i}));
        mse30         = immse(double(original_frames{i}), double(reconstructed_GOP30{i}));
    
        psnr_GOP1(i)  = 10 * log10(Constants.Instance().MAX_I^2 / mse1);
        psnr_GOP15(i) = 10 * log10(Constants.Instance().MAX_I^2 / mse15);
        psnr_GOP30(i) = 10 * log10(Constants.Instance().MAX_I^2 / mse30);
    end
    
    frame_numbers = 1:Constants.FRAMELENGTH();
    plot(frame_numbers, psnr_GOP1,  'r', 'DisplayName', 'GOP = 1'); hold on;
    plot(frame_numbers, psnr_GOP15, 'g', 'DisplayName', 'GOP = 15');
    plot(frame_numbers, psnr_GOP30, 'b', 'DisplayName', 'GOP = 30');
    xlabel('Frame Number');
    ylabel('PSNR (dB)');
    title('PSNR Comparison for Different GOP Sizes');
    legend;
    grid on;
end
