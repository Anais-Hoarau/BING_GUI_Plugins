%Distance beyond min becomes negative
%distances is a matrix
function out = sign_distance( distances )
    disp('--> Signing distance...');
    [~, indexMinDistance] = min(distances);
    disp('----> Building multiplier array...');
    multiplier = zeros(1, length(distances));
    multiplier(1:indexMinDistance-1) = 1;
    multiplier(indexMinDistance:end) = -1;
    disp('----> Multiplying array...');
    out = distances .* multiplier;
end

