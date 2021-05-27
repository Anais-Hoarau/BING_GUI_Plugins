function SyntaxChecker()%Todo : ajouter la possibilité de choisir le niveau du rapport. Voir aussi pour la complexité
    folderName = uigetdir(pwd, 'Dossier à vérifier');
    if isempty(folderName)
        return
    end
    errorOptions = {'Errors only', 'Errors and severe warnings', 'All errors and warnings'};
    [errorLevelItem,ok] = listdlg('ListString', errorOptions, 'SelectionMode', 'single', 'CancelString', 'Annuler');
    if ~ok
        return
    end;
    errorLevel = '';
    switch errorLevelItem
        case 1
            errorLevel = '-m2';
        case 2
            errorLevel = '-m1';
        case 3
            errorLevel = '-m0';
        otherwise
            error('Pas de correspondance trouvée entre l''item choisi et un niveau d''erreur');
    end
    progressBar = waitbar(0, 'Localisation des .m en cours...');
    mList = findAllMFiles(folderName);
    for i = 1:1:length(mList)
        [~, filename, ~] = fileparts(mList{i});
        waitbar(i/length(mList), progressBar, filename);
        errors = mlint(errorLevel, mList{i});
        if ~isempty(errors)
            disp(['### ' mList{i} ' ###']);
            for k = 1:1:length(errors)
                theError = errors(k);
                disp(['<a href="matlab: opentoline(''' mList{i} ''',' num2str(theError.line) ',' num2str(theError.column(1)) ')">L' num2str(theError.line) '(C' num2str(theError.column(1)) '-' num2str(theError.column(2)) ')' '</a> : ' theError.message]);
            end
        end
    end
    close(progressBar);
end

function out = findAllMFiles(path)
    out = {};
    listing = dir(path);
    for i = 1:1:length(listing)
        if listing(i).isdir
            if ~any(strcmp(listing(i).name, {'.' '..'}))
                out = [out{:} findAllMFiles([path filesep listing(i).name])];
            end
        else
           if regexp(listing(i).name, '.*\.m$', 'once')
              out{end + 1} = [path filesep listing(i).name];
           end
        end
    end         
end