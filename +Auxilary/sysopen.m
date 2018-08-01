function sysopen(file, args)
    file = Auxilary.file2str(file);
    
    if ispc && nargin >= 2
        if ischar(args) && strcmpi(args, 'notepad++')
            try_notepad(file);
            return;
        end
    end
    
    try
        if ispc
            winopen(file);
        elseif ismac
            system(sprintf('open "%s"', file));
        elseif isnunix
            system(sprintf('xdg-open "%s"', file));
        end
    catch 
        if ~ispc || ~try_notepad(file)
            [~, filename, ext] = fileparts(file);
            string = 'Could not find an appropriate application to open';
            string = sprintf('% file %.% ', string, filename, ext);
            warndlg(string);
        end
    end
end


function success = try_notepad(file)
    places = {'%ProgramFiles%', '%ProgramFiles(x86)%', '%AppData%'};
    
    for place = each(places)
        exefile = fullfile(place, 'Notepad++\notepad++.exe');
        dircmd = sprintf('dir "%s"', exefile);
        [nope, ~] = system(dircmd);
        
        if ~nope
            opencmd = sprintf('"%s" "%s" & \nexit', exefile, file);
            [fail, ~] = system(opencmd);
            success = ~fail;
            if success
                return;
            end
        end
    end
    
    opencmd = sprintf('notepad "%s" \nexit', file);
    [fail, ~] = system(opencmd);
    success = ~fail;
end