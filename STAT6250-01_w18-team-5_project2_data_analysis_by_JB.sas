*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
STAT6250-01_w18-team-5_project2_data_analysis_by_JB.sas

This file uses four merged data sets to address research questions regarding
graduation and dropout rates for students at schools in California during the
2014-2015 and 2015-2016 academic years.

Data set name: grad_drop_merged_sorted created in external file
STAT6250-01_w18-team-5_project2_data_preparation.sas, which is assumed to be
in the same directory as this file.

See the file referenced above for data set properties.
;

* environmental setup;

* set relative file import path to current directory;
X "cd ""%substr(%sysget(SAS_EXECFILEPATH),1,%eval(%length(%sysget(SAS_EXECFILEPATH))-%length(%sysget(SAS_EXECFILENAME))))""";

* load external file that generates analytic data set Education_raw;
%include '.\STAT6250-01_w18-team-5_project2_data_preparation.sas';


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;


title1
'Research Question: What are the top five counties that experienced the greatest increase in ratio of dropouts to enrollments from 2015 to 2016?'
;

title2
'Rationale: We can identify areas where dropouts have increased year over year and examine what can be done to retain students in these areas.'
;

footnote1
'Here we see the five counties with the highest increase in dropout rate from the academic years ending in 2015 to 2016.'
;

footnote2
'The dropout rate for either year is calculated by dividing the total number of students who dropped out in a county by the total enrollment for that county.'
;

footnote3
'The change in dropout rate for each county is the dropout rate for 2015-2016 minus the dropout rate for 2014-2015.'
;


*
Methodology: Using the merged data set, we extract the sum of enrollments and
dropouts for each county using PROC MEANS. From there, we separate the output
into two separate data sets, one for each year, and we calculate the dropout
rate for each year, excluding any counties where total enrollment is less than
50 to remove outliers. We then merge the data sets for each year by county, and
calculate the change in dropout rate from year to year in each county. Finally,
we sort by the descending change in the dropout rate, and print the descriptive
data for the five counties with the greatest increase in dropout rate.

Limitations: In the original data sets, we merged records about graduation and
dropout rate based on CDS code. As a result, there is missing data in some
records in which a CDS code from the dropout records does not appear in the
graduation records or vice versa.

Possible Follow-up Steps: Move the data steps into the data prep file, and do
additional research to see if county names can be located for unmatched CDS
codes.
;
proc means
        noprint
        sum
        data=grad_drop_merged_sorted
        nonobs
    ;
    var
        ETOT
        DTOT
    ;
    class
        YEAR
        COUNTY
    ;
    output
        out=JB0_data
        sum(ETOT DTOT) = ETOT_sum DTOT_sum
    ;
;
run;
data JB1_data1415;
    retain
        YEAR
        COUNTY
        ETOT_sum_1415
        DTOT_sum_1415
        dropout_ratio_1415
    ;
    keep
        YEAR
        COUNTY
        ETOT_sum_1415
        DTOT_sum_1415
        dropout_ratio_1415
    ;
    set JB0_data(rename=(ETOT_sum=ETOT_sum_1415 DTOT_sum=DTOT_sum_1415));
        dropout_ratio_1415 = DTOT_sum_1415/ETOT_sum_1415
    ;
    if
        _TYPE_ ne 3
    then
        delete
    ;
    if
        YEAR ne 1415
    then
        delete
    ;
    if
        ETOT_sum_1415 < 50
    then
        delete
    ;
run;
data JB1_data1516;
    retain
        YEAR
        COUNTY
        ETOT_sum_1516
        DTOT_sum_1516
        dropout_ratio_1516
    ;
    keep
        YEAR
        COUNTY
        ETOT_sum_1516
        DTOT_sum_1516
        dropout_ratio_1516
    ;
    set JB0_data(rename=(ETOT_sum=ETOT_sum_1516 DTOT_sum=DTOT_sum_1516));
        dropout_ratio_1516 = DTOT_sum_1516/ETOT_sum_1516
    ;
    if
        _TYPE_ ne 3
    then
        delete
    ;
    if
        YEAR ne 1516
    then
        delete
    ;
    if
        ETOT_sum_1516 < 50
    then
        delete
    ;
