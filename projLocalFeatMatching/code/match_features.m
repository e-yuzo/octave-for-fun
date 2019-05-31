% Local Feature Stencil Code
% Written by James Hays for CS 143 @ Brown / CS 4476/6476 @ Georgia Tech

% 'features1' and 'features2' are the n x feature dimensionality features
%   from the two images.
% If you want to include geometric verification in this stage, you can add
% the x and y locations of the features as additional inputs.
%
% 'matches' is a k x 2 matrix, where k is the number of matches. The first
%   column is an index in features1, the second column is an index
%   in features2. 
% 'Confidences' is a k x 1 matrix with a real valued confidence for every
%   match.
% 'matches' and 'confidences' can empty, e.g. 0x2 and 0x1.
function [matches, confidences] = match_features(features1, features2)

% This function does not need to be symmetric (e.g. it can produce
% different numbers of matches depending on the order of the arguments).

% To start with, simply implement the "ratio test", equation 4.18 in
% section 4.1.3 of Szeliski. For extra credit you can implement various
% forms of spatial verification of matches.

% Placeholder that you can delete. Random matches and confidences

num_features = min(size(features1, 1), size(features2,1));
num_features = size(features1, 1);
feat1_size = size(features1, 1);
feat2_size = size(features2, 1);

matches = zeros(num_features, 2);

%this is the ratio i think
confidences = zeros(num_features, 1);

for h = 1:feat1_size
  hist1 = features1(h, :);
  list_of_distances = zeros(feat2_size, 1);
  index_match1 = h;
  for i = 1:feat2_size
    hist2 = features2(i, :);
    distance = histogramDistance(hist1, hist2);
    list_of_distances(i) = distance;
  endfor%i
  [values, indexes] = sort(list_of_distances, 'ascend');
  index_match2 = indexes(1); %index containing the lowest value
  
  confidences(h) = ( getRatio(values(1), values(2)) );
  
  matches(h, 1) = index_match1;
  matches(h, 2) = index_match2;
endfor%h

%num_features = min(size(features1, 1), size(features2,1));
%matches = zeros(num_features, 2);
%matches(:,1) = randperm(num_features); 
%matches(:,2) = randperm(num_features);
%confidences = rand(num_features,1);

% Sort the matches so that the most confident onces are at the top of the
% list. You should not delete this, so that the evaluation
% functions can be run on the top matches easily.
[confidences, ind] = sort(confidences, 'ascend');
matches = matches(ind,:);
endfunction

%each histogram is a size 128 vector
function [distance] = histogramDistance(hist1, hist2)
  sub = hist1 .- hist2;
  exp = sub .^ 2;
  summation = sum(exp);
  distance = sqrt(summation);
endfunction

function [ratio] = getRatio(dist1, dist2)
  if dist1 > dist2
    ratio = dist2 / dist1;
  else
    ratio = dist1 / dist2;
  endif
endfunction