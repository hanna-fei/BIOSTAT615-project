# Layer 2: the accept/reject rule.
# Every row of a Run must follow Metropolis-Hastings exactly: accept when
# log u < log r, record the proposal on acceptance and the current position
# again on rejection, and never produce NaN.

# Step size 0.5 from p = 0.5 sends many proposals outside (0, 1), so the
# out-of-support branch is exercised as well as ordinary accepts and rejects.
drug_run <- function(step_size = 0.5, iterations = 500, seed = 1) {
  run_chain("Drug trial", k = 14, n = 20, step_size = step_size,
            start = 0.5, iterations = iterations, seed = seed)
}

test_that("a Run has one row per iteration with the documented columns", {
  run <- drug_run(iterations = 300)
  expect_s3_class(run, "data.frame")
  expect_equal(nrow(run), 300)
  expect_named(run, c("iteration", "current", "proposal", "log_r",
                      "log_u", "accepted", "position"))
  expect_equal(run$iteration, 1:300)
  expect_type(run$accepted, "logical")
})

test_that("a Run stores its settings as attributes", {
  run <- drug_run(step_size = 0.1, iterations = 50, seed = 7)
  expect_equal(attr(run, "preset"), "Drug trial")
  expect_equal(attr(run, "k"), 14)
  expect_equal(attr(run, "n"), 20)
  expect_equal(attr(run, "step_size"), 0.1)
  expect_equal(attr(run, "start"), 0.5)
  expect_equal(attr(run, "iterations"), 50)
  expect_equal(attr(run, "seed"), 7)
})

test_that("a proposal is accepted exactly when log u < log r", {
  run <- drug_run()
  expect_identical(run$accepted, run$log_u < run$log_r)
  # Both outcomes actually occur, so the check above is not vacuous.
  expect_true(any(run$accepted))
  expect_true(any(!run$accepted))
})

test_that("a proposal with r >= 1 is always accepted", {
  run <- drug_run(step_size = 0.05)
  uphill <- run$log_r >= 0
  expect_true(any(uphill))
  expect_true(all(run$accepted[uphill]))
})

test_that("an out-of-range Drug trial proposal has r = 0 and is always rejected", {
  run <- drug_run()
  outside <- run$proposal <= 0 | run$proposal >= 1
  expect_true(any(outside))
  expect_true(all(run$log_r[outside] == -Inf))
  expect_false(any(run$accepted[outside]))
  # The chain itself never leaves the support.
  expect_true(all(run$position > 0 & run$position < 1))
})

test_that("no column of a Run ever contains NaN", {
  run <- drug_run()
  for (column in names(run)) {
    expect_false(any(is.nan(run[[column]])), label = column)
  }
})

test_that("a rejected proposal records the current position again", {
  run <- drug_run()
  rejected <- !run$accepted
  expect_identical(run$position[rejected], run$current[rejected])
})

test_that("an accepted proposal becomes the new position", {
  run <- drug_run()
  accepted <- run$accepted
  expect_identical(run$position[accepted], run$proposal[accepted])
})

test_that("each iteration starts where the previous one ended", {
  run <- drug_run()
  expect_identical(run$current[1], 0.5)
  expect_identical(run$current[-1], run$position[-nrow(run)])
})

test_that("a starting point outside the support is refused", {
  for (bad_start in c(0, 1, -0.2, 1.5)) {
    expect_error(
      run_chain("Drug trial", k = 14, n = 20, step_size = 0.1,
                start = bad_start, iterations = 10, seed = 1),
      "Starting point must be between 0 and 1"
    )
  }
})
