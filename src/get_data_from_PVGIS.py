import sys
import requests

def data_from_PVGIS(path,url):
    """ Use requests to retrieve data from the PVGSIS API and use them directly to SOLTHES. 
    A tmy file is generated through the PVGIS API. The default format is the csv one. """
    
    res=requests.get(url)

    if res.status_code == 200:
    # Print the get content in case you need.
    # print(res.text)
        data_filename=path+'.csv'
        #Write data directly as it is already in a csv format.
        with open(data_filename, 'w', encoding='utf-8', newline='') as output_file:
            output_file.write(res.text)
    else:
        print(f"Request failed with status code: {res.status_code}")
        print(f"Fail message? {res.text}")

def main():
    """ Main entry point for the script """
    #define the parameters for the data file
    site='Volos' #Only for reference purposes
    latitude='37.98'
    longitude='23.72'
    startyear='2005'
    endyear='2016'
    outputformat='csv'
    url="https://re.jrc.ec.europa.eu/api/tmy?lat="+latitude+"&lon="+longitude+"&startyear="+startyear+"&endyear="+endyear+"&outputformat="+outputformat
    
    #Put into the specific data folder
    path='../data/data_'+site
    
    data_from_PVGIS(path,url)

if __name__=='__main__':
    sys.exit(main())

