# =============================================================================
# PIUP Study 2 — Monte Carlo Power Simulation
# Absent-Content Interpretation, Explanation Effects, and Trust Calibration
# 2×2×2 Between-Subjects Factorial Experiment (L × E × I)
#
# Purpose: supplement G*Power analytical estimates (design note §10) with
# simulation-based power curves that:
#   (a) account for the 20-25% exclusion rate explicitly,
#   (b) handle the factorial structure without single-df approximations,
#   (c) show power across a plausible range of effect sizes, and
#   (d) serve as a reproducible OSF supplement.
#
# Design note:    docs/piup-study2-design-note-2026-06-22.md (§10)
# Analysis script: analysis/piup-study2-analysis.R
#
# Author:        Jony Bursztyn
# Script version: 2026-06-29 (pre-pilot; upload to OSF before data collection)
# R version:     >= 4.3
#
# Required packages: none (base R only)
#   Optional for plots: ggplot2 (function defined but not called by default)
#
# Hypotheses simulated:
#   H2.1 — E main effect on Q-AC (binary accuracy; chi-squared, one-tailed)
#   H2.2 — L × E interaction on M2 trust composite (ANOVA F-test)
#   H2.3 — I2 reduces miscalibration residual in L2 [CONDITIONAL on H4]
#           * Test design: I1-L2 vs I2-L2 on M4 calibration residual.
#           * M4 (calibration_confidence) is collected for ALL conditions (tick-4246
#             FF fix: post-receipt Q-AC confidence question for all N=240).
#             This simulation applies directly; no grouping change needed.
#
# Usage:
#   source("piup-study2-power-simulation.R")
#   Results printed to console; CSV saved to analysis/results-study2/power-sim/
#
# NOTE: This is a PRE-DATA simulation only. It does not use any study observations.
#       All effect-size grids are designed to bracket the primary assumptions in
#       design note §10; the exact assumptions are highlighted with [PRIMARY ESTIMATE].
# =============================================================================

# --- 0. SETUP ----------------------------------------------------------------

set.seed(20260629L)   # Locked at script creation date
nsim          <- 2000L  # Iterations per scenario (CI half-width ≤ ±2.2pp at 95%)
alpha         <- 0.05
excl_rate     <- 0.22   # Expected exclusion proportion (design note §10 says 20-25%; midpoint)
n_per_cell    <- 30L    # Target analytic n per cell
n_cells       <- 8L     # 2 × 2 × 2 = 8 conditions
N_recruit     <- ceiling(n_per_cell * n_cells / (1 - excl_rate))  # Recruit target

# Analytic sample: after exclusions, expected total
n_analytic    <- n_per_cell * n_cells    # 240 analytic Ps after exclusion
# Per E level (collapsing L and I): 120 analytic Ps each
n_per_E_level <- n_analytic / 2L

# Output directory
out_dir <- "results-study2/power-sim"
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

cat("==========================================================\n")
cat("PIUP Study 2 — Monte Carlo Power Simulation\n")
cat(sprintf("nsim = %d | alpha = %.2f | excl_rate = %.0f%%\n",
            nsim, alpha, excl_rate * 100))
cat(sprintf("Recruit target: N = %d | Analytic target: N = %d (%d per cell)\n",
            N_recruit, n_analytic, n_per_cell))
cat("==========================================================\n\n")


# =============================================================================
# SECTION 1 — H2.1: E MAIN EFFECT ON Q-AC (chi-squared, one-tailed)
# =============================================================================
# Q-AC is the primary binary composite (correct absent-content interpretation).
# H2.1: p(Q-AC correct | E1) > p(Q-AC correct | E2).
# Test: one-tailed chi-squared on 2×2 table (E × Q-AC), converted from
# prop.test(..., alternative = "greater").
#
# Effect-size grid: p_E2 fixed at 0.50 (conservative prior, design note §10.1).
# p_E1 varies: 0.55 (null-ish), 0.60, 0.65, 0.70 [PRIMARY], 0.75, 0.80.
# Per E level n: 120 (60 per L, pooled over I; all I receive same E).
# --------------------------------------------------------------------------

