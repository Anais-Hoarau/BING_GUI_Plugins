function found_files = find_file_with_extension(path,extension)
    found_files = {};
    files = dir(path);
    for i = 1:length(files)
        if ~files(i).isdir
            [~, ~, ext] = fileparts(files(i).name);
            if strcmpi(ext,extension)
                found_files{end+1} = [path files(i).name];
            end
        end
    end
end