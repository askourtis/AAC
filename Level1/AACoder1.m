function AACSeq1 = AACoder1(fNameIn)
% Reads and converts to frequency domain the data of the given filename
%
% Parameters:
%   fNameIn - The name of the file [string]
%
% Returns:
%   The frames in FREQUENCY domain
%       STRUCT:
%           frameType   - The type of the frame                           [String]
%           winType     - The type of the window                          [String]
%           chl         - The FREQUENCY domain frame of the left channel  [vector 1024-by-1]
%           chr         - The FREQUENCY domain frame of the right channel [vector 1024-by-1]


%% Type Checks
assert(isscalar(fNameIn), "fNameIn is not a scalar")
assert(isstring(fNameIn), "fNameIn is not a string")

%% Code
% Form output
AACSeq1 = struct('frameType',   {},                     ... 
                 'winType',     {},                     ...
                 'chl',         struct('frameF', {}),   ...
                 'chr',         struct('frameF', {}));

% Frame width and window type
FW = 2048;
wt = "KBD";

% Read the file
in = audioread(fNameIn);

% Extra zeros size to complete a frame
M = FW - mod(size(in, 1), FW);
% ZeroPad not to lose information
data = [zeros(FW/2, 2); in; zeros(M + FW/2, 2)];
N = size(data,1);

% C frames fit in the total frame width
C = 2 * N/FW - 1;

% Initialize
pft = "OLS";
FT  = data(1:FW, :);
% Loop
for i = 1:C-1
    % Get the next frame with 1/2 overlap
    NFTR = (1:FW) + i*FW/2;
    NFT = data(NFTR, :);
    
    % Calculate the frame type
    pft = SSC(FT, NFT, pft);
    
    % Calculate the FREQUENCY domain frame
    FF = filterbank(FT, pft, wt);
    
    % Assign to output
    AACSeq1(i).frameType = pft;
    AACSeq1(i).winType = wt;
    AACSeq1(i).chl.frameF = FF(:, 1);
    AACSeq1(i).chr.frameF = FF(:, 2);
    
    % Current FT = Next FT
    FT = NFT;
end
end
