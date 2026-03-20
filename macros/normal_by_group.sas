/*=============================================================================================
  Macro:     NORMAL_BY_GROUP
  Purpose:   Run normality tests for one numeric variable within groups, and return both
             the full set of test results and a simplified summary with decision flags.

  Inputs:
    DATA=      Input dataset.
    VAR=       Numeric variable to test for normality.
    GROUP=     Categorical grouping variable (observations are split by this).
    ALPHA=     Significance level (default = 0.05). Used to decide "Reject normality" vs.
               "Do not reject normality".
    OUTTEST=   (Optional) Output dataset with all test results (long format with one row
               per test per group). Defaults to WORK._NORM_TESTS_<var>.
    OUTSW=     (Optional) Output dataset with summary table and decision rule applied.
               Defaults to WORK._NORM_SUMMARY_<var>.

  Outputs:
    OUTTEST    One row per test per group with statistics and p-values.
    OUTSW      Simplified summary with decision rule applied at α=ALPHA.
    Listing    Prints OUTSW to the current output destination.

  Notes:
    - All normality tests are retained in the output dataset.
    - Printed PROC UNIVARIATE output is suppressed to keep the report compact.
    - Missing GROUP values are treated as their own group level unless filtered.
=============================================================================================*/

%macro normal_by_group(
  data=,
  var=,
  group=,
  alpha=0.05,
  outtest=,
  outsw=
);

  %local _outtest _outsw _alphalabel;

  %let _outtest    = %sysfunc(coalescec(&outtest, work._norm_tests_&var));
  %let _outsw      = %sysfunc(coalescec(&outsw,   work._norm_summary_&var));
  %let _alphalabel = %sysfunc(putn(&alpha, best.));

  /* Sort data for BY-processing */
  proc sort data=&data out=_norm_src_;
    by &group;
  run;

  /* Run normality tests by group and capture output without printing full PROC UNIVARIATE tables */
  ods exclude all;
  proc univariate data=_norm_src_ normal;
    by &group;
    var &var;
    ods output TestsForNormality=&_outtest;
  run;
  ods exclude none;

  /* Build summary table */
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
      Conclusion  = "Decision at alpha=&_alphalabel"
      Normal_Flag = "Do Not Reject (1=yes)";
  run;

  title "Normality Tests by &group for &var";
  proc print data=&_outsw noobs label;
  run;
  title;

%mend normal_by_group;
