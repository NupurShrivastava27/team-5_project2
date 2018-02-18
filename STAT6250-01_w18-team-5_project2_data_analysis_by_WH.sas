*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding high school enrollments and dropouts and graduations trends
at California pubilc high schools by race, gender and schoo (AY2014-2015-2016).
Dataset Name: grad_drop_merged_sorted created in external file
STAT6250-01_w18-team-5_project2_data_preparation.sas, which is assumed to be
in the same directory as this file
See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic datasets cde_2014_analytic_file,
  cde_2014_analytic_file_sort_frpm, and cde_2014_analytic_file_sort_sat;
%include '.\STAT6250-02_w18-team-5_project2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What is the percentage of graduation between African American vs White in the year 2014-2015'
;

title2
'Rationale: This shows the difference graduation rate between Afircan American and White students in the year 2014-2015.'
;




*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Which county (column B) has the highest graduation rate in the year 2015-2016?'
;

title2
'Rationale: This would show us which county did best in terms of graduation rate in the year 2015-2016.'
;



*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What is the percentage increase/decrease for Grade 12 boys enrollment from the year 2014 to 2016?'
;

title2
'Rationale: This would show us the trend for the graduation rate for Grade 12 boys from year 2014 to 2016.'
;
