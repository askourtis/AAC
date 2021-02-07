function [FFout, TNSc] = TNS(FFin, ft)
% Applies the TNS transformation on the given frame
%
% Parameters:
%   FFin - The frame in FREQUENCY domain          [Matrix 1024-by-2]
%           If ft is "ESH" the return is 8 128-by-2 matrices one under the other
%   ft - The frame type                           [String]
%           Acceptable inputs: "OLS", "LSS", "ESH", "LPS"
%
% Returns:
%   FFout - The new signal                        [Matrix 1024-by-2]
%   TNSc - The TNS coefficient symbols            [Matrix (4|32)-by-2]

%% Type Checks
assert(ismatrix(FFin), "FFin is not matrix")
assert(all(size(FFin) == [1024 2]), "FFin is not of size 1024 by 2" )
assert(isnumeric(FFin), "FFin is not numeric")

assert(isscalar(ft), "ft is not scalar")
assert(isstring(ft), "ft is not string")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)


%% Load data
persistent B
if isempty(B)
    B = importdata('TableB219.mat');
end

%% Code
if ft == "ESH"
    % Prepare bands
    b = [ B.B219b(:, 2) B.B219b(:, 3) ] + 1;
    
    % Preallocate
    FFout = zeros(size(FFin));
    TNSc = zeros([32, size(FFin, 2)]);
    
    % For each subframe
    for i = 0:7
        % Define ranges for the given i
        FFR  = i*128 + (1:128);
        TNSR = i*4 + (1:4);
        
        % Select the FFin subframe
        X  = FFin(FFR,:);
        % Normalize
        Sw = normalizationCoeff(X, b);
        Xw = X ./ Sw;
        % Compute linear coefficients
        a  = [linearCoeffs(Xw(:,1)) linearCoeffs(Xw(:,2))];
        
        % Quantize and compute FFout based on the quantized coefficients
        TNSc(TNSR,:) = quantize(a);
        a = dequantize(TNSc(TNSR,:));
        FFout(FFR,:) = applyFilter(X, a);
    end
else
    % Prepare bands
    b = [ B.B219a(:, 2) B.B219a(:, 3) ] + 1;
    
    % Normalize
    Sw  = normalizationCoeff(FFin, b);
    Xw  = FFin ./ Sw;
    % Compute linear coefficients
    a = [linearCoeffs(Xw(:,1)) linearCoeffs(Xw(:,2))];
    
    % Quantize and compute FFout based on the quantized coefficients
    TNSc = quantize(a);
    a = dequantize(TNSc);
    FFout = applyFilter(FFin, a);
end

%% Return Checks
assert(ismatrix(FFout), "FFout is not matrix")
assert(all(size(FFout) == size(FFin)), "FFout is not of the same size as FFin" )
assert(isnumeric(FFout), "FFout is not numeric")

assert(ismatrix(TNSc), "TNSc is not matrix")
assert(isnumeric(TNSc), "TNSc is not numeric")
assert(all(size(TNSc) == [4 2]) || all(size(TNSc) == [32 2]), "TNSc is not of size 4 by 2 or 32 by 2" )
end


function Sw = normalizationCoeff(X, b)
% Computes the normalization coefficients of X
%% Calculate energy P and initial Sw
Sw = zeros(size(X));
for j = 1:length(b)
    k = b(j,1):b(j,2);
    P = sum(X(k,:).^2, 1);
    Sw(k,:) = repmat(sqrt(P), [length(k) 1]);
end
%% Smoothen Sw
for k = length(Sw) - 1:-1:1
    Sw(k,:) = (Sw(k,:) + Sw(k+1,:)) / 2;
end
for k = 2:length(Sw)
    Sw(k,:) = (Sw(k,:) + Sw(k-1,:)) / 2;
end
end


function a = linearCoeffs(X)
% Computes the linear coefficients

% Calculate autocorrelation for 4 lags
r = autocorr(X, 'NumLags', 4);
r = r(2:end);

% Autocorrelation is always an even function
% r(-x) = r(x)
% r(0)  = 1
R = [
        1    r(1) r(2) r(3);
        r(1) 1    r(1) r(2);
        r(2) r(1) 1    r(1);
        r(3) r(2) r(1) 1
    ];

% Solve Ra = r => a = R^-1 r
a = R\r;
end

function FFout = applyFilter(FFin, a)
% Apply the filter for the a coefficients on the input FFin

% Prepare output
FFout = zeros(size(FFin));

% Columnwise loop
for i = 1:size(FFin, 2)
    FFout(:,i) = filter([1; -a(:,i)], 1, FFin(:,i));
end

end
