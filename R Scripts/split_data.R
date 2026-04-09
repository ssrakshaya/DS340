# ============================================================================
# Data Splitting Script
# Splits df_politicians.csv, df_newspeople.csv, df_activists.csv into
# train (70%), test (20%), and validation (10%) sets at the user level.
# Output: 9 CSV files in Data/split_output/
# ============================================================================

library(tidyverse)

# ── Paths ────────────────────────────────────────────────────────────────────
inputPath  <- "C:/Users/Josh/OneDrive - The Pennsylvania State University/DS 340W/Data/"
outputPath <- paste0(inputPath, "split_output/")

# Create output folder if it doesn't exist
if (!dir.exists(outputPath)) dir.create(outputPath)

# ── Parameters ───────────────────────────────────────────────────────────────
TRAIN_RATIO <- 0.70
TEST_RATIO  <- 0.20
VAL_RATIO   <- 0.10
SEED        <- 42

# ── Files to split ───────────────────────────────────────────────────────────
files <- list(
  politicians = "df_politicians.csv",
  newspeople  = "df_newspeople.csv",
  activists   = "df_activists.csv"
)

# ── Split function ────────────────────────────────────────────────────────────
split_dataset <- function(filename, name, input_path, output_path,
                          train_ratio, test_ratio, seed) {
  
  cat("\nProcessing:", name, "\n")
  
  df <- read_csv(paste0(input_path, filename), show_col_types = FALSE)
  cat("  Total rows: ", nrow(df), "\n")
  cat("  Total users:", n_distinct(df$UserID), "\n")
  
  # Get unique users and shuffle at user level
  set.seed(seed)
  users   <- unique(df$UserID)
  users   <- sample(users)
  n_users <- length(users)
  
  # Calculate split indices
  n_train <- floor(n_users * train_ratio)
  n_test  <- floor(n_users * test_ratio)
  # Validation gets remainder so every user is assigned exactly once
  
  train_users <- users[1:n_train]
  test_users  <- users[(n_train + 1):(n_train + n_test)]
  val_users   <- users[(n_train + n_test + 1):n_users]
  
  train_df <- df %>% filter(UserID %in% train_users)
  test_df  <- df %>% filter(UserID %in% test_users)
  val_df   <- df %>% filter(UserID %in% val_users)
  
  # Verify no user overlap
  stopifnot(length(intersect(train_users, test_users))  == 0)
  stopifnot(length(intersect(train_users, val_users))   == 0)
  stopifnot(length(intersect(test_users,  val_users))   == 0)
  stopifnot(nrow(train_df) + nrow(test_df) + nrow(val_df) == nrow(df))
  
  # Save
  write_csv(train_df, paste0(output_path, "df_", name, "_train.csv"))
  write_csv(test_df,  paste0(output_path, "df_", name, "_test.csv"))
  write_csv(val_df,   paste0(output_path, "df_", name, "_val.csv"))
  
  cat("  Train:", nrow(train_df), "rows |", length(train_users), "users ->",
      paste0("df_", name, "_train.csv"), "\n")
  cat("  Test: ", nrow(test_df),  "rows |", length(test_users),  "users ->",
      paste0("df_", name, "_test.csv"),  "\n")
  cat("  Val:  ", nrow(val_df),   "rows |", length(val_users),   "users ->",
      paste0("df_", name, "_val.csv"),   "\n")
  
  invisible(list(
    train_rows  = nrow(train_df),  test_rows  = nrow(test_df),
    val_rows    = nrow(val_df),    train_users = length(train_users),
    test_users  = length(test_users), val_users = length(val_users)
  ))
}

# ── Run splits ────────────────────────────────────────────────────────────────
cat("=" , rep("=", 50), "\n", sep = "")
cat("DATA SPLITTING\n")
cat("Train: ", TRAIN_RATIO * 100, "% | Test: ", TEST_RATIO * 100,
    "% | Val: ", VAL_RATIO * 100, "%\n", sep = "")
cat("Split level: User (all tweets from a user go to same split)\n")
cat("Output folder:", outputPath, "\n")
cat(rep("=", 51), "\n", sep = "")

results <- imap(files, function(filename, name) {
  split_dataset(
    filename    = filename,
    name        = name,
    input_path  = inputPath,
    output_path = outputPath,
    train_ratio = TRAIN_RATIO,
    test_ratio  = TEST_RATIO,
    seed        = SEED
  )
})

cat("\n", rep("=", 51), "\n", sep = "")
cat("COMPLETE. 9 files written to:", outputPath, "\n")
cat(rep("=", 51), "\n", sep = "")