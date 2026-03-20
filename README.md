# WHRI Statistical Methods Repository

This repository establishes a standardized framework for the development, implementation, and documentation of statistical analyses within the Women’s Health Research Institute (WHRI). It is designed to support consistency, reproducibility, and methodological rigor across diverse research programs involving clinical, epidemiological, and administrative data.

---

## Analytical Framework

The repository reflects an integrated approach to the full analytical lifecycle, from data acquisition to interpretation and knowledge translation. Each method is structured as a self-contained analytical unit, ensuring that all components of the analysis are transparent, reproducible, and aligned with best practices in biostatistics and data governance.

This framework supports:
- Standardization of analytical workflows across projects  
- Clear documentation of assumptions, methods, and results  
- Reproducibility of statistical analyses  
- Scalability across multiple research domains and datasets  

---

## Standardization of Analysis

To ensure consistency and quality, all methods follow a common structure:

- `data/` – input datasets used in the analysis  
- `macros/` – SAS code and reusable analytical components  
- `Results/` – statistical outputs and structured interpretation  
- `docs/` – supporting documentation, including data definitions and methodological notes  

This standardized approach enables:
- Efficient onboarding of new analysts and collaborators  
- Reuse of validated analytical components  
- Consistent interpretation and reporting across studies  
- Alignment with data governance, documentation, and quality assurance practices  

---

## Scope and Application

The repository supports a wide range of analytical approaches, including descriptive statistics, hypothesis testing, regression modeling, and advanced methods applied to longitudinal, clinical, and population health data.

The initial implementation includes:
- Independent two-sample t-test  
  (see branch: `T-test-for-two-independent-samples`)

Additional methods will be developed and integrated following the same framework.

---

## Data Governance and Reproducibility

This repository aligns with principles of:
- Data integrity and quality assurance  
- Transparent and auditable analytical processes  
- Structured documentation across the data lifecycle  
- Responsible use of sensitive and linked data  

All analyses are designed to support reproducible research and consistent reporting standards.

---

## Purpose

This repository is intended to:
- Standardize statistical analysis practices within WHRI  
- Provide a reusable framework for analytical workflows  
- Support training and capacity building in applied biostatistics  
- Facilitate collaboration across multidisciplinary research teams  

---

## Software

All analyses are conducted using SAS.
R copy will be created to mathc the SAS analysis exactly
