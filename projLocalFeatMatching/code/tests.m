pkg load image;

img = imread('../data/NotreDame/921919841_a30df938f2_o.jpg');
img = uint8(img);
#gauss_filter = imfilter ("gaussian");
%apply = imsmooth(img, "Gaussian", 3, sigma=1.5);
%imwrite(uint8(apply), "gauss.jpg");

  #gauss_filter = fspecial ("gaussian", [3, 3], 1.5);
 # apply = imsmooth(img, "Gaussian", 3, sigma=1.5);
 # blurred_image = uint8(apply);
 # imwrite(blurred_image, "gauss.jpg");
  # hist_bin_8 = zeros(1, 8, 'single');
  # window_cell_orient = cell(4,  4);
  # window_cell_orient{1, 2}
  
confidences = [1, 3, 1, 4]
matches = [1, 2, 4, 5]
[confidences, ind] = sort(confidences, 'descend')
matches = matches(ind)