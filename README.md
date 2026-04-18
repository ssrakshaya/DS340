# Moralized Language Predicts Hate Speech on Social Media
## Replication and Extension — DS 340W

Replication and extension of [Solovev & Pröllochs (2022)](https://doi.org/10.1093/pnasnexus/pgac281), which found that moralized language in social media posts predicts hate speech in replies. The original paper used a multilevel binomial regression (GLMM) on three Twitter datasets. This project replicates their findings and extends them with three alternative model specifications that relax different assumptions of the original model.

---

## Repository Structure

- **R Scripts/**
  - `Main.Rmd` — Primary analysis: BB, GAMM, GMERF models
  - `Supplements.Rmd` — Robustness checks replicating paper supplements
  - `utils.R` — Helper functions from parent paper
  - `split_data.R` — R data splitting script
- **Data/**
  - `df_politicians.csv` — Politicians dataset (335,698 tweets)
  - `df_newspeople.csv` — Newspeople dataset (307,820 tweets)
  - `df_activists.csv` — Activists dataset (47,716 tweets)
  - `split_output/` — Pre-split train/test/val CSV files (9 files)
  - `Graphs/` — Generated visualizations (PDF)
- **R Data/** — Saved model results, CV outputs, and confidence intervals

---

## Models

Three models extend the parent paper's binomial GLMM:

| Model | Description | Key extension |
|---|---|---|
| **BB** | Betabinomial mixed model | Relaxes binomial distributional assumption; handles overdispersion |
| **GAMM** | Generalized additive mixed model | Relaxes linearity assumption; models non-linear predictor effects |
| **GMERF** | Generalized mixed effects random forest | Relaxes both linearity and parametric assumptions; iterative EM algorithm |

---

## Running the Code on a New Machine

### Step 1 — Install R and RStudio
- Download R from https://cran.r-project.org/ (minimum version 4.1.0)
- Download RStudio from https://posit.co/download/rstudio-desktop/

### Step 2 — Download the repository
- Go to https://github.com/ssrakshaya/DS340
- Click the green **Code** button and select **Download ZIP**
- Extract the ZIP to a folder of your choice
- Note the full path to that folder

### Step 3 — Install required packages
- Open RStudio
- Open `R Scripts/install_packages.R`
- Run the entire script and wait for all packages to install
- All packages should show a checkmark when complete

### Step 4 — Set your project path
- Open `R Scripts/Main.Rmd` in RStudio
- Find the `paths` chunk near the top of the file
- Change `PROJECT_ROOT` to match where you extracted the repository:

**Windows:**
```r
PROJECT_ROOT <- "C:/Users/yourname/Downloads/DS340"
```

**Mac:**
```r
PROJECT_ROOT <- "/Users/yourname/Downloads/DS340"
```

This is the only line you need to change. All other paths are set automatically.

### Step 5 — Run the code

Run all chunks in `Main.Rmd` in order from top to bottom. The chunks are:

1. `setup` — loads all libraries
2. `paths` — sets file paths using your PROJECT_ROOT
3. `load-data` — loads all three datasets
4. `functions` — defines helper functions
5. `sample-for-dev` — **DEV_SAMPLE is set to 500 by default for quick verification**
6. `bb-fit` — fits Beta-Binomial model (~30 seconds on 500 rows)
7. `bb-cv` — runs BB cross-validation (~1 minute on 500 rows)
8. `gamm-fit` — fits GAMM (~60 seconds on 500 rows)
9. `gamm-cv` — runs GAMM cross-validation (~2 minutes on 500 rows)
10. `gmerf-function` — defines GMERF function
11. `gmerf-fit` — fits GMERF (~30 seconds on 500 rows)
12. `gmerf-cv-function` — defines GMERF CV function
13. `gmerf-cv-run` — runs GMERF cross-validation (~1 minute on 500 rows)
14. `model-comparison` — displays comparison table
15. `test-set` — runs test set evaluation
16. `overfitting-check` — compares test RMSE to CV RMSE across all models
17. `bb-99ci` — computes 99% confidence intervals for BB coefficients
18. `gamm-parametric` — extracts GAMM parametric coefficient table
19. Visualization chunks — generates all figures and saves to Graphs folder

> **Note:** Running on 500 rows verifies the code runs without errors but will not reproduce the reported results. Sample results will look different from the paper — this is expected.

---

After completing `Main.Rmd`, open `Supplements.Rmd` and update `PROJECT_ROOT` in the `paths` chunk to match your machine (same path as `Main.Rmd`). Then run all chunks in order from top to bottom. The chunks are:

1. `setup` — loads all libraries
2. `paths` — sets file paths using your PROJECT_ROOT
3. `load-data` — loads all three datasets
4. `helper-functions` — defines shared formulas and helper functions used across all robustness checks
5. `oos-r2-function` — defines out-of-sample R² evaluation function
6. `oos-r2-run` — runs OOS R² comparison across four model specifications (~2 minutes on 500 rows)
7. `xyz-function` — defines XYZ implausible model test function
8. `xyz-run` — fits main model and implausible XYZ model, compares AIC (~1 minute on 500 rows)
9. `source-hate-function` — defines source hate control model function
10. `source-hate-run` — fits model controlling for whether source tweet was hateful (~30 seconds on 500 rows)
11. `retweet-function` — defines retweet count control function
12. `retweet-run` — fits model controlling for retweet count (~30 seconds on 500 rows)
13. `likes-function` — defines like count control function
14. `likes-run` — fits model controlling for like count (~30 seconds on 500 rows)
15. `directed-generalised-function` — defines directed vs generalised hate speech function
16. `directed-generalised-run` — fits separate models for directed and generalised hate speech (~1 minute on 500 rows)
17. `proportions-function` — defines word proportions specification function
18. `proportions-run` — fits model using moral word proportions instead of counts (~30 seconds on 500 rows)
19. `binary-function` — defines binary moral words indicator function
20. `binary-run` — fits model using binary presence/absence indicators (~30 seconds on 500 rows)
21. `distinct-emotions-function` — defines positive/negative emotional words function
22. `distinct-emotions-run` — fits model separating emotional words by valence (~30 seconds on 500 rows)
23. `interactions-function` — defines interaction effects function
24. `interactions-run` — fits model with MoralWords × WordCount interaction terms (~30 seconds on 500 rows)
25. `robustness-summary` — prints consolidated summary of all robustness check results
26. `oos-r2-improvement-plot` — generates OOS R² improvement bar chart
27. `robustness-stability-plot` — generates MoralWords coefficient stability plot across all nine specifications

> **Note:** All robustness checks use `df_train_sample` so they will run quickly on 500 rows. Results will differ from the paper but the code will run without errors.

### Step 6 — Load saved results to verify reported findings

After running all chunks, paste the following into the R console to load the full pre-saved results and verify the numbers reported in the paper:

```r
rdataPath <- paste0(PROJECT_ROOT, "/R Data/")
load(paste0(rdataPath, "bb_models.RData"))
load(paste0(rdataPath, "bb_cv_results.RData"))
load(paste0(rdataPath, "gamm_cv_results.RData"))
load(paste0(rdataPath, "gmerf_cv_results.RData"))
gmerf_cv_results <- cv_results
load(paste0(rdataPath, "test_results.RData"))
load(paste0(rdataPath, "oos_r2_results.RData"))
load(paste0(rdataPath, "bb_99ci.RData"))
load(paste0(rdataPath, "gamm_parametric.RData"))
load(paste0(rdataPath, "source_hate_results.RData"))
load(paste0(rdataPath, "binary_results.RData"))
load(paste0(rdataPath, "proportions_results.RData"))
load(paste0(rdataPath, "distinct_emotions_results.RData"))
load(paste0(rdataPath, "interaction_results.RData"))
cat("All results loaded successfully.\n")
```

Then rerun the model comparison, test set, and visualization chunks to display the full reported results.

> **Note:** Large model objects (gamm_models, gmerf_models) are not included in this repository due to file size constraints. The pre-saved results files above contain all numerical outputs reported in the paper.

### Step 7 — Full reproduction (optional, ~15 hours)
To reproduce results from scratch on the full dataset, set `DEV_SAMPLE <- NULL` in the `sample-for-dev` chunk and rerun all model fitting and CV chunks. This will exactly reproduce all reported results.

---

## Key Results

All three models consistently replicate the parent paper's core finding that moralized language predicts hate speech across all three datasets:

| Dataset | MoralWords OR% (ours) | MoralWords OR% (paper) |
|---|---|---|
| Politicians | 11.62% | 10.76% |
| Newspeople | 13.61% | 14.70% |
| Activists | 19.12% | 16.48% |

Cross-validation RMSE is essentially identical across all three model specifications, confirming the finding is robust to modeling assumptions. The GAMM additionally reveals non-linear effects of moral language (EDF > 1 for MoralWords across all datasets) that the original linear model could not detect.

---

## Data

Data is from [Solovev & Pröllochs (2022)](https://osf.io/k4baq/) via the Open Science Framework. Pre-split CSV files are provided in `Data/split_output/` so data splitting does not need to be rerun. Splits were generated at the user level — all tweets from a given author are assigned to the same split — preventing data leakage through random effects.

---

## Citation

Solovev, K., & Pröllochs, N. (2022). Moralized language predicts hate speech on social media. *PNAS Nexus*, 2(1). https://doi.org/10.1093/pnasnexus/pgac281

---

## Authors

KS — Penn State University, DS 340W

