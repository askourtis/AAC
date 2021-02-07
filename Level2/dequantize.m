function a = dequantize(b)
% Converts symbols b to values a
%
% Parameters:
%   b - Any integer between 1 and 15
%
% Returns:
%   The value associated with the symbol b
L = -0.7:0.1:0.7;
a = L(b);
end

