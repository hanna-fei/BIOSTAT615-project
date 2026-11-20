# Targets: one constructor per preset. Each returns the same list:
#
#   preset           the preset's display name
#   log_target(x)    log of the target up to a constant; -Inf outside the support
#   true_curve(x)    the exact, normalized density (for the walk and histogram panels)
#   true_mean        the target's exact mean
#   true_mean_label  how the true mean is printed in the diagnostics panel
#   default_start    the starting point the controls reset to for this preset
#   plot_range       fixed x-axis range for the walk and histogram panels
#   in_support(x)    TRUE where the target is positive
#   support_message  shown when the starting point is outside the support

# Drug trial: k successes in n patients, flat prior on the response rate p.
# The target is the binomial likelihood without its constant,
#   f(p) = p^k (1 - p)^(n - k)  on (0, 1),
# whose normalized form is Beta(k + 1, n - k + 1) with mean (k + 1) / (n + 2).
target_drug_trial <- function(k, n) {
  in_support <- function(p) p > 0 & p < 1

  log_target <- function(p) {
    out <- rep(-Inf, length(p))
    inside <- in_support(p)
    p_in <- p[inside]
    out[inside] <- k * log(p_in) + (n - k) * log1p(-p_in)
    out
  }

  list(
    preset = "Drug trial",
    log_target = log_target,
    true_curve = function(p) stats::dbeta(p, k + 1, n - k + 1),
    true_mean = (k + 1) / (n + 2),
    true_mean_label = sprintf("%d/%d", as.integer(k + 1), as.integer(n + 2)),
    default_start = 0.5,
    plot_range = c(0, 1),
    in_support = in_support,
    support_message = "Starting point must be between 0 and 1"
  )
}

# Look up a preset by its display name. k and n are used only by the Drug trial.
get_target <- function(preset, k = NULL, n = NULL) {
  switch(
    preset,
    "Drug trial" = target_drug_trial(k, n),
    stop("Unknown preset: ", preset, call. = FALSE)
  )
}
