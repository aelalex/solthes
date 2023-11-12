#data_PVGIS.py
import sys
import requests

def data_from_PVGIS(path,url):
    """ Use requests to retrieve data from the PVGIS API and use them directly to SOLTHES. 
    A tmy file is generated through the PVGIS API. The default format is the csv one. """
    
    #Check info for PVGIS API from here: https://joint-research-centre.ec.europa.eu/photovoltaic-geographical-information-system-pvgis/getting-started-pvgis/api-non-interactive-service_en
    
    res=requests.get(url)

    if res.status_code == 200:
    # Print the get content in case you need.
    # print(res.text)
        data_filename=path+'.csv'
        #Write data directly as it is already in a csv format.
        with open(data_filename, 'w', encoding='utf-8', newline='') as output_file:
            output_file.write(res.text)
            print('csv file successfully stored in ',data_filename)
    else:
        print(f"Request failed with status code: {res.status_code}")
        print(f"Fail message? {res.text}")
        
    return res.status_code

def site_data(input_str):
    """ Input string for the site data information for downloading data for PVGIS and generating the corresponding URL. 
        The input_string must have a form of "site,latitude,longitude,startyear,endyear,outputformat" with commma as a delimiter.
        Example: from input_str to site='Volos', latitude='37.98', longitude='23.72', startyear='2005', endyear='2016', outputformat='csv'"""
    
    input_data=input_str.split(',')
    site=input_data[0]
    latitude=input_data[1]
    longitude=input_data[2]
    startyear=input_data[3]
    endyear=input_data[4]
    outputformat=input_data[5]

    url="https://re.jrc.ec.europa.eu/api/tmy?lat="+latitude+"&lon="+longitude+"&startyear="+startyear+"&endyear="+endyear+"&outputformat="+outputformat
    
    #Put into the specific data folder
    path='../data/data_'+site
    
    return data_from_PVGIS(path,url)




