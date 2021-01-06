function SNR = demoAAC1(fNameIn, fNameOut)
% Demonstration for Level 1
%
% Parameters:
%   fNameIn - The name of the input file   [string]
%   fNameOut - The name of the output file [string]
%
% Returns:
%   The SNR of the signal after encoding and decoding


%% Type Checks
assert(isscalar(fNameOut), "fNameOut is not a scalar")
assert(isstring(fNameOut), "fNameOut is not a string")

assert(isscalar(fNameIn), "fNameIn is not a scalar")
assert(isstring(fNameIn), "fNameIn is not a string")

%% Code
% Read Input file
IN = audioread(fNameIn);
% Pad to complete last frame
IN = [IN; zeros(1024 - mod(length(IN), 1024),2)];

% Encode
EN = AACoder1(fNameIn);
% Decode
DE = iAACoder1(EN, fNameOut);

% Calculate Noise and SNR
NOISE = IN-DE;
SNR = snr(IN, NOISE);
end
