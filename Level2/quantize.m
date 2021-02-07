function b = quantize(a)
b = zeros(size(a));
d = (-0.7:0.1:0.7) - 0.05;

for i = 1:size(a,2)
    b(:,i) = min(max(sum(a(:,i) > d, 2), 1), 15);
end
end