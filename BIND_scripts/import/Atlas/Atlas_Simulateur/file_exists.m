function exists = file_exists(file_path)
    if exist(file_path) == 2
        exists = true;
    else
        exists = false;
    end
end