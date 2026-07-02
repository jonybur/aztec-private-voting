# PIUP Study 3 Analysis Script
# Title: Does a social proof signal on a vote receipt increase post-vote
#        verification return rates? A two-arm field feasibility pilot.
# Pre-registration: docs/piup-study3-osf-prereg-2026-07-01.md
# Design doc:       docs/piup-study3-social-verification-2026-06-29.md
# Power analysis:   docs/piup-study3-power-analysis-2026-06-29.md
# Created: 2026-07-01 (tick-4405)
# Author: Jony Bursztyn
#
# ─────────────────────────────────────────────────────────────────────────────
# IMPORTANT: This is a FEASIBILITY PILOT.
#   - No NHST p-value threshold is applied to the primary endpoint (DV1).
#   - Inferential summary = 90% CI for the condition odds ratio (§6).
#   - Do not modify the primary analysis after unblinding condition assignments.
#   - Run only AFTER the OSF pre-registration is filed and confirmed.
# ─────────────────────────────────────────────────────────────────────────────
#
# DATA PIPELINE OVERVIEW (Study 3 is a live-election field study):
#   - DV1 (verified at T+14): derived from on-chain logs + participant self-report
#   - DV2, M1 (T0): post-vote survey administered immediately after receipt display
#   - DV3, DV4, C1 (T+14): 14-day follow-up survey
#   - DV5 (opt-in log): timestamped on-chain verify_vote_counted() calls
#   - condition: "control" | "treatment" (assigned at T0, server-side)
#
# Expected merged data columns (one row per participant):
#   participant_id     : string (pseudonymous)
#   condition          : "control" | "treatment"
#   dv1_verified       : integer 0 | 1 (verified on-chain OR self-reported at T+14)
#   dv1_onchain        : integer 0 | 1 | NA (verified per on-chain log; NA if DV5 not opted-in)
#   dv1_selfreport     : integer 0 | 1 | NA (self-reported at T+14 follow-up; NA if lost to FU)
#   dv2_intent         : integer 1–7 (intent to verify, T0; may be post-treatment for late voters)
#   dv3_comprehension  : integer 0 | 1 (comprehension composite correct; adapted Q1–Q4 rubric)
#   dv4_trust1         : integer 1–7 ("The receipt convinced me my vote was counted")
#   dv4_trust2         : integer 1–7 ("I understand what the receipt is for")
#   m1_efficacy1–4     : integer 1–5 each (adapted Compeau-Higgins; m1_eff1...m1_eff4)
#   c1_reason          : character (open-ended; qualitative only)
#   log_optin          : integer 0 | 1 (consented to on-chain log analysis at T0)
#   log_n_calls        : integer or NA (number of verify calls logged; NA if not opt-in)
#   log_first_call_day : numeric or NA (days from T0 to first verify call; NA if 0 calls)
#   partial_verify_fail: integer 0 | 1 (aborted call flagged by deployment system)
#   late_voter         : integer 0 | 1 (1 = voted after counter floor was reached; DV2 post-treat)

library(dplyr)
library(broom)   # tidy() on glm; install.packages("broom") if needed
library(survival) # survfit, Surv; install.packages("survival") if needed

# For Kaplan-Meier plots (optional, install if available):
# library(survminer)  # ggsurvplot

# ─────────────────────────────────────────────────────────────────────────────
# 0. LOAD DATA
# ─────────────────────────────────────────────────────────────────────────────
# Replace this with the actual merged data path before analysis.
# DATA_PATH <- "data/piup-study3-merged.csv"
# df_raw <- read.csv(DATA_PATH, stringsAsFactors = FALSE)