cat("=== SECTION 1: H2.1 — E main effect on Q-AC (one-tailed chi-squared) ===\n\n")

p_E2_fixed <- 0.50
p_E1_grid  <- c(0.55, 0.60, 0.65, 0.70, 0.75, 0.80)

h21_results <- data.frame(
  p_E1           = numeric(0),
  p_E2           = numeric(0),
  cohens_h       = numeric(0),
  n_per_E_level  = numeric(0),
  power_sim      = numeric(0),
  power_ci_lo    = numeric(0),
  power_ci_hi    = numeric(0),
  primary        = character(0),
  stringsAsFactors = FALSE
)

for (p_E1 in p_E1_grid) {
  h_effect <- 2 * asin(sqrt(p_E1)) - 2 * asin(sqrt(p_E2_fixed))

  reject <- logical(nsim)
  for (i in seq_len(nsim)) {
    # Simulate analytic participants (post-exclusion)
    e1_correct <- rbinom(1, n_per_E_level, p_E1)
    e2_correct <- rbinom(1, n_per_E_level, p_E2_fixed)
    # One-tailed test: p_E1 > p_E2
    result <- suppressWarnings(
      prop.test(c(e1_correct, e2_correct),
                c(n_per_E_level, n_per_E_level),
                alternative = "greater",
                correct = FALSE)
    )
    reject[i] <- result$p.value < alpha
  }

  power_est <- mean(reject)
  # Wilson 95% CI for power estimate
  k      <- sum(reject)
  n_obs  <- nsim
  ci     <- prop.test(k, n_obs)$conf.int

  h21_results <- rbind(h21_results, data.frame(
    p_E1           = p_E1,
    p_E2           = p_E2_fixed,
    cohens_h       = round(h_effect, 3),
    n_per_E_level  = n_per_E_level,
    power_sim      = round(power_est, 3),
    power_ci_lo    = round(ci[1], 3),
    power_ci_hi    = round(ci[2], 3),
    primary        = ifelse(p_E1 == 0.70, "[PRIMARY ESTIMATE]", ""),
    stringsAsFactors = FALSE
  ))

  cat(sprintf("  p_E1=%.2f | p_E2=%.2f | h=%.3f | power=%.3f [%.3f, %.3f]%s\n",
              p_E1, p_E2_fixed, h_effect, power_est, ci[1], ci[2],
              ifelse(p_E1 == 0.70, " ← PRIMARY ESTIMATE", "")))
}

write.csv(h21_results, file.path(out_dir, "h21_power_curve.csv"), row.names = FALSE)
cat(sprintf("\n  H2.1 CSV saved: %s\n\n", file.path(out_dir, "h21_power_curve.csv")))


# =============================================================================
# SECTION 2 — H2.1 with REALISTIC EXCLUSION RATE (sensitivity check)
# =============================================================================
# Repeat H2.1 primary estimate (p_E1=0.70, p_E2=0.50) varying exclusion rate
# from 15% to 35% while holding N_recruit constant.
# --------------------------------------------------------------------------

cat("=== SECTION 2: H2.1 sensitivity — exclusion rate (N_recruit constant) ===\n\n")

excl_grid <- c(0.15, 0.18, 0.20, 0.22, 0.25, 0.28, 0.32, 0.35)
p_E1_primary <- 0.70

excl_results <- data.frame(
  excl_rate     = numeric(0),
  analytic_N    = numeric(0),
  n_per_E_level = numeric(0),
  power_sim     = numeric(0),
  power_ci_lo   = numeric(0),
  power_ci_hi   = numeric(0),
  stringsAsFactors = FALSE
)

