function [res] = check_response(prompt)
%  Function to check response from prompt for only Yes (Y) or No (N)
res = input(prompt,'s');
while not (isequal(res,'Y') || isequal(res,'N'))
    prompt='Please enter Y or N:  ';
    res = input(prompt,'s');
end
end