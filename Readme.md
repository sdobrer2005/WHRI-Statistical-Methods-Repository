
# Independent Two-Sample t-test

This branch presents a structured implementation of the independent two-sample t-test using SAS. It serves as both a methodological reference and a teaching example, illustrating key statistical concepts, assumptions, and interpretation within a reproducible analytical framework.

---

## Overview

The independent two-sample t-test is used to compare the means of a continuous outcome between two independent groups. It evaluates whether the observed difference in means is greater than would be expected by chance under the null hypothesis.

---

## Statistical Formulation

Let:

- \( \mu_1 \) and \( \mu_2 \) denote the population means of the two groups  

The hypotheses are:

- **Null hypothesis (H₀):** \( \mu_1 = \mu_2 \)  
- **Alternative hypothesis (H₁):** \( \mu_1 \neq \mu_2 \)  

The test statistic is based on the standardized difference between group means, accounting for within-group variability.

---

## Assumptions

The validity of the independent two-sample t-test relies on the following assumptions:

### 1. Independence
Observations are independent within and between groups.

### 2. Normality
The outcome variable is approximately normally distributed within each group.

Assessment includes:
- Skewness and kurtosis  
- Formal tests (Shapiro–Wilk, Kolmogorov–Smirnov, Cramer–von Mises, Anderson–Darling)  

### 3. Homogeneity of Variance
The variances of the two groups are equal when using the pooled t-test.

If this assumption is violated, the Welch t-test provides a robust alternative.

---

## Normality Assessment

Normality is evaluated using both descriptive and formal approaches:

- **Descriptive measures:**  
  - Skewness (symmetry of distribution)  
  - Kurtosis (tail behavior; SAS reports excess kurtosis where 0 indicates normal-like tails)

- **Statistical tests:**  
  - Shapiro–Wilk (primary test)  
  - Kolmogorov–Smirnov  
  - Cramer–von Mises  
  - Anderson–Darling  

**Interpretation:**
- p-value > 0.05 → no evidence against normality  
- p-value ≤ 0.05 → evidence of deviation from normality  

Given moderate sample sizes (n ≈ 50 per group), the t-test is generally robust to mild deviations from normality.

---

## Variance Assessment

Equality of variances is assessed prior to selecting the appropriate form of the test:

- Equal variances → pooled t-test  
- Unequal variances → Welch t-test  

---

## Interpretation of Results

The analysis provides:

- Group means and measures of variability  
- Assessment of distributional assumptions  
- Test statistic and p-value  
- Confidence intervals for the difference in means  

A statistically significant result indicates evidence of a difference in means between the two groups. Interpretation should consider both statistical significance and practical relevance.

---

## Application

This example uses the IRIS dataset to demonstrate the implementation and interpretation of the independent two-sample t-test in a controlled, reproducible setting.

---

## Purpose

This branch serves as:

- A teaching resource for understanding the independent t-test  
- A template for standardized analytical workflows  
- A reference for assumption assessment and interpretation  

---

## Software

All analyses are conducted using SAS.
