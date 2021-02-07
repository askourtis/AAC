function [FFout, TNSc] = TNS(FFin, ft)
%TNS Implements the Temporal Noise Shaping.
%   [FRAMEFOUT, TNSCOEFFS] = TNS(FRAMEFIN, FRAMETYPE) will perform TNS on frame FRAMEFIN of frame
%   type FRAMETYPE. TNSCOEFFS are tha quantized TNS coefficients 4 x 8 for 'ESH' frame type and 4 x 1
%   for other frame types. FRAMEFOUT are the MDCT coefficients after TNS, same size as FRAMEFIN.
%
%   See also ITNS.


if ft == "ESH"
    load('TableB219.mat','B219b')
    b = [ B219b(:, 2) B219b(:, 3) ] + 1;
    
    FFout = zeros(size(FFin));
    TNSc = zeros([32, size(FFin, 2)]);
    
    for i = 0:7
        FFR  = i*128 + (1:128);
        TNSR = i*4 + (1:4);
        
        X  = FFin(FFR,:);
        Sw = normalizationCoeff(X, b);
        Xw = X ./ Sw;
        a = [linearCoeffs(Xw(:,1)) linearCoeffs(Xw(:,2))];
        
        TNSc(TNSR,:) = quantize(a);
        a = dequantize(TNSc(TNSR,:));
        FFout(FFR,:) = applyFilter(X, a);
    end
    
else
    load('TableB219.mat','B219a')
    b = [ B219a(:, 2) B219a(:, 3) ] + 1;
    
    Sw  = normalizationCoeff(FFin, b);
    Xw  = FFin ./ Sw;
    a = [linearCoeffs(Xw(:,1)) linearCoeffs(Xw(:,2))];
    TNSc = quantize(a);
    a = dequantize(TNSc);
    FFout = applyFilter(FFin, a);
end
end


function Sw = normalizationCoeff(X, b)
%% Calculate energy P and initial Sw.
Sw = zeros(size(X));
for j = 1:length(b)
    k = b(j,1):b(j,2);
    P = sum(X(k,:).^2, 1);
    Sw(k,:) = repmat(sqrt(P), [length(k) 1]);
end
%% Smoothen Sw.
for k = length(Sw) - 1:-1:1
    Sw(k,:) = (Sw(k,:) + Sw(k+1,:)) / 2;
end
for k = 2:length(Sw)
    Sw(k,:) = (Sw(k,:) + Sw(k-1,:)) / 2;
end
end


function a = linearCoeffs(X)

% Calculate autocorrelation for 4 lags
r = autocorr(X, 'NumLags', 4);

% Autocorrelation is always
R = [
        r(1) r(2) r(3) r(4);
        r(2) r(1) r(2) r(3);
        r(3) r(2) r(1) r(2);
        r(4) r(3) r(2) r(1)
    ];

r = r(2:end);
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
