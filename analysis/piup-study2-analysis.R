# =============================================================================
# PIUP Study 2 — Pre-Registered Analysis Script
# Absent-Content Interpretation, Explanation Effects, and Trust Calibration
# 2×2×2 Between-Subjects Factorial Experiment
#
# Design note:   docs/piup-study2-design-note-2026-06-22.md
# Study 1 ref:   docs/piup-study1-preregistration-2026-06-22.md
# Study 1 script: analysis/piup-study1-analysis.R
#
# Author:          Jony Bursztyn
# Script version:  2026-06-25 (pre-pilot; upload to OSF before data collection)
# R version:       >= 4.3
#
# Required packages:
#   install.packages(c("PropCIs", "TOSTER", "irr", "dunn.test",
#                      "broom", "emmeans"))
# Note: effsize and multcomp not required — effect sizes computed via base-R
# cramer_v_base() / TOSTER::tsum_TOST(); multcomp not called anywhere.
#
# Factors:
#   L (Label):       L1 = "vote fingerprint"    / L2 = "confirmation code"
#   E (Explanation): E1 = explanation present   / E2 = explanation absent
#   I (Intervention):I1 = no calibration prompt / I2 = calibration prompt + feedback
#
# 8 conditions: L1E1I1, L1E1I2, L1E2I1, L1E2I2,
#               L2E1I1, L2E1I2, L2E2I1, L2E2I2
#
# Primary measures:
#   M1 — Q-AC absent-content accuracy (binary)
#   M2 — Trust-in-receipt composite (McKnight scale, 4 items, 1–7 Likert)
#   M3 — Save intention (1–7 self-report) + download click (binary)
#   M4 — Confidence miscalibration residual (all conditions; post-receipt Q-AC confidence)
#   M5 — Verification instruction engagement (binary: expand click)
#   M6 — Open-text Q-OE absent-choice explanation (0–2, two raters)
#
# Confirmatory hypotheses (4 pre-specified families):
#   H2.1 — E main effect on Q-AC (chi-squared, one-tailed, E1 > E2)
#   H2.2 — L × E interaction on M2 trust (two-way ANOVA + simple effects)
#   H2.3 — I2 reduces miscalibration residual in L2 [CONDITIONAL on Study 1 H4]
#   H2.4 — M1 accuracy predicts M3 download click (logistic regression)
#
# Usage:
#   1. Replace DATA_PATH with path to Prolific/Qualtrics export (CSV)
#   2. Set H4_SUPPORTED to match Study 1 H4 verdict before final run
#   3. Verify column names match COLUMN MAP below
#   4. source("piup-study2-analysis.R")
#   5. Results written to analysis/results-study2/ as CSV + console output
#
# All analyses in this script are PRE-SPECIFIED. Any analyses added after
# data collection are marked [EXPLORATORY] and do not constitute confirmatory
# evidence for any hypothesis.
# =============================================================================

# --- 0. SETUP ----------------------------------------------------------------

library(PropCIs)   # Wilson CIs for proportions
library(TOSTER)    # Equivalence tests (TOST)
library(irr)       # Cohen's kappa (inter-rater reliability)
library(dunn.test) # Dunn's post-hoc for Kruskal-Wallis
library(broom)     # tidy() for model output
library(emmeans)   # emmeans for simple effects from ANOVA

set.seed(20260625)  # Reproducibility seed — locked at pre-registration date

# --- Base-R helper: Cramér's V and OR (mirrors Study 1; no DescTools dep) ---
cramer_v_base <- function(chisq_stat, n, k) {
  sqrt(as.numeric(chisq_stat) / (n * (k - 1)))
}

