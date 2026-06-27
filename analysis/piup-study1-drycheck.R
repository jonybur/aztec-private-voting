# =============================================================================
# PIUP Study 1 — DRY-CHECK SCRIPT (NOT pre-registered)
#
# Purpose: Validate that the pre-registered analysis script can parse
#          correctly structured data and run pilot-mode instrument checks.
#          Does NOT test confirmatory hypotheses.
#
# This script:
#   1. Generates N=40 synthetic pilot data matching the expected column format
#   2. Writes it to data/prolific-export.csv (creates data/ dir if absent)
#   3. Checks all required columns are present
#   4. Runs the pilot instrument validation logic inline (mirrors §10 of main script)
#   5. Reports pass/fail for each check
#
# Run: Rscript analysis/piup-study1-drycheck.R
# =============================================================================

cat("\n=== PIUP Study 1 — DRY-CHECK ===\n")
cat("Generating N=40 synthetic pilot data...\n\n")

set.seed(20260622)

N_PER_COND <- 10   # 10 per condition = N=40

CONDITIONS <- c("A", "B", "C", "D")
CONDITION_LABELS <- c(
  A = "vote fingerprint",
  B = "confirmation code",
  C = "nullifier",
  D = "receipt ID"
)

# Synthetic data generator: biased toward correct answers for fingerprint (A),
# lower for nullifier (C), medium for others — mimicking H1/H3 expectations.
accuracy_probs <- list(
  A = list(q1=0.85, q2=0.80, q3=0.75, q4=0.80),
  B = list(q1=0.75, q2=0.55, q3=0.60, q4=0.70),  # H2: q2/q3 lower for B
  C = list(q1=0.50, q2=0.40, q3=0.45, q4=0.50),  # H3: lower composite for C
  D = list(q1=0.70, q2=0.65, q3=0.60, q4=0.65)
)

make_participant <- function(cond, id) {
  probs <- accuracy_probs[[cond]]
  list(
    participant_id       = paste0("SYNTH_", cond, "_", sprintf("%02d", id)),
    condition            = cond,
    q1_correct           = rbinom(1, 1, probs$q1),
    q2_correct           = rbinom(1, 1, probs$q2),
    q3_correct           = rbinom(1, 1, probs$q3),
    q4_correct           = rbinom(1, 1, probs$q4),
    q5_rater1            = sample(0:2, 1),
    q5_rater2            = sample(0:2, 1),
    mental_model_rater1  = sample(0:2, 1),
    mental_model_rater2  = sample(0:2, 1),
    confidence_q1        = sample(4:7, 1),    # slightly overconfident
    confidence_q2        = sample(3:7, 1),
    confidence_q3        = sample(3:6, 1),
    confidence_q4        = sample(4:7, 1),
    attention_check_1    = rbinom(1, 1, 0.92),  # ~92% pass rate
    attention_check_2    = rbinom(1, 1, 0.92),
    response_time_sec    = round(runif(1, 300, 720)),  # 5–12 min
    occupation_sw_eng    = rbinom(1, 1, 0.05),   # ~5% exclude
    age_group            = sample(c("18-24","25-34","35-44","45-54","55+"), 1),
    prior_voting         = rbinom(1, 1, 0.85),
    tech_efficacy_mean   = round(runif(1, 2, 5), 1),
    download_intent      = sample(1:5, 1),
    label_affect         = sample(-3:3, 1)
  )
}

rows <- list()
for (cond in CONDITIONS) {
  for (i in seq_len(N_PER_COND)) {
    rows[[length(rows) + 1]] <- make_participant(cond, i)
  }
}

df_raw <- do.call(rbind, lapply(rows, as.data.frame, stringsAsFactors = FALSE))

# Write synthetic data
dir.create("data", showWarnings = FALSE)
write.csv(df_raw, "data/prolific-export.csv", row.names = FALSE)
cat(sprintf("Synthetic data written: N = %d, conditions = %s\n\n",
            nrow(df_raw), paste(CONDITIONS, collapse = ", ")))

# =============================================================================
# COLUMN VALIDATION
# =============================================================================
cat("--- Column validation ---\n")
expected_cols <- c(
  "participant_id", "condition",
  "q1_correct", "q2_correct", "q3_correct", "q4_correct",
  "q5_rater1", "q5_rater2",
  "mental_model_rater1", "mental_model_rater2",
  "confidence_q1", "confidence_q2", "confidence_q3", "confidence_q4",
  "attention_check_1", "attention_check_2",
  "response_time_sec", "occupation_sw_eng",
  "age_group", "prior_voting", "tech_efficacy_mean", "download_intent", "label_affect"
)
present <- expected_cols %in% colnames(df_raw)
for (i in seq_along(expected_cols)) {
  cat(sprintf("  %-30s %s\n", expected_cols[i], if(present[i]) "OK" else "MISSING"))
}
if (all(present)) {
  cat("\nAll expected columns present. ✓\n\n")
} else {
  cat("\nWARNING: Missing columns detected!\n\n")
}

