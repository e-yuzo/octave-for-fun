function [hybrid_image,low_frequencies,high_frequencies] = gen_hybrid_image( image1, image2, cutoff_frequency )
% Inputs:
% - image1 -> The image from which to take the low frequencies.
% - image2 -> The image from which to take the high frequencies.
% - cutoff_frequency -> The standard deviation, in pixels, of the Gaussian 
%                       blur that will remove high frequencies.

%criação do filtro
filter = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);
%cáculo do high pass e low pass das imagens image2 (cat) e image1 (dog), respectivamente.
low_frequencies = my_imfilter(image1, filter);
high_frequencies = image2 - my_imfilter(image2, filter);
%criação da imagem híbrida a partir do low_frequencies e high_frequencies
hybrid_image = low_frequencies + high_frequencies;