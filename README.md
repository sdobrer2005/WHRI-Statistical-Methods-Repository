Example-in-SAS
This rasperatory includes codes in SAS that will help you to perform your own analysis on specific data set

The raspiratory includes sample data sets - publicly available - and detailed code with instructions for all the steps. Most of the programs will include reusable macros that can be applied of your personal data sets.

I. First project includes of implimentation of t-test for two independent samples using publicly availabe data set IRIS

Data set description: The SAS IRIS dataset is a classic example dataset (originally Fisher’s iris data, 1936) that is widely used for demonstrating statistical methods, classification, and visualization. Here’s a summary:

Structure

Number of observations: 150 Number of variables: 5

Variables SepalLength (numeric, cm) SepalWidth (numeric, cm) PetalLength (numeric, cm) PetalWidth (numeric, cm)

Species (categorical: Setosa, Versicolor, Virginica)

Key Features Each species has 50 observations. Setosa is linearly separable from the other two species. Versicolor and Virginica overlap somewhat, making them useful for demonstrating classification methods. Petal length and width provide stronger discrimination between species compared to sepal measurements.

The most important part of t-test use is assumptions validations

Independence of observations: The two groups are independent (no overlap in subjects, no repeated measures). Observations within each group are independent.

Scale of measurement: The dependent variable is continuous (interval or ratio).

Normality: Each group’s outcome variable is approximately normally distributed. Assessed via plots (histogram, Q–Q plot) or tests (Shapiro–Wilk, Kolmogorov–Smirnov). Mild deviations are usually fine, especially if sample sizes are moderate/large (Central Limit Theorem).

Homogeneity of variances: Note the t-test macro would look for the output of the F-test and will choose appropriate p-value from the t-test output. The population variances of the two groups are equal. Test with Levene’s test or F-test. If unequal → use Welch’s t-test, which relaxes this assumption.
