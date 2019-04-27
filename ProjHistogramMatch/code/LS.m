#resolução do sistema linear
function res = LS(p1, p2, p3)
  a = [p1(1)^2, p1(1), 1; p2(1)^2, p2(1), 1; p3(1)^2, p3(1), 1];
  b = [p1(2); p2(2); p3(2)];
  res = a\b;
endfunction