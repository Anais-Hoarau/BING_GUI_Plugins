ts = load('following.txt');

ts0 = ts(1,:);
ts1 = ts(2,:);

[coh, pha, gain] = following(ts0, ts1, 60)

