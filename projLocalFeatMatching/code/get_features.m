% Local Feature Stencil Code
% Written by James Hays for CS 143 @ Brown / CS 4476/6476 @ Georgia Tech

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'descriptor_window_image_width', in pixels, is the local feature descriptor width. 
%   You can assume that descriptor_window_image_width will be a multiple of 4 
%   (i.e., every cell of your local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations, then you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, descriptor_window_image_width)


% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each descriptor_window_image_width/4. 'cell' in this context
%    nothing to do with the Matlab data structue of cell(). It is simply
%    the terminology used in the feature literature to describe the spatial
%    bins where gradient distributions will be described.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

window = zeros(descriptor_window_image_width, descriptor_window_image_width, 'single');

x = int32(x);
y = int32(y);

x_size = size(x, 1);
y_size = size(y, 1);

image = im2uint8(image); %check the validity of this line

blurred_image = blur(image); 

window_cell_magnit = cell(x_size, 1);
window_cell_orient = cell(x_size, 1);

width = descriptor_window_image_width / 2; #8

aux = x;
x = y;
y = aux;

%creating 16x16 window for each point
for i = 1:x_size %preenche matriz para cada coordenada
  sub_image = blurred_image( (x(i)-width-1) : (x(i)+width), (y(i)-width-1) : (y(i)+width) ); #18x18 because of the way mags and degrees are calculated
  %sub_image = blurred_image( (y(i)-width-1) : (y(i)+width), (x(i)-width-1) : (x(i)+width) );
  [mag, deg] = calculate_gradient(sub_image, x, y); %retorna duas matrizes 16x16
  window_cell_magnit{i} = mag;
  window_cell_orient{i} = deg;
endfor
#size(window_cell_magnit{1})

%creating 128 dimensional vector: 8 bin histogram for each 4x4 window (get submatrix of window_cell_*)
%bins = zeros(16, 8, 'single'); %each line has one bin for]
%list_of_windows and features have the same 
features = zeros(size(x,1), 128, 'single');
list_of_windows = cell(1, x_size); %uma window para cada coordenada
for i = 1:x_size
  extra_index = 1;
  cell_magnit = window_cell_magnit{i}; %16x16 matrix magnitudes
  cell_orient = window_cell_orient{i}; %16x16 matrix orientations in radians
  list_of_bins = cell(4, 4);
  for r = 0:3 %processa uma matriz 16x16
    for c = 0:3
      sub_m = cell_magnit( ((r*4)+1) : ((r*4)+4), ((c*4)+1) : ((c*4)+4) );
      sub_o = cell_orient( ((r*4)+1) : ((r*4)+4), ((c*4)+1) : ((c*4)+4) );
      hist_bin_8 = zeros(1, 8, 'single');
      for j = 1:4
        for k = 1:4
          bin_pos = getBin( sub_o(j, k) );
          hist_bin_8(1, bin_pos+1) = hist_bin_8(1, bin_pos+1) + sub_m(j, k);
        endfor %k
      endfor %j
      list_of_bins{r+1, c+1} = hist_bin_8;
      
      %this 'for' is just used to populate matrix 'features'
      for lol = 1:8
        features(i, extra_index) = hist_bin_8(1, lol);
        extra_index = extra_index + 1;
      endfor
      
    endfor %c
  endfor %r
  list_of_windows{1, i} = list_of_bins;
endfor %i

%unit length normalizer
for i = i:x_size
  vector_128 = features(i, :);
  normalized_v = normalizeVector(vector_128);
  features(i, :) = normalized_v;
endfor

%TODO: apply circular Gaussian on each; Each feature should be normalized to unit length
endfunction

%returns magnitude and orientations for coordinates (x, y)
%sub_image is a 18x18 image around point (x, y)
function [mag, deg] = calculate_gradient(sub_image, x, y)
  [rows, cols] = size(sub_image); #18x18 matrix
  mag = zeros(16, 16, 'single');
  deg = zeros(16, 16, 'single');
  for i = 2:(rows-1)
    for j = 2:(cols-1)
      #gradient magnitude calculation
      first_m = ( sub_image(i+1, j) - sub_image(i-1, j) ) ^ 2;
      secon_m = ( sub_image(i, j+1) - sub_image(i, j-1) ) ^ 2;
      mag(i-1, j-1) = sqrt(first_m + secon_m);
      
      #gradient orientation in radians calculation
      first_o = sub_image(i, j+1) - sub_image(i, j-1);
      secon_o = sub_image(i+1, j) - sub_image(i-1, j);
      deg(i-1, j-1) = atan2(first_o, secon_o);
    endfor
  endfor
endfunction

%returns blurred image
function [blurred_image] = blur( image )
  apply = imsmooth(image, "Gaussian", 3, sigma=1.5);
  blurred_image = (apply);
  imwrite(blurred_image, "gauss.jpg");
endfunction

%returns the position of the value in the bin
function [bin_position] = getBin( radians )
  deg = rad2deg(radians);
  bin_position = floor(mod(deg, 8));
endfunction