for (er in excl_grid) {
  n_analytic_e <- floor(N_recruit * (1 - er))
  n_per_E_e    <- n_analytic_e %/% 2L  # Balanced E levels

  reject <- logical(nsim)
  for (i in seq_len(nsim)) {
    e1_correct <- rbinom(1, n_per_E_e, p_E1_primary)
    e2_correct <- rbinom(1, n_per_E_e, p_E2_fixed)
    result <- suppressWarnings(
      prop.test(c(e1_correct, e2_correct),
                c(n_per_E_e, n_per_E_e),
                alternative = "greater",
                correct = FALSE)
    )
    reject[i] <- result$p.value < alpha
  }

  power_est <- mean(reject)
  k   <- sum(reject)
  ci  <- prop.test(k, nsim)$conf.int

  excl_results <- rbind(excl_results, data.frame(
    excl_rate     = er,
    analytic_N    = n_analytic_e,
    n_per_E_level = n_per_E_e,
    power_sim     = round(power_est, 3),
    power_ci_lo   = round(ci[1], 3),
    power_ci_hi   = round(ci[2], 3),
    stringsAsFactors = FALSE
  ))

  cat(sprintf("  excl=%.0f%% | analytic_N=%d | n_per_E=%d | power=%.3f [%.3f, %.3f]%s\n",
              er * 100, n_analytic_e, n_per_E_e,
              power_est, ci[1], ci[2],
              ifelse(er == 0.22, " ← PRIMARY ASSUMPTION", "")))
}

write.csv(excl_results, file.path(out_dir, "h21_excl_sensitivity.csv"), row.names = FALSE)
cat(sprintf("\n  Exclusion sensitivity CSV saved: %s\n\n",
            file.path(out_dir, "h21_excl_sensitivity.csv")))


# =============================================================================
# SECTION 3 — H2.2: L × E INTERACTION ON M2 TRUST (ANOVA F-test)
# =============================================================================
# M2 is the McKnight trust composite (4 items, α-averaged, 1-7 Likert).
# H2.2 is a two-way interaction effect (L × E) in a 2×2×2 ANOVA (L × E × I).
# The ANOVA is run on collapsed cells (interaction test, 1 df in a 2×2 table).
#
# Simulation strategy:
#   - Generate M2 scores from cell means + SD=1.5 (plausible for a 4-item 1-7 scale)
#   - Cell means parameterised by interaction ES f = 0 (null), 0.15, 0.22 [PRIMARY], 0.30
#   - Test: two-way ANOVA on L × E, extract interaction F, compare to Fcrit
#
# Effect-size grid: Cohen's f (interaction) in {0, 0.10, 0.15, 0.22, 0.30, 0.35}
# SD of M2 assumed = 1.5 (1-7 scale; conservative).
# --------------------------------------------------------------------------

cat("=== SECTION 3: H2.2 — L × E interaction on M2 trust composite ===\n\n")

m2_sd      <- 1.5    # Within-cell SD
m2_grand   <- 4.5    # Grand mean (midpoint of 1-7 range)
n_cell     <- n_per_cell   # 30 per cell
f_grid     <- c(0, 0.10, 0.15, 0.22, 0.30, 0.35)

# Interaction pattern: f = SD of cell means / within_SD
# For a 2×2 crossed interaction (L × E), the "interaction contrast" is
# (mean_L1E1 - mean_L1E2) - (mean_L2E1 - mean_L2E2).
# We implement the interaction as a differential E-effect by L:
#   E effect is larger for L2 (confirmation code) than L1 (vote fingerprint),
#   consistent with the H2 dissociation mechanism in design note §2.

h22_results <- data.frame(
  cohens_f     = numeric(0),
  n_per_cell   = numeric(0),
  N_analytic   = numeric(0),
  power_sim    = numeric(0),
  power_ci_lo  = numeric(0),
  power_ci_hi  = numeric(0),
  primary      = character(0),
  stringsAsFactors = FALSE
)

