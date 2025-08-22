/*===========================================================================================
 | Macro:    NORMAL_BY_GROUP
 | Developed: Sabina Dobrere, Senior Statistician, P.Stat
 | Date: August 22 2025
 | Purpose:  Run within-group normality diagnostics for a numeric variable.
 |           - Extracts ALL normality tests from PROC UNIVARIATE (SW, AD, KS, CVM, etc.)
 |           - Builds a tidy summary table with an α-based decision + Normal_Flag (0/1)
 |           - Optionally renders histograms (with Normal + Kernel overlays) and Q–Q plots
 |
 | Typical use-cases:
 |   • Pre-checks for two-sample parametric tests (e.g., t-test) by group
 |   • Model assumption diagnostics, teaching materials, reproducible reports
 |
 | Inputs (parameters):
 |   data=    : Input dataset (e.g., work.iris)
 |   var=     : Numeric variable to assess (e.g., PetalLength)
 |   group=   : Grouping variable (categorical). Normality is checked separately within each level
 |   alpha=   : Significance level for decision rule. Default 0.05
 |   plots=   : Y/N. If Y, produces histogram + Q–Q plots per group
 |   outtest= : Output dataset (long format) capturing ALL TestsForNormality rows by group
 |              If omitted, defaults to work._norm_tests_<var>
 |   outsw=   : Output dataset (summary) with decision rule & Normal_Flag for ALL tests by group
 |              If omitted, defaults to work._norm_summary_<var>
 |
 | Outputs:
 |   • &outtest  : Long table with columns like &group, Test, Statistic, pValue (one row/test/group)
 |   • &outsw    : Summary table with decision text and Normal_Flag (1=do not reject, 0=reject)
 |   • Plots     : If plots=Y, per-group histogram (Normal+Kernel overlays) and Q–Q plots
 |
 | Implementation notes:
 |   • Requires BY-processing → data are sorted by &group into a temp view (_norm_src_)
 |   • ODS OUTPUT captures “TestsForNormality” into &outtest for programmatic use
 |   • α-based decision is a convenience rule; always interpret alongside plots and context
 |   • For very small n, Shapiro–Wilk is generally preferred; for large n, tests are sensitive
 |   • Consider variance checks separately (e.g., Levene) when planning parametric tests
 |
 | Versioning & reproducibility:
 |   • Turn on macro trace if needed: options mprint mlogic symbolgen;
 |   • Wrap calls with ODS WORD/RTF/HTML to create shareable reports
 |
 | Example:
 | 
 |   %normal_by_group(data=work.iris, var=PetalLength, group=Species,
 |                    alpha=0.05, plots=Y,
 |                    outtest=work.iris_norm_tests,
 |                    outsw=work.iris_norm_summary);
 *==========================================================================================*/
%macro normal_by_group(
  data=,
  var=,
  group=,
  alpha=0.05,
  plots=Y,
  outtest=,
  outsw=
);

  /*========================
    Internal macro variables
   ========================*/
  %local _plots _outtest _outsw _alphalabel;

  /* Normalize PLOTS flag to upper-case Y/N for simple comparisons later */
  %let _plots   = %upcase(&plots);

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

  /* Enable ODS Graphics for histograms and Q–Q plots; safe to call regardless of PLOTS flag */
  ods graphics on;

  /*=========================================================================================
    1) Gather ALL normality tests by group
       PROC UNIVARIATE with NORMAL option produces:
         - TestsForNormality (Shapiro–Wilk, Anderson–Darling, Kolmogorov–Smirnov, C-von Mises)
         - Moments, BasicMeasures (requested via ODS SELECT for the listing; not captured by default)
       We capture TestsForNormality to &outtest for downstream programmatic use.
    =========================================================================================*/
  proc univariate data=_norm_src_ normal;
    by &group;          /* run per group */
    var &var;           /* the numeric variable being assessed */

    /* Limit the listing to commonly useful panels (keeps the Results Viewer clean) */
    ods select Moments BasicMeasures TestsForNormality;

    /* Programmatic capture of “TestsForNormality” in a long/stacked format */
    ods output TestsForNormality = &_outtest;
  run;

  /*=========================================================================================
    2) Build a summary table over ALL tests with an α-based decision rule.
       Interpretation:
        - If pValue < alpha  → "Reject normality at α="
        - Else               → "Do not reject normality at α="
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
      Conclusion = cats('Reject normality at α=', "&_alphalabel");
      Normal_Flag = 0;
    end;

    else do;
      Conclusion = cats('Do not reject normality at α=', "&_alphalabel");
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
  title "Normality Tests by &group for &var (α=&_alphalabel)";
  proc print data=&_outsw noobs label;
  run;
  title;

  /*=========================================================================================
    3) Visualization (optional): histogram + normal overlay + kernel, and Q–Q plot per group
       Rationale:
        - Statistical tests alone can be misleading (e.g., large-n sensitivity).
        - Plots help identify skewness, heavy tails, outliers, or multi-modality.
       Implementation details:
        - We reuse the sorted _norm_src_ copy for consistent BY-processing.
        - HISTOGRAM statement overlays Normal and Kernel density for context.
        - QQPLOT uses ML estimates (mu=est sigma=est) by default for each group.
    =========================================================================================*/
  %if &_plots = Y %then %do;

    title "Histogram of &var with Normal Overlay by &group";
    proc univariate data=_norm_src_ normal;
      by &group;
      var &var;

      /* Histogram with both Normal fit and Kernel density overlay for shape comparison */
      histogram &var / normal kernel;

      /* Quick descriptive inset for context (n, mean, sd, skewness, kurtosis) */
      inset n mean std skewness kurtosis / pos=ne header='Descriptives';
    run;

    title "Q–Q Plot of &var vs Normal by &group";
    proc univariate data=_norm_src_ normal;
      by &group;
      var &var;

      /* Q–Q plot against Normal; MU and SIGMA are estimated from the data in each group */
      qqplot &var / normal(mu=est sigma=est);
    run;
    title;

  %end;

  /* Close ODS Graphics scope for this macro run */
  ods graphics off;

%mend normal_by_group;
