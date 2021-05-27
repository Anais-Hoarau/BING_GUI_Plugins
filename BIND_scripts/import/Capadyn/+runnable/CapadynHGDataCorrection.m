function CapadynHGDataCorrection(data_file)
load(data_file)

% distance_f(1:400)=distance_f(1:400)/8; % if peak is not present
% distance_f(8020:8040)=distance_f(8020:8040)*4; % if peak is not present
% distance_f(9700:end)=distance_f(9700:end)*1.3; % if peak is not present

distance_f_inv = -distance_f;

MPH1 = 0.1;
MPD1 = 30;
MPP1 = 0.05;
MINW1 = 2;
findpeaks(distance_f,'minpeakheight',MPH1,'MinPeakDistance',MPD1,'MinPeakProminence',MPP1,'WidthReference','halfprom','MinPeakWidth',MINW1,'Annotate','extents')

hold on;

MPH = -0.4;
MaxPH = 0.08;
MPD = 25;
MPP = 0.05;
MINW = 15;
findpeaks(distance_f_inv,'minpeakheight',MPH,'maxpeakheight',MaxPH,'MinPeakDistance',MPD,'MinPeakProminence',MPP,'WidthReference','halfprom','MinPeakWidth',MINW,'Annotate','extents')
[N_distance_max_y,N_pic_min] = findpeaks(distance_f_inv,'minpeakheight',MPH,'maxpeakheight',MaxPH,'MinPeakDistance',MPD,'MinPeakProminence',MPP,'WidthReference','halfprom','MinPeakWidth',MINW);
N_distance_max_y = -N_distance_max_y;
plot(N_pic,N_distance_max,N_pic_min,N_distance_max_y)

N_distance_max_x = zeros(1,length(N_distance_max))';
if length(N_distance_max_y) == length(N_distance_max)
    for i_pk = 1:length(N_distance_max)
        N_distance_max_x(i_pk) = N_distance_max(i_pk) * (1 - (N_distance_max_y(i_pk)/N_distance_max(i_pk))^2)^0.5;
    end
end

hold off
plot(N_pic,N_distance_max,N_pic,N_distance_max_x,N_pic,N_distance_max_y)

%% vitesse
N_vitesse = zeros(size(N_pic));
tempo = N_distance_max_x(2:length(N_distance_max_x))./(diff(N_pic)*0.01)*3.6;
N_vitesse(2:length(N_vitesse)) = tempo;

clearvars tempo;

%% N_values put in time
i_pic = 1;
rythme_pas = zeros(1,length(distance_f))';
vitesse_pas_x = zeros(1,length(distance_f))';
distance_pas_x = zeros(1,length(distance_f))';
for i_value = 1:N_pic(end)
    if i_value < N_pic(i_pic)
        rythme_pas(i_value) = N_rythme(i_pic);
        vitesse_pas_x(i_value) = N_vitesse(i_pic);
        distance_pas_x(i_value) = N_distance_max_x(i_pic);
    elseif i_value == N_pic(i_pic)
        rythme_pas(i_value) = N_rythme(i_pic);
        vitesse_pas_x(i_value) = N_vitesse(i_pic);
        distance_pas_x(i_value) = N_distance_max_x(i_pic);
        i_pic = i_pic+1;
    end
end

%% Check distances
mean(N_distance_max)
sum(N_distance_max)
mean(N_distance_max_y)
sum(N_distance_max_y)
mean(N_distance_max_x)
sum(N_distance_max_x)

%% Save data
save( ...
    data_file,'acc_d_p','acc_g_p','acc_terre_x_d_p','acc_terre_x_g_p', ...
    'acc_terre_y_d_p','acc_terre_y_g_p','acc_terre_z_d_p','acc_terre_z_g_p', ...
    'data_l','distance','distance_f','distance_pas','distance_pas_x','gyro_d_p','gyro_g_p', ...
    'N_distance_max','N_distance_max_x','N_pic','N_rythme','N_vitesse','q_d_p','q_g_p', ...
    'rythme_pas','vitesse_pas','vitesse_pas_x','x_d_p','x_g_p','y_d_p','y_g_p','z_d_p','z_g_p' ...
    )

end