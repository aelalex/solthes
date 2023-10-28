function [timeUTC,T2m,RH,Gh,Gbn,Gdh,IRh,WS10m,WD10m,SP] = importfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [TIMEUTC,T2M,RH,GH,GBN,GDH,IRH,WS10M,WD10M,SP] = IMPORTFILE(FILENAME)
%   Reads data from text file FILENAME for the default selection.
%
%   [TIMEUTC,T2M,RH,GH,GBN,GDH,IRH,WS10M,WD10M,SP] = IMPORTFILE(FILENAME,
%   STARTROW, ENDROW) Reads data from rows STARTROW through ENDROW of text
%   file FILENAME.
%
% Example:
%   [timeUTC,T2m,RH,Gh,Gbn,Gdh,IRh,WS10m,WD10m,SP] = importfile('tmy_37.967_23.719_2007_2016.csv',18, 8777);
%
%    See also TEXTSCAN.

%% Info about data
% The CSV output contains a header with the following information:
% 
% Latitude [decimal degrees]
% Longitude [decimal degrees]
% Elevation [m]
% A list of years used for each month to construct the TMY. If the full time series is requested, this list will not be included in the output.
% After this follows the header line for the actual data. The consist of 1 year (or several years) of hourly data, each hour on a separate line, with the following columns:
% 
% Date & time (UTC for normal CSV, local timezone time for the EPW format)
% T2m [�C] - Dry bulb (air) temperature.
% RH [%] -  Relative Humidity.
% G(h) [W/m2] - Global horizontal irradiance.
% Gb(n) [W/m2] - Direct (beam) irradiance.
% Gd(h) [W/m2] - Diffuse horizontal irradiance.
% IR(h) [W/m2] - Infrared radiation downwards.
% WS10m [m/s] - Windspeed.
% WD10m [�] - Wind direction.
% SP [Pa] - Surface (air) pressure.

%% Initialize variables.
delimiter = ',';
if nargin<=2
    startRow = 18;
    endRow = 8777;
end

%% Format for each line of text:
%   column1: text (%q)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%q%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
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

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
timeUTC = dataArray{:, 1};
T2m = dataArray{:, 2};
RH = dataArray{:, 3};
Gh = dataArray{:, 4};
Gbn = dataArray{:, 5};
Gdh = dataArray{:, 6};
IRh = dataArray{:, 7};
WS10m = dataArray{:, 8};
WD10m = dataArray{:, 9};
SP = dataArray{:, 10};


