*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
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


* load external file that generates analytic data set grad_drop_merged_sorted;
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

*
Using the combined data set from the data prep file, generate a new data set
containing the sums of enrollments (ETOT_sum) and dropouts (DTOT_sum) for each
county, sorted by year and by county
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

*
From the data set generated in the previous PROC MEANS step, generate a new
data set that includes only the year, county, enrollment total, dropout total,
and calculated dropout ratio (dropout_ratio_1415) for each county, excluding
any counties in which enrollment is very low (less than 50 students total), and
only choosing data for AY2014-2015
;
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

*
From the data set generated in the previous PROC MEANS step, generate a new
data set that includes only the year, county, enrollment total, dropout total,
and calculated dropout ratio (dropout_ratio_1516) for each county, excluding
any counties in which enrollment is very low (less than 50 students total), and
only choosing data for AY2015-2016
;
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

*
Merge the data sets created in the previous two steps to create a new data set
that includes all the data from the previous steps as well as a new calculated
value, change_in_dropout_ratio, which is the dropout ratio from AY2015-2016
minus the dropout ratio from AY2014-2015
;
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

*
Sort the data set generated in the previous step by descending change in dropout
ratio
;
proc sort
        data=JB1_merged
        out=JB1_sorted
    ;
    by
        descending change_in_dropout_ratio
    ;
run;

*
Print the descriptive data for the counties with the highest increase in dropout
ratio from AY2014-2015 to AY2015-2016
;
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
    label
        COUNTY = 'County'
        ETOT_Sum_1415='2014-2015 Enrollments'
        dropout_ratio_1415='2014-2015 Dropouts per Enrollments'
        ETOT_Sum_1516='2015-2016 Enrollments'
        dropout_ratio_1516='2015-2016 Dropouts per Enrollments'
        change_in_dropout_ratio='Change in Dropouts per Enrollments'
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
'For each county, the top bar shows the ratio of the graduation rate for each ethnic group. The bottom bar shows the dropout rate of each ethnic group in that county.'
;

footnote2
'If there is no achievement gap, we would expect the ratio of ethnicities of the graduating class to be roughly similar to the ratio of ethnicities of students who have dropped out.'
;

footnote3
'However, we can see that in each of these counties, there appears to be a large discrepancy between these ratios, which indicates that certain ethnic groups are more likely to drop out than others.'
;

footnote4
'If the segment for a given ethnic group is much larger in the lower bar than in the upper bar, it indicates that within that county, members of that ethnic group drop out in greater proportion than they graduate, which could indicate an achievement gap between members of that group and the rest of the population in that county.'
;

footnote5
'In this case, we see that in San Francisco County, the proportions of Hispanic and African American students who drop out is significantly higher than the proportions of those who graduate.'
;

footnote6
'We can also observe a disparity in Tehama county, where the proportion of Hispanic students who drop out is much higher than the proportion of Hispanic students who graduate.'
;

*
Methodology: Create a new data set from the graduation data set which only
includes the counties from the previous step and the 2015-2016 academic year.
Then calculate the total graduation and dropout rates for each ethnicity in
these counties, and present the data in a reasonable format. In this case, the
graduation data contains a breakdown of each school's graduates by ethnicity,
with each ethnicity represented by a separate column. Because of this, when
extracting the data, we need to transpose the graduation data so that it is
listed vertically. Then, we need to merge it with data about drops by county
and create graphs that show the proportions of the graduation rate and dropout
rate for each ethnicity.

Limitations: There is some ambiguity with the differences between the count of
total graduates in each county, and the number of enrolled 12th grade students
in each county minus the number of students who dropped out. It is possible that
this is due to students who should have graduated were unable to do so, in which
case it would appear that they had enrolled, but not graduated, and not dropped
out. More investigation on this may be appropriate.

Possible Follow-up Steps: Figure out how to label the bars in the bar graph to
say "Grad" and "Drop" for each bar.
;