odds_ratio_base <- function(mat, conf.level = 0.95) {
  a <- mat[1,1]; b <- mat[1,2]; c <- mat[2,1]; d <- mat[2,2]
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

# --- Configuration -----------------------------------------------------------

DATA_PATH     <- "data/prolific-export-study2.csv"   # Replace with actual path
RESULTS_DIR   <- "analysis/results-study2"
PILOT         <- FALSE   # TRUE = pilot mode (instrument validation only, no HTs)
H4_SUPPORTED  <- FALSE   # Set TRUE if Study 1 H4 is confirmed before running H2.3

# TOST equivalence bounds (pre-specified, §9)
EQUIV_BOUNDS_SAVE  <- 0.5  # ±0.5 SD on M3 save intention (H2.3 equivalence test)

dir.create(RESULTS_DIR, showWarnings = FALSE, recursive = TRUE)

# --- COLUMN MAP (update to match Prolific/Qualtrics export headers) ----------

COL_ID         <- "participant_id"
COL_CONDITION  <- "condition"       # "L1E1I1","L1E1I2","L1E2I1","L1E2I2",
                                    # "L2E1I1","L2E1I2","L2E2I1","L2E2I2"
COL_L          <- "label"           # "L1" or "L2"
COL_E          <- "explanation"     # "E1" or "E2"
COL_I          <- "intervention"    # "I1" or "I2"

# M1: Absent-content accuracy (Q-AC)
COL_QAC        <- "qac_correct"     # 1 = correct ("No, my vote is not shown"), 0 = wrong/unsure

# M2: Trust composite (4 McKnight items, 1–7 Likert each)
COL_TI1        <- "trust_integrity_1"   # "receipt accurately reflects what happened"
COL_TI2        <- "trust_integrity_2"   # "fingerprint/code is unique to my ballot"
COL_TC1        <- "trust_competence_1"  # "could use receipt to prove ballot counted"
COL_TC2        <- "trust_competence_2"  # "I understand what this receipt is for"

# M3: Save intention
COL_SAVE_INTENT  <- "save_intention"   # 1–7 self-report ("how likely to save/screenshot")
COL_DOWNLOAD_CLICK <- "download_clicked" # 1 = clicked download, 0 = did not

# M4: Calibration confidence (all conditions — post-receipt Q-AC confidence)
# [Fixed tick-4246: FF resolved (a) — all conditions, not I2 only. Instrument §11 updated
# to match: Q-AC-conf appears for all participants after the primary comprehension question.]
COL_CALIB_CONF <- "calibration_confidence"  # 1–7 Likert ("How confident are you in your answer above?")

# M5: Verification instruction engagement
COL_VERIFY_EXPAND <- "verify_expanded"  # 1 = expanded "how to verify", 0 = did not

# M6: Open-text rater scores
COL_QOE_RATER1 <- "qoe_rater1"  # 0, 1, or 2
COL_QOE_RATER2 <- "qoe_rater2"  # 0, 1, or 2

# Exclusion-related columns
COL_ATTN1      <- "attention_check_1"   # 1 = pass
COL_ATTN2      <- "attention_check_2"   # 1 = pass
COL_RT_SEC     <- "response_time_sec"   # Total completion time in seconds
COL_OCCUPATION <- "occupation_sw_eng"   # 1 = self-reported software engineer (exclude)
COL_PRIOR_STUDY <- "prior_receipt_study" # 1 = completed a prior voting-receipt study
COL_BROWSER_FALLBACK <- "browser_fallback"  # 1 = participant received static screenshot
                                             # (browser could not render interactive prototype)
                                             # NOT excluded; flagged as sensitivity covariate (§9.3)

# Demographics (descriptive only)
COL_AGE        <- "age_group"
COL_PRIOR_VOTE <- "prior_voting"
COL_EFFICACY   <- "tech_efficacy_mean"  # Mean of 3-item Hargittai scale

# Condition factor levels
CONDITIONS <- c("L1E1I1","L1E1I2","L1E2I1","L1E2I2",
                "L2E1I1","L2E1I2","L2E2I1","L2E2I2")
CONDITION_LABELS <- c(
  L1E1I1 = "fingerprint + explanation + no calibration",
  L1E1I2 = "fingerprint + explanation + calibration",
  L1E2I1 = "fingerprint + no explanation + no calibration",
  L1E2I2 = "fingerprint + no explanation + calibration",
  L2E1I1 = "code + explanation + no calibration",
  L2E1I2 = "code + explanation + calibration",
  L2E2I1 = "code + no explanation + no calibration",
  L2E2I2 = "code + no explanation + calibration"
)

# =============================================================================
# SYNTHETIC DATA GENERATOR (smoke-test only; remove before OSF upload)
# =============================================================================

generate_synthetic_data <- function(n_per_cell = 30) {
  # 8 conditions × n_per_cell participants
  conds <- rep(CONDITIONS, each = n_per_cell)
  N     <- length(conds)

  # Parse factor levels from condition string
  L_vec <- ifelse(startsWith(conds, "L1"), "L1", "L2")
  E_vec <- ifelse(grepl("E1", conds), "E1", "E2")
  I_vec <- ifelse(grepl("I1", conds), "I1", "I2")

  # M1: Q-AC accuracy — E1 boosts; L1 gives small additional boost
  p_qac <- ifelse(E_vec == "E1" & L_vec == "L1", 0.80,
           ifelse(E_vec == "E1" & L_vec == "L2", 0.72,
           ifelse(E_vec == "E2" & L_vec == "L1", 0.55,
                                                  0.40)))
  qac <- rbinom(N, 1, p_qac)

  # M2: Trust (4 items, 1–7); L1E1 highest, L2E2 lowest
  trust_mu <- ifelse(E_vec == "E1" & L_vec == "L1", 5.5,
              ifelse(E_vec == "E1" & L_vec == "L2", 5.0,
              ifelse(E_vec == "E2" & L_vec == "L1", 4.5,
                                                     4.0)))
  trust_items <- matrix(
    pmin(7, pmax(1, round(rnorm(N * 4, rep(trust_mu, 4), 1.2)))),
    nrow = N, ncol = 4
  )
  colnames(trust_items) <- c(COL_TI1, COL_TI2, COL_TC1, COL_TC2)

  # M3: Save intention (1–7)
  save_mu <- ifelse(qac == 1, 5.0, 3.5)
  save_intent <- pmin(7, pmax(1, round(rnorm(N, save_mu, 1.5))))
  download_click <- rbinom(N, 1, plogis(save_intent - 4))

  # M4: Calibration confidence (all conditions — post-receipt Q-AC confidence)
  # [Fixed tick-4246: FF resolved (a) — calib_conf collected for all N=240, not I2-only.
  # Synthetic: L2 conditions expected to show higher confidence than L1 (over-confidence
  # from eCommerce schema); I2 intervention expected to reduce L2 miscalibration.]
  calib_conf_mu <- ifelse(L_vec == "L2",
                          ifelse(I_vec == "I2", 4.5, 5.0),   # I2 reduces L2 over-confidence
                          4.2)                                 # L1: correctly calibrated
  calib_conf <- pmin(7, pmax(1, round(rnorm(N, calib_conf_mu, 1.3))))

  # M5: Verify expansion (higher in E1 conditions)
  p_expand <- ifelse(E_vec == "E1", 0.60, 0.35)
  verify_expand <- rbinom(N, 1, p_expand)

  # M6: Open-text (0–2, two raters; agreement ~ 0.75)
  qoe_true <- sample(0:2, N, replace = TRUE, prob = c(0.3, 0.4, 0.3))
  qoe_r1 <- pmax(0, pmin(2, qoe_true + sample(c(-1,0,0,0,1), N, replace = TRUE)))
  qoe_r2 <- pmax(0, pmin(2, qoe_true + sample(c(-1,0,0,0,1), N, replace = TRUE)))

  # Exclusion cols
  attn1 <- rbinom(N, 1, 0.88)
  attn2 <- rbinom(N, 1, 0.90)
  rt    <- round(rnorm(N, 700, 120))
  occ   <- rbinom(N, 1, 0.04)
  prior  <- rbinom(N, 1, 0.03)
  fbk    <- rbinom(N, 1, 0.03)  # ~3% browser-fallback rate (synthetic)

  # Demographics
  age   <- sample(c("18-24","25-34","35-44","45-54","55+"), N, replace = TRUE,
                   prob = c(0.18, 0.30, 0.26, 0.16, 0.10))
  pvote <- rbinom(N, 1, 0.62)
  eff   <- round(rnorm(N, 3.5, 0.8), 1)

  df <- data.frame(
    participant_id      = sprintf("SYNTH%04d", seq_len(N)),
    condition           = conds,
    label               = L_vec,
    explanation         = E_vec,
    intervention        = I_vec,
    qac_correct         = qac,
    trust_integrity_1   = trust_items[,1],
    trust_integrity_2   = trust_items[,2],
    trust_competence_1  = trust_items[,3],
    trust_competence_2  = trust_items[,4],
    save_intention      = save_intent,
    download_clicked    = download_click,
    calibration_confidence = calib_conf,
    verify_expanded     = verify_expand,
    qoe_rater1          = qoe_r1,
    qoe_rater2          = qoe_r2,
    attention_check_1   = attn1,
    attention_check_2   = attn2,
    response_time_sec   = rt,
    occupation_sw_eng   = occ,
    prior_receipt_study = prior,
    browser_fallback    = fbk,
    age_group           = age,
    prior_voting        = pvote,
    tech_efficacy_mean  = eff,
    stringsAsFactors    = FALSE
  )
  df
}

# =============================================================================
# 1. DATA LOADING AND PRE-PROCESSING
# =============================================================================

cat("\n=============================================================\n")
cat("PIUP Study 2 — Pre-Registered Analysis\n")
cat("Script version: 2026-06-25\n")
cat("H4_SUPPORTED (Study 1):", H4_SUPPORTED, "\n")
cat("PILOT mode:", PILOT, "\n")
cat("=============================================================\n\n")

# ---- 1.1 Load data ----------------------------------------------------------

if (!file.exists(DATA_PATH)) {
  cat("DATA_PATH not found. Using synthetic data for smoke test.\n")
  cat("*** SYNTHETIC DATA — DO NOT USE FOR PUBLICATION ***\n\n")
  raw <- generate_synthetic_data(n_per_cell = 30)
} else {
  raw <- read.csv(DATA_PATH, stringsAsFactors = FALSE)
}

cat("Raw data loaded: N =", nrow(raw), "\n")
cat("Conditions observed:",
    paste(sort(unique(raw[[COL_CONDITION]])), collapse = ", "), "\n\n")

# ---- 1.2 Validate factor levels ---------------------------------------------

unexpected_conds <- setdiff(raw[[COL_CONDITION]], CONDITIONS)
if (length(unexpected_conds) > 0) {
  warning("Unexpected condition codes: ", paste(unexpected_conds, collapse = ", "),
          "\nCheck COL_CONDITION mapping.")
}

# ---- 1.3 Exclusions (pre-specified, §9.3) -----------------------------------

n_raw <- nrow(raw)
exclusion_log <- data.frame(rule = character(), n_excluded = integer(),
                            n_remaining = integer(), stringsAsFactors = FALSE)

log_exclusion <- function(df, rule, n_before) {
  n_after <- nrow(df)
  n_exc   <- n_before - n_after
  cat(sprintf("  Exclusion [%s]: n = %d excluded; N remaining = %d\n",
              rule, n_exc, n_after))
  exclusion_log <<- rbind(exclusion_log,
    data.frame(rule = rule, n_excluded = n_exc, n_remaining = n_after,
               stringsAsFactors = FALSE))
}

df <- raw

# Exclude self-reported software engineers / cryptographers
n_before <- nrow(df)
df <- df[df[[COL_OCCUPATION]] != 1, ]
log_exclusion(df, "self-reported software engineer/cryptographer", n_before)

# Flag prior voting-receipt study participants (§6.8 — NOT excluded; sensitivity flag only)
# Pre-registration §5: "Prior-study sensitivity flag (not an exclusion)" — participants
# flagged as prior_receipt_study = 1 are RETAINED in the primary analytic sample and
# excluded only in the pre-specified §6.8 sensitivity check (see §6.8 section below).
# [Fixed tick-4301/Amendment 17: was incorrectly excluded; pre-reg §5 says flag-not-exclude.]
n_prior_study <- sum(!is.na(df[[COL_PRIOR_STUDY]]) & df[[COL_PRIOR_STUDY]] == 1)
cat(sprintf("  Prior voting-receipt study: n = %d flagged (NOT excluded; sensitivity flag per §6.8)\n",
            n_prior_study))

# Exclude response time < 90 seconds
n_before <- nrow(df)
df <- df[!is.na(df[[COL_RT_SEC]]) & df[[COL_RT_SEC]] >= 90, ]
log_exclusion(df, "response time < 90 sec", n_before)

# Exclude participants who failed BOTH attention checks
n_before <- nrow(df)
df <- df[!(df[[COL_ATTN1]] == 0 & df[[COL_ATTN2]] == 0), ]
log_exclusion(df, "failed both attention checks", n_before)

# Flag browser-fallback participants (design note §9.3 — NOT excluded; sensitivity covariate only)
# These participants received a static screenshot when their browser could not render
# the interactive React prototype. Per design note §9.3 (pre-registration §4.1), they are
# retained in the analytic sample but flagged; H2.1 is re-run without them as a sensitivity
# check (§5).
# [Amendment 21 (pre-data): "pre-registration §9.3" corrected to "design note §9.3" — the
# pre-registration §9 has no §9.3 subsection; §9.3 is a design note section number.]
if (COL_BROWSER_FALLBACK %in% names(df)) {
  n_browser_fallback <- sum(df[[COL_BROWSER_FALLBACK]] == 1, na.rm = TRUE)
  cat(sprintf("  Browser fallback (static screenshot): n = %d flagged (NOT excluded; sensitivity covariate per §9.3)\n",
              n_browser_fallback))
} else {
  cat("  Note: 'browser_fallback' column not found in data — COL_BROWSER_FALLBACK not in column map.\n")
  cat("  Assuming all participants saw the interactive prototype (browser_fallback = 0 for all).\n")
  df[[COL_BROWSER_FALLBACK]] <- 0L
}

cat(sprintf("\nFinal analytic N after exclusions: %d / %d (%.1f%% retained)\n\n",
            nrow(df), n_raw, 100 * nrow(df) / n_raw))

# ---- 1.4 Derive composite measures ------------------------------------------

# M2 trust composite
trust_cols <- c(COL_TI1, COL_TI2, COL_TC1, COL_TC2)
df$m2_trust <- rowMeans(df[, trust_cols], na.rm = TRUE)

# M1 convenience
df$m1_qac <- df[[COL_QAC]]

# M3 self-report save intention
df$m3_save <- df[[COL_SAVE_INTENT]]

# M3 download click (binary factor)
df$m3_click <- df[[COL_DOWNLOAD_CLICK]]

# M4 calibration confidence residual (all conditions — tick-4246 FF fix).
# [Fixed tick-4246: M4 was I2-only retrospective CAL-probe; changed to all-conditions
# post-receipt Q-AC confidence so H2.3 t-test (I1-L2 vs. I2-L2) is testable.]
# Residual = confidence (1–7 scaled to 0–1) − Q-AC accuracy
df$m4_conf_raw <- df[[COL_CALIB_CONF]]
df$m4_residual <- NA_real_
conf_rows <- !is.na(df$m4_conf_raw)  # Should be all N=240 rows after tick-4246 fix
# Scale confidence to 0–1 (1→0.0, 7→1.0)
df$m4_residual[conf_rows] <- (df$m4_conf_raw[conf_rows] - 1) / 6 - df$m1_qac[conf_rows]

# M5 verify expansion
df$m5_expand <- df[[COL_VERIFY_EXPAND]]

# M6 inter-rater mean
# round() matches the instrument §16 formula: qoe_final = round((r1 + r2) / 2).
# After the tie-breaking protocol (§16), both raters should agree on integer scores,
# so round() will have no effect in practice — but is retained for consistency with
# the pre-registered instrument.
df$m6_qoe <- round(rowMeans(df[, c(COL_QOE_RATER1, COL_QOE_RATER2)], na.rm = TRUE))

# Factor variables for ANOVA
df$L <- factor(df[[COL_L]], levels = c("L1", "L2"),
               labels = c("fingerprint", "confirmation_code"))
df$E <- factor(df[[COL_E]], levels = c("E1", "E2"),
               labels = c("explanation_present", "explanation_absent"))
df$I <- factor(df[[COL_I]], levels = c("I1", "I2"),
               labels = c("no_calibration", "calibration"))
df$condition_f <- factor(df[[COL_CONDITION]], levels = CONDITIONS)

# =============================================================================
# 2. DESCRIPTIVE STATISTICS
# =============================================================================

cat("=============================================================\n")
cat("2. DESCRIPTIVE STATISTICS\n")
cat("=============================================================\n\n")

cat("Sample sizes by condition:\n")
print(table(df[[COL_CONDITION]]))
cat("\n")

cat("Sample sizes by factor:\n")
cat("  L (Label):       "); print(table(df$L))
cat("  E (Explanation): "); print(table(df$E))
cat("  I (Intervention):"); print(table(df$I))
cat("\n")

# M1 Q-AC accuracy by E (primary grouping)
cat("M1 (Q-AC accuracy) by Explanation:\n")
m1_by_E <- tapply(df$m1_qac, df$E, function(x)
  sprintf("%.1f%% (n=%d)", 100 * mean(x, na.rm=TRUE), sum(!is.na(x))))
print(m1_by_E)
cat("\n")

cat("M1 (Q-AC accuracy) by L × E cell:\n")
m1_le <- tapply(df$m1_qac, list(df$L, df$E), function(x)
  sprintf("%.1f%% (n=%d)", 100 * mean(x, na.rm=TRUE), sum(!is.na(x))))
print(m1_le)
cat("\n")

cat("M2 (Trust composite 1–7) by L × E cell:\n")
m2_le <- tapply(df$m2_trust, list(df$L, df$E), function(x)
  sprintf("mean=%.2f, sd=%.2f, n=%d", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE), sum(!is.na(x))))
