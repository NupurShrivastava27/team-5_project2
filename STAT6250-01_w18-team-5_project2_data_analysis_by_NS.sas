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


* load external file that generates analytic datasets cde_2014_analytic_file,
  cde_2014_analytic_file_sort_frpm, and cde_2014_analytic_file_sort_sat;
%include '.\STAT6250-01_w18-team-5_project2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What are the number of total enrollments vs dropouts of high school students for each grade in 2014-2015-2016?'
;

title2
'Rationale: This provides a comparison between both enrollments and dropouts of each grade of CA high schools (2014-2015-2016).'
;

footnote1
'Above result shows the stacked bar graph of all enrollments and dropouts of CA high schools, sum total by counties/schools (2014-2015-2016).'
;

footnote2
'Moreover, we can see a clear comparison between AY2014-2016, suggesting to know the reasons behind the high rate of dropouts after enrollments.'
;

*
Note: This compares these columns "E9, E10, E11, E12, D9, D10, D11, D12" 
from dropouts1415 to the same column names from dropouts1516.

Methodology: After combining all datasets during data preparation, use sum
in proc sql to have the totals of grade 9th to 12th for 2014 and 2015 and
print in the temporary dataset created in the corresponding data-prep file. 
Finally, plotted a graph out of it.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: Need to bring the table in bar/stacked graph, be 
more presentable.
;

proc sql;
    create table
        Enroll_drops as
    select 
        YEAR, 
        sum(E9) format=comma14.  as Enroll_Grade9th,
        sum(E10) format=comma14. as Enroll_Grade10th,
        sum(E11) format=comma14. as Enroll_Grade11th,
        sum(E12) format=comma14. as Enroll_Grade12th,
        sum(D9) format=comma14.  as Dropout_Grade9th,
        sum(D10) format=comma14. as Dropout_Grade10th,
        sum(D11) format=comma14. as Dropout_Grade11th,
        sum(D12) format=comma14. as Dropout_Grade12th
    from 
        Grad_drop_merged_sorted
    where
        YEAR is not missing
    group by
        YEAR
    ;
select * from Enroll_drops;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What are the number of male and female enrollments and dropouts AY2014-15-2016?'
;

title2
'Rationale: This would help inform which gender has contributed the most in enrollments and dropouts AY2014-15-2016.'
;

footnote1
'As can be seen, an increasing number of female dropouts from 2014-2015-2016.'
;

footnote2
'Moreover, graph possibly shows the increase of male in enrollments from 2014-2015-2016.'
;

*
Note: This compares the columns "ETOT, DTOT" from dropouts1415
to the same column from dropouts1516.

Methodology: Use proc sort to sort the dataset by gender. Then 
sum the columns 'ETOT' and 'DTOT' in proc print AY (2014-2015-2016), 
.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: A possible follow-up to this approach could use an inferential
statistical technique like linear regression.
;
 
proc means
    noprint
    data=grad_drop_merged_sorted 
    sum
    ;
	var
        ETOT
        DTOT
    ;
    class
        YEAR
        GENDER
    ;
    output
        out=enrol_drop_gender (drop=_type_ _freq_)
        sum(ETOT DTOT) = ETOT_sum DTOT_sum
    ;
run; 
data ns2_enrol_drop_gender
    ;
    set 
        enrol_drop_gender
    ;
    if 
        cmiss(of _all_) 
    then 
        delete
    ;
run;
proc sgpanel 
    data=ns2_enrol_drop_gender
    ;
    title3 "Male and Female Enrollments and Dropouts AY2014-15-2016"
    ;
    panelby 
        YEAR
        GENDER
    ;
    rowaxis label
        ="Enroll Vs Drops"
    ;
    vbar
        GENDER / 
    response
        =ETOT_sum 
    transparency
        =0.2
    ;
    vbar
        GENDER /
    response
        =DTOT_sum
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
'Research Question: Provide the proportion of Summer twelfth-grade graduates by ethnic demographic for AY1415-1516?'
;

