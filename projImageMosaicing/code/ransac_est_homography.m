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

%   número máximo de iterações
    ransacIterations = 1000; %test this
%   quantidade de pontos selecionados
    numberOfPoints = 4;
%   fundamental matrix com maior número de inliers
    MATRIX = zeros( 3, 3 );
%   tamanho das matrizes que possuem os pontos
    matches_size = size( x1, 1 )
    matches_bSize = size( x2, 1 )
%   present maximum number of inliers
    presentInliers = 0;
    A_4by2 = zeros( 4, 2 );
    B_4by2 = zeros( 4, 2 );
    %execução de 1000 iterações
    i = 1;
    ssd = @(x, y) sum((x-y).^2);
    while i <= ransacIterations
%       seleção de 8 índices aleatórios
    	randSample = randsample( matches_size, numberOfPoints );
%       seleção dos 8 pontos dos matches_a e matches_b
%         for j=1:numberOfPoints
%             %8x2 matrix
%             A_4by2( j, : ) = matches_a( randSample(j), : );
%             B_4by2( j, : ) = matches_b( randSample(j), : );
%         end
        
%       3x3 fundamental matrix estimation
        matrix = est_homography( x2(randSample), y2(randSample), x1(randSample), y1(randSample) );
        %list of inlying distances
        distance = zeros( matches_size, 1 );
%         homoCoord1 = [x1, y1, ones(matches_size, 1)];
%         homoCoord2 = [x2, y2];
%         
%         transformedPoints = (homoCoord1 * matrix)';
%         transformedPoints = transformedPoints(1:2,:)./repmat(transformedPoints(3,:),2,1);
%         distance = sum((transformedPoints-homoCoord2(:,1:2)').^2,1)';
%       
        matches_a = [x1, y1];
        matches_b = [x2, y2];
        for k = 1:matches_size
            %cálculo da distância para matches_a e matches_b
%             A = [ matches_a(k, :)'; 1 ]; %3x1
%             B = [ matches_b(k, :), 1 ]; %1x3
%             distance(k) = B * matrix * A;
% %             disp(distance);
            t_xy = matrix*[x1(k), y1(k), 1]';
            t_xy = t_xy/t_xy(end);

            distance(k) = ssd([x2(k), y2(k), 1]', t_xy);
        end
        %disp(distance);
%       identificar os indexes dos inliers considerando o threshold definido
        idxes = find( abs(distance) <= thresh );
%       quantidade de inliers
        futureInliers = size( idxes, 1 );
%       atualização dos valores

        if ( futureInliers > presentInliers )
            presentInliers = futureInliers;
            MATRIX = matrix;
            IDXES = idxes;
%           distances from the Best_Fmatrix
            distances = distance;
        end
        
        i = i + 1;
    end
    disp(thresh);
    
%   seleção de 30 índices
    [~, best_idxes]  = sort( abs( distances ), 'ascend' );
%   disp(distances)
%   disp(best_idxes)
%     inliers_a = matches_a( best_idxes( 1:30 ), : );
%     inliers_b = matches_b( best_idxes( 1:30 ), : );

%%

inlier_ind = best_idxes;
H = MATRIX;

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