print(m2_le)
cat("\n")

# Trust scale internal consistency (Cronbach's alpha approximation)
trust_mat <- df[, trust_cols]
trust_mat_complete <- trust_mat[complete.cases(trust_mat), ]
if (nrow(trust_mat_complete) > 1 && ncol(trust_mat_complete) > 1) {
  item_vars  <- apply(trust_mat_complete, 2, var, na.rm = TRUE)
  total_var  <- var(rowSums(trust_mat_complete), na.rm = TRUE)
  k          <- ncol(trust_mat_complete)
  alpha_raw  <- (k / (k - 1)) * (1 - sum(item_vars) / total_var)
  cat(sprintf("M2 Cronbach's alpha (trust composite): α = %.3f", alpha_raw))
  if (alpha_raw < 0.70) cat("  *** BELOW THRESHOLD — report items individually (§7.1) ***")
  cat("\n\n")
}

cat("M3 (Save intention 1–7) by E:\n")
print(tapply(df$m3_save, df$E, function(x)
  sprintf("mean=%.2f, sd=%.2f", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE))))

cat("\nM3 (Download click rate) by E:\n")
print(tapply(df$m3_click, df$E, function(x)
  sprintf("%.1f%%", 100 * mean(x, na.rm=TRUE))))
cat("\n")

# Save descriptives
desc_out <- data.frame(
  condition = CONDITIONS,
  n         = as.integer(table(df$condition_f)[CONDITIONS]),
  m1_qac_pct = 100 * as.numeric(tapply(df$m1_qac, df$condition_f, mean, na.rm=TRUE)[CONDITIONS]),
  m2_trust   = as.numeric(tapply(df$m2_trust, df$condition_f, mean, na.rm=TRUE)[CONDITIONS]),
  m3_save    = as.numeric(tapply(df$m3_save, df$condition_f, mean, na.rm=TRUE)[CONDITIONS]),
  m3_click_pct = 100 * as.numeric(tapply(df$m3_click, df$condition_f, mean, na.rm=TRUE)[CONDITIONS]),
  stringsAsFactors = FALSE
)
write.csv(desc_out, file.path(RESULTS_DIR, "descriptives_study2.csv"), row.names = FALSE)
cat("Descriptives written to:", file.path(RESULTS_DIR, "descriptives_study2.csv"), "\n\n")

# =============================================================================
# 3. INTER-RATER RELIABILITY — M6 OPEN-TEXT (§9.4)
# =============================================================================

cat("=============================================================\n")
cat("3. INTER-RATER RELIABILITY — M6 Q-OE OPEN TEXT (§9.4)\n")
cat("=============================================================\n\n")

rater_data <- df[, c(COL_QOE_RATER1, COL_QOE_RATER2)]
rater_data_complete <- rater_data[complete.cases(rater_data), ]

# kappa_ok gates ALL M6 analysis (pre-reg §6.7: κ ≥ 0.70 required before any Q-OE analysis).
# [Amendment 20 (pre-data): flag was missing — KW ran unconditionally even when κ < 0.70.]
kappa_ok <- FALSE

if (nrow(rater_data_complete) > 0) {
  kappa_result <- irr::kappa2(rater_data_complete, weight = "unweighted")
  cat(sprintf("Cohen's kappa (unweighted): κ = %.3f, z = %.2f, p = %.4f, n = %d\n",
              kappa_result$value, kappa_result$statistic, kappa_result$p.value,
              kappa_result$subjects))
  if (kappa_result$value < 0.70) {
    cat("*** κ < 0.70 — raters must adjudicate disagreements before proceeding (§9.4). ***\n")
    cat("*** Pause analysis at this point; do not proceed to confirmatory tests. ***\n")
    cat("*** M6 Q-OE analysis skipped — re-run after rater adjudication and rescoring (§6.7). ***\n")
  } else {
    cat("κ ≥ 0.70 — inter-rater agreement adequate. Proceed to hypothesis tests.\n")
    kappa_ok <- TRUE
  }
} else {
  cat("No complete rater pairs found. Check COL_QOE_RATER1 / COL_QOE_RATER2 mapping.\n")
  cat("M6 Q-OE analysis skipped — cannot compute kappa without rater data.\n")
}
cat("\n")

# =============================================================================
# 3.5 Q-OE 15 RANDOM SAMPLES PER CONDITION (§6.7 — drawn before hypothesis testing)
# =============================================================================
# Pre-registration §6.7: "15 randomly sampled Q-OE responses per condition published
# as illustrative examples (random sample drawn before hypothesis testing)."
# Fixed seed ensures reproducibility; sample is drawn here before any hypothesis
# outcome is computed so the choice of examples cannot be influenced by results.
# [Added tick-4301/Amendment 18]

COL_QOE_TEXT <- "qoe_open_text"  # raw open-text Q-OE column (confirm column name on data collection)

