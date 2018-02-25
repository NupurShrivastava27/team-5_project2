*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
This file uses the following analytic dataset to address several research
questions regarding high school enrollments and dropouts and graduations trends
at California pubilc high schools by race, gender and schoo (AY2014-2015-2016).
Dataset Name: grad_drop_merged_sorted created in external file
STAT6250-02_w18-team-5_project2_data_preparation.sas, which is assumed to be
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
'Research Question: What is the graduation rate of between African American vs White in the year 2014-2015'
;

title2
'Rationale: This shows the difference graduation rate between Afircan American and White students in the year 2014-2015.'
;

footnote1
'Above result shows the total number of graduates of African American and White student on the year 2014-2015 and their percentage'
;

footnote2
'We can clearly see the discrepancy between the graduation rate between African American students and White student.'
;

*
Note: This compares these columns "AFRICAN_AM, WHITE" from 
grad1415_final to the same "TOTAL_SUM" from grad1415_means_sorted.

Methodology: After combining all datasets during data preparation, use sum in 
proc sql to produce the totals graduates of African American and White students.
Then divide the sum from the total number of gradautes in the year 2014-2015.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: Compare it to the 2015-2016 data.
Possbile perfrom hypothesis testing to determine if disrepancy is significant.
;

proc SQL;
    Select 
        (sum(AFRICAN_AM)) as african_grad label = "Total African American Grad", 
        (sum(WHITE)) as white_grad label = "Total White Grad", 
        (sum(AFRICAN_AM) / (Select (sum(TOTAL_sum)) From grad1415_means_sorted)) 
            label = "African American Grad %" 
                format = percent7.1,
        (sum(WHITE) / (Select (sum(TOTAL_sum)) From grad1415_means_sorted)) 
            label = "White Grad %" 
                format = percent7.1
    From
        grad1415_final
    ;    
Quit;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Which county (column B) has the highest graduation rate in the year 2014-2015?'
;

title2
'Rationale: This would show us which county did best in terms of graduation rate in the year 2014-2015.'
;

footnote1
'Above shows a histogram of all the counties total number of graduates in the year 2014-2015.'
;

footnote2
'From the graph we can see that Los Angeles has the highest number of gradautes in 2014-2015.'
;

footnote3
'This could be from the large population in Los Angeles County.'
;

*
Note: This plots a histogram showing total graduates from all counties.

Methodology: After combining all datasets during data preparation, use sgplot 
to present the total graduates in each counties.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: Compare it to the 2015-2016 data.
Maybe further investigate African American and White students graduation rate
in LA County.
;

proc sgplot
    data=grad1415_means_sorted;
    hbar county / response=TOTAL_sum;
    title9 'Number of graduates in each county during 2014-2015';
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: What is the percentage increase/decrease for Grade 12 boys enrollment from the year 2014 to 2016?'
;

title2
'Rationale: This would show us the trend for the graduation rate for Grade 12 boys from year 2014 to 2016.'
;

footnote1
'The above show us the percentage change in the boy enrollment from 2014-2016.'
;

footnote2
'This is calculated by subtracting the total number of boy enrolled in 14-15 from 15-16 and divide by the boys enrolled in 14-15.'
;

footnote3
'Hence, if there is a decrease in enrollment, it would show a negative number.  Otherwise, a positive number.'
;

footnote4
'Our result shows that there is a 0.82% decrease in grade 12 boys enrollment.'
;

*
Note: This compares the changes in enrollment rate of Grad 12 boys from 2014-2016.

Methodology: Using Proc SQL, we create 2 tables which contain the the sum of 
grade 12 boys enrollment  from each year.  Then i calculated the percentage change
by selecting the total from each table.

Limitations: This methodology does not account for any schools with missing 
data, nor does it attempt to validate data in any ways.

Followup Steps: Limit it to certain county and or race.
Determine if trend support graduation rate of different enthic group.
;

proc SQL;
    Create Table E12B_1415 as
        Select
            sum(E12) as tote_1415 label = "Total Number of Boy Enrolled in 2014-2015"
        From
            grad_drop_merged_sorted
        Where
            GENDER='M' and
            YEAR = 1415
        ;
Quit;
proc SQL;
    Create Table E12B_1516 as
        Select 
            sum(E12) as tote_1516 label = "Total Number of Boy Enrolled in 2015-2016"
        From 
            grad_drop_merged_sorted
        Where 
            GENDER = 'M' and 
            YEAR = 1516
        ;
Quit;
proc SQL;
    Select
        (((Select tote_1516 From E12B_1516)-tote_1415)/tote_1415) as E12B_change 
            label = "Percentage Change of Boys' Enrollment from 2014-2016" 
                format=percent7.2
    From 
        E12B_1415;
Quit;

title;
footnote;
