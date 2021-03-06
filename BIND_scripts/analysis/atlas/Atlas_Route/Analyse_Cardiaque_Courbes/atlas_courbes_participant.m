%% Analyse des donn?es cardiaque
% Calcule des variations du rythme cardiaque et moyennage pas individu
function atlas_courbes_participant()
MAIN_FOLDER = 'Y:\PROJETS ACTUELS\ATLAS\Manip Route\DONNEES\MANIPS';
FIG_FOLDER = 'Y:\PROJETS ACTUELS\ATLAS\Manip Route\DONNEES\MANIPS\Figs';
EXCEL_FILE = 'Y:\PROJETS ACTUELS\ATLAS\Manip Route\DONNEES\MANIPS\atlas_hrv_data_participant.xlsx';

TRIPS_LIST = dirrec(MAIN_FOLDER, '.trip');

res = strfind(TRIPS_LIST ,'Copie');
TRIPS_LIST = TRIPS_LIST(cellfun(@isempty,res));

% Seuil de discrimination du HRV
RRdata.seuil_hrv = inf;

% Initialisation des variables
complete_verbale_data = [];
complete_visuospatiale_data = [];
data_verbale_aller = [];
data_visuospatiale_aller = [];
data_verbale_retour = [];
data_visuospatiale_retour = [];


RRdata.hrv_verbale.mean = nan(1,13);
RRdata.hrv_verbale.std = nan(1,13);
RRdata.hrv_verbale.N = nan;

RRdata.hrv_visuospatiale.mean = nan(1,13);
RRdata.hrv_visuospatiale.std = nan(1,13);
RRdata.hrv_visuospatiale.N = nan;

i_ligne = 1;