run;
data JB1_merged;
    retain
        COUNTY
        ETOT_sum_1415
        DTOT_sum_1415
        dropout_ratio_1415
        ETOT_sum_1516
        DTOT_sum_1516
        dropout_ratio_1516
        change_in_dropout_ratio
    ;
    merge
        JB1_data1415
        JB1_data1516
    ;
    by
        COUNTY
    ;
    change_in_dropout_ratio = dropout_ratio_1516 - dropout_ratio_1415
    ;
run;
proc sort
        data=JB1_merged
        out=JB1_sorted
    ;
    by
        descending change_in_dropout_ratio
    ;
run;
proc print
        noobs
        label
            data = JB1_sorted(obs=5)
    ;
    var
        COUNTY
        ETOT_sum_1415
        dropout_ratio_1415
        ETOT_sum_1516
        dropout_ratio_1516
        change_in_dropout_ratio
    ;
run;
title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;


title1
'Research Question: Within the counties with a high increase in the ratio of dropouts to enrollments year over year, what are the proportions of the ethnic backgrounds of students who graduated compared to students who dropped out in the 2015-2016 academic year?'
;

title2
'Rationale: We may be able to identify evidence of the achievement gap by determining if the ratio of ethnic backgrounds of students who dropped out is significantly different from that of those who graduated.'
;

footnote1
'If there is no achievement gap, we would expect the ratio of ethnicities of the graduating class to be roughly similar to the ratio of ethnicities of students who have dropped out.'
;

footnote2
'However, we can see that in each of these counties, there appears to be a large discrepancy between these ratios, which indicates that certain ethnic groups are more likely to drop out than others.'
;

*
Methodology: Create a new data set from our original data set which only
includes the counties from the previous step and the 2015-2016 academic year.
Then calculate the total enrollment and dropout rates for each ethnicity in
these counties, and present the data in a reasonable format.

Limitations: There is some ambiguity with the differences between the count of
total graduates in each county, and the number of enrolled 12th grade students
in each county minus the number of students who dropped out. It is possible that
this is due to students who should have graduated were unable to do so, in which
case it would appear that they had enrolled, but not graduated, and not dropped
out. More investigation on this may be appropriate.

Possible Follow-up Steps: Determine the most appropriate way to display this
information in a way that explains the results for non-statisticians (i.e. pie
chart, bar chart, some other format) and also resolve and interpret the
discrepancy noted above.
;
proc sql;
    create table JB2_data as
    select *
    from grad_drop_merged_sorted
    where COUNTY
    in ('Inyo', 'Stanislaus', 'San Francisco', 'Lassen' ,'Tehama')
    and YEAR = 1516
    ;
quit;
proc sql;

proc means
        noprint
        sum
        mode
        data=JB2_data
        nonobs
    ;
    var
        E12
        D12
        TOTAL_sum
    ;
    class
        COUNTY
        ETHNIC
    ;
    output
        out=JB2_means1
        sum(E12 D12) = E12_sum D12_sum
        mode(TOTAL_sum) = TOTAL_mode
    ;
;
run;

proc sql;
    create table JB2_data2 as
    select *
    from grad_all
    where COUNTY
    in ('Inyo', 'Stanislaus', 'San Francisco', 'Lassen' ,'Tehama')
    ;
quit;

proc means
        noprint
        sum
        data=JB2_data2
        nonobs
    ;
    var
        NOT_REPORTED    /* Code 0 */
        AM_IND          /* Code 1 */
        ASIAN           /* Code 2 */
        PAC_ISLD        /* Code 3 */
        FILIPINO        /* Code 4 */
        HISPANIC        /* Code 5 */
        AFRICAN_AM      /* Code 6 */
        WHITE           /* Code 7 */
        TWO_MORE_RACES  /* Code 9 */
        TOTAL
    ;
    class
        YEAR
        COUNTY
    ;
    output
        out=JB2_means2
        sum(
            NOT_REPORTED    /* Code 0 */
            AM_IND          /* Code 1 */
            ASIAN           /* Code 2 */
            PAC_ISLD        /* Code 3 */
            FILIPINO        /* Code 4 */
            HISPANIC        /* Code 5 */
            AFRICAN_AM      /* Code 6 */
            WHITE           /* Code 7 */
            TWO_MORE_RACES  /* Code 9 */
            TOTAL
        ) = Code0 Code1 Code2 Code3 Code4 Code5 Code6 Code7 Code9 TOT_sum
    ;