*
Use PROC SQL to generate a new data set containing only the graduation data for
AY2015-2016 for schools in counties with the highest change in dropout ratio
;
proc sql;
    create table JB2_data2 as
    select *
    from grad_all
    where COUNTY
    in ('Inyo', 'Stanislaus', 'San Francisco', 'Lassen' ,'Tehama')
    and
    year=1516
    ;
quit;

*
Use PROC MEANS with the data set generated in the previous step to sum up the
graduation numbers at each school by ethnicity and overall for each county,
generating new columns named "Code#" corresponding to the ethnicity code as
denoted in the data dictionary, and also as included in the data sets that
pertain to student dropout rates
;
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

*
Use PROC SQL and the _TYPE_=1 condition to extract the lines from the previously
created data set that include data specific to each county
;
proc sql;
    create table JB2_sorted3 as
    select * from JB2_means2
    where _TYPE_=1
    ;
quit;

*
Because the dropout data is organized with columns containing county and
ethnic code, we need to transpose the data set generated in the previous step
so that the resulting data set contains graduation data with columns for
county and ethnic code, along with the count of graduations for each of those
combinations stored in "COL1"
;
proc transpose data=JB2_sorted3 out=JB2_sorted4;
    by County;
run;

*
Use PROC SQL to generate a new data set from the previous data set that excludes
rows that do not include an ethnic code
;
proc sql;
    create table JB2_sorted5 as
    select * from JB2_sorted4
    where _NAME_ not in ('YEAR', '_TYPE_', '_FREQ_', 'TOT_sum')
    ;
quit;

