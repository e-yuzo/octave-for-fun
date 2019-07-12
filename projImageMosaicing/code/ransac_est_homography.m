function [H, inlier_ind] = ransac_est_homography(y1, x1, y2, x2, thresh, iter, im1, im2, verbose)
% RANSAC_EST_HOMOGRAPHY estimates the homography between two corresponding
% feature points through RANSAC. im2 is the source and im1 is the destination.

% INPUT
% y1,x1,y2,x2 = corresponding point coordinate vectors Nx1
% thresh      = threshold on distance to see if transformed points agree
% iter        = iteration number for multiple image stitching
% im1, im2    = images

% OUTPUT
% H           = the 3x3 matrix computed in final step of RANSAC
% inlier_ind  = nx1 vector with indices of points that were inliers


if nargin < 9
   verbose = false; 
end

% original feature matches
N = size(y1, 1);


%% PUT YOUR CODE HERE 

%   n�mero m�ximo de itera��es
    ransacIterations = 5000;
%   quantidade de pontos selecionados
    numberOfPoints = 4;
%   fundamental matrix com maior n�mero de inliers
    MATRIX = zeros( 3, 3 );
%   tamanho das matrizes que possuem os pontos
    matches_size = size( x1, 1 )
    matches_bSize = size( x2, 1 )
%   present maximum number of inliers
    presentInliers = 0;
    A_4by2 = zeros( 4, 2 );
    B_4by2 = zeros( 4, 2 );
    i = 1;
%   fun��o que calcula a dist�ncia
    ssd = @(x, y) sum((x-y).^2);
%   execu��o de 1000 itera��es
    while i <= ransacIterations
%       sele��o de 8 �ndices aleat�rios
    	randSample = randsample( matches_size, numberOfPoints );
%       3x3 fundamental matrix estimation
        matrix = est_homography( x1(randSample), y1(randSample), x2(randSample), y2(randSample) );
%       list of distances (armazena as dist�ncias)
        distance = zeros( matches_size, 1 );
%       calcula a posi��o (x, y) da imagem original para a posi��o (X, Y) da
%       imagem destino
        [x, y] = apply_homography(matrix, x2, y2);
%       calcula as dist�ncias utilizando a fun��o ssd definida
        for k = 1:matches_size
            a1 = [x(k); y(k)];
            a2 = [x1(k); y1(k)];
            distance(k) = ssd(a1, a2);
        end
%       identificar os indexes dos inliers considerando o threshold definido
        idxes = find( abs(distance) <= thresh );
%       quantidade de inliers
        futureInliers = size( idxes, 1 );
%       atualiza��o dos valores
        if ( futureInliers > presentInliers )
            presentInliers = futureInliers;
            MATRIX = matrix;
            IDXES = idxes;
%           distances: usando o MATRIX
            distances = distance;
        end
        
        i = i + 1;
    end
% recalcular Homography utilizando todos os inliers
MATRIX2 = est_homography( x1(IDXES), y1(IDXES), x2(IDXES), y2(IDXES) );

inlier_ind = IDXES;
disp(size(inlier_ind, 1));
H = MATRIX2;

%% END OF CODE



%% PLACEHOLDER CODE TO PLOT ONLY THE INLIERS WHEN YOU WERE DONE
%inlier_ind = 1:min(size(y1,1),size(y2,1));
%H = est_homography(x1,y1,x2,y2);
%% DELETE THE ABOVE LINES WHEN YOU WERE DONE

% Plot the verbose details
if ~verbose
    return
end

dh1 = max(size(im2,1)-size(im1,1),0);
dh2 = max(size(im1,1)-size(im2,1),0);

h = figure(1)

% Original Matches
subplot(2,1,1);
imshow([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]);
delta = size(im1,2);
line([x1'; x2' + delta], [y1'; y2']);
title(sprintf('%d Original matches', N));
axis image off;

% Inlier Matches
subplot(2,1,2);
imshow([padarray(im1,dh1,'post') padarray(im2,dh2,'post')]);
delta = size(im1,2);
line([x1(inlier_ind)'; x2(inlier_ind)' + delta], [y1(inlier_ind)'; y2(inlier_ind)']);
title(sprintf('%d (%.2f%%) inliner matches out of %d', size(inlier_ind,2), 100*size(inlier_ind,2)/N, N));
axis image off;
drawnow;

% Save the figures
p         = mfilename('fullpath');
rootDir = fileparts(fileparts(p));
outputDir = fullfile(rootDir, 'results/');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
fileString = fullfile(outputDir, ['matches', num2str(iter,'%02d')]);
fig_save(h, fileString, 'png');
end
%close(h); %this was changed
