% Projet ATLAS : Analyse donn�es cardiaques - R�ponse cardiaque �voqu�e

% -------------------------------------------------------------------------

% Phases :
% 1 - codage de la charge mentale, de l'exploitabilit� du cardiaque, du
% type de double tache
% 2 - traitement des section pertinent: D�tection des pics sur les ondes
% qrs, d�termination de intervalles R-R
% 3 - Confirmation visuelle et �limnation des fausses d�tections
% 4 - Aggr�mation des donn�es par sujet (aller et retour)
% 5 - Analyse statistique

% -------------------------------------------------------------------------


% Phase 2 :
% Traitement des trips en utilisant les scripts ECGlab
function atlas_cardiaque_RRintervalsdetection()

global samplerate_ecg 
samplerate_ecg = 1000; %Hz
%%
% FOLDER = 'E:\PROJETS ACTUELS\ATLAS\Manip Route\DONNEES\MANIPS';
% 
% TRIPS_LIST = dirrec(FOLDER, '.trip');
% res = strfind(TRIPS_LIST ,'Copie');
% TRIPS_LIST = TRIPS_LIST(cellfun(@isempty,res));

TRIPS_LIST ={'E:\PROJETS ACTUELS\ATLAS\Manip Route\DONNEES\MANIPS\S006\RETOUR\s006_RETOUR.trip'};

for i_trip=1:1:length(TRIPS_LIST)
    trip_file = TRIPS_LIST{i_trip};
    disp(['Processing trip : ' trip_file])
    
    trip = fr.lescot.bind.kernel.implementation.SQLiteTrip(trip_file, 0.04, true);
    Metas = trip.getMetaInformations();
    
    % test si le trip a d�j� �t� traitement et si les donn�es cardiaques existent
