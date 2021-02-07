function FFout = iTNS(FFin, ft, TNSc)
% Inverse of TNS applies the inverse filter on each frame to undo the
% effects of TNS
%
% Parameters:
%   FFin - The frame in FREQUENCY domain          [Matrix 1024-by-2]
%           If ft is "ESH" the return is 8 128-by-2 matrices one under the other
%   ft - The frame type                           [String]
%           Acceptable inputs: "OLS", "LSS", "ESH", "LPS"
%   TNSc - The TNS coefficient symbols            [Matrix (4|32)-by-2]
%
% Returns:
%   The new signal

%% Type Checks
assert(ismatrix(FFin), "FFin is not matrix")
assert(all(size(FFin) == [1024 2]), "FFin is not of size 1024 by 2" )
assert(isnumeric(FFin), "FFin is not numeric")

assert(isscalar(ft), "ft is not scalar")
assert(isstring(ft), "ft is not string")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)

assert(ismatrix(TNSc), "TNSc is not matrix")
assert(isnumeric(TNSc), "TNSc is not numeric")
assert(all(size(TNSc) == [4 2]) || all(size(TNSc) == [32 2]), "TNSc is not of size 4 by 2 or 32 by 2" )

%% Code
FFout = zeros(size(FFin));
if ft == "ESH"
    for i = 0:7
        for j = 1:size(FFin, 2)
            FFR  = i*128 + (1:128);
            TNSR = i*4 + (1:4);
            a = [1 -dequantize(TNSc(TNSR, j))];
            FFout(FFR, j) = filter(1, a, FFin(FFR, j));
        end
    end
else
    for j = 1:size(FFin, 2)
        a = [1 -dequantize(TNSc(:, j))];
        FFout(:, j) = filter(1, a, FFin(:, j));
    end
end

%% Return Checks
assert(ismatrix(FFout), "FFout is not matrix")
assert(all(size(FFout) == size(FFin)), "FFout is not of the same size as FFin" )
assert(isnumeric(FFout), "FFout is not numeric")
end
