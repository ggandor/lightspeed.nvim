# Suggestions for colorscheme integrations

Dear fellow plugin authors, while letting your creativity fly, keep the
following in mind: Lightspeed's highlighting scheme is pretty complex, and it is
important to guarantee at least some level of consistency across themes, in
order to not confuse users that switch between multiple ones regularly.

Therefore you should aim to keep the basic arrangement intact, that is, the
attribute lists (bold, underline, etc.) and all the invariants between groups
(like "shortcuts = inside-out labels"), even if you do not necessarily agree
with the defaults.

* Choose **two base colors**: a warmer one (for the primary target group) and a
  colder one (for the secondary - distant - target group). Neither should melt
  too much into the background - this is a motion plugin, and usability takes
  priority over aesthetics.

* The highlight groups of overlapped beacons use slightly darker (dark themes)
  or lighter (light themes) versions of the base colors. This is the only
  difference among them and the non-overlapped versions.

* Regular labels have _no_ background; shortcut-labels _do_ have a background,
  which is the same as the foreground color for the corresponding regular label
  type.

* All labels, including shortcuts, have an `underline` attribute.

* `LightspeedMaskedChar` has no background, and has an empty attribute list; it
  can be of any color, but should be unobtrusive - being dimmer and also less
  saturated than the labels, otherwise the UI becomes too chaotic. 

* `LightspeedUnlabeledMatch` uses black or dark grey (light themes), or white or
  light grey (dark themes), with no or minimal saturation - this is what
  distinguishes them from the labeled beacons, and make them instantly
  recognizable.

* Even if a colorscheme does not aim to make any further modifications, it is
  suggested to link `LightspeedGreyWash` to `Comment`, provided that the latter
  is some kind of neutral grey, without an own background color.

