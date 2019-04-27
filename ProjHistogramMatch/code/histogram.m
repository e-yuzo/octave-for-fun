#####
pkg load image;
pkg load communications;

patch1 = imread("../data/img1_patch.png");
patch2 = imread("../data/img2_patch.png");

patch1_double = (patch1);
patch2_double = (patch2);

patch1_double = im2double(patch1);
patch2_double = im2double(patch2);

#patch1_hsv = rgb2hsv(patch1_double);
#patch2_hsv = rgb2hsv(patch2_double);

R1 = patch1_double(:,:,1);
G1 = patch1_double(:,:,2);
B1 = patch1_double(:,:,3);

R2 = patch2_double(:,:,1);
G2 = patch2_double(:,:,2);
B2 = patch2_double(:,:,3);

#res = H(H, Hp);
#res = D(R1, R2);
#res;

#construção dos argumentos para AS
#function L = AS(s0, t0, e, k, Ha, Hb)
s0 = [0, 0; 128, 128; 255, 255];
t0 = 256;
e = 10^(-5);
k = 100;
haha = [0:255];
[Ha x1] = imhist(R1);
[Hb x2] = imhist(R2);
figure(4), plot(haha, Ha);
L = AS(s0, t0, e, k, Ha, Hb);

figure(1), plot(haha, Ha);
figure(2), plot(haha, Hb);
figure(3), plot(haha, L);
#####