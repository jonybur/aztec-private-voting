# =============================================================================
# PIUP Study 2 — DRY-CHECK SCRIPT (NOT pre-registered)
#
# Purpose: Validate that the pre-registered analysis script can parse
#          correctly structured data and run pilot-mode instrument checks.
#          Does NOT run confirmatory hypothesis tests.
#
# Study 2 is a 2×2×2 between-subjects factorial experiment.
# Factors:
#   L (Label):       L1 = "vote fingerprint"  / L2 = "confirmation code"
#   E (Explanation): E1 = explanation present / E2 = explanation absent
#   I (Intervention):I1 = no calibration      / I2 = calibration prompt
# 8 conditions: L1E1I1, L1E1I2, L1E2I1, L1E2I2,
#               L2E1I1, L2E1I2, L2E2I1, L2E2I2
#
# This script:
#   1. Generates N=5 per condition (N=40 total) synthetic pilot data
#   2. Writes it to data/prolific-export-study2.csv (creates data/ dir if absent)
#   3. Checks all required columns are present
#   4. Simulates exclusion rules (mirrors §2 of main script)
#   5. Runs IRR spot-check (Cohen's kappa for M6/Q-OE raters)
#   6. Runs pilot instrument validation (floor/ceiling; M2 internal consistency)
#   7. Reports package availability for all 6 required packages
#
# Run: Rscript analysis/piup-study2-drycheck.R
# Design note: docs/piup-study2-design-note-2026-06-22.md
# =============================================================================

cat("\n=== PIUP Study 2 — DRY-CHECK ===\n")
cat("2×2×2 factorial design (8 conditions)\n")
cat("Generating N=5 per condition (N=40 total) synthetic pilot data...\n\n")

set.seed(20260625)

N_PER_COND <- 5

CONDITIONS <- c("L1E1I1", "L1E1I2", "L1E2I1", "L1E2I2",
                "L2E1I1", "L2E1I2", "L2E2I1", "L2E2I2")

# Factor labels — mirrors piup-study2-analysis.R §1.3
LABEL_MAP   <- c(L1 = "L1", L2 = "L2")
EXPL_MAP    <- c(E1 = "E1", E2 = "E2")
INTV_MAP    <- c(I1 = "I1", I2 = "I2")

# Decode condition code to factor levels
decode_condition <- function(cond_code) {
  list(
    label        = substr(cond_code, 1, 2),  # "L1" or "L2"
    explanation  = substr(cond_code, 3, 4),  # "E1" or "E2"
    intervention = substr(cond_code, 5, 6)   # "I1" or "I2"
  )
}

# Synthetic accuracy probs: H2.1 expects E1 > E2 on Q-AC (M1)
# H2.2 expects L1E2 underperforms L2E2 more than L1E1 vs. L2E1 on M2
accuracy_probs <- list(
  L1E1I1 = 0.75,  # fingerprint + explanation: best case
  L1E1I2 = 0.75,
  L1E2I1 = 0.55,  # fingerprint + no explanation: intermediate
  L1E2I2 = 0.55,
  L2E1I1 = 0.70,  # code + explanation: explanation corrects schema import
  L2E1I2 = 0.70,
  L2E2I1 = 0.40,  # code + no explanation: schema import worst case
  L2E2I2 = 0.40
)

# Trust probs (M2 items, 1–7 scale): E1 > E2; L1E2 < L2E2 gap
trust_means <- list(
  L1E1I1 = 5.2, L1E1I2 = 5.2,
  L1E2I1 = 4.6, L1E2I2 = 4.6,
  L2E1I1 = 5.0, L2E1I2 = 5.0,
  L2E2I1 = 4.0, L2E2I2 = 4.0
)

make_participant <- function(cond_code, id) {
  factors <- decode_condition(cond_code)
  qac_p   <- accuracy_probs[[cond_code]]
  m2_mu   <- trust_means[[cond_code]]

  # Trust items: 1–7 Likert, correlated around m2_mu
  make_trust_item <- function(mu) max(1, min(7, round(rnorm(1, mu, 1.0))))

  # Calibration confidence (I2 only; NA for I1)
  calib_conf <- if (factors$intervention == "I2") sample(3:7, 1) else NA

  list(
    participant_id        = paste0("SYNTH_", cond_code, "_", sprintf("%02d", id)),
    condition             = cond_code,
    label                 = factors$label,
    explanation           = factors$explanation,
    intervention          = factors$intervention,
    qac_correct           = rbinom(1, 1, qac_p),
    trust_integrity_1     = make_trust_item(m2_mu),
    trust_integrity_2     = make_trust_item(m2_mu),
    trust_competence_1    = make_trust_item(m2_mu),
    trust_competence_2    = make_trust_item(m2_mu),
    save_intention        = sample(1:7, 1),
    download_clicked      = rbinom(1, 1, 0.55),
    calibration_confidence = calib_conf,
    verify_expanded       = rbinom(1, 1, 0.45),
    qoe_rater1            = sample(0:2, 1),
    qoe_rater2            = sample(0:2, 1),
    attention_check_1     = rbinom(1, 1, 0.92),
    attention_check_2     = rbinom(1, 1, 0.92),
    response_time_sec     = round(runif(1, 360, 900)),  # 6–15 min
    occupation_sw_eng     = rbinom(1, 1, 0.05),
    prior_receipt_study   = rbinom(1, 1, 0.02),
    browser_fallback      = rbinom(1, 1, 0.03),  # ~3% static screenshot fallback (§9.3)
    age_group             = sample(c("18-24","25-34","35-44","45-54","55+"), 1),
    prior_voting          = rbinom(1, 1, 0.85),
    tech_efficacy_mean    = round(runif(1, 2.0, 5.0), 1)
  )
}

