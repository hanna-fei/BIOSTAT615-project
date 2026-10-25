# SPEC: Metropolis-Hastings Explorer

BIOSTAT 615 final project, Track A (interactive web app). Repository: https://github.com/hanna-fei/BIOSTAT615-project (public).

This document is addressed to the coding agent that will build the project. It was produced from a grilling session with the project owner. Every decision below was confirmed by the owner; where this document says "must", treat it as a requirement. The vocabulary in **Glossary** (at the end) is canonical: use those terms in code, UI labels, issues and commit messages, and avoid the listed synonyms.

---

## Problem Statement

Metropolis-Hastings is easy to state and easy to get wrong. A student can implement the four steps (propose, compare, accept or reject, repeat) and still not understand why the **step size** decides whether the output is any good. Too small a step size gives a chain that accepts almost everything yet crawls, so its samples are highly correlated and it may not reach the bulk of the target in time. Too large a step size gives a chain that rejects almost everything and sits still. On a target with two separated modes, a small step size can stay in one mode forever, and the answer is confidently wrong with nothing obviously broken.

Static textbook figures show one finished chain at a time. They do not let a reader watch individual proposals being accepted or rejected, rewind to the moment a chain gets stuck, or change the step size and immediately see the acceptance rate, the effective sample size and the estimate move. The project owner's classmates and the course grader, who are statistically literate, need a tool that demonstrates this mechanism correctly and verifiably, not just plausibly.

## Solution

A single-page R Shiny app that runs entirely in the browser through Shinylive and webR, hosted on GitHub Pages, so it needs no server and no install.

The user picks a **preset** (Drug trial, Standard normal, or Bimodal distribution), a **step size** on a log-scale slider, a **starting point**, a number of iterations, a **burn-in** and a seed, and presses **Run**. The app computes the whole **chain** at once (a **Run**), then plays it back with a single slider that has a built-in play button. Four panels follow the **viewed iteration**:

- **Walk**: the **true curve** of the target, a dot at the **current position**, and a fading **trail** of the last 50 **proposals** in green (accepted) or red (rejected). The latest proposal's **acceptance ratio** r and **uniform draw** u are printed below.
- **Trace**: chain value against iteration, with the burn-in region shaded.
- **Histogram**: the chain after burn-in up to the viewed iteration, with the true curve overlaid.
- **Diagnostics**: **acceptance rate**, **ESS**, the **estimate** next to the true mean, and an autocorrelation plot.

A **Run log** table below the panels records one row per Run in the current page visit, so a user can compare step sizes across Runs without a second chain on screen.

For the Drug trial with 14 successes in 20 patients and a flat prior, the target is the binomial likelihood without its constant, p^14 (1 − p)^6, whose exact normalized form is Beta(15, 7) with mean 15/22 ≈ 0.682. The app shows the sampler recovering that answer, and shows how badly tuned step sizes fail to.

## User Stories

### Choosing what to sample

1. As a classmate, I want to pick a preset from a dropdown, so that I can see the sampler on targets with different shapes without writing any code.
2. As a classmate, I want the Drug trial preset to let me enter the number of successes k and the number of patients n, so that I can see the sampler estimate a response rate for data I choose.
3. As a classmate, I want the Drug trial to start with k = 14 and n = 20, so that the first thing I see is a concrete, checkable example with known answer 15/22.
4. As a classmate, I want the app to refuse k and n values that make no sense (non-integers, n < 1, k < 0 or k > n), with a clear message, so that I never see a chain built on impossible data.
5. As a classmate, I want a Standard normal preset, so that I can see the sampler on the simplest well-behaved target.
6. As a classmate, I want a Bimodal distribution preset (a 30/70 mixture of Normal(−3, 1) and Normal(3, 1)), so that I can see a small step size get stuck in one mode and produce a wrong estimate.
7. As a classmate, I want the k and n inputs to appear only when the Drug trial is selected, so that the controls stay uncluttered for the other presets.

### Choosing how to sample

