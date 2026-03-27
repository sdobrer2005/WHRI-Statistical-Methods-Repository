/*============================================================================================+
  Macro:     TO_RUN
  Purpose:   Loop over a list of numeric variables, run normality tests within groups using
             %NORMAL_BY_GROUP, and then produce a Word report with both the summary tables
             and diagnostic plots (histogram + Q–Q plot).

  Workflow:
    1. For each variable in &NORM:
         - Calls %NORMAL_BY_GROUP with plots disabled.
         - Creates OUTTEST and OUTSW datasets for programmatic results.
    2. Deletes the raw TestsForNormality datasets (Norm_<var>) to keep only
       the cleaner summaries (Norm_sum_<var>).
    3. Opens a Word destination (landscape layout).
    4. For each variable:
         - Prints the Norm_sum_<var> summary table (with smaller fonts).
         - Derives the matching group level from &STRATA (positionally).
         - Runs PROC UNIVARIATE twice with WHERE=(&group="&level"):
              * Histogram of the variable for that group (with normal overlay).
              * Q–Q plot of the variable for that group (with normal reference).
         - Uses ODS SELECT so only the figures print, not the full UNIVARIATE output.
    5. Closes the Word destination.

  Inputs:
    &NORM     Space-separated list of numeric variables to test.
    &GROUP    Categorical grouping variable (e.g., Species).
    &STRATA   Space-separated list of group values to align with variables
              (e.g., Setosa Versicolor Virginica).
    &L        Number of variables in &NORM (set outside this macro).
    &OUTDOC   Path to the Word document where results will be written.

  Outputs:
    - Word file (&OUTDOC) with, per variable:
        * A formatted summary table of normality tests.
        * A histogram (per variable/group).
        * A Q–Q plot (per variable/group).
    - WORK datasets Norm_sum_<var> (kept) with decision summaries.

  Notes:
    - This version expects that &STRATA and &NORM are aligned in length and order.
      Example: the i-th variable in &NORM is paired with the i-th group in &STRATA.
    - Each variable’s results appear on a separate page in the Word file.
    - Figures are produced one per group (not combined across groups).
===========================================================================;



%macro to_run_norm;
/* 1) run normality macro for each variable (no plots here to avoid duplicates) */
%do i=1 %to &l;
  %normal_by_group(
    data=work.iris,
    var=%scan(&norm,&i),         /* fixed: removed stray semicolon */
    group=&group,                /* group is the VARIABLE name */
    alpha=0.05,
    outtest=norm_%scan(&norm,&i),
    outsw=norm_sum_%scan(&norm,&i)
  );
%end;

/* 2) delete raw TestsForNormality tables; keep norm_sum_* */
%do i=1 %to &l;
  proc datasets library=work nolist;
    delete Norm_%scan(&norm,&i);
  quit;
%end;

options orientation=landscape;
ods graphics on;

ods word file="&outdoc" style=journal startpage=now;
title "Normality diagnostics by &group";
footnote j=l "Generated: &sysdate9 at &systime";

%do i=1 %to &l;
  %let var=%scan(&norm,&i);

  *Summary table (smaller font);
  title "Normality Tests by &group for &var";
  proc print data=norm_sum_&var noobs
             style(header)=[fontsize=8pt]
             style(data)=[fontsize=8pt];
  run;

    %let level=%scan(&strata,&i);
	*Hisogram;
    ods select Histogram;
    title "Histogram of &var for &group=&level";
    proc univariate data=work.iris(where=(&group="&level")) normal;
      var &var;
      histogram &var / normal kernel;
    run;

    * Q–Q plot ;
    ods select QQPlot;
    title "Q–Q Plot of &var for &group=&level";
    proc univariate data=work.iris(where=(&group="&level")) normal;
      var &var;
      qqplot &var / normal(mu=est sigma=est);
    run;

%end;    

ods word close;
title; footnote;

%mend to_run_norm;
