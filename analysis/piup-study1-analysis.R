# =============================================================================
# PIUP Study 1 — Pre-Registered Analysis Script
# Receipt Identifier Label Comprehension: Between-Subjects Experiment
#
# Pre-registration: docs/piup-study1-preregistration-2026-06-22.md
# Protocol:        docs/piup-study-protocol-2026-06-22.md
# ADR:             docs/adr-037-piup-study1-label-rationale.md
#
# Author:          Jony Bursztyn
# Script version:  2026-06-22 (pre-pilot; uploaded to OSF before data collection)
# R version:       >= 4.3
#
# Required packages:
#   install.packages(c("PropCIs", "irr", "dunn.test"))
# [AMENDMENT 2026-06-24] DescTools removed; replaced with base-R (see below).
# [CLEANUP tick-4055] effsize and broom removed from install list — never in
#   pre-reg §6.9, never called. effsize::cohen.h() was superseded by inline
#   2*asin(sqrt(p)) calculation in tost_prop(); broom::tidy() was never used.
#
# Usage:
#   1. Replace DATA_PATH with the path to your Prolific export (CSV)
#   2. Verify column names match COLUMN MAP section below
#   3. source("piup-study1-analysis.R")
#   4. Results are written to analysis/results/ as CSV + console output
#
# All analyses in this script are PRE-SPECIFIED. Any analyses added after
# data collection are marked [EXPLORATORY] and do not constitute confirmatory
# evidence for any hypothesis.
# =============================================================================

# --- 0. SETUP ----------------------------------------------------------------

library(PropCIs)   # Wilson CIs for proportions
# [AMENDMENT tick-4032] TOSTER removed. The pre-registration §6.9 listed TOSTER as a planned
# package for equivalence tests. However, TOSTER::tsum_TOST operates on means (t-tests), not
# on proportions (z-tests), making it inappropriate for the H2-tertiary composite TOST.
# H2-tertiary uses a custom tost_prop() z-test below (per Lakens 2017 TOST framework;
# proportions use z-test on raw probability scale, not arcsine-transform t-test).
# TOSTER was never called anywhere in the script; removing it eliminates a spurious
# dependency. Statistical results unchanged. Documented as Amendment 10.
library(irr)       # Cohen's kappa (inter-rater reliability)
library(dunn.test) # Dunn's post-hoc for Kruskal-Wallis
# [CLEANUP tick-4055] effsize removed. Loaded for Cohen's h, but cohen_h is
# computed inline in tost_prop() as 2*asin(sqrt(p1)) - 2*asin(sqrt(p2));
# effsize::cohen.h() was never called. Not in pre-reg §6.9. No OSF amendment
# required (packages not in pre-reg; no statistical result affected).
# [CLEANUP tick-4055] broom removed. Loaded for tidy() model output but
# tidy() was never called anywhere in the script. Not in pre-reg §6.9.
# [AMENDMENT 2026-06-24] DescTools removed — CramerV and OddsRatio
# replaced with base-R equivalents (cramer_v_base / odds_ratio_base below).
# Statistical results are identical; change made for portability (DescTools
# requires the 'fs' C++ dependency unavailable in the analysis environment).
# This amendment is logged per §14 (Amendments log) of the pre-registration.

set.seed(20260622)  # Reproducibility seed — locked at pre-registration date

# --- Base-R replacements for DescTools::CramerV and DescTools::OddsRatio ---
# [AMENDMENT 2026-06-24]: these replace the DescTools package calls.

cramer_v_base <- function(chisq_stat, n, k) {
  # Cramér's V = sqrt(χ² / (n × (k − 1)))
  # k = min(rows, cols) of the contingency table
  sqrt(as.numeric(chisq_stat) / (n * (k - 1)))
}

odds_ratio_base <- function(mat, conf.level = 0.95) {
  # Woolf (log-transform) CI for OR from a 2×2 matrix
  # mat rows = groups, cols = correct / incorrect
  a <- mat[1,1]; b <- mat[1,2]; c <- mat[2,1]; d <- mat[2,2]
  # Guard against zeros (add 0.5 continuity correction)
  if (any(c(a,b,c,d) == 0)) { a <- a+0.5; b <- b+0.5; c <- c+0.5; d <- d+0.5 }
  or_val <- (a * d) / (b * c)
  z      <- qnorm(1 - (1 - conf.level) / 2)
  se_log <- sqrt(1/a + 1/b + 1/c + 1/d)
  ci_lo  <- exp(log(or_val) - z * se_log)
  ci_hi  <- exp(log(or_val) + z * se_log)
  result <- or_val
  attr(result, "conf.int") <- c(ci_lo, ci_hi)
  result
}

DATA_PATH     <- "data/prolific-export.csv"   # Replace with actual path
RESULTS_DIR   <- "analysis/results"
PILOT         <- FALSE  # Set TRUE when running on pilot data (N=40)
                        # Pilot runs produce instrument-validation output only;
                        # NO hypothesis tests are run on pilot data.

dir.create(RESULTS_DIR, showWarnings = FALSE, recursive = TRUE)

# --- COLUMN MAP (update to match your Prolific/Qualtrics export) ----------
# These are the expected column names from the Prolific export.
# Adjust COL_* constants if your export uses different headers.

COL_ID         <- "participant_id"
COL_CONDITION  <- "condition"        # "A", "B", "C", or "D"
COL_Q1         <- "q1_correct"       # 1 = correct, 0 = incorrect
COL_Q2         <- "q2_correct"
COL_Q3         <- "q3_correct"
COL_Q4         <- "q4_correct"
COL_Q5_RATER1  <- "q5_rater1"        # 0, 1, or 2 (per-rater score)
COL_Q5_RATER2  <- "q5_rater2"
COL_MM_RATER1  <- "mental_model_rater1"  # Open-text mental model, scored 0–2
COL_MM_RATER2  <- "mental_model_rater2"
COL_CONF_Q1    <- "confidence_q1"    # 1–7 Likert
COL_CONF_Q2    <- "confidence_q2"
COL_CONF_Q3    <- "confidence_q3"
COL_CONF_Q4    <- "confidence_q4"
COL_ATTN1      <- "attention_check_1" # 1 = pass, 0 = fail
COL_ATTN2      <- "attention_check_2"
COL_RT_SEC     <- "response_time_sec" # Total completion time in seconds
COL_OCCUPATION <- "occupation_sw_eng" # 1 = self-reported software engineer (exclude)
COL_AGE        <- "age_group"
COL_PRIOR_VOTE <- "prior_voting"
COL_EFFICACY   <- "tech_efficacy_mean"  # Mean of 3-item Hargittai scale
COL_INTENT     <- "download_intent"     # 1–5 behavioral intent
COL_AFFECT     <- "label_affect"        # −3 to +3 valence slider

