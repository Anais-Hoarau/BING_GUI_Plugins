function seuilAmpliMinPicR = MadisonDetectMax(sig, nbptfenetre)
    
    nbpt = length(sig);
    nbfen= floor(nbpt/nbptfenetre);
    valmax = zeros(nbfen,1);
    for i=1:nbfen-1
        valmax(i) = max(sig((i-1)*nbptfenetre+1: i*nbptfenetre));
    end
    xx= -2:0.1:2;
    histvalmax = hist(valmax,xx);
    [maxpic, indexmaxpix] =findpeaks(histvalmax);
    [~,  indexpospicmax] = max(maxpic);
    v1 = xx(indexmaxpix(indexpospicmax));
    maxpic(indexpospicmax)=0;
    [~ , indexpospicmax] = max(maxpic);
    v2 = xx(indexmaxpix(indexpospicmax));
    seuilAmpliMinPicR = (v1+v2)/2;
    
end