*
Use PROC FREQ to generate a new data set from the previous data set that adds
a column (PERCENT). For each county, the total number of graduations in
AY2015-2016 is calculated, and then the number of graduates of each ethnicity
within that county is divided by the total graduations in the county to generate
a percentage. The result in PERCENT is 100 times the number of graduates in a
county of a specific ethnicity (Code# in column _NAME_) divided by the total
number of graduates in that county. For example, in row 6 of the resulting data
set, COUNTY is "Inyo", _NAME_ is "Code5", and PERCENT is approximately 72.98.
According to the data dictionary, ethnic code 5 corresponds to Hispanic. This
means that in Inyo County, 72.98% of the graduates in 2016 were Hispanic.
;
proc freq data=JB2_sorted5 noprint;
   tables _NAME_ / out=JB2_sorted8;
   weight COL1;
   by COUNTY ;
run;

*
Create a final data set for graduation data that drops the _NAME_ and COUNT
columns, while creating a new column for a numerical representation of ethnic
code (ETHNIC) that is created by using the substr() function to extract the
number from each "Code#" entry in the _NAME_ field. This step also renames
PERCENT to Grad_percent to be more descriptive for when we later merge it with
the data set that refers to the percentages of students who drop out.
;
data JB2_sorted9(drop=_NAME_ COUNT);
    set JB2_sorted8(rename=(Percent=Grad_percent));
    length ETHNIC 8;
    ETHNIC = substr(_NAME_,5,1);
run;

*
Now that the graduation data set for the counties of interest has been created,
use PROC SQL to start to prepare a data set containing data about the number
of students who dropped out in AY2015-2016 in the counties in question
;
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

*
Sort the data set generated in the previous step by county and ethnic code,
similar to the structure of the final graduation data set
;
proc sort
        data=drop_by_county
        out=drop_by_county1
    ;
    by
        COUNTY
        ETHNIC
    ;
run;

*
Use PROC MEANS to calculate the total number of dropouts per county in
AY2015-2016 (DTOT_by_county)
;
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

*
Use PROC SQL to generate a new data set from the previous data set that includes
only the county, ethnic code, and total number of dropouts per county
;
proc sql;
    create table drop_by_county3 as
    select County, Ethnic, DTOT_by_county
    from drop_by_county2
    where _TYPE_ = 3
    ;
quit;

*
Use PROC FREQ to generate a new data set that includes a column PERCENT that
represents the percentage of the total number of students who drop out in each
county who belong to the ethnic group represented by the associated ethnic code.
For example, in row 6 of the resulting data set, COUNTY is "Inyo", ETHNIC is 5,
and PERCENT is approximately 72.98. According to the data dictionary, ethnic
code 5 corresponds to Hispanic. This means that in Inyo County, 72.98% of the
students who dropped out in AY2015-2016 were Hispanic.
;
proc freq data=drop_by_county3 noprint;
   tables ETHNIC / out=drop_by_county4;
   weight DTOT_by_county;
   by COUNTY ;
run;

*
Create a new data set from the previous data set that eliminates the COUNT
column and renames PERCENT to Drop_percent to be more descriptive
;
data drop_by_county5(drop=COUNT);
    set drop_by_county4(rename=(Percent=Drop_percent));
run;

*
Create a data set that includes the proportions of graduates of each ethnicity
in the graduating class in each county, as well as the proportions of
ethnicities of students who drop out in each county
;
data JB2_final;
    merge JB2_sorted9 drop_by_county5;
    by COUNTY ETHNIC;
run;

*
Create an attribute map for use in generating a bar plot that displays a
different color for each ethnicity
;
data JB2_map;
    retain linecolor "black";
    length id $3. value $18. fillcolor $8.;
    input id $ value $ fillcolor $;
    infile datalines delimiter='|';
    datalines;
        eth|Not Reported|cx607d8b
        eth|Native American|cx8bc34a
        eth|Asian|cx009688
        eth|Pacific Islander|cxff5722
        eth|Filipino|cx673ab7
        eth|Hispanic|cxffc107
        eth|African American|cx3f51b5
        eth|White|cx00bcd4
        eth|Two or More Races|cx795548
;
run;

*
Create a new data set containing the single digit ethnic code (ETHNIC) and the
text of the ethnicity it represents (Ethnic_group) for use in the bar plot to
be generated
;
data JB2_partial1;
    informat Ethnic_group $20.;
    input ETHNIC Ethnic_group $;
    infile datalines delimiter='|';
    datalines;
        0|Not Reported
        1|Native American
        2|Asian
        3|Pacific Islander
        4|Filipino
        5|Hispanic
        6|African American
        7|White
        9|Two or More Races
    ;
run;

*
Use PROC SQL to generate the final data set to be used to generate a bar plot
;
proc sql;
    create table JB2_final1 as
    select
        County,
        /* JB2_final.Ethnic, */
        Ethnic_Group,
        Grad_percent,
        Drop_percent
    from JB2_final left join JB2_partial1
    on JB2_final.ETHNIC = JB2_partial1.ETHNIC
    ;
quit;

*
Use ODS GRAPHICS to fix the height of the display area, and then use PROC SGPLOT
to create two grouped bar charts for each county, in which the top bar shows
the proportions of ethnicities in the graduating class of 2016 in that county,
while the bottom bar shows the proportions of ethnicities of the total
population of students who have dropped out in AY2015-2016 in each county
;
ods graphics on / height=8in;
proc sgplot data=JB2_final1 dattrmap=JB2_map;
    hbarparm category=County response=Grad_Percent /
        group=Ethnic_group grouporder=data groupdisplay=stack
        discreteoffset=-0.17 barwidth=.3 attrid=eth dataskin=pressed;
        /* order by counts of 1st bar */
    hbarparm category=County response=Drop_Percent /
        group=Ethnic_group grouporder=data groupdisplay=stack
        discreteoffset=0.17 barwidth=.3 attrid=eth dataskin=pressed;
        /* order by counts of 2nd bar */
    yaxis discreteorder=data label="County";
    xaxis grid values=(0 to 100 by 10) label="Percentage of Total with Group";
run;

title;
footnote;


*******************************************************************************;
* Research Question Analysis Starting Point;
*******************************************************************************;

title1
'Research Question: Within counties with a high increase in the ratio of dropouts, at which grade levels do we see the greatest number of dropouts in 2015-2016?'
;

title2
'Rationale: If we can identify the point at which most students drop out, we may be able to put additional resources into student retention shortly before that point.'
;

footnote1
'Here we see that in Inyo, Stanislaus, Tehama, and Lassen Counties, most of their students who drop out will do so while they are in 12th grade.'
;

footnote2
'Additionally, we can see that Inyo and Stanislaus Counties have a much larger number of students who drop out overall than the rest of the counties shown here.'
;

footnote3
'However, in San Francisco County, it appears that a majority of drop outs occur while students are in 11th grade; additional research may be required to determine the cause of this anomaly.'
;

*
Methodology: Using the original merged data set, create a subset and sum up
the dropouts by grade level for each county, and display the total number of
dropouts per grade level in a horizontal bar chart.

Limitations: It might make more sense to display this as a ratio rather than as
a raw number, and crosstab information using the ethnicity data from the
previous step may help illuminate trends that are present. Also, the absence of
total enrollment numbers in each county deprives the chart of some context.

Possible Follow-up Steps: Determine the most effective way to communicate the
results to a non-statistician audience, and add the data and sorting steps to
the data prep file. Also look into adding total enrollment to the chart for
additional context.
;

*
Generate a new data set using the final data set created in the data prep file
that contains only the county and number of dropouts for each grade level for
every school in AY2015-2016, keeping only the records from the counties we found
at the end of the first research question
;
proc sql;
    create table JB3_data as
    select County, D7, D8, D9, D10, D11, D12, DUS
    from grad_drop_merged_sorted
    where County
    in ('Inyo', 'Stanislaus', 'San Francisco', 'Lassen' ,'Tehama')
    and year = 1516
    ;
quit;

*
Use PROC MEANS to find the total number of students who dropped out in each
grade level by county in AY2015-2016, saving the results in new columns D#_sum
in which # represents the grade level
;
proc means
        noprint
        sum
        data=JB3_data
        nonobs
    ;
    var
        D7
        D8
        D9
        D10
        D11
        D12
        DUS
    ;
    class
        COUNTY
    ;
    output
        out=JB3_means1
        sum(D7 D8 D9 D10 D11 D12 DUS) =
            D7_sum
            D8_sum
            D9_sum
            D10_sum
            D11_sum
            D12_sum
            DUS_sum
    ;
;
run;

*
Use PROC SQL to extract only the county and totals of students who dropped out
from each grade level (note that DUS_sum, which contained the total number of
students from a grade other than 7-12 who dropped out, is dropped at this point
because the count for this variable for each county in question is 0)
;
proc sql;
    create table JB3_means2 as
    select County, D7_sum, D8_sum, D9_sum, D10_sum, D11_sum, D12_sum
    from JB3_means1
    where _TYPE_=1
    ;
quit;

*
Create a final data set that includes the name of the each county, the grade
level, and the number of students who dropped out from that grade level in that
county (Count), for use in the final bar chart
;
data JB3_final;
    set JB3_means2;
    keep
        County
        Grade
        Count
    ;
    retain
        County
        Grade
        Count
    ;
    Grade=7; Count=D7_sum; output;
    Grade=8; Count=D8_sum; output;
    Grade=9; Count=D9_sum; output;
    Grade=10; Count=D10_sum; output;
    Grade=11; Count=D11_sum; output;
    Grade=12; Count=D12_sum; output;
run;

*
Use PROC SGPLOT to create a bar chart using the previous data set in which we
see the total number of students who dropped out in AY2015-2016 for each county
and for each grade level
;
proc sgplot data=JB3_final;
    hbarparm category=County response=Count / dataskin=pressed
        group=Grade groupdisplay=cluster;
    xaxis grid offsetmin=0.1 label='2015-2016 Dropouts by County by Grade';
    x2axis offsetmax=0.95 display=(nolabel) valueattrs=(size=6);
    yaxis label='County';
run;

title;
footnote;