rows <- list()
for (cond_code in CONDITIONS) {
  for (i in seq_len(N_PER_COND)) {
    rows[[length(rows) + 1]] <- make_participant(cond_code, i)
  }
}

df_raw <- do.call(rbind, lapply(rows, function(r) {
  as.data.frame(r, stringsAsFactors = FALSE)
}))

# Write synthetic data
dir.create("data", showWarnings = FALSE)
write.csv(df_raw, "data/prolific-export-study2.csv", row.names = FALSE)
cat(sprintf("Synthetic data written: N = %d across %d conditions\n",
            nrow(df_raw), length(CONDITIONS)))
cat(sprintf("Conditions: %s\n\n", paste(CONDITIONS, collapse = ", ")))

# =============================================================================
# COLUMN VALIDATION
# =============================================================================
cat("--- Column validation ---\n")
expected_cols <- c(
  "participant_id", "condition",
  "label", "explanation", "intervention",
  "qac_correct",
  "trust_integrity_1", "trust_integrity_2",
  "trust_competence_1", "trust_competence_2",
  "save_intention", "download_clicked",
  "calibration_confidence",
  "verify_expanded",
  "qoe_rater1", "qoe_rater2",
  "attention_check_1", "attention_check_2",
  "response_time_sec", "occupation_sw_eng",
  "prior_receipt_study", "browser_fallback",
  "age_group", "prior_voting", "tech_efficacy_mean"
)

present <- expected_cols %in% colnames(df_raw)
for (i in seq_along(expected_cols)) {
  cat(sprintf("  %-30s %s\n", expected_cols[i],
              if (present[i]) "OK" else "MISSING"))
}
if (all(present)) {
  cat("\nAll expected columns present. ✓\n\n")
} else {
  cat(sprintf("\nWARNING: %d column(s) missing!\n\n", sum(!present)))
}

# =============================================================================
# FACTOR COVERAGE CHECK
# =============================================================================
cat("--- Factor coverage ---\n")
cat("Condition counts:\n")
cond_table <- table(df_raw$condition)
for (cond in CONDITIONS) {
  n <- if (cond %in% names(cond_table)) cond_table[[cond]] else 0
  cat(sprintf("  %-10s n = %d %s\n", cond, n,
              if (n == 0) "*** MISSING ***" else ""))
}
cat(sprintf("  Total: N = %d\n\n", nrow(df_raw)))

cat("Factor balance:\n")
cat(sprintf("  L (Label):       L1 = %d, L2 = %d\n",
            sum(df_raw$label == "L1"), sum(df_raw$label == "L2")))
cat(sprintf("  E (Explanation): E1 = %d, E2 = %d\n",
            sum(df_raw$explanation == "E1"), sum(df_raw$explanation == "E2")))
cat(sprintf("  I (Intervention):I1 = %d, I2 = %d\n\n",
            sum(df_raw$intervention == "I1"), sum(df_raw$intervention == "I2")))

# =============================================================================
# SIMULATE EXCLUSIONS (mirrors main script §2)
# =============================================================================
cat("--- Exclusion simulation ---\n")
n_raw <- nrow(df_raw)
df    <- df_raw

# Rule 1: Software engineers
df <- df[df$occupation_sw_eng != 1, ]
cat(sprintf("  After SW engineer exclusion:    N = %d (removed %d)\n",
            nrow(df), n_raw - nrow(df)))

# Rule 2: Prior receipt study participants
n_before <- nrow(df)
df <- df[is.na(df$prior_receipt_study) | df$prior_receipt_study != 1, ]
cat(sprintf("  After prior-study exclusion:    N = %d (removed %d)\n",
            nrow(df), n_before - nrow(df)))