CONDITIONS <- c("A", "B", "C", "D")
CONDITION_LABELS <- c(
  A = "vote fingerprint",
  B = "confirmation code",
  C = "nullifier",
  D = "receipt ID"
)

# =============================================================================
# 1. DATA LOADING AND PRE-PROCESSING
# =============================================================================

cat("\n=============================================================\n")
cat("PIUP Study 1 — Pre-Registered Analysis\n")
cat("Script version: 2026-06-22\n")
cat("=============================================================\n\n")

# ---- 1.1 Load raw data ------------------------------------------------------

if (!file.exists(DATA_PATH)) {
  stop("DATA_PATH not found: ", DATA_PATH,
       "\nUpdate DATA_PATH to point to your Prolific CSV export.")
}

raw <- read.csv(DATA_PATH, stringsAsFactors = FALSE)
cat("Raw data loaded: N =", nrow(raw), "\n")
cat("Conditions observed:", paste(sort(unique(raw[[COL_CONDITION]])), collapse=", "), "\n\n")

# ---- 1.2 Exclusions (pre-specified; §4.1) ------------------------------------

n_raw <- nrow(raw)
exclusion_log <- data.frame(
  rule      = character(),
  n_excluded = integer(),
  n_remaining = integer(),
  stringsAsFactors = FALSE
)

log_exclusion <- function(df, rule, n_before) {
  n_after <- nrow(df)
  n_exc   <- n_before - n_after
  cat(sprintf("  Exclusion [%s]: n = %d excluded; N remaining = %d\n",
              rule, n_exc, n_after))
  exclusion_log <<- rbind(exclusion_log, data.frame(
    rule = rule, n_excluded = n_exc, n_remaining = n_after,
    stringsAsFactors = FALSE
  ))
  df
}

cat("--- Pre-specified exclusions ---\n")

# Rule 1: Fail BOTH attention checks
df <- raw
df <- df[!(df[[COL_ATTN1]] == 0 & df[[COL_ATTN2]] == 0), ]
df <- log_exclusion(df, "Failed both attention checks", n_raw)

# Rule 2: Response time < 90 seconds
n_before <- nrow(df)
df <- df[df[[COL_RT_SEC]] >= 90, ]
df <- log_exclusion(df, "Response time < 90 sec", n_before)

# Rule 3: Self-reported software engineers
n_before <- nrow(df)
df <- df[df[[COL_OCCUPATION]] != 1, ]
df <- log_exclusion(df, "Self-reported software engineer", n_before)

n_final <- nrow(df)
cat(sprintf("\nFinal analytic N = %d (%.1f%% retained)\n\n",
            n_final, 100 * n_final / n_raw))

# ---- 1.3 Derived variables ---------------------------------------------------

# Composite accuracy (Q1–Q4)
df$composite_acc <- rowMeans(df[, c(COL_Q1, COL_Q2, COL_Q3, COL_Q4)], na.rm = TRUE)

# Confidence composite (Q1–Q4)
df$confidence_composite <- rowMeans(
  df[, c(COL_CONF_Q1, COL_CONF_Q2, COL_CONF_Q3, COL_CONF_Q4)], na.rm = TRUE
)

# Missing answers treated as incorrect (pre-registered §6.1 rule 7)
for (col in c(COL_Q1, COL_Q2, COL_Q3, COL_Q4)) {
  df[[col]][is.na(df[[col]])] <- 0
}

# Condition as factor with reference = A
df$condition <- factor(df[[COL_CONDITION]], levels = CONDITIONS)

# ---- 1.4 Condition balance check --------------------------------------------

cat("--- Condition assignment balance ---\n")
balance <- table(df$condition)
print(balance)
cat("\n")

if (PILOT) {
  cat("*** PILOT MODE: Hypothesis tests SUPPRESSED. Instrument validation only. ***\n\n")
}

# ---- 1.5 Save clean data ----------------------------------------------------

write.csv(df, file.path(RESULTS_DIR, "clean_data.csv"), row.names = FALSE)
cat("Clean data written to:", file.path(RESULTS_DIR, "clean_data.csv"), "\n\n")

# =============================================================================
# 2. INTER-RATER RELIABILITY (must pass before analysis; §6.1 rules 5 & 6)
# =============================================================================

cat("=============================================================\n")
cat("2. INTER-RATER RELIABILITY\n")
cat("=============================================================\n\n")

check_kappa <- function(data, rater1_col, rater2_col, label, threshold = 0.70) {
  r1 <- data[[rater1_col]]
  r2 <- data[[rater2_col]]
  # Remove rows where either rater has NA
  complete <- !is.na(r1) & !is.na(r2)
  r1 <- r1[complete]
  r2 <- r2[complete]
  ratings_matrix <- cbind(r1, r2)
  k_result <- irr::kappa2(ratings_matrix, weight = "unweighted")
  kappa_val <- k_result$value
  cat(sprintf("  %s: Cohen's κ = %.3f (N pairs = %d)\n", label, kappa_val, sum(complete)))
  if (kappa_val < threshold) {
    warning(sprintf(
      "IRR BELOW THRESHOLD for %s: κ = %.3f < %.2f. Adjudicate disagreements before proceeding.",
      label, kappa_val, threshold
    ))
    cat(sprintf("  *** WARNING: κ = %.3f < %.2f threshold — adjudicate before analysis ***\n",
                kappa_val, threshold))
  } else {
    cat(sprintf("  ✓ κ = %.3f >= %.2f threshold — proceed\n", kappa_val, threshold))
  }
  invisible(k_result)
}

# Q5 open-text mental model
k_q5 <- check_kappa(df, COL_Q5_RATER1, COL_Q5_RATER2,
                    "Q5 (privacy/coercion open text)")

# Mental model quality (RQ3 open text)
k_mm <- check_kappa(df, COL_MM_RATER1, COL_MM_RATER2,
                    "Mental model quality (open text)")

# Average Q5 scores (mean of two raters; used only after κ check passes)
df$q5_score    <- (df[[COL_Q5_RATER1]] + df[[COL_Q5_RATER2]]) / 2
df$mm_score    <- (df[[COL_MM_RATER1]] + df[[COL_MM_RATER2]]) / 2

cat("\n")

# =============================================================================
# 3. DESCRIPTIVE STATISTICS
# =============================================================================

