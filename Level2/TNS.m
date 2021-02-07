function [FFout, TNSc] = TNS(FFin, ft)
%TNS Implements the Temporal Noise Shaping.
%   [FRAMEFOUT, TNSCOEFFS] = TNS(FRAMEFIN, FRAMETYPE) will perform TNS on frame FRAMEFIN of frame
%   type FRAMETYPE. TNSCOEFFS are tha quantized TNS coefficients 4 x 8 for 'ESH' frame type and 4 x 1
%   for other frame types. FRAMEFOUT are the MDCT coefficients after TNS, same size as FRAMEFIN.
%
%   See also ITNS.



FFout = zeros(size(FFin));
TNSc = zeros([4, size(FFin, 2)]);

if ft == "ESH"
    load('TableB219.mat','B219b')
    b = [ B219b(:, 2) B219b(:, 3) ] + 1;
    
    for i = 0:7
        FFR  = i*128 + (1:128);
        TNSR = i*4 + (1:4);
        X  = FFin(FFR,:);
        Sw = normalizationCoeff(X, b);
        Xw = X ./ Sw;
        a = [linearCoeffs(Xw(:,1)) linearCoeffs(Xw(:,2))];
        a = quantizeCoeffs(a);
        [FFout(FFR,1), TNSc(TNSR,1)] = filterFrame(X(:,1), a(:,1));
        [FFout(FFR,2), TNSc(TNSR,2)] = filterFrame(X(:,2), a(:,2));
    end
    
else
    load('TableB219.mat','B219a')
    b = [ B219a(:, 2) B219a(:, 3) ] + 1;
    
    Sw  = normalizationCoeff(FFin, b);
    Xw  = FFin ./ Sw;
    a = [linearCoeffs(Xw(:,1)) linearCoeffs(Xw(:,2))];
    a = quantizeCoeffs(a);
    [FFout(:,1), TNSc(:,1)] = filterFrame(FFin(:,1), a(:,1));
    [FFout(:,2), TNSc(:,2)] = filterFrame(FFin(:,2), a(:,2));  
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
p = 4;
r = autocorr(X, 'NumLags', p);

R = [
        r(1) r(2) r(3) r(4);
        r(2) r(1) r(2) r(3);
        r(3) r(2) r(1) r(2);
        r(4) r(3) r(2) r(1)
    ];

r = r(2:end);
a = R\r;
end


function ca = quantizeCoeffs(a)
ca = max(min(round(a,1), 0.7), -0.7);
end


function [frameFout, a] = filterFrame(frame, a)
a = [1; -a];
a = makeInvertible(a);
frameFout = filter(a, 1, frame);
a = -a(2:end);
end


function ia = makeInvertible(a)
r = roots(a);
if any( r > 1 | r < -1 )
    e = 0.001;
    r(r == 0) = e; % Avoid division by zero.
    % Force roots inside |z| < 1 circle.
    r(r > 1) = 1 - e;
    r(r < -1) = - 1 + e;
    ia = poly(r); % Recreate.
else
    ia = a;
end
end
