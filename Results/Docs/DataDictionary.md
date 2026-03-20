
## Data Dictionary: Skewness and Kurtosis

### Skewness

**Definition:**  
Skewness measures the degree of asymmetry of a distribution around its mean.

**Interpretation:**
- Skewness ≈ 0 → approximately symmetric distribution  
- Skewness > 0 → right-skewed (longer tail to the right)  
- Skewness < 0 → left-skewed (longer tail to the left)  

**Guidelines (rule of thumb):**
- |Skewness| < 0.5 → approximately symmetric  
- 0.5 ≤ |Skewness| < 1 → moderate skewness  
- |Skewness| ≥ 1 → substantial skewness  

**Relevance:**  
Skewness helps assess whether the normality assumption is reasonable for parametric tests such as the t-test.

---

### Kurtosis

**Definition:**  
Kurtosis measures the heaviness of the tails of a distribution relative to a normal distribution.

**Interpretation:**
- Kurtosis ≈ 0 → similar to normal distribution (mesokurtic)  
- Kurtosis > 0 → heavier tails (leptokurtic - distribution with heavier tails than normal)  
- Kurtosis < 0 → lighter tails (platykurtic - distribution with lighter tails than normal)  

**Guidelines (rule of thumb):**
- |Kurtosis| < 1 → approximately normal tail behavior  
- Kurtosis > 1 → heavier tails, potential outliers  
- Kurtosis < −1 → lighter tails  

**Relevance:**  
Kurtosis provides information about the presence of extreme values and helps evaluate whether deviations from normality may impact statistical inference.

---

### Notes

- These are descriptive measures and should be interpreted alongside formal tests of normality.  
- Small deviations from zero are common and do not necessarily invalidate parametric methods, particularly with moderate sample sizes.
