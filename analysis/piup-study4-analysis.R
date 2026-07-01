# PIUP Study 4 Analysis Script
# Title: Does a temporal UI-lock on a vote receipt reduce coercion compliance
#        under adversarial pressure? A 2x2 between-subjects vignette experiment.
# Pre-registration: docs/piup-study4-osf-prereg-2026-07-01.md
# Design doc:       docs/piup-study4-temporal-coercion-vignette-2026-07-01.md
# Created: 2026-07-01 (tick-4390)
# Author: Jony Bursztyn
#
# Run this script AFTER data collection. All analyses are pre-registered.
# Do not modify the primary analysis section after unblinding condition assignments.
#
# Columns expected (from Qualtrics export — see pre-reg §12 variable reference):
#   condition            : "D0P1" | "D0P2" | "D1P1" | "D1P2"
#   ui_cond              : "D0" | "D1"
#   pressure_cond        : "P1" | "P2"
#   QR5_DV1              : integer 1–7  (sharing intent; higher = more sharing)
#   QR5_DV2              : integer 1–7  (perceived deniability; higher = more deniable)
#   QR3_DV3              : "Yes — the receipt showed how I voted" |
#                          "No — the receipt did not show how I voted" |
#                          "I'm not sure"
#   comprehension_check_correct : 1 (correct) | 0 (incorrect/not sure)
#   QR6_ATTN             : integer 1–7  (attention check; correct = 7)
#   attention_fail       : 0 | 1
#   QR6_M1               : integer 1–7  (technology self-efficacy)
#   QR6_C1               : "Yes" | "No"  (prior voting app experience)
#   Q_TotalDuration      : integer seconds

library(dplyr)
library(effsize)   # cohen.d(); install.packages("effsize") if needed
library(TOSTER)    # TOSTtwo(); install.packages("TOSTER") if needed

# ─────────────────────────────────────────────────────────────────────────────
# 0. LOAD DATA
# ─────────────────────────────────────────────────────────────────────────────

# Replace this path with the actual Qualtrics export CSV path before running.
# DATA_PATH <- "data/piup-study4-export.csv"
# df_raw <- read.csv(DATA_PATH, stringsAsFactors = FALSE)

# For dry-run testing: synthetic stub (remove before real analysis)
# set.seed(42)
# df_raw <- data.frame(
#   condition = sample(c("D0P1","D0P2","D1P1","D1P2"), 200, replace=TRUE),
#   ui_cond = sample(c("D0","D1"), 200, replace=TRUE),
#   pressure_cond = sample(c("P1","P2"), 200, replace=TRUE),
#   QR5_DV1 = sample(1:7, 200, replace=TRUE),
#   QR5_DV2 = sample(1:7, 200, replace=TRUE),
#   comprehension_check_correct = sample(c(0,1), 200, replace=TRUE, prob=c(0.2,0.8)),
#   QR6_ATTN = sample(c(7,7,7,7,7,7,7,1,2,3), 200, replace=TRUE),
#   attention_fail = 0,
#   QR6_M1 = sample(1:7, 200, replace=TRUE),
#   QR6_C1 = sample(c("Yes","No"), 200, replace=TRUE),
#   Q_TotalDuration = sample(180:800, 200, replace=TRUE)
# )

# ─────────────────────────────────────────────────────────────────────────────
# 1. EXCLUSION DERIVATION
# ─────────────────────────────────────────────────────────────────────────────

df <- df_raw %>%
  mutate(
    # Hard exclusions (replaced — do NOT appear in ITT sample)
    exclude_attn   = (QR6_ATTN != 7),
    exclude_time   = (Q_TotalDuration < 180),     # < 3 minutes
    exclude_any    = exclude_attn | exclude_time,

    # Sensitivity analysis flag (NOT an exclusion — stay in ITT)
    low_comprehension = (comprehension_check_correct == 0),

    # Factor coding (pre-registered reference levels)
    D = factor(ui_cond, levels = c("D0", "D1")),  # D0 = countdown-only (reference)
    P = factor(pressure_cond, levels = c("P1", "P2")),  # P1 = moderate (reference)

    # Centred M1 for regression
    M1_c = QR6_M1 - mean(QR6_M1, na.rm = TRUE),

    # C1 binary
    C1_bin = as.integer(QR6_C1 == "Yes")
  )

# Exclusion log
exclusion_log <- tibble::tibble(
  criterion = c("Attention check fail (QR6_ATTN != 7)",
                "Completion time < 3 min",
                "Any exclusion (union)"),
  n_excluded = c(sum(df$exclude_attn, na.rm=TRUE),
                 sum(df$exclude_time, na.rm=TRUE),
                 sum(df$exclude_any, na.rm=TRUE))
)
print(exclusion_log)

