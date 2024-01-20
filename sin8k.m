fs = 8000;
f = 2000;
dt = 1/fs;
t = 0:dt:1;

sig = sin(2*pi*f*t);
% plot(t, sig)
sound(sig, fs)

% 