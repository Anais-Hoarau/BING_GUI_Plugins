function [ Pxx, Pyy, Pxy, coh, pha, phas, gain, F ] = coherence( a, b, window , noverlap , nfft, Fs )

%function [ Pxx, Pyy, Pxy, Pxyc , coh, pha, F ] = coherence( a, b, nfft, Fs, filt, noverlap )

%
% Computing power spectrum, cross spectrum, coherence and phase
%
% All input parameters are equivalent to csd or the other spectrum 
% related function in MATLAB.
%
% This program use csd.m in Signal Processing Toolbox.
%
% Input
%	a and b	input data (in time domain)
%	nfft		number of data for FFT
%	Fs		sampling frequency
%	filt		filter vector, hanning(nfft/2)
%	n_overlap	number of overlap for smoothing
%
% Output
%	Pxx		spectrum of f1
%	Pyy		spectrum of f2
%	Pxy		cross spectrum between f1 and f2
%	coh		coherence
%	pha		phase
%	freq		frequency vector

%--------------------------------------------------------------------------------
% zero-pad shorter time series if necessary (so that length(a)=length(b).
% Note that a and b are N x 1 column vectors
if length(a) < length(b) a = [a ; zeros(length(b)-length(a) , 1)]; end
if length(b) < length(a) b = [b ; zeros(length(a)-length(b) , 1)]; end

%--------------------------------------------------------------------------------
%The business

% [Pxx, Pxyc , F] = csd( a, a, nfft, Fs, filt, noverlap );       %autospectra a
% [Pyy, Pyyc , F] = csd( b, b, nfft, Fs, filt, noverlap );       %autospectra b
% [Pxy, Pxxc , F] = csd( a, b, nfft, Fs, filt, noverlap );       %Cross spectra

%CSD superceded (still works); CPSD does not detrend.  do this first
[Pxx , F] = cpsd( a, a, window , noverlap , nfft, Fs, 'twosided');       %autospectra a
[Pyy , F] = cpsd( b, b, window , noverlap , nfft, Fs, 'twosided');       %autospectra b
[Pxy , F] = cpsd( a, b, window , noverlap , nfft, Fs, 'twosided');       %Cross spectra

Kxy  = real( Pxy );
Qxy  = imag( Pxy );
coh  = abs(Pxy.*conj(Pxy))./(Pxx.*Pyy);
pha  = atan2( Qxy, Kxy );                  %4 quadrants in complex plane [-pi,pi]
%pha  = atan( Qxy ./ Kxy );                  %assumes positive frequencies (positive lags) [-pi/2 , pi/2]
gain = abs(Pxy./Pxx);
phas = unwrap(pha)./(2*pi*F);

