function [data] = read_cpd(filename, title)
    % Format string for each line of text:
    %formatSpec = '%f%f%f%f%f%f%f%f%f%[^\n\r]';
    formatSpec = '%f%f%f';
    
    % Open the text file.
    fileID = fopen(filename,'r');

    %% filename
    [directory, name, ext] = fileparts(filename);
    data.filename = [name ext];
    data.directory = directory;
    
    %% title
    if nargin >= 2
        data.title = title;
    end
    
    %% Read columns of data according to format string.
    frewind(fileID);
    dataArray = textscan(fileID, formatSpec, Inf, 'ReturnOnError', false);

    %% Close the text file.
    fclose(fileID);

    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    %% Allocate imported array to column variable names
    
    data.f = dataArray{:, 1};
    data.Cp = dataArray{:, 2};
    data.D = dataArray{:, 3};
end