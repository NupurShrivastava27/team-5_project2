*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following dataset to address several research
questions regarding high school enrollments and dropouts and graduations trends
at California pubilc high schools by race, gender and schools AY2014-2015-2016.

Dataset Name: grad_drop_merged_sorted created in external file
STAT6250-01_w18-team-5_project2_data_preparation.sas, which is assumed to be
in the same directory as this file

See included file for dataset properties
;

* environmental setup;

* set relative file import path to current directory (using standard SAS trick);
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";


* load external file that generates analytic data set grad_drop_merged_sorted;
%include '.\STAT6250-01_w18-team-5_project2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What are the total enrollments and dropouts of each gradres in CA high school ( 2014-2015-2016 )?'
;

title2
'Rationale: This provides a comparison between total enrollments and dropouts of 9th to 12th graders in CA high school ( 2014-2015-2016 ).'
;

footnote1
'Above result shows the bar graph of total enrollments and dropouts, sum total by counties and schools.'
;

footnote2
'Moreover, we can see a clear comparison between 2014-2016,i.e decrease in both enrollments and dropouts from 2014 to 2016.'
;

*
Note: This compares these columns "E9, E10, E11, E12, D9, D10, D11, D12" 
from dropouts1415 to the same column names from dropouts1516.

Methodology: First, after combining all datasets during data preparation, 
use sum function in sql procedure to have the totals of individual 9th,
10th, 11th and 12th graders from dataset Grad_drops_merge_sorted for 
AY 2014-2015 and 2015-2016. Then populate the correct values using array 
function to provide table lookups in the temprary dataset. Finally, 
plot here a graph using proc sgpanel to dipict the total enrollments 
and dropouts of each gradres in CA high school ( 2014-2015-2016 ).

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: This graph presents only high level picture of enrollments 
and dropouts for 2014-2016.However, gender distributions with respect to 
enrollments and dropouts are not presented here in this graph.
;

proc sgpanel 
    data=Enroll_drop_1416
    ;
    title3 "Enrollments and Dropouts ( 2014-15-2016 .)"
    ;
    format 
        Enrollments comma10.0
    ;
    format 
        Dropouts comma10.0
    ;
    panelby 
        YEAR 
    ;
    rowaxis label="Enrollments  and  Dropouts"
    ;
    vbar
        Graders / 
    response=Enrollments  DATALABEL
    transparency=0.2
    ;
    vbar
        Graders / 
    response =Dropouts DATALABEL
    barwidth =0.5
    transparency=0.2
    ;
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What are the total male and female enrollments and dropouts ( 2014-15-2016 )?'
;

title2
'Rationale: This would help inform which gender has contributed the most in enrollments and dropouts AY2014-15-2016.'
;

footnote1
'As can be seen, an decrease in numbers of female and male with respect to both enrollments and dropouts from 2014 to 2016.'
;

footnote2
'However, we should know the reason of dropouts from AY 2014-2015-2016.'
;

*
Note: This compares the columns "ETOT, DTOT" from dropouts1415
to the same column from dropouts1516.

Methodology: First, use sum function to the columns 'ETOT' and 'DTOT' 
in mean procedure from sorted datset 'grad_drop_merged_sorted' for 
AY 2014-2015-2016. Finally, here plot a graph using proc sgpanel which,
dipict the total male and female enrollments and dropouts ( 2014-15-2016 ).

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.And this graphh does
not shows the ethnic categories of genders.Ethnic categories could help us
to peek more into demographic data.

Followup Steps: A possible follow-up to this approach could use an inferential
statistical technique like linear regression.
;
 
proc sgpanel 
    data=ns2_enrol_drop_gender
    ;
    title3 "Male and Female Enrollments and Dropouts AY2014-15-2016"
    ;
    format 
        Enrollments comma10.0
    ;
    format 
        Dropouts comma10.0
    ;
    panelby
        YEAR 
    ;
    rowaxis label
        ="Enrollments  Vs  Dropouts"
    ;
    vbar
        GENDER / DATALABEL
    response
        =Enrollments  DATALABEL
    transparency
        =0.2
    ;
    vbar
        GENDER /
    response
        =Dropouts  DATALABEL
    barwidth
        =0.5
    transparency
        =0.2
    ;
run;
 
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Provide the percentage of summer twelfth-grade graduates by ethnic demographic for AY1415-1516?'
;

title2
'Rationale: This graph shows a high level demographic information of summer school graduates of California schools.'
;

footnote1
'High percentage of graduation from summer twelth grade belongs to the Hispanic, White and African Americans.'
;

footnote2
'This data includes summer graduates and does not include students with General Educational Development (GED) test or California High School Proficiency Examination (CHSPE).'
;

*
Note: This compares the column Total from grads1415 to the column TOTAL from
grads1516.

Methodology: After combining grads1415 and grads1516 during data preparation,  
first, use sum function in sql procedure in order to calculate percentage using
columns HISPANIC, AM_IND, ASIAN, PAC_ISLD, FILIPINO, AFRICAN_AM, WHITE, 
TWO_MORE_RACES, NOT_REPORTED and TOTAL from GRAD1415_RAW and GRAD1516_RAW 
dataset. Secondly, created new dataset with raw data with the input statement.
Then used arrays function to provide table lookups and sort the final
temporary dataset to print in in tabular format. Finally, print the percentage
of summer twelfth-grade graduates by ethnic demographic for AY1415-1516 in 
tabular form.

Limitations: This methodology does not account for schools with missing data,
nor does it attempt to validate data in any way. Moreover, this data includes 
summer graduates and does not include students with high school equivalencies, 
such as, General Educational Development (GED) test or California High School 
Proficiency Examination (CHSPE).'

Followup Steps: However, given the magnitude of these numbers, further 
investigation should be performed to ensure no data errors are involved.
;

proc print noobs 
    data=Grad_ethnic_1416_sorted
    ;
run;

title;
footnote;