cat("=============================================================\n")
cat("3. DESCRIPTIVE STATISTICS (per condition)\n")
cat("=============================================================\n\n")

# Wilson CI helper ---------------------------------------------------------
wilson_ci <- function(x_correct, n, conf = 0.95) {
  # Returns: proportion, lower, upper (Wilson method; pre-registered §6.9)
  result <- PropCIs::scoreci(x = x_correct, n = n, conf.level = conf)
  list(
    prop  = x_correct / n,
    lower = result$conf.int[1],
    upper = result$conf.int[2],
    n     = n,
    x     = x_correct
  )
}

format_prop_ci <- function(ci_list) {
  sprintf("%.1f%% [%.1f%%, %.1f%%] (n=%d, x=%d)",
          ci_list$prop * 100,
          ci_list$lower * 100,
          ci_list$upper * 100,
          ci_list$n,
          ci_list$x)
}

# Per-question, per-condition accuracy table
desc_results <- data.frame()

for (cond in CONDITIONS) {
  sub <- df[df$condition == cond, ]
  n_c <- nrow(sub)
  for (q in c("q1", "q2", "q3", "q4")) {
    col <- get(paste0("COL_", toupper(q)))
    x   <- sum(sub[[col]], na.rm = TRUE)
    ci  <- wilson_ci(x, n_c)
    desc_results <- rbind(desc_results, data.frame(
      condition   = cond,
      label       = CONDITION_LABELS[cond],
      question    = q,
      n           = n_c,
      n_correct   = x,
      prop        = round(ci$prop, 3),
      ci_lower    = round(ci$lower, 3),
      ci_upper    = round(ci$upper, 3),
      stringsAsFactors = FALSE
    ))
  }
  # Composite
  comp_x <- sum(sub$composite_acc >= 0.75, na.rm = TRUE)  # ≥ 3/4 correct as "high"
  cat(sprintf("Condition %s (%s): N=%d, composite prop correct = %.1f%% [%.1f%%, %.1f%%]\n",
              cond, CONDITION_LABELS[cond], n_c,
              mean(sub$composite_acc, na.rm=TRUE) * 100,
              wilson_ci(sum(sub[[COL_Q1]]+sub[[COL_Q2]]+sub[[COL_Q3]]+sub[[COL_Q4]], na.rm=TRUE),
                        n_c * 4)$lower * 100,
              wilson_ci(sum(sub[[COL_Q1]]+sub[[COL_Q2]]+sub[[COL_Q3]]+sub[[COL_Q4]], na.rm=TRUE),
                        n_c * 4)$upper * 100))
}

write.csv(desc_results, file.path(RESULTS_DIR, "descriptives.csv"), row.names = FALSE)
cat("\nDescriptives written to:", file.path(RESULTS_DIR, "descriptives.csv"), "\n\n")

# Confidence descriptives
cat("--- Confidence composite (mean ± SD) by condition ---\n")
conf_desc <- tapply(df$confidence_composite, df$condition, function(x)
  sprintf("%.2f ± %.2f (n=%d)", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE), sum(!is.na(x))))
print(conf_desc)
cat("\n")

# =============================================================================
# 4. PRIMARY ANALYSIS — RQ1 OMNIBUS (§6.2)
# =============================================================================

if (!PILOT) {

cat("=============================================================\n")
cat("4. PRIMARY ANALYSIS — RQ1 OMNIBUS (§6.2)\n")
cat("=============================================================\n\n")

# Median split on composite accuracy (pre-registered)
overall_median <- median(df$composite_acc, na.rm = TRUE)
df$composite_hi <- as.integer(df$composite_acc >= overall_median)
cat(sprintf("Composite accuracy median = %.2f; binary split at >= %.2f\n\n",
            overall_median, overall_median))

# Chi-squared test of homogeneity across 4 conditions
cont_table <- table(df$condition, df$composite_hi)
cat("Contingency table (condition × composite_hi):\n")
print(cont_table)
cat("\n")

chisq_rq1 <- chisq.test(cont_table)
cat("Chi-squared (omnibus):\n")
print(chisq_rq1)

# Cramér's V
cramer_v <- cramer_v_base(chisq_rq1$statistic, sum(cont_table), min(dim(cont_table)))
cat(sprintf("Cramér's V = %.3f\n\n", cramer_v))

cat("Decision: ")
if (chisq_rq1$p.value < 0.05) {
  cat("SIGNIFICANT — proceed to pre-specified pairwise comparisons (§6.3)\n\n")
} else {
  cat("NON-SIGNIFICANT (p >= 0.05). Report null; H2-primary and H3-Q1 tests\n")
  cat("proceed regardless (pre-specified per §6.2)\n\n")
}

} # end if (!PILOT)

# =============================================================================
# 5. PLANNED PAIRWISE COMPARISONS — HOLM CORRECTION (§6.3)
# =============================================================================
# Helper: one-tailed chi-squared for 2x2 table (direction: x1 > x2)
# Returns list(p_one_tailed, chi2, df, OR, OR_lo, OR_hi, p_two_tailed)

two_by_two_chisq <- function(x1_correct, n1, x2_correct, n2,
                              direction = "greater",
                              conf = 0.95) {
  # direction: "greater" (x1 > x2) or "less" (x1 < x2)
  mat <- matrix(
    c(x1_correct, n1 - x1_correct,
      x2_correct, n2 - x2_correct),
    nrow = 2, byrow = TRUE,
    dimnames = list(c("Cond1", "Cond2"), c("Correct", "Incorrect"))
  )
  test    <- chisq.test(mat, correct = FALSE)
  p_two   <- test$p.value
  # One-tailed: if observed direction matches hypothesis, halve p
  p1 <- x1_correct / n1
  p2 <- x2_correct / n2
  if ((direction == "greater" && p1 >= p2) ||
      (direction == "less"    && p1 <= p2)) {
    p_one <- p_two / 2
  } else {
    p_one <- 1 - p_two / 2  # opposite direction; conservative
  }
  or_result <- odds_ratio_base(mat, conf.level = conf)
  list(
    chi2         = test$statistic,
    df           = test$parameter,
    p_two_tailed = p_two,
    p_one_tailed = p_one,
    prop1        = p1,
    prop2        = p2,
    OR           = or_result[1],
    OR_lo        = attr(or_result, "conf.int")[1],
    OR_hi        = attr(or_result, "conf.int")[2],
    mat          = mat
  )
}

