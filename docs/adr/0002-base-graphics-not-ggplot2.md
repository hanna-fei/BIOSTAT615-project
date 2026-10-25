# Base R graphics, not ggplot2

All four panels are drawn with base R graphics because playback redraws them on every frame inside webR. Measured in native R 4.5.2 on a 5,000-iteration Run, base graphics drew the four panels in about 10 ms per frame and ggplot2 4.0.3 in about 267 ms (≈28× slower); webR is slower still for both, so ggplot2 would cut playback to roughly one frame per second. ggplot2 would also add 10 packages (13.7 MB) to the first page load on top of what Shiny already downloads. Do not switch to ggplot2 without re-measuring playback in the deployed app.
