function x = iAACoder1(AACSeq1, fNameOut)
% Converts to TIME domain the given inputs and writes to file
%
% Parameters:
%   AACSeq1  - The signal in the FREQUENCY domain [STRUCT]
%       STRUCT:
%           frameType   - The type of the frame                           [String]
%           winType     - The type of the window                          [String]
%           chl         - The FREQUENCY domain frame of the left channel  [vector 1024-by-1]
%           chr         - The FREQUENCY domain frame of the right channel [vector 1024-by-1]
%   fNameOut - The name of the file [string]
%
% Returns [Optional]:
%   The signal in the TIME domain

%% Type Checks
assert(isscalar(fNameOut), "fNameOut is not a scalar")
assert(isstring(fNameOut), "fNameOut is not a string")

%% Code
% C frames
C = length(AACSeq1);
% The size given the frames
N = (C + 1) * 1024;
% Initialize the decoded signal in the TIME domain
D = zeros(N, 2);

% For each frame
for i = 1:C
    % Convert FF to FT
    FF = [AACSeq1(i).chl.frameF AACSeq1(i).chr.frameF];
    FT = iFilterbank(FF, AACSeq1(i).frameType, AACSeq1(i).winType);
    
    % Add the result to the correct place acounting the overlap
    DR = (1:2048) + (i-1)*1024;
    D(DR,:) = D(DR,:) + FT;
end

% Remove padded zeros.
D = D(1024+1:end-1024, :);


% Save results.
audiowrite(convertStringsToChars(fNameOut), D, 48000);

% Return if need to
if nargout == 1
    x = D;
end
end
