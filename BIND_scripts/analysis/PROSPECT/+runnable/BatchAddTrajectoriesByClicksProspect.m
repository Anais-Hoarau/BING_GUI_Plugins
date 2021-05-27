function BatchAddTrajectoriesByClicksProspect()
MAIN_FOLDER = '\\vrlescot.ifsttar.fr\PROSPECT\CODAGE';
fileName2Load = 'trip_input_list_all.mat';
load([MAIN_FOLDER filesep fileName2Load],'-mat');

for i_trip = 1:length(tripinputlist)
    folder_name = cell2mat(tripinputlist(i_trip,2));
    full_directory = [MAIN_FOLDER filesep 'TRIPSALL' filesep folder_name];
    trip_name = [folder_name '.trip'];
    video_name = [folder_name(1:20) '_MJPEG.avi'];
    trip_file = [full_directory filesep trip_name];
    video_file = [full_directory filesep video_name];
    
%     video_info = mmfileinfo(video_file);
%     for i_time=0:0.5:video_info.Duration-0.04
%         vidObj  = VideoReader(video_file,'CurrentTime',i_time);
%         imshow(readFrame(vidObj));
%     end
%     close();
%     clickObjectPoint = str2num(cell2mat(inputdlg('Entrez le nombre de zones à cliquer','nombre de zones à cliquer')));

    for i_click = 1:2 %clickObjectPoint
        clicArea_name = cell2mat(inputdlg('Entrez le nom sans espace de la zone à cliquer (ex : "car_1", "cycle_1", "pedestrian")','nom de la zone à cliquer'));
        
        vidObj  = VideoReader(video_file);
        trajectories = [];
        while hasFrame(vidObj)
            imshow(readFrame(vidObj),'InitialMagnification','fit');
            tc = vidObj.CurrentTime;
            try
                [x,y] = ginput();
            catch
                break
            end
            trajectories = [trajectories, [tc,x,y]];
        end
        save([trip_file(1:end-5) '_' clicArea_name], 'trajectories')
    end
end
end