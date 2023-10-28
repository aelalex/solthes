function Weather_data = read_tmy2_data(filename)
%   Weather_data = read_tmy2_data(FILENAME)
%   Reads data from the tmy2 data file FILENAME
%   
%   Important detail: The header file is different in the US-based tmy2 files than in the
%   Europe-based tmy2 files.Therefore, a different treatment is required
%   for the header file. The rest of the data, the numerical ones, is the
%   same for both type of tmy2 file.
%
%   Example:
%   Weather_data = read_tmy2_data('US-NY-New-York-City-94728.tm2');
%
%    See also TEXTSCAN for details.

%% Open the text file.
fileID = fopen(filename,'r');
%% Format for header
%Header is different for US-locations and EU locations (based on
%meteoronorm) so different regex expressions.
eu_expression = '^\s*(\d+)\s*([A-Za-z/\.\- ]+)\s+(\d+)\s+([NSEW])\s+(\d+)\s+(\d+)\s+([NSEW])\s+(\d+)\s+(\d+)\s+(\d+)$';
us_expression='^\s*(\d+)\s+([A-Z_ ]+)\s+([A-Z]+)\s+(-?\d+)\s+([NSEW])\s+(\d+)\s+(\d+)\s+([NSEW])\s+(\d+)\s+(\d+)\s+(\d+)$';
%Read header from file
line_1=fgetl(fileID);  % Read 1st line as a char
line_str=string(line_1);
%
tokens = regexp(line_str, eu_expression, 'tokens');
%Test what TMY data file is, for Europe or USA
try
    %If the tokens is empty this means that the regex expresion must be for
    %US location
    element = tokens{1};

    %Check for an empty cell and handle it
    if isempty(element) || isempty(tokens)
        error('Not an EU TMY2 data file.');
    end
    %Latitude and longitude calcs for Europe
    Weather_data.SiteLatitude = (str2double(tokens{1,1}{1,5})+str2double(tokens{1,1}{1,6})./60)*(2.*strcmpi(tokens{1,1}{1,4},'N')-1);
    Weather_data.SiteLongitude = (str2double(tokens{1,1}{1,8})+str2double(tokens{1,1}{1,9})./60)*(2.*strcmpi(tokens{1,1}{1,7},'E')-1);
    Weather_data.SiteElevation = str2double(tokens{1,1}{1,10});
catch exception
    % Handle the error
    disp(['Not an EU TMY2 data file. An error occurred: ' exception.message]);
    %
    tokens = regexp(line_str, us_expression, 'tokens');
    %Latitude and longitude calcs for US are different since the header
    %contains extra information, the State of the site.
    Weather_data.SiteLatitude = (str2double(tokens{1,1}{1,6})+str2double(tokens{1,1}{1,7})./60)*(2.*strcmpi(tokens{1,1}{1,5},'N')-1);
    Weather_data.SiteLongitude = (str2double(tokens{1,1}{1,9})+str2double(tokens{1,1}{1,10})./60)*(2.*strcmpi(tokens{1,1}{1,8},'E')-1);
    Weather_data.SiteElevation = str2double(tokens{1,1}{1,10});
end
%% Read numerical data from file
data = textscan(fileID, '%2f%2f%2f%2f%4f%4f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s%1f%4f%1s%1f%2f%1s%1f%2f%1s%1s%4f%1s%1s%4f%1s%1f%3f%1s%1f%4f%1s%1f%3f%1s%1f%3f%1s%1f%4f%1s%1f%5f%1s%1f%10s%3f%1s%1f%3f%1s%1f%3f%1s%1f%2f%1s%1f',8760);
%% Close the text file.
fclose(fileID);
%% Store only the needed data from the tmy2 file and ingore the rest.
Weather_data.SiteID = tokens{1,1}{1,1};
Weather_data.StationName = strtrim(tokens{1,1}{1,2});
Weather_data.GHI=data{1,7};
Weather_data.DNI=data{1,10};
Weather_data.DHI=data{1,13};
Weather_data.Temp_drybulb=data{1,34};




