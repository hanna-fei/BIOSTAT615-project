# The sampler: random-walk Metropolis-Hastings with a Normal(0, step_size)
# proposal. The proposal is symmetric, so the Hastings correction cancels and
# the acceptance ratio is r = f(x') / f(x).
#
# Returns a Run: a data frame with one row per iteration, in which
#   current   is the current position before the step,
#   proposal  is x' = current + Normal(0, step_size),
#   log_r     is log f(x') - log f(x)  (-Inf when x' is outside the support),
#   log_u     is the log of the uniform draw,
#   accepted  is log_u < log_r,
#   position  is the chain value recorded at this iteration.
# The chain is the `position` column. The settings are stored as attributes.
run_chain <- function(preset, k = NULL, n = NULL, step_size, start,
                      iterations, seed) {
  target <- get_target(preset, k, n)
  log_f <- target$log_target

  # The starting point must have log f > -Inf. Then log f(x) is always finite,
  # so log_r is either finite or -Inf (never -Inf - -Inf = NaN).
  log_f_current <- log_f(start)
  if (!is.finite(log_f_current)) {
    stop(target$support_message, call. = FALSE)
  }

  current <- numeric(iterations)
  proposal <- numeric(iterations)
  log_r <- numeric(iterations)
  log_u <- numeric(iterations)
  accepted <- logical(iterations)
  position <- numeric(iterations)

  # One set.seed, then exactly one Normal and one Uniform per iteration, in
  # that order, so the same seed gives the same Run in native R and in webR.
  set.seed(seed)
  x <- start
  for (i in seq_len(iterations)) {
    x_new <- x + stats::rnorm(1, mean = 0, sd = step_size)
    u <- stats::runif(1)

    log_f_new <- log_f(x_new)
    log_r_i <- log_f_new - log_f_current
    log_u_i <- log(u)
    accept <- log_u_i < log_r_i

    current[i] <- x
    proposal[i] <- x_new
    log_r[i] <- log_r_i
    log_u[i] <- log_u_i
    accepted[i] <- accept

    if (accept) {
      x <- x_new
      log_f_current <- log_f_new
    }
    position[i] <- x
  }

  run <- data.frame(
    iteration = seq_len(iterations),
    current = current,
    proposal = proposal,
    log_r = log_r,
    log_u = log_u,
    accepted = accepted,
    position = position
  )

  attr(run, "preset") <- preset
  attr(run, "k") <- k
  attr(run, "n") <- n
  attr(run, "step_size") <- step_size
  attr(run, "start") <- start
  attr(run, "iterations") <- iterations
  attr(run, "seed") <- seed
  run
}
