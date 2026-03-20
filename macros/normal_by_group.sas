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

  %local _outtest _outsw _outdesc _alphalabel;

  %let _outtest    = %sysfunc(coalescec(&outtest, work._norm_tests_&var));
  %let _outsw      = %sysfunc(coalescec(&outsw,   work._norm_summary_&var));
  %let _outdesc    = %sysfunc(coalescec(&outdesc, work._desc_&var));
  %let _alphalabel = %sysfunc(putn(&alpha, best.));

  proc sort data=&data out=_norm_src_;
    by &group;
  run;

  /*========================
    RAW OUTPUT
  ========================*/
  %if &mode = ALL or &mode = RAW %then %do;

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

    /* still need dataset even if not printed */
    proc univariate data=_norm_src_ normal noprint;
      by &group;
      var &var;
      ods output TestsForNormality=&_outtest;
    run;

  %end;

  /*========================
    SUMMARY TABLE
  ========================*/
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
  run;

  /*========================
    DESCRIPTIVE TABLE
  ========================*/
  proc means data=_norm_src_ n mean std median min max q1 q3 noprint;
    by &group;
    var &var;
    output out=_desc_raw_
      n=N mean=Mean std=StdDev median=Median
      min=Min max=Max q1=Q1 q3=Q3;
  run;

  data &_outdesc;
    set _desc_raw_(drop=_TYPE_ _FREQ_);
    IQR = Q3 - Q1;
    keep &group N Mean StdDev Median Min Max Q1 Q3 IQR;
  run;

  /*========================
    CLEAN OUTPUT
  ========================*/
  %if &mode = ALL or &mode = CLEAN %then %do;

    title "Descriptive Statistics by &group for &var";
    proc print data=&_outdesc noobs;
    run;

    title "Normality Summary by &group for &var";
    proc print data=&_outsw noobs;
    run;

    title;

  %end;

%mend normal_by_group;
