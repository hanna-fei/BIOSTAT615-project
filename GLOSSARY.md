# Metropolis-Hastings Explorer

An interactive teaching app that runs a Metropolis-Hastings sampler step by step, to show why tuning the step size matters.

## Sampler

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

## Playback

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

## Diagnostics

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

## Presets

**Preset**:
One of the named targets the user picks from: Drug trial, Standard normal, Bimodal distribution.
_Avoid_: Example, scenario, model

**Drug trial**:
The preset that estimates a response rate p from k successes in n patients under a flat prior; its exact answer is Beta(k + 1, n − k + 1).
_Avoid_: Binomial preset, Beta example

**Bimodal distribution**:
The preset whose target is a 30/70 mixture of Normal(−3, 1) and Normal(3, 1); it shows a small step size getting stuck in one mode.
_Avoid_: Mixture preset, two-humped target
