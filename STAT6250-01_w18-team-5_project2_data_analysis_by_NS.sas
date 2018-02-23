*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding high school enrollments and dropouts and graduations trends
at California pubilc high schools by race, gender and school AY2014-2015-2016.
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
proc sql to have the totals of grade 9th to 12th for 2014 and 2015 and print 
in the temporary dataset created in the corresponding data-prep file. 
Finally, ploted a graph out of it.
Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.
Possible Follow-up Steps: Need to bring the table in bar/stack graph to be 
more presentable.
;

proc sql;
   create table Enroll_drops as
   select YEAR, 
   sum(E9) format=comma14.  as Enroll_Grade9th,
   sum(E10) format=comma14. as Enroll_Grade10th,
   sum(E11) format=comma14. as Enroll_Grade11th,
   sum(E12) format=comma14. as Enroll_Grade12th,
   sum(D9) format=comma14.  as Dropout_Grade9th,
   sum(D10) format=comma14. as Dropout_Grade10th,
   sum(D11) format=comma14. as Dropout_Grade11th,
   sum(D12) format=comma14. as Dropout_Grade12th
      from Grad_drop_merged_sorted
      where YEAR is not missing
      group by YEAR;
proc sgpanel data=Enroll_drops;
  title 'Actual Sales by Product, Year and Quarter';
  panelby YEAR  / layout=columnlattice novarname noborder colheaderpos=bottom;
  vbar Enroll_Grade9th / response=Enroll_Grade9th group=YEAR dataskin=gloss;
  colaxis display=(nolabel);
  rowaxis grid;
  run;
proc sgplot data=Enroll_drops;
  title 'Actual Sales by Product and Quarter';
  vbar Enroll_Grade9th / response=Enroll_Grade9th group=YEAR 
        groupdisplay=cluster 
        dataskin=gloss;
  xaxis display=(nolabel);
  yaxis grid;
  run;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What is the rate of genders (male vs female) enrollments and dropouts AY2014-15-2016?'
;

title2
'Rationale: This would help inform which gender has contributed most enrollments and dropouts (2014-15-2016).'
;

footnote1
'As can be seen, there was an increase in rate of female dropouts AY2015-16.'
;

footnote2
'Explanations in graph possibly shows the increase in female dropouts AY2014-2015-2016.'
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
data NS2_enrol_drop_gender; 
set enrol_drop_gender;
if cmiss(of _all_) then delete;
run;
proc print data=NS2_enrol_drop_gender noobs;
run;
proc sgpanel data=NS2_enrol_drop_gender;
title3 "Male and Female Enrollments and Dropouts AY2014-15-2016";
panelby YEAR GENDER;
rowaxis label="Enroll Vs Drops";
vbar GENDER / response=ETOT_sum 
transparency=0.2;
vbar GENDER / response=DTOT_sum barwidth=0.5 
transparency=0.2; 
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
handle missing data, e.g., by using a previous year's data or a rolling average
of previous years' data as a proxy.
;

title;
footnote;