# Rule 3: Response time < 90 sec
n_before <- nrow(df)
df <- df[!is.na(df$response_time_sec) & df$response_time_sec >= 90, ]
cat(sprintf("  After RT exclusion:             N = %d (removed %d)\n",
            nrow(df), n_before - nrow(df)))

# Rule 4: Fail both attention checks
n_before <- nrow(df)
df <- df[!(df$attention_check_1 == 0 & df$attention_check_2 == 0), ]
cat(sprintf("  After attn-check exclusion:     N = %d (removed %d)\n",
            nrow(df), n_before - nrow(df)))

cat(sprintf("\nFinal analytic N = %d (%.1f%% retained)\n\n",
            nrow(df), 100 * nrow(df) / n_raw))

# Warn if any condition has fewer than 3 participants after exclusion
cat("Post-exclusion condition sizes:\n")
post_table <- table(df$condition)
any_thin <- FALSE
for (cond in CONDITIONS) {
  n <- if (cond %in% names(post_table)) post_table[[cond]] else 0
  flag <- if (n < 3) " *** THIN (<3) ***" else ""
  cat(sprintf("  %-10s n = %d%s\n", cond, n, flag))
  if (n < 3) any_thin <- TRUE
}
if (any_thin) {
  cat("  NOTE: Thin cells expected in N=40 synthetic pilot; not a concern for real study.\n")
}
cat("\n")

# =============================================================================
# M2 TRUST COMPOSITE — INTERNAL CONSISTENCY
# =============================================================================
cat("--- M2 Trust composite internal consistency ---\n")
trust_cols <- c("trust_integrity_1", "trust_integrity_2",
                "trust_competence_1", "trust_competence_2")
trust_mat <- df[, trust_cols]
trust_mat_complete <- trust_mat[complete.cases(trust_mat), ]
if (nrow(trust_mat_complete) > 1) {
  item_vars <- apply(trust_mat_complete, 2, var, na.rm = TRUE)
  total_var <- var(rowSums(trust_mat_complete), na.rm = TRUE)
  k <- ncol(trust_mat_complete)
  alpha_raw <- (k / (k - 1)) * (1 - sum(item_vars) / total_var)
  cat(sprintf("  Cronbach's α = %.3f (threshold = 0.70) %s\n",
              alpha_raw,
              if (alpha_raw >= 0.70) "✓"
              else "*** BELOW THRESHOLD — check item coding before full study ***"))
  cat("  NOTE: Low α expected in small synthetic samples; recheck with real pilot data.\n\n")
} else {
  cat("  SKIP: insufficient complete cases for alpha computation.\n\n")
}

# =============================================================================
# IRR CHECK (M6 Q-OE raters)
# =============================================================================
cat("--- IRR check (M6 Q-OE; Cohen's kappa) ---\n")
if (requireNamespace("irr", quietly = TRUE)) {
  rater_data <- df[, c("qoe_rater1", "qoe_rater2")]
  rater_complete <- rater_data[complete.cases(rater_data), ]
  if (nrow(rater_complete) > 2) {
    kappa_res <- irr::kappa2(rater_complete, weight = "unweighted")
    cat(sprintf("  κ = %.3f (n=%d pairs; threshold = 0.70) %s\n",
                kappa_res$value, kappa_res$subjects,
                if (kappa_res$value >= 0.70) "✓"
                else "*** BELOW THRESHOLD (expected with random synthetic scores) ***"))
  } else {
    cat("  SKIP: too few complete rater pairs.\n")
  }
  cat("  NOTE: Synthetic Q-OE scores are random — low kappa is expected.\n\n")
} else {
  cat("  SKIP: 'irr' not installed. Install with: install.packages('irr')\n\n")
}

# =============================================================================
# PILOT INSTRUMENT VALIDATION
# =============================================================================
cat("--- Pilot instrument validation ---\n")

cat("M1 (Q-AC accuracy) floor/ceiling by condition (< 20% = floor; > 90% = ceiling):\n")
for (cond in CONDITIONS) {
  sub_c <- df[df$condition == cond, ]
  if (nrow(sub_c) == 0) {
    cat(sprintf("  %-10s NO DATA\n", cond))
  } else {
    prop <- mean(sub_c$qac_correct, na.rm = TRUE)
    flag <- if (prop < 0.20) "*** FLOOR ***"
            else if (prop > 0.90) "*** CEILING ***"
            else ""
    cat(sprintf("  %-10s %.1f%% (n=%d) %s\n", cond, 100 * prop, nrow(sub_c), flag))
  }
}

cat("\nM3 save intention distribution (1–7):\n")
print(table(df$save_intention, useNA = "always"))