format_test <- function(t, alpha = 0.05, one_tailed = TRUE) {
  p <- if (one_tailed) t$p_one_tailed else t$p_two_tailed
  sig <- if (p < alpha) "* SIGNIFICANT" else "  ns"
  sprintf("χ²(1)=%.3f, p(one-tailed)=%.4f %s | prop1=%.1f%%, prop2=%.1f%% | OR=%.2f [%.2f, %.2f]",
          t$chi2, t$p_one_tailed, sig,
          t$prop1*100, t$prop2*100, t$OR, t$OR_lo, t$OR_hi)
}

get_n_correct <- function(data, cond, q_col) {
  sub <- data[data$condition == cond, ]
  list(x = sum(sub[[q_col]], na.rm=TRUE), n = nrow(sub))
}

if (!PILOT) {

# =============================================================================
# 5A. HYPOTHESIS 1 — "vote fingerprint" > "receipt ID" on privacy (§6.4)
#     Family H1: 2 tests (Q2 A>D, Q3 A>D); Holm within family
# =============================================================================

cat("=============================================================\n")
cat("5A. H1 — fingerprint > receipt-ID on privacy mental model (§6.4)\n")
cat("=============================================================\n\n")

A_q2 <- get_n_correct(df, "A", COL_Q2); D_q2 <- get_n_correct(df, "D", COL_Q2)
A_q3 <- get_n_correct(df, "A", COL_Q3); D_q3 <- get_n_correct(df, "D", COL_Q3)

h1_q2 <- two_by_two_chisq(A_q2$x, A_q2$n, D_q2$x, D_q2$n, direction = "greater")
h1_q3 <- two_by_two_chisq(A_q3$x, A_q3$n, D_q3$x, D_q3$n, direction = "greater")

# Holm correction within H1 family (m = 2)
h1_p_raw    <- c(h1_q2$p_one_tailed, h1_q3$p_one_tailed)
h1_p_holm   <- p.adjust(h1_p_raw, method = "holm")

cat("H1-Q2 (A > D, one-tailed):", format_test(h1_q2), "\n")
cat("H1-Q3 (A > D, one-tailed):", format_test(h1_q3), "\n")
cat(sprintf("\nHolm-corrected within H1 family:\n"))
cat(sprintf("  H1-Q2: p_holm = %.4f %s\n", h1_p_holm[1], ifelse(h1_p_holm[1] < 0.05, "* SIGNIFICANT", "ns")))
cat(sprintf("  H1-Q3: p_holm = %.4f %s\n", h1_p_holm[2], ifelse(h1_p_holm[2] < 0.05, "* SIGNIFICANT", "ns")))

h1_support <- all(h1_p_holm < 0.05)
cat(sprintf("\nH1 VERDICT: %s\n", ifelse(h1_support,
  "SUPPORTED (both H1-Q2 and H1-Q3 significant after Holm correction)",
  "NOT SUPPORTED (requires both tests significant)")))
cat("\n")

# =============================================================================
# 5B. HYPOTHESIS 2 — fingerprint / confirmation-code dissociation (§6.5)
#     Family H2: 3 tests (Q2 A>B, Q3 A>B, TOST composite A≈B); Holm within family
# =============================================================================

cat("=============================================================\n")
cat("5B. H2 — fingerprint vs. confirmation-code dissociation (§6.5)\n")
cat("=============================================================\n\n")

A_q2b <- get_n_correct(df, "A", COL_Q2); B_q2 <- get_n_correct(df, "B", COL_Q2)
A_q3b <- get_n_correct(df, "A", COL_Q3); B_q3 <- get_n_correct(df, "B", COL_Q3)

# H2-primary: Q2, A > B, one-tailed
h2_primary <- two_by_two_chisq(A_q2b$x, A_q2b$n, B_q2$x, B_q2$n, direction = "greater")

# H2-secondary: Q3, A > B, one-tailed
h2_secondary <- two_by_two_chisq(A_q3b$x, A_q3b$n, B_q3$x, B_q3$n, direction = "greater")

# H2-tertiary: TOST on composite accuracy (A ≈ B), equivalence bounds ±0.10
A_sub <- df[df$condition == "A", ]
B_sub <- df[df$condition == "B", ]

cat("H2-primary (Q2, A > B, one-tailed):", format_test(h2_primary), "\n")
cat("H2-secondary (Q3, A > B, one-tailed):", format_test(h2_secondary), "\n\n")

# H2-tertiary TOST for proportions: custom z-test implementation
# TOSTER::tsum_TOST is for means (t-distribution); proportions require a z-test on the
# raw probability scale (not arcsine-transformed). Implements the two one-sided z-test
# (TOST) procedure from Lakens (2017): two one-sided tests on (p1 - p2) with pooled SE.
p_A_comp  <- mean(A_sub$composite_acc, na.rm = TRUE)
p_B_comp  <- mean(B_sub$composite_acc, na.rm = TRUE)
n_A_comp  <- sum(!is.na(A_sub$composite_acc))
n_B_comp  <- sum(!is.na(B_sub$composite_acc))

cat(sprintf("H2-tertiary (TOST, composite A ≈ B, bounds ±0.10):\n"))
cat(sprintf("  Condition A: proportion = %.3f (N=%d)\n", p_A_comp, n_A_comp))
cat(sprintf("  Condition B: proportion = %.3f (N=%d)\n", p_B_comp, n_B_comp))

# TOST for two proportions via z-test (pooled)
tost_prop <- function(p1, n1, p2, n2, low_eqbound, high_eqbound, alpha = 0.05) {
  # Two one-sided z-tests for proportions
  # H0a: (p1 - p2) <= low_eqbound  →  H1a: (p1 - p2) > low_eqbound
  # H0b: (p1 - p2) >= high_eqbound →  H1b: (p1 - p2) < high_eqbound
  diff  <- p1 - p2
  se    <- sqrt(p1 * (1 - p1) / n1 + p2 * (1 - p2) / n2)
  z_lo  <- (diff - low_eqbound)  / se   # should be > 0 for equivalence
  z_hi  <- (diff - high_eqbound) / se   # should be < 0 for equivalence
  # [AMENDMENT tick-4029] Bug fix: lower.tail flags were inverted.
  # H0a: diff <= low_eqbound; reject H0a when z_lo large → p = P(Z >= z_lo) = lower.tail=FALSE.
  # H0b: diff >= high_eqbound; reject H0b when z_hi small → p = P(Z <= z_hi) = lower.tail=TRUE.
  # Prior code had these swapped: pnorm(z_lo, TRUE) and pnorm(z_hi, FALSE),
  # producing p-values > 0.5 when within bounds and making equivalence impossible to establish.
  p_lo  <- pnorm(z_lo, lower.tail = FALSE)  # one-tailed: P(Z >= z_lo)
  p_hi  <- pnorm(z_hi, lower.tail = TRUE)   # one-tailed: P(Z <= z_hi)
  p_tost <- max(p_lo, p_hi)
  equiv  <- p_tost < alpha
  # Cohen's h for effect size
  h <- 2 * asin(sqrt(p1)) - 2 * asin(sqrt(p2))
  ci_lo <- diff - qnorm(1 - alpha) * se
  ci_hi <- diff + qnorm(1 - alpha) * se
  list(diff = diff, se = se, z_lo = z_lo, z_hi = z_hi,
       p_lo = p_lo, p_hi = p_hi, p_tost = p_tost,
       equivalence_established = equiv, cohen_h = h,
       ci_lo_90 = ci_lo, ci_hi_90 = ci_hi)
}

tost_result <- tost_prop(p_A_comp, n_A_comp, p_B_comp, n_B_comp,
                          low_eqbound = -0.10, high_eqbound = 0.10)

cat(sprintf("  Observed difference (A - B) = %.4f\n", tost_result$diff))
cat(sprintf("  SE(diff) = %.4f\n", tost_result$se))
cat(sprintf("  z(lower bound) = %.3f, p_lo = %.4f\n", tost_result$z_lo, tost_result$p_lo))
cat(sprintf("  z(upper bound) = %.3f, p_hi = %.4f\n", tost_result$z_hi, tost_result$p_hi))
cat(sprintf("  TOST p (max of p_lo, p_hi) = %.4f\n", tost_result$p_tost))
cat(sprintf("  Cohen's h = %.3f\n", tost_result$cohen_h))
cat(sprintf("  90%% CI of difference: [%.4f, %.4f]\n",
            tost_result$ci_lo_90, tost_result$ci_hi_90))
cat(sprintf("  Equivalence established (bounds ±0.10, α=0.05): %s\n\n",
            ifelse(tost_result$equivalence_established, "YES ✓", "NO ✗")))

# Holm correction within H2 family (m = 3; TOST p used for H2-tertiary)
h2_p_raw  <- c(h2_primary$p_one_tailed, h2_secondary$p_one_tailed, tost_result$p_tost)
h2_p_holm <- p.adjust(h2_p_raw, method = "holm")

cat("Holm-corrected within H2 family:\n")
cat(sprintf("  H2-primary   (Q2, A>B):      p_holm = %.4f %s\n",
            h2_p_holm[1], ifelse(h2_p_holm[1] < 0.05, "* SIGNIFICANT", "ns")))
cat(sprintf("  H2-secondary (Q3, A>B):      p_holm = %.4f %s\n",
            h2_p_holm[2], ifelse(h2_p_holm[2] < 0.05, "* SIGNIFICANT", "ns")))
cat(sprintf("  H2-tertiary  (TOST, A≈B):    p_tost = %.4f %s\n",
            h2_p_holm[3], ifelse(h2_p_holm[3] < 0.05, "* SIGNIFICANT (equiv. established)", "ns (equiv. NOT established)")))

# H2 outcome classification (pre-registered §6.5)
primary_sig <- h2_p_holm[1] < 0.05 && h2_primary$prop1 > h2_primary$prop2  # A > B on Q2
equiv_estab <- tost_result$equivalence_established

# Post-hoc reversed test (two-tailed; only if primary not significant)
h2_reversed_test <- two_by_two_chisq(B_q2$x, B_q2$n, A_q2b$x, A_q2b$n, direction = "greater")
reversed_sig <- (!primary_sig) && (h2_reversed_test$p_one_tailed < 0.05) && equiv_estab

h2_verdict <- if (primary_sig && equiv_estab) {
  "SUPPORTED: A > B on Q2 (primary) + composite equivalence established"
} else if (!primary_sig && equiv_estab) {
  "NULL: A not > B on Q2, but composite equivalence established"
} else if (reversed_sig) {
  "REVERSED: B > A on Q2 (post-hoc) + equivalence established — PUBLISH IMMEDIATELY (novel result)"
} else {
  "INCONCLUSIVE: Does not meet criteria for supported/null/reversed. Report effect sizes; consider expanding n."
}

cat(sprintf("\nH2 OUTCOME CLASSIFICATION: %s\n\n", h2_verdict))

# Note on Q1 crossover (described but not confirmatory)
A_q1 <- get_n_correct(df, "A", COL_Q1); B_q1 <- get_n_correct(df, "B", COL_Q1)
cat(sprintf("[Descriptive, non-confirmatory] Q1 (vote-counted inference) A vs. B:\n"))
cat(sprintf("  A = %.1f%%, B = %.1f%% (H2 predicts B may edge A on Q1 — non-directional)\n\n",
            100 * A_q1$x / A_q1$n, 100 * B_q1$x / B_q1$n))

# =============================================================================
# 5C. HYPOTHESIS 3 — nullifier underperforms all conditions (§6.6)
#     Family H3: 6 tests; Holm within family
# =============================================================================

cat("=============================================================\n")
cat("5C. H3 — nullifier underperforms all conditions (§6.6)\n")
cat("=============================================================\n\n")

C_q1 <- get_n_correct(df, "C", COL_Q1)
B_q1_h3 <- get_n_correct(df, "B", COL_Q1)
D_q1 <- get_n_correct(df, "D", COL_Q1)

# H3-Q1 per pair: C < A, C < B, C < D (one-tailed)
h3_q1_ca <- two_by_two_chisq(C_q1$x, C_q1$n, A_q1$x, A_q1$n, direction = "less")
h3_q1_cb <- two_by_two_chisq(C_q1$x, C_q1$n, B_q1_h3$x, B_q1_h3$n, direction = "less")
h3_q1_cd <- two_by_two_chisq(C_q1$x, C_q1$n, D_q1$x, D_q1$n, direction = "less")

cat("H3-Q1 C < A:", format_test(h3_q1_ca), "\n")
cat("H3-Q1 C < B:", format_test(h3_q1_cb), "\n")
cat("H3-Q1 C < D:", format_test(h3_q1_cd), "\n\n")

# H3-composite: omnibus chi-squared (4 conditions × composite_hi)
cont_h3 <- table(df$condition, df$composite_hi)
chisq_h3 <- chisq.test(cont_h3, correct = FALSE)
cat(sprintf("H3-omnibus chi-squared (composite × 4 conditions): χ²=%.3f, df=%d, p=%.4f\n",
            chisq_h3$statistic, chisq_h3$parameter, chisq_h3$p.value))

# Holm-corrected pairwise from omnibus (C vs. each)
C_comp <- get_n_correct(df, "C", "composite_hi")
A_comp <- get_n_correct(df, "A", "composite_hi")
B_comp_h3 <- get_n_correct(df, "B", "composite_hi")
D_comp <- get_n_correct(df, "D", "composite_hi")

# Recompute composite_hi counts since column was derived above
C_comp_x <- sum(df[df$condition=="C", "composite_hi"], na.rm=TRUE)
C_comp_n <- sum(df$condition=="C")
A_comp_x <- sum(df[df$condition=="A", "composite_hi"], na.rm=TRUE)
A_comp_n <- sum(df$condition=="A")
B_comp_x <- sum(df[df$condition=="B", "composite_hi"], na.rm=TRUE)
B_comp_n <- sum(df$condition=="B")
D_comp_x <- sum(df[df$condition=="D", "composite_hi"], na.rm=TRUE)
D_comp_n <- sum(df$condition=="D")

h3_comp_ca <- two_by_two_chisq(C_comp_x, C_comp_n, A_comp_x, A_comp_n, direction="less")
h3_comp_cb <- two_by_two_chisq(C_comp_x, C_comp_n, B_comp_x, B_comp_n, direction="less")
h3_comp_cd <- two_by_two_chisq(C_comp_x, C_comp_n, D_comp_x, D_comp_n, direction="less")

cat("H3-composite C < A:", format_test(h3_comp_ca), "\n")
cat("H3-composite C < B:", format_test(h3_comp_cb), "\n")
cat("H3-composite C < D:", format_test(h3_comp_cd), "\n\n")

# Holm correction within H3 family (m = 6)
h3_p_raw  <- c(h3_q1_ca$p_one_tailed, h3_q1_cb$p_one_tailed, h3_q1_cd$p_one_tailed,
               h3_comp_ca$p_one_tailed, h3_comp_cb$p_one_tailed, h3_comp_cd$p_one_tailed)
h3_p_holm <- p.adjust(h3_p_raw, method = "holm")
h3_names  <- c("Q1(C<A)", "Q1(C<B)", "Q1(C<D)", "comp(C<A)", "comp(C<B)", "comp(C<D)")

cat("Holm-corrected within H3 family (m=6):\n")
for (i in seq_along(h3_names)) {
  cat(sprintf("  %s: p_holm = %.4f %s\n",
              h3_names[i], h3_p_holm[i],
              ifelse(h3_p_holm[i] < 0.05, "* SIGNIFICANT", "ns")))
}

# Support criterion: C significantly lower than >= 2 of 3 other conditions on Q1
h3_q1_sig_count <- sum(h3_p_holm[1:3] < 0.05)
h3_verdict <- if (h3_q1_sig_count >= 2) {
  sprintf("SUPPORTED: C significantly lower than %d/3 conditions on Q1 (after Holm correction)", h3_q1_sig_count)
} else {
  sprintf("NOT SUPPORTED: C significantly lower than %d/3 conditions on Q1 (need ≥ 2)", h3_q1_sig_count)
}
cat(sprintf("\nH3 VERDICT: %s\n\n", h3_verdict))

# Ethics clause check
C_q1_prop <- C_q1$x / C_q1$n
if (C_q1_prop < 0.30) {
  cat(sprintf("*** ETHICS CLAUSE TRIGGERED: Condition C Q1 accuracy = %.1f%% < 30%% ***\n",
              C_q1_prop * 100))
  cat("    Consider substituting Condition C label before full study launch (see §3 ethics clause)\n\n")
}

# =============================================================================
# 5D. HYPOTHESIS 4 — confirmation-code overconfidence (§6.7)
#     Family H4: 3 tests (confidence B > A, B > C, B > D); Holm within family
# =============================================================================

cat("=============================================================\n")
cat("5D. H4 — confirmation-code overconfidence (§6.7)\n")
cat("=============================================================\n\n")

# One-way ANOVA on confidence composite
conf_aov <- aov(confidence_composite ~ condition, data = df)
conf_aov_summary <- summary(conf_aov)
cat("One-way ANOVA on confidence composite:\n")
print(conf_aov_summary)
cat("\n")

f_pval <- conf_aov_summary[[1]][["Pr(>F)"]][1]

if (f_pval < 0.05) {
  cat("ANOVA significant — proceed to Tukey HSD post-hoc comparisons\n\n")
  tukey_result <- TukeyHSD(conf_aov)
  print(tukey_result)
  cat("\n")
} else {
  cat("ANOVA not significant (p >= 0.05). Pre-specified Tukey HSD comparisons reported regardless.\n")
  tukey_result <- TukeyHSD(conf_aov)
}

# Extract B vs. A, B vs. C, B vs. D from Tukey table
tukey_df <- as.data.frame(tukey_result$condition)
tukey_df$comparison <- rownames(tukey_df)

h4_comparisons <- c("B-A", "B-C", "B-D")
# Tukey HSD uses alphabetical order; B-A, B-C, B-D should be present
# If not (e.g. stored as A-B), flip sign and negate diff
get_tukey_p <- function(tukey_df, comp) {
  row <- tukey_df[tukey_df$comparison == comp, ]
  if (nrow(row) == 0) {
    # Try reversed
    parts <- strsplit(comp, "-")[[1]]
    rev_comp <- paste(rev(parts), collapse="-")
    row <- tukey_df[tukey_df$comparison == rev_comp, ]
  }
  if (nrow(row) == 0) return(NA)
  row[["p adj"]]
}

get_tukey_diff <- function(tukey_df, comp) {
  # Returns signed diff; if comparison stored reversed (e.g. A-B when B-A requested),
  # negates sign so result always reflects (requested_first - requested_second).
  row <- tukey_df[tukey_df$comparison == comp, ]
  if (nrow(row) > 0) return(row[["diff"]])
  parts <- strsplit(comp, "-")[[1]]
  rev_comp <- paste(rev(parts), collapse="-")
  row <- tukey_df[tukey_df$comparison == rev_comp, ]
  if (nrow(row) == 0) return(NA)
  -row[["diff"]]  # negate because comparison was stored in opposite direction
}

cat("Tukey HSD: B vs. {A, C, D} (pre-specified)\n")
h4_p_vals   <- sapply(h4_comparisons, get_tukey_p,   tukey_df = tukey_df)
h4_diff_vals <- sapply(h4_comparisons, get_tukey_diff, tukey_df = tukey_df)

# Holm within H4 family (m=3) — Tukey already family-wise corrected,
# but per pre-registration we report Holm within H4 family explicitly
h4_p_holm <- p.adjust(h4_p_vals, method = "holm")
for (i in seq_along(h4_comparisons)) {
  direction_ok <- !is.na(h4_diff_vals[i]) && h4_diff_vals[i] > 0
  cat(sprintf("  %s: diff=%.3f, Tukey p_adj=%.4f | Holm=%.4f %s%s\n",
              h4_comparisons[i], h4_diff_vals[i], h4_p_vals[i], h4_p_holm[i],
              ifelse(h4_p_holm[i] < 0.05, "* SIGNIFICANT", "ns"),
              ifelse(!direction_ok, " [DIRECTION REVERSED — B < other]", "")))
}

# Calibration analysis: Spearman correlation per condition
cat("\nCalibration: Spearman ρ (accuracy ~ confidence) per condition\n")
cat("H4 predicts B will have lower calibration than A\n")
spearman_results <- list()
for (cond in CONDITIONS) {
  sub_c <- df[df$condition == cond, ]
  # Per-participant accuracy score (0–4)
  sub_c$acc_score <- rowSums(sub_c[, c(COL_Q1, COL_Q2, COL_Q3, COL_Q4)], na.rm = TRUE)
  cor_result <- cor.test(sub_c$acc_score, sub_c$confidence_composite,
                         method = "spearman", exact = FALSE)
  spearman_results[[cond]] <- cor_result
  cat(sprintf("  Condition %s (%s): Spearman ρ = %.3f, p = %.4f\n",
              cond, CONDITION_LABELS[cond], cor_result$estimate, cor_result$p.value))
}

# H4 support requires BOTH significance AND correct direction (B > others)
# Tukey HSD is two-tailed; must verify direction explicitly.
h4_sig       <- all(h4_p_holm  < 0.05,  na.rm = TRUE)
h4_direction <- all(h4_diff_vals > 0, na.rm = TRUE)  # diff = B - other; must be positive
h4_support   <- h4_sig && h4_direction

rho_B <- spearman_results[["B"]]$estimate
rho_A <- spearman_results[["A"]]$estimate
cat(sprintf("\n  ρ(B) = %.3f vs. ρ(A) = %.3f → calibration %s for B vs. A\n",
            rho_B, rho_A, ifelse(rho_B < rho_A, "LOWER (H4 calibration direction)", "higher")))

h4_verdict <- if (h4_support) {
  "SUPPORTED: B confidence significantly > all other conditions (Holm-corrected, direction confirmed)"
} else if (h4_sig && !h4_direction) {
  "DIRECTION FAILURE: B significantly DIFFERENT from others but NOT in predicted direction (B < some). H4 not supported."
} else {
  sprintf("NOT SUPPORTED: only %d/3 comparisons significant (and/or direction not consistently B > others)",
          sum(h4_p_holm < 0.05, na.rm=TRUE))
}
cat(sprintf("\nH4 VERDICT: %s\n\n", h4_verdict))

} # end if (!PILOT)

