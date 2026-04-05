#########################################################################################
### Functions
#########################################################################################

# CCDF
ccdf <- function(x) {
  ecdf_fun <- ecdf(x)
  df <- data.frame(x = unique(x), y = 1 - sapply(unique(x), ecdf_fun))
  return(df)
}

# Make formula
make_formula <- function(dv, ev, controls) {
  frmla <-
    as.formula(paste(
      dv,
      paste(c(ev, controls), collapse = " + "),
      sep = " ~ "
    ))
  return(frmla)
}

# Pretty summary statistics
descriptiveStatistics <- function(x, digits = 3,
                                  subset = c("mean", "median", "min", "max", "sd", "skew", "kurtosis"),
                                  filename = NULL) {
  m <- psych::describeBy(x, group = rep("", nrow(x)), mat = TRUE, digits = digits, fast = F)[, subset]

  # fix the concatenated "1" for the grouping in describeBy
  rownames(m) <- colnames(x)

  # fix kurtosis (as psych::describeBy is actuall computing the excess kurtosis)
  colnames(m) <- plyr::mapvalues(colnames(m), c("kurtosis"), c("excess_kurtosis"))

  if (!is.null(filename)) {
    col_names <- plyr::mapvalues(colnames(m),
                                 c("mean", "median", "min", "max", "sd", "skew", "excess_kurtosis"),
                                 c("Mean", "Median", "Min.", "Max", "Std. dev.", "Skewness", "Excess kurtosis"))
    showColumns(col_names)

    print(xtable::xtable(m, digits = digits),
          only.contents = TRUE, include.colnames = FALSE, booktabs = TRUE,
          file = filename, type = "latex")
  }

  return(m)
}

# Regression model coefficient names to TeX
coef_names_tex <- function(model, model_variables, display_variables, cut = NULL) {

  comb_vars <- expand.grid(model_variables, model_variables, stringsAsFactors = FALSE) %>% filter(Var1 != Var2)

  dict <- apply(comb_vars, 1, paste, collapse = ":") %>% enframe(., value = "value") %>% bind_cols(comb_vars) %>%
    left_join(tibble(model_variables, display_variables) %>%
                dplyr::select(model_variables, DV1 = display_variables), by = c("Var1" = "model_variables")) %>%
    left_join(tibble(model_variables, display_variables) %>%
                dplyr::select(model_variables, DV2 = display_variables), by = c("Var2" = "model_variables")) %>%
    mutate(display_variables = paste0(DV1, " $\\times$ ", DV2)) %>%
    dplyr::select(model_variables = value, display_variables = display_variables) %>%
    bind_rows(tibble(model_variables, display_variables), .)

  custom_names_display <- lapply(model, function(x) rownames(summary(x)$coefficients)) %>%
    unlist() %>% unique() %>% enframe(.) %>% dplyr::select(-name)

  if(!is.null(cut)) {
    custom_names_display <- custom_names_display %>% mutate(value = gsub(cut, "", value))
  }

  custom_names_display <- custom_names_display %>%
    left_join(dict, by = c("value" = "model_variables")) %>%
    mutate(display_variables = ifelse(is.na(display_variables), value, display_variables)) %>%
    pull(display_variables)

  return(custom_names_display)
}


# Names to TeX
names_tex <- function(names, model_variables, display_variables, cut = NULL, threeway_interaction = F) {

  comb_vars <- expand.grid(model_variables, model_variables, stringsAsFactors = FALSE)

  dict <- apply(comb_vars, 1, paste, collapse = ":") %>% enframe(., value = "value") %>% bind_cols(comb_vars) %>%
    left_join(tibble(model_variables, display_variables) %>%
                dplyr::select(model_variables, DV1 = display_variables), by = c("Var1" = "model_variables")) %>%
    left_join(tibble(model_variables, display_variables) %>%
                dplyr::select(model_variables, DV2 = display_variables), by = c("Var2" = "model_variables")) %>%
    mutate(display_variables = paste0(DV1, " $\\times$ ", DV2)) %>%
    dplyr::select(model_variables = value, display_variables = display_variables) %>%
    bind_rows(tibble(model_variables, display_variables), .)

  if(threeway_interaction) {
    comb_vars <- expand.grid(model_variables, model_variables, model_variables, stringsAsFactors = FALSE)# %>% filter(! Var1 != Var2)

    dict <- apply(comb_vars, 1, paste, collapse = ":") %>% enframe(., value = "value") %>% bind_cols(comb_vars) %>%
      left_join(tibble(model_variables, display_variables) %>%
                  dplyr::select(model_variables, DV1 = display_variables), by = c("Var1" = "model_variables")) %>%
      left_join(tibble(model_variables, display_variables) %>%
                  dplyr::select(model_variables, DV2 = display_variables), by = c("Var2" = "model_variables")) %>%
      left_join(tibble(model_variables, display_variables) %>%
                  dplyr::select(model_variables, DV3 = display_variables), by = c("Var3" = "model_variables")) %>%
      mutate(display_variables = paste0(DV1, " $\\times$ ", DV2, " $\\times$ ", DV3)) %>%
      dplyr::select(model_variables = value, display_variables = display_variables) %>%
      bind_rows(dict, .)
  }

  custom_names_display <- names %>% enframe(.)

  if(!is.null(cut)) {
    custom_names_display <- custom_names_display %>% mutate(value = gsub(cut, "", value))
  }

  custom_names_display <- custom_names_display %>%
    left_join(dict, by = c("value" = "model_variables")) %>%
    mutate(display_variables = ifelse(is.na(display_variables), value, display_variables)) %>%
    pull(display_variables)

  return(custom_names_display)
}

upper_to_title <- function(x, upper = FALSE) {
  r <- gsub('([A-Z])', ' \\1', x, perl = TRUE) %>% trimws()
  if(!upper) {
    r <- str_to_sentence(r)
  }
  return(r)
}

get_cis <- function(model, replace_dict = vnames_list, sign_level = 0.01, after_comma = 3) {
  coef_table <- broom::tidy(model, conf.level = 1 - sign_level, conf.int = T) %>%
    filter(effect == "fixed") %>%
    dplyr::select(term, estimate, conf.low, conf.high, p.value) %>%
    mutate(term = stringr::str_replace_all(term, pattern = replace_dict)) %>%
    mutate(term = factor(term)) %>%
    mutate(p.value = case_when(
      p.value < 0.001 ~ paste0("$<0.001$"),
      TRUE ~ as.character(round(p.value, after_comma))
    )) %>%
    mutate(
      conf.low = round(conf.low, after_comma),
      conf.high = round(conf.high, after_comma)
    )
  return(coef_table)
}

#########################################################################################
### ggplot2 theme set
#########################################################################################

theme_set(
  theme_bw() +
    theme(legend.position = c(0.7, 0.9),
          legend.title = element_blank(), legend.direction = "horizontal",
          legend.text = element_text(colour = "black", size = 20),
          legend.background=element_rect(fill="transparent", colour=NA),
          legend.key = element_rect(fill = "transparent", colour = "transparent"),
          legend.key.width = unit(1.25, "cm"), legend.key.height = unit(1.25, "cm")
    ) +
    theme(axis.text.x = element_text(colour = "black", size = 20, vjust = 0.5),
          axis.text.y = element_text(colour = "black", size = 20, vjust = 0.5),
          axis.title.x = element_text(size = 20),
          axis.title.y = element_text(size = 20, vjust = 1.5)
    )# +
    #theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
)