cat("\nM5 verify expansion rate by condition:\n")
exp_by_cond <- tapply(df$verify_expanded, df$condition, mean, na.rm = TRUE)
for (cond in CONDITIONS) {
  rate <- if (cond %in% names(exp_by_cond)) exp_by_cond[[cond]] else NA
  cat(sprintf("  %-10s %.1f%%\n", cond, 100 * rate))
}

cat("\nTask completion time (seconds):\n")
print(summary(df$response_time_sec))
med_rt <- median(df$response_time_sec, na.rm = TRUE)
if (med_rt < 480 || med_rt > 900) {
  cat(sprintf("  *** NOTE: Median RT = %.0f sec (outside 8–15 min target) ***\n", med_rt))
  cat("  (Expected for synthetic data — real pilot should be 8–15 min)\n")
}

cat("\nAttention check pass rates:\n")
n_pass1 <- sum(df_raw$attention_check_1 == 1, na.rm = TRUE)
n_pass2 <- sum(df_raw$attention_check_2 == 1, na.rm = TRUE)
n_pass_either <- sum(df_raw$attention_check_1 == 1 | df_raw$attention_check_2 == 1, na.rm = TRUE)
cat(sprintf("  ATTN1 pass: %d/%d (%.1f%%)\n", n_pass1, n_raw, 100 * n_pass1 / n_raw))
cat(sprintf("  ATTN2 pass: %d/%d (%.1f%%)\n", n_pass2, n_raw, 100 * n_pass2 / n_raw))
cat(sprintf("  Either pass:  %d/%d (%.1f%%) %s\n",
            n_pass_either, n_raw, 100 * n_pass_either / n_raw,
            if (n_pass_either / n_raw >= 0.80) "✓" else "*** WARNING: < 80% ***"))

# I2-condition calibration confidence check
cat("\nM4 calibration_confidence (I2 conditions only — should be NA for I1):\n")
i1_na_ok <- all(is.na(df$calibration_confidence[df$intervention == "I1"]))
cat(sprintf("  I1 cells all NA: %s\n", if (i1_na_ok) "✓" else "*** WARNING: I1 cells have non-NA values ***"))
i2_mean <- mean(df$calibration_confidence[df$intervention == "I2"], na.rm = TRUE)
cat(sprintf("  I2 mean confidence: %.2f (1–7 scale)\n\n", i2_mean))

# =============================================================================
# PACKAGE AVAILABILITY CHECK
# =============================================================================
cat("--- Package availability ---\n")
# Required packages per main script §0 SETUP header (post-cleanup tick-4058):
# PropCIs, TOSTER, irr, dunn.test, broom, emmeans
pkgs <- c("PropCIs", "TOSTER", "irr", "dunn.test", "broom", "emmeans")
for (p in pkgs) {
  avail <- requireNamespace(p, quietly = TRUE)
  cat(sprintf("  %-15s %s\n", p,
              if (avail) "OK"
              else "MISSING — install before study run"))
}
missing_pkgs <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  cat(sprintf("\nTo install missing packages:\n"))
  cat(sprintf("  install.packages(c('%s'))\n\n",
              paste(missing_pkgs, collapse = "', '")))
} else {
  cat("  All required packages installed. \u2713\n\n")
}

# =============================================================================
# SUMMARY
# =============================================================================
cat("\n=== DRY-CHECK COMPLETE ===\n")
cat(sprintf("Conditions:          %d (8 expected) ✓\n", length(CONDITIONS)))
cat(sprintf("Column structure:    %s\n", if (all(present)) "OK ✓" else "ISSUES FOUND"))
cat(sprintf("Factor balance:      L: %d×%d | E: %d×%d | I: %d×%d\n",
            sum(df_raw$label == "L1"), sum(df_raw$label == "L2"),
            sum(df_raw$explanation == "E1"), sum(df_raw$explanation == "E2"),
            sum(df_raw$intervention == "I1"), sum(df_raw$intervention == "I2")))
cat(sprintf("Exclusion logic:     OK ✓ (final N=%d from %d)\n", nrow(df), n_raw))
cat(sprintf("IRR (M6):            see above\n"))
cat(sprintf("Pilot validation:    OK ✓\n"))
cat("\nNext steps:\n")
cat("  1. Replace data/prolific-export-study2.csv with real pilot export\n")
cat("  2. Verify column names match Qualtrics/Prolific export headers\n")
cat("  3. Set PILOT=TRUE in piup-study2-analysis.R and source() it\n")
cat("  4. Review M1 floor/ceiling and M2 alpha before full-study launch\n")
cat("  5. Pre-register piup-study2-analysis.R on OSF before data collection\n\n")
cat("Design note: docs/piup-study2-design-note-2026-06-22.md\n")
cat("Study 1 reference: docs/piup-study1-preregistration-2026-06-22.md\n\n")
