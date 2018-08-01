function filepaths = file2str(files)
    if iscellstr(files)
        filepaths = files;
    elseif ischar(files)
        filepaths = {files};
    else
        names = {files.name};
        paths = {files.folder};
        filepaths = strcat(paths(:), filesep, names(:));
    end
    if length(filepaths) == 1
        filepaths = char(filepaths);
    end
end

