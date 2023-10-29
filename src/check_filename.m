function [filename,txt]=check_filename()
%Check if the filename needs to be changed
prompt = 'Do you want to change the name of the weather data file? Y or N:  ';
txt = input(prompt,'s');
while not (isequal(txt,'Y') || isequal(txt,'N'))
    prompt='Please enter Y or N:  ';
    txt = input(prompt,'s');
end
%Enter the filename
filename='';
if txt=='Y'
    prompt = 'Please enter filename for the weather data:  ';
    filename = input(prompt,'s');
    while (isfile(filename)== false)
        prompt='Please enter correct filename with folder data, e.g., data/data_Athens.csv :  ';
        filename = input(prompt,'s');
    end
end