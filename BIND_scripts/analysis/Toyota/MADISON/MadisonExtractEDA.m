function MadisonExtractEDA()
    
    edaValues = cell2mat(dataRecord.getVariableValues('eda'));
    indexdebut=1;
    while (biopacTimecode(indexdebut)<temps_DEBUT)
        indexdebut = indexdebut+1;
    end
    temps_EDA = biopacTimecode (indexdebut:end);
    signal_EDA = edaValues (indexdebut:end);
    signal_temps_EDA = [temps_EDA ; signal_EDA'];
    nomSignal = ['EDA_P' num2str(i) '.csv'];
    save(nomSignal,'signal_temps_EDA', '-ascii')
    
    % Specifier dossier o� l'on va chercher les donn�es
    Ledalab('D:\hidalgo\Desktop\MADISON 2 Scripts 25042019\', 'open', 'text', 'downsample', 50, 'analyze', 'CDA', 'export_scrlist', [.01 3])
    
end