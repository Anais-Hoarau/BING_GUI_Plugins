function fixHeaders(pathToVarFile, scenario)
    %Opening the file and storing it as a line by line cell array
    disp('Loading lines...');
    file = fopen(pathToVarFile);
    lines = {};
    while ~feof(file)
        aLine = fgets(file);
        lines{end + 1} = aLine;
    end
    fclose(file);

    %Extracting header
    disp('Fixing headers...');
    switch(scenario)
        case('1')
            header = ';pas	temps	heureGMT	sec	nbVhs	dt	indEssai	numInstruction	vp: Route	vp: Voie (mm)	vp: Cap (deg)	vp: Sens	vp: Pk (mm)	vp: Vit (m/s)	vp: Regime (tr/min)	vp: Acc (m/s²)	vp: VitDepLat (m/s)	vp: Topo[x](mm)	vp: Topo[y](mm)	vp: Topo[z](mm)	vp: T.I.V. (s)	vp: T.T.C. (s)	vp: cab.volant	vp: cab.accél	vp: cab.frein	vp: cab.embrayage	vp: cab.BV	vp: cab.indics	vp: AccLatMDV (m/s²)	vp: CptKmTotal (mm)	-12: Route	-12: Voie (mm)	-12: Cap (deg)	-12: Sens	-12: Pk (mm)	-12: Vit (m/s)	-12: Topo[x](mm)	-12: Topo[y](mm)	-12: Topo[z](mm)	-1000: Route	-1000: Voie (mm)	-1000: Cap (deg)	-1000: Sens	-1000: Pk (mm)	-1000: Vit (m/s)	-1000: Topo[x](mm)	-1000: Topo[y](mm)	-1000: Topo[z](mm)	-1001: Route	-1001: Voie (mm)	-1001: Cap (deg)	-1001: Sens	-1001: Pk (mm)	-1001: Vit (m/s)	-1001: Topo[x](mm)	-1001: Topo[y](mm)	-1001: Topo[z](mm)			commentaires';
        case('2')
            header = ';pas	temps	heureGMT	sec	nbVhs	dt	indEssai	numInstruction	vp: Route	vp: Voie (mm)	vp: Cap (deg)	vp: Sens	vp: Pk (mm)	vp: Vit (m/s)	vp: Regime (tr/min)	vp: Acc (m/s²)	vp: VitDepLat (m/s)	vp: Topo[x](mm)	vp: Topo[y](mm)	vp: Topo[z](mm)	vp: T.I.V. (s)	vp: T.T.C. (s)	vp: cab.volant	vp: cab.accél	vp: cab.frein	vp: cab.embrayage	vp: cab.BV	vp: cab.indics	vp: AccLatMDV (m/s²)	vp: CptKmTotal (mm)	-12: Route	-12: Voie (mm)	-12: Cap (deg)	-12: Sens	-12: Pk (mm)	-12: Vit (m/s)	-12: Topo[x](mm)	-12: Topo[y](mm)	-12: Topo[z](mm)	-13: Route	-13: Voie (mm)	-13: Cap (deg)	-13: Sens	-13: Pk (mm)	-13: Vit (m/s)	-13: Topo[x](mm)	-13: Topo[y](mm)	-13: Topo[z](mm)	-14: Route	-14: Voie (mm)	-14: Cap (deg)	-14: Sens	-14: Pk (mm)	-14: Vit (m/s)	-14: Topo[x](mm)	-14: Topo[y](mm)	-14: Topo[z](mm)	-15: Route	-15: Voie (mm)	-15: Cap (deg)	-15: Sens	-15: Pk (mm)	-15: Vit (m/s)	-15: Topo[x](mm)	-15: Topo[y](mm)	-15: Topo[z](mm)			commentaires';
        case('5')
            header = ';pas	temps	heureGMT	sec	nbVhs	dt	indEssai	numInstruction	vp: Route	vp: Voie (mm)	vp: Cap (deg)	vp: Sens	vp: Pk (mm)	vp: Vit (m/s)	vp: Regime (tr/min)	vp: Acc (m/s²)	vp: VitDepLat (m/s)	vp: Topo[x](mm)	vp: Topo[y](mm)	vp: Topo[z](mm)	vp: T.I.V. (s)	vp: T.T.C. (s)	vp: cab.volant	vp: cab.accél	vp: cab.frein	vp: cab.embrayage	vp: cab.BV	vp: cab.indics	vp: AccLatMDV (m/s²)	vp: CptKmTotal (mm)	-12: Route	-12: Voie (mm)	-12: Cap (deg)	-12: Sens	-12: Pk (mm)	-12: Vit (m/s)	-12: Topo[x](mm)	-12: Topo[y](mm)	-12: Topo[z](mm)	-13: Route	-13: Voie (mm)	-13: Cap (deg)	-13: Sens	-13: Pk (mm)	-13: Vit (m/s)	-13: Topo[x](mm)	-13: Topo[y](mm)	-13: Topo[z](mm)	-14: Route	-14: Voie (mm)	-14: Cap (deg)	-14: Sens	-14: Pk (mm)	-14: Vit (m/s)	-14: Topo[x](mm)	-14: Topo[y](mm)	-14: Topo[z](mm)	-15: Route	-15: Voie (mm)	-15: Cap (deg)	-15: Sens	-15: Pk (mm)	-15: Vit (m/s)	-15: Topo[x](mm)	-15: Topo[y](mm)	-15: Topo[z](mm)			commentaires';
        case('6')
            header = ';pas	temps	heureGMT	sec	nbVhs	dt	indEssai	numInstruction	vp: Route	vp: Voie (mm)	vp: Cap (deg)	vp: Sens	vp: Pk (mm)	vp: Vit (m/s)	vp: Regime (tr/min)	vp: Acc (m/s²)	vp: VitDepLat (m/s)	vp: Topo[x](mm)	vp: Topo[y](mm)	vp: Topo[z](mm)	vp: T.I.V. (s)	vp: T.T.C. (s)	vp: cab.volant	vp: cab.accél	vp: cab.frein	vp: cab.embrayage	vp: cab.BV	vp: cab.indics	vp: AccLatMDV (m/s²)	vp: CptKmTotal (mm)	-13: Route	-13: Voie (mm)	-13: Cap (deg)	-13: Sens	-13: Pk (mm)	-13: Vit (m/s)	-13: Topo[x](mm)	-13: Topo[y](mm)	-13: Topo[z](mm)	-1000: Route	-1000: Voie (mm)	-1000: Cap (deg)	-1000: Sens	-1000: Pk (mm)	-1000: Vit (m/s)	-1000: Topo[x](mm)	-1000: Topo[y](mm)	-1000: Topo[z](mm)			commentaires';
        case('7')
            header = ';pas	temps	heureGMT	sec	nbVhs	dt	indEssai	numInstruction	vp: Route	vp: Voie (mm)	vp: Cap (deg)	vp: Sens	vp: Pk (mm)	vp: Vit (m/s)	vp: Regime (tr/min)	vp: Acc (m/s²)	vp: VitDepLat (m/s)	vp: Topo[x](mm)	vp: Topo[y](mm)	vp: Topo[z](mm)	vp: T.I.V. (s)	vp: T.T.C. (s)	vp: cab.volant	vp: cab.accél	vp: cab.frein	vp: cab.embrayage	vp: cab.BV	vp: cab.indics	vp: AccLatMDV (m/s²)	vp: CptKmTotal (mm)	-12: Route	-12: Voie (mm)	-12: Cap (deg)	-12: Sens	-12: Pk (mm)	-12: Vit (m/s)	-12: Topo[x](mm)	-12: Topo[y](mm)	-12: Topo[z](mm)	-13: Route	-13: Voie (mm)	-13: Cap (deg)	-13: Sens	-13: Pk (mm)	-13: Vit (m/s)	-13: Topo[x](mm)	-13: Topo[y](mm)	-13: Topo[z](mm)	-15: Route	-15: Voie (mm)	-15: Cap (deg)	-15: Sens	-15: Pk (mm)	-15: Vit (m/s)	-15: Topo[x](mm)	-15: Topo[y](mm)	-15: Topo[z](mm)			commentaires';
        case('8')
            header = ';pas	temps	heureGMT	sec	nbVhs	dt	indEssai	numInstruction	vp: Route	vp: Voie (mm)	vp: Cap (deg)	vp: Sens	vp: Pk (mm)	vp: Vit (m/s)	vp: Regime (tr/min)	vp: Acc (m/s²)	vp: VitDepLat (m/s)	vp: Topo[x](mm)	vp: Topo[y](mm)	vp: Topo[z](mm)	vp: T.I.V. (s)	vp: T.T.C. (s)	vp: cab.volant	vp: cab.accél	vp: cab.frein	vp: cab.embrayage	vp: cab.BV	vp: cab.indics	vp: AccLatMDV (m/s²)	vp: CptKmTotal (mm)	-12: Route	-12: Voie (mm)	-12: Cap (deg)	-12: Sens	-12: Pk (mm)	-12: Vit (m/s)	-12: Topo[x](mm)	-12: Topo[y](mm)	-12: Topo[z](mm)	-1000: Route	-1000: Voie (mm)	-1000: Cap (deg)	-1000: Sens	-1000: Pk (mm)	-1000: Vit (m/s)	-1000: Topo[x](mm)	-1000: Topo[y](mm)	-1000: Topo[z](mm)	-1001: Route	-1001: Voie (mm)	-1001: Cap (deg)	-1001: Sens	-1001: Pk (mm)	-1001: Vit (m/s)	-1001: Topo[x](mm)	-1001: Topo[y](mm)	-1001: Topo[z](mm)	P-1: position X (en m)	P-1: position Y (en m)	P-1: vitesse (en m/s)			commentaires';
        otherwise
            error('Scenario incorrect');
    end
    disp('Rewriting the file...');
    file = fopen(pathToVarFile, 'w');
    fprintf(file, '%s\n', header);
    for i = 2:1:length(lines)
        fprintf(file, '%s', lines{i});
    end
    fclose(file);
    disp('Done');
end