# Dry-run stub (synthetic — remove before real analysis):
# set.seed(99)
# N <- 80
# df_raw <- data.frame(
#   participant_id  = paste0("P", sprintf("%03d", 1:N)),
#   condition       = sample(c("control","treatment"), N, replace=TRUE),
#   dv1_verified    = sample(c(0,1), N, replace=TRUE, prob=c(0.85, 0.15)),
#   dv1_onchain     = NA_integer_,
#   dv1_selfreport  = sample(c(0,1,NA), N, replace=TRUE, prob=c(0.7,0.15,0.15)),
#   dv2_intent      = sample(1:7, N, replace=TRUE),
#   dv3_comprehension = sample(c(0,1), N, replace=TRUE, prob=c(0.2,0.8)),
#   # NOTE: Dry-run uses pre-computed dv3_comprehension. Real Qualtrics data will have
#   # raw item columns dv3_q1–dv3_q4 instead. See DV3 SCORING block below (after mutate).
#   # Simulated raw items for end-to-end scoring test (optional — keep if testing Option A/B):
#   # dv3_q1 = sample(c("Yes","No","I'm not sure"), N, replace=TRUE, prob=c(0.75,0.15,0.10)),
#   # dv3_q2 = sample(c("No","Yes","I'm not sure"), N, replace=TRUE, prob=c(0.70,0.20,0.10)),
#   # dv3_q3 = sample(c("No","Yes","I'm not sure"), N, replace=TRUE, prob=c(0.70,0.20,0.10)),
#   # dv3_q4 = sample(c("b","a","c","d"), N, replace=TRUE, prob=c(0.75,0.10,0.10,0.05)),
#   dv4_trust1      = sample(1:7, N, replace=TRUE),
#   dv4_trust2      = sample(1:7, N, replace=TRUE),
#   m1_eff1         = sample(1:5, N, replace=TRUE),
#   m1_eff2         = sample(1:5, N, replace=TRUE),
#   m1_eff3         = sample(1:5, N, replace=TRUE),
#   m1_eff4         = sample(1:5, N, replace=TRUE),
#   c1_reason       = rep("N/A", N),
#   log_optin       = sample(c(0,1), N, replace=TRUE, prob=c(0.4,0.6)),
#   log_n_calls     = NA_integer_,
#   log_first_call_day = NA_real_,
#   partial_verify_fail = sample(c(0,1), N, replace=TRUE, prob=c(0.95,0.05)),
#   late_voter      = sample(c(0,1), N, replace=TRUE, prob=c(0.7,0.3))
# )

# ─────────────────────────────────────────────────────────────────────────────
# 1. DERIVED VARIABLES AND DATA PREPARATION
# ─────────────────────────────────────────────────────────────────────────────

df <- df_raw %>%
  mutate(
    # Factor coding (pre-reg §7.1): control = reference
    cond_fac = factor(condition, levels = c("control", "treatment")),
    cond_bin = as.integer(condition == "treatment"),  # 0=control, 1=treatment

    # M1 composite (mean of 4 items; Compeau-Higgins scale adapted)
    m1_composite = rowMeans(cbind(m1_eff1, m1_eff2, m1_eff3, m1_eff4), na.rm = TRUE),
    m1_c = m1_composite - mean(rowMeans(cbind(m1_eff1, m1_eff2, m1_eff3, m1_eff4), na.rm=TRUE),
                               na.rm = TRUE),  # mean-centred for regression

    # DV4 composite
    dv4_trust = rowMeans(cbind(dv4_trust1, dv4_trust2), na.rm = TRUE),

    # DV2 mean-centred (covariate in primary analysis)
    dv2_c = dv2_intent - mean(dv2_intent, na.rm = TRUE),

    # Partial verifier flag (coded as missing in ITT; see §7.2 SA-1)
    dv1_for_itt = if_else(partial_verify_fail == 1L, NA_integer_, dv1_verified)
  )

