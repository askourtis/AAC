function FF = MDCT(FT, W)
% Calculates the MDCT of the given frame multiplied with the given window
% 
% Parameters:
%   FT - The frame in the TIME domain           [Matrix N-by-K]
%   W  - The window                             [Matrix N-by-1]
%
% Returns:
%   The frame in the FREQUENCY domain           [Matrix N/2-by-K]

%% Type Checks
assert(isnumeric(FT), "FT is not numeric")
assert(ismatrix(FT), "FT is not matrix")

assert(isnumeric(W), "W is not numeric")
assert(isvector(W), "W is not vector")

assert(size(FT, 1) == size(W, 1), "FT and W is not of same length")

%% Code
N = size(FT, 1);
K = size(FT, 2);

C = CosMat(N);              % NxN/2
C = reshape(C, [N 1 N/2]);  % Nx1xN/2

FF = 2*sum(FT .* ...    % N x K x 1     |\
            W .* ...    % N x 1 x 1     |-> sum(N x K x N/2) -> 1 x K x N/2
            C);         % N x 1 x N/2   |/
 
FF = permute(FF, [3 2 1]); % After permute |-> N/2 x K

%% Type Checks
assert(isnumeric(FF), "FF is not numeric")
assert(ismatrix(FF), "FF is not matrix")
assert(all(size(FF) == [N/2 K]), "FF is not of size N/2-by-K")
end

function C = CosMat(N)
% Calculates and caches the MDCT cosine vector for the given size
% 
% Parameters:
%   N - The size of the cosine matrix   [scalar]
%
% Returns:
%   The vector with the given size      [vector NxN/2]

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
    C  = cos( 2*pi/N * ((1:N) - 1 + n0)' .* ((1:(N/2)) - 1 + 1/2) );
    
    K(end+1) = N;
    V{end+1} = C;
end


%% Return Checks
assert(all(size(C) == [N N/2]), "C is not of size NxN/2")
assert(isnumeric(C), "C is not numeric")
end
