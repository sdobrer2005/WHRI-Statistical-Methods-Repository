/*=============================================================================================
  Macro:     NORMAL_BY_GROUP
  Purpose:   Run normality tests for one numeric variable within groups and print either:
             1) original SAS raw output from PROC UNIVARIATE
             2) clean descriptive statistics table + clean normality summary table
             3) or both

  Inputs:
    DATA=      Input dataset.
    VAR=       Numeric variable to test for normality.
    GROUP=     Categorical grouping variable.
    ALPHA=     Significance level (default = 0.05).
    OUTTEST=   Optional output dataset with all normality tests.
    OUTSW=     Optional output dataset with summary decision table.
    OUTDESC=   Optional output dataset with descriptive statistics table.
    MODE=      RAW | CLEAN | ALL   (default = ALL)

  Outputs:
    OUTTEST    One row per test per group with statistics and p-values.
    OUTSW      Simplified summary with decision rule applied at α=ALPHA.
    OUTDESC    Descriptive statistics by group.
    Listing    Prints output according to MODE.
=============================================================================================*/

%macro normal_by_group(
  data=,
  var=,
  group=,
  alpha=0.05,
  outtest=,
  outsw=,
  outdesc=,
  mode=ALL
);

  %local _outtest _outsw _outdesc _alphalabel _mode;

  %let _outtest    = %sysfunc(coalescec(&outtest, work._norm_tests_&var));
  %let _outsw      = %sysfunc(coalescec(&outsw,   work._norm_summary_&var));
  %let _outdesc    = %sysfunc(coalescec(&outdesc, work._desc_&var));
  %let _alphalabel = %sysfunc(putn(&alpha, best.));
  %let _mode       = %upcase(&mode);

  /* Sort data for BY-processing */
  proc sort data=&data out=_norm_src_;
    by &group;
  run;

  /*========================================================
    Always create the test dataset
  ========================================================*/
  %if &_mode = RAW or &_mode = ALL %then %do;
    title "Raw SAS Output: PROC UNIVARIATE for &var by &group";

    proc univariate data=_norm_src_ normal;
      by &group;
      var &var;
      ods select Moments BasicMeasures TestsForNormality;
      ods output TestsForNormality=&_outtest;
    run;

    title;
  %end;
  %else %do;
    ods exclude all;
    proc univariate data=_norm_src_ normal;
      by &group;
      var &var;
      ods output TestsForNormality=&_outtest;
    run;
    ods exclude none;
  %end;

  /*========================================================
    Create clean normality summary dataset
  ========================================================*/
  data &_outsw;
    set &_outtest(rename=(Stat=Statistic));

    length Conclusion $50 Normal_Flag 8.;

    if missing(pValue) then do;
      Conclusion = 'p-value missing';
      Normal_Flag = .;
    end;
    else if pValue < &alpha then do;
      Conclusion = 'Reject normality';
      Normal_Flag = 0;
    end;
    else do;
      Conclusion = 'Do not reject normality';
      Normal_Flag = 1;
    end;

    keep &group Test Statistic pValue Conclusion Normal_Flag;

    label
      &group      = "Group"
      Test        = "Normality Test"
      Statistic   = "Test Statistic"
      pValue      = "p-value"
      Conclusion  = "Decision (alpha=&_alphalabel)"
      Normal_Flag = "Do Not Reject (1=yes)";
  run;

  /*========================================================
    Create descriptive statistics dataset
  ========================================================*/
  proc means data=_norm_src_ n mean std median min max q1 q3 noprint;
    by &group;
    var &var;
    output out=_desc_raw_
      n=N
      mean=Mean
      std=StdDev
      median=Median
      min=Min
      max=Max
      q1=Q1
      q3=Q3;
  run;

  data &_outdesc;
    set _desc_raw_(drop=_TYPE_ _FREQ_);

    IQR = Q3 - Q1;

    keep &group N Mean StdDev Median Min Max Q1 Q3 IQR;

    label
      &group = "Group"
      N      = "N"
      Mean   = "Mean"
      StdDev = "Std Dev"
      Median = "Median"
      Min    = "Min"
      Max    = "Max"
      Q1     = "Q1"
      Q3     = "Q3"
      IQR    = "IQR";
  run;

  /*========================================================
    Print clean output when requested
  ========================================================*/
  %if &_mode = CLEAN or &_mode = ALL %then %do;

    title "Descriptive Statistics by &group for &var";
    proc print data=&_outdesc noobs label;
    run;

    title "Normality Summary by &group for &var";
    proc print data=&_outsw noobs label;
    run;

    title;
  %end;

%mend normal_by_group;
