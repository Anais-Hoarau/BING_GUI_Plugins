% % buffer_ecg(end) = input;
% % output = buffer_ecg;
% 
% x = (1:100);
% n = 10;
% p = 9;
% % if cmpt > 50
% y = buffer(x,n,p);
% % end
% % cmpt = cmpt+1;

% buffSize = 10000;
% circBuff = nan(1,buffSize);

% for input = 1:100000
%     circBuff = [input circBuff(1:end-1)];
% end

circBuff = [input circBuff(1:end-1)];
output = circBuff;

if 
    
end