function subFolderList = get_sub_folders(folderName)

% Get a list of all files and folders in this folder.
files = dir(folderName);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags);
% Aggregate
subFolderList = {};
for i = 1:length(subFolders)
    if ~strcmp(subFolders(i).name(1),'.')
        subFolderList{end+1} = strcat(subFolders(i).folder,'\',subFolders(i).name);
    end
end
subFolderList = subFolderList';