# =============================================================================
# 6. Q5 OPEN-TEXT ANALYSIS (§6.8)
# =============================================================================

cat("=============================================================\n")
cat("6. Q5 OPEN-TEXT ANALYSIS (Kruskal-Wallis + Dunn post-hoc, §6.8)\n")
cat("=============================================================\n\n")

cat("Q5 score distribution by condition:\n")
q5_desc <- tapply(df$q5_score, df$condition, function(x)
  sprintf("mean=%.2f, sd=%.2f, n=%d", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE), sum(!is.na(x))))
print(q5_desc)
cat("\n")

if (!PILOT) {
  kw_result <- kruskal.test(q5_score ~ condition, data = df)
  cat("Kruskal-Wallis test:\n")
  print(kw_result)
  cat("\n")

  if (kw_result$p.value < 0.05) {
    cat("Significant — Dunn's post-hoc (Holm correction):\n")
    dunn_result <- dunn.test::dunn.test(df$q5_score, df$condition,
                                         method = "holm", kw = FALSE, label = TRUE)
  } else {
    cat("Non-significant (p >= 0.05). Q5 Dunn's post-hoc not warranted.\n")
  }
  cat("\n")
}

# =============================================================================
# 7. SECONDARY MEASURES (EXPLORATORY — §5.3)
# =============================================================================

