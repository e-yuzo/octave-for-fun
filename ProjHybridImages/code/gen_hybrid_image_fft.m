function [low_frequencies_dog,low_frequencies_cat] = gen_hybrid_image_fft( image1, image2, cutoff_frequency, X )
% Inputs:
% - image1 -> The image from which to take the low frequencies.
% - image2 -> The image from which to take the high frequencies.
% - cutoff_frequency -> The standard deviation, in pixels, of the Gaussian 
%                       blur that will remove high frequencies.
% - X -> The channel of the specified image that will be used in the calculations.

###################################
##### IMAGE1.toLowFrequencies #####
b = padarray(image1, size(image1), "zeros", "post");
c = im2double(b(:,:,X:3));
d = fft2(c);
d = fftshift(d);
[n m o] = size(c);
h = zeros([n,m]);
for i = 1:n
  for j = 1:m
    h(i,j) = H(i,j,size(c),cutoff_frequency);
  end
end
g = d.*h;
g = ifftshift(g);
at = ifft2(g);
at = abs(at);
[x y o] = size(image1);
low_frequencies_dog = at(1:x,1:y);

###################################
##### IMAGE2.toLowFrequencies #####
b = padarray(image2, size(image2), "zeros", "post");
c = im2double(b(:,:,X:3));
d = fft2(c);
d = fftshift(d);
[n m o] = size(c);
h = zeros([n,m]);
for i = 1:n
  for j = 1:m
    h(i,j) = H(i,j,size(c),cutoff_frequency);
  end
end
g = d.*h;
g = ifftshift(g);
at = ifft2(g);
at = abs(at);
[x y o] = size(image2);
atc = at(1:x,1:y);
low_frequencies_cat = atc;
