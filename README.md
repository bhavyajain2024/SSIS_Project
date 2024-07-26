# Introduction
This is an SSIS Project that takes in data from a flat file source and then transforms the data to the required for format. Later on data cleaning is done on the transformed data using sql queries which is then incrementally pushed to the production database.

# Approach and Methodologies used in ETL

## Extract

In this project data extraction is through a flat file input, which is a CSV file in this case.

Extraction Methods: Data is extracted using the flat file connection in SSIS. In the flat file connection manager we specifiy the delimeter, path, etc. for the file.
Tools/Technologies: SSIS is the primary tool for this as it provides a flat file connection manager.

## Transform and cleaning

Data is first checked for empty and null values in the Total Price column because those can be replaced with zeroes.

Data Formatting: Data extracted from the CSV file is in strings, therefore all of that is converted to their respective data types in this transformation. This step also removes, null values, inconsistent dates, negative values for columns that can be only positve. After this step Union All is used to remove the old columns having all strings in order to just move forward in our process with one set of columns having correct data types.

Data Cleaning:

1. A C# script is used to compare the emails inputted against a regex which replaces failing matches with NULL values.
2. Multiple SQL scripts is used to do the following:
    1. Remove Duplicates
    2. Validate Dates and convert them to correct date format
    3. Checking if Total Purchase value is too large, a value above 100000 is decided to be too large for now.
    4. NULL value check is done on emails which were set to null via the script above
    5. All the dates are check for inconsistencies based on business logic. For example, if registration date is younger than the last login date, or registration date is very old (even before internet was created), or either of the dates are set to be future from now.
All the rows caught during cleaning are directed towards CSV file error outputs. A log folder location is provided by the user as an input when the solution is ran.

Tools/Technologies: SSIS Script tasks, SQL Script tasks are the most common ones to be used in this step. For outputting errors I used Flat File outputs.

## Load

Data from the previous steps is loaded into a production table through OLE DB Destination.

Loading Methods: Incremental loading technique is used in this step, where only the new records are pushed to the production table.

Tools/Technologies: SSIS data flow tasks are mainly used here.

## Error Handling and Logging
Discuss how errors are handled and logged:

Error Detection: Errors are checked through a combination of data flow tasks and sql scripts. In data flow tasks, any errors that are encounted are outputted to a CSV file in the provided error output folder by the user. Errors through data flow tasks include Error ID logged by the system automatically. Any errors that are captured through SQL scripts are put into an errorLog table, which later on is loaded to a CSV file which proper error messsage, giving the reviewer useful information about why these records were marked as errors.

Recovery: There is transaction management used the SQL scripts so that if any of them fails, then there won't be data inconsistencies.

# How To Setup Project

## Prerequisite

There is an expectation of some basic knowledge about how to run SQL queries and use SQL Server Management Studio. Also know how of how to load a solution in Visual Studio 2022 and run it.

## System Requirements