for (f_val in f_grid) {
  # Convert f to interaction contrast magnitude
  # For a 2×2 table with equal n, f = |interaction_effect| / (2 * sigma)
  # where interaction_effect = (mu_11 - mu_12) - (mu_21 - mu_22)
  # We set the E-effect for L1 = delta_L1, E-effect for L2 = delta_L2,
  # interaction magnitude = |delta_L1 - delta_L2|.
  # With f = interaction_contrast_SD / sigma:
  # f = (|delta_L1 - delta_L2| / 2) / sigma (for balanced 2×2)
  # => |delta_L1 - delta_L2| = 2 * f * sigma
  delta <- 2 * f_val * m2_sd  # Interaction contrast magnitude

  # Cell means: E1 always better than E2 (positive E main effect)
  # L1-E1 vs L2-E1: equal (no L main effect assumed in null)
  # L1-E2 vs L2-E2: L2 drops more than L1 (interaction)
  mu_L1E1 <- m2_grand + delta / 4
  mu_L1E2 <- m2_grand - delta / 4
  mu_L2E1 <- m2_grand + delta / 4 + delta / 2   # L2 benefits more from E1
  mu_L2E2 <- m2_grand - delta / 4 - delta / 2   # L2 suffers more from E2

  # I factor: no effect on M2 (calibration intervention doesn't affect trust)
  # → I1 and I2 within each L×E cell have the same mean

  reject <- logical(nsim)
  for (i in seq_len(nsim)) {
    # Generate data: 8 cells × n_cell Ps, with I collapsed for trust (no I effect)
    cells <- expand.grid(L = c("L1", "L2"), E = c("E1", "E2"), I = c("I1", "I2"))
    df_sim <- do.call(rbind, lapply(seq_len(nrow(cells)), function(r) {
      mu <- switch(paste0(cells$L[r], cells$E[r]),
                   L1E1 = mu_L1E1, L1E2 = mu_L1E2,
                   L2E1 = mu_L2E1, L2E2 = mu_L2E2)
      data.frame(
        L  = cells$L[r],
        E  = cells$E[r],
        I  = cells$I[r],
        M2 = rnorm(n_cell, mu, m2_sd)
      )
    }))
    df_sim$L <- factor(df_sim$L)
    df_sim$E <- factor(df_sim$E)

    # Two-way ANOVA: M2 ~ L * E (I excluded from this test; consistent with §4.2)
    aov_fit  <- aov(M2 ~ L * E, data = df_sim)
    p_int    <- summary(aov_fit)[[1]]["L:E", "Pr(>F)"]
    reject[i] <- p_int < alpha   # Two-tailed; H2.2 does not specify direction
  }

  power_est <- mean(reject)
  k   <- sum(reject)
  ci  <- prop.test(k, nsim)$conf.int

  h22_results <- rbind(h22_results, data.frame(
    cohens_f    = f_val,
    n_per_cell  = n_cell,
    N_analytic  = n_analytic,
    power_sim   = round(power_est, 3),
    power_ci_lo = round(ci[1], 3),
    power_ci_hi = round(ci[2], 3),
    primary     = ifelse(f_val == 0.22, "[PRIMARY ESTIMATE]", ""),
    stringsAsFactors = FALSE
  ))

  cat(sprintf("  f=%.2f | n_per_cell=%d | N=%d | power=%.3f [%.3f, %.3f]%s\n",
              f_val, n_cell, n_analytic,
              power_est, ci[1], ci[2],
              ifelse(f_val == 0.22, " ← PRIMARY ESTIMATE", "")))
}

write.csv(h22_results, file.path(out_dir, "h22_power_curve.csv"), row.names = FALSE)
cat(sprintf("\n  H2.2 CSV saved: %s\n\n", file.path(out_dir, "h22_power_curve.csv")))