if (COL_QOE_TEXT %in% names(df)) {
  set.seed(20260901)  # fixed seed; pre-registered — do not change after data collection
  cat("=============================================================\n")
  cat("3.5 Q-OE RANDOM SAMPLE (§6.7 — drawn before hypothesis testing)\n")
  cat("=============================================================\n\n")
  for (cond in levels(df$condition_f)) {
    cond_rows <- df[df$condition_f == cond &
                    !is.na(df[[COL_QOE_TEXT]]) &
                    nchar(trimws(as.character(df[[COL_QOE_TEXT]]))) > 0, ]
    n_avail <- nrow(cond_rows)
    sampled <- cond_rows[sample(seq_len(n_avail), min(15L, n_avail)), ]
    cat(sprintf("Condition %s (n=%d available; sampling %d):\n",
                cond, n_avail, nrow(sampled)))
    for (i in seq_len(nrow(sampled))) {
      cat(sprintf("  %2d. %s\n", i, as.character(sampled[[COL_QOE_TEXT]][i])))
    }
    cat("\n")
  }
  cat("  *** PRE-SPECIFIED (§6.7); drawn before hypothesis testing ***\n\n")
} else {
  cat(sprintf("[NOTE] Q-OE text column '%s' not found in data.\n", COL_QOE_TEXT))
  cat("  Confirm column name on data collection; update COL_QOE_TEXT accordingly.\n\n")
}

# =============================================================================
# 4. HYPOTHESIS TESTS (suppressed in PILOT mode)
# =============================================================================