You need to have Windows system. SSMS and SSIS are not compatible for Mac OS. To work on Mac OS you can use [Parallels](https://www.parallels.com/products/desktop/?utm_id=62180888&extensionid={extensionid}&matchtype=e&device=c&devicemodel=&creative=&network=o&placement=&x-source=ppc&msclkid=786a9fce855f13d2e695f96d90417383&utm_source=bing&utm_medium=cpc&utm_campaign=PDfM%20-%20B%20-%20EN%20-%20CA%20-%20PS%20-%20AMER&utm_term=parallels%20for%20mac&utm_content=Parallels%20for%20Mac) which is a paid software. However, my recommendation is to use a windows machine.

## Software Requirements

You need the following present in your system as a basic requirement to run the project:

1. You need Visual Studio 2022, with data storing and processing tools (SQL Server Data Tools) installed via the VS installer. In addition to this, you need to have SQL Server Integration Services Projects 2022 installed as an extension to Visual Studio 2022.

2. You need to have MS SQL Server 2022 installed in your system. You only need one instance of it installed with Integration Services installed with Database Engine. To install these manually configure your MS SQL Install by selecting custom install. Follow [this guide](https://www.mssqltips.com/sqlservertip/6635/install-ssis/) here to just install an instance of MS SQL Server, you don't need to worry about creating an Integration Services Catalog.

3. You need to install SQL Server Management Studio 20. Here you can run scripts to create the initial database that is required for running the package.

4. You need to install [Microsoft Access Database Engine 2016 Redistributable](https://www.microsoft.com/en-us/download/details.aspx?id=54920&irgwc=1&msockid=2e8ccacf04fc6f773d44de0a05c76e5d). This is required to the project to be able to access Excel Files.

## Instructions to how to run the solution

Running the solution is really straightforward. You need to create a database through either of the following two options or use one that you already have:

1. You can create one with a name of your choice in your MS SQL Server instance for which I have provided a script called DatabaseCreationScript.sql that you can modify to create a database with you name preference. Just run the script on the MS SQL Server instance you have or created.
2. You can load the backup file that I have provided in this repo. That will create a database with the following name:
KoreAssignment_bhavya_jain. This backup file also includes three tables as follows:
    1. errorLog.Users
    2. prod.Users
    3. stg.Users

You can remove data from all three as they contain final results of the execution of the solution. If you don't remove data from these then you won't be able to see any difference after running the solution because new data won't be added as only incremental updates are done which means that any data that is already present is not added again. After truncating all these you can continue with the next steps. As for if you select the first option and only create a database, don't worry about these tables, as they will be created automatically using the SSIS solution.


Download the zip file from this repo, extract it to a location on your system. Then open visual studio 2022 and open the solution provided in this repo under the folder SSIS_Project/KORE_Software_Project.

1. In the solution explorer, expand SSIS Packages, double click ETL-Project_Solution.dtsx.
2. Click Start on top in Visual Studio.
3. You will be prompted to input the following details (Note: All the text that is already present in input boxed that opens are placeholders, please remove them):
    1. Name of the server. Here you should type the server name that you have created or already have present instance of MS SQL. If you selected default instance name then it should be the name of your system.
    2. Database name. Here you should enter the database name that you created earlier or imported (KoreAssignment_bhavya_jain).
    3. Error Output Folder. Here you need to enter the folder location where you need your error logs from ETL process. Enter it in the same format as the example provided as a placeholder text in the input box. You can use the folder provided in this repo for error logs. Just enter the address to that folder based on where it is located in your system to the following string: "Location of the project in your system\SSIS_Project\ErrorLogs"
    4. Input CSV File location: Here you need to enter the location of the input CSV file, from where you are reading raw data to be processed. In this repo the file I used is located in the following address which you can use by adding the inital path based on the location of SSIS_Project files your system location: "path from you system"/SSIS_Project/KORE_Software_Project/InputData.csv

Now the rest of the process should begin without any other inputs from your side. The ETL process will take the raw data from InputData.csv file and the process will clean that data. At the end you can see cleaned data in prod.Users table in the database you selected. stg.Users and errorLog.Users table would be empty as they are truncated at the end of ETL process as the data in errorLog table is already exported and stg table data is not needed as they would only be there if production table already had them. You will see errorLog files in the selected logging folder and you will see database backup files in the following location: C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\

The backup files in the folder above are organized in four names:
1. YourDatabaseName_InitialBackup_YYYYMMDD :- This backup is taken of the initial state of your database before any processing.
2. YourDatabaseName_AfterDataExtractionBackup_YYYYMMDD :- This backup is taken after extraction and transformation stage of the SSIS package.
3. YourDatabaseName_AfterDataCleanupBackup_YYYYMMDD :- This backup is taken after cleanup of the data.
4. YourDatabaseName_PostCompletionBackup_YYYYMMDD :- This backup is taken after cleaned data is pushed to the production table.