# ─────────────────────────────────────────────────────────────────────────────
# DV3 SCORING — UNCOMMENT WHEN REAL DATA ARRIVES
# (Dry-run stub uses pre-computed dv3_comprehension = 0|1. Real Qualtrics data
#  has raw item columns dv3_q1, dv3_q2, dv3_q3, dv3_q4 from the T+14 survey.
#  See survey instrument: docs/piup-study3-survey-instrument-2026-07-01.md §5.2.)
#
# ⚠️ JONY-DECISION REQUIRED before uncommenting — select ONE of the two options:
#   Option A (recommended, per instrument §5.2): all-4-correct binary.
#     Uncomment the OPTION A block below.
#   Option B: majority-rule (≥3 of 4 correct). Requires a sensitivity SA.
#     Uncomment the OPTION B block below.
#
# Qualtrics export column names (rename if Qualtrics exports differently):
#   dv3_q1 — response to DV3-1 ("Does verifying confirm vote was counted?")
#             Correct answer: "Yes"
#   dv3_q2 — response to DV3-2 ("Does verifying reveal which option you chose?")
#             Correct answer: "No"
#   dv3_q3 — response to DV3-3 (wording PENDING JONY DECISION — two options, tick-4437):
#     Option DV3-3A (recommended): "If you verified your vote in front of another person,
#                                   could they learn which option you voted for?"
#     Option DV3-3B (keep original): "If you showed your receipt link to another person,
#                                    could they learn which option you chose?"
#     Either way: Correct answer = "No". Score unchanged; update this comment + instrument
#     §5.2 once Jony confirms. Combined OSF amendment: DV3 items + scoring rule (tick-4437).
#   dv3_q4 — response to DV3-4 ("What does successful verification prove?")
#             Correct answer: option (b) — "Counted, not choice"
#             Qualtrics exports verbatim text or recoded value; use the correct match below.
#
# ── OPTION A (ALL-CORRECT BINARY — RECOMMENDED) ───────────────────────────
# Uncomment lines below once DV3 item wording is confirmed and Jony selects Option A:
#
# df <- df %>%
#   mutate(
#     dv3_q1_correct = as.integer(dv3_q1 == "Yes"),
#     dv3_q2_correct = as.integer(dv3_q2 == "No"),
#     dv3_q3_correct = as.integer(dv3_q3 == "No"),
#     dv3_q4_correct = as.integer(dv3_q4 == "b"),  # or verbatim text if Qualtrics exports it
#     dv3_comprehension = as.integer(
#       dv3_q1_correct == 1L & dv3_q2_correct == 1L &
#       dv3_q3_correct == 1L & dv3_q4_correct == 1L
#     )
#   )
#
# ── OPTION B (MAJORITY RULE — ≥3 of 4 CORRECT) ────────────────────────────
# Uncomment lines below if Jony selects Option B instead:
# (If Option B: also add a sensitivity analysis comparing to Option A scoring.)
#
# df <- df %>%
#   mutate(
#     dv3_q1_correct = as.integer(dv3_q1 == "Yes"),
#     dv3_q2_correct = as.integer(dv3_q2 == "No"),
#     dv3_q3_correct = as.integer(dv3_q3 == "No"),
#     dv3_q4_correct = as.integer(dv3_q4 == "b"),
#     dv3_n_correct  = dv3_q1_correct + dv3_q2_correct + dv3_q3_correct + dv3_q4_correct,
#     dv3_comprehension = as.integer(dv3_n_correct >= 3L)
#   )
# # Option B sensitivity (add to §7.5 exploratory section):
# # cat("\n  [SA-DV3] Re-check with Option A strict scoring:\n")
# # df_sa_dv3a <- df %>% mutate(
# #   dv3_comprehension = as.integer(dv3_q1_correct == 1L & dv3_q2_correct == 1L &
# #                                  dv3_q3_correct == 1L & dv3_q4_correct == 1L))
# # print(table(df_sa_dv3a$condition, df_sa_dv3a$dv3_comprehension))
#
# ── IF DATA HAS PRE-COMPUTED dv3_comprehension (merged externally) ──────────
# If the merged CSV already has a binary dv3_comprehension column (0/1),
# skip both blocks above. Verify column is integer 0|1 before proceeding:
# stopifnot(all(df$dv3_comprehension %in% c(0L, 1L, NA_integer_)))
# ─────────────────────────────────────────────────────────────────────────────