if (!PILOT) {

# ---- Helper: chi-squared for two proportions (one-tailed) ------------------
two_prop_chisq_one_tailed <- function(n1, x1, n2, x2, direction = "greater") {
  # direction = "greater": H_A is p1 > p2
  # Returns list: OR, OR_CI, chi_stat, p_two_tailed, p_one_tailed, n1/x1/n2/x2
  mat <- matrix(c(x1, n1 - x1, x2, n2 - x2), nrow = 2, byrow = TRUE)
  ct  <- chisq.test(mat, correct = FALSE)
  or  <- odds_ratio_base(mat)
  # One-tailed p: chi-squared is symmetric, so one-tailed = two-tailed / 2
  # only when the effect is in the predicted direction
  p_one <- if ((direction == "greater" && x1/n1 > x2/n2) ||
               (direction == "less"    && x1/n1 < x2/n2)) {
    ct$p.value / 2
  } else {
    1 - ct$p.value / 2
  }
  list(
    chi_stat   = as.numeric(ct$statistic),
    df         = ct$parameter,
    p_two      = ct$p.value,
    p_one      = p_one,
    n1 = n1, x1 = x1, p1 = x1/n1,
    n2 = n2, x2 = x2, p2 = x2/n2,
    OR = as.numeric(or),
    OR_CI_lo   = attr(or, "conf.int")[1],
    OR_CI_hi   = attr(or, "conf.int")[2],
    direction  = direction
  )
}

fmt_binary_result <- function(res) {
  sprintf("%.1f%% vs %.1f%%; χ²(1) = %.3f; OR = %.2f [%.2f, %.2f]; p(one-tailed) = %.4f",
          100*res$p1, 100*res$p2,
          res$chi_stat, res$OR, res$OR_CI_lo, res$OR_CI_hi, res$p_one)
}

# =============================================================================
# 4.1 H2.1 — E MAIN EFFECT ON Q-AC (§9.1)
# =============================================================================

cat("=============================================================\n")
cat("4.1 H2.1 — E MAIN EFFECT ON Q-AC ACCURACY (§9.1)\n")
cat("Prediction: E1 > E2 on absent-content accuracy (M1)\n")
cat("=============================================================\n\n")

# Aggregate E levels (pool across L and I)
E1_rows <- df$E == "explanation_present"
E2_rows <- df$E == "explanation_absent"
n_E1    <- sum(E1_rows, na.rm = TRUE)
n_E2    <- sum(E2_rows, na.rm = TRUE)
x_E1    <- sum(df$m1_qac[E1_rows], na.rm = TRUE)
x_E2    <- sum(df$m1_qac[E2_rows], na.rm = TRUE)

h21_result <- two_prop_chisq_one_tailed(n_E1, x_E1, n_E2, x_E2, direction = "greater")
cat("H2.1: E1 vs. E2 on Q-AC\n")
cat("  ", fmt_binary_result(h21_result), "\n\n")

# Wilson confidence intervals for each E level
cat("Wilson 95% CIs:\n")
cat(sprintf("  E1 (explanation present): %.1f%% [%.1f%%, %.1f%%] (n=%d)\n",
            100*h21_result$p1,
            100*as.numeric(PropCIs::scoreci(x_E1, n_E1, 0.95)$conf.int[1]),
            100*as.numeric(PropCIs::scoreci(x_E1, n_E1, 0.95)$conf.int[2]),
            n_E1))
cat(sprintf("  E2 (explanation absent):  %.1f%% [%.1f%%, %.1f%%] (n=%d)\n",
            100*h21_result$p2,
            100*as.numeric(PropCIs::scoreci(x_E2, n_E2, 0.95)$conf.int[1]),
            100*as.numeric(PropCIs::scoreci(x_E2, n_E2, 0.95)$conf.int[2]),
            n_E2))

h21_sig <- h21_result$p_one < 0.05
h21_verdict <- if (h21_sig) {
  sprintf("H2.1 SUPPORTED: Explanation significantly increases absent-content accuracy (p=%.4f).",
          h21_result$p_one)
} else {
  sprintf("H2.1 NOT SUPPORTED: No significant E main effect on Q-AC (p=%.4f).",
          h21_result$p_one)
}
cat(sprintf("\nH2.1 VERDICT: %s\n\n", h21_verdict))

# Predicted rank ordering (exploratory cell-level check — §8.1)
cat("[EXPLORATORY] Q-AC accuracy by L × E cell (predicted: L1E1 ≥ L2E1 > L1E2 ≥ L2E2):\n")
cell_acc <- tapply(df$m1_qac, list(df$L, df$E), mean, na.rm = TRUE)
print(round(cell_acc * 100, 1))
cat("\n")

# Ceiling note (pre-specified: §11.2 — if I2E1 cells > 90%, flag)
cat("[Pre-specified ceiling check per §11.2 (I2E1 conditions)]\n")
for (l_lev in c("fingerprint","confirmation_code")) {
  cell_I2E1 <- df$L == l_lev & df$E == "explanation_present" & df$I == "calibration"
  acc_I2E1  <- mean(df$m1_qac[cell_I2E1], na.rm = TRUE)
  flag <- if (!is.nan(acc_I2E1) && acc_I2E1 > 0.90) "*** CEILING — see §11.2 ***" else "OK"
  cat(sprintf("  %s I2E1: %.1f%% %s\n", l_lev, 100*acc_I2E1, flag))
}
cat("\n")

# =============================================================================
# 4.2 H2.2 — L × E INTERACTION ON M2 TRUST (§9.1)
# =============================================================================

cat("=============================================================\n")
cat("4.2 H2.2 — L × E INTERACTION ON M2 TRUST COMPOSITE (§9.1)\n")
cat("Prediction: Interaction F significant; E effect larger for L2 than L1\n")
cat("=============================================================\n\n")

# M2 α gate: if Cronbach's α < 0.70, H2.2 ANOVA on composite is compromised.
# Pre-registration §5.3: "α ≥ 0.70 required; if not met, items reported individually."
# [Amendment 23 (pre-data): warning block added — prior code printed *** BELOW THRESHOLD ***
# in the descriptives section but then ran H2.2 ANOVA on the composite unconditionally.
# No hypothesis, alpha level, or verdict criterion change; result is still computed for
# descriptive reference but is clearly flagged as exploratory when α < 0.70.]
if (exists("alpha_raw") && !is.na(alpha_raw) && alpha_raw < 0.70) {
  cat("*** WARNING: M2 Cronbach's α = ", round(alpha_raw, 3), " < 0.70 ***\n")
  cat("*** Per pre-registration §5.3: composite cannot be used; items should be reported ***\n")
  cat("*** individually. H2.2 ANOVA results below are EXPLORATORY (composite reliability ***\n")
  cat("*** insufficient). Do not treat as confirmatory evidence. ***\n\n")
  cat("[EXPLORATORY — α < 0.70] Individual M2 item means by L × E cell:\n")
  for (item_col in trust_cols) {
    cat(sprintf("  %s:\n", item_col))
    print(tapply(df[[item_col]], list(df$L, df$E), mean, na.rm = TRUE))
  }
  cat("\n")
}

# Two-way ANOVA (L × E, between-subjects) — main effects + interaction
# Exclude I factor for this analysis (pool across I per design note §9.1 / pre-registration §6.3)
# [Amendment 21 (pre-data): "pre-registration §9.1" corrected — §9 of pre-reg is Open Science
# Commitments; the H2.2 pooling spec is design note §9.1 / pre-registration §6.3.]
df_anova <- df[!is.na(df$m2_trust) & !is.na(df$L) & !is.na(df$E), ]

m2_aov <- aov(m2_trust ~ L * E, data = df_anova)
m2_aov_tidy <- broom::tidy(m2_aov)
cat("Two-way ANOVA (L × E) on M2 trust:\n")
print(m2_aov_tidy)
cat("\n")

# Interaction F significance
interaction_row <- m2_aov_tidy[m2_aov_tidy$term == "L:E", ]
h22_interaction_sig <- !is.null(interaction_row) &&
                       nrow(interaction_row) > 0 &&
                       !is.na(interaction_row$p.value) &&
                       interaction_row$p.value < 0.05

if (h22_interaction_sig) {
  cat("Interaction is significant (α = 0.05). Pre-specified simple effects follow:\n\n")

  # Simple effect of E within L1 (fingerprint)
  df_L1 <- df_anova[df_anova$L == "fingerprint", ]
  t_E_L1 <- t.test(m2_trust ~ E, data = df_L1, var.equal = FALSE)
  cat(sprintf("  Simple effect of E within L1 (fingerprint): t(%s) = %.3f, p = %.4f\n",
              round(t_E_L1$parameter, 1), t_E_L1$statistic, t_E_L1$p.value))
  cat(sprintf("    E1 mean=%.2f, E2 mean=%.2f, diff=%.2f [%.2f, %.2f]\n",
              t_E_L1$estimate[1], t_E_L1$estimate[2],
              t_E_L1$estimate[1] - t_E_L1$estimate[2],
              t_E_L1$conf.int[1], t_E_L1$conf.int[2]))

  # Simple effect of E within L2 (confirmation code)
  df_L2 <- df_anova[df_anova$L == "confirmation_code", ]
  t_E_L2 <- t.test(m2_trust ~ E, data = df_L2, var.equal = FALSE)
  cat(sprintf("  Simple effect of E within L2 (confirmation code): t(%s) = %.3f, p = %.4f\n",
              round(t_E_L2$parameter, 1), t_E_L2$statistic, t_E_L2$p.value))
  cat(sprintf("    E1 mean=%.2f, E2 mean=%.2f, diff=%.2f [%.2f, %.2f]\n",
              t_E_L2$estimate[1], t_E_L2$estimate[2],
              t_E_L2$estimate[1] - t_E_L2$estimate[2],
              t_E_L2$conf.int[1], t_E_L2$conf.int[2]))

  # Predicted direction: E effect larger for L2
  E_eff_L1 <- abs(t_E_L1$estimate[1] - t_E_L1$estimate[2])
  E_eff_L2 <- abs(t_E_L2$estimate[1] - t_E_L2$estimate[2])
  cat(sprintf("\n  E effect size: L1=%.2f, L2=%.2f — L2 > L1: %s (predicted direction)\n",
              E_eff_L1, E_eff_L2, if (E_eff_L2 > E_eff_L1) "YES ✓" else "NO ✗"))

  h22_verdict <- sprintf(
    "H2.2 SUPPORTED: L × E interaction significant (F(1,%d) = %.3f, p = %.4f). E effect larger in L2 (%.2f) than L1 (%.2f): %s.",
    as.integer(m2_aov_tidy$df[m2_aov_tidy$term == "Residuals"]),  # residual df
    interaction_row$statistic, interaction_row$p.value,
    E_eff_L2, E_eff_L1,
    if (E_eff_L2 > E_eff_L1) "CONFIRMED" else "NOT CONFIRMED"
  )
} else {
  # Report 90% CI on interaction term per pre-registration §6.3
  cat("Interaction not significant. Reporting 90% CI on interaction term (pre-specified):\n")

  m2_lm <- lm(m2_trust ~ L * E, data = df_anova)
  # Use emmeans to get interaction contrast + 90% CI reliably
  emm <- emmeans::emmeans(m2_lm, ~ L * E)
  int_contrast <- emmeans::contrast(emm, interaction = "pairwise")
  cat("Interaction contrast (emmeans, 90% CI):\n")
  print(summary(int_contrast, infer = TRUE, level = 0.90))
  cat("\n")

  # Descriptive main effects — pre-registration §6.3:
  # "report E main effect and L main effect descriptively"
  cat("Descriptive marginal means — E main effect (pooled across L):\n")
  emm_E <- emmeans::emmeans(m2_lm, ~ E)
  print(summary(emm_E))
  cat("\nDescriptive marginal means — L main effect (pooled across E):\n")
  emm_L <- emmeans::emmeans(m2_lm, ~ L)
  print(summary(emm_L))
  cat("\n")

  h22_verdict <- sprintf(
    "H2.2 NOT SUPPORTED: L × E interaction not significant (F = %.3f, p = %.4f). Null result; 90%% CI on interaction term reported above. E and L marginal means reported descriptively.",
    ifelse(is.na(interaction_row$statistic), NA, interaction_row$statistic),
    ifelse(is.na(interaction_row$p.value), NA, interaction_row$p.value)
  )
}
cat(sprintf("\nH2.2 VERDICT: %s\n\n", h22_verdict))

# =============================================================================
# 4.3 H2.3 — CALIBRATION INTERVENTION ON MISCALIBRATION RESIDUAL (§9.1)
#     CONDITIONAL ON STUDY 1 H4 BEING SUPPORTED
# =============================================================================

cat("=============================================================\n")
cat("4.3 H2.3 — CALIBRATION EFFECT ON M4 RESIDUAL (§9.1)\n")
cat(sprintf("H4_SUPPORTED (Study 1): %s\n", H4_SUPPORTED))
cat("=============================================================\n\n")

if (!H4_SUPPORTED) {
  cat("H2.3 is SKIPPED: Study 1 H4 not supported.\n")
  cat("Pre-registration §9.1: H2.3 is a pre-specified conditional test —\n")
  cat("run only if H4 is supported in Study 1. See study 2 design note §5.\n\n")
  h23_verdict <- "H2.3 SKIPPED (conditional test; Study 1 H4 not supported)"
} else {
  cat("H4 supported — running H2.3 on L2 conditions only.\n\n")

  # L2 participants
  # [Fixed tick-4246: JONY-ACTION HH resolved via FF option (a).
  # M4 (calibration_confidence) is now collected for ALL conditions (post-receipt
  # Q-AC confidence, instrument §11 updated). I1 participants are no longer NA;
  # df_L2 filter no longer needs !is.na(m4_residual) — all L2 rows have M4.]
  df_L2     <- df[df$L == "confirmation_code", ]
  df_L2_I1  <- df_L2[df_L2$I == "no_calibration", ]  # n=60 target (pools E1+E2 within L2); has M4 (post-receipt)
  df_L2_I2  <- df_L2[df_L2$I == "calibration", ]     # n=60 target (pools E1+E2 within L2); has M4 (post-receipt)

  cat(sprintf("L2 analytic n: I1 = %d, I2 = %d\n", nrow(df_L2_I1), nrow(df_L2_I2)))

  # M4 residual: one-tailed t-test, prediction I1 > I2 (calibration reduces residual)
  if (nrow(df_L2_I1) > 1 && nrow(df_L2_I2) > 1) {
    t_h23 <- t.test(df_L2_I1$m4_residual, df_L2_I2$m4_residual,
                    alternative = "greater", var.equal = FALSE)
    # Cohen's d for M4 t-test (pre-reg §6.4: "Report Cohen's d + 95% CI"; Amendment 15)
    m4_n1   <- nrow(df_L2_I1); m4_n2 <- nrow(df_L2_I2)
    m4_sd1  <- sd(df_L2_I1$m4_residual, na.rm = TRUE)
    m4_sd2  <- sd(df_L2_I2$m4_residual, na.rm = TRUE)
    m4_sp   <- sqrt(((m4_n1 - 1) * m4_sd1^2 + (m4_n2 - 1) * m4_sd2^2) / (m4_n1 + m4_n2 - 2))
    m4_diff <- mean(df_L2_I1$m4_residual, na.rm = TRUE) - mean(df_L2_I2$m4_residual, na.rm = TRUE)
    m4_d    <- m4_diff / m4_sp
    # Two-sided 95% CI on Cohen's d: Hedges & Olkin (1985) SE approximation
    m4_se_d    <- sqrt(1/m4_n1 + 1/m4_n2 + m4_d^2 / (2 * (m4_n1 + m4_n2 - 2)))
    m4_d_ci_lo <- m4_d - qt(0.975, df = t_h23$parameter) * m4_se_d
    m4_d_ci_hi <- m4_d + qt(0.975, df = t_h23$parameter) * m4_se_d
    cat(sprintf("M4 residual (I1 vs. I2, L2 only): t(%s) = %.3f, p(one-tailed) = %.4f\n",
                round(t_h23$parameter, 1), t_h23$statistic, t_h23$p.value))
    # [Fixed tick-4297: diff in sprintf incorrectly used t_h23$conf.int[1] (CI lower bound)
    # instead of the actual mean difference; conf.int[1] was also printed twice. Fixed:
    # compute m4_diff directly. Cohen's d + two-sided 95% CI added per pre-reg §6.4
    # (Amendment 15). No hypothesis, test, or verdict change.]
    cat(sprintf("  I1 mean = %.3f; I2 mean = %.3f; diff = %.3f; Cohen's d = %.3f [%.3f, %.3f]\n",
                mean(df_L2_I1$m4_residual, na.rm = TRUE),
                mean(df_L2_I2$m4_residual, na.rm = TRUE),
                m4_diff, m4_d, m4_d_ci_lo, m4_d_ci_hi))

    # M3 save intention equivalence test: I1 ≈ I2 in L2 (TOST, bounds ±0.5 SD)
    save_sd <- sd(df_L2$m3_save, na.rm = TRUE)
    bounds  <- EQUIV_BOUNDS_SAVE * save_sd
    cat(sprintf("\nM3 save intention equivalence (L2): bounds = ±%.2f (%.2f × SD=%.2f)\n",
                bounds, EQUIV_BOUNDS_SAVE, save_sd))

    tost_h23 <- TOSTER::tsum_TOST(
      m1 = mean(df_L2_I1$m3_save, na.rm = TRUE),
      m2 = mean(df_L2_I2$m3_save, na.rm = TRUE),
      sd1 = sd(df_L2_I1$m3_save, na.rm = TRUE),
      sd2 = sd(df_L2_I2$m3_save, na.rm = TRUE),
      n1 = nrow(df_L2_I1),
      n2 = nrow(df_L2_I2),
      low_eqbound  = -bounds,
      high_eqbound =  bounds,
      alpha = 0.05,
      var.equal = FALSE
    )
    cat("TOST result (M3 equivalence):\n")
    print(tost_h23)

    # Version-agnostic TOST p-value extraction.
    # TOSTER v0.3.x returned $TOST_p1 / $TOST_p2 directly on the list.
    # TOSTER v0.4+ returns an object of class "TOSTt" whose $TOST slot is a
    # data frame with a "p.value" column (two rows: lower and upper bound tests).
    # Using !is.null(tost_h23$TOST_p1) as the only guard silently evaluates to
    # FALSE on v0.4+, causing the equivalence verdict to always print
    # "NOT ESTABLISHED" regardless of the actual test result.
    tost_pmax <- if (!is.null(tost_h23$TOST_p1) && !is.null(tost_h23$TOST_p2)) {
      max(tost_h23$TOST_p1, tost_h23$TOST_p2, na.rm = TRUE)      # TOSTER v0.3.x
    } else if (!is.null(tost_h23[["TOST"]]) &&
               "p.value" %in% names(tost_h23[["TOST"]])) {
      max(tost_h23[["TOST"]][["p.value"]], na.rm = TRUE)           # TOSTER v0.4+
    } else {
      NA_real_  # Unknown structure — print() output above is the authoritative reference
    }

    # If equivalence not established: report M3 Cohen's d + 90% CI (pre-reg §6.4)
    # [Fixed tick-4303/Amendment 19: this fallback was missing; pre-reg §6.4 specifies
    # "If equivalence not established, report M3 Cohen's d and 90% CI."]
    if (is.na(tost_pmax) || tost_pmax >= 0.05) {
      cat("Equivalence not established — reporting M3 Cohen's d + 90% CI (pre-reg §6.4):\n")
      m3_n1   <- nrow(df_L2_I1); m3_n2 <- nrow(df_L2_I2)
      m3_m1   <- mean(df_L2_I1$m3_save, na.rm = TRUE)
      m3_m2   <- mean(df_L2_I2$m3_save, na.rm = TRUE)
      m3_sd1  <- sd(df_L2_I1$m3_save, na.rm = TRUE)
      m3_sd2  <- sd(df_L2_I2$m3_save, na.rm = TRUE)
      m3_sp   <- sqrt(((m3_n1 - 1) * m3_sd1^2 + (m3_n2 - 1) * m3_sd2^2) /
                      (m3_n1 + m3_n2 - 2))
      m3_d    <- (m3_m1 - m3_m2) / m3_sp
      # Welch df for 90% CI (from independent t.test on M3 save)
      t_m3    <- t.test(df_L2_I1$m3_save, df_L2_I2$m3_save, var.equal = FALSE)
      m3_se_d <- sqrt(1/m3_n1 + 1/m3_n2 + m3_d^2 / (2 * (m3_n1 + m3_n2 - 2)))
      # 90% two-sided CI: ±t(0.95, df_welch) × SE
      m3_d_ci_lo <- m3_d - qt(0.95, df = t_m3$parameter) * m3_se_d
      m3_d_ci_hi <- m3_d + qt(0.95, df = t_m3$parameter) * m3_se_d
      cat(sprintf("  M3 save intent Cohen's d = %.3f [90%% CI: %.3f, %.3f]\n",
                  m3_d, m3_d_ci_lo, m3_d_ci_hi))
      cat(sprintf("  (I1 mean=%.2f, SD=%.2f; I2 mean=%.2f, SD=%.2f)\n",
                  m3_m1, m3_sd1, m3_m2, m3_sd2))
    }

    h23_mismatch_note <- if (nrow(df_L2_I1) < 30 || nrow(df_L2_I2) < 30) {
      sprintf(
        "\n*** POWER WARNING: L2 subgroup n < 30 per cell (I1=%d, I2=%d). Test may be underpowered. See §10.3 — consider Study 2b. ***",
        nrow(df_L2_I1), nrow(df_L2_I2))
    } else { "" }

    h23_verdict <- sprintf(
      "H2.3: Calibration t-test p(one-tailed) = %.4f (%s); TOST equivalence on save intent: %s.%s",
      t_h23$p.value,
      if (t_h23$p.value < 0.05) "SUPPORTED — residual reduced" else "NOT SUPPORTED",
      if (!is.na(tost_pmax) && tost_pmax < 0.05)
        "EQUIVALENT (save intent preserved)" else "NOT ESTABLISHED",
      h23_mismatch_note
    )
  } else {
    cat("Insufficient L2 observations for H2.3.\n")
    h23_verdict <- "H2.3 SKIPPED (insufficient L2 observations)"
  }
  cat(sprintf("\nH2.3 VERDICT: %s\n\n", h23_verdict))
}

# =============================================================================
# 4.4 H2.4 — M1 PREDICTS M3 DOWNLOAD CLICK (§9.1)
# =============================================================================

cat("=============================================================\n")
cat("4.4 H2.4 — M1 ACCURACY PREDICTS M3 DOWNLOAD CLICK (§9.1)\n")
cat("Prediction: Q-AC accuracy (M1=1) predicts higher download click rate\n")
cat("=============================================================\n\n")

df_lr <- df[!is.na(df$m3_click) & !is.na(df$m1_qac) &
            !is.na(df$L) & !is.na(df$E) & !is.na(df$I), ]

# Primary logistic regression: download_click ~ M1 + L + E + I (main effects)
lr_primary <- glm(m3_click ~ m1_qac + L + E + I,
                  data = df_lr, family = binomial())
lr_summary <- broom::tidy(lr_primary, exponentiate = TRUE, conf.int = TRUE)
cat("Primary logistic regression (download click ~ M1 + L + E + I):\n")
print(lr_summary[, c("term","estimate","conf.low","conf.high","p.value")])
cat("\n")

# OR for M1
m1_row <- lr_summary[lr_summary$term == "m1_qac", ]
if (nrow(m1_row) > 0) {
  cat(sprintf("M1 (Q-AC accuracy): OR = %.2f [%.2f, %.2f], p = %.4f\n",
              m1_row$estimate, m1_row$conf.low, m1_row$conf.high, m1_row$p.value))
  h24_sig <- m1_row$p.value < 0.05 && m1_row$estimate > 1
  h24_verdict <- if (h24_sig) {
    sprintf("H2.4 SUPPORTED: Correct absent-content interpretation predicts higher download click (OR = %.2f, p = %.4f).",
            m1_row$estimate, m1_row$p.value)
  } else {
    sprintf("H2.4 NOT SUPPORTED: M1 does not significantly predict download click (OR = %.2f, p = %.4f).",
            m1_row$estimate, m1_row$p.value)
  }
}
cat(sprintf("\nH2.4 VERDICT: %s\n\n", h24_verdict))

# [EXPLORATORY] M1 × L interaction — stronger effect in fingerprint condition?
cat("[EXPLORATORY] M1 × L interaction (§9.1 exploratory):\n")
lr_exp <- glm(m3_click ~ m1_qac * L + E + I,
              data = df_lr, family = binomial())
lr_exp_tidy <- broom::tidy(lr_exp, exponentiate = TRUE, conf.int = TRUE)
int_row_exp <- lr_exp_tidy[grepl("m1_qac:L", lr_exp_tidy$term), ]
if (nrow(int_row_exp) > 0) {
  cat(sprintf("  M1 × L interaction: OR = %.2f, p = %.4f\n",
              int_row_exp$estimate, int_row_exp$p.value))
} else {
  cat("  Interaction term not found; check factor level names.\n")
}
cat("  *** EXPLORATORY — not pre-registered. ***\n\n")

} # end if (!PILOT)