8. As a classmate, I want to set the step size on a slider from 0.01 to 5 on a log scale, so that small values like 0.01 and 0.05 are as easy to pick as large values like 1 and 5.
9. As a classmate, I want the slider to show the actual step size ("s = 0.050") rather than its logarithm, so that I always know the value being used.
10. As a classmate, I want to set the starting point, so that I can see what happens when a chain starts far from the bulk of the target.
11. As a classmate, I want the starting point to reset to the preset's default (Drug trial 0.5, Standard normal 0, Bimodal −3) when I change preset, so that I never carry a meaningless starting point from one preset into another.
12. As a classmate, I want the app to refuse to Run from a starting point where the target is zero (for the Drug trial, anything outside (0, 1)), with the message "Starting point must be between 0 and 1", so that the sampler never starts in an undefined state.
13. As a classmate, I want to set the number of iterations, up to 20,000, so that I can choose between a short Run that shows every step and a long Run that shows convergence.
14. As a classmate, I want to type a seed, so that I can repeat exactly the same Run later or share it with someone else.
15. As a classmate, I want changing any setting other than burn-in to wait until I press Run, so that I control when a new chain is computed and can line up several changes first.
16. As a classmate, I want the app to open with sensible defaults (Drug trial, k = 14, n = 20, step size 0.1, starting point 0.5, 5,000 iterations, burn-in 500, seed 42), so that pressing Run immediately gives a meaningful result.

### Running and playing back

17. As a classmate, I want pressing Run to compute the whole chain at once, so that playback is smooth and I can move backwards as well as forwards.
18. As a classmate, I want playback to start paused at iteration 1 after each Run, so that I see the very first proposal before anything moves.
19. As a classmate, I want one slider with a built-in play/pause button to control playback, so that I can play, pause, or drag to any iteration, including the end, with a single control.
20. As a classmate, I want a Run of 150 iterations or fewer to play back one iteration per frame, so that I can follow every proposal and every accept/reject decision.
21. As a classmate, I want any Run to take roughly the same time (about 30 seconds) to play back in full, so that a 20,000-iteration Run does not take an hour to watch.
22. As a classmate, I want the panel showing the viewed iteration's number, so that I always know where in the Run I am.
23. As a classmate, I want the walk panel to keep showing the recent history of proposals even when playback skips iterations, so that long Runs still show how the sampler is behaving.

### The walk panel

24. As a classmate, I want to see the target's true curve, so that I know where the sampler should be spending its time.
25. As a classmate, I want a dot marking the current position, so that I can see where the chain is now.
26. As a classmate, I want the last 50 proposals drawn as dots in green when accepted and red when rejected, fading with age, so that I can see at a glance whether the sampler is taking timid steps, wild steps or good ones.
27. As a classmate, I want the latest proposal drawn larger than the rest of the trail, so that I can tell which decision r and u refer to.
28. As a classmate, I want r and u for the latest proposal printed below the plot, so that I can verify the accept/reject rule myself (accept when u < r).
29. As a classmate, I want proposals outside the plotted range still to be visible, so that large step sizes do not silently hide their rejections.
30. As a classmate, I want an out-of-range Drug trial proposal to show as rejected with r = 0, so that I can see why it was rejected.

### The trace panel

31. As a classmate, I want a trace plot of the chain against iteration up to the viewed iteration, so that I can see mixing, stickiness and drift.
32. As a classmate, I want the burn-in region shaded on the trace, so that I can see which iterations are being discarded.
33. As a classmate, I want the trace to show flat stretches after rejections, so that I can see a chain that rejects a lot standing still.

### The histogram panel

34. As a classmate, I want a histogram of the chain after burn-in up to the viewed iteration, so that I can watch it build up into the shape of the target.
35. As a classmate, I want the true curve always drawn over the histogram, so that I can judge how close the samples are to the target.
36. As a classmate, I want the histogram to say "Collecting after burn-in (iteration N)…" while the viewed iteration is still inside the burn-in, so that an empty panel does not look like a bug.

### The diagnostics panel