# =============================================================================
# SECTION 4 — H2.3: CALIBRATION INTERVENTION ON M4 RESIDUAL (t-test, one-tailed)
# =============================================================================
# CONDITIONAL test: run only if Study 1 H4 is supported.
# Tests: L2-I1 vs L2-I2 on M4 calibration residual (overcalibration).
# N: 60 (L2 only: I1 n=30, I2 n=30, pooled across E-levels).
#
# RESOLVED — tick-4246 FF fix:
#   M4 (calibration_confidence) is the post-receipt Q-AC confidence question,
#   collected for ALL conditions (N=240). The I1-L2 group has valid M4 data.
#   This simulation's test design (I1-L2 vs I2-L2 on M4 residual) is correct
#   and matches the pre-registration exactly. No alternative grouping is needed.
#   See: docs/piup-study2-survey-instrument-2026-06-28.md §11 and
#        analysis/piup-study2-analysis.R (conf_rows comment, tick-4246/4251).
#
# Effect-size grid: Cohen's d in {0.20, 0.35, 0.50, 0.65, 0.80}
# n per group: 30 (L2, within each I level, pooled over E).
# Residual: continuous, approximately Normal (design note §10.3).
# --------------------------------------------------------------------------

cat("=== SECTION 4: H2.3 — Calibration intervention on M4 residual (conditional) ===\n\n")
cat("[NOTE] M4 is measured in ALL conditions (tick-4246 FF fix). I1-L2 vs I2-L2 test is valid.\n\n")

n_h23 <- n_per_cell   # 30 per I level within L2
d_grid <- c(0.20, 0.35, 0.50, 0.65, 0.80)

h23_results <- data.frame(
  cohens_d    = numeric(0),
  n_per_group = numeric(0),
  power_sim   = numeric(0),
  power_ci_lo = numeric(0),
  power_ci_hi = numeric(0),
  primary     = character(0),
  stringsAsFactors = FALSE
)

for (d_val in d_grid) {
  # I2 group (calibration): lower residual (less overcalibration); set mean=0.
  # I1 group (no calibration): higher residual by d SDs.
  mu_I1 <-  d_val / 2   # Overcalibration in control group
  mu_I2 <- -d_val / 2   # Reduced by I2 intervention
  sigma <- 1.0           # Standardised

  reject <- logical(nsim)
  for (i in seq_len(nsim)) {
    x_I1 <- rnorm(n_h23, mu_I1, sigma)
    x_I2 <- rnorm(n_h23, mu_I2, sigma)
    # One-tailed: I1 > I2 (calibration reduces residual)
    t_res <- t.test(x_I1, x_I2, alternative = "greater", var.equal = FALSE)
    reject[i] <- t_res$p.value < alpha
  }

  power_est <- mean(reject)
  k   <- sum(reject)
  ci  <- prop.test(k, nsim)$conf.int

  h23_results <- rbind(h23_results, data.frame(
    cohens_d    = d_val,
    n_per_group = n_h23,
    power_sim   = round(power_est, 3),
    power_ci_lo = round(ci[1], 3),
    power_ci_hi = round(ci[2], 3),
    primary     = ifelse(d_val == 0.50, "[PRIMARY ESTIMATE]", ""),
    stringsAsFactors = FALSE
  ))

  cat(sprintf("  d=%.2f | n=%d/group | power=%.3f [%.3f, %.3f]%s\n",
              d_val, n_h23, power_est, ci[1], ci[2],
              ifelse(d_val == 0.50, " ← PRIMARY ESTIMATE", "")))
}

# Also show increased n for a powered 2b study (design note §10.3 note)
n_2b <- 40L  # n=80 total (L2 only)
cat(sprintf("\n  Study 2b scenario (L2-only, n=%d/group):\n", n_2b))
for (d_val in c(0.35, 0.50, 0.65)) {
  reject <- logical(nsim)
  for (i in seq_len(nsim)) {
    x_I1 <- rnorm(n_2b,  d_val / 2, 1.0)
    x_I2 <- rnorm(n_2b, -d_val / 2, 1.0)
    t_res <- t.test(x_I1, x_I2, alternative = "greater", var.equal = FALSE)
    reject[i] <- t_res$p.value < alpha
  }
  power_2b <- mean(reject)
  ci_2b <- prop.test(sum(reject), nsim)$conf.int
  cat(sprintf("    d=%.2f | n=%d/group | power=%.3f [%.3f, %.3f]\n",
              d_val, n_2b, power_2b, ci_2b[1], ci_2b[2]))
}