# =============================================================================
# 5. SECONDARY / EXPLORATORY MEASURES
# =============================================================================

cat("=============================================================\n")
cat("5. SECONDARY AND EXPLORATORY MEASURES\n")
cat("=============================================================\n\n")

# M5: Verification instruction engagement by E
cat("[EXPLORATORY] M5 Verify expansion rate by E:\n")
print(tapply(df$m5_expand, df$E, function(x)
  sprintf("%.1f%% (n=%d)", 100*mean(x, na.rm=TRUE), sum(!is.na(x)))))
cat("Expected: E1 > E2 (explanation establishes verification purpose first).\n\n")

# M5 by L × E
cat("[EXPLORATORY] M5 Verify expansion rate by L × E cell:\n")
print(100 * round(tapply(df$m5_expand, list(df$L, df$E), mean, na.rm = TRUE), 3))
cat("\n")

# M6: Open-text quality — GATED on κ ≥ 0.70 (pre-reg §6.7: required before any Q-OE analysis).
# [Amendment 20 (pre-data): previously ungated — KW and descriptives ran even if κ < 0.70.]
if (kappa_ok) {
  cat("[EXPLORATORY] M6 Q-OE mean rater score by E:\n")
  print(tapply(df$m6_qoe, df$E, function(x)
    sprintf("mean=%.2f, sd=%.2f, n=%d", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE), sum(!is.na(x)))))
  cat("\n")

  if (!PILOT) {
    # Kruskal-Wallis on M6 across all 8 conditions (pre-specified supplementary, §6.7)
    kw_m6 <- kruskal.test(m6_qoe ~ condition_f, data = df)
    cat("[EXPLORATORY] Kruskal-Wallis M6 across 8 conditions:\n")
    print(kw_m6)
    if (kw_m6$p.value < 0.05) {
      cat("Significant — Dunn post-hoc (Holm):\n")
      dunn_m6 <- dunn.test::dunn.test(df$m6_qoe, df$condition_f,
                                       method = "holm", kw = FALSE, label = TRUE)
    }
    cat("  *** EXPLORATORY ***\n\n")
  }
} else {
  cat("[M6 Q-OE analysis skipped — κ < 0.70 threshold not met.\n")
  cat("  Score/rescore Q-OE data after rater adjudication and re-run (§6.7, pre-reg).\n\n")
}