%     AttributesList = Metas.getTripAttributesList;
%     if any(strcmp(AttributesList,'RRdetection'))
%         if logical(str2double(trip.getAttribute('RRdetection')))
%             display('This trip has already been processed ... moving to next trip')
%             continue
%         end
%     end

    if Metas.existEvent('cardiac_RRintervals')
        trip.removeEvent('cardiac_RRintervals')
    end

    if ~Metas.existData('MP150_data')
        continue
    end
    
    %% R�cup�ration des Events � traiter dans les tables
    TopageA_ok = Metas.existEventVariable('Topage_A','type') & ...
        Metas.existEventVariable('Topage_A','cardiaque_exploitable') & ...
        Metas.existEventVariable('Topage_A','charge_mentale');
    
    TopageB_ok = Metas.existEventVariable('Topage_B','type') & ...
        Metas.existEventVariable('Topage_B','cardiaque_exploitable') & ...
        Metas.existEventVariable('Topage_B','charge_mentale');
    
    MW_ok = Metas.existEventVariable('MindWandering','type') & ...
        Metas.existEventVariable('MindWandering','cardiaque_exploitable') & ...
        Metas.existEventVariable('MindWandering','charge_mentale');
    
    EventTablesList = {'Topage_A','Topage_B','MindWandering'};
    DoubleTaskList = {'visuo spatiale','verbale'};
    
    Event2ProcessList.timecode =[];
    Event2ProcessList.pics_position =[];
    if TopageA_ok && TopageB_ok && MW_ok       
        i_Events2Process =1;
        for i_EventTable = 1:1:length(EventTablesList)
            currentTable = EventTablesList{i_EventTable};
            record = trip.getAllEventOccurences(currentTable);
            EventDataArray = record.buildCellArrayWithVariables({'timecode','type','cardiaque_exploitable','charge_mentale'});
            for i_list=1:1:size(EventDataArray,2)
                if (EventDataArray{2,i_list}== 2 || EventDataArray{2,i_list}== 3) && EventDataArray{3,i_list}== 1 && EventDataArray{4,i_list}== 1
                    Event2ProcessList.timecode(i_Events2Process) = EventDataArray{1,i_list};
                    Event2ProcessList.table{i_Events2Process} = currentTable;
                    Event2ProcessList.type{i_Events2Process} = DoubleTaskList{EventDataArray{2,i_list}-1};               
                    i_Events2Process = i_Events2Process + 1;
                end
            end
        end
    end
    
    %% R�cup�ration des donn�es cardiaques correspondant au Events et calcul des intervalles R-R
    if ~(isempty(Event2ProcessList.timecode) && isempty(Event2ProcessList.pics_position))
        for i_Events2Process=1:1:size(Event2ProcessList.timecode,2)
            EventTime = Event2ProcessList.timecode(i_Events2Process);
            partial_record = trip.getDataVariableOccurencesInTimeInterval('MP150_data','Cardiaque_filtre', EventTime-0.5-5, EventTime+6+5);% on prend les 5 sec autours pour limiter les effets de bords
            
            % recup�ration des donn�es correspondant � l'Event
            timecode = cell2mat(partial_record.getVariableValues('timecode'));
            cardiac = cell2mat(partial_record.getVariableValues('Cardiaque_filtre'));
            
            % calcul des intervalles RR
            id_pics = ecglabRR_detecta_ondar(cardiac,2);
            pics_tc = timecode(id_pics);
            Event2ProcessList.pics_position{i_Events2Process} = pics_tc;
            Event2ProcessList.first_pic_tc(i_Events2Process) = pics_tc(1);
            interRR = round(1000*diff(timecode(id_pics))); % in milliseconds
            Event2ProcessList.RRintervals{i_Events2Process} = interRR;
            
        end
        

        
        %% Remplissage du trip : creation d'une table d'Event
        %%  Creation de la table d'event
        if ~(trip.getMetaInformations().existEvent('cardiac_RRintervals'))
            newMetaEvent = fr.lescot.bind.data.MetaEvent;
            newMetaEvent.setName('cardiac_RRintervals');
            Names = {'type_tache','first_pic_tc','RRintervals'};
            Types = {'TEXT', 'REAL', 'TEXT'};
            
            var = cell(1,length(Names));
            for i=1:1:length(Names)
                var{i} = fr.lescot.bind.data.MetaEventVariable();
                var{i}.setName(Names{i});
                var{i}.setType(Types{i});
            end
            
            % set the metaSituationVariables in the metaSituation
            newMetaEvent.setVariables(var);
            
            % add the metaSituation to the trip
            trip.addEvent(newMetaEvent);
            trip.setIsBaseEvent('cardiac_RRintervals',false)
        end
        
        %% Remplissage de la table
        if ~isempty(Event2ProcessList.pics_position)
            
            Variables_Pairs = cell(2,length(Event2ProcessList.pics_position));
            Variables_Pairs(1,:) = num2cell(Event2ProcessList.timecode);
            
            Variables_Pairs(2,:) = Event2ProcessList.type;
            trip.setBatchOfTimeEventVariablePairs('cardiac_RRintervals','type_tache',Variables_Pairs)
            
            Variables_Pairs(2,:) = num2cell(Event2ProcessList.first_pic_tc);
            trip.setBatchOfTimeEventVariablePairs('cardiac_RRintervals','first_pic_tc',Variables_Pairs)
            
            % Mise en forme des RR intervals
            Variables_Pairs(2,:) = cellfun(@array2str, Event2ProcessList.RRintervals, 'UniformOutput', false);
            trip.setBatchOfTimeEventVariablePairs('cardiac_RRintervals','RRintervals',Variables_Pairs)
        end
    end
    
    clear Event2ProcessList Variables_Pairs
    trip.setAttribute('RRdetection','1')
    delete(trip)
end
end
function [str]=array2str(array)
    str = '';
    if isempty(array)
        return; 
    else
        if size(array,1)>1
            array = array';
        end
        str = mat2str(array);
        if length(array)>1
            str = str(2:end-1);
        end
    end
end