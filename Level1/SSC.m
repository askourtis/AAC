function ft = SSC(CFT, NFT, pft)
% The function SSC calculates the frame type of the current frame, given
% the next frame and the previous frame type
%
% Parameters:
%   CF  - The current frame                 [Matrix 2048-by-2]
%   NF  - The nect frame                    [Matrix 2048-by-2]
%   pft - The previous frame type           [String]
%           Acceptable inputs: "OLS", "LSS", "ESH", "LPS"
%
% Returns:
%   The type of the current frame
%       Possible returns: "OLS", "LSS", "ESH", "LPS"

%% Type checks
assert(ismatrix(CFT), "CFT is not matrix")
assert(isnumeric(CFT), "CFT is not numeric")
assert(all(size(CFT) == [2048 2]), "CFT is not of size 2048 by 2")

assert(ismatrix(NFT), "NFT is not matrix")
assert(isnumeric(NFT), "NFT is not numeric")
assert(all(size(NFT) == [2048 2]), "NFT is not of size 2048 by 2")

assert(isscalar(pft), "pft is not scalar")
assert(isstring(pft), "pft is not string")
assert(any(pft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for pft is not acceptable", pft)

%% Code
if pft == "LSS"
    % If previous frame is LSS return ESH
    ft = "ESH";
elseif pft == "LPS"
    % If previous frame is LPS return OLS
    ft = "OLS";
else
    % Calculate if NFT is ESH
    isNFESH = isESH(NFT);
    % Deduce the current type for both channels
    TR = deduceType(isNFESH(1), pft);
    TL = deduceType(isNFESH(2), pft);
    % Combine with the given combination table
    ft = combineTypes(TR, TL);
end

%% Return Checks
assert(isstring(ft), "ft is not string")
assert(isscalar(ft), "ft is not scalar")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)
end


function R = isESH(F)
% isESH calculates if the frame is ESH for both channels
%
% Parameters:
%   F - The frame           [Matrix 2048-by-2]
%
% Returns:
%   A logical vector        [Vector 1-by-2]

%% Type Checks
assert(isnumeric(F), "F is not numeric")
assert(ismatrix(F), "F is not a matrix")
assert(all(size(F) == [2048 2]), "F is not of size 2048-by-2")

%% Code
% Select the active region for ESH
A = F(577:1600,:);
% Apply the filter
H = filter([0.7548, -0.7548], [1, -0.5095], A);
% Reshape for convenience
H = reshape(H, [128 8 2]);
% Calculate S^2
S2 = squeeze(sum(H.^2));
% Calculate cumulative AVG
CA = cumsum(S2(1:end-1,:)) ./ repmat(1:(size(S2,1)-1), [2 1])';
% Calculate dS^2
DS2 = S2(2:end,:) ./ CA;
% Deduce if the channel is ESH
R = any(S2(2:end,:) > 10^-3 & DS2 > 10);

%% Return Checks
assert(islogical(R), "R is not logical")
assert(isvector(R), "R is not vector")
assert(all(size(R) == [1 2]), "R is not of size 1-by-2")
end

function ft = deduceType(esh, pft)
% Deduction table for next frame and previous frame
%
% Parameters:
%   esh - Next frame type       [Logical]
%   pft - Previous frame type   [String]
%           Acceptable inputs: "OLS", "ESH"
%
% Returns:
%   The type of the current frame
%       Possible returns: "OLS", "LSS", "ESH", "LPS"

%% Type Checks
assert(islogical(esh), "esh is not logical");
assert(isscalar(esh), "esh is not scalar");

assert(isstring(pft), "pft is not string");
assert(isscalar(pft), "pft is not scalar");
assert(any(pft == ["OLS" "ESH"]), "'%s' value for pft is not acceptable", pft)

%% Code
if pft == "OLS"
    if esh
        ft = "LSS";
    else
        ft = "OLS";
    end
elseif pft == "ESH"
    if esh
        ft = "ESH";
    else
        ft = "LPS";
    end
else
    error("Code should not reach this point. pft = '%s'", pft)
end

%% Return Checks
assert(isstring(ft), "ft is not string")
assert(isscalar(ft), "ft is not scalar")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)
end

function ft = combineTypes(TL, TR)
% Combination table for the channels
%
% Parameters:
%   TL - The type of the left channel       [String]
%   TR - The type of the right channel      [String]
%
% Returns:
%   The type of the whole frame
%       Possible returns: "OLS", "LSS", "ESH", "LPS"

%% Type Checks
assert(isstring(TL), "TL is not string");
assert(isscalar(TL), "TL is not scalar");
assert(any(TL == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for TL is not acceptable", TL)

assert(isstring(TR), "TR is not string");
assert(isscalar(TR), "TR is not scalar");
assert(any(TR == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for TR is not acceptable", TR)

%% Code
if TL == TR
    ft = TL;
elseif any([TL TR] == "ESH")
    ft = "ESH";
elseif TL == "OLS"
    ft = TR;
elseif TR == "OLS"
    ft = TL;
else
    ft = "ESH";
end

%% Return Checks
assert(isstring(ft), "ft is not string")
assert(isscalar(ft), "ft is not scalar")
assert(any(ft == ["OLS" "LSS" "ESH" "LPS"]), "'%s' value for ft is not acceptable", ft)
end