37. As a classmate, I want the acceptance rate over every iteration so far, including burn-in, so that I can see how often the sampler moves.
38. As a classmate, I want the ESS of the chain after burn-in, so that I can see how many independent draws the chain is really worth.
39. As a classmate, I want the estimate (the mean after burn-in) shown next to the true mean, for example "Estimated mean: 0.671 | True mean: 0.682 (15/22)", so that I can see whether the sampler got the right answer.
40. As a classmate, I want an autocorrelation plot for lags 0 to 50 of the chain after burn-in, so that I can see why a small step size gives a low ESS.
41. As a classmate, I want ESS, the estimate and the autocorrelation plot to show "—" when fewer than about 20 iterations are kept after burn-in, so that I am not shown numbers that mean nothing.
42. As a classmate, I want the message "Chain never moved: every proposal rejected" when that happens, so that a degenerate chain is explained rather than producing errors.

### Burn-in

43. As a classmate, I want to set the burn-in, defaulting to 10% of the iterations, so that I can decide how much of the start to discard.
44. As a classmate, I want changing the burn-in to update the panels immediately without a new Run, so that I can see the effect of discarding more or less of the same chain.
45. As a classmate, I want the burn-in to reset to 10% of the iterations when I change the number of iterations, so that it never exceeds the chain length.
46. As a classmate, I want burn-in iterations excluded from the histogram, estimate, ESS and autocorrelation but included in the acceptance rate, so that the summaries describe the settled chain while the acceptance rate describes the sampler's behaviour.

### Run log

47. As a classmate, I want each Run added as a row to a Run log (Run number, preset with k and n where relevant, step size, starting point, iterations, burn-in, seed, acceptance rate, ESS, estimate), so that I can compare step sizes across Runs.
48. As a classmate, I want to click a Run log row to reload that Run's settings, so that I can return to an interesting Run and replay it exactly.
49. As a classmate, I want the Run log to reset when I reload the page, so that each visit starts clean.
50. As a grader, I want each Run log row to contain the seed, so that every result in the log can be reproduced.

### Reproducibility and correctness

51. As a grader, I want the same settings and seed to give an identical Run, so that results in the write-up and video can be reproduced in the app.
52. As a grader, I want a Run with seed 42 in the deployed app to match the same Run in native R, so that I can trust that the browser build computes the same thing as the tested code.
53. As a grader, I want an automated test suite that checks the targets, the accept/reject rule, reproducibility, convergence and ESS, so that correctness is demonstrated rather than claimed.
54. As a grader, I want the test suite to run on every push with a visible passing badge, so that I can see the code is tested without running anything myself.
55. As a grader, I want the ESS checked against simulated chains with a known answer and against `coda::effectiveSize()`, so that I know the diagnostic is accurate.
56. As a grader, I want a test showing the Bimodal preset with a small step size getting stuck, so that the app's central claim is itself tested.

### Access and performance

57. As a classmate, I want to open the app from a link with nothing to install, so that I can try it in seconds.
58. As a classmate, I want a loading message while webR and the R packages download, so that the first visit does not look broken.
59. As a classmate, I want playback to run at around 5 frames per second, so that it looks like an animation rather than a slideshow.
60. As a classmate on a narrow screen, I want the panels to stack in a single column, so that the app is still usable on a small laptop or a tablet.

### After the checkpoint (stretch goals)

61. As a classmate, I want to compare two chains with different step sizes side by side, or three fixed chains (too small, about right, too large), so that I can see the tuning trade-off without relying on memory.
62. As a classmate, I want a plot of ESS against step size built from the Run log, so that I can see the classic "too small, too large" curve emerge.
63. As a classmate, I want a separation slider for the Bimodal preset, so that I can find the distance at which a given step size stops crossing between modes.

## Implementation Decisions

### Platform and stack

