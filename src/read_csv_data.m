function Weather_data = read_csv_data(filename)
% read_csv_data Import numeric data from a csv file.
%
% The CSV output contains a header with the following information:
% % Latitude [decimal degrees]
% Longitude [decimal degrees]
% Elevation [m]
% A list of years used for each month to construct the TMY. If the full time series is requested, this list will not be included in the output.
% After this follows the header line for the actual data. The consist of 1 year of hourly data, each hour on a separate line, with the following columns:
% 
% Date & time (UTC for normal CSV, local timezone time for the EPW format)
% T2m [°C] - Dry bulb (air) temperature.
% RH [%] -  Relative Humidity.
% G(h) [W/m2] - Global horizontal irradiance.
% Gb(n) [W/m2] - Direct (beam) irradiance.
% Gd(h) [W/m2] - Diffuse horizontal irradiance.
% IR(h) [W/m2] - Infrared radiation downwards.
% WS10m [m/s] - Windspeed.
% WD10m [°] - Wind direction.
% SP [Pa] - Surface (air) pressure.
%
% Example:
%   Weather_data = read_csv_data('data_Athens.csv');

%% Initialize variables.
delimiter = ',';
if nargin<=2
    %Since the fget1 is used for reading the first two lines, then a
    %startrow has to begin sooner than the actual line number in the csv
    %file.
    startRow = 16;
    endRow = 8775;
end

%% Open the text file.
fileID = fopen(filename,'r');
%% Read Latitude and Longitude
expression = '([-+]?\d+(\.\d+)?)';
%Read first 2 lines from file to extract Latitude and Longitude
line_1=string(fgetl(fileID));  % Read 1st line as a char
line_2=string(fgetl(fileID));  % Read 2nd line as a char
tokens = regexp(line_1, expression, 'tokens');
lat=str2double(tokens{1}{1});
tokens = regexp(line_2, expression, 'tokens');
long=str2double(tokens{1}{1});
%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
formatSpec = '%q%f%f%f%f%f%f%f%f%f%[^\n\r]';
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end
%% Close the text file.
fclose(fileID);
%% Allocate imported array to data structure
Weather_data.latitude=lat;
Weather_data.longitude=long;
Weather_data.timeUTC = dataArray{:, 1};
Weather_data.T2m = dataArray{:, 2};
Weather_data.RH = dataArray{:, 3};
Weather_data.Gh = dataArray{:, 4};
Weather_data.Gbn = dataArray{:, 5};
Weather_data.Gdh = dataArray{:, 6};
Weather_data.IRh = dataArray{:, 7};
Weather_data.WS10m = dataArray{:, 8};
Weather_data.WD10m = dataArray{:, 9};
Weather_data.SP = dataArray{:, 10};


