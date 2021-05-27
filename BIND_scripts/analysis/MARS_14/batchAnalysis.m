
tripDir = uigetdir(pwd, 'Selectionnez le dossier qui contient les .trip à enrichir (y compris dans des sous-dossiers');

prefixes = {'M1' 'M2' 'M3' 'M4'};
associatedPOIFiles = { 'POIM1.xls' 'POIM2.xls' 'POIM3.xls' 'POIM4.xls' };

for x=1:length(prefixes);
    tripPrefix = prefixes{x};
    toEnrichTrip = dirrec(tripDir, '.trip');
    toRemoveFromEnrichmentList = [];
    for i = 1:1:length(toEnrichTrip)
        [~, filename] = fileparts(toEnrichTrip{i});
        if ~strncmp(tripPrefix, filename, length(tripPrefix))
            toRemoveFromEnrichmentList(end + 1) = i;
        end
    end
    toEnrichTrip(toRemoveFromEnrichmentList) = [];
    
    for i = 1:length(toEnrichTrip)
       addPOI( toEnrichTrip{i},associatedPOIFiles{x} );
       enrichSections( toEnrichTrip{i} );
    end
end