- The app is R Shiny, exported with Shinylive so it runs in the browser on webR, and published to GitHub Pages. There is no server.
- The app depends only on `shiny` and `bslib`. `testthat` and `coda` are used by the tests only and must never be loaded by the app.
- **All plots use base R graphics, not ggplot2** (see ADR 0002). Measured in native R 4.5.2 on a 5,000-iteration Run, base graphics drew the four panels in about 10 ms per frame and ggplot2 in about 267 ms; ggplot2 would also add 13.7 MB of packages to the first page load.
- The layout uses `bslib`: a sidebar of controls, a two-by-two grid of panels (walk, trace, histogram, diagnostics), the playback slider below the grid, and the Run log below that. Panels stack to one column on narrow screens.
- On-screen text is minimal: panel titles, axis labels, and the r and u readout. No teaching captions. The audience is classmates and the grader.
- The built site is never committed. A GitHub Actions workflow runs `shinylive` export and deploys to Pages on every push to `main`. A second workflow runs the test suite on every push.

### Module structure

The sampler and the statistics are plain R functions with no Shiny code. Shiny auto-sources them from the app's R folder, and the tests load the same files, so the browser and the tests run identical code. The app's UI and server do nothing but collect inputs, call these functions and draw.

- **Targets**: for each preset, the log target (up to a constant), the true curve (exact normalized density), the true mean, the default starting point, the plotting range, and the support check. Drug trial: log f(p) = k log p + (n − k) log(1 − p) on (0, 1), true curve Beta(k + 1, n − k + 1), true mean (k + 1)/(n + 2). Standard normal: log f(x) = −x²/2, true curve N(0, 1), true mean 0. Bimodal: log of 0.3 φ(x + 3) + 0.7 φ(x − 3), computed stably, true mean 0.3 × (−3) + 0.7 × 3 = 1.2.
- **Sampler**: one function, `run_chain(preset, k, n, step_size, start, iterations, seed)`, returning a Run.
- **Diagnostics**: one function, `summarise_chain(chain, burn_in, upto)`, returning the diagnostics.
- **Plots**: one base-graphics function per panel, each taking the Run (or its summary) and the viewed iteration.

### The Run (output of `run_chain`)

A data frame with one row per iteration i = 1..iterations, with columns:

- `iteration`
- `current`: the current position *before* the step
- `proposal`: x' = current + Normal(0, step_size)
- `log_r`: log f(x') − log f(x); −Inf when the proposal is outside the target's support
- `log_u`: log of the uniform draw
- `accepted`: logical, `log_u < log_r`
- `position`: the chain value recorded at iteration i, which is `proposal` if accepted and `current` otherwise

The chain is the `position` column. Settings (preset, k, n, step size, start, iterations, seed) are stored as attributes so the Run log and plots can read them.

### Sampler rules

- `run_chain` calls `set.seed(seed)` once at the start, then for each iteration draws exactly one Normal(0, step_size) and one Uniform(0, 1), in that order, so that same seed means same Run, in native R and in webR (both use the default Mersenne-Twister generator).
- All comparisons are on the log scale to avoid underflow: accept when log u < log f(x') − log f(x).
- A proposal outside the support (Drug trial: p ≤ 0 or p ≥ 1) has log f = −Inf and is always rejected. The comparison must never produce `NaN`: the starting point is validated to have log f > −Inf, so log f(x) is always finite.
- On rejection the current position is recorded again.
- Input validation happens before `run_chain` is called. The Run button is disabled with a message when: k or n is not an integer, n < 1, k < 0, k > n, the starting point is outside the support, iterations is outside 10 to 20,000, or burn-in is outside 0 to iterations − 1.

### Diagnostics (output of `summarise_chain`)

`summarise_chain(chain, burn_in, upto)` takes a plain numeric vector (not a Run), so it can be tested on any chain. It considers iterations 1..upto and returns:

- `acceptance_rate`: the fraction of iterations 2..upto whose position differs from the previous one, counted over all iterations including burn-in. Proposals are continuous, so a position changes exactly when its proposal was accepted. This definition works on any plain chain. It differs from the mean of a Run's `accepted` column only in leaving out iteration 1.
- `kept`: the number of iterations after burn-in up to `upto` (max(0, upto − burn_in)).
- `estimate`: the mean of the kept iterations.
- `acf`: autocorrelations of the kept iterations for lags 0 to 50.
- `ess`: kept ÷ (1 + 2 Σ ρ_k), where the sum uses Geyer's initial positive sequence: sum consecutive pairs ρ_{2m} + ρ_{2m+1}, stopping at the first pair that is not positive. Autocorrelations for this sum are computed to as many lags as the rule needs, not just 50. Base R only.
- When `kept` < 20, `estimate`, `ess` and `acf` are `NA` and the UI shows "—".
- When the kept iterations have zero variance (the chain never moved), `ess` and `acf` are `NA` and the UI shows "Chain never moved: every proposal rejected".

The app calls `summarise_chain` on every playback frame with `upto` = the viewed iteration, so it must stay fast: a few milliseconds in native R for a 20,000-iteration chain.

### Playback

- Pressing Run computes the whole Run (ADR 0001). The cost is negligible: in native R, 20,000 iterations take about 20 to 40 ms.
- Playback is a single `sliderInput` with `animate = TRUE`, ranging over 1..iterations. Its step is `max(1, ceiling(iterations / 150))`, and the animation interval is about 200 ms, so a full Run plays in about 30 seconds and Runs of 150 iterations or fewer advance one iteration per frame.
- After each Run, the slider resets to iteration 1, paused.
- Changing any setting other than burn-in does nothing until Run is pressed. Changing burn-in re-renders the trace shading, the histogram and the diagnostics for the current Run immediately.

### Panels

- **Walk**: the true curve over the preset's fixed plotting range (Drug trial [0, 1], Standard normal [−4, 4], Bimodal [−6.5, 6.5]). The current position at the viewed iteration is a dot on the curve. The trail is the proposals from iterations max(1, v − 49)..v, coloured green (accepted) or red (rejected), with transparency increasing with age; the proposal at v is drawn larger. Proposals outside the plotting range are drawn as markers clamped to the edge of the range. Below the plot: r and u for the proposal at v, printed as r = exp(log_r), with "r = 0 (outside support)" for out-of-range proposals.
- **Trace**: position against iteration for 1..v, with the region 1..burn-in shaded. The x-axis spans the whole Run so the plot does not rescale during playback.
- **Histogram**: positions from iterations burn-in + 1..v, drawn on the density scale with the true curve overlaid. The x-axis is the preset's plotting range. When v ≤ burn-in, the panel shows "Collecting after burn-in (iteration burn-in + 1)…".
- **Diagnostics**: acceptance rate, ESS, "Estimated mean: … | True mean: …", and an autocorrelation bar plot for lags 0 to 50 with the y-axis fixed at [−0.2, 1], so the bars don't rescale during playback.

### Controls

- The step-size slider is a `sliderInput` over log₁₀(s) from −2 to log₁₀(5) ≈ 0.699, with its own value label hidden. The text "s = …" (three significant figures) is printed under it, and the server uses 10^value.
- The k and n inputs are shown only for the Drug trial.
- Changing the preset resets the starting point to that preset's default. It does not change the step size, iterations or seed.
- Changing iterations resets the burn-in to 10% of iterations, rounded.
- Defaults: Drug trial, k = 14, n = 20, step size 0.1, starting point 0.5, 5,000 iterations, burn-in 500, seed 42.

### Run log

- A reactive table held only in the session. It resets on page reload.
- One row is appended per Run, computed when the Run is made from the full chain with the burn-in in effect at that moment: Run number, preset (with "k/n" for the Drug trial), step size, starting point, iterations, burn-in, seed, acceptance rate, ESS, estimate.
- Clicking a row restores that row's settings into the controls. The user then presses Run to reproduce it exactly.

### Design for the stretch goals

Nothing in the MVP may assume there is only one chain beyond the UI itself. `run_chain` and `summarise_chain` are already independent of Shiny, so comparing chains means calling them more than once and drawing more panels.

## Testing Decisions

### What makes a good test here

Tests check external behaviour through the two seams, `run_chain()` and `summarise_chain()`. They do not reach into helper functions, so the internals can be refactored freely. Each test should state a fact about Metropolis-Hastings or about the app's contract that a grader would recognise, for example "an out-of-range proposal is always rejected". Statistical tests use fixed seeds and tolerances wide enough never to flake.

### Seams

- **`run_chain(preset, k, n, step_size, start, iterations, seed)`**: test layers 1 to 4.
- **`summarise_chain(chain, burn_in, upto)`**: test layer 5, plus the edge cases.
- The plots and the Shiny UI have no automated tests. They are covered by the manual deployment checklist.

### The five layers (testthat, native R)

1. **Targets are right up to a constant.** For each preset, on a Run of a few hundred iterations, every row's `log_r` equals log of the exact density at `proposal` minus log of the exact density at `current` (`dbeta(·, k + 1, n − k + 1)`, `dnorm`, the 30/70 mixture), within numerical tolerance, wherever the proposal is inside the support.
2. **Accept/reject follows the rule.** In every row, `accepted == (log_u < log_r)`. Whenever `log_r ≥ 0`, the proposal is accepted. Out-of-range Drug trial proposals have `log_r == -Inf`, are rejected, and no column ever contains `NaN`. In every rejected row, `position == current`. In every accepted row, `position == proposal`. Each row's `current` equals the previous row's `position`.
3. **Runs are reproducible.** The same arguments give identical Runs. Changing only the seed gives a different Run.
4. **The sampler converges, and fails when it should.** For each preset at a well-tuned step size, a 20,000-iteration Run with a fixed seed and 10% burn-in has an estimate within a preset-specific tolerance of the true mean. For the Drug trial with k = 14 and n = 20, the true mean is 15/22. The tolerances are about 4 times the spread measured during planning (native R, 30 seeds each):

   | Preset | Step size | Measured sd of the estimate | Max error seen | Tolerance |
   |---|---|---|---|---|
   | Drug trial | 0.25 | 0.002 | 0.004 | 0.01 |
   | Standard normal | 2.4 | 0.014 | 0.028 | 0.06 |
   | Bimodal | 4 | 0.060 | 0.141 | 0.25 |

   Quartiles must also be within tolerance of the true quartiles. Calibrate those tolerances the same way (4 times the sd over 30 seeds) when writing the test, and record the calibration in a comment. Opposite test: Bimodal with step size 0.05, started at −3, must have an estimate below 0, far from the true +1.2. During planning it gave −3.21.
5. **ESS is accurate.** On simulated AR(1) chains (φ ∈ {0, 0.5, 0.9}, n = 20,000, fixed seeds), whose true ESS is n(1 − φ)/(1 + φ), `summarise_chain` gives an ESS within 15% of the truth and within 15% of `coda::effectiveSize()`.

### Edge cases

- `kept` < 20 gives `NA` for the estimate, ESS and acf.
- A constant chain gives `NA` for ESS and acf, with no warnings or errors.
- `upto` ≤ `burn_in` gives `kept == 0`.
- The acceptance rate from position changes equals the mean of the Run's `accepted` column over iterations 2..upto.

### Continuous integration

A GitHub Actions workflow installs R, `testthat` and `coda` and runs the suite on every push. The README shows the workflow's status badge.

### Manual deployment checklist (after each deployment)

1. The GitHub Pages URL loads in a fresh private window and the loading message appears.
2. A default Run (seed 42) shows the same first five positions and the same final estimate as `run_chain` with the same arguments in native R.
3. All four panels and the Run log render, playback runs, and pausing and dragging the slider both work.
4. Each preset Runs, and an invalid Drug trial input disables Run with its message.

### Prior art

The repository has no code yet, so there is no prior art in it. The course homework (for example the `oracle.R` / `tests` layout in hw-02) uses a similar pattern: plain functions checked by a test folder.

## Out of Scope

- **Comparing chains on screen** (two side by side, or three fixed), a plot of ESS against step size, and a separation slider for the Bimodal preset. These are stretch goals for after the Nov 23 checkpoint and must not be built before then.
- **Custom targets typed in by the user.** Parsing arbitrary R expressions is a safety and validation problem, and every preset has a known true curve.
- **Teaching captions** or other explanatory text for first-time MCMC learners.
- **A separate speed control, step buttons or a "jump to end" button.** The single animated slider replaces them.
- **Other proposal distributions** (non-Normal, adaptive, independence samplers), **multivariate targets**, and **other MCMC methods** (Gibbs, HMC).
- **Multiple chains and R-hat**, and **automatic burn-in detection**.
- **Saving the Run log** between page visits, or exporting it.
- **ggplot2**, `shinyWidgets`, `coda` in the app, or any other package beyond `shiny` and `bslib` in the browser.
- **Automated browser tests** (shinytest2).

## Milestones

| By (ET) | Milestone |
|---|---|
| Mon Oct 26, 11:59 PM | Proposal: this SPEC.md plus the Google Doc. |
| Sun Nov 1 | Targets and `run_chain` implemented, with test layers 1 to 4 passing in native R and in CI. |
| Sun Nov 8 | First Shinylive deployment to GitHub Pages tested end to end, even if the app is a placeholder. `summarise_chain` and test layer 5 passing. |
| Sun Nov 15 | All four panels, playback with the trail, burn-in, the estimate and the Run log working locally. |
| Mon Nov 23, 11:59 PM | Checkpoint: the full MVP deployed and passing the manual checklist, plus the brief report. |
| Nov 24 – Dec 10 | Stretch goals, in order: comparing chains, the ESS-against-step-size plot, the Bimodal separation slider. |
| Dec 10 – 16 | Freeze features. Tidy the repository and README, and record the video. |
| Thu Dec 17, 3:30 PM | Final submission: repository plus video. |

## Risks

| Risk | Mitigation |
|---|---|
| The first Shinylive/webR deployment fails or behaves differently from native R. | Deploy a placeholder in week 2 (by Nov 8), not at the end. Check deployments with the manual checklist, including the seed-42 comparison with native R. |
| Playback draws more slowly in webR than estimated. | Base graphics only (ADR 0002). Keep per-frame work to `summarise_chain` plus four base plots. If it's still too slow, lengthen the animation interval or reduce the trail before cutting features. |
| webR's first page load is slow. | Only `shiny` and `bslib` in the browser. Show a loading message. Mention the expected wait in the README. |
| The webR random number stream differs from native R for the same seed. | `run_chain` draws a fixed sequence (one Normal, then one Uniform, per iteration) after a single `set.seed`. The manual checklist compares seed 42 directly. If they differ, document it; reproducibility within the app still holds. |
| The ESS method disagrees with `coda` on some chains. | Test layer 5 bounds the disagreement at 15% on chains with known ESS. Investigate any failure before shipping. |
| The scope grows past the checkpoint. | Comparing chains and the other stretch goals are explicitly after Nov 23. The single-chain MVP is complete without them. |

## Further Notes

- The method follows https://en.wikipedia.org/wiki/Metropolis%E2%80%93Hastings_algorithm. The Normal random-walk proposal is symmetric, so the Hastings correction cancels and r = f(x')/f(x).
- For the Drug trial with k = 14 and n = 20, r = (p'/p)^14 · ((1 − p')/(1 − p))^6, implemented as `log_r` = 14 (log p' − log p) + 6 (log(1 − p') − log(1 − p)).
- On the Bimodal preset, the density midway between the modes is about 1.6% of the peak, so step sizes below about 1 rarely cross between modes, while step sizes of about 3 to 5 cross easily. The 0.01 to 5 slider covers both behaviours.
- Native R timings measured during planning (R 4.5.2): 10,000 iterations ≈ 10 to 20 ms per preset; `acf` on 10,000 values ≈ 2 ms. webR is slower by an unmeasured factor.