cat("Total loaded N =", nrow(df), "\n")
cat("Condition assignment:\n"); print(table(df$condition))

# ITT sample: primary analysis uses dv1_verified; partial verify failures = missing
df_itt <- df %>% filter(!is.na(dv1_for_itt))
cat("ITT N (excl. partial verify failures) =", nrow(df_itt), "\n")

# Manipulation check: was counter floor reached?
n_treat <- sum(df$condition == "treatment")
n_ctrl  <- sum(df$condition == "control")
cat("Treatment n =", n_treat, "| Control n =", n_ctrl, "\n")

# NOTE: If the social proof counter never reached the floor (≥5 verifications in
# the treatment condition), the manipulation was not delivered. In this case, do
# NOT run the primary logistic regression. Report descriptives only and follow the
# manipulation-failure protocol (pre-reg §7.7). Jony must inspect deployment logs
# to determine whether and when the floor was reached before proceeding.
cat("\n[DEPLOYMENT CHECK REQUIRED] Confirm counter floor (≥5 verifications) was\n",
    "reached in the treatment condition before T+14. Check deployment logs.\n",
    "If floor NOT reached: skip §7.1 primary analysis; report §7.7 protocol.\n\n")

# ─────────────────────────────────────────────────────────────────────────────
# 2. PRIMARY ANALYSIS — §7.1
#    Logistic regression: DV1 ~ Condition + DV2 (intent) + M1 (self-efficacy)
#    Inferential summary: OR + 90% CI for condition coefficient
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.1 PRIMARY: Logistic regression (ITT) ======\n")
cat("Model: dv1_verified ~ condition + dv2_intent + m1_composite\n")
cat("Inferential framework: 90% CI for condition OR — no NHST threshold.\n\n")

glm_primary <- glm(dv1_for_itt ~ cond_bin + dv2_c + m1_c,
                   data   = df_itt,
                   family = binomial(link = "logit"))

cat("Model summary:\n")
print(summary(glm_primary))

# OR with 90% CI (confint uses profile likelihood by default)
ci_90 <- confint(glm_primary, level = 0.90)
or_table <- exp(cbind(OR = coef(glm_primary), ci_90))
cat("\nOdds ratios (90% CI):\n")
print(round(or_table, 3))

or_condition    <- or_table["cond_bin", "OR"]
or_ci_lower     <- or_table["cond_bin", "5 %"]
or_ci_upper     <- or_table["cond_bin", "95 %"]

cat("\nCondition OR =", round(or_condition, 3),
    " 90% CI [", round(or_ci_lower, 3), ",", round(or_ci_upper, 3), "]\n")

# Verification rates per condition (descriptive with 95% binomial CI)
cat("\nVerification rates per condition (descriptive):\n")
rates <- df_itt %>%
  group_by(condition) %>%
  summarise(
    n        = n(),
    n_verified = sum(dv1_for_itt, na.rm = TRUE),
    rate     = mean(dv1_for_itt, na.rm = TRUE),
    ci_lo    = binom.test(sum(dv1_for_itt, na.rm=TRUE), n())$conf.int[1],
    ci_hi    = binom.test(sum(dv1_for_itt, na.rm=TRUE), n())$conf.int[2],
    .groups  = "drop"
  )
print(rates)

# Pre-specified interpretation rule (pre-reg §6 table)
cat("\n--- Pre-specified interpretation rule (pre-reg §6) ---\n")
if (or_ci_lower >= 1.5) {
  verdict <- "Social proof effect plausible (CI lower >= 1.5). Proceed to powered replication (N >= 280)."
} else if (or_ci_upper >= 1.0) {
  verdict <- "Effect uncertain (CI width indeterminate). Use CI + baseline to select powered replication N from power analysis Table 2."
} else {
  verdict <- "CI upper < 1.0: counter may SUPPRESS verification. Investigate mechanism before replication. Do NOT proceed to powered replication without design revision."
}
cat("Verdict:", verdict, "\n")

