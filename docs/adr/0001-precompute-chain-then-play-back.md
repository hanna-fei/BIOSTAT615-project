# Compute the whole chain up front, then play it back

The app is described as showing the sampler "in real time", but pressing Run computes the entire chain at once and the panels then play back through it with a play/pause control and an iteration slider. Computing one iteration per animation tick was rejected because each redraw in webR (via Shinylive) is slow enough that a few thousand iterations would take minutes to watch, and it would not allow rewinding to a particular step.