## Architectural Decision Records

### ADR 0001: Compute the whole chain up front, then play it back

The app is described as showing the sampler "in real time", but pressing Run computes the entire chain at once and the panels then play back through it with a play/pause control and an iteration slider. Computing one iteration per animation tick was rejected because each redraw in webR (via Shinylive) is slow enough that a few thousand iterations would take minutes to watch, and it would not allow rewinding to a particular step.

### ADR 0002: Base R graphics, not ggplot2

All four panels are drawn with base R graphics because playback redraws them on every frame inside webR. Measured in native R 4.5.2 on a 5,000-iteration Run, base graphics drew the four panels in about 10 ms per frame and ggplot2 4.0.3 in about 267 ms (≈28× slower); webR is slower still for both, so ggplot2 would cut playback to roughly one frame per second. ggplot2 would also add 10 packages (13.7 MB) to the first page load on top of what Shiny already downloads. Do not switch to ggplot2 without re-measuring playback in the deployed app.

## Glossary

### Sampler

**Target**:
The distribution the sampler is trying to draw from, known only up to a constant.
_Avoid_: Posterior (except for the Drug trial), density, f

**Current position**:
The value the chain is at before a step, written x.
_Avoid_: State, current sample

**Starting point**:
The current position before the first iteration; each preset has its own default, and it must be a value where the target is positive.
_Avoid_: Initial value, x0, seed