cat("=============================================================\n")
cat("7. SECONDARY MEASURES [EXPLORATORY]\n")
cat("=============================================================\n\n")

# [EXPLORATORY] Behavioral intent (download) by condition
cat("[EXPLORATORY] Download intent (1–5) by condition:\n")
print(tapply(df[[COL_INTENT]], df$condition, mean, na.rm=TRUE))

# [EXPLORATORY] Label affect by condition
cat("\n[EXPLORATORY] Label affect (−3 to +3) by condition:\n")
print(tapply(df[[COL_AFFECT]], df$condition, mean, na.rm=TRUE))

# [EXPLORATORY] Mental model quality by condition (rater mean)
cat("\n[EXPLORATORY] Mental model quality (0–2 rater mean) by condition:\n")
print(tapply(df$mm_score, df$condition, mean, na.rm=TRUE))

# [EXPLORATORY] Pairwise not pre-specified (note: not confirmatory)
cat("\n[EXPLORATORY] A vs. D composite (not pre-specified for composite, only Q2/Q3):\n")
A_comp2 <- get_n_correct(df, "A", "composite_hi")
D_comp2 <- get_n_correct(df, "D", "composite_hi")
A_comp2_x <- sum(df[df$condition=="A", "composite_hi"], na.rm=TRUE)
D_comp2_x <- sum(df[df$condition=="D", "composite_hi"], na.rm=TRUE)
t_exp <- two_by_two_chisq(A_comp2_x, A_comp_n, D_comp2_x, D_comp_n, direction="greater")
cat("  ", format_test(t_exp, one_tailed=TRUE), "\n")
cat("  *** This is EXPLORATORY — not pre-registered. Interpret with caution. ***\n\n")

