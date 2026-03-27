/*=============================================================================================
  Macro:     FIGURES_BY_GROUP
  Purpose:   Generate distribution figures by group:
             - Histogram
             - Kernel density
             - Normal density
             - Q-Q plot
=============================================================================================*/

%macro figures_by_group(
  data=,
  var=,
  group=
);

  proc sort data=&data out=_fig_src_;
    by &group;
  run;

  ods graphics on / width=6in height=4in;

  title "Distribution Plots for &var by &group";
    ods select Histogram QQPlot;

  proc univariate data=_fig_src_ normal;
    by &group;
    var &var;

    histogram &var / normal kernel;
    qqplot &var / normal(mu=est sigma=est);
  run;

  title;
  ods graphics off;

%mend figures_by_group;