**Proposal**:
The candidate value x' = x + a Normal(0, s) step, offered for acceptance or rejection.
_Avoid_: Candidate, jump

**Step size**:
The standard deviation s of the proposal's Normal step; the tuning knob the app is about.
_Avoid_: Proposal width, sigma, scale

**Acceptance ratio**:
r = f(x') / f(x), the target at the proposal divided by the target at the current position.
_Avoid_: Acceptance probability, Hastings ratio

**Uniform draw**:
The value u drawn from Uniform(0, 1) and compared to the acceptance ratio; the proposal is accepted when u < r.
_Avoid_: Random number, threshold

**Chain**:
The full ordered record of positions, one per iteration, with the current position recorded again after each rejection.
_Avoid_: Samples, trace, run

### Playback

**Run**:
One complete chain computed in a single go from the chosen settings and seed, together with every proposal, acceptance ratio, uniform draw and accept/reject outcome; pressing Run produces a new one.
_Avoid_: Simulation, session

**Viewed iteration**:
The iteration the panels are currently showing during playback of a Run.
_Avoid_: Current step, frame, playhead

**Trail**:
The last 50 proposals up to the viewed iteration, drawn on the walk panel in green (accepted) or red (rejected) and fading with age.
_Avoid_: History, recent proposals, path

**Run log**:
The table of past Runs in this page visit, one row per Run with its settings, burn-in, seed, acceptance rate, ESS and estimate.
_Avoid_: History, results table

**True curve**:
The exact, normalized density of the target, drawn on the walk panel and over the histogram from the first sample so the histogram can be compared with it.
_Avoid_: Truth, reference density, exact answer

### Diagnostics

**Burn-in**:
The user-chosen number of early iterations discarded before the chain is used for the histogram, estimate, ESS and autocorrelation; the acceptance rate still counts them.
_Avoid_: Warm-up, transient

**Estimate**:
The mean of the chain after burn-in, up to the viewed iteration, shown next to the true mean of the target.
_Avoid_: Result, answer, posterior mean (except for the Drug trial)

**ESS**:
The effective sample size: how many independent draws the kept part of the chain is worth, computed from the same autocorrelations the autocorrelation plot shows.
_Avoid_: Effective N, n_eff

**Acceptance rate**:
The fraction of proposals accepted so far in a chain; distinct from the acceptance ratio, which belongs to a single proposal.
_Avoid_: Acceptance ratio, acceptance probability

### Presets

**Preset**:
One of the named targets the user picks from: Drug trial, Standard normal, Bimodal distribution.
_Avoid_: Example, scenario, model

**Drug trial**:
The preset that estimates a response rate p from k successes in n patients under a flat prior; its exact answer is Beta(k + 1, n − k + 1).
_Avoid_: Binomial preset, Beta example

**Bimodal distribution**:
The preset whose target is a 30/70 mixture of Normal(−3, 1) and Normal(3, 1); it shows a small step size getting stuck in one mode.
_Avoid_: Mixture preset, two-humped target
