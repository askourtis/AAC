function FT = iFilterbank(FF, ft, wt)
% Converts the given frame from FREQUENCY domain to TIME domain given the
% frame type and the window type
%
% Parameters:
%   FF - The frame in FREQUENCY domain          [Matrix 1024-by-2]
%           If ft is "ESH" the return is 8 128-by-2 matrices one under the other
%   ft - The frame type                         [String]
%           Acceptable inputs: "OLS", "LSS", "ESH", "LPS"
%   wt - The window type
%           Acceptable inputs: "KBD", "SIN"
%
% Returns:
%   The frame in the FREQUENCY domain      [Matrix 2048-by-2]

%% Type Checks
assert(ismatrix(FF), "FF is not matrix")
assert(all(size(FF) == [1024 2]), "FF is not of size 1024 by 2" )
assert(isnumeric(FF), "FF is not numeric")

assert(isscalar(ft), "ft is not scalar")
assert(isstring(ft), "ft is not string")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)

assert(isscalar(wt), "wt is not scalar")
assert(isstring(wt), "wt is not string")
assert(any(wt == ["KBD" "SIN"]), "'%s' value for wt is not acceptable", wt)

%% Code
W = window(ft, wt);

if ft == "ESH"
    FT = zeros(2048,2);
    for i = 0:7
        FFR = (1:128) + i * 128;
        FTR = 448 + (1:256) + i * 128;
        FT(FTR,:) = FT(FTR,:) + iMDCT(FF(FFR,:), W);
    end
elseif any(ft == ["OLS" "LSS" "LPS"])
    FT = iMDCT(FF, W);
else
    error("Code should not reach this point. ft = '%s'", ft)
end

%% Return Checks
assert(ismatrix(FT), "FT is not matrix")
assert(all(size(FT) == [2048 2]), "FT is not of size 2048 by 2" )
assert(isnumeric(FT), "FT is not numeric")
end

