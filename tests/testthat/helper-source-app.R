# Load the app's plain R functions (targets, run_chain, summarise_chain, ...)
# so the tests run exactly the code that Shiny auto-sources in the browser.
# testthat runs helpers with the working directory set to tests/testthat/.

app_r_dir <- test_path("..", "..", "app", "R")

for (app_file in sort(list.files(app_r_dir, pattern = "\\.[Rr]$", full.names = TRUE))) {
  source(app_file, local = TRUE)
}

rm(app_r_dir, app_file)
