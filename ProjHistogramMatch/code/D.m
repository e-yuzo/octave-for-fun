function summation = D(h1, h2)
  #since both images are the same size
  #[x y] = size(h1);
  #image_size = x * y;
  #[counts1, x1] = imhist(channel1);
  #[counts2, x2] = imhist(channel2);
  #res = ((h1 ./ image_size) .- (h2 ./ image_size)) .^ 2;#normalizado
  res = h1 .- h2;
  res = res .^ 2;
  summation = sum(res);
endfunction