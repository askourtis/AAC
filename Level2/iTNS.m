function FFout = iTNS(FFin, ft, TNSc)
%ITNS Inverts Temporal Noise Shaping.
%   FRAMEFOUT = ITNS(FRAMEFIN, FRAMETYPE, TNSCOEFFS) will invert TNSs output.
%
%   See also TNS.

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
end