for i_trips = 1:1:length(TRIPS_LIST)
    
    % R?cup?ration des id et creation du trip
    [~,file]=fileparts(TRIPS_LIST{i_trips});
    participant_id = file(1:strfind(file,'_')-1);
    trajet = file(strfind(file,'_')+1:end);    
    disp(['Processing : ' TRIPS_LIST{i_trips}])
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(TRIPS_LIST{i_trips},0.04,false);
    
    Metas = trip.getMetaInformations();
    if Metas.existEvent('cardiac_RRintervals')
        %% R?cup?ration des donn?es 
        record = trip.getAllEventOccurences('cardiac_RRintervals');
        RRdata.timecode = record.getVariableValues('timecode');
        RRdata.type_tache = record.getVariableValues('type_tache');
        RRdata.first_pic_tc = record.getVariableValues('first_pic_tc');
        RRdata.RRintervals = record.getVariableValues('RRintervals');
        if isempty(RRdata.timecode)
            process = false;
        else
            process = true;
        end
        
        if process
            %% Calcul de la variation du rythme cardiaque
            RRdata.hrv_values = cell(1,length(RRdata.timecode));
            RRdata = compute_hrv(RRdata);
            
            %% Regroupement des donn?es par tache
                for i_essai = 1:1:length(RRdata.hrv_values)
                    if any(abs(RRdata.hrv_values{i_essai})>RRdata.seuil_hrv)
                        continue
                    end
                    if strcmp(RRdata.type_tache{i_essai},'verbale') && strcmp(trajet,'ALLER')
                        data_verbale_aller = [data_verbale_aller ; RRdata.hrv_values{i_essai}];
                    elseif strcmp(RRdata.type_tache{i_essai},'visuo spatiale') && strcmp(trajet,'ALLER')
                        data_visuospatiale_aller = [data_visuospatiale_aller ; RRdata.hrv_values{i_essai}];
                    elseif strcmp(RRdata.type_tache{i_essai},'verbale') && strcmp(trajet,'RETOUR')
                        data_verbale_retour = [data_verbale_retour ; RRdata.hrv_values{i_essai}];
                    elseif strcmp(RRdata.type_tache{i_essai},'visuo spatiale') && strcmp(trajet,'RETOUR')
                        data_visuospatiale_retour = [data_visuospatiale_retour ; RRdata.hrv_values{i_essai}];    
                    else
                        error('Cette situation n''est pas envisag?e')
                    end
                end
        end
    else
    end
    
    %% Log to excel file
    if strcmp(trajet,'RETOUR')
        if ~isempty(data_verbale_aller) || ~isempty(data_verbale_retour)
            complete_verbale_data = [data_verbale_aller ; data_verbale_retour];
            RRdata.hrv_verbale.mean = mean (complete_verbale_data);
            RRdata.hrv_verbale.std = std(complete_verbale_data);
            RRdata.hrv_verbale.N = size(complete_verbale_data,1);
        end
        if ~isempty(data_visuospatiale_aller) || ~isempty(data_visuospatiale_retour)
            complete_visuospatiale_data = [data_visuospatiale_aller ; data_visuospatiale_retour];
            RRdata.hrv_visuospatiale.mean = mean(complete_visuospatiale_data);
            RRdata.hrv_visuospatiale.std = std(complete_visuospatiale_data);
            RRdata.hrv_visuospatiale.N = size(complete_visuospatiale_data,1);
        end
        clear ligne_mean ligne_std
        ligne_mean = [participant_id num2cell([RRdata.hrv_verbale.mean RRdata.hrv_verbale.N RRdata.hrv_visuospatiale.mean RRdata.hrv_visuospatiale.N])];
        ligne_std = [participant_id num2cell([RRdata.hrv_verbale.std RRdata.hrv_verbale.N RRdata.hrv_visuospatiale.std RRdata.hrv_visuospatiale.N])];
        
        xlswrite(EXCEL_FILE, ligne_mean,'mean',xls_range(1,i_ligne,size(ligne_mean,2),size(ligne_mean,1)))
        xlswrite(EXCEL_FILE, ligne_std,'std',xls_range(1,i_ligne,size(ligne_std,2),size(ligne_std,1)))
        i_ligne = i_ligne + size(ligne_std,1);
        
        %% Reinitialisation des variables
        complete_verbale_data = [];
        complete_visuospatiale_data = [];
        data_verbale_aller = [];
        data_visuospatiale_aller = [];
        data_verbale_retour = [];
        data_visuospatiale_retour = [];
        
        RRdata.hrv_verbale.mean = nan(1,13);
        RRdata.hrv_verbale.std = nan(1,13);
        RRdata.hrv_verbale.N = nan;
        
        RRdata.hrv_visuospatiale.mean = nan(1,13);
        RRdata.hrv_visuospatiale.std = nan(1,13);
        RRdata.hrv_visuospatiale.N = nan;
    end
    
    %% Delete Trip
    delete(trip)
end

%% Calcul des moyennes et des ?carts type par groupe et par sous groupes
%RRdata = compute_stats(RRdata);

%% Visualisation
%data_visualization(RRdata, false, true, FIG_FOLDER)
end


%% Calcul de la variation du rythme cadiaque
function  [RRdata_out] = compute_hrv(RRdata)
    RRdata_out = RRdata;
    for id_event = 1:1:length(RRdata_out.timecode)
        event_timecode = RRdata_out.timecode{id_event};

        RRintervalles = str2num(RRdata_out.RRintervals{id_event});%#ok
        N_pics = length(RRintervalles)+1;

        pics_timecodes = zeros(1,N_pics);
        pics_timecodes(1) = RRdata_out.first_pic_tc{id_event};

        for i_pic = 1:1:N_pics-1
            pics_timecodes(i_pic+1) = pics_timecodes(i_pic) + RRintervalles(i_pic)/1000;
        end

        % Update hr interpolation value : interpolation des intervalles RR ? 10Hz
        data_hr.timecode = pics_timecodes(1:end-1) + diff(pics_timecodes)/2;
        data_hr.value = 60./(RRintervalles/1000);

        data_hr.timecode_interp = pics_timecodes(1):1/10:pics_timecodes(end);
        data_hr.value_interp = interp1(data_hr.timecode, data_hr.value, data_hr.timecode_interp, 'spline');

        hrv.timecode = (-0.5:0.5:5.5) + 0.25;
        mask_hrv = (data_hr.timecode_interp < event_timecode + 6) & (data_hr.timecode_interp > event_timecode - 0.5);
        interp_heartRate_section = data_hr.value_interp(mask_hrv);
        hrv.values = mean(reshape(interp_heartRate_section, 5, []));

        hrv.values = hrv.values - hrv.values(1);

        RRdata_out.hrv_values{id_event} = hrv.values;
    end