if (!PILOT) {
  # M4 residual descriptives across I conditions (all L)
  cat("[EXPLORATORY] M4 Calibration residual by I (all conditions; all L):\n")
  # [Fixed tick-4246: M4 now all conditions; no NA filter needed]
  df_I2 <- df[!is.na(df$m4_residual), ]
  print(tapply(df_I2$m4_residual, df_I2$L, function(x)
    sprintf("mean=%.3f, sd=%.3f, n=%d", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE), sum(!is.na(x)))))
  cat("Positive residual = over-confidence; H4 from Study 1 predicts L2 > L1.\n\n")
}

# --- Pre-specified sensitivity: H2.1 excluding browser-fallback participants (§9.3) ---
if (!PILOT) {
  cat("[SENSITIVITY] H2.1 re-run excluding browser-fallback participants (§9.3):\n")
  df_no_fallback   <- df[df[[COL_BROWSER_FALLBACK]] == 0 | is.na(df[[COL_BROWSER_FALLBACK]]), ]
  n_fbk_excluded   <- nrow(df) - nrow(df_no_fallback)
  if (n_fbk_excluded > 0) {
    E1_nb <- df_no_fallback$E == "explanation_present"
    E2_nb <- df_no_fallback$E == "explanation_absent"
    h21_nb <- two_prop_chisq_one_tailed(
      sum(E1_nb, na.rm = TRUE),
      sum(df_no_fallback$m1_qac[E1_nb], na.rm = TRUE),
      sum(E2_nb, na.rm = TRUE),
      sum(df_no_fallback$m1_qac[E2_nb], na.rm = TRUE),
      direction = "greater"
    )
    cat(sprintf("  Excluding %d browser-fallback participant(s) (N=%d remaining):\n",
                n_fbk_excluded, nrow(df_no_fallback)))
    cat(sprintf("  %s\n", fmt_binary_result(h21_nb)))
    cat(sprintf("  Sensitivity verdict: %s\n",
                if (h21_nb$p_one < 0.05)
                  "H2.1 SUPPORTED in full-prototype-only sample (result robust)"
                else
                  "H2.1 NOT SUPPORTED in full-prototype-only sample (browser-fallback may have affected primary result)"))
  } else {
    cat("  No browser-fallback participants detected — sensitivity check not applicable.\n")
  }
  cat("  *** PRE-SPECIFIED SENSITIVITY (§9.3) ***\n\n")
}

# --- Pre-specified sensitivity: H2.4 excluding browser-fallback participants (§9.3) ---
# download_clicked = 0 for fallback participants is an ARTIFACT of rendering failure:
# static screenshots have no interactive button, so behavioural download click cannot be
# observed. The H2.4 logistic regression (download_click ~ M1 + L + E + I) is therefore
# contaminated if fallback participants are included. This sensitivity re-runs H2.4 excluding
# them, and is the most important §9.3 sensitivity for H2.4.
if (!PILOT) {
  cat("[SENSITIVITY] H2.4 re-run excluding browser-fallback participants (§9.3):\n")
  n_fbk_h24 <- sum(df[[COL_BROWSER_FALLBACK]] == 1, na.rm = TRUE)
  if (n_fbk_h24 > 0) {
    df_no_fbk_h24 <- df[df[[COL_BROWSER_FALLBACK]] == 0 | is.na(df[[COL_BROWSER_FALLBACK]]), ]
    df_lr_nb <- df_no_fbk_h24[
      !is.na(df_no_fbk_h24$m3_click) & !is.na(df_no_fbk_h24$m1_qac) &
      !is.na(df_no_fbk_h24$L) & !is.na(df_no_fbk_h24$E) & !is.na(df_no_fbk_h24$I), ]
    lr_nb_h24 <- glm(m3_click ~ m1_qac + L + E + I, data = df_lr_nb, family = binomial())
    lr_nb_h24_tidy <- broom::tidy(lr_nb_h24, exponentiate = TRUE, conf.int = TRUE)
    m1_nb_row <- lr_nb_h24_tidy[lr_nb_h24_tidy$term == "m1_qac", ]
    cat(sprintf("  Excluding %d browser-fallback participant(s) (N=%d remaining in LR):\n",
                n_fbk_h24, nrow(df_lr_nb)))
    if (nrow(m1_nb_row) > 0) {
      cat(sprintf("  M1 (Q-AC accuracy): OR = %.2f [%.2f, %.2f], p = %.4f\n",
                  m1_nb_row$estimate, m1_nb_row$conf.low, m1_nb_row$conf.high, m1_nb_row$p.value))
      cat(sprintf("  Sensitivity verdict: %s\n",
                  if (m1_nb_row$p.value < 0.05 && m1_nb_row$estimate > 1)
                    "H2.4 SUPPORTED in full-prototype-only sample (result robust)"
                  else
                    "H2.4 NOT SUPPORTED in full-prototype-only sample (browser-fallback contamination may have affected download_clicked)"))
    } else {
      cat("  m1_qac term not found in sensitivity LR — check factor levels.\n")
    }
  } else {
    cat("  No browser-fallback participants detected — sensitivity check not applicable.\n")
  }
  cat("  NOTE: download_clicked = 0 for fallback Ps is an artefact (no interactive button in static screenshot).\n")
  cat("  *** PRE-SPECIFIED SENSITIVITY (§9.3) ***\n\n")
}

# =============================================================================
# §6.8 PRE-SPECIFIED SENSITIVITY: PRIOR VOTING-RECEIPT STUDY PARTICIPANTS
# =============================================================================
# Pre-registration §6.8: "Re-run H2.1 and H2.4 excluding prior_receipt_study = 1
# participants. Report both primary and sensitivity-check results."
# [Added tick-4301/Amendment 17]

if (n_prior_study > 0) {
  df_no_prior <- df[is.na(df[[COL_PRIOR_STUDY]]) | df[[COL_PRIOR_STUDY]] != 1, ]
  cat("[SENSITIVITY] §6.8 re-run excluding prior_receipt_study = 1 participants:\n")
  cat(sprintf("  Excluding %d prior-study participant(s); N remaining = %d\n",
              n_prior_study, nrow(df_no_prior)))

  # H2.1 sensitivity: E main effect on Q-AC
  E1_np <- df_no_prior$E == "explanation_present"
  E2_np <- df_no_prior$E == "explanation_absent"
  h21_np <- two_prop_chisq_one_tailed(
    sum(E1_np, na.rm = TRUE),
    sum(df_no_prior$m1_qac[E1_np], na.rm = TRUE),
    sum(E2_np, na.rm = TRUE),
    sum(df_no_prior$m1_qac[E2_np], na.rm = TRUE),
    direction = "greater"
  )
  cat(sprintf("  H2.1 excl. prior-study: %s\n", fmt_binary_result(h21_np)))
  cat(sprintf("  H2.1 sensitivity verdict: %s\n",
              if (h21_np$p_one < 0.05)
                "H2.1 SUPPORTED excl. prior-study (result robust)"
              else
                "H2.1 NOT SUPPORTED excl. prior-study (prior-study contamination may have affected primary result)"))

  # H2.4 sensitivity: M1 predicts M3 download click
  lr_np <- glm(m3_click ~ m1_qac + L + E + I, data = df_no_prior, family = binomial())
  lr_np_tidy <- broom::tidy(lr_np, exponentiate = TRUE, conf.int = TRUE)
  m1_np_row <- lr_np_tidy[lr_np_tidy$term == "m1_qac", ]
  if (nrow(m1_np_row) > 0) {
    cat(sprintf("  H2.4 excl. prior-study: OR = %.2f [%.2f, %.2f]; p = %.4f\n",
                m1_np_row$estimate, m1_np_row$conf.low, m1_np_row$conf.high,
                m1_np_row$p.value))
    cat(sprintf("  H2.4 sensitivity verdict: %s\n",
                if (m1_np_row$p.value < 0.05 && m1_np_row$estimate > 1)
                  "H2.4 SUPPORTED excl. prior-study (result robust)"
                else
                  "H2.4 NOT SUPPORTED excl. prior-study (prior-study participants may have affected primary result)"))
  } else {
    cat("  H2.4: m1_qac term not found in sensitivity model — check factor levels.\n")
  }
  cat("  *** PRE-SPECIFIED SENSITIVITY (§6.8) ***\n\n")
} else {
  cat("[SENSITIVITY] §6.8: No prior-study participants in analytic sample — sensitivity not applicable.\n\n")
}