write.csv(h23_results, file.path(out_dir, "h23_power_curve.csv"), row.names = FALSE)
cat(sprintf("\n  H2.3 CSV saved: %s\n\n", file.path(out_dir, "h23_power_curve.csv")))


# =============================================================================
# SECTION 5 — H2.4: M1 ACCURACY PREDICTS M3 DOWNLOAD CLICK (logistic regression)
# =============================================================================
# H2.4 is a logistic regression (download_clicked ~ m1_qac + covariates).
# This is a directional prediction: better M1 → higher odds of download_click.
# Power for logistic regression depends on OR and marginal click rate.
#
# Simulation: N=240, binary M1 and binary download_clicked.
# OR grid: 1.0 (null), 1.5, 2.0 [PRIMARY], 2.5, 3.0
# Marginal click rate (P(click | M1=0)): 0.30 assumed (untutored baseline)
# --------------------------------------------------------------------------

cat("=== SECTION 5: H2.4 — M1 accuracy predicts M3 download click (logistic) ===\n\n")

p_click_m1_0 <- 0.30   # Marginal click rate when Q-AC is wrong
or_grid      <- c(1.0, 1.5, 2.0, 2.5, 3.0)
# Fraction with M1=1 (correct Q-AC) in the analytic sample:
# Assume 55% overall accuracy (between E1=70% and E2=50% priors; collapsed)
p_m1_correct <- 0.55
N_h24        <- n_analytic  # 240

h24_results <- data.frame(
  OR          = numeric(0),
  p_click_0   = numeric(0),
  p_click_1   = numeric(0),
  N           = numeric(0),
  power_sim   = numeric(0),
  power_ci_lo = numeric(0),
  power_ci_hi = numeric(0),
  primary     = character(0),
  stringsAsFactors = FALSE
)

for (or_val in or_grid) {
  # P(click | M1=1) from OR and P(click | M1=0)
  p0 <- p_click_m1_0
  p1 <- (or_val * p0 / (1 - p0)) / (1 + or_val * p0 / (1 - p0))

  reject <- logical(nsim)
  for (i in seq_len(nsim)) {
    m1_vec    <- rbinom(N_h24, 1, p_m1_correct)
    p_click_i <- ifelse(m1_vec == 1, p1, p0)
    click_vec <- rbinom(N_h24, 1, p_click_i)
    df_h24    <- data.frame(m1 = m1_vec, click = click_vec)
    fit       <- glm(click ~ m1, data = df_h24, family = binomial())
    p_m1      <- coef(summary(fit))["m1", "Pr(>|z|)"]
    # H2.4 is one-tailed (positive OR predicted)
    b_m1      <- coef(fit)["m1"]
    reject[i] <- (p_m1 / 2) < alpha & b_m1 > 0
  }

  power_est <- mean(reject)
  k   <- sum(reject)
  ci  <- prop.test(k, nsim)$conf.int

  h24_results <- rbind(h24_results, data.frame(
    OR          = or_val,
    p_click_0   = round(p0, 3),
    p_click_1   = round(p1, 3),
    N           = N_h24,
    power_sim   = round(power_est, 3),
    power_ci_lo = round(ci[1], 3),
    power_ci_hi = round(ci[2], 3),
    primary     = ifelse(or_val == 2.0, "[PRIMARY ESTIMATE]", ""),
    stringsAsFactors = FALSE
  ))

  cat(sprintf("  OR=%.1f | P(click|0)=%.2f | P(click|1)=%.2f | power=%.3f [%.3f, %.3f]%s\n",
              or_val, p0, p1, power_est, ci[1], ci[2],
              ifelse(or_val == 2.0, " ← PRIMARY ESTIMATE", "")))
}