# ITT sample (primary analysis)
df_itt <- df %>% filter(!exclude_any)
cat("ITT N =", nrow(df_itt), "\n")
print(table(df_itt$condition))

# ─────────────────────────────────────────────────────────────────────────────
# 2. H4.2 — PRIMARY: D × P interaction on DV1 (run first, per pre-reg §7.1)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== H4.2: D × P interaction on DV1 (ANOVA) ======\n")

aov_h42 <- aov(QR5_DV1 ~ D * P, data = df_itt)
aov_summary <- summary(aov_h42)
print(aov_summary)

# η² partial for D × P interaction
ss <- aov_summary[[1]][["Sum Sq"]]
ss_dp <- ss[3]   # D:P interaction row
ss_resid <- ss[4]
eta2_partial_dp <- ss_dp / (ss_dp + ss_resid)
cat("η² partial (D × P) =", round(eta2_partial_dp, 4), "\n")

# Cell means
cell_means <- df_itt %>%
  group_by(D, P) %>%
  summarise(M_DV1 = mean(QR5_DV1, na.rm=TRUE), SD_DV1 = sd(QR5_DV1, na.rm=TRUE), n = n(), .groups="drop")
print(cell_means)

# Simple effects (pre-registered, only if interaction p < .05)
f_dp <- aov_summary[[1]][["F value"]][3]
p_dp <- aov_summary[[1]][["Pr(>F)"]][3]
cat("D × P: F =", round(f_dp, 3), ", p =", round(p_dp, 4), "\n")

