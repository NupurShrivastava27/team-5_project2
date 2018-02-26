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