# =============================================================================
# 8. SUMMARY TABLE — ALL 14 PRE-SPECIFIED CONFIRMATORY TESTS
# =============================================================================

if (!PILOT) {

cat("=============================================================\n")
cat("8. SUMMARY — ALL 14 PRE-SPECIFIED CONFIRMATORY TESTS\n")
cat("=============================================================\n\n")

summary_tests <- data.frame(
  family     = c("H1","H1","H2","H2","H2","H3","H3","H3","H3","H3","H3","H4","H4","H4"),
  test_id    = c("H1-Q2","H1-Q3",
                 "H2-primary","H2-secondary","H2-tertiary",
                 "H3-Q1(C<A)","H3-Q1(C<B)","H3-Q1(C<D)",
                 "H3-comp(C<A)","H3-comp(C<B)","H3-comp(C<D)",
                 "H4-conf(B>A)","H4-conf(B>C)","H4-conf(B>D)"),
  description = c(
    "Q2 accuracy A > D (one-tailed)",
    "Q3 accuracy A > D (one-tailed)",
    "Q2 accuracy A > B (one-tailed) [PRIMARY ENDPOINT]",
    "Q3 accuracy A > B (one-tailed)",
    "Composite equivalence A ≈ B, bounds ±0.10 (TOST)",
    "Q1 accuracy C < A (one-tailed)",
    "Q1 accuracy C < B (one-tailed)",
    "Q1 accuracy C < D (one-tailed)",
    "Composite accuracy C < A (one-tailed)",
    "Composite accuracy C < B (one-tailed)",
    "Composite accuracy C < D (one-tailed)",
    "Confidence B > A (Tukey HSD)",
    "Confidence B > C (Tukey HSD)",
    "Confidence B > D (Tukey HSD)"
  ),
  p_raw     = round(c(h1_q2$p_one_tailed, h1_q3$p_one_tailed,
                h2_primary$p_one_tailed, h2_secondary$p_one_tailed, tost_result$p_tost,
                h3_q1_ca$p_one_tailed, h3_q1_cb$p_one_tailed, h3_q1_cd$p_one_tailed,
                h3_comp_ca$p_one_tailed, h3_comp_cb$p_one_tailed, h3_comp_cd$p_one_tailed,
                h4_p_vals), 4),
  p_holm    = round(c(h1_p_holm, h2_p_holm, h3_p_holm, h4_p_holm), 4),
  significant = c(h1_p_holm < 0.05, h2_p_holm < 0.05, h3_p_holm < 0.05, h4_p_holm < 0.05),
  stringsAsFactors = FALSE
)

print(summary_tests[, c("family","test_id","p_raw","p_holm","significant")])
write.csv(summary_tests, file.path(RESULTS_DIR, "confirmatory_tests_summary.csv"),
          row.names = FALSE)
cat("\nSummary table written to:", file.path(RESULTS_DIR, "confirmatory_tests_summary.csv"), "\n")

# =============================================================================
# 9. H2 OUTCOME CLASSIFICATION + PRODUCTION DECISION
# =============================================================================

cat("\n=============================================================\n")
cat("9. H2 OUTCOME CLASSIFICATION + PRODUCTION DECISION (§6.5, §13)\n")
cat("=============================================================\n\n")

cat(sprintf("H2 OUTCOME: %s\n\n", h2_verdict))

# Map H2 outcome + H4 verdict to production decision
h2_reversed <- grepl("REVERSED", h2_verdict)
h2_null     <- grepl("NULL", h2_verdict)
h2_support  <- grepl("SUPPORTED", h2_verdict) && !grepl("NOT", h2_verdict)
h4_sup      <- grepl("SUPPORTED", h4_verdict)

prod_decision <- if (h2_reversed && h4_sup) {
  "USE 'confirmation code' as default; add trust-calibration intervention for privacy-critical deployments. PUBLISH IMMEDIATELY — novel result."
} else if (h2_reversed) {
  "SWITCH to 'confirmation code' immediately. Update VoteReceipt.tsx default labelVariant."
} else if (h2_null) {
  "CONSIDER switching to 'confirmation code'. Familiarity benefit with no measured privacy cost."
} else if (h2_support) {
  "KEEP 'vote fingerprint' as default. Representational schema advantage on privacy items confirmed."
} else {
  "INCONCLUSIVE. Report effect sizes. Consider n expansion or design revision before production decision."
}

cat(sprintf("PRODUCTION DECISION: %s\n\n", prod_decision))

} # end if (!PILOT)

