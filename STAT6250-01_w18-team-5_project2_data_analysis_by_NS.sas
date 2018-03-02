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
10th, 11th and 12th graders for AY 2014-2015 and 2015-2016 from 
dropouts1415 and dropouts1516 dataset respectively. Populate the correct
values using array function to provide table lookups in the temprary dataset. 
Finally, plotted a graph using proc sgpanel.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: This graph presents only high level picture of enrollments 
and dropouts for 2014-2016.However, gender distributions with respect to 
enrollments and dropouts are not presented here in this graph.
;

proc sql;
    create table
        enroll_drops as
    select 
        YEAR, 
        sum(E9) format=comma14.  as Enroll_GradeNine,
        sum(E10) format=comma14. as Enroll_GradeTen,
        sum(E11) format=comma14. as Enroll_GradeEleven,
        sum(E12) format=comma14. as Enroll_GradeTwelth,
        sum(D9) format=comma14.  as Dropout_GradeNine,
        sum(D10) format=comma14. as Dropout_GradeTen,
        sum(D11) format=comma14. as Dropout_GradeEleven,
        sum(D12) format=comma14. as Dropout_GradeTwelth
    from 
        Grad_drop_merged_sorted
    where
        YEAR is not missing
    group by
        YEAR
    ;
quit;

/*Arrays been used to provide table lookups.*/ 
data enrolls_prep; 
    set 
        enroll_drops
    ; 
    array 
        enroll_drops[4] 
        Enroll_GradeNine--Enroll_GradeTwelth
    ; 
    do I=1 to 4
    ; 
        Enrollments=enroll_drops(i)
    ; 
    output
    ; 
    end
    ; 
    keep 
        Enrollments; 
run;  
data drops_prep; 
    set 
        enroll_drops
    ; 
    array 
        enroll_drops[4] 
        Dropout_GradeNine--Dropout_GradeTwelth
    ; 
    do I=1 to 4
    ; 
        Dropouts=enroll_drops(i)
    ; 
    output
    ; 
    end
    ; 
    keep 
        Dropouts
    ; 
run; 
data enrolls_drops_years 
    ; 
    input  
        YEAR 
        Graders  
    ; 
    datalines 
    ; 
        1415 09
        1415 10
        1415 11
        1415 12
        1516 09
        1516 10
        1516 11
        1516 12
    ; 

data enroll_years; 
    merge 
        enrolls_drops_years  
        enrolls_prep
    ; 
run; 

data drop_years; 
    merge 
        enrolls_drops_years
        drops_prep
    ; 
run;

data Enroll_drop_1416;
    set 
        enroll_years
    ;
    set 
        drop_years
    ;
run;

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
AY 2014-2015-2016. Finally, plot a graph using proc sgpanel.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.And this graphh does
not shows the ethnic categories of genders.Ethnic categories could help us
to peek more into demographic data.

Followup Steps: A possible follow-up to this approach could use an inferential
statistical technique like linear regression.
;
 
proc means
    noprint
    data=grad_drop_merged_sorted 
    sum MAXDEC=2
    ;
    label
        ETOT = 'Total Enrollments'
        DTOT = 'Total Dropouts'
		YEAR = 'Year'
		GENDER = 'Gender'
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
        sum(ETOT DTOT) = Enrollments Dropouts
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
dataset. Secondly, created new dataset with raw Data with the input statement.
used arrays function been used to provide table lookups. Finally, sort the final
temporary dataset to print in in tabular format.

Limitations: This methodology does not account for schools with missing data,
nor does it attempt to validate data in any way. Moreover, this data includes 
summer graduates and does not include students with high school equivalencies, 
such as, General Educational Development (GED) test or California High School 
Proficiency Examination (CHSPE).'

Followup Steps: However, given the magnitude of these numbers, further 
investigation should be performed to ensure no data errors are involved.
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
    from 
        GRAD1415_RAW
    ; 
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
    from 
        Grad1516_RAW 
    ; 
quit; 

data grad_ethnic_cat; 
    input  
        Ethnic_Category $25. 
    ; 
    datalines 
    ; 
        Hispanic
        AmericanInd
        Asian
        PacificIsld
        Filipino  
        AfricanAmerican
        White   
        MoreRaces
        NotReported
    ; 

data grad_ethnic_value; 
    set 
        ethnic_1415
    ; 
    array 
        ethnic_1415[9] 
        Hisp--NotReported
    ; 
    do 
        I=1 to 9
    ; 
 	Ethnic_2014=ethnic_1415(i)
    ; 
    output
    ; 
    end
    ; 
    keep
 		Ethnic_2014
    ; 
run;
 
data grad_ethnic_value2; 
    set 
        ethnic_1516
    ; 
    array 
        ethnic_1516[9]
        Hisp--NotReported; 
    do 
        I=1 
    to 9
    ; 
     Ethnic_2015=ethnic_1516(i)
    ; 
    output
    ; 
    end
    ; 
    keep
        Ethnic_2015 
    ; 
run;  
data grad_ethnic_final1; 
    merge 
        grad_ethnic_cat
        grad_ethnic_value 
    ; 
run;
 
data grad_ethnic_final2; 
    merge 
        grad_ethnic_cat
        grad_ethnic_value2 
    ; 
run;

data Grad_ethnic_1416;
    set 
        grad_ethnic_final1
    ;
	
	format 
        ethnic_2014  percent8.2
    ;
    label
        Ethnic_2014='Ethnic(2014-2015)'
    ;
    set 
        grad_ethnic_final2
    ;
	format 
        ethnic_2015  percent8.2
    ;
	label
        Ethnic_2015='Ethnic(2015-2016)'
    ;
run;
proc sort 
    data=Grad_ethnic_1416 
    out=Grad_ethnic_1416_sorted
    ;
    by descending
        ethnic_2014 
        ethnic_2015 
    ;
run;
proc print noobs 
    data=Grad_ethnic_1416_sorted
    ;
run;

title;
footnote;

