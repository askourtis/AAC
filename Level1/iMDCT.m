function FT = iMDCT(FF, W)
% Calculates the iMDCT of the given frame and then multiplies with the
% given window
% 
% Parameters:
%   FF - The frame in the FREQUENCY domain      [Matrix M-by-K]
%   W  - The window                             [Matrix 2M-by-1]
%
% Returns:
%   The frame in the TIME domain           [Matrix 2M-by-K]

%% Type Checks
assert(isnumeric(FF), "FF is not numeric")
assert(ismatrix(FF), "FF is not matrix")

assert(isnumeric(W), "W is not numeric")
assert(isvector(W), "W is not vector")

assert(2*size(FF, 1) == size(W, 1), "FF should be half of W")

%% Code
N = 2*size(FF, 1);
K = size(FF, 2);

C = CosMat(N);              % N/2 x N
C = reshape(C, [N/2 1 N]);  % N/2 x 1 x N

FT = 2/N * sum(FF .* C);        % 1 x K x N
FT = permute(FT, [3 2 1]) .* W; % N x K = 2M x K

%% Type Checks
assert(isnumeric(FT), "FT is not numeric")
assert(ismatrix(FT), "FT is not matrix")
assert(all(size(FT) == [N K]), "FT is not of size 2M-by-K")
end

function C = CosMat(N)
% Calculates and caches the iMDCT cosine vector for the given size
% 
% Parameters:
%   N - The size of the cosine matrix   [scalar]
%
% Returns:
%   The vector with the given size      [vector N/2xN]

%% Type Checks
assert(isscalar(N), "N is not scalar")
assert(isnumeric(N), "N is not numeric")
assert(N > 0, "N is not positive")
assert(floor(N) == N, "N is not integer")

%% Code

% Cache
% K - Keys   [Integers]
% V - Values [Vectors]
persistent K V

% Initialize
if isempty(K)
    K = [];
    V = {};
end

% Search if N is in K
I = find(K == N, 1);

% If not found calculate the vector, else return from memory
if ~isempty(I)
    C = V{I};
else
    n0 = (N/2 + 1)/2;
    C  = cos( 2*pi/N * ((1:N) - 1 + n0) .* ((1:(N/2)) - 1 + 1/2)' );
    
    K(end+1) = N;
    V{end+1} = C;
end


%% Return Checks
assert(all(size(C) == [N/2 N]), "C is not of size NxN/2")
assert(isnumeric(C), "C is not numeric")
end
