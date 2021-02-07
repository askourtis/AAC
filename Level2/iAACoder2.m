function x = iAACoder2(AACSeq2, fNameOut)
% Converts to TIME domain the given inputs and writes to file
%
% Parameters:
%   AACSeq1  - The signal in the FREQUENCY domain [STRUCT]
%       STRUCT:
%           frameType   - The type of the frame                           [String]
%           winType     - The type of the window                          [String]
%           chl         - STRUCT:
%                           The FREQUENCY domain frame of the left channel                [vector 1024-by-1]
%                           The TNS coefficients for the given frame of the left channel  [vector (4|32)-by-1]
%           chl         - STRUCT:
%                           The FREQUENCY domain frame of the right channel                [vector 1024-by-1]
%                           The TNS coefficients for the given frame of the right channel  [vector (4|32)-by-1]
%   fNameOut - The name of the file [string]
%
% Returns [Optional]:
%   The signal in the TIME domain

%% Type Checks
assert(isscalar(fNameOut), "fNameOut is not a scalar")
assert(isstring(fNameOut), "fNameOut is not a string")

%% Code
% C frames
C = length(AACSeq2);
% The size given the frames
N = (C + 1) * 1024;
% Initialize the decoded signal in the TIME domain
D = zeros(N, 2);

% For each frame
for i = 1:C
    % Apply iTNS
    FF   = [AACSeq2(i).chl.frameF    AACSeq2(i).chr.frameF];
    TNSc = [AACSeq2(i).chl.TNScoeffs AACSeq2(i).chr.TNScoeffs];
    FF = iTNS(FF, AACSeq2(i).frameType, TNSc);
    
    % Convert FF to FT
    FT = iFilterbank(FF, AACSeq2(i).frameType, AACSeq2(i).winType);
    
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
