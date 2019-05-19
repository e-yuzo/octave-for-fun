#função main
pkg load image;
pkg load communications;

patch1 = imread("../data/img1_patch.png");
patch2 = imread("../data/img2_patch.png");

patch1_uint = uint8(patch1);
patch2_uint = uint8(patch2);

#extração dos canais
R1 = patch1_uint(:,:,1);
G1 = patch1_uint(:,:,2);
B1 = patch1_uint(:,:,3);

R2 = patch2_uint(:,:,1);
G2 = patch2_uint(:,:,2);
B2 = patch2_uint(:,:,3);

#construção dos parâmetros
s0 = [10, 10; 100, 100; 220, 220]; #estado inicial dos 3 pontos
t0 = 10^(-3); #temperatura inicial
e = 10^(-7); #temperatura final
k = 100; #epoch: número de iterações após cada atualização da temperatura

#extração dos histogramas dos canais das duas imagens
[hr1] = imhist(R1);
[hr2] = imhist(R2);
[hg1] = imhist(G1);
[hg2] = imhist(G2);
[hb1] = imhist(B1);
[hb2] = imhist(B2);

#geração das tabelas de correlação
g = AS(s0, t0, e, k, hg2, hg1);
b = AS(s0, t0, e, k, hb2, hb1);
r = AS(s0, t0, e, k, hr2, hr1);

[x y] = size(R2);

#aplicação das tabelas de correlação nos três canais da imagem original
#para cada intensidade (pixel)
for i = 1:x
  for j = 1:y
    R2(i, j) = r(R2(i, j)+1);
    G2(i, j) = g(G2(i, j)+1);
    B2(i, j) = b(B2(i, j)+1);
  endfor
endfor

#concatenação das três matrizes (canais)
imagem = cat(3, R2, G2, B2);
imwrite(imagem, "generatedImage.png");