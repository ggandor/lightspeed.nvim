# Announcement

For a more lightweight, easier-to-use alternative, check out the author's new,
work-in-progress plugin, [Leap](https://github.com/ggandor/leap.nvim). It is a
streamlined, refined successor of Lightspeed, incorporating all the lessons
learned from the predecessor, achieving much better balance between speed,
simplicity (of both interface and implementation) and intuitiveness.

# 🌌 lightspeed.nvim

Lightspeed is a motion plugin for [Neovim](https://neovim.io/), with a
relatively small interface and lots of innovative ideas, that allow for making
on-screen movements with yet unprecedented ease and efficiency. The aim is to
maximize speed while minimizing mental effort and breaks in the flow, providing
a distractionless experience, that should feel as "native" as possible.

![welcome](../media/welcome.gif?raw=true)

## The gist in 30 secs

With Lightspeed you can jump to any positions in the visible window area by
entering a 2-character search pattern, and then optionally a "label" character
for choosing among multiple matches. The plugin aims to substitute _all_ native
commands for in-window navigation (`/`, `?`, `gg`, `f`, etc.) with a uniform,
minimal set of atomic (repeatable), multi-axis motions.

So far we have more or less described what
[vim-sneak](https://github.com/justinmk/vim-sneak) does. The game-changing idea
in Lightspeed is its "clairvoyant" ability: it maps possible futures, and shows
you which keys you will need to press _before_ you actually need to do that, so
despite the use of target labels, you can keep typing in a continuous manner.
You can almost always reach the destination by at most - and very often less
than - four keystrokes in total, that can be typed in one go.

## Video tutorial

If this sounds cool enough, read on, or watch the [6-minute introductory video
by DevOnDuty](https://youtu.be/ESyld9NCl1w) - a very good entry point, showing
the basic usage with straightforward, easy to understand explanations.

## Sky chart

* [Evolution and design](#-evolution-and-design)
* [An in-depth introduction of the key features](#-an-in-depth-introduction-of-the-key-features)
* [Getting started](#-getting-started)
* [Usage](#-usage)
* [Configuration](#-configuration)
* [Why is there no feature X or Y?](#-why-is-there-no-feature-x-or-y)
* [Contributing](#-contributing)
* [Inspired by](#-inspired-by)

### Quick links (FAQ)

* [EasyMotion/Hop-style config](#easymotionhop-style-config)
* [Suggestions for colorscheme integrations](COLORSCHEMES.md)
* [Enforce the default highlighting if a colorscheme messes things
  up](#highlight-groups)
* [Multi-line f/t motions VS macros and :normal](#notes)
* [Using the plugin together with
  vim-surround](https://github.com/ggandor/lightspeed.nvim/discussions/83)

## 🧬 Evolution and design

### Composite motions do not compose

Everyone has been taught that the "Vim way" of reaching distant points in the
window is using combinations of primitive motions: `8jfx;;`. The pipelining
instinct is so deeply ingrained in our Vim-infected mindsets, that many of us
tend to forget that this approach has evolved merely as a consequence of the
limitations of the interface, and is not some divinely decreed, superior way of
doing things; while the ["controls as
language"](https://mkremins.github.io/blog/controls-as-language/) paradigm is an
ingenious aspect of Vim in general, "compound sentences" make no sense for doing
arbitrary jumps between A and B, that should ideally be _atomic_.

### Railways versus jetpacks

[EasyMotion](https://github.com/easymotion/vim-easymotion) attempted to improve
the situation by introducing many new "atoms" - direct routes to a lot of
specific targets. That plugin and its derivatives
([Hop](https://github.com/phaazon/hop.nvim), or
[Avy](https://github.com/abo-abo/avy) for Emacs) are a bit like convoluted
railway networks, with pre-built stations: each time you have to think about
which train to take, which exit point is the closest to your goal, etc. In
short, they buy speed for cognitive load - a questionable bargain.

Sneak's approach, however, with its sole focus on using 2-character search
patterns for targeting, and later combining that with the labeling method
inspired by EasyMotion, felt close to perfect at its time. A user of Sneak
embraces a philosophy that is just the opposite of above: you barely need to
think about motions anymore - "sneaking" gets you everywhere you need to be,
with maximal precision. It is like having a _jetpack_ on you all the time.

### Always a step ahead of you

Lightspeed takes the next logical step, and eliminates yet more cognitive
overhead, unnecessary keystrokes or interruptions, by blurring the boundary
between one- and two-character search. The idea is to process the input
incrementally - analyzing the available information after _each_ keystroke, to
assist the user and offer shortcuts:

* **jump based on partial input:** if the character is unique in the search
  direction, you will automatically jump after the first input (these characters
  are highlighted beforehand, so this is never too surprising)
* **shortcut-labels:** for some matches, it is possible to use the target
  label right after the first input, as if doing 1-character search
* **ahead-of-time displayed target labels:** in any case, you will _see_ the
  label right after the first input, so once you need to type it, your brain
  will already have processed it

The last one is probably the biggest game-changer, beating the major problem of
all other general-purpose motion plugins - the frustrating momentary pause
between entering your search pattern and selecting the target. Once you try it,
you will never look back.

To see these features in action, check the [screen
recordings](#-an-in-depth-introduction-of-the-key-features) in the in-depth
introduction below.

### Universal motions

To make the suite complete, Lightspeed implements [enhanced f/t-like motions
working over multiple lines](#1-character-search-ft), with same-key repeat
available, and a so-called [x-mode](#operator-pending-mode), providing
exclusive/inclusive variations for 2-character search. Together the four
bi-directional motions (`s`/`x`/`f`/`t`) make it possible to reach and operate
on the whole window area with high efficiency in all situations when there is no
obvious atomic alternative - like `w`, `{`, or `%` - available.

### Other improvements and quality-of-life features

* **smart shifting between Sneak/EasyMotion mode** - the plugin automatically
  jumps to the first match if the remaining matches can be covered by a limited
  set of "safe" target labels, but stays in place, and switches to an extended,
  more comfortable label set otherwise
* **linewise operations** are possible via the same interface, by targeting
  (potentially off-screen) EOL characters
* **uniform repeat interface**, and flawless dot-repeat support for operators
  (with [repeat.vim](https://github.com/tpope/vim-repeat) installed)
* **bidirectional** search (opt-in)
* **cross-window** motions

### High-level guiding principles

_"Some people . . . like tons of features, but experienced users really care
about cohesion, conceptual integrity, and reliability. I think of [the latter]
as the @tpope school."_
([justinmk](https://github.com/justinmk/vim-sneak/issues/62#issuecomment-34044380))

* [80/20](https://youtu.be/Bt-vmPC_-Ho?t=1249): focus on features that are
  applicable in all contexts - micro-improvements to the most frequent tasks
  accumulate more savings than vanity features that turn out to be rarely needed
  in practice

* [Design is making
  decisions](https://www.infoq.com/presentations/Design-Composition-Performance/):
  mitigate choice paralysis for the user, regarding both usage (the kinds of
  targeting methods provided) and configuration options

* [Sharpen the saw](http://vimcasts.org/blog/2012/08/on-sharpening-the-saw/):
  the plugin should feel a natural extension to the core, with an interplay as
  seamless and intuitive as possible

## 📚 An in-depth introduction of the key features

### Jump on partial input

If you enter a character that is the only match in the search direction,
Lightspeed jumps to it directly, without waiting for a second input. These
unique characters are highlighted beforehand;
[quick-scope](https://github.com/unblevable/quick-scope) is based on a similar
idea, but the intent here is not a "choose me!"-kind of preliminary orientation
(the assumption is that you _know_ where you want to go), more like giving
feedback for your brain _while_ you type.

![jumping to unique characters](../media/intro_img1_jump_to_unique.gif?raw=true)

To further mitigate accidents, a short timeout is set by default, until the
second character in the pair (and only that) is "swallowed". In operator-pending
mode, the operated area gets a temporary highlight until the next character is
entered.

### Ahead-of-time labeling

Target labels are shown ahead of time, _right after typing the first input
character_. This means you can often type without any serious break in the
flow, almost as if using 3-character search. It is a micro-optimisation, but
can mean the world - Lightspeed simply _feels_ different because of this.

![incremental labeling](../media/intro_img2_incremental_labeling.gif?raw=true)

### Shortcuts

Made possible by the above, Lightspeed has the concept of "shortcutable"
positions, where the assigned label itself is enough to determine the target:
those you can reach via typing the label character right after the first
input, bypassing the second one. This case is surprisingly frequent in
practice, and in case of harder-to-type sequences, when you're not rushing
with 200+ CPM, can work really well.

You can see that "shortcuts" are highlighted differently (with a background
color):

![shortcuts](../media/intro_img3_shortcuts.gif?raw=true)

Note that this is just an alternative: you do not _have to_ watch out for
these, and nothing bad happens if you type the second input as normal, and
then type the label to reach the target. But in my experience, you can often
guess whether the targeted position will be shortcutable, e.g. if there is a
character that seems to be consistently followed by the same other character
in the window (simple examples: a comment leader, e.g. `-` in Lua, or an `<`
if there are lots of `<Plug>` forms in a section of a Vim config file).

### Grouping matches by distance

When there is a large number of matches, we cycle through groups instead of
trying to label everything at once (just like Sneak does it). However, the
immediate next group is always shown ahead of time too, with a different color,
so your brain has a bit of time to process the label, even in case of a distant
group. If the target is right in the second group, you don't even have to think
in terms of "switching groups" - a blue label should rather be thought of as a
`<space>`-prefixed, 2-character label. That means we have `2 * number-of-labels`
targets right away that are in the efficiently-reachable/low-cognitive-load
range.

![groups](../media/intro_img4_groups.gif?raw=true)

Note that Lightspeed keeps the invariant that a label consists of _exactly one
character_, that should _always stay in the same position_, once appeared. (No
rolling/flashing sequence of labels, like in case of Hop/EasyMotion.)

## 🚀 Getting started

### Requirements

* Neovim >= 0.7.0

### Dependencies

* [repeat.vim](https://github.com/tpope/vim-repeat) is required for the dot-repeat
functionality to work as intended.

### Installation

#### [packer](https://github.com/wbthomason/packer.nvim)
```Lua
use 'ggandor/lightspeed.nvim'
```

#### [vim-plug](https://github.com/junegunn/vim-plug)
```Vim
Plug 'ggandor/lightspeed.nvim'
```

## 🏹 Usage

"Just relax and let your mind go blank" - Lightspeed thinks for you. It always
presents information before it is actually needed.

### 2-character search (s/x)

Without further ado, let's cut to the chase, and learn by doing.
([Permalink](https://github.com/neovim/neovim/blob/8215c05945054755b2c3cadae198894372dbfe0f/src/nvim/window.c#L1078)
to the file, if you want to follow along.)

The search is invoked with `s` in the forward direction, and `S` in the backward
direction. Let's press `s`:

![quick example 1](../media/quick_example_1.png?raw=true)

You can see that the search area is greyed out, and you can also see some
characters highlighted. Those are characters with only one occurrence, and you
can jump to them by simply typing the given character.

Let's target some word containing `me`. After entering the letter `m`, the
plugin processes all bigrams starting with it, and from here on, you have all
the visual information you need to reach your specific target:

![quick example 2](../media/quick_example_2.png?raw=true)

Now type `e`. If you aimed for the first match (in `frame_minheight`), you are
good to go, just continue the work! (The labels for the subsequent matches of
`me` remain visible until the next keypress, but they are carefully chosen
"safe" letters, guaranteed to not interfere with your following editing
command.) If you aimed for some other match, then type the label, for example
`u`, and move on to that.

![quick example 3](../media/quick_example_3.png?raw=true)

An alternative could have been using a [shortcut](#shortcuts) - skipping the
second pattern character (`e` in our case), and just typing the label, if it has
an inverse highlight. This is only practical if the first pattern character is
hard to type - it is not worth it to deliberately pause and wait for a potential
shortcut, instead of going with the flow. Shortcuts can _always_ be used as
normal labels - skipping is optional.

To show the last important feature, let's zoom out a bit, and target the struct
member on the line `available = oldwin->w_frame->fr_height;` near the bottom,
using the pattern `fr`, by first pressing `s`, and then `f`:

![quick example 4](../media/quick_example_4.png?raw=true)

The blue labels indicate the "secondary" group of matches, where we start to
reuse the available labels for a given pair (`s`, `f`, `n`... again). You can
reach those by prefixing the label with `<space>`, that switches to the
subsequent match group. For example, to jump to the "blue" `j` target, you
should now press `r<space>j`. In very rare cases, if the large number of matches
cannot be covered even by two label groups, you might need to press `<space>`
multiple times, until you see the target labeled, first with blue, and then,
after one more `<space>`, red.

To summarize, here is the general flow again (in Normal and Visual mode, with
the default settings):

`s|S char1 (char2|shortcut)? (<space>|<tab>)* label?`

That is,
- invoke in the forward (`s`) or backward (`S`) direction
- enter the first character of the search pattern (might [short-circuit after
  this](#jump-on-partial-input), if the character is unique in the search
  direction)
    - _the "beacons" are lit at this point; all potential matches are labeled
      (char1 + ?)_
- finish the motion by selecting a [shortcut](#shortcuts), or enter the second
  character of the search pattern (might short-circuit after this, if there is
  only one match)
    - _certain beacons are extinguished; only char1 + char2 matches remain_
    - _the cursor automatically jumps to the first match if there are enough
      "safe" labels; pressing any other key than a group-switch or a target
      label exits the plugin now_
- optionally [cycle through the groups of
  matches](#grouping-matches-by-distance) that can be labeled at once
- choose a labeled target to jump to (in the current group)

#### When matches are too close to each other

If a match is too close to the next one, the beacon should be "squeezed" into
the original 2-column box of the match; that is, on top of an `A` `B` match, a
`B` `label` pair will appear, where the first field shows the character masked
by the label (it is shifted left by a column) - those are the brownish
characters you can see on some of the screenshots. In the most extreme case, the
`B` field can even be overlapped by the label of another match, but only until
the second input has not been entered - after that, all overlapped matches are
guaranteed to become uncovered.

#### Operator-pending mode

In Operator-pending mode, there are two different (pairs of) motions available,
providing the necessary additional comfort and precision, since in that case we
are targeting exact positions, and can only aim once, without the means of easy
correction.

`z`/`Z` are the equivalents of Normal/Visual `s`/`S`, and they follow the
semantics of `/` and `?` in terms of cursor placement and inclusive/exclusive
operational behaviour, including forced motion types (`:h forced-motion`):

```
ab···|                    |···ab
█████·  ←  Zab    zab  →  ████ab
██████  ← vZab    vzab →  █████b
```

The mnemonic for **X-mode** could be **extend/exclude** (corresponding to
`x`/`X`). It provides missing variants for the two directions:

```
ab···|                    |···ab
ab███·  ←  Xab    xab  →  ██████
ab████  ← vXab    vxab →  █████b
```

As you can see from the figure, `x` goes to the end of the match, including it
in the operation, while `X` stops just before - in an absolute sense, after -
the end of the match (the equivalent of `T` for two-character search). In
simpler terms: in X-mode, **the relevant edge of the operated area gets an
offset of +2**.

The assignment of `z` and `x` seems a sensible default, considering that those
keys are free in O-P mode, and the handy visual mnemonic that `x` is physically
to the right of `z` on a QWERTY keyboard (think about "pulling" the cursor
forward). We are also acknowledging that "surround" plugins in Operator-pending
mode may benefit more from being able to use the `s`/`S` keypair than
general-purpose motion plugins like Lightspeed.

#### Cross-window motions

`gs` and `gS` are like `s`/`S`, but they search in the successor/predecessor
windows in the window tree of the current tab page. In practical terms: `gs`
scans downwards/rightwards, while `gS` upwards/leftwards. In exceptional cases,
the direction can be switched on the fly with `tab` after invocation.

#### Bidirectional search

By mapping to the special keys `<Plug>Lightspeed_omni_s` and
`<Plug>Lightspeed_omni_gs`, you can search in the whole window or tab page,
instead of just a given direction. In this case, the matches are sorted by their
screen distance from the cursor, advancing in concentric circles. This is a very
different mental model, but has its own merits too.

### 1-character search (f/t)

Lightspeed also overrides the native `f`/`F`/`t`/`T` motions with enhanced
versions that work over multiple lines. In all other respects they behave the
same way as the native ones.

### Matching line breaks (linewise motions)

The newline character is represented by `<enter>` in search patterns. For
example, `f<enter>` is equivalent to `$`, and will move the cursor to the end of
the line. `s<enter>` will label all EOL positions, including off-screen ones
(labeled as `<{label}` or `{label}>`), providing an easy way to move to blank
lines. Likewise, a character before EOL can be targeted by `s{char}<enter>`
(`\n` in the match is highlighted as `¬` by default).

### Repeating motions

Repeating in Lightspeed works in a uniform way across all motions - all of the
following methods (and even combinations of them) are valid options.

Note that for s/x motions the labels will remain available during the whole
time, even after entering instant-repeat mode, if the "safe" label set is in
use.

#### "Instant" repeat (after jumping)

- In Normal and Visual mode, the motions can be repeated by pressing the
  corresponding trigger key - `s`, `f`, `t` - again. (They continue in the
  original direction, whether it was forward or backward.) `S`, `F` and `T`, on
  the other hand, always _revert_ the previous repeat. Note that in the case of
  `T` (or `X`, if mapped), this results in a different, and presumably more
  useful behaviour than what you are used to in clever-f and Sneak: it does not
  repeat the search in the reverse direction, but puts the cursor back to its
  previous position - _before_ the previous match -, allowing for an easy
  correction when you accidentally overshoot your target.

- For f/t-search, there is a special, opt-in repeat mode: pressing the _target
  character_ again can also repeat the motion
  (`opts.repeat_ft_with_target_char`).

#### "Cold" repeat

- Pressing `<backspace>` after invoking any of Lightspeed's motions searches
  with the previous input (1- and 2-character searches are saved separately).
  Subsequent keystrokes of `<backspace>` move on to the next match (that is, it
  invokes "instant-repeat" mode), while `<tab>` reverts (just like `S`/`F`/`T`).

- There are also dedicated `<Plug>` keys available for repeating the two search
  modes. `;` and `,` are mapped to f/t repeat by default (following the native
  behaviour), but it might be a good idea to remap them to repeat s/x. If you
  would like to set them to repeat the last Lightspeed motion (whether it was
  s/x or f/t), see `:h lightspeed-custom-mappings`. Just like above, subsequent
  keystrokes move on to the next match, while the opposite key reverts the
  previous motion.

#### Dot-repeat

Dot-repeat aims to behave in the most intuitive way in different situations -
on special cases, see `:h lightspeed-dot-repeat`.

### See also

For more details, see the docs (`:h lightspeed-usage`, `:h
lightspeed-default-mappings`), and the [in-depth
introduction](#-an-in-depth-introduction-of-the-key-features).

## 🔧 Configuration

Lightspeed exposes a configuration table (`opts`), that can be set directly, or
via a `setup` function that updates the current settings with the values given
in its argument table.

```Lua
-- NOTE: This is just illustration - there is no need to copy/paste the
-- defaults, or call `setup` at all, if you do not want to change anything.

require'lightspeed'.setup {
  ignore_case = false,
  exit_after_idle_msecs = { unlabeled = nil, labeled = nil },
  --- s/x ---
  jump_to_unique_chars = { safety_timeout = 400 },
  match_only_the_start_of_same_char_seqs = true,
  force_beacons_into_match_width = false,
  -- Display characters in a custom way in the highlighted matches.
  substitute_chars = { ['\r'] = '¬', },
  -- Leaving the appropriate list empty effectively disables "smart" mode,
  -- and forces auto-jump to be on or off.
  safe_labels = { . . . },
  labels = { . . . },
  -- These keys are captured directly by the plugin at runtime.
  special_keys = {
    next_match_group = '<space>',
    prev_match_group = '<tab>',
  },
  --- f/t ---
  limit_ft_matches = 4,
  repeat_ft_with_target_char = false,
}
```

For a detailed description of the available options, see the docs: `:h
lightspeed-config`.

You can also set options individually from the command line:
```Lua
lua require'lightspeed'.opts.jump_to_unique_chars = false
```

### EasyMotion/Hop-style config

By default, Lightspeed is tuned for maximum speed, especially for close and
midrange movements, but the cost of this is increased visual noise and a bit
more hectic experience. For a "calmer" style of navigation, similar to using Hop
or EasyMotion, add the following two lines to your config:

```
jump_to_unique_chars = false,
safe_labels = {}
```

These disable the two most obtrusive automagic features (jumping to unique
characters, and to the first 2-character match), while you can still enjoy
Lightspeed's unique advantage of making the labels visible right as you type.

You might also want to use bidirectional search instead of the default `s`/`S` -
for that, see `:h lightspeed-custom-mappings`.

### Keymaps

Lightspeed aims to be part of an "extended native" layer, similar to such
canonized Vim plugins like [surround.vim](https://github.com/tpope/vim-surround)
or [targets.vim](https://github.com/wellle/targets.vim). Therefore it provides
carefully thought-out defaults, mapping to the following keys: `s`, `S` (Normal
and Visual mode), `gs`, `gS` (Normal mode), `z`, `Z`, `x`, `X`
(Operator-pending mode), and - obviously, enhancing the built-in motions - `f`,
`F`, `t`, `T`, `;`, `,` (all modes). See `:h lightspeed-default-mappings` for
details.

That said, Lightspeed will check for conflicts with any custom mappings created
by you or other plugins, and will not overwrite them, unless explicitly told so.
To set alternative keymaps, you can use the `<Plug>` keys listed in `:h
lightspeed-custom-mappings`.

#### Overridden native keymaps (`s`/`S`/`gs`)

Basic motions, like Lightspeed jumps, should have the absolute least friction
among all commands, since they are the most frequent.

- `s`: for replacing one character, `r` is the adequate choice; for the rare
  case when one wants to continue inserting after that, using `cl` is more than
  fine
- `S`: `cc` is comfortable enough, and it is consistent with `yy` and `dd`
- `gs`: probably no one misses this shortcut for the `:sleep` command

#### Setting keys to repeat the last lightspeed motion (s/x/f/t)

That can be achieved easily with autocommands and expression mappings. See `:h
lightspeed-custom-mappings`.

#### Using the repeat keys for instant repeat only

Likewise, see `:h lightspeed-custom-mappings` for an example snippet.

#### Disabling the default keymaps

See `:h lightspeed-disable-default-mappings`.

### User events

Lightspeed triggers `User` events on entering/exiting, so that you can set
up autocommands, e.g. to change the values of some editor options while the
plugin is active. For details, check `:h lightspeed-events`.

### Highlight groups

For customizing the highlight colors, see `:h lightspeed-highlight`. If you are
a colorscheme author/maintainer, please also check out the appropriate
[guide](COLORSCHEMES.md).

In case you - as a user - are not happy with a certain colorscheme's
integration, you could force reloading the default settings by calling
`lightspeed.init_highlight(true)`. The call can even be wrapped in an
autocommand to automatically re-init on every colorscheme change:

```Vim
autocmd ColorScheme * lua require'lightspeed'.init_highlight(true)
```

This can be tweaked further, you could e.g. check the actual colorscheme, and
only execute for certain ones, etc.

### Notes

* While the plugin is active, the actual cursor is down on the command line, but
  its position in the window is kept highlighted, using the attributes of the
  built-in `Cursor` highlight group - should you experience any issues, you
  should check the state of that first. Alternatively, you can tweak the
  `LightspeedCursor` group, to highlight the cursor in a custom way.

* If you are using VSCode with NeoVim extension, you need to set
  [`hi LightspeedCursor gui=reverse`](https://github.com/vscode-neovim/vscode-neovim/pull/868#issuecomment-1131963354)
  in your nvim config to support the fake cursor and make Lightspeed work.

* The otherwise useful multiline scoping of `f/F/t/T` can be undesirable when
  recording macros or executing `:normal`. This is [being worked
  on](https://github.com/ggandor/lightspeed.nvim/issues/14), but as an API
  change, it should be thought through carefully. In the meantime, here is a
  rather elegant workaround for macros by [rktjmp](https://github.com/rktjmp)
  (caveat: [this causes a problem for same-key
  repeat](https://github.com/ggandor/lightspeed.nvim/discussions/84#discussioncomment-1666026)):

  ```Vim
  nmap <expr> f reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_f" : "f"
  nmap <expr> F reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_F" : "F"
  nmap <expr> t reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_t" : "t"
  nmap <expr> T reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_T" : "T"
  ```
  For `:normal`, you could use the bang-version `:normal!`, although that disables
  all custom mappings, so that is only a half-measure.

## ❔ Why is there no feature X or Y?

### Smart case-sensitivity?

See [#64](https://github.com/ggandor/lightspeed.nvim/issues/64). It is
unfortunately impossible for this plugin, by design. (Because of ahead-of-time
labeling, it would require showing two different labels - corresponding to two
different futures - at the same time.)

### Arbitrary-length search pattern?

That is practically labeling `/?` matches, right? It is overkill for our
purposes, IMO. Again, we are optimizing for the common case. A 2-character
pattern, with the secondary group of matches displayed ahead of time, should be
enough for making an on-screen jump efficiently 99% of the time; in that
remaining 1%, just live with having to press `Space` multiple times. (What the
heck are you editing, on what size of display, by the way?)

### Labeled matches for 1-character search?

That would be pretty pointless, for two reasons. First, the pause is inevitable
then, since it is physically impossible to show labels ahead of time. And
usually there are too many matches, so we should use multi-character labels.
(The closer ones you could probably reach with `sab` directly, instead of `fa` +
`l`.) Now, ask yourself the question: isn't it much better to type two on-screen
characters and then a "little bit surprising" label almost in one go (`sabl`),
than to type one on-screen character, and wait for (most probably) two
surprising characters to appear (`fa` + `lm`)?

Second, labeling matches makes it impossible to directly jump to the first
target when doing operations - we're making our lives harder in the most
frequent case (e.g. couldn't do a simple `dfa`).

In general, if you need to start thinking about whether to use `f` or `s`,
scanning the context, then the whole thing is screwed already. Minimal mental
effort. That is the mantra of Lightspeed. You should think of `f` and `t` as
_shortcuts_ for very specific situations, when you can count the number of
occurrences, and thus reach for them in a totally automatic way, and _not_ as
equals of the `s`/`x` motions.

### I miss Sneak's "vertical scope" feature...

That might indeed be useful, but I considered it would needlessly complicate the
plugin. Sometime in the future we might add that though.

If you work with tabular data frequently, you can make a mapping instead that
pre-populates the normal search prompt with horizontal bounds based on the
count, something like the following (`:h /\%v`):

```Vim
" note: g? in the example overwrites the superfun native rot13 command
nnoremap <expr> g/ '/<C-u>\%>'.(col(".")-v:count1).'v\%<'.(col(".")+v:count1).'v'
nnoremap <expr> g? '?<C-u>\%>'.(col(".")-v:count1).'v\%<'.(col(".")+v:count1).'v'
```

## 🌜 Contributing

Every contribution is very welcome, be it a bug report, fix, or just a
discussion-initiating question - please do not feel intimidated. If you have any
problems with the documentation especially, do not hesitate to reach out.

Tip: besides the [issue
tracker](https://github.com/ggandor/lightspeed.nvim/issues), be sure to also
check/use [Discussions](https://github.com/ggandor/lightspeed.nvim/discussions)
for announcements, simple Q&A, and open-ended brainstorming.

Regarding feature requests and enhancements, consider the [guiding
principles](#high-level-guiding-principles) first. If you have a different
vision, feel free to fork the plugin and improve upon it in ways you think are
best - I am glad to help  -, but I'd like to keep this version streamlined, and
save it from feature creep. Of course, that doesn't mean that I am not open for
discussions.

Lightspeed is written in [Fennel](https://fennel-lang.org/), and compiled to Lua
ahead of time. I am aware that using Fennel might limit the number of available
contributors, but compile-time macros, pattern matching, and a bunch of other
features are simply too much of a convenience. (Learning a Lisp can be an
eye-opening experience anyway, even though Fennel is something of a half-blood.)

As for "building", the plugin is really just one `.fnl` file at the moment, that
you can compile into the `lua` folder with the Fennel executable manually, or
using the provided Makefile.

## 💡 Inspired by

As always, we are standing on the shoulders of giants:

- [Sneak](https://github.com/justinmk/vim-sneak): a big fan of this - absolute
  respect for [justinmk](https://github.com/justinmk), besides his work on
  Neovim, for making a motion plugin that I have considered to be close to
  perfect for a long time
- [clever-f](https://github.com/rhysd/clever-f.vim)
- [Hop](https://github.com/phaazon/hop.nvim): a promising take on EasyMotion in
  the Neovim-era
- [EasyMotion](https://github.com/easymotion/vim-easymotion): the venerable one,
  of course