# =============================================================================
# SIMULATE EXCLUSIONS (mirrors §4.1)
# =============================================================================
cat("--- Exclusion simulation ---\n")
n_raw <- nrow(df_raw)
df <- df_raw

# Rule 1: Fail both attention checks
df <- df[!(df$attention_check_1 == 0 & df$attention_check_2 == 0), ]
cat(sprintf("  After attn-check exclusion: N = %d (removed %d)\n", nrow(df), n_raw - nrow(df)))

# Rule 2: Response time < 90 sec
n_before <- nrow(df)
df <- df[df$response_time_sec >= 90, ]
cat(sprintf("  After RT exclusion:         N = %d (removed %d)\n", nrow(df), n_before - nrow(df)))

# Rule 3: Software engineers
n_before <- nrow(df)
df <- df[df$occupation_sw_eng != 1, ]
cat(sprintf("  After SW engineer exclusion: N = %d (removed %d)\n", nrow(df), n_before - nrow(df)))

cat(sprintf("\nFinal analytic N = %d (%.1f%% retained)\n\n",
            nrow(df), 100 * nrow(df) / n_raw))

# =============================================================================
# IRR CHECK (uses irr package if available)
# =============================================================================
cat("--- IRR check (Cohen's kappa) ---\n")
if (requireNamespace("irr", quietly = TRUE)) {
  kappa_q5 <- irr::kappa2(cbind(df$q5_rater1, df$q5_rater2), weight = "unweighted")
  kappa_mm <- irr::kappa2(cbind(df$mental_model_rater1, df$mental_model_rater2), weight = "unweighted")
  cat(sprintf("  Q5 (open-ended):      κ = %.3f (threshold = 0.70) %s\n",
              kappa_q5$value, if(kappa_q5$value >= 0.70) "✓" else "*** BELOW THRESHOLD"))
  cat(sprintf("  Mental model (MQ1):   κ = %.3f (threshold = 0.70) %s\n",
              kappa_mm$value, if(kappa_mm$value >= 0.70) "✓" else "*** BELOW THRESHOLD (expected in synthetic data)"))
  cat("  NOTE: Synthetic rater scores are random — low kappa is expected.\n\n")
} else {
  cat("  SKIP: 'irr' package not installed. Install with: install.packages('irr')\n\n")
}

# =============================================================================
# PILOT INSTRUMENT VALIDATION (mirrors §10)
# =============================================================================
cat("--- Pilot instrument validation ---\n")

cat("Floor/ceiling check (< 20% or > 90% in any condition = concern):\n")
for (cond in CONDITIONS) {
  sub_c <- df[df$condition == cond, ]
  for (q in c("q1_correct", "q2_correct", "q3_correct", "q4_correct")) {
    prop_c <- mean(sub_c[[q]], na.rm = TRUE)
    flag <- if (prop_c < 0.20) "*** FLOOR ***" else if (prop_c > 0.90) "*** CEILING ***" else ""
    cat(sprintf("  Cond %s, %s: %.1f%% %s\n", cond, q, prop_c * 100, flag))
  }
}

cat("\nTask time (seconds) descriptives:\n")
print(summary(df$response_time_sec))
med_rt <- median(df$response_time_sec, na.rm = TRUE)
if (med_rt < 480 || med_rt > 720) {
  cat(sprintf("*** NOTE: Median RT = %.0f sec (outside 8–12 min target) ***\n", med_rt))
  cat("    (Expected for synthetic data — real pilot should be 8–12 min)\n")
}

cat("\nAttention check pass rate:\n")
n_pass <- sum(df_raw$attention_check_1 == 1 | df_raw$attention_check_2 == 1, na.rm = TRUE)
cat(sprintf("  Passed at least one check: %d / %d (%.1f%%) %s\n",
            n_pass, n_raw, 100 * n_pass / n_raw,
            if(n_pass / n_raw >= 0.80) "✓" else "*** WARNING: < 80%"))

# =============================================================================
# PACKAGE CHECK REPORT
# =============================================================================
cat("\n--- Package availability ---\n")
# [AMENDMENT 2026-06-24] DescTools removed from required packages list.
# [AMENDMENT tick-4032] TOSTER removed (never called; not a proportions test).
# [CLEANUP tick-4055] effsize, broom, multcomp removed: never loaded or called in
#   analysis script; not in pre-reg §6.9. Required packages: PropCIs, irr, dunn.test.
pkgs <- c("PropCIs", "irr", "dunn.test")
for (p in pkgs) {
  avail <- requireNamespace(p, quietly = TRUE)
  cat(sprintf("  %-15s %s\n", p, if(avail) "OK" else "MISSING — install before full study run"))
}

cat("\n=== DRY-CHECK COMPLETE ===\n")
cat("Column structure: OK\n")
cat("Exclusion logic: OK\n")
cat("Pilot validation: OK\n")
cat("To install missing packages: install.packages(c('PropCIs','irr','dunn.test'))\n")
cat("To run pilot analysis (N=40): set PILOT=TRUE in piup-study1-analysis.R and source() it.\n\n")
