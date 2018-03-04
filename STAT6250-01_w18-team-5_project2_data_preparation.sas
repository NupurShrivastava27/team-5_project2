*******************************************************************************;
**************** 80-character banner for column width reference ***************;
* (set window width to banner width to calibrate line length to 80 characters *;
*******************************************************************************;

*
[Dataset 1 Name] grad1415

[Dataset Description] Graduates by Ethnicity and School, 2014-15

[Experimental Unit Description] Data for graduates of high schools in California
in AY2014-2015 by ethnicity and school

[Number of Observations] 2490

[Number of Features] 15

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2014-15&cCat=GradEth&cPage=filesgrad.asp,
downloaded and then converted to xls format

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgrad09.asp

[Unique ID Schema] Column "CDS_CODE" uniquely identifies each school in
California that produced graduates in 2015.

--

[Dataset 2 Name] grad1516

[Dataset Description] Graduates by Ethnicity and School, 2015-16

[Experimental Unit Description] Data for graduates of high schools in California
in AY2015-2016 by ethnicity and school

[Number of Observations] 2521

[Number of Features] 15

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2015-16&cCat=GradEth&cPage=filesgrad.asp,
downloaded and then converted to xls format

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsgrad09.asp

[Unique ID Schema] Column "CDS_CODE" uniquely identifies each school in
California that produced graduates in 2016.

--

[Dataset 3 Name] dropouts1415

[Dataset Description] Dropouts by Race & Gender, 2014-2015

[Experimental Unit Description] Data for dropouts from junior high and high
schools in California in AY2014-2015 by race, gender, and school

[Number of Observations] 58,875

[Number of Features] 20

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2014-15&cCat=Dropouts&cPage=filesdropouts,
downloaded and then converted to xls format

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsdropouts.asp

[Unique ID Schema] The CDS_CODE, ETHNIC, and GENDER columns comprise a composite
 key that uniquely identifies groups by school, ethnic background, and gender.

--

[Dataset 4 Name] dropouts1516

[Dataset Description] Dropouts by Race & Gender, 2015-2016

[Experimental Unit Description] Data for dropouts from junior high and high
schools in California in AY2015-2016 by race, gender, and school

[Number of Observations] 59,316

[Number of Features] 20

[Data Source] http://dq.cde.ca.gov/dataquest/dlfile/dlfile.aspx?cLevel=School&cYear=2015-16&cCat=Dropouts&cPage=filesdropouts,
downloaded and then converted to xls format

[Data Dictionary] https://www.cde.ca.gov/ds/sd/sd/fsdropouts.asp

[Unique ID Schema] The CDS_CODE, ETHNIC, and GENDER columns comprise a composite
key that uniquely identifies groups by school, ethnic background, and gender.
;

* environmental setup;

* create output formats;

* setup environmental parameters;

%let inputDataset1URL =
https://github.com/stat6250/team-5_project2/blob/master/data/grad1415.xls?raw=true
;
%let inputDataset1Type = xls;
%let inputDataset1DSN = grad1415_raw;

%let inputDataset2URL =
https://github.com/stat6250/team-5_project2/blob/master/data/grad1516.xls?raw=true
;
%let inputDataset2Type = xls;
%let inputDataset2DSN = grad1516_raw;

%let inputDataset3URL =
https://github.com/stat6250/team-5_project2/blob/master/data/dropouts1415.xls?raw=true
;
%let inputDataset3Type = xls;
%let inputDataset3DSN = dropouts1415_raw;

%let inputDataset4URL =
https://github.com/stat6250/team-5_project2/blob/master/data/dropouts1516.xls?raw=true
;
%let inputDataset4Type = xls;
%let inputDataset4DSN = dropouts1516_raw;


* load raw datasets over the wire, if they doesn't already exist;
%macro loadDataIfNotAlreadyAvailable(dsn,url,filetype);
    %put &=dsn;
    %put &=url;
    %put &=filetype;
    %if
        %sysfunc(exist(&dsn.)) = 0
    %then
        %do;
            %put Loading dataset &dsn. over the wire now...;
            filename tempfile "%sysfunc(getoption(work))/tempfile.xlsx";
            proc http
                method="get"
                url="&url."
                out=tempfile
                ;
            run;
            proc import
                file=tempfile
                out=&dsn.
                dbms=&filetype.;
            run;
            filename tempfile clear;
        %end;
    %else
        %do;
            %put Dataset &dsn. already exists. Please delete and try again.;
        %end;
%mend;
%loadDataIfNotAlreadyAvailable(
    &inputDataset1DSN.,
    &inputDataset1URL.,
    &inputDataset1Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset2DSN.,
    &inputDataset2URL.,
    &inputDataset2Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset3DSN.,
    &inputDataset3URL.,
    &inputDataset3Type.
)
%loadDataIfNotAlreadyAvailable(
    &inputDataset4DSN.,
    &inputDataset4URL.,
    &inputDataset4Type.
)


* sort and check raw data sets for duplicates with respect to primary keys,
  data contains no blank rows so no steps to remove blanks is needed;
proc sort
        nodupkey
        data=grad1415_raw
        out=grad1415_raw_sorted(where=(not(missing(CDS_CODE))))
    ;
    by
        CDS_CODE
    ;
run;
proc sort
        nodupkey
        data=grad1516_raw
        out=grad1516_raw_sorted(where=(not(missing(CDS_CODE))))
    ;
    by
        CDS_CODE
    ;
run;
proc sort
        nodupkey
        data=dropouts1415_raw
        out=dropouts1415_raw_sorted(where=(not(missing(CDS_CODE))))
    ;
    by
        CDS_CODE
        ETHNIC
        descending GENDER
    ;
run;
proc sort
        nodupkey
        data=dropouts1516_raw
        out=dropouts1516_raw_sorted(where=(not(missing(CDS_CODE))))
    ;
    by
        CDS_CODE
        ETHNIC
        descending GENDER
    ;
run;

*
Use PROC MEANS to generate a data set containing the total number of graduates
from each county in AY2014-2015 (TOTAL_sum), as well as the total number of
schools in each county (_FREQ_)
;
proc means
        noprint
        sum
        data = grad1415_raw_sorted
        nonobs
    ;
    var TOTAL
    ;
    by COUNTY
    ;
    output
        out=grad1415_means
        sum(TOTAL) = TOTAL_sum
    ;
run;

* Sort the data set created in the previous step by county;
proc sort data=grad1415_means out=grad1415_means_sorted;
    by COUNTY;
run;

*
Merge the data set containing graduations by school and total graduations by
county in AY2014-2015 so that each row in the new data set contains graduation
statistics for an individual school as well as the total number of graduations
in the county in which that school is located
;
data grad1415_final;
    merge
        grad1415_raw_sorted
        grad1415_means_sorted
    ;
    by COUNTY;
run;

*
Use PROC MEANS to generate a data set containing the total number of graduates
from each county in AY2015-2016 (TOTAL_sum), as well as the total number of
schools in each county (_FREQ_)
;
proc means
        noprint
        sum
        data = grad1516_raw_sorted
        nonobs
    ;
    var TOTAL
    ;
    by COUNTY
    ;
    output
        out=grad1516_means
        sum(TOTAL) = TOTAL_sum
    ;
run;

* Sort the data set created in the previous step by county;
proc sort data=grad1516_means out=grad1516_means_sorted;
    by COUNTY;
run;

*
Merge the data set containing graduations by school and total graduations by
county in AY2015-2016 so that each row in the new data set contains graduation
statistics for an individual school as well as the total number of graduations
in the county in which that school is located
;
data grad1516_final;
    merge
        grad1516_raw_sorted
        grad1516_means_sorted
    ;
    by COUNTY;
run;

*
Vertically join the two final data sets containing graduation records for use
in analysis steps
;
data grad_all;
    set
        grad1415_final
        grad1516_final
    ;
run;

*
Combine data sets for dropout and graduation data for AY2014-2015 horizontally
;
data all1415;
    merge
        dropouts1415_raw_sorted
        grad1415_final;
    by CDS_CODE;
run;

*
Combine data sets for dropout and graduation data for AY2015-2016 horizontally
;
data all1516;
    merge
        dropouts1516_raw_sorted
        grad1516_final;
    by CDS_CODE;
run;

*
Finally, combine all merged data into a single data set containing dropout and
graduation data for both years
;
data grad_drop_merged;
    set all1415 all1516;
run;

*
Sort the resulting combined data set by year, CDS code, ethnic code, and gender,
excluding any records in which the CDS code is missing
;
proc sort
        nodupkey
        data=grad_drop_merged
        out=grad_drop_merged_sorted(where=(not(missing(CDS_CODE))))
    ;
    by
        YEAR
        CDS_CODE
        ETHNIC
        descending GENDER
    ;
run;


* Begin data steps for JB analysis file;

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

* End data steps for JB analysis file;

* Begin data steps for NS analysis file;

*
First, after combining all datasets during data preparation, use sum function 
in sql procedure to have the totals of individual 9th,10th, 11th and 12th 
graders from dataset Grad_drop_merged_sorted for AY 2014-2015 and 2015-2016. 
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

*
Then populate the correct values using array function to provide table lookups 
in the temprary dataset
;
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

*
Merging two datasets from array into new enroll_years dataset
;
data enroll_years; 
    merge 
        enrolls_drops_years  
        enrolls_prep
    ; 
run; 

*
Merging two datasets from array into new drop_years dataset
;
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

*
First, use sum function to the columns 'ETOT' and 'DTOT' 
in mean procedure from sorted datset 'grad_drop_merged_sorted' for 
AY 2014-2015-2016
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

*
After combining grads1415 and grads1516 during data preparation,  
first, use sum function in sql procedure in order to calculate percentage using
columns HISPANIC, AM_IND, ASIAN, PAC_ISLD, FILIPINO, AFRICAN_AM, WHITE, 
TWO_MORE_RACES, NOT_REPORTED and TOTAL from GRAD1415_RAW and GRAD1516_RAW 
datasets.
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

*
Created new dataset with raw data with the input statement.Then used arrays 
function to provide table lookups and sort the final temporary dataset to 
print in a tabular format.
;
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
        Hisp--NotReported
    ; 
    do I=1 to 9
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

*
Merging two datasets from array into new grad_ethnic_final1 dataset
;
data grad_ethnic_final1; 
    merge 
        grad_ethnic_cat
        grad_ethnic_value 
    ; 
run;

*
Merging two datasets from array into new grad_ethnic_final2 dataset
;
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

*
Use proc sort to create a temporary sorted table in descending by 
ethnic_2014 and ethnic_2015 and populate the final sorted observation
into Grad_ethnic_1416_sorted.
;
proc sort 
    data=Grad_ethnic_1416 
    out=Grad_ethnic_1416_sorted
    ;
    by descending
        ethnic_2014 
        ethnic_2015 
    ;
run;

*End data steps for NS analysis file;

*Begin data steps for WH analysis file;

*
Using proc sql, i calculated the sum of the column AFRICAN_AM and WHITE
then also calculate their percentage by using the total graduates number 
from GRAD1415_MEANS_SORTED data set.  I also set the percentage to have
2 decimal places.
; 
proc sql;
    create table african_white_grad_1415 as
        select 
            (sum(AFRICAN_AM)) as african_grad 
                label = "Total African American Grad 14-15", 
            (sum(WHITE)) as white_grad 
                label = "Total White Grad 14-15", 
            (sum(AFRICAN_AM) / (select (sum(TOTAL_sum)) from grad1415_means_sorted)) 
                label = "African American Grad % 14- 15" 
                    format = percent7.1,
            (sum(WHITE) / (select (sum(TOTAL_sum)) from grad1415_means_sorted)) 
                label = "White Grad % 14-15" 
                    format = percent7.1
    from
        grad1415_final
    ;    
quit;
proc sql;
    create table african_white_grad_1516 as
        select 
            (sum(AFRICAN_AM)) as african_grad 
                label = "Total African American Grad 15-16", 
            (sum(WHITE)) as white_grad 
                label = "Total White Grad 15-16", 
            (sum(AFRICAN_AM) / (select (sum(TOTAL_sum)) from grad1415_means_sorted)) 
                label = "African American Grad % 15-16" 
                    format = percent7.1,
            (sum(WHITE) / (select (sum(TOTAL_sum)) from grad1415_means_sorted)) 
                label = "White Grad % 15-16" 
                    format = percent7.1
    from
        grad1415_final
    ;    
quit;
data african_white_grad_1416;
    merge
        african_white_grad_1415
        african_white_grad_1516
    ;
run;

*
By using proc sql, i created a new table called E12B_1415 to contain the
total number of Grade 12 boys enrolled in the year 2014-2015.  I calculated
the total number of boy by using the sum formula from the dataset 
GRAD_DROP_MERGED_SORTED and set a condition where Gender is M and the year 
is 1415.
;
proc sql;
    create table E12B_1415 as
        select
            sum(E12) as tote_1415 
                label = "Total Number of Grade 12 Boy Enrolled in 2014-2015"
        from
            grad_drop_merged_sorted
        where
            GENDER='M' and
            YEAR = 1415
        ;
quit;

*
By using proc sql, i created a new table called E12B_1516 to contain the
total number of Grade 12 boys enrolled in the year 2015-2016.  I calculated
the total number of boy by using the sum formula from the dataset 
GRAD_DROP_MERGED_SORTED and set a condition where Gender is M and the year 
is 1516.
;
proc sql;
    create table E12B_1516 as
        select 
            sum(E12) as tote_1516 
                label = "Total Number of Grade 12 Boy Enrolled in 2015-2016"
        from 
            grad_drop_merged_sorted
        where 
            GENDER = 'M' and 
            YEAR = 1516
        ;
quit;

*End data steps for WH analysis file;
