load('\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\02_20150911_110803_6672\02_20150911_110803_6672_MJPEG4K.mat')
nb_markers = 2;
video_duration = 30;

%% Modify config struct
config.markerList = num2cell(char((1:nb_markers)' + 64));

%% Modify data and export struct
data.nMarkers = nb_markers;
data.videoPathName = '\\vrlescot.ifsttar.fr\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\02_20150911_110803_6672\';
data.markerList = num2cell(char((1:nb_markers)' + 64));
export.markerNames = num2cell(char((1:nb_markers)' + 64));
data.timecodes = 0:0.04:video_duration;
data.xMeasured = zeros(750,nb_markers);
data.yMeasured = zeros(750,nb_markers);
export.X = zeros(750,nb_markers);
export.Y = zeros(750,nb_markers);

yMeasured_C2 = 2160 - 1639;
yMeasured_C1 = 2160 - 1128;
x_idx = 0;
y_idx = 1;

yMeasured = yMeasured_C2;
y_traj_shift = 0.66;
for y_pts = 1:2
    xMeasured = 0;
    for x_pts = 1:129
        if x_idx > 4*129
            x_idx = 0;
            y_idx = y_idx + 1;
        end
        data.xMeasured(x_idx + x_pts, y_idx) = xMeasured;
        data.yMeasured(x_idx + x_pts, y_idx) = yMeasured;
        export.X(x_idx + x_pts, y_idx) = xMeasured;
        export.Y(x_idx + x_pts, y_idx) = yMeasured;
        xMeasured = xMeasured + 30;
        yMeasured = yMeasured + y_traj_shift;
    end
    x_idx = x_idx + 129;
    yMeasured = yMeasured_C1;
    y_traj_shift = 0.1318;
%     yMeasured = yMeasured + 30;
end

clearvars -except config data export
save('\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\02_20150911_110803_6672\02_20150911_110803_6672_MJPEG4K.mat')
clearvars