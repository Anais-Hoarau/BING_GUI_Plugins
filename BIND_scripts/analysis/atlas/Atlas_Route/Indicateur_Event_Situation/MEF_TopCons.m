% Cette fonction mets en forme le signal TopCons et l'ajoute à la structure
% au trip ou à la structure

% Input : le trip et la structure
%
% Output : nope

function MEF_TopCons(trip,mat_file_path)


%% Traitement du trip

    metas = trip.getMetaInformations ;
    if metas.existData('Mopad_Synchrovideo') && ~metas.existDataVariable('Mopad_Synchrovideo','TopConsigne')
        
    %% Récupération du top de début de manip
    clap_start =str2double( trip.getAttribute('mopad_top_clap_start'));
    nom_sujet = trip.getAttribute('nomSujet');
    freqData = trip.getAttribute('frequenceData');
    
    %% Récupération du record 'Synchrovideo'
    record = trip.getAllDataOccurences('Mopad_Synchrovideo');
    timecode = cell2mat(record.getVariableValues('timecode'));
    TopCons = cell2mat(record.getVariableValues('TopCons'));
    
    N_tot = length(TopCons);
    
    %%
    
    timecode_short = timecode (timecode > clap_start);
    TopCons_short = TopCons (timecode > clap_start);

    baseline = mean( TopCons_short(freqData* 6 : freqData * 7)); % on récupère la baseline après les Tops entres les sécondes 6 et 7 ...

    N=length(TopCons_short);
    TopConsigne = zeros(1, N);
    
    
    %%  Filtrage du TopCons
    TopConsigne(TopCons_short>( 1.8 + baseline)) = 2; %topage Manette bouton noir -> situation Atlas Route
    TopConsigne(TopCons_short>(5.7+ baseline)) = 6; 
    TopConsigne(TopCons_short>(6.4 + baseline)) = 8; %topage Manette bouton 1 -> event 1 Atlas Route
    TopConsigne(TopCons_short> (8+ baseline)) = 10; %topage Manette bouton 1 -> event 2 Atlas Route
    TopConsigne = [ zeros(1,N_tot-N)  TopConsigne ];   % On remplie avec des zeros le début de TopConsigne pour que tous les vecteurs aient la même taille
    
    MetaVariable = fr.lescot.bind.data.MetaDataVariable;
    MetaVariable.setName('TopConsigne')
    MetaVariable.setType('REAL')
    MetaVariable.setUnit('Volt')
    trip.addDataVariable('Mopad_Synchrovideo',MetaVariable);
    
    N_inser=1;
    i=1;
    batch_size =10000;
    while N_inser < length(TopConsigne)        
        if N_inser+batch_size < length(TopConsigne)
            trip.setBatchOfTimeDataVariablePairs('Mopad_Synchrovideo','TopConsigne',[num2cell(timecode(N_inser:N_inser+batch_size)) ; num2cell(TopConsigne(N_inser:N_inser+batch_size))]);
            N_inser = N_inser + batch_size;
            disp(['Inserting TopConsigne : ' num2str(i*batch_size) ' lines / '  num2str(length(TopConsigne)) ' lines']);
        else
            trip.setBatchOfTimeDataVariablePairs('Mopad_Synchrovideo','TopConsigne',[num2cell(timecode(N_inser:end)) ; num2cell(TopConsigne(N_inser:end))]);
            break
        end       
        i=i+1;
    end
        
    figure;
    plot(timecode, TopCons, timecode, TopConsigne)
    legend('TopCons', 'TopConsigne')
    title(['TopConsigne - Données Trip : ' nom_sujet])
    hgsave(['TopCons_TopConsigne_' nom_sujet])
    close all
    
    else
        if ~metas.existData('Mopad_Synchrovideo')
            errordlg('The table ''mopad_Synchrovideo'' does not exist the current trip');
        end
    
    

    end
    
    clear TopCons TopConsigne TopCons_short timecode timecode_short clap_start freqData nom_sujet
    
    
    
    %% Traitement de la structure
    load(mat_file_path)
    
    %MOPAD
    participant_name = fieldnames(atlas);
    participant_name = participant_name{1};
    
    clap_start =atlas.(participant_name).mopad.META.mopad_top_clap_start;
    nom_sujet = fieldnames(atlas);
    nom_sujet = nom_sujet{1};
    
    if any(strcmp(fieldnames(atlas.(participant_name).mopad.Synchrovideo),'TopCons'))
         freq_struct_mopad = atlas.(participant_name).mopad.META.frequenceData;
         
         
             %% Récupération du top de début de manip
 
    %% Récupération du record 'Synchrovideo'
    timecode = atlas.(participant_name).mopad.Synchrovideo.time_sync.values;
    TopCons = atlas.(participant_name).mopad.Synchrovideo.TopCons.values ;
    
    N_tot = length(TopCons);
    
    %%
    
    %timecode_short = timecode (timecode > clap_start);
    TopCons_short = TopCons (timecode > clap_start);

    baseline = mean( TopCons_short(freq_struct_mopad * 6 : freq_struct_mopad * 7)); % on récupère la baseline après les Tops entres les sécondes 6 et 7 ...

    N=length(TopCons_short);
    TopConsigne = zeros(1, N);
    
    
    %%  Filtrage du TopCons
    TopConsigne(TopCons_short>( 1.9 + baseline)) = 2; %topage Manette bouton noir -> situation Atlas Route
    TopConsigne(TopCons_short>(5.7+ baseline)) = 6; 
    TopConsigne(TopCons_short>(7.5 + baseline)) = 8; %topage Manette bouton 1 -> event 1 Atlas Route
    TopConsigne(TopCons_short> (9.5+ baseline)) = 10; %topage Manette bouton 1 -> event 2 Atlas Route
    TopConsigne = [ zeros(1,N_tot-N)  TopConsigne ];
    
