
# ============================================================================
# install_packages.R
# Run this script once on a new machine before running any other code.
# This installs all packages required for Main.Rmd and Supplements.Rmd
# ============================================================================

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
    { library(pkg, character.only = TRUE); cat(" ✓", pkg, "\n") },
    error = function(e) cat(" ✗", pkg, "FAILED:", e$message, "\n")
  )
}

cat("\nDone. You can now run Main.Rmd and Supplements.Rmd\n")

