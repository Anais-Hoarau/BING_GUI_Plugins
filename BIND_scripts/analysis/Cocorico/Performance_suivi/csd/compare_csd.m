ts = load('test.txt');

ts0 = ts(1,:);
ts1 = ts(2,:);

ts0 = ts0 - mean(ts0);
ts1 = ts1 - mean(ts1);

NFFT = 1024*8;
Fs = 60/1;
noverlap = NFFT/16;
noverlap = [];

window = hanning(NFFT);
% window = hamming(NFFT);
window = [];
%[fxx, f] = csd(ts0, ts1, NFFT, Fs, window, noverlap, 'mean');
%fxx = real(fxx);

[Pxx, f] = cpsd(ts0, ts0, window, noverlap, NFFT, Fs);
[Pyy, f] = cpsd(ts1, ts1, window, noverlap, NFFT, Fs);
[Pxy, f] = cpsd(ts0, ts1, window, noverlap, NFFT, Fs);

Kxy  = real( Pxy );
Qxy  = imag( Pxy );
coh  = abs(Pxy.*conj(Pxy))./(Pxx.*Pyy);
pha  = atan2( Qxy, Kxy );                  %4 quadrants in complex plane [-pi,pi]
%pha  = atan( Qxy ./ Kxy );                  %assumes positive frequencies (positive lags) [-pi/2 , pi/2]
gain = abs(Pxy./Pxx);
phas = unwrap(pha)./(2*pi*f);

mean(coh(6:14))
mean(phas(6:14))
mean(gain(6:14))