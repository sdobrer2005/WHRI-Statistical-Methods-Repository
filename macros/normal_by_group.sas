

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

  Processing steps:
    1. Sort input data by GROUP (required for BY-processing in PROC UNIVARIATE).
    2. Use PROC UNIVARIATE with NORMAL option to run:
         - Shapiro–Wilk
         - Anderson–Darling
         - Kolmogorov–Smirnov
         - Cramér–von Mises
       Capture all tests into OUTTEST.
    3. Build OUTSW summary dataset:
         - Keeps only GROUP, Test, Statistic, p-value, and a Decision column
           ("Reject normality" vs "Do not reject normality").
         - Adds Normal_Flag (1 = do not reject, 0 = reject, . = missing).
    4. Print OUTSW with labels for quick review.

  Outputs:
    OUTTEST    One row per test per group with statistics and p-values.
    OUTSW      Simplified summary with decision rule applied at α=ALPHA.
    Listing    Prints OUTSW to the current output destination.

  Notes:
    - This version produces *no plots*. Figures (histograms, QQ plots, etc.)
      should be generated outside this macro for maximum flexibility.
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

  /*========================
    Internal macro variables
   ========================*/
  %local  _outtest _outsw _alphalabel;

  /* If caller did not pass OUTTEST/OUTSW, create sensible defaults that include &var name */
  %let _outtest = %sysfunc(coalescec(&outtest, work._norm_tests_&var));
  %let _outsw   = %sysfunc(coalescec(&outsw,   work._norm_summary_&var));

  /* Store alpha both as numeric and as a formatted string for titles/labels */
  %let _alphalabel = %sysfunc(putn(&alpha, best.));

  /*=========================================================================
    BY-processing requires sorted data. Create a sorted working copy to avoid
    side effects on the input dataset and to make behavior deterministic.
    Note: If GROUP has missing values, they will form their own BY group.
          If you want to exclude missing, filter here (e.g., where=(not missing(&group))).
   =========================================================================*/
  proc sort data=&data out=_norm_src_;
    by &group;
  run;

  /*=========================================================================================
    1) Gather ALL normality tests by group
       PROC UNIVARIATE with NORMAL option produces:
         - TestsForNormality (Shapiro-Wilk, Anderson-Darling, Kolmogorov-Smirnov, C-von Mises)
         - Moments, BasicMeasures (requested via ODS SELECT for the listing; not captured by default)
       We capture TestsForNormality to &outtest for downstream programmatic use.
    =========================================================================================*/
  proc univariate data=_norm_src_ normal;
   var &var;           

    /* Limit the listing to commonly useful panels (keeps the Results Viewer clean) */
    ods select Moments BasicMeasures TestsForNormality;

    /* Programmatic capture of TestsForNormality in a long/stacked format */
    ods output TestsForNormality = &_outtest;
	where group="%scan(&strata.,&i.)";
  run;

  /*=========================================================================================
    2) Build a summary table over ALL tests with an Î±-based decision rule.
       Interpretation:
        - If pValue < alpha  ’ "Reject normality"
        - Else               ’ "Do not reject normality"
       Normal_Flag is a convenience indicator: 1 = do not reject, 0 = reject, .=missing p
       Keep only essential columns for clean reporting and downstream merges/joins.
    =========================================================================================*/
  data &_outsw;
    set &_outtest;

    length Conclusion $50 Normal_Flag 8.;

    /* Handle potential missing p-values (rare, but safe-guard the logic) */
    if missing(pValue) then do;
      Conclusion = 'p-value missing';
      Normal_Flag = .;
    end;

    else if pValue < &alpha then do;
      Conclusion = cats('Reject normality');
      Normal_Flag = 0;
    end;

    else do;
      Conclusion = cats('Do not reject normality');
      Normal_Flag = 1;
    end;

    /* Retain only the most useful columns for summaries/reports */
    keep &group Test Statistic pValue Conclusion Normal_Flag;

    /* Human-friendly labels for PROC PRINT / ODS output */
    label
      &group      = "Group"
      Test        = "Test"
      Statistic   = "Statistic/W"
      pValue      = "p-value"
      Conclusion  = "Decision"
      Normal_Flag = "Normal (1=yes)";
  run;

  /* Lightweight listing of the summary table for quick visual inspection */
  title "Normality Tests by &group for &var ";
  proc print data=&_outsw noobs label;
  run;
  title;

%mend normal_by_group;