# ─────────────────────────────────────────────────────────────────────────────
# 3. SENSITIVITY ANALYSIS 1 — §7.2
#    Partial verifiers recoded as 0 (non-verifiers)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.2 SA-1: Partial verifiers as non-verifiers ======\n")

n_partial <- sum(df$partial_verify_fail == 1, na.rm = TRUE)
cat("Partial verify failures recoded as 0:", n_partial, "\n")

if (n_partial > 0) {
  df_sa1 <- df %>%
    mutate(dv1_sa1 = if_else(partial_verify_fail == 1L, 0L, dv1_verified))

  glm_sa1 <- glm(dv1_sa1 ~ cond_bin + dv2_c + m1_c,
                 data   = df_sa1,
                 family = binomial(link = "logit"))
  ci_sa1 <- exp(confint(glm_sa1, level = 0.90))["cond_bin", ]
  or_sa1 <- exp(coef(glm_sa1)["cond_bin"])
  cat("SA-1 condition OR =", round(or_sa1, 3),
      " 90% CI [", round(ci_sa1[1], 3), ",", round(ci_sa1[2], 3), "]\n")
  cat("OR difference vs. primary:", round(or_sa1 - or_condition, 3), "\n")
} else {
  cat("No partial verify failures in data — SA-1 not applicable.\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 4. SENSITIVITY ANALYSIS 2 — §7.3
#    Per-protocol analysis: opt-in log subsample (DV5)
#    Compares OR estimates from self-report vs. on-chain DV1 within this subsample
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.3 SA-2: Per-protocol (opt-in log subsample) ======\n")

df_optin <- df %>% filter(log_optin == 1L)
cat("Log opt-in subsample N =", nrow(df_optin), "\n")

if (nrow(df_optin) >= 10 && !all(is.na(df_optin$dv1_onchain))) {
  # Self-report DV1 in opt-in subsample
  glm_sa2_sr <- glm(dv1_verified ~ cond_bin + dv2_c + m1_c,
                    data   = df_optin,
                    family = binomial(link = "logit"))
  or_sa2_sr <- exp(coef(glm_sa2_sr)["cond_bin"])
  ci_sa2_sr <- exp(confint(glm_sa2_sr, level = 0.90))["cond_bin", ]
  cat("SA-2 (self-report DV1, opt-in subsample):",
      "OR =", round(or_sa2_sr, 3),
      "90% CI [", round(ci_sa2_sr[1], 3), ",", round(ci_sa2_sr[2], 3), "]\n")

  # On-chain DV1 in opt-in subsample (if available)
  df_optin_oc <- df_optin %>% filter(!is.na(dv1_onchain))
  if (nrow(df_optin_oc) >= 10) {
    glm_sa2_oc <- glm(dv1_onchain ~ cond_bin + dv2_c + m1_c,
                      data   = df_optin_oc,
                      family = binomial(link = "logit"))
    or_sa2_oc <- exp(coef(glm_sa2_oc)["cond_bin"])
    ci_sa2_oc <- exp(confint(glm_sa2_oc, level = 0.90))["cond_bin", ]
    cat("SA-2 (on-chain DV1, opt-in subsample):",
        "OR =", round(or_sa2_oc, 3),
        "90% CI [", round(ci_sa2_oc[1], 3), ",", round(ci_sa2_oc[2], 3), "]\n")
    cat("SR vs. on-chain OR difference:",
        round(or_sa2_sr - or_sa2_oc, 3), "\n")
  } else {
    cat("Insufficient on-chain records for on-chain comparison.\n")
  }
} else {
  cat("Opt-in subsample too small or no on-chain data — SA-2 not estimable.\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 5. SENSITIVITY ANALYSIS 3 — §7.8
#    DV2 timing heterogeneity: re-run primary excluding DV2 as covariate
#    Applies to participants who voted AFTER counter floor was reached (late voters)
#    — for these, DV2 is post-treatment and may bias the primary estimate
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.8 SA-3: DV2 timing heterogeneity ======\n")

n_late <- sum(df_itt$late_voter == 1L, na.rm = TRUE)
pct_late <- round(100 * n_late / nrow(df_itt), 1)
cat("Late voters (voted after counter floor reached):", n_late,
    "(", pct_late, "% of ITT) — DV2 is post-treatment for this subgroup.\n")

# Re-run without DV2 covariate
glm_sa3 <- glm(dv1_for_itt ~ cond_bin + m1_c,
               data   = df_itt,
               family = binomial(link = "logit"))
or_sa3 <- exp(coef(glm_sa3)["cond_bin"])
ci_sa3 <- exp(confint(glm_sa3, level = 0.90))["cond_bin", ]
cat("SA-3 (without DV2):",
    "OR =", round(or_sa3, 3),
    "90% CI [", round(ci_sa3[1], 3), ",", round(ci_sa3[2], 3), "]\n")
cat("OR difference (with vs. without DV2):", round(or_condition - or_sa3, 3), "\n")

or_pct_diff <- abs(or_condition - or_sa3) / or_condition * 100
if (or_pct_diff > 10) {
  cat("WARNING: OR estimates differ by >10% (", round(or_pct_diff, 1),
      "%) — report both estimates and note post-treatment bias mechanism.\n")
} else {
  cat("OR estimates agree within 10% — post-treatment bias not detected.\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 6. EXPLORATORY: MODERATION BY SELF-EFFICACY — §7.4
#    Condition × M1 interaction (exploratory; underpowered at pilot N)
#    Stratify by self-efficacy tertile if interaction p < .10
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.4 EXPLORATORY: Self-efficacy moderation ======\n")

glm_mod <- glm(dv1_for_itt ~ cond_bin * m1_c,
               data   = df_itt,
               family = binomial(link = "logit"))
cat("Model: dv1 ~ condition * m1_c (logistic)\n")
print(summary(glm_mod))

coef_int <- coef(glm_mod)["cond_bin:m1_c"]
pval_int <- summary(glm_mod)$coefficients["cond_bin:m1_c", "Pr(>|z|)"]
cat("Condition × M1 interaction: β =", round(coef_int, 4),
    ", p =", round(pval_int, 4), "\n")

if (pval_int < 0.10) {
  cat("Interaction p < .10 — stratifying by self-efficacy tertile (pre-registered).\n")

  # Tertile split based on T0 data (pre-registered cut)
  tertile_breaks <- quantile(df_itt$m1_composite, probs = c(1/3, 2/3), na.rm = TRUE)
  df_itt <- df_itt %>%
    mutate(m1_tertile = case_when(
      m1_composite <= tertile_breaks[1] ~ "Low",
      m1_composite <= tertile_breaks[2] ~ "Medium",
      TRUE                              ~ "High"
    ),
    m1_tertile = factor(m1_tertile, levels = c("Low", "Medium", "High")))

  cat("M1 tertile distribution:\n")
  print(table(df_itt$m1_tertile))

  cat("OR per tertile (exploratory):\n")
  for (tert in c("Low", "Medium", "High")) {
    df_tert <- df_itt %>% filter(m1_tertile == tert)
    if (nrow(df_tert) >= 10 && length(unique(df_tert$dv1_for_itt)) > 1) {
      g <- glm(dv1_for_itt ~ cond_bin, data = df_tert, family = binomial(link = "logit"))
      or_t <- exp(coef(g)["cond_bin"])
      ci_t <- tryCatch(exp(confint(g, level = 0.90))["cond_bin", ],
                       error = function(e) c(NA, NA))
      cat("  ", tert, "M1: OR =", round(or_t, 3),
          " 90% CI [", round(ci_t[1], 3), ",", round(ci_t[2], 3), "]\n")
    } else {
      cat("  ", tert, "M1: insufficient variation in DV1 — OR not estimable.\n")
    }
  }
  cat("NOTE: Stratified ORs are exploratory; underpowered at pilot N. No primary inference.\n")
} else {
  cat("Interaction p >= .10 — stratified analysis not run (pre-registered threshold not met).\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 7. EXPLORATORY: COMPREHENSION (RQ3b) — §7.5
#    χ² on DV3 comprehension composite across conditions (predicted null)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.5 EXPLORATORY: Comprehension by condition (DV3) ======\n")

dv3_table <- table(df_itt$condition, df_itt$dv3_comprehension)
cat("DV3 correct by condition (0=incorrect, 1=correct):\n")
print(dv3_table)

if (all(dv3_table >= 1) && length(unique(df_itt$dv3_comprehension)) > 1) {
  chi_dv3 <- chisq.test(dv3_table, correct = FALSE)
  cat("χ²(", chi_dv3$parameter, ") =", round(chi_dv3$statistic, 3),
      ", p =", round(chi_dv3$p.value, 4), "\n")
  cat("Predicted: null condition difference in comprehension.\n")
  cat("Note: RQ3b is exploratory and underpowered at pilot N.\n")
} else {
  cat("Insufficient cell counts for χ² — report raw proportions only.\n")
  cat("Comprehension rates per condition:\n")
  print(prop.table(dv3_table, margin = 1))
}

# ─────────────────────────────────────────────────────────────────────────────
# 8. DESCRIPTIVE: TIME-TO-VERIFY SURVIVAL ANALYSIS (RQ3c) — §7.6
#    Kaplan-Meier by condition; log-rank test
#    ONLY if log opt-in n >= 40 (pre-registered threshold)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.6 DESCRIPTIVE: Time-to-verify survival (RQ3c) ======\n")

n_optin_with_log <- sum(df$log_optin == 1L & !is.na(df$log_first_call_day), na.rm = TRUE)
cat("Log opt-in n with timing data:", n_optin_with_log, "\n")

if (n_optin_with_log >= 40) {
  cat("Threshold met (>= 40) — running Kaplan-Meier survival analysis.\n")

  df_surv <- df %>%
    filter(log_optin == 1L) %>%
    mutate(
      # Participants who verified: event time = log_first_call_day
      # Participants who didn't verify: censored at day 14
      surv_time  = if_else(!is.na(log_first_call_day), log_first_call_day, 14.0),
      surv_event = if_else(!is.na(log_first_call_day), 1L, 0L)
    )

  surv_obj <- Surv(time = df_surv$surv_time, event = df_surv$surv_event)
  km_fit   <- survfit(surv_obj ~ condition, data = df_surv)
  cat("Kaplan-Meier summary:\n")
  print(summary(km_fit, times = c(1, 3, 7, 14)))

  # Log-rank test
  logrank <- survdiff(surv_obj ~ condition, data = df_surv)
  p_logrank <- 1 - pchisq(logrank$chisq, df = length(logrank$n) - 1)
  cat("Log-rank test: χ²(1) =", round(logrank$chisq, 3),
      ", p =", round(p_logrank, 4), "\n")
  cat("NOTE: This is descriptive; no confirmatory inference. Underpowered at pilot N.\n")

  # Plot (requires survminer; comment out if not installed)
  # if (requireNamespace("survminer", quietly = TRUE)) {
  #   ggsurvplot(km_fit, data = df_surv, risk.table = TRUE,
  #              title = "PIUP Study 3: Time-to-verify KM curves",
  #              xlab = "Days from T0", ylab = "Proportion not yet verified")
  # }
} else {
  cat("Threshold NOT met (< 40 log opt-ins with timing data) — survival analysis not run.\n")
  cat("Report descriptive: proportion who verified per condition is already in §7.1.\n")
}

# ─────────────────────────────────────────────────────────────────────────────
# 9. SECONDARY OUTCOMES — DV2, DV4
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== SECONDARY OUTCOMES (descriptive) ======\n")

# DV2 — Stated intent to verify at T0 (not a primary endpoint; covariate in §7.1)
cat("DV2 (stated intent to verify, T0) by condition:\n")
dv2_summary <- df_itt %>%
  group_by(condition) %>%
  summarise(M_DV2 = round(mean(dv2_intent, na.rm=TRUE), 2),
            SD_DV2 = round(sd(dv2_intent, na.rm=TRUE), 2),
            n = n(), .groups = "drop")
print(dv2_summary)
cat("NOTE: DV2 is a covariate in the primary model, not a confirmatory endpoint.",
    "Late voters' DV2 is post-treatment (see §7.8 SA-3).\n")

# DV4 — Affect toward receipt at T+14 (trust composite)
cat("\nDV4 (trust composite at T+14) by condition:\n")
dv4_summary <- df %>%
  filter(!is.na(dv4_trust)) %>%
  group_by(condition) %>%
  summarise(M_DV4 = round(mean(dv4_trust, na.rm=TRUE), 2),
            SD_DV4 = round(sd(dv4_trust, na.rm=TRUE), 2),
            n = n(), .groups = "drop")
print(dv4_summary)

# ─────────────────────────────────────────────────────────────────────────────
# 10. MANIPULATION FAILURE CHECK (pre-reg §7.7)
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== §7.7 MANIPULATION FAILURE CHECK ======\n")
cat("Confirm via deployment logs: did the social proof counter activate in the\n",
    "treatment condition (i.e., were >= 5 unique receipt IDs verified on-chain\n",
    "before the end of the 14-day window in at least 1 voter's view of the receipt)?\n\n")
cat("IF floor was NOT reached:\n",
    "  - The treatment was not delivered as designed.\n",
    "  - Report verification rates descriptively (raw fractions per condition).\n",
    "  - Do NOT run the §7.1 primary logistic regression.\n",
    "  - Classify as implementation feasibility check.\n",
    "  - Revise floor threshold (e.g., to >= 3) before powered replication registration.\n")
cat("IF floor WAS reached:\n",
    "  - Proceed with §7.1 primary analysis above.\n",
    "  - Note the day (T+D) when floor was reached and the treatment counter value\n",
    "    seen by the median late voter.\n")

# ─────────────────────────────────────────────────────────────────────────────
# 11. DATA QUALITY AND ATTRITION SUMMARY
# ─────────────────────────────────────────────────────────────────────────────
cat("\n====== DATA QUALITY SUMMARY ======\n")

cat("Total participants at T0:", nrow(df), "\n")
cat("Condition balance:", paste(names(table(df$condition)),
                                 table(df$condition), sep=" = ", collapse="; "), "\n")
cat("Lost to follow-up (no T+14 DV1):",
    sum(is.na(df$dv1_verified)), "\n")
cat("Partial verify failures:", n_partial, "\n")
cat("Log opt-in rate:", round(mean(df$log_optin), 3), "\n")
cat("Late voters (DV2 post-treatment):", n_late, "\n")

cat("\nM1 self-efficacy descriptives (full sample):\n")
print(summary(df$m1_composite))

cat("\nVerification rates (raw, full sample):\n")
print(df %>%
  group_by(condition) %>%
  summarise(rate = round(mean(dv1_verified, na.rm=TRUE), 3), n = n(), .groups="drop"))

cat("\n====== Analysis complete ======\n")
cat("Pre-registration: docs/piup-study3-osf-prereg-2026-07-01.md\n")
cat("Analysis created: 2026-07-01 (tick-4405)\n")
cat("NOTE: This is a feasibility pilot. No NHST threshold applies to the primary endpoint.\n",
    "Inferential summary = 90% CI for condition OR. Report both OR and CI width.\n")
