% Written by Henry Hu for CSCI 1430 @ Brown and CS 4495/6476 @ Georgia Tech

% Find the best fundamental matrix using RANSAC on potentially matching
% points

% 'matches_a' and 'matches_b' are the Nx2 coordinates of the possibly
% matching points from pic_a and pic_b. Each row is a correspondence (e.g.
% row 42 of matches_a is a point that corresponds to row 42 of matches_b.

% 'Best_Fmatrix' is the 3x3 fundamental matrix
% 'inliers_a' and 'inliers_b' are the Mx2 corresponding points (some subset
% of 'matches_a' and 'matches_b') that are inliers with respect to
% Best_Fmatrix.

% For this section, use RANSAC to find the best fundamental matrix by
% randomly sample interest points. You would reuse
% estimate_fundamental_matrix() from part 2 of this assignment.

% If you are trying to produce an uncluttered visualization of epipolar
% lines, you may want to return no more than 30 points for either left or
% right images.

function [ Best_Fmatrix, inliers_a, inliers_b ] = ransac_fundamental_matrix( matches_a, matches_b )
%   número máximo de iterações
    ransacIterations = 500; %test this
%   quantidade de pontos selecionados
    numberOfPoints = 8;
%   threshold entre inliers e outliers
    threshold = 0.015; %test this
%   fundamental matrix com maior número de inliers
    Best_Fmatrix = zeros( 3, 3 );
%   tamanho das matrizes que possuem os pontos
    matches_aSize = size( matches_a, 1 )
    matches_bSize = size( matches_b, 1 )
%   present maximum number of inliers
    presentInliers = 0;
    A_8by2 = zeros( 8, 2 );
    B_8by2 = zeros( 8, 2 );
    i = 1;
    while i <= ransacIterations
%       seleção de 8 índices aleatórios
    	randSample = randsample( matches_aSize, numberOfPoints );
        
%       seleção dos 8 pontos dos matches_a e matches_b
        for j=1:numberOfPoints
            %8x2 matrix
            A_8by2( j, : ) = matches_a( randSample(j), : );
            B_8by2( j, : ) = matches_b( randSample(j), : );
        end
        
%       3x3 fundamental matrix estimation
        futureFundamentalMatrix = estimate_fundamental_matrix( A_8by2, B_8by2 );
        %list of inlying distances
        distance = zeros( matches_aSize, 1 );
        
        for k = 1:matches_aSize
            %cálculo da distância para matches_a e matches_b
            A = [ matches_a(k, :), 1 ]'; %3x1
            B = [ matches_b(k, :), 1 ]; %1x3
            distance(k) = B * futureFundamentalMatrix * A;
        end
        
%       identificar os indexes dos inliers considerando o threshold definido
        idxes = find( abs(distance) <= threshold );
%       quantidade de inliers
        futureInliers = size( idxes, 1 );
%       atualização dos valores
        if ( futureInliers > presentInliers )
            presentInliers = futureInliers;
            Best_Fmatrix = futureFundamentalMatrix;
            Best_Idxes = idxes;
%           distances from the Best_Fmatrix
            distances = distance;
        end
        
        i = i + 1;
    end
%   seleção de 30 índices
    %[~, best_idxes]  = sort( abs( distances ), 'ascend' );
    inliers_a = matches_a( Best_Idxes, : );
    inliers_b = matches_b( Best_Idxes, : );
end
