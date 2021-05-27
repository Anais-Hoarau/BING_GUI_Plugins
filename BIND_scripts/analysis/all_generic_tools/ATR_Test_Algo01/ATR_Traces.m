% ATR_Traces.m
%
% Quelques idées de tracés
%

% les bornes, à définir
% quelques exemples à tester
% a = 16500;  b = 17000;
% a = 16840;  b = 16870;
% a = 31600;  b = 31650;
% a = 107650; b = 107750;
% a = 107800; b = 107900;
% a = 93400;  b = 93900;

figure; plot(X1(a:b),Y1(a:b));hold on; plot(X1(a:b),Y1(a:b),'r+');

figure; plot (MvtOc(a:b), 'DisplayName', 'MvtOc', 'YDataSource', 'MvtOc');

figure; plot (STDcosAPS(a:b), 'DisplayName', 'STDcosAPS', 'YDataSource', 'STDcosAPS');

figure; plot (Amax(a:b), 'DisplayName', 'Amax', 'YDataSource', 'Amax');

figure; plot (vitAmax(a:b), 'DisplayName', 'vitAmax', 'YDataSource', 'vitAmax');

% 
% figure;
% subplot(311); plot(X1(a:b));
% subplot(312); plot(Y1(a:b));
% subplot(313); plot(MvtOc(a:b));

% à corriger & faire les autres valeurs, par exemple :
% 1: red
% 2: vert
% 3: jaune
ind1 = find(MvtOc == 1.);
ind2 = find(MvtOc == 2.);
ind3 = find(MvtOc == 3.);

% autres idées
figure; plot(X1,Y1);hold on; plot(X1,Y1,'+');
plot(X1(ind1),Y1(ind1),'r+');
plot(X1(ind2),Y1(ind2),'g+');
plot(X1(ind3),Y1(ind3),'y+');

figure;
subplot(211); plot(X1,'b-+'); hold on; plot(ind1,X1(ind1),'r+'); plot(ind2,X1(ind2),'g+'); plot(ind3,X1(ind3),'y+');
subplot(212); plot(Y1,'b-+'); hold on; plot(ind1,Y1(ind1),'r+'); plot(ind2,Y1(ind2),'g+'); plot(ind3,Y1(ind3),'y+');

% tracé des qualités
figure; hist(GAZE_QUAL_L+GAZE_QUAL_R);
figure; plot(GAZE_QUAL_L+GAZE_QUAL_R);

% -------------------------------------------------------------------------

% idées pour mettre en sous-programmmes et ne tracer qu'une petite zone
x = X1([a:b]);
y = Y1([a:b]);
mo = MvtOc([a:b]);
am = Amax([a:b]);
vm = vitAmax([a:b]);
sa = STDcosAPS([a:b]);

i1 = find(mo == 1.);
i2 = find(mo == 2.);
i3 = find(mo == 3.);

% figure; plot(x,y); hold on; plot(x,y,'+');
figure; plot(am);
figure; plot(vm);
figure; plot(sa);
figure; plot(mo); hold on; plot(mo,'+');

figure; plot(x,y,'b-+'); hold on; plot(x(i1),y(i1),'r+'); plot(x(i2),y(i2),'g+'); plot(x(i3),y(i3),'y+');


% clear a b x y mo am vm sa



