# 🌌 lightspeed.nvim

Lightspeed is a cutting-edge motion plugin for [Neovim](https://neovim.io/),
with a small interface and lots of innovative ideas, that allow for making
on-screen movements with yet unprecedented ease and efficiency. The aim is to
maximize speed while minimizing mental effort and breaks in the flow, providing
an intuitive, distractionless experience, that should feel as "native" as
possible.

## The gist in 30 secs

With Lightspeed you can jump to any positions in the visible window area by
entering a 2-character search pattern, and then optionally a "label" character
for choosing among multiple matches. The plugin aims to substitute _all_ native
commands for in-window navigation (`/`, `?`, `gg`, `f`, etc.) with a uniform,
_minimal_ set of atomic (repeatable), multi-axis motions.

So far we have more or less described what
[vim-sneak](https://github.com/justinmk/vim-sneak) does. The game-changing idea
in Lightspeed is its "clairvoyant" ability: it maps possible futures, and shows
you which keys you will need to press _before_ you actually need to do that, so
despite the use of target labels, you can keep typing in a continuous manner.
Over 95 percent of the time, you can reach the destination by at most - and very
often less than - four keystrokes in total, that can be typed _in one go_.

If this sounds cool enough, read on, or watch this [6-minute introductory video
by DevOnDuty](https://youtu.be/ESyld9NCl1w) first.

## Sky chart

* [A lightning pitch](#-a-lightning-pitch)
* [An in-depth introduction of the key features](#-an-in-depth-introduction-of-the-key-features)
* [Getting started](#-getting-started)
* [Usage](#-usage)
* [Configuration](#-configuration)
* [Why is there no feature X or Y?](#-why-is-there-no-feature-x-or-y)
* [Contributing](#-contributing)
* [Inspired by](#-inspired-by)

### Quick links (FAQ)

* [A primer on the highlighting strategy](#a-primer-on-the-highlighting-strategy)
* [Guidelines for colorscheme
  integrations](#guidelines-for-colorscheme-integrations)
* [Enforce the default highlighting if a colorscheme messes things
  up](#enforce-the-default-highlighting)
* [Multi-line f/t motions VS macros and :normal](#notes)
* [Using the plugin together with
  vim-surround](https://github.com/ggandor/lightspeed.nvim/discussions/83)

## ⚡ A lightning pitch

The plugin's closest ancestor is Justin Keyes' beloved
[vim-sneak](https://github.com/justinmk/vim-sneak), in that they share the same
basic assumptions, namely:

1. To reach all kinds of distant targets, ideally we need a few
   _context-independent_ motions, that are flexible enough to do the job all
   the time, and can be invoked/operated with _total automatism_, without
   being aware of the type or the surroundings of the target.
2. For that, the most adequate basis is unidirectional 1- and 2-character
   search.
3. The interface should be _optimized for the common case_.

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

To make the suite complete, Lightspeed also implements [enhanced f/t-like
motions working over multiple lines](#1-character-search-ft), with same-key
repeat available, and a so-called [x-mode](#x-mode), providing
exclusive/inclusive variations for 2-character search. Together the four
bi-directional motions (`s`/`x`/`f`/`t`) make it possible to reach and operate
on the whole window area with high efficiency in all situations when there is no
obvious atomic alternative - like `w`, `{`, or `%` - available.

### Other quality-of-life features

* **smart shifting between Sneak/EasyMotion mode** - the plugin automatically
  jumps to the first match if the remaining matches can be covered by a limited
  set of "safe" target labels, but stays in place, and switches to an extended,
  more comfortable label set otherwise
* **linewise operations** are possible without limitations via the same uniform
  interface, by targeting (potentially off-screen) EOL characters
* flawless **dot-repeat support** for operators (with
  [repeat.vim](https://github.com/tpope/vim-repeat) installed)
* skips folds
* skips repeated (3+) sequences of the same character, for preserving labels
  (opt-out)
* greys out the search area, like EasyMotion does (opt-out)
* the cursor stays visible all the time
* uses extmarks, and does not mess with the Conceal group

### Guiding principles

_"Some people . . . like tons of features, but experienced users really care
about cohesion, conceptual integrity, and reliability. I think of [the latter]
as the @tpope school."_
([justinmk](https://github.com/justinmk/vim-sneak/issues/62#issuecomment-34044380))

* [80/20](https://youtu.be/Bt-vmPC_-Ho?t=1249): focus on features that are
  applicable in all contexts; micro-optimisations for the most frequent tasks
  accumulate more savings than vanity features that turn out to be rarely needed
  in practice

* [Design is making
  decisions](https://www.infoq.com/presentations/Design-Composition-Performance/):
  mitigate choice paralysis for the user, regarding both usage and configuration

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
(the assumpiton is that you _know_ where you want to go), more like giving
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
input, bypassing the second one. This case is suprisingly frequent in
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

* Neovim >= 0.5.0

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

Command sequence for 2-character search in Normal and Visual mode, with the
default settings:

`s|S char1 (char2|shortcut)? (<space>|<tab>)* label?`

That is, 
- invoke in the forward (`s`) or backward (`S`) direction
- enter 1st character of the search pattern (might [short-circuit after
  this](#jump-on-partial-input), if the character is unique in the search
  direction) 
- _the "beacons" are lit at this point; all potential matches are labeled (char1 + ?)_
- enter 2nd character of the search pattern (might short-circuit after this, if
  there is only one match), or the label character, if the target is
  [shortcutable](#shortcuts).
- _certain beacons are extinguished; only char1 + char2 matches remain_
- _the cursor automatically jumps to the first match if there are enough "safe"
  labels; pressing any other key than a group-switch or a target label exits the
  plugin now_
- optionally [cycle through the groups of
  matches](#grouping-matches-by-distance) that can be labeled at once
- choose a labeled target to jump to (in the current group)

In Operator-pending mode the search is invoked with `z`/`Z`, acknowledging that
"surround" plugins may benefit even more from being able to use `s`/`S` then.

#### A primer on the highlighting strategy

Let's say you would like to jump to an `A` `B` pair, and you have entered `A`,
the first character of the search pattern.

At that moment, all `A` `?` matches will be highlighted, in different manners
according to the next step needed to be taken to reach them.

- The directly reachable ones among the `A` `?` matches will be highlighted as
  they are (with white/black for dark/light themes, respectively). For those, it
  is enough to finish the pattern, i.e., type `?`, to land on the target.

- Otherwise, in the usual case, a label will appear right next to the second
  character. These labels can also be [shortcuts](#shortcuts), with a filled
  background (the inverse of a regular label), that allow for reaching the
  target right after the first input.

- If a match is too close to the next one, the beacon should be "squeezed" into
  the original 2-column box of the match; that is, on top of an `A` `?` match, a
  `?` `label` pair will appear, where the first field shows the character masked
  by the label (it is shifted left by a column). In the most extreme case, the
  `?` field can even be overlapped by the label of another match, but only until
  the second input has not been entered - after that, all overlapped matches are
  guaranteed to become uncovered.

#### X-mode

`s`/`S` follow the semantics of `/` and `?` in terms of cursor placement and
inclusive/exclusive operational behaviour, including forced motion types (`:h
forced-motion`): 

```
ab···|                         |···ab
|b····  ← S    jump      s  →  ····|b
██████  ← S    select    s  →  █████b
█████·  ← Z    operate   z  →  ████ab
██████  ← vZ   operate   vz →  █████b
```

The mnemonic for X-mode could be **extend/exclude** (corresponding to `x`/`X`).
It provides missing variants for the two directions:

```
ab···|                         |···ab
ab|···  ← ?    jump      ?  →  ····a|
ab████  ← ?    select    ?  →  ██████
ab███·  ← X    operate   x  →  ██████
ab████  ← vX   operate   vx →  █████b
```

As you can see from the figure, `x` goes to the end of the match, while `X`
stops just before - in an absolute sense, after - the end of the match (the
equivalent of `T` for two-character search). In Operator-pending mode, the edge
of the operated area always gets an offset of +2. This means that in the forward
direction the motion becomes _inclusive_ (the end position will be included in
the operation).

In Operator-pending mode `x`/`X` are readily available mappings for X-mode. This
seems a sensible default, considering that those keys are free in O-P mode, and
the handy visual mnemonic that `x` is physically to the right of `z` on a QWERTY
keyboard (think about "pulling" the cursor forward).

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
following methods (and even combinations of them) are valid options:

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

- There are dedicated repeat `<Plug>` keys available for the two search modes.
  `;` and `,` are mapped to f/t repeat by default (following the native
  behaviour), but it might be a good idea to remap them to repeat s/x. If you
  would like to set them to repeat the last Lightspeed motion (whether it was
  s/x or f/t), see `:h lightspeed-custom-mappings`. Just like above, subsequent
  keystrokes move on to the next match, while the opposite key reverts the
  previous motion.

Note that for s/x motions the labels will remain available during the whole
time, even after entering instant-repeat mode.

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
(Note: There is no need to call `setup` at all, if you are fine with the
defaults.)

```Lua
require'lightspeed'.setup {
  exit_after_idle_msecs = { labeled = nil, unlabeled = 1000 },

  -- s/x
  grey_out_search_area = true,
  highlight_unique_chars = true,
  match_only_the_start_of_same_char_seqs = true,
  jump_on_partial_input_safety_timeout = 400,
  substitute_chars = { ['\r'] = '¬' },
  -- Leaving the appropriate list empty effectively disables
  -- "smart" mode, and forces auto-jump to be on or off.
  safe_labels = { ... },
  labels = { ... },
  cycle_group_fwd_key = '<space>',
  cycle_group_bwd_key = '<tab>',

  -- f/t
  limit_ft_matches = 4,
  repeat_ft_with_target_char = false,
}
```

For a detailed description of the available options, see the docs: `:h
lightspeed-config`.

You can also set options individually from the command line:
```Lua
lua require'lightspeed'.opts.highlight_unique_chars = false
```

### Keymaps

Lightspeed aims to be part of an "extended native" layer, similar to such
canonized Vim plugins like [surround.vim](https://github.com/tpope/vim-surround)
or [targets.vim](https://github.com/wellle/targets.vim). Therefore it provides
carefully thought-out defaults, mapping to the following keys: `s`, `S` (Normal
and Visual mode), `z`, `Z`, `x`, `X` (Operator-pending mode), and - obviously,
enhancing the built-in motions - `f`, `F`, `t`, `T`, `;`, `,` (all modes).

That said, Lightspeed will check for conflicts with any custom mappings created
by you or other plugins, and will not overwite them, unless explicitly told so.
To set alternative keymaps, you can use the following `<Plug>` keys in all modes
(pattern length, direction, motion/operation semantics):

```
<Plug>Lightspeed_s      2-character  forward   /-like (0,  exclusive op)
<Plug>Lightspeed_S      2-character  backward  ?-like (0,  exclusive op)
<Plug>Lightspeed_x      2-character  forward          (+1, inclusive op)
<Plug>Lightspeed_X      2-character  backward         (+2, exclusive op)
                                                                        
<Plug>Lightspeed_f      1-character  forward   f-like (0,  inclusive op)
<Plug>Lightspeed_F      1-character  backward  F-like (0,  exclusive op)
<Plug>Lightspeed_t      1-character  forward   t-like (-1, inclusive op)
<Plug>Lightspeed_T      1-character  backward  T-like (+1, exclusive op)

Repeat, or revert the opposite key
<Plug>Lightspeed_;_sx
<Plug>Lightspeed_;_ft

Repeat in the reverse direction, or revert the opposite key
<Plug>Lightspeed_,_sx
<Plug>Lightspeed_,_ft
```

(Note: Be sure to use `-map`, and not `-noremap`, for `<Plug>` mappings, as they
should be used recursively, by design.)

#### Using the repeat `<Plug>` keys for instant repeat only

That can be achieved easily with an expression mapping. See `h:
lightspeed-custom-mappings`.

#### Why `s`/`S`?

Basic motions should have the absolute least friction among all commands, since
they are the most frequent. The native `s` and `S` both have comfortable
equivalents - `cl` and `cc`, respectively.

#### Disabling features

It is considered an exceptional request if one would like to revert to the
native behaviour of certain keys, that is, would not like to use some search
mode of the plugin at all; but in that case, all they have to do is to unmap the
relevant keys after the plugin has been sourced (`noremap f f` or `silent! unmap
f` for each).

### User events

Lightspeed triggers `User` events on entering/exiting, so that you can set
up autocommands, e.g. to change the values of some editor options while the
plugin is active. For details, check `:h lightspeed-events`.

### Highlight groups

For customizing the highlight colors, see `:h lightspeed-highlight`.

#### Guidelines for colorscheme integrations

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

#### Enforce the default highlighting

If you - as a user - are not happy with a certain colorscheme's integration, you
could force reloading the default settings by calling
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

* The otherwise useful multiline scoping of `f/F/t/T` can be undesireable when
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

### Case insensitivity for 2-character search?

See [#64](https://github.com/ggandor/lightspeed.nvim/issues/64). TL;DR:
`smartcase`-like behaviour would be super-useful, but is unfortunately
impossible for this plugin, _by design_. At the same time, the value of a plain
"ignore case" setting is questionable, because that would mean ignoring our
clever "shortcutting" features too. Here, capitals can very frequently make you
reach the target faster - so start using them!

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

### Bi-directional search?

Wontfix. When you aim for a target, you know the direction to go, that's not
something you have to consciously think about or something that slows you down
at all. Consequently, it's utterly wasteful _not_ to use this information and
encode it in the trigger key right away, to ease our lives, by - on average -
halving the search area and thus doubling the number of available target labels,
while creating less visual noise on screen. (Note that bi-directional search
also makes it impossible - or at least very problematic - to automatically jump
to the first match, an extremely convenient feature.)

### Multi-window search?

That, in itself, is actually not that bad an idea. Maybe the only feature of
EasyMotion that I envy a bit. Would be fun to use together with Lightspeed's
incremental labeling. But it seems almost impossible to be implemented, by
design; it goes too much against Lightspeed's basic tenets. What about
directions? What do we do when there are not enough labels?

(In any case, I humbly suggest mapping `<C-w>h/j/k/l` to `<A-h/j/k/l>` first, if
you have not done that already.)

## 🌜 Contributing

Every contribution is very welcome, be it a bug report, fix, or just a
discussion-initiating question - please do not feel intimidated. If you have any
problems with the documentation especially, do not hesitate to reach out.

Tip: besides the [issue
tracker](https://github.com/ggandor/lightspeed.nvim/issues), be sure to also
check/use [Discussions](https://github.com/ggandor/lightspeed.nvim/discussions)
for announcements, simple Q&A, and open-ended brainstorming.

Regarding feature requests and enhancements, consider the [guiding
principles](#guiding-principles) first. If you have a different vision, feel
free to fork the plugin and improve upon it in ways you think are best - I am
glad to help  -, but I'd like to keep this version streamlined, and save it from
feature creep. Of course, that doesn't mean that I am not open for discussions.

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

