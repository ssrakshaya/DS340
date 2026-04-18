# ============================================================================
# install_packages.R
# Run this script once on a new machine before running any other code.
# This installs all packages required for Main.Rmd and Supplements.Rmd
# ============================================================================

# Install dependencies that tidymodels commonly fails on first
dep_packages <- c(
  "Matrix",
  "Rcpp",
  "RcppArmadillo",
  "hardhat",
  "parsnip",
  "recipes",
  "rsample",
  "tune",
  "workflows",
  "yardstick",
  "dials",
  "GPfit",
  "lhs",
  "DiceDesign",
  "foreach",
  "iterators"
)

cat("Installing tidymodels dependencies first...\n")
new_deps <- dep_packages[!(dep_packages %in% installed.packages()[,"Package"])]
if (length(new_deps) > 0) {
  install.packages(new_deps, dependencies = TRUE)
}

# Main packages
packages <- c(
  "tidyverse",
  "lme4",
  "glmmTMB",
  "mgcv",
  "ranger",
  "tidymodels",
  "broom",
  "broom.mixed",
  "wesanderson",
  "car",
  "furrr",
  "future",
  "lubridate",
  "texreg",
  "xtable"
)

# Install any packages that aren't already installed
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]

if (length(new_packages) > 0) {
  cat("Installing", length(new_packages), "packages:\n")
  cat(paste(" -", new_packages, collapse = "\n"), "\n\n")
  install.packages(new_packages, dependencies = TRUE)
} else {
  cat("All packages already installed.\n")
}

# Verify all packages load successfully
cat("\nVerifying package loading:\n")
for (pkg in packages) {
  result <- tryCatch(
    { library(pkg, character.only = TRUE); cat(" \u2713", pkg, "\n") },
    error = function(e) cat(" \u2717", pkg, "FAILED:", e$message, "\n")
  )
}

cat("\nDone. You can now run Main.Rmd and Supplements.Rmd\n")
cat("NOTE: Make sure utils.R is in the same folder as Main.Rmd and Supplements.Rmd\n")
cat("      utils.R is available in the R Scripts/ folder of the repository.\n")