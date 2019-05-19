#função responsável por encontrar a distância entre dois histogramas
function summation = D(h1, h2)
  pixels1 = sum(h1);
  pixels2 = sum(h2);
  h1 = h1 ./ pixels1; #normalização dos histogramas
  h2 = h2 ./ pixels2;
  res = h1 .- h2;
  res = res .^ 2;
  summation = sum(res);
endfunction