run;
proc sort
        data=JB2_means2
        out=JB2_sorted2
    ;
    by
        YEAR
    ;
run;

proc sql;
    create table JB2_sorted3 as
    select * from JB2_sorted2
    where (_TYPE_ = 3 AND YEAR=1516)
    ;
quit;

proc transpose data=JB2_sorted3 out=JB2_sorted4;
    by County;
run;

proc sql;
	create table JB2_sorted5 as
	select * from JB2_sorted4
	where _NAME_ not in ('YEAR', '_TYPE_', '_FREQ_', 'TOT_sum')
	;
quit;

* This is perfect. Do not change it!;

proc freq data=JB2_sorted5 noprint;
   tables _NAME_ / out=JB2_sorted8;
   weight COL1;
   by COUNTY ;
run;

* End perfection;


proc sql;
    create table drop_by_county as
    select
        CDS_CODE,
        ETHNIC,
        GENDER,
        DTOT,
        YEAR,
        COUNTY
    from grad_drop_merged_sorted
    where COUNTY
    in ('Inyo', 'Stanislaus', 'San Francisco', 'Lassen' ,'Tehama')
    and YEAR = 1516
    ;
quit;

proc sort
        data=drop_by_county
        out=drop_by_county1
    ;
    by
        COUNTY
        ETHNIC
    ;
run;

proc means
        noprint
        sum
        data=drop_by_county1
        nonobs
    ;
    var
        DTOT
    ;
    class
        COUNTY
        ETHNIC
    ;
    output
        out=drop_by_county2
        sum(DTOT) = DTOT_by_county
    ;
;
run;

proc sql;
    create table drop_by_county3 as
    select County, Ethnic, DTOT_by_county
    from drop_by_county2
    where _TYPE_ = 3
    ;
quit;

proc freq data=drop_by_county3 noprint;
   tables ETHNIC / out=drop_by_county4;
   weight DTOT_by_county;
   by COUNTY ;
run;

data drop_by_county5(drop=COUNT);
    set drop_by_county4(rename=(Percent=Drop_percent));
run;

data JB2_sorted9(drop=_NAME_ COUNT);
    set JB2_sorted8(rename=(Percent=Grad_percent));
    length ETHNIC 8;
    ETHNIC = substr(_NAME_,5,1);
run;

data JB2_final;
    merge JB2_sorted9 drop_by_county5;
    by COUNTY ETHNIC;
run;

data JB2_map;
   /* The ID required variable contains the name of the attribute map */
   /* The VALUE required variable contains the value of the GROUP variable, 
      which in this case is FLAVOR */
   /* The FILLCOLOR variable is used to change the color for the bars created by the VBAR 
      statement. */

   input id $ value fillcolor $;
   datalines;
eth 0 red
eth 1 orange
eth 2 yellow
eth 3 green
eth 4 blue
eth 5 purple
eth 6 brown
eth 7 black
eth 9 white
;
run;

* FIGURE THIS OUT;

proc sgplot data=JB2_final dattrmap=JB2_map;
hbarparm category=County response=Grad_Percent / group=Ethnic 
              grouporder=data groupdisplay=stack discreteoffset=-0.17
              barwidth=0.3 attrid=eth; /* order by counts of 1st bar */
hbarparm category=County response=Drop_Percent / group=Ethnic 
              grouporder=data groupdisplay=stack discreteoffset=0.17
              barwidth=0.3 attrid=eth; /* order by counts of 2nd bar */
yaxis discreteorder=data;
xaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
run;


* END FIGURE THIS OUT;


title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;


title1
'Research Question: Within counties with a high increase in the ratio of dropouts, at which grade levels do we see the greatest number of dropouts?'
;

title2
'Rationale: If we can identify the point at which most students drop out, we may be able to put additional resources into student retention shortly before that point.'
;

footnote1
''
;

*
Methodology: Using the data set created at the start of the previous question,
sum up the dropouts by grade level for each county, and display the total
number of dropouts per grade level using a reasonable presentation method.

Limitations: It might make more sense to display this as a ratio rather than as
a raw number, and crosstab information using the ethnicity data from the
previous step may help illuminate trends that are present.

Possible Follow-up Steps: Determine the most effective way to communicate the
results to a non-statistician audience, and add the data and sorting steps to
the data prep file.
;

title;
footnote;
