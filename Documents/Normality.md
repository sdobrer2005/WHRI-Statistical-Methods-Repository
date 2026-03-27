# 01. Normality Assessment

## Summary
The distribution of continuous variables (sepal length, sepal width, and petal length) was assessed within each species to evaluate the assumption of normality.

For each variable, descriptive statistics were calculated, including mean, standard deviation, median, interquartile range, and range. These measures were used to examine central tendency and variability within groups.

Formal tests of normality were conducted using the Shapiro–Wilk test. Additional tests available within the same framework (e.g., Kolmogorov–Smirnov, Cramér–von Mises, and Anderson–Darling) were also considered to provide a comprehensive assessment.

Graphical diagnostics were used to complement formal testing. Histograms with overlaid kernel and normal density curves were generated to evaluate the overall shape of the distributions. Quantile–quantile (Q–Q) plots were used to assess agreement between the observed data and the theoretical normal distribution.

Assessment of normality was based on the combined interpretation of descriptive statistics, formal test results, and graphical diagnostics.

## Overview

Assessment of normality is a fundamental step in the evaluation of continuous variables, particularly when parametric statistical methods are considered. The objective is to determine whether the observed data are consistent with a normal (Gaussian) distribution.

## Statistical Approach

Normality was evaluated using multiple complementary statistical tests that compare the empirical distribution of the data to the theoretical normal distribution. These tests capture different aspects of deviation, including overall fit, central tendency, and tail behavior.

The following classes of methods were applied:

### 1. Order Statistics–Based Method

- **Shapiro–Wilk Test**  
  Assesses normality by evaluating the correlation between ordered sample values and the corresponding expected values under a normal distribution. This test is particularly sensitive to general departures from normality and performs well in small to moderate sample sizes.

### 2. Empirical Distribution Function (EDF)–Based Methods

These methods are based on the comparison between the empirical cumulative distribution function (ECDF) and the cumulative distribution function (CDF) of the normal distribution.

- **Kolmogorov–Smirnov Test**  
  Quantifies the maximum absolute deviation between the ECDF and the theoretical CDF.

- **Cramér–von Mises Test**  
  Measures the integrated squared difference between the ECDF and the theoretical distribution across all values.

- **Anderson–Darling Test**  
  A modification of EDF-based methods that applies greater weight to deviations in the tails of the distribution.

## Decision Rule

For each test, statistical significance is evaluated using a predefined threshold:

- **Significance level (α) = 0.05**

Interpretation:

- **p-value < α** → evidence against normality  
- **p-value ≥ α** → insufficient evidence to reject normality  

To facilitate interpretation, results may also be expressed as:

- **1 = do not reject normality**  
- **0 = reject normality**

## Interpretation Strategy

Different normality tests are sensitive to different characteristics of the data:

- Central deviations (e.g., skewness, asymmetry)  
- Tail deviations (e.g., heavy or light tails)  
- Global distributional differences  

Accordingly, normality should be evaluated using all tests collectively, rather than relying on a single test.

Interpretation should consider:

- Consistency across multiple tests  
- Magnitude and pattern of deviations  
- Analytical context and downstream model assumptions  

## Considerations

Normality tests are inherently sensitive to sample size:

- In large samples, minor deviations may result in statistically significant findings  
- In small samples, meaningful deviations may not be detected  

Therefore, statistical test results should be interpreted alongside descriptive statistics and, where appropriate, graphical diagnostics.

## Additional Resources

Detailed theoretical background and implementation specifics for each test are available in standard statistical references and software documentation.
https://documentation.sas.com/doc/en/pgmsascdc/v_073/procstat/procstat_univariate_details53.htm

