function [filename,answer]=check_filename()
%   Ask whether to download weather data files from PVGIS. If no then ask whether to change here
%   the name of the file already stored in the data folder.
%   In prompts always put N (No) if the weather file data is already saved in
%   the correct folder.

%Check whether to download a file
prompt = 'Do you want to download a weather data file from PVGIS? Y or N:  ';
answer=check_response(prompt);
if answer=='Y'
    prompt = 'Please enter the weather data details in form of: area,latitude,longitude,start_year,end_year,output_format ';
    input_data = input(prompt,'s');
    
    %Call python from Matlab but check first that it is set-up correctly.
    if isempty(pyenv)
        disp('Python is not set up in MATLAB. Store weather file manually.');
    else
        %Call Python subroutine to download the data and store them to
        %folder data
        status_code=py.data_PVGIS.site_data(input_data);
        %check the status code to see if the data are downloaded properly.
        while (int64(status_code)==400)
             prompt = 'Please enter data in correct form of, e.g., Volos,37.98,23.72,2005,2016,csv  ';
             input_data = input(prompt,'s');
             status_code=py.data_PVGIS.site_data(input_data);
        end
    end
else
    %Check if the filename needs to be changed
    prompt = 'Do you want to change the name of the weather data file or has it been already done in SOLTHES_main? Y or N:  ';
    answer=check_response(prompt);
    
    %Enter the filename if there is a new file.
    filename='';
    if answer=='Y'
        prompt = 'Please enter filename for the weather data:  ';
        filename = input(prompt,'s');
        while (isfile(filename)== false)
            prompt='Please enter correct filename with folder data, e.g., ../data/data_Athens.csv :  ';
            filename = input(prompt,'s');
        end
    end
end