if (p_dp < 0.05) {
  cat("\n--- Simple effects (interaction significant — planned contrasts) ---\n")

  # D1 vs. D0 within P1 (one-tailed: H4.2 predicts D1 < D0)
  within_p1 <- df_itt %>% filter(P == "P1")
  t_p1 <- t.test(QR5_DV1 ~ D, data = within_p1, alternative = "greater")  # D0 > D1
  cat("D1 vs. D0 within P1 (one-tailed, D0 > D1):\n")
  print(t_p1)

  # D1 vs. D0 within P2 (one-tailed: H4.2 predicts D1 < D0, larger reduction)
  within_p2 <- df_itt %>% filter(P == "P2")
  t_p2 <- t.test(QR5_DV1 ~ D, data = within_p2, alternative = "greater")
  cat("D1 vs. D0 within P2 (one-tailed, D0 > D1):\n")
  print(t_p2)

  # Compute interaction contrast: (M_D0_P2 - M_D1_P2) - (M_D0_P1 - M_D1_P1)
  cm <- cell_means
  contrast <- (cm$M_DV1[cm$D=="D0" & cm$P=="P2"] - cm$M_DV1[cm$D=="D1" & cm$P=="P2"]) -
              (cm$M_DV1[cm$D=="D0" & cm$P=="P1"] - cm$M_DV1[cm$D=="D1" & cm$P=="P1"])
  cat("Interaction contrast (D0_P2 - D1_P2) - (D0_P1 - D1_P1) =", round(contrast, 3), "\n")
  cat("Expected direction (positive = H4.2 supported):", contrast > 0, "\n")
} else {
  cat("D × P interaction not significant (p >= .05). Simple effects not run (pre-registered).\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. H4.1 — MAIN EFFECT: D (UI-lock) on DV1, collapsed over P
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== H4.1: Main effect of UI-lock on DV1 (one-tailed t-test) ======\n")

t_h41 <- t.test(QR5_DV1 ~ D, data = df_itt, alternative = "greater")  # D0 > D1
print(t_h41)

# Cohen's d (D0 vs. D1 on DV1)
d_h41 <- cohen.d(df_itt$QR5_DV1[df_itt$D == "D0"],
                  df_itt$QR5_DV1[df_itt$D == "D1"])
cat("Cohen's d (D0 > D1):", round(d_h41$estimate, 3),
    "95% CI [", round(d_h41$conf.int[1], 3), ",", round(d_h41$conf.int[2], 3), "]\n")
cat("H4.1 supported:", t_h41$p.value < 0.05, "\n")

# ─────────────────────────────────────────────────────────────────────────────
# 4. H4.3 — SECONDARY: D on DV2 (perceived deniability), one-tailed
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== H4.3: UI-lock effect on DV2 (perceived deniability) ======\n")

t_h43 <- t.test(QR5_DV2 ~ D, data = df_itt, alternative = "less")  # D1 > D0 → D0 < D1
print(t_h43)

d_h43 <- cohen.d(df_itt$QR5_DV2[df_itt$D == "D1"],
                  df_itt$QR5_DV2[df_itt$D == "D0"])
cat("Cohen's d (D1 > D0 on DV2):", round(d_h43$estimate, 3), "\n")
cat("H4.3 supported:", t_h43$p.value < 0.05, "\n")

cat("\nNote: DV2 asymmetry — in D0 cells the download button is enabled, so 'the app",
    "won't let me' is counterfactually deniable (not literally true). DV2 in D0 measures",
    "perceived usefulness of an unavailable excuse; DV2 in D1 measures perceived usefulness",
    "of an available, truthful excuse. This asymmetry limits causal inference from H4.3",
    "but does not preclude the test (pre-reg §6 H4.3 note).\n")

# ─────────────────────────────────────────────────────────────────────────────
# 5. H4.4 — EXPLORATORY: Self-efficacy moderation (D × P × M1)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== H4.4: Moderated regression (D × P × M1 on DV1) ======\n")

df_h44 <- df_itt %>%
  mutate(
    D_bin = as.numeric(D == "D1"),  # 0 = D0, 1 = D1
    P_bin = as.numeric(P == "P2")   # 0 = P1, 1 = P2
  )

lm_h44 <- lm(QR5_DV1 ~ D_bin * P_bin * M1_c, data = df_h44)
lm_summary <- summary(lm_h44)
print(lm_summary)

# Three-way interaction coefficient
coef_3way <- coef(lm_summary)["D_bin:P_bin:M1_c", ]
cat("D × P × M1 three-way: β =", round(coef_3way["Estimate"], 4),
    ", 95% CI: use confint(lm_h44)\n")
cat("ΔR² from three-way term: see model comparison below\n")

# ΔR² for three-way term
lm_h44_no3way <- lm(QR5_DV1 ~ D_bin * P_bin + D_bin * M1_c + P_bin * M1_c, data = df_h44)
anova_comparison <- anova(lm_h44_no3way, lm_h44)
print(anova_comparison)

# ─────────────────────────────────────────────────────────────────────────────
# 6. SENSITIVITY ANALYSES
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== Sensitivity Analyses ======\n")

# SA-1: Comprehension filter (exclude DV3 incorrect)
cat("\n--- SA-1: Comprehension filter (DV3-correct only) ---\n")
df_pp <- df_itt %>% filter(!low_comprehension)
cat("N after comprehension filter:", nrow(df_pp), "\n")
cat("Excluded for low comprehension (per condition):\n")
print(table(df_itt$condition[df_itt$low_comprehension]))

aov_sa1 <- aov(QR5_DV1 ~ D * P, data = df_pp)
cat("H4.2 ANOVA (SA-1):\n"); print(summary(aov_sa1))
t_sa1 <- t.test(QR5_DV1 ~ D, data = df_pp, alternative = "greater")
cat("H4.1 t-test (SA-1): p =", round(t_sa1$p.value, 4), "\n")

# SA-2: M1 as covariate on H4.1 and H4.2
cat("\n--- SA-2: M1 as covariate (not moderator) ---\n")
lm_sa2_h41 <- lm(QR5_DV1 ~ D + M1_c, data = df_h44)
lm_sa2_h42 <- lm(QR5_DV1 ~ D_bin * P_bin + M1_c, data = df_h44)
cat("H4.1 with M1 covariate:\n"); print(summary(lm_sa2_h41))
cat("H4.2 with M1 covariate:\n"); print(summary(lm_sa2_h42))

# SA-3: C1 as covariate
cat("\n--- SA-3: C1 (prior voting app experience) as covariate ---\n")
lm_sa3_h41 <- lm(QR5_DV1 ~ D + C1_bin, data = df_h44 %>% mutate(C1_bin = as.integer(QR6_C1 == "Yes")))
lm_sa3_h42 <- lm(QR5_DV1 ~ D_bin * P_bin + C1_bin, data = df_h44 %>% mutate(C1_bin = as.integer(QR6_C1 == "Yes")))
cat("H4.1 with C1 covariate:\n"); print(summary(lm_sa3_h41))
cat("H4.2 with C1 covariate:\n"); print(summary(lm_sa3_h42))

# SA-4: ANCOVA with M1 + C1 combined
cat("\n--- SA-4: ANCOVA — M1 + C1 combined covariates ---\n")
lm_sa4 <- lm(QR5_DV1 ~ D_bin * P_bin + M1_c + C1_bin,
             data = df_h44 %>% mutate(C1_bin = as.integer(QR6_C1 == "Yes")))
cat("H4.2 ANCOVA (M1 + C1 covariates):\n"); print(summary(lm_sa4))

# ─────────────────────────────────────────────────────────────────────────────
# 7. NULL RESULT PROTOCOL — TOST (pre-reg §7.3)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== Null Result Protocol: TOST ======\n")
cat("Run TOST if H4.1 is not significant (p >= .05, one-tailed).\n")
cat("Equivalence bounds: ±1 SD of DV1 (pooled, full ITT sample).\n")

sd_dv1 <- sd(df_itt$QR5_DV1, na.rm = TRUE)
cat("SD(DV1) pooled =", round(sd_dv1, 3), "\n")
cat("Equivalence bound (raw scale) = ±", round(sd_dv1, 3), "\n")

# Compute Cohen's d bounds (±1 SD in original scale → ±1 SD / SD_pooled)
# i.e., the raw bound equals 1 SD so in d units: bounds = ±1.0 ... but check
# TOSTER uses the bound in raw units or d units depending on function.
# TOSTtwo() takes bound_d (Cohen's d) or bound_raw.
# Bound in d units = raw_bound / SD_pooled = 1.0.

t_result_main <- t_h41  # H4.1 test result
p_h41 <- t_result_main$p.value

if (p_h41 >= 0.05) {
  cat("H4.1 not significant — running TOST with bounds ±1 SD (d = ±1.0).\n")

  # TOSTtwo: two-group independent samples
  n_d0 <- sum(df_itt$D == "D0", na.rm = TRUE)
  n_d1 <- sum(df_itt$D == "D1", na.rm = TRUE)
  m_d0 <- mean(df_itt$QR5_DV1[df_itt$D == "D0"], na.rm = TRUE)
  m_d1 <- mean(df_itt$QR5_DV1[df_itt$D == "D1"], na.rm = TRUE)
  sd_d0 <- sd(df_itt$QR5_DV1[df_itt$D == "D0"], na.rm = TRUE)
  sd_d1 <- sd(df_itt$QR5_DV1[df_itt$D == "D1"], na.rm = TRUE)

  # Equivalence bound: ±1 pooled SD of DV1 (raw scale), pre-registered.
  # tsum_TOST() is the current TOSTER API (>= 0.4.0); eqbound_type="raw" avoids
  # the biased SMD bound; eqb = sd_dv1 implements the pre-registered ±1-SD bound.
  tost_result <- tsum_TOST(
    m1 = m_d0, m2 = m_d1,
    sd1 = sd_d0, sd2 = sd_d1,
    n1 = n_d0, n2 = n_d1,
    eqb = sd_dv1,
    eqbound_type = "raw",
    alpha = 0.05
  )
  print(tost_result)
  tost_p1 <- tost_result$TOST$p.value[1]
  tost_p2 <- tost_result$TOST$p.value[2]
  cat("Equivalence established (both p < .05):", tost_p1 < 0.05 & tost_p2 < 0.05, "\n")
} else {
  cat("H4.1 significant — TOST not required.\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 8. DESCRIPTIVES AND DATA QUALITY SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== Descriptives ======\n")

cat("Cell Ns:\n")
print(table(df_itt$condition))

cat("\nDV1 means by condition:\n")
print(df_itt %>% group_by(D, P) %>%
  summarise(M = round(mean(QR5_DV1, na.rm=TRUE), 2),
            SD = round(sd(QR5_DV1, na.rm=TRUE), 2),
            n = n(), .groups="drop"))

cat("\nDV2 means by D condition:\n")
print(df_itt %>% group_by(D) %>%
  summarise(M_DV2 = round(mean(QR5_DV2, na.rm=TRUE), 2),
            SD_DV2 = round(sd(QR5_DV2, na.rm=TRUE), 2),
            n = n(), .groups="drop"))

cat("\nDV3 comprehension check rate:\n")
print(table(df_itt$comprehension_check_correct) / nrow(df_itt))

cat("\nM1 self-efficacy distribution:\n")
print(summary(df_itt$QR6_M1))

cat("\nC1 prior voting app experience:\n")
print(table(df_itt$QR6_C1) / nrow(df_itt))

cat("\n====== Analysis complete ======\n")
cat("Pre-registration: docs/piup-study4-osf-prereg-2026-07-01.md\n")
cat("Analysis created: 2026-07-01 (tick-4390)\n")
