function data = read_sac(filename, title)
    
    % Open the *.sac file
    fid = fopen(filename);

    % Get information about *sac file
    %[filename, permission, machineformat, encoding] = fopen(fid) ;

    %% Parameters to search in the sac file
    % using fseek and fread

    % Number of cycles 
    fseek(fid, 100, 'bof') ;
    NbCycle = double(fread(fid, 1, '*uint16')) ;
    Cycle_list = 1 : NbCycle ;

    % Scan Width
    fseek(fid, 345, 'bof') ;
    Scan_Width = double(fread(fid, 1, '*uint16')) ;

    % Number of measurements for each mass 
    fseek(fid, 347, 'bof') ;
    Steps = double(fread(fid, 1, '*uint16')) ;

    % Number of data points for each cycle 
    fseek(fid, 386, 'bof') ;
    NbPts = double(fread(fid, 1, '*uint16')) ;

    % First mass u
    fseek(fid, 341, 'bof') ;
    First_u = double(fread(fid, 1, '*float')) ;

    % First mass exported
    fseek(fid, 348, 'bof') ;
    u_start = double(fread(fid, 1, '*float')) ;

    % Last mass exported
    fseek(fid, 352, 'bof') ;
    u_end = double(fread(fid, 1, '*float')) ;

    % Unit of the intensity I
    fseek(fid, 234, 'bof') ;
    Units_I = fread(fid, 1, '*char') ;

    % Unit of the mass u
    fseek(fid, 263, 'bof') ;
    Units_u = fread(fid, 1, '*char') ;

    % UTC time when storage starts
    fseek(fid, 194, 'bof') ;
    UTC = fread(fid, 1, 'ulong') ;

    % UTC time conversion (Elapsed time in seconds from January 1st 1970) to
    % date format (ex. 26-Feb-2013 09:49:25)).
    Start_time = datestr(datenum([1970, 1, 1, 0, 0, UTC])) ;

    %% "Real" number of data point for each cycle
    Cal_NbPts = Scan_Width * Steps ;

    %% Construction of the uma 
    mass_u = zeros(NbPts + 33, 1) ;

    mass_u(1) = First_u ;
    for i =  2 : (NbPts + 33) 
       mass_u(i,1) = mass_u(i-1,1) + (1 / Steps) ;
    end

    %% Creation of the matrix of cycles 
    % Time of each cycle
    fseek(fid, 0, 'bof') ;

    time_cycle_all = fread(fid, 'ulong') ;
    n = size(time_cycle_all, 1) ;

    j = 0 ;
    time_cycle = zeros(1, NbCycle) ;

    for i = 96 : (Cal_NbPts + 3) : n 
       j = j + 1 ;
       time_cycle(j) = time_cycle_all(i) ;
    end

    % Data for each cycle
    fseek(fid, 0, 'bof') ;
    data_cycle_all = fread(fid, '*float') ;

    % Offset to reach the heading of first cycle
    dec = 96 ;
    l = 0 ;

    data_cycle = zeros(NbPts + 33, NbCycle) ; 

    for k = 1 : 1 : NbCycle
        for i = 1 : (Cal_NbPts)
            data_cycle(i,k) = data_cycle_all(dec + i + 2 + l) ;
        end
        l = l + 3 + Cal_NbPts ;
    end

    fclose(fid);
    
    data = struct;
    data.mass_u = mass_u;
    data.intensity = data_cycle;
    
    %% title
    if nargin >= 2
        data.title = title;
    end

    % 2D plot : I = f(u) for all cycle
    % figure(1)
    % plot(u, data_cycle) ;
    % xlabel('Mass (u)') ;
    % ylabel('Intensity (A)') ;
    % title('I = f(u)')
    
    % 3D plot : I = f(u) vs time cycle
    % X = repmat(mass_u, 1, NbCycle) ;
    % Y1 = repmat(time_cycle, size(mass_u,1) , 1) ;
    % Y2 = repmat(Cycle_list, size(mass_u,1) , 1) ;
    
    %figure(2)
    %plot3(X, Y1, data_cycle) ;
    %xlabel('Mass (u)') ;
    %ylabel('Time cycle (s)');
    %zlabel('Intensity (A)') ;
    %title('I = f(u) vs Time Cycle')

    %figure(3)
    %plot3(X, Y2, data_cycle) ;
    %xlabel('Mass (u)') ;
    %ylabel('Cycle');
    %zlabel('Intensity (A)') ;
    %title('I = f(u) vs Cycle')

end