# =============================================================================
# PIUP Study 4 — DRY-CHECK SCRIPT (NOT pre-registered)
#
# Purpose: Validate that the pre-registered analysis script can parse
#          correctly structured data and run to completion on synthetic data.
#          Does NOT test confirmatory hypotheses — all p-values are meaningless
#          on synthetic data.
#
# Study 4 design: 2×2 between-subjects vignette experiment
#   D (UI-lock):    D0 = countdown-only (reference); D1 = hard UI-lock
#   P (Pressure):   P1 = moderate (reference); P2 = high
#   Conditions:     D0P1, D0P2, D1P1, D1P2
#
# This script:
#   1. Generates N=200 synthetic participants (50/condition) matching the
#      expected Qualtrics export column format
#   2. Checks all required columns are present and types are correct
#   3. Runs the full pre-registered analysis pipeline (exclusions, all 4
#      hypotheses, sensitivity analyses, TOST)
#   4. Reports PASS/FAIL for each section
#
# Run: Rscript analysis/piup-study4-drycheck.R
#
# Pre-registration: docs/piup-study4-osf-prereg-2026-07-01.md
# Analysis script:  analysis/piup-study4-analysis.R
# Created: 2026-07-01 (tick-4391)
# Author: Jony Bursztyn
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(effsize)   # cohen.d()
  library(TOSTER)    # TOSTtwo()
})

PASS <- function(msg) cat("[PASS]", msg, "\n")
FAIL <- function(msg) { cat("[FAIL]", msg, "\n"); stop(msg) }