# =============================================================================
# 6. SUMMARY TABLE — ALL PRE-SPECIFIED CONFIRMATORY TESTS
# =============================================================================

if (!PILOT) {

cat("=============================================================\n")
cat("6. SUMMARY — ALL PRE-SPECIFIED CONFIRMATORY TESTS\n")
cat("=============================================================\n\n")

# Build summary table
summary_tests <- data.frame(
  family      = c("H2.1", "H2.2", "H2.3", "H2.4"),
  description = c(
    "E main effect on Q-AC accuracy (E1 > E2, one-tailed chi-squared)",
    "L × E interaction on M2 trust (two-way ANOVA; simple effects if F sig.)",
    "I2 reduces M4 miscalibration residual in L2 [CONDITIONAL on Study 1 H4]",
    "M1 (Q-AC accuracy) predicts M3 download click (logistic regression)"
  ),
  p_value   = round(c(
    h21_result$p_one,
    ifelse(nrow(interaction_row) > 0, interaction_row$p.value, NA),
    NA,  # H2.3 p extracted from h23_verdict text; see above
    ifelse(exists("m1_row") && nrow(m1_row) > 0, m1_row$p.value, NA)
  ), 4),
  significant = c(
    h21_sig,
    h22_interaction_sig,
    NA,  # H2.3 conditional
    ifelse(exists("h24_sig"), h24_sig, NA)
  ),
  verdict     = c(
    h21_verdict,
    h22_verdict,
    h23_verdict,
    ifelse(exists("h24_verdict"), h24_verdict, "H2.4 — see above")
  ),
  stringsAsFactors = FALSE
)

print(summary_tests[, c("family","p_value","significant")])
cat("\n")
for (i in seq_len(nrow(summary_tests))) {
  cat(sprintf("[%s] %s\n", summary_tests$family[i], summary_tests$verdict[i]))
}
write.csv(summary_tests, file.path(RESULTS_DIR, "confirmatory_tests_summary_study2.csv"),
          row.names = FALSE)
cat("\nSummary table written to:",
    file.path(RESULTS_DIR, "confirmatory_tests_summary_study2.csv"), "\n\n")

# =============================================================================
# 7. PRODUCTION / DESIGN DECISION (§3 — contingency table)
# =============================================================================

cat("=============================================================\n")
cat("7. DESIGN DECISION (§3 contingency)\n")
cat("=============================================================\n\n")

h21_sup <- h21_result$p_one < 0.05
h22_sup <- h22_interaction_sig

design_decision <- if (h21_sup && h22_sup) {
  "Explanation copy is the primary load-bearing element (H2.1 supported). Label × Explanation interaction confirmed (H2.2): fingerprint + explanation is the strongest combination. DEPLOY L1E1 (vote fingerprint + absent-choice explanation) as the production default."
} else if (h21_sup && !h22_sup) {
  "Explanation copy drives accuracy improvement (H2.1 supported) with no significant label moderation (H2.2 null). Explanation is necessary; label is not independently causal. DEPLOY with explanation copy regardless of label choice."
} else if (!h21_sup && h22_sup) {
  "Explanation has no main effect on accuracy (H2.1 null), but label × explanation interaction exists (H2.2). Check simple effects to determine which L × E combination is superior."
} else {
  "Neither explanation effect nor interaction is significant. Absent-content accuracy may be ceiling in these conditions (check §11.2 ceiling note) or the receipt design requires broader revision. FLAG for Jony — do not change production defaults without further investigation."
}
cat(sprintf("DESIGN DECISION: %s\n\n", design_decision))

} # end if (!PILOT)

# =============================================================================
# 8. PILOT INSTRUMENT VALIDATION (PILOT mode only)
# =============================================================================

if (PILOT) {

cat("=============================================================\n")
cat("8. PILOT INSTRUMENT VALIDATION (N per cell ≈ 5–10)\n")
cat("=============================================================\n\n")

cat("M2 Trust composite — internal consistency check:\n")
trust_alpha_msg <- if (exists("alpha_raw")) {
  sprintf("α = %.3f (%s)", alpha_raw, if (alpha_raw < 0.70) "BELOW THRESHOLD" else "OK")
} else "Not computed"
cat("  ", trust_alpha_msg, "\n\n")

cat("Floor/ceiling on M1 (Q-AC) by condition:\n")
for (cond in CONDITIONS) {
  sub_c <- df[df[[COL_CONDITION]] == cond, ]
  n_c   <- nrow(sub_c)
  prop  <- mean(sub_c$m1_qac, na.rm = TRUE)
  flag  <- if (prop < 0.20) "*** FLOOR ***" else if (prop > 0.90) "*** CEILING ***" else ""
  cat(sprintf("  %s: %.1f%% (n=%d) %s\n", cond, 100*prop, n_c, flag))
}

cat("\nM3 save intention distribution:\n")
print(table(df$m3_save, useNA = "always"))

cat("\nVerification instruction engagement by condition:\n")
print(tapply(df$m5_expand, df[[COL_CONDITION]], mean, na.rm = TRUE))

cat("\nTask completion time (seconds):\n")
print(summary(df[[COL_RT_SEC]]))
med_rt <- median(df[[COL_RT_SEC]], na.rm = TRUE)
if (med_rt < 480 || med_rt > 900) {
  cat("*** WARNING: Median time outside 8–15 min target. Adjust task length before full study. ***\n")
}

cat("\nAttention check pass rates:\n")
cat(sprintf("  Passed ATTN1: %d/%d (%.1f%%)\n",
            sum(df[[COL_ATTN1]] == 1, na.rm=TRUE), nrow(df),
            100 * mean(df[[COL_ATTN1]] == 1, na.rm=TRUE)))
cat(sprintf("  Passed ATTN2: %d/%d (%.1f%%)\n",
            sum(df[[COL_ATTN2]] == 1, na.rm=TRUE), nrow(df),
            100 * mean(df[[COL_ATTN2]] == 1, na.rm=TRUE)))

cat("\nM6 inter-rater spot check (kappa, if available):\n")
rater_pilot <- df[, c(COL_QOE_RATER1, COL_QOE_RATER2)]
rater_pilot_complete <- rater_pilot[complete.cases(rater_pilot), ]
if (nrow(rater_pilot_complete) > 2) {
  k_pilot <- irr::kappa2(rater_pilot_complete, weight = "unweighted")
  cat(sprintf("  κ = %.3f (n=%d pairs) — %s\n",
              k_pilot$value, k_pilot$subjects,
              if (k_pilot$value < 0.60) "LOW — revise coding guide before full study"
              else "Acceptable for pilot"))
}

cat("\n*** PILOT MODE: Hypothesis tests SUPPRESSED per pre-registration §7.1. ***\n")
# [Amendment 21 (pre-data): §9 corrected to §7.1 — pre-reg §9 is Open Science Commitments;
# pilot HT suppression is specified in pre-registration §7.1: "NOT used for hypothesis testing".]
cat("*** Pilot data will NOT be combined with full-study data. ***\n\n")

}

# =============================================================================
# 9. SESSION INFO
# =============================================================================

cat("=============================================================\n")
cat("9. SESSION INFO\n")
cat("=============================================================\n\n")
print(sessionInfo())

cat("\n--- Study 2 Analysis Complete ---\n")
cat(sprintf("Results written to: %s/\n", RESULTS_DIR))
cat("Files: descriptives_study2.csv, confirmatory_tests_summary_study2.csv\n\n")
cat("Design note: docs/piup-study2-design-note-2026-06-22.md\n")
cat("Study 1 reference: docs/piup-study1-preregistration-2026-06-22.md\n")
cat("Upload this script (piup-study2-analysis.R) and piup-study2-drycheck.R to OSF before\n")
cat("pilot launch (pre-registration §9). Remove synthetic data generator block first.\n")
# [Amendment 21 (pre-data): added piup-study2-drycheck.R upload requirement (pre-reg §9
# lists both scripts); changed "data collection" to "pilot launch" to match §9 wording.]
cat("Set H4_SUPPORTED to match Study 1 verdict before final run.\n")
cat("Any deviation from the pre-registration must be documented in the amendments log.\n")