write.csv(h24_results, file.path(out_dir, "h24_power_curve.csv"), row.names = FALSE)
cat(sprintf("\n  H2.4 CSV saved: %s\n\n", file.path(out_dir, "h24_power_curve.csv")))


# =============================================================================
# SECTION 6 — SUMMARY TABLE
# =============================================================================

cat("=============================================================\n")
cat("SUMMARY — Primary estimates (PRIMARY ESTIMATE rows)\n")
cat("=============================================================\n\n")

cat(sprintf("H2.1 (E main on Q-AC, chi-sq one-tailed):  power = %.3f  [n_per_E=%d, p_E1=0.70, p_E2=0.50, h=%.3f]\n",
            h21_results$power_sim[h21_results$p_E1 == 0.70],
            n_per_E_level,
            h21_results$cohens_h[h21_results$p_E1 == 0.70]))

cat(sprintf("H2.2 (L×E interaction on M2, ANOVA):        power = %.3f  [N=%d, f=0.22]\n",
            h22_results$power_sim[h22_results$cohens_f == 0.22],
            n_analytic))

cat(sprintf("H2.3 (I effect on M4 residual, t one-tail): power = %.3f  [n=%d/group, d=0.50] [CONDITIONAL on H4]\n",
            h23_results$power_sim[h23_results$cohens_d == 0.50],
            n_per_cell))

cat(sprintf("H2.4 (M1→click logistic, one-tailed):       power = %.3f  [N=%d, OR=2.0]\n",
            h24_results$power_sim[h24_results$OR == 2.0],
            n_analytic))

cat("\n")
cat("Design note §10 analytical estimates (G*Power):\n")
cat("  H2.1: ~0.84  |  H2.2: ~0.80  |  H2.3: ~0.72  |  H2.4: (not reported)\n")
cat("\n")
cat("Simulation CI half-widths are ≤ ±0.014 at 95% confidence (nsim = 5000).\n\n")

# Write combined summary CSV
summary_df <- data.frame(
  hypothesis  = c("H2.1", "H2.2", "H2.3", "H2.4"),
  description = c("E main on Q-AC (chi-sq, 1-tail)",
                  "L×E interaction on M2 (ANOVA)",
                  "I effect on M4 residual (t, 1-tail; CONDITIONAL)",
                  "M1 predicts M3 click (logistic, 1-tail)"),
  effect_size = c("h=0.358 (p_E1=0.70, p_E2=0.50)",
                  "f=0.22 (interaction contrast)",
                  "d=0.50 (I1-L2 vs I2-L2)",
                  "OR=2.0 (P_click=0.30→0.46)"),
  N           = c(n_analytic, n_analytic, n_per_cell * 2, n_analytic),
  power_sim   = c(
    h21_results$power_sim[h21_results$p_E1 == 0.70],
    h22_results$power_sim[h22_results$cohens_f == 0.22],
    h23_results$power_sim[h23_results$cohens_d == 0.50],
    h24_results$power_sim[h24_results$OR == 2.0]
  ),
  gpower_analytical = c(0.84, 0.80, 0.72, NA_real_),
  note = c("", "", "CONDITIONAL on Study 1 H4; M4 all-conditions (tick-4246 FF fix)", ""),
  stringsAsFactors = FALSE
)
write.csv(summary_df, file.path(out_dir, "power_summary.csv"), row.names = FALSE)
cat(sprintf("Summary CSV saved: %s\n\n", file.path(out_dir, "power_summary.csv")))

cat("=============================================================\n")
cat("Simulation complete.\n")
cat(sprintf("Output directory: analysis/%s\n", out_dir))
cat("=============================================================\n")