title2
'Rationale: This graph shows a high level demographic information of summer school graduates for the schoolof California.'
;

footnote1
'This data includes summer graduates and does not include students with high school equivalencies, such as, General Educational Development (GED) test or California High School Proficiency Examination (CHSPE).'
;

footnote2
"However, given the magnitude of these numbers, further investigation should be performed to ensure no data errors are involved."
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
handle missing data, e.g., by using a previous year's data or a rolling 
average of previous years' data as a proxy.
;

proc sql; 
    create table 
        ethnic_1415 as 
    select  
    sum(HISPANIC) / SUM(TOTAL) as Hisp format=percent8.2, 
    sum(AM_IND) / SUM(TOTAL) as Amid format=percent8.2, 
    sum(ASIAN) / SUM(TOTAL) as Asian format=percent8.2, 
    sum(PAC_ISLD) / SUM(TOTAL) as PacId format=percent8.2, 
    sum(FILIPINO) / SUM(TOTAL) as Filip format=percent8.2, 
    sum(AFRICAN_AM) / SUM(TOTAL) as AfricanAm format=percent8.2, 
    sum(WHITE) / SUM(TOTAL) as While format=percent8.2, 
    sum(TWO_MORE_RACES) / SUM(TOTAL) as TwoMoreRaces format=percent8.2, 
    sum(Not_REPORTED) / SUM(TOTAL) as NotReported format=percent8.2 
    from GRAD1415_RAW; 
quit; 
proc sql; 
    create table ethnic_1516 as 
    select  
    sum(HISPANIC) / SUM(TOTAL) as Hisp format=percent8.2, 
    sum(AM_IND) / SUM(TOTAL) as Amid format=percent8.2, 
    sum(ASIAN) / SUM(TOTAL) as Asian format=percent8.2, 
    sum(PAC_ISLD) / SUM(TOTAL) as PacId format=percent8.2, 
    sum(FILIPINO) / SUM(TOTAL) as Filip format=percent8.2, 
    sum(AFRICAN_AM) / SUM(TOTAL) as AfricanAm format=percent8.2, 
    sum(WHITE) / SUM(TOTAL) as While format=percent8.2, 
    sum(TWO_MORE_RACES) / SUM(TOTAL) as TwoMoreRaces format=percent8.2, 
    sum(Not_REPORTED) / SUM(TOTAL) as NotReported format=percent8.2 
    from Grad1516_RAW 
    ; 
quit; 
data grad_ethnic_cat 
    ; 
   input  
       Ethnic_Cat $  
    ; 
datalines 
    ; 
HISPANIC  
AMIND  
ASIAN  
PACISLD  
FILIPINO  
AFRICANAM  
WHITE   
TWOMORERACES  
NOTREPORTED  
 ; 
data grad_ethnic_value; 
set ethnic_1415; 
array ethnic_1415[9] Hisp--NotReported; 
do I=1 to 9; 
Ethnic_1415=ethnic_1415(i); 
output; 
end; 
keep Ethnic_1415; 
run;  
data grad_ethnic_value2; 
set ethnic_1516; 
array ethnic_1516[9] Hisp--NotReported; 
 do I=1 to 9; 
 Ethnic_1516=ethnic_1516(i); 
 output; 
 end; 
 keep Ethnic_1516; 
run;  
data grad_ethnic_final1; 
   merge grad_ethnic_cat  grad_ethnic_value ; 
run; 
data grad_ethnic_final2; 
   merge grad_ethnic_cat  grad_ethnic_value2; 
run;
data Grad_ethnic_1416;
   set grad_ethnic_final1;
   set grad_ethnic_final2;
run;
proc print 
    data=Grad_ethnic_1416;
    title3 'The percentage of Summer twelfth-grade graduates by ethnic AY1415-1516';
    title4 '||Pie Graph by year out of this table is coming soon||';
run;

title;
footnote;

