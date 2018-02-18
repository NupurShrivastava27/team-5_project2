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
'Research Question: What is the number of total enrollments vs dropouts high school students for each grades in 2014-2015-2016?'
;

title2
'Rationale: This provides a comparison between both enrollments and dropouts of each grades of California High Schools (2014-2015-2016).'
;

footnote1
'Above result shows the stack bar graph of all enrollments and dropouts of California High Schools, sum total by Counties/Schools (2014-2015-2016).'
;

footnote2
'Moreover, we can see clear comparison between AY2014-2016, suggesting to know the reasons behind high rate of dropouts after enrollments.'
;

*
Note: This compares these columns "E9, E10, E11, E12, D9, D10, D11, D12" from 
dropouts1415 to the same column names from dropouts1516.
Methodology: After combining all datasets during data preparation, use sum in 
proc print to produce the totals of grade 9th to 12th for 2014 and 2015, 
using column E9 to E12 and print in the temporary dataset created in the 
corresponding data-prep file. Finally, ploted a graph out of it.
Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.
Possible Follow-up Steps: Need to bring the table in bar/stack graph to be 
more presentable.
;

data grad_drop;
    set grad_drop_merged_sorted;
run; 
proc print 
    data = grad_drop; 
    sum E9 E10 E11 E12;
    sum D9 D10 D11 D12;    
    where CDS_CODE ne ' ';
run; 
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What is the rate of genders (male vs female) in both enrollments and dropouts (2014-15-2016)?'
;

title2
'Rationale: This would help inform which gender has contributed most enrollments and dropouts (2014-15-2016).'
;

footnote1
'As can be seen, there was an extremely high rate of female dropouts AY2014-15.'
;

footnote2
'Explanations in graph possibly shows the increase and decrease of female dropouts out of enrollments AY 2014-2015-2016.'
;

*
Note: This compares the columns "ETOT, DTOT" from dropouts1415
to the same column from dropouts1516.
Methodology: Use proc sort to sort the dataset by gender. Then 
sum the columns 'ETOT' and 'DTOT' in proc print AY (2014-2015-2016), 
Then use graphs for better comaprison and appealing presentation.
Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.
Followup Steps: A possible follow-up to this approach could use an inferential
statistical technique like linear regression.
;
 
proc sort 
    data=grad_drop_merged_sorted
    out=grad_drop_sorted;
    by gender;
run; 
proc print 
    data = grad_drop_sorted;
    sum ETOT DTOT;
    where location ne ' ';
    by gender;
run; 
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: List least 10 Counties attained lowest mean in graduations AY2014-2015-2016?'
;

title2
'Rationale: This would help identify last 10 Counties in California attained graduations for the year 2014-15-2016, finding reason with suggestions to least average counties for more school preparation that might have good impact in future batch.'
;

footnote1
'All ten counties listed appear to have mean of 12th-graders graduating, suggesting least average counties for school preparation that might have the greatest impact in better results.'
;

footnote2
"However, given the magnitude of these numbers, further investigation should be performed to ensure no data errors are involved."
;

footnote3
"However, assuming there are no data issues underlying this analysis, possible explanations for such large numbers of 12th-graders , as well as lack of proper counseling for students early enough in high school to complete all necessary coursework."
;

*
Note: This compares the column Total from grads1415 to the column TOTAL from
grads1516.
Methodology: After combining grads1415 and grads1516 during data preparation,  
use proc mean by counties and then use proc sort to sort the dataset in 
decending order and finally, print here to display  10 observations. 
Limitations: This methodology does not account for schools with missing data,
nor does it attempt to validate data in any way, like filtering for values
outside of admissable values.
Followup Steps: More carefully clean the values of variables so that the
statistics computed do not include any possible illegal values, and better
handle missing data, e.g., by using a previous year's data or a rolling average
of previous years' data as a proxy.
;
proc means 
    data=grad_drop_merged_sorted mean;
    out=grad_drop_sorted;
    by COUNTY;
    var TOTAL;
run;
proc sort 
    data=grad_drop_sorted;    
    by TOTAL descending;
run;
proc print 
    data=grad_drop_sorted;
    var COUNTY
        TOTAL;
run;
title;
footnote;

