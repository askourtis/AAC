function WIN = window(ft, wt)
% Produces the correct window given the window type and the frame type
%
% Parameters:
%   ft - The frame type                    [String]
%           Acceptable inputs: "OLS", "LSS", "ESH", "LPS"
%   wt - The window type                   [String]
%           Acceptable inputs: "KBD", "SIN"
%
% Returns:
%   The window  [Vector Nx1]

%% Type Checks
assert(isscalar(ft), "ft is not scalar")
assert(isstring(ft), "ft is not string")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)

assert(isscalar(wt), "wt is not scalar")
assert(isstring(wt), "wt is not string")
assert(any(wt == ["KBD" "SIN"]), "'%s' value for wt is not acceptable", wt)

%% Code
if ft == "ESH"
    N = 256;
    alpha = 4;
elseif any(ft == ["OLS" "LSS" "LPS"])
    N = 2048;
    alpha = 6;
else
    error("Code should never reach this point. ft = '%s'", ft)
end

switch ft
    case { "OLS", "ESH" }
        if wt == "KBD"
            WIN = kbdwindow(N, alpha);
        else
            WIN = sinwindow(N);
        end
    case "LSS"
        WIN            = window("OLS", wt);
        WIN(1345:1600) = window("ESH", wt);
        WIN(1025:1472) = 1;
        WIN(1601:end)  = 0;
    case "LPS"
        WIN = flip(window("LSS", wt));
    otherwise
        error("Code should never reach this point. ft = '%s'", ft)
end

%% Return Checks
assert(isvector(WIN), "WIN is not vector")
assert(isnumeric(WIN), "WIN is not numeric")
assert(all(size(WIN) == [N 1]), "WIN is not of size Nx1")
end

function WIN = kbdwindow(N, alpha)
% Produces and caches a sin window with width N
%
% Parameters:
%   N - The width of the window
%
% Returns:
%   The window  [Vector Nx1]

%% Type Checks
assert(isscalar(N), "N is not scalar")
assert(isnumeric(N), "N is not numeric")
assert(floor(N) == N, "N is not integer")
assert(N > 0, "N is not positive")

assert(isscalar(alpha), "alpha is not scalar")
assert(isnumeric(alpha), "alpha is not numeric")
assert(floor(alpha) == alpha, "alpha is not integer")
assert(alpha > 0, "alpha is not positive")

%% Code
% K keys
% A keys
% V values
persistent K A V

% Initialize cache
if isempty(K)
    K = [];
    A = [];
    V = {};
end

% Check if N is in the chace
I = find(K == N & A == alpha, 1);

% If N is in the cache
if ~isempty(I)
    WIN = V{I};
else
    W   = kaiser(N/2 + 1, alpha*pi);
    H   = sqrt( cumsum(W(1:end-1)) ./ sum(W) );
    WIN = [H; flip(H)];
    
    K(end+1) = N;
    A(end+1) = alpha;
    V{end+1} = WIN;
end

%% Return Checks
assert(isvector(WIN), "WIN is not vector")
assert(isnumeric(WIN), "WIN is not numeric")
assert(all(size(WIN) == [N 1]), "WIN is not of size Nx1")
end

function WIN = sinwindow(N)
% Produces and caches a sin window with width N
%
% Parameters:
%   N - The width of the window
%
% Returns:
%   The window  [Vector Nx1]

%% Type Checks
assert(isscalar(N), "N is not scalar")
assert(isnumeric(N), "N is not numeric")
assert(floor(N) == N, "N is not integer")
assert(N > 0, "N is not positive")

%% Code
% K keys
% V values
persistent K V

% Initialize cache
if isempty(K)
    K = [];
    V = {};
end

% Check if N is in the chace
I = find(K == N, 1);

% If N is in the cache
if ~isempty(I)
    WIN = V{I};
else
    WIN = sin(pi/N * ((1:N) - 1 + 1/2))';
    
    K(end+1) = N;
    V{end+1} = WIN;
end

%% Return Checks
assert(isvector(WIN), "WIN is not vector")
assert(isnumeric(WIN), "WIN is not numeric")
assert(all(size(WIN) == [N 1]), "WIN is not of size Nx1")
end