end

%% Calcul des moyennes et ecart type : par groupe et sous-groupe
function [RRdata_out] = compute_stats(RRdata)
RRdata_out = RRdata;
%%Par sous groupe
% verbale, flow +
RRdata_out.hrv_verbale_plus.mean = mean(RRdata_out.hrv_verbale_plus.data);
RRdata_out.hrv_verbale_plus.std = std(RRdata_out.hrv_verbale_plus.data);
RRdata_out.hrv_verbale_plus.N = size(RRdata_out.hrv_verbale_plus.data,1);
% verbale, flow -
RRdata_out.hrv_verbale_moins.mean = mean(RRdata_out.hrv_verbale_moins.data);
RRdata_out.hrv_verbale_moins.std = std(RRdata_out.hrv_verbale_moins.data);
RRdata_out.hrv_verbale_moins.N = size(RRdata_out.hrv_verbale_moins.data,1);
% visuo spatiale, flow +
RRdata_out.hrv_visuospatiale_plus.mean = mean(RRdata_out.hrv_visuospatiale_plus.data);
RRdata_out.hrv_visuospatiale_plus.std = std(RRdata_out.hrv_visuospatiale_plus.data);
RRdata_out.hrv_visuospatiale_plus.N = size(RRdata_out.hrv_visuospatiale_plus.data,1);
% visuo spatiale, flow - 
RRdata_out.hrv_visuospatiale_moins.mean = mean(RRdata_out.hrv_visuospatiale_moins.data);
RRdata_out.hrv_visuospatiale_moins.std = std(RRdata_out.hrv_visuospatiale_moins.data);
RRdata_out.hrv_visuospatiale_moins.N = size(RRdata_out.hrv_visuospatiale_moins.data,1);

%% Regroupement par groupe: par tache et par flow
% verbale
RRdata_out.hrv_verbale.data = [RRdata_out.hrv_verbale_plus.data ; RRdata_out.hrv_verbale_moins.data];
RRdata_out.hrv_verbale.N = size(RRdata_out.hrv_verbale.data,1);
RRdata_out.hrv_verbale.mean  = mean(RRdata_out.hrv_verbale.data);
RRdata_out.hrv_verbale.std  = std(RRdata_out.hrv_verbale.data);
% visuo spatiale
RRdata_out.hrv_visuospatiale.data = [RRdata_out.hrv_visuospatiale_plus.data ; RRdata_out.hrv_visuospatiale_moins.data];
RRdata_out.hrv_visuospatiale.N = size(RRdata_out.hrv_visuospatiale.data,1);
RRdata_out.hrv_visuospatiale.mean  = mean(RRdata_out.hrv_visuospatiale.data);
RRdata_out.hrv_visuospatiale.std  = std(RRdata_out.hrv_visuospatiale.data);
% flow +
RRdata_out.hrv_flow_plus.data = [RRdata_out.hrv_verbale_plus.data ; RRdata_out.hrv_visuospatiale_plus.data];
RRdata_out.hrv_flow_plus.N = size(RRdata_out.hrv_flow_plus.data,1);
RRdata_out.hrv_flow_plus.mean  = mean(RRdata_out.hrv_flow_plus.data);
RRdata_out.hrv_flow_plus.std  = std(RRdata_out.hrv_flow_plus.data);
%flow -
RRdata_out.hrv_flow_moins.data = [RRdata_out.hrv_verbale_moins.data ; RRdata_out.hrv_visuospatiale_moins.data];
RRdata_out.hrv_flow_moins.N = size(RRdata_out.hrv_flow_moins.data,1);
RRdata_out.hrv_flow_moins.mean  = mean(RRdata_out.hrv_flow_moins.data);
RRdata_out.hrv_flow_moins.std  = std(RRdata_out.hrv_flow_moins.data);
end