# =============================================================================
# 10. PILOT INSTRUMENT VALIDATION (runs in PILOT mode only)
# =============================================================================

if (PILOT) {

cat("=============================================================\n")
cat("10. PILOT INSTRUMENT VALIDATION (N=40)\n")
cat("=============================================================\n\n")

cat("Floor/ceiling check (< 20% or > 90% in any condition = concern):\n")
for (cond in CONDITIONS) {
  sub_c <- df[df$condition == cond, ]
  n_c <- nrow(sub_c)
  for (q in c(COL_Q1, COL_Q2, COL_Q3, COL_Q4)) {
    prop_c <- mean(sub_c[[q]], na.rm = TRUE)
    flag <- if (prop_c < 0.20) "*** FLOOR ***" else if (prop_c > 0.90) "*** CEILING ***" else ""
    cat(sprintf("  Cond %s, %s: %.1f%% %s\n", cond, q, prop_c * 100, flag))
  }
}

cat("\nTask time (seconds) descriptives:\n")
print(summary(df[[COL_RT_SEC]]))
if (median(df[[COL_RT_SEC]], na.rm = TRUE) < 480 || median(df[[COL_RT_SEC]], na.rm = TRUE) > 720) {
  cat("*** WARNING: Median completion time outside 8–12 min target. Review task length. ***\n")
}

cat("\nAttention check pass rate:\n")
n_pass <- sum(df[[COL_ATTN1]] == 1 | df[[COL_ATTN2]] == 1, na.rm = TRUE)
cat(sprintf("  Passed at least one check: %d / %d (%.1f%%)\n",
            n_pass, nrow(raw), 100 * n_pass / nrow(raw)))
if (n_pass / nrow(raw) < 0.80) {
  cat("  *** WARNING: Pass rate < 80%%. Revise attention checks before full study. ***\n")
}

cat("\n*** PILOT MODE: Hypothesis tests SUPPRESSED per pre-registration §7. ***\n")
cat("*** Pilot data will NOT be combined with full-study data. ***\n\n")

}

# =============================================================================
# 11. SESSION INFO
# =============================================================================

cat("=============================================================\n")
cat("11. SESSION INFO\n")
cat("=============================================================\n\n")
print(sessionInfo())

cat("\n--- Analysis complete ---\n")
cat(sprintf("Results written to: %s/\n", RESULTS_DIR))
cat("Files: clean_data.csv, descriptives.csv, confirmatory_tests_summary.csv\n\n")
cat("Pre-registration reference: docs/piup-study1-preregistration-2026-06-22.md\n")
cat("If any analysis deviates from the pre-registration, document in §14 (Amendments log).\n")