%     figure;
%     plot(timecode, TopCons, timecode, TopConsigne)
%     legend('TopCons', 'TopConsigne')
%     title(['TopConsigne - Données Strcut Atlas : ' nom_sujet])
    
    atlas.(participant_name).mopad.Synchrovideo.TopConsigne.values = TopConsigne';
    atlas.(participant_name).mopad.Synchrovideo.TopConsigne.unit = 'Volt';
    atlas.(participant_name).mopad.Synchrovideo.TopConsigne.comments = 'crée à partir du script MEF_TopCons ';
    
    end
    
    
    clear TopCons TopConsigne TopCons_short timecode timecode_short freqData
    try
    %MP150
    
    if any(strcmp(fieldnames(atlas.(participant_name).MP150.data),'TopCons'))
        
        freq_struct_MP150 = atlas.(participant_name).MP150.META.frequenceDATA;
        %% Récupération du record 'Synchrovideo'
        timecode = atlas.(participant_name).MP150.data.time_sync.values ;
        TopCons = atlas.(participant_name).MP150.data.TopCons.values;
        
        N_tot = length(TopCons);
        
        %%
        
        %timecode_short = timecode (timecode > clap_start);
        TopCons_short = TopCons (timecode > clap_start);
        
        baseline = mean( TopCons_short(freq_struct_MP150* 6 : freq_struct_MP150 * 7)); % on récupère la baseline après les Tops entres les sécondes 6 et 7 ...
        
        N=length(TopCons_short);
        TopConsigne = zeros(1, N);
        
        
        %%  Filtrage du TopCons
        TopConsigne(TopCons_short>( 0.8 + baseline) & TopCons_short < ( 7 + baseline)) = 2; %topage Manette bouton noir -> situation Atlas Route
        TopConsigne(TopCons_short>(2.8+ baseline) & TopCons_short < ( 7 + baseline)) = 6;
        TopConsigne(TopCons_short>(3.8 + baseline)& TopCons_short < ( 7 + baseline)) = 8; %topage Manette bouton 1 -> event 1 Atlas Route
        TopConsigne(TopCons_short> (5.5+ baseline)& TopCons_short < ( 7 + baseline)) = 10; %topage Manette bouton 1 -> event 2 Atlas Route
        TopConsigne = [ zeros(1,N_tot-N)  TopConsigne ];
        
%         figure;
%         plot(timecode, TopCons, timecode, TopConsigne)
%         legend('TopCons', 'TopConsigne')
%         title(['TopConsigne - Données Strcut MP150 : ' nom_sujet])
        
        atlas.(participant_name).MP150.data.Topconsigne.values = TopConsigne';
        atlas.(participant_name).MP150.data.Topconsigne.unit = 'Volt';
        atlas.(participant_name).MP150.data.Topconsigne.comments = 'crée à partir du script MEF_TopCons ';
            
    end
    catch
    end
    save(mat_file_path,'atlas');
   
end