%% Visualisation
function data_visualization(RRdata, bool_plot, bool_save, FIG_FOLDER)
    if ~bool_plot
        return
    end
    close all
    hrv_time = -0.25:0.5:5.75;
    
    % Verbale vs Visuo spatiale
    h1 = figure;    
    h_a1 = axes;
    title(['Verbale vs. Visuo-spatiale. Seuil = ' num2str(RRdata.seuil_hrv)])
    hold on
    errorbar(hrv_time, RRdata.hrv_verbale.mean ,RRdata.hrv_verbale.std/sqrt(RRdata.hrv_verbale.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'r', 'Color', 'r' )
    errorbar(hrv_time, RRdata.hrv_visuospatiale.mean ,RRdata.hrv_visuospatiale.std/sqrt(RRdata.hrv_visuospatiale.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'b' , 'Color', 'b')
    xlabel('Temps (s)')
    ylabel('Variation du rythme cardiaque (bpm)')
    legend(['verbale. n = ' num2str(RRdata.hrv_verbale.N)],['visuo-spatiale. n = ' num2str(RRdata.hrv_visuospatiale.N)])
    plot_vertical_lines(h_a1)
    hold off
    
    % Verbale vs Visuo spatiale
    h2 = figure;    
    h_a2 = axes;
    title(['Flow + vs. Flow -. Seuil = ' num2str(RRdata.seuil_hrv)])
    hold on
    errorbar(hrv_time, RRdata.hrv_flow_plus.mean ,RRdata.hrv_flow_plus.std/sqrt(RRdata.hrv_flow_plus.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'r', 'Color', 'r' )
    errorbar(hrv_time, RRdata.hrv_flow_moins.mean ,RRdata.hrv_flow_moins.std/sqrt(RRdata.hrv_flow_moins.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'b' , 'Color', 'b')
    xlabel('Temps (s)')
    ylabel('Variation du rythme cardiaque (bpm)')
    legend(['Flow +. n = ' num2str(RRdata.hrv_flow_plus.N)],['Flow -. n = ' num2str(RRdata.hrv_flow_moins.N)])
    plot_vertical_lines(h_a2)
    hold off
    
    % Verbale: Flow + vs Flow - 
    h3 = figure;    
    h_a3 = axes;
    title(['Verbale : Flow + vs Flow -. Seuil = ' num2str(RRdata.seuil_hrv)])
    hold on
    errorbar(hrv_time, RRdata.hrv_verbale_plus.mean ,RRdata.hrv_verbale_plus.std/sqrt(RRdata.hrv_verbale_plus.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'r', 'Color', 'r' )
    errorbar(hrv_time, RRdata.hrv_verbale_moins.mean ,RRdata.hrv_verbale_moins.std/sqrt(RRdata.hrv_verbale_moins.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'b' , 'Color', 'b')
    
    xlabel('Temps (s)')
    ylabel('Variation du rythme cardiaque (bpm)')
    legend(['Verbale : Flow +. n = ' num2str(RRdata.hrv_verbale_plus.N)], ...
           ['Verbale : Flow -. n = ' num2str(RRdata.hrv_verbale_moins.N)])
    plot_vertical_lines(h_a3)
    hold off
    
    % Visuo-spatiale: Flow + vs. Flow -
    h4 = figure;    
    h_a4 = axes;
    title(['Visuo-spatiale : Flow + vs Flow -. Seuil = ' num2str(RRdata.seuil_hrv)])
    hold on
    errorbar(hrv_time, RRdata.hrv_visuospatiale_plus.mean ,RRdata.hrv_visuospatiale_plus.std/sqrt(RRdata.hrv_visuospatiale_plus.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'r', 'Color', 'r' )
    errorbar(hrv_time, RRdata.hrv_visuospatiale_moins.mean ,RRdata.hrv_visuospatiale_moins.std/sqrt(RRdata.hrv_visuospatiale_moins.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'b' , 'Color', 'b')
    
    xlabel('Temps (s)')
    ylabel('Variation du rythme cardiaque (bpm)')
    legend(['Visuo-spatiale : Flow +. n = ' num2str(RRdata.hrv_visuospatiale_plus.N)], ...
           ['Visuo-spatiale : Flow -. n = ' num2str(RRdata.hrv_visuospatiale_moins.N)])
    plot_vertical_lines(h_a4)
    hold off
    
    % Flow + : verbale vs visuo-spatiale
    h5 = figure;    
    h_a5 = axes;
    title(['Flow + : Verbale vs. Visuo-spatiale. Seuil = ' num2str(RRdata.seuil_hrv)])
    hold on
    errorbar(hrv_time, RRdata.hrv_verbale_plus.mean ,RRdata.hrv_verbale_plus.std/sqrt(RRdata.hrv_verbale_plus.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'r', 'Color', 'r' )
    errorbar(hrv_time, RRdata.hrv_visuospatiale_plus.mean ,RRdata.hrv_visuospatiale_plus.std/sqrt(RRdata.hrv_visuospatiale_plus.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'b' , 'Color', 'b')
    
    xlabel('Temps (s)')
    ylabel('Variation du rythme cardiaque (bpm)')
    legend(['Flow + : verbale. n = ' num2str(RRdata.hrv_verbale_plus.N)], ...
           ['Flow + : visuo-spatiale. n = ' num2str(RRdata.hrv_visuospatiale_plus.N)])
    plot_vertical_lines(h_a5)
    hold off
    
    % Flow - : verbale vs visuo-spatiale
    h6 = figure;    
    h_a6 = axes;
    title(['Flow - : Verbale vs. Visuo-spatiale. Seuil = ' num2str(RRdata.seuil_hrv)])
    hold on
    errorbar(hrv_time, RRdata.hrv_verbale_moins.mean ,RRdata.hrv_verbale_moins.std/sqrt(RRdata.hrv_verbale_moins.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'r', 'Color', 'r' )
    errorbar(hrv_time, RRdata.hrv_visuospatiale_moins.mean ,RRdata.hrv_visuospatiale_moins.std/sqrt(RRdata.hrv_visuospatiale_moins.N), ...
        'LineStyle', 'None', 'Marker', 's', 'MarkerFaceColor', 'b' , 'Color', 'b')
    
    xlabel('Temps (s)')
    ylabel('Variation du rythme cardiaque (bpm)')
    legend(['Flow - : verbale. n = ' num2str(RRdata.hrv_verbale_moins.N)], ...
           ['Flow - : visuo-spatiale. n = ' num2str(RRdata.hrv_visuospatiale_moins.N)])
    plot_vertical_lines(h_a6)
    hold off
    
    if bool_save
        for i=1:1:6
        h = eval(['h' num2str(i)]);   
        hgsave(h,[FIG_FOLDER '\figure_' num2str(i) '.fig'])
        print(h, [FIG_FOLDER '\figure_' num2str(i) '.jpeg'],'-djpeg','-r800')
        delete(h)
        end            
    end
    
end

%% 
function plot_vertical_lines(axe_handle)
times =(-0.5:0.5:6);
axe_pos = axis(axe_handle);
for i_line = 1:1:length(times)
    plot([times(i_line) times(i_line)], [axe_pos(3) axe_pos(4)], 'k--', 'LineWidth', 1)
end
axis(axe_handle,[-0.5 6 axe_pos(3) axe_pos(4)])
end