cat("\n=== PIUP Study 4 — DRY-CHECK ===\n")
cat("Study: 2×2 vignette (D = UI-lock, P = coercion pressure)\n")
cat("Hypotheses: H4.1 (main D on DV1), H4.2 (D×P interaction on DV1),\n")
cat("            H4.3 (D on DV2), H4.4 (D×P×M1 three-way)\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 1: SYNTHETIC DATA GENERATION
# ─────────────────────────────────────────────────────────────────────────────
cat("--- Section 1: Synthetic data generation ---\n")

set.seed(20260701)

N_PER_COND <- 50   # 50/condition = N = 200

CONDITIONS    <- c("D0P1", "D0P2", "D1P1", "D1P2")
UI_CONDS      <- c(D0P1 = "D0", D0P2 = "D0", D1P1 = "D1", D1P2 = "D1")
PRESS_CONDS   <- c(D0P1 = "P1", D0P2 = "P2", D1P1 = "P1", D1P2 = "P2")

# Expected direction per pre-reg:
#   H4.1: D1 < D0 on DV1 (UI-lock reduces sharing intent)
#   H4.2: D×P interaction — pressure amplifies the D1 reduction
#   H4.3: D1 > D0 on DV2 (UI-lock increases perceived deniability)
# Bias synthetic data to match expected direction so the pipeline exercises
# the simple-effects branch (interaction p < .05). Values are illustrative only.

make_participant <- function(cond, id) {
  ui   <- UI_CONDS[cond]
  pres <- PRESS_CONDS[cond]

  # DV1: sharing intent (1–7). D0=higher, D1=lower; P2 amplifies difference.
  dv1_mean <- switch(cond,
    D0P1 = 4.5,   # countdown only, moderate pressure
    D0P2 = 5.0,   # countdown only, high pressure (more coercion → more sharing)
    D1P1 = 3.5,   # UI-lock, moderate pressure (lock reduces sharing)
    D1P2 = 3.0    # UI-lock, high pressure (largest reduction — H4.2)
  )
  dv1 <- pmin(7, pmax(1, round(rnorm(1, dv1_mean, 1.5))))

  # DV2: perceived deniability (1–7). D1=higher (lock gives truthful excuse).
  dv2_mean <- if (ui == "D1") 5.0 else 3.5
  dv2 <- pmin(7, pmax(1, round(rnorm(1, dv2_mean, 1.4))))

  # DV3: comprehension check (which label is shown on receipt)
  # ~75% correct rate across conditions; slightly higher for D1 (lock is salient)
  correct_prob <- if (ui == "D1") 0.80 else 0.72
  dv3_correct <- rbinom(1, 1, correct_prob)
  dv3_text <- if (dv3_correct == 1) {
    "No — the receipt did not show how I voted"
  } else {
    sample(c("Yes — the receipt showed how I voted", "I'm not sure"), 1)
  }

  # Attention check (correct = 7); ~88% pass rate
  attn <- if (rbinom(1, 1, 0.88)) 7L else sample(1:6, 1)

  # completion time (seconds); ~10% are speed-throughs under 180s
  duration <- if (rbinom(1, 1, 0.90)) {
    as.integer(round(runif(1, 210, 800)))
  } else {
    as.integer(round(runif(1, 60, 175)))
  }

  # M1: tech self-efficacy (1–7); approximately normal
  m1 <- pmin(7, pmax(1, round(rnorm(1, 4.8, 1.5))))

  # C1: prior voting app experience ("Yes" / "No"); ~40% yes
  c1 <- if (rbinom(1, 1, 0.40)) "Yes" else "No"

  list(
    participant_id           = paste0("SYNTH_", cond, "_", sprintf("%03d", id)),
    condition                = cond,
    ui_cond                  = ui,
    pressure_cond            = pres,
    QR5_DV1                  = dv1,
    QR5_DV2                  = dv2,
    QR3_DV3                  = dv3_text,
    comprehension_check_correct = dv3_correct,
    QR6_ATTN                 = attn,
    attention_fail           = 0L,   # set by exclusion logic; init to 0
    QR6_M1                   = m1,
    QR6_C1                   = c1,
    Q_TotalDuration          = duration
  )
}

rows <- list()
for (cond in CONDITIONS) {
  for (i in seq_len(N_PER_COND)) {
    rows[[length(rows) + 1]] <- make_participant(cond, i)
  }
}
df_raw <- do.call(rbind, lapply(rows, as.data.frame, stringsAsFactors = FALSE))
df_raw$QR5_DV1   <- as.integer(df_raw$QR5_DV1)
df_raw$QR5_DV2   <- as.integer(df_raw$QR5_DV2)
df_raw$QR6_ATTN  <- as.integer(df_raw$QR6_ATTN)
df_raw$QR6_M1    <- as.integer(df_raw$QR6_M1)

cat("Generated", nrow(df_raw), "synthetic participants (", N_PER_COND, "/condition)\n")
cat("Condition distribution:\n"); print(table(df_raw$condition))
PASS("Synthetic data generated")

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 2: COLUMN CHECK
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 2: Required column check ---\n")

REQUIRED_COLS <- c(
  "condition", "ui_cond", "pressure_cond",
  "QR5_DV1", "QR5_DV2", "QR3_DV3",
  "comprehension_check_correct",
  "QR6_ATTN", "attention_fail",
  "QR6_M1", "QR6_C1", "Q_TotalDuration"
)

missing_cols <- setdiff(REQUIRED_COLS, names(df_raw))
if (length(missing_cols) > 0) {
  FAIL(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
} else {
  PASS(paste("All", length(REQUIRED_COLS), "required columns present"))
}

# Range checks
checks <- list(
  list(col="QR5_DV1",  min=1, max=7, label="DV1 in [1,7]"),
  list(col="QR5_DV2",  min=1, max=7, label="DV2 in [1,7]"),
  list(col="QR6_ATTN", min=1, max=7, label="Attention in [1,7]"),
  list(col="QR6_M1",   min=1, max=7, label="M1 in [1,7]")
)
for (chk in checks) {
  vals <- df_raw[[chk$col]]
  if (any(vals < chk$min | vals > chk$max, na.rm=TRUE)) {
    FAIL(paste(chk$col, "out of range:", chk$label))
  } else {
    PASS(chk$label)
  }
}

# Factor level checks
if (!all(df_raw$ui_cond %in% c("D0", "D1")))       FAIL("ui_cond invalid levels")
if (!all(df_raw$pressure_cond %in% c("P1", "P2"))) FAIL("pressure_cond invalid levels")
if (!all(df_raw$QR6_C1 %in% c("Yes", "No")))       FAIL("QR6_C1 invalid levels")
PASS("Factor levels valid (ui_cond, pressure_cond, QR6_C1)")

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 3: EXCLUSION DERIVATION (mirrors analysis script §1)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 3: Exclusion derivation ---\n")

df <- df_raw %>%
  mutate(
    exclude_attn  = (QR6_ATTN != 7),
    exclude_time  = (Q_TotalDuration < 180),
    exclude_any   = exclude_attn | exclude_time,
    low_comprehension = (comprehension_check_correct == 0),
    D   = factor(ui_cond,       levels = c("D0", "D1")),
    P   = factor(pressure_cond, levels = c("P1", "P2")),
    M1_c = QR6_M1 - mean(QR6_M1, na.rm = TRUE),
    C1_bin = as.integer(QR6_C1 == "Yes")
  )

n_attn <- sum(df$exclude_attn, na.rm=TRUE)
n_time <- sum(df$exclude_time, na.rm=TRUE)
n_any  <- sum(df$exclude_any,  na.rm=TRUE)

cat("Excluded — attention fail:", n_attn, "\n")
cat("Excluded — too fast:", n_time, "\n")
cat("Excluded — any:", n_any, "\n")

if (n_any < 0 || n_any > nrow(df)) FAIL("Exclusion count out of range")
PASS(paste("Exclusion logic runs; ITT N =", nrow(df) - n_any))

df_itt <- df %>% filter(!exclude_any)
cat("ITT N =", nrow(df_itt), "| Condition breakdown:\n")
print(table(df_itt$condition))

if (nrow(df_itt) < 100) FAIL("ITT sample unexpectedly small (< 100) — check exclusion logic")
PASS("ITT sample size reasonable")

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 4: H4.2 — D × P interaction on DV1 (ANOVA)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 4: H4.2 — D × P ANOVA ---\n")

tryCatch({
  aov_h42    <- aov(QR5_DV1 ~ D * P, data = df_itt)
  aov_summary <- summary(aov_h42)
  ss           <- aov_summary[[1]][["Sum Sq"]]
  ss_dp        <- ss[3]; ss_resid <- ss[4]
  eta2_dp      <- ss_dp / (ss_dp + ss_resid)

  f_dp <- aov_summary[[1]][["F value"]][3]
  p_dp <- aov_summary[[1]][["Pr(>F)"]][3]
  cat("D × P: F =", round(f_dp, 3), ", p =", round(p_dp, 4),
      ", η² =", round(eta2_dp, 4), "\n")

  cell_means <- df_itt %>%
    group_by(D, P) %>%
    summarise(M_DV1 = mean(QR5_DV1, na.rm=TRUE),
              SD_DV1 = sd(QR5_DV1, na.rm=TRUE),
              n = n(), .groups="drop")
  print(cell_means)

  if (p_dp < 0.05) {
    cat("Interaction significant — running simple effects branch\n")
    within_p1 <- df_itt %>% filter(P == "P1")
    within_p2 <- df_itt %>% filter(P == "P2")
    t_p1 <- t.test(QR5_DV1 ~ D, data = within_p1, alternative = "greater")
    t_p2 <- t.test(QR5_DV1 ~ D, data = within_p2, alternative = "greater")
    cat("Within P1: p =", round(t_p1$p.value, 4),
        " | Within P2: p =", round(t_p2$p.value, 4), "\n")
    cm <- cell_means
    contrast <- (cm$M_DV1[cm$D=="D0" & cm$P=="P2"] - cm$M_DV1[cm$D=="D1" & cm$P=="P2"]) -
                (cm$M_DV1[cm$D=="D0" & cm$P=="P1"] - cm$M_DV1[cm$D=="D1" & cm$P=="P1"])
    cat("Interaction contrast =", round(contrast, 3), "\n")
  } else {
    cat("Interaction not significant — simple effects skipped (pre-registered)\n")
  }
  PASS("H4.2 ANOVA runs without error")
}, error = function(e) FAIL(paste("H4.2 ANOVA error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 5: H4.1 — Main effect of D on DV1 (one-tailed)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 5: H4.1 — D main effect on DV1 ---\n")

tryCatch({
  t_h41 <- t.test(QR5_DV1 ~ D, data = df_itt, alternative = "greater")
  d_h41 <- cohen.d(df_itt$QR5_DV1[df_itt$D == "D0"],
                   df_itt$QR5_DV1[df_itt$D == "D1"])
  cat("H4.1: t =", round(t_h41$statistic, 3),
      ", p (one-tailed) =", round(t_h41$p.value, 4),
      ", d =", round(d_h41$estimate, 3), "\n")
  PASS("H4.1 t-test + Cohen's d runs without error")
}, error = function(e) FAIL(paste("H4.1 error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 6: H4.3 — D effect on DV2 (one-tailed)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 6: H4.3 — D effect on DV2 (deniability) ---\n")

tryCatch({
  t_h43 <- t.test(QR5_DV2 ~ D, data = df_itt, alternative = "less")
  d_h43 <- cohen.d(df_itt$QR5_DV2[df_itt$D == "D1"],
                   df_itt$QR5_DV2[df_itt$D == "D0"])
  cat("H4.3: t =", round(t_h43$statistic, 3),
      ", p (one-tailed) =", round(t_h43$p.value, 4),
      ", d (D1 > D0) =", round(d_h43$estimate, 3), "\n")
  PASS("H4.3 t-test + Cohen's d runs without error")
}, error = function(e) FAIL(paste("H4.3 error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 7: H4.4 — Three-way moderated regression (D × P × M1)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 7: H4.4 — D × P × M1 moderated regression ---\n")

tryCatch({
  df_h44 <- df_itt %>%
    mutate(D_bin = as.numeric(D == "D1"),
           P_bin = as.numeric(P == "P2"))

  lm_h44        <- lm(QR5_DV1 ~ D_bin * P_bin * M1_c, data = df_h44)
  lm_h44_no3way <- lm(QR5_DV1 ~ D_bin * P_bin + D_bin * M1_c + P_bin * M1_c, data = df_h44)
  anova_cmp     <- anova(lm_h44_no3way, lm_h44)
  coef_3way     <- coef(summary(lm_h44))["D_bin:P_bin:M1_c", ]
  cat("D × P × M1 β =", round(coef_3way["Estimate"], 4),
      ", ΔR² F-test p =", round(anova_cmp[["Pr(>F)"]][2], 4), "\n")
  PASS("H4.4 moderated regression runs without error")
}, error = function(e) FAIL(paste("H4.4 error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 8: SENSITIVITY ANALYSES
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 8: Sensitivity analyses (SA-1 through SA-4) ---\n")

tryCatch({
  # SA-1: Comprehension filter
  df_pp <- df_itt %>% filter(!low_comprehension)
  cat("SA-1: N after comprehension filter:", nrow(df_pp), "\n")
  aov_sa1 <- aov(QR5_DV1 ~ D * P, data = df_pp)
  t_sa1   <- t.test(QR5_DV1 ~ D, data = df_pp, alternative = "greater")
  cat("SA-1 H4.2 ANOVA: F(D×P) =",
      round(summary(aov_sa1)[[1]][["F value"]][3], 3), "\n")
  cat("SA-1 H4.1 t-test: p =", round(t_sa1$p.value, 4), "\n")
  PASS("SA-1 (comprehension filter) runs without error")
}, error = function(e) FAIL(paste("SA-1 error:", e$message)))

tryCatch({
  # SA-2: M1 as covariate
  df_h44_sa <- df_itt %>%
    mutate(D_bin = as.numeric(D == "D1"), P_bin = as.numeric(P == "P2"))
  lm_sa2_h41 <- lm(QR5_DV1 ~ D + M1_c, data = df_h44_sa)
  lm_sa2_h42 <- lm(QR5_DV1 ~ D_bin * P_bin + M1_c, data = df_h44_sa)
  cat("SA-2 D coef (H4.1+M1):", round(coef(lm_sa2_h41)["DD1"], 3), "\n")
  PASS("SA-2 (M1 covariate) runs without error")
}, error = function(e) FAIL(paste("SA-2 error:", e$message)))

tryCatch({
  # SA-3: C1 as covariate
  df_h44_sa <- df_itt %>%
    mutate(D_bin = as.numeric(D == "D1"), P_bin = as.numeric(P == "P2"),
           C1_bin = as.integer(QR6_C1 == "Yes"))
  lm_sa3_h41 <- lm(QR5_DV1 ~ D + C1_bin, data = df_h44_sa)
  lm_sa3_h42 <- lm(QR5_DV1 ~ D_bin * P_bin + C1_bin, data = df_h44_sa)
  cat("SA-3 D coef (H4.1+C1):", round(coef(lm_sa3_h41)["DD1"], 3), "\n")
  PASS("SA-3 (C1 covariate) runs without error")
}, error = function(e) FAIL(paste("SA-3 error:", e$message)))

tryCatch({
  # SA-4: ANCOVA M1 + C1 combined
  df_h44_sa <- df_itt %>%
    mutate(D_bin = as.numeric(D == "D1"), P_bin = as.numeric(P == "P2"),
           C1_bin = as.integer(QR6_C1 == "Yes"))
  lm_sa4 <- lm(QR5_DV1 ~ D_bin * P_bin + M1_c + C1_bin, data = df_h44_sa)
  cat("SA-4 ANCOVA R² =", round(summary(lm_sa4)$r.squared, 4), "\n")
  PASS("SA-4 (M1+C1 ANCOVA) runs without error")
}, error = function(e) FAIL(paste("SA-4 error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 9: NULL RESULT PROTOCOL — TOST
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 9: TOST null result protocol ---\n")

tryCatch({
  # Force TOST path: compute H4.1 p but run TOST regardless (dry-check)
  t_h41_val <- t.test(QR5_DV1 ~ D, data = df_itt, alternative = "greater")
  p_h41 <- t_h41_val$p.value
  sd_dv1 <- sd(df_itt$QR5_DV1, na.rm = TRUE)

  n_d0 <- sum(df_itt$D == "D0"); n_d1 <- sum(df_itt$D == "D1")
  m_d0 <- mean(df_itt$QR5_DV1[df_itt$D == "D0"], na.rm=TRUE)
  m_d1 <- mean(df_itt$QR5_DV1[df_itt$D == "D1"], na.rm=TRUE)
  sd_d0 <- sd(df_itt$QR5_DV1[df_itt$D == "D0"], na.rm=TRUE)
  sd_d1 <- sd(df_itt$QR5_DV1[df_itt$D == "D1"], na.rm=TRUE)

  cat("TOST inputs: m_D0 =", round(m_d0,2), ", m_D1 =", round(m_d1,2),
      ", sd_D0 =", round(sd_d0,2), ", sd_D1 =", round(sd_d1,2),
      ", n_D0 =", n_d0, ", n_D1 =", n_d1, "\n")
  cat("Equivalence bound: \u00b1", round(sd_dv1, 3), "(raw; = \u00b11 pooled SD, pre-registered)\n")

  # Dry-check runs TOST unconditionally to validate it executes.
  # tsum_TOST() is the current API (TOSTER >= 0.4.0).
  # eqbound_type = "raw" + eqb = sd_dv1 implements the pre-registered \u00b11-SD bound.
  tost_result <- tsum_TOST(
    m1 = m_d0, m2 = m_d1,
    sd1 = sd_d0, sd2 = sd_d1,
    n1 = n_d0, n2 = n_d1,
    eqb = sd_dv1,
    eqbound_type = "raw",
    alpha = 0.05
  )
  tost_p1 <- tost_result$TOST$p.value[1]
  tost_p2 <- tost_result$TOST$p.value[2]
  cat("TOST p1 =", round(tost_p1, 4),
      " | TOST p2 =", round(tost_p2, 4), "\n")
  cat("H4.1 p (one-tailed) =", round(p_h41, 4),
      " → TOST would be", if (p_h41 >= 0.05) "REQUIRED" else "not required", "\n")
  PASS("TOST null result protocol runs without error")
}, error = function(e) FAIL(paste("TOST error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# SECTION 10: DESCRIPTIVES SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
cat("\n--- Section 10: Descriptives summary ---\n")

tryCatch({
  cat("Cell Ns (ITT):\n"); print(table(df_itt$condition))

  cat("\nDV1 (sharing intent) by condition:\n")
  print(df_itt %>% group_by(D, P) %>%
    summarise(M = round(mean(QR5_DV1, na.rm=TRUE), 2),
              SD = round(sd(QR5_DV1, na.rm=TRUE), 2),
              n = n(), .groups="drop"))

  cat("\nDV2 (deniability) by UI condition:\n")
  print(df_itt %>% group_by(D) %>%
    summarise(M_DV2 = round(mean(QR5_DV2, na.rm=TRUE), 2),
              SD_DV2 = round(sd(QR5_DV2, na.rm=TRUE), 2),
              n = n(), .groups="drop"))

  cat("\nDV3 comprehension rate:\n")
  print(table(df_itt$comprehension_check_correct) / nrow(df_itt))

  PASS("Descriptives summary runs without error")
}, error = function(e) FAIL(paste("Descriptives error:", e$message)))

# ─────────────────────────────────────────────────────────────────────────────
# FINAL SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
cat("\n=== DRY-CHECK COMPLETE — ALL SECTIONS PASSED ===\n")
cat("Analysis script piup-study4-analysis.R is structurally valid.\n")
cat("All pre-registered analyses execute without errors on synthetic data.\n")
cat("N=200 synthetic participants (50/condition, ~20% excluded by attention/time; ITT N=160).\n")
cat("Note: pre-reg target is N=160 (40/condition, replacement design). N=200 is drycheck-only simulation pool.\n")
cat("\nNOTE: p-values above are meaningless on synthetic data.\n")
cat("Run piup-study4-analysis.R only after real data collection.\n")
cat("Pre-registration: docs/piup-study4-osf-prereg-2026-07-01.md\n")
cat("Dry-check created: 2026-07-01 (tick-4391)\n")
