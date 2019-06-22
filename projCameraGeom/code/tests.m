n = [1, 2, 3, 4];
y = randsample(n,3)

%     A_by3 = [ matches_a ones( matches_aSize, 1 ) ]; %Ax3
%     B_by3 = [ matches_b ones( matches_aSize, 1 )]; %Bx3
%     distances = sum( ( B_by3 .* ( Best_Fmatrix * A_by3' )' ), 2 );
%     [~, best_idxes]  = sort( abs( distances ), 'ascend' );
%     inliers_a = matches_a( best_idxes( 1:30 ), : );
%     inliers_b = matches_b( best_idxes( 1:30 ), : );

%   A = [ matches_a(k, :)'; 1 ]; %3x1
% 	B = [ matches_b(k, :), 1 ]; %1x3
% 	distance(k) = B * futureFundamentalMatrix * A;