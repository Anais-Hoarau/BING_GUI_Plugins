function [ mCoh, mPha, mGain ] = following( lead, follow, fs )
%COHERENCE Computes the coherence, phase and gain of to signals
%   This methods is used to evaluate the performance of a driver during
%   a following situation.
%
%   This is an implementation of the technique described in
%   Brookhuis, K.A., De Waard, D., & Mulder, L.J.M. (1994).
%
%   More info: http://www.rug.nl/research/heymans-institute/research-programs/traffic_and_environmental_psychology/tools

    lead = lead - mean(lead);
    follow = follow - mean(follow);
    
    l = length(lead);
    nfft = 2^nextpow2(l);
    fftFreqs = fs / 2 * linspace(0, 1, nfft/2+1);
    leadFft = fft(lead, nfft) / l;
    leadFftFiltered = filter(ones(3,1)/3, 1, 2*abs(leadFft(1:nfft/2+1)));
    
    [top, index] = max(leadFftFiltered);
    
    lower = find(leadFftFiltered(1:index(1)) < (.5*top));
    lowFrequencyIndex = [fftFreqs(lower(end)) lower(end)];
    lowFrequencyIndex(1) =  max(floor(100*lowFrequencyIndex(1))/100, fftFreqs(2));
    [~, lowFrequencyIndex(2)] = min(abs(fftFreqs-lowFrequencyIndex(1))) ;

    upper = find(leadFftFiltered(index(1):end) < (.5*top));
    highFrequencyIndex = [fftFreqs(upper(1)+index(1)) upper(1)+index(1)];
    highFrequencyIndex(1) = ceil(100*highFrequencyIndex(1))/100;
    [~, highFrequencyIndex(2)] = min(abs(fftFreqs-highFrequencyIndex(1))) ;
    
    window = [];
    noverlap = [];
    
    [Pxx , ~] = cpsd(lead, lead, window , noverlap , nfft, fs, 'twosided');
    [Pyy , ~] = cpsd(follow, follow, window , noverlap , nfft, fs, 'twosided');
    [Pxy , F] = cpsd(lead, follow, window , noverlap , nfft, fs, 'twosided');

    Kxy  = real( Pxy );
    Qxy  = imag( Pxy );
    coh  = abs(Pxy.*conj(Pxy))./(Pxx.*Pyy);
    pha  = atan2( Qxy, Kxy );
    gain = abs(Pxy./Pxx);
    phas = unwrap(pha)./(2*pi*F);
    
    lfi = lowFrequencyIndex(2);
    hfi = highFrequencyIndex(2);
    
    mCoh = mean(coh(lfi(1):hfi(end)));
    mPha = mean(phas(lfi(1):hfi(end)));
    mGain = mean(gain(lfi(1):hfi(end)));
end

