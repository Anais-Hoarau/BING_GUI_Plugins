load('\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\01_20150911_110803_6672\01_20150911_110803_6672_MJPEG4K.mat')
%% Modify config struct
config.markerList = num2cell(char((1:16)' + 64));

%% Modify data and export struct
data.nMarkers = 16;
data.videoPathName = '\\vrlescot.ifsttar.fr\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\01_20150911_110803_6672\';
data.markerList = num2cell(char((1:16)' + 64));
export.markerNames = num2cell(char((1:16)' + 64));
data.xMeasured = zeros(750,16);
data.yMeasured = zeros(750,16);
export.X = zeros(750,16);
export.Y = zeros(750,16);

yMeasured = 0;
x_idx = 0;
y_idx = 1;

for y_pts = 1:73
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
    end
    x_idx = x_idx + 129;
    yMeasured = yMeasured + 30;
end

clearvars -except config data export
save('\\vrlescot\PROSPECT\CODAGE\DATA_CALIBRATION\TEST\WP5\01_20150911_110803_6672\01_20150911_110803_6672_MJPEG4K.mat')
clearvars