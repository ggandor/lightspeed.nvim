# 🌌 lightspeed.nvim

Lightspeed is a cutting-edge motion plugin for [Neovim](https://neovim.io/),
with a small interface and lots of innovative ideas, that allow for making
on-screen movements with yet unprecedented ease and efficiency. The aim is to
maximize speed while minimizing mental effort and breaks in the flow, providing
an intuitive, distractionless experience, that should feel as "native" as
possible.

### A lightning pitch

The plugin's closest ancestor is Justin M. Keyes' beloved
[vim-sneak](https://github.com/justinmk/vim-sneak), in that they share the same
basic assumptions, namely: (1) to reach all kinds of distant targets, ideally we
need a small number of _context-independent_ motions, that are flexible enough
to do the job all the time, and can be invoked/operated with _total automatism_;
(2) for that, the most adequate basis is unidirectional one and two character
search; (3) the interface should be optimized for the _common case_.

#### Railways versus jetpacks

[EasyMotion](https://github.com/easymotion/vim-easymotion) and its derivatives
([Hop](https://github.com/phaazon/hop.nvim), or
[Avy](https://github.com/abo-abo/avy) for Emacs) are like a bunch of different -
however sophisticated - railway (maglev, hyperloop...) networks, with pre-built
stations: you have to think about which train to take, which exit point is the
closest to your goal, etc.

A user of Sneak, on the other hand, embraces a different philosophy: you barely
need to think about motions anymore - label-mode "sneaking" gets you everywhere
you need to be, with maximal precision. It is like having a _jetpack_ on you all
the time.

#### Always one step ahead of you

Lightspeed, in particular, is like having a jetpack _with a GPS_. While
preserving the minimalist approach of Sneak, it has a bunch of brand-new
features, that blur the boundary between one- and two-character search. It is
all about processing the input incrementally - analyzing the available
information after _each_ keystroke, to assist the user and offer shortcuts:

* **ahead-of-time displayed target labels:** in any case, you will _see_ the
  label right after the first input, so once you need to type it, your brain
  will already have processed it
* **shortcut-labels:** for some matches, it is possible to _use_ the target
  label right after the first input, as if doing 1-character search
* **jump based on partial input:** if the character is unique in the search
  direction, you will _automatically jump_ after the first input

The first one is probably the biggest game-changer, eliminating the major
problem of all other general-purpose motion plugins - the frustrating momentary
pause between entering your search pattern and selecting the target. Once you
try it, you will never look back.

To see these features in action, check the screen recordings in the [in-depth
introduction](https://github.com/ggandor/lightspeed.nvim#-an-in-depth-introduction-of-the-key-features) below.

#### Universal motions

To make the suite complete, Lightspeed also implements **multiline 1-character
(f/t-like) search modes**, with same-key repeat available (similar to
[clever-f](https://github.com/rhysd/clever-f.vim) or Sneak's "clever" modes),
and a so-called **x-mode** (extend/exclude), providing exclusive/inclusive pairs
for 2-character search too, allowing for more precision and comfort especially
in Operator-pending mode. Together they make it possible to reach the whole
on-screen area with very high efficiency in all situations when there is no
obvious _atomic_ alternative - like `w`, `{`, or `%` - available.

#### Other quality-of-life features

* having a choice between automatically jumping to the first match (Sneak-like -
  default) or allowing for more comfortable target labels (EasyMotion-like)
* flawless **dot-repeat support** for operators (with
  [repeat.vim](https://github.com/tpope/vim-repeat) installed)
* skips folds
* skips repeated (3+) sequences of the same character, for preserving labels
  (opt-out)
* greys out the search area, like EasyMotion does (opt-out)
* unique characters in the search direction can be highlighted before entering
  any input (opt-in)
* the cursor stays visible all the time
* uses extmarks, and does not mess with the Conceal group

## 🚀 Getting started

### Requirements

* Neovim >= 0.5.0

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

### 2-character search

Command sequence for 2-character search in Normal and Visual mode, with the
default settings:

`s|S char1 (char2|shortcut)? (<tab>|<s-tab>)* label?`

That is, 
- invoke in the forward (`s`) or backward (`S`) direction
- enter 1st character of the search pattern (might [short-circuit after
  this](https://github.com/ggandor/lightspeed.nvim#jump-on-partial-input), if
  the character is unique in the search direction) 
- _the "beacons" are lit at this point; all potential matches are labeled (char1 + ?)_
- enter 2nd character of the search pattern (might short-circuit after this, if
  there is only one match), or the label character, if the target is
  [shortcutable](https://github.com/ggandor/lightspeed.nvim#shortcuts).
- _certain beacons are extinguished; only char1 + char2 matches remain_
- _the cursor automatically jumps to the first match by default; pressing any
  other key than a group-switch or a target label exits the plugin now_
- optionally [cycle through the groups of
  matches](https://github.com/ggandor/lightspeed.nvim#grouping-matches-by-distance)
  that can be labeled at once
- choose a labeled target to jump to (in the current group)

In Operator-pending mode the search is invoked with `z`/`Z`, acknowledging that
"surround" plugins may benefit even more from being able to use `s`/`S` then.

#### X-mode

`s`/`S` follow the semantics of `/` and `?` in terms of cursor placement and
inclusive/exclusive operational behaviour, including forced motion types (`:h
forced-motion`). 

```
ab···|                         |···ab
|b····  ← S    jump      s  →  ····|b
██████  ← S    select    s  →  █████b
█████·  ← Z    operate   z  →  ████ab
██████  ← vZ   operate   vz →  █████b
```

The mnemonic for X-mode could be "extend/exclude" - it provides missing variants
for the two directions.

In the forward direction, the cursor goes to the end of the match; in the
backward direction, the cursor stops just before - in an absolute sense, after -
the end of the match (the equivalent of `T` for two-character search). In
Operator-pending mode, the edge of the operated area always gets an offset of
+2. This means that in the forward direction the motion becomes _inclusive_ (the
end position will be included in the operation). Compare the illustration with
the above one:

```
ab···|                         |···ab
ab|···  ← ?    jump      ?  →  ····a|
ab████  ← ?    select    ?  →  ██████
ab███·  ← X    operate   x  →  ██████
ab████  ← vX   operate   vx →  █████b
```

In Operator-pending mode `x`/`X` are readily available mappings for X-mode. This
seems a sensible default, as those keys are free in O-P mode; consider also the
handy mnemonics, and the fact that `z` and `x` are physically right next to each
other on a QWERTY keyboard.

In any Vim mode, X-mode can also be invoked by pressing `<c-x>` before the
search pattern.

#### Matching before line breaks

A character before EOL can be targeted by pressing `<enter>` after it (indicated
by `¬` in the highlighted match).

#### A note on the highlighting strategy

Let's say you would like to jump to an `AB` pair, and you have already entered
`A`, the first character of the search pattern.

If `jump_to_first_match` is on - the default setting -, then the directly
reachable ones among the `AX` matches will be highlighted as they are (with
white/black for dark/light themes, respectively). For these, it is enough to
finish the pattern, i.e., type `B`, to land on the target.

All other beacons on top of `A` `X` matches look like:

`X` `label`

where the first field (the place of `X`, showing the character masked by the
label) might be overlapped by the label of another match, and `label` itself
might be a [shortcut](https://github.com/ggandor/lightspeed.nvim#shortcuts),
with a filled background (the inverse of a regular label).

### 1-character search

Lightspeed also overrides the native `f`/`F`/`t`/`T` motions with enhanced
versions that work over multiple lines. 

In Normal and Visual mode, the motion can be repeated by pressing the
corresponding key - `f` or `t` - again. (They continue in the original
direction, whether it was forward or backward.) `F` and `T`, on the other hand,
always _revert_ the previous repeat. Note that in the case of `T`, this results
in a different, and presumably more useful behaviour than what you're used to in
clever-f and Sneak: `T` does not repeat the search in the reverse direction, but
puts the cursor back to its previous position - _before_ the previous match -,
allowing for an easy correction when you accidentally overshoot your target.

This "instant-repeat" mode is active until you type any other character.

By default, `;` and `,` are not utilized by the plugin anymore - you are free to
remap them to more useful things (`:` and `localleader` are great contenders).
If you are too used to the native Vim way, and want to keep using them for
repeating, there are two different possibilities.

First, you can specify custom keys for instant-repeat, in the `opts` table (see
the configuration section). The keys will be temporarily hijacked by the plugin
then, but the actual mappings will not be disturbed, so you can use them in
multiple roles. If you would like the keys to actually restart the search and
trigger repeat at any time, even after the plugin has finished executing
(similar to the native behaviour), there is a workaround for that too - see `:h
lightspeed-custom-ft-repeat-mappings`.

### Repeating motions

Pressing `<enter>` after invoking any of Lightspeed's commands searches with the
previous input (1- and 2-character searches are saved separately).

Dot-repeat aims to behave in the most intuitive way in different situations - on
special cases, see `:h lightspeed-dot-repeat`.

### See also

For more details, see the docs (`:h lightspeed-usage`, `:h
lightspeed-default-mappings`), and the [in-depth
introduction](https://github.com/ggandor/lightspeed.nvim#-an-in-depth-introduction-of-the-key-features)
below.

## 🔧 Configuration

Lightspeed exposes a configuration table (`opts`), that can be set directly, or
via a `setup` function that updates the current settings with the values given
in its argument table. (Note: There is no need to call `setup` at all, if you
are fine with the defaults.)

```Lua
require'lightspeed'.setup {
  jump_to_first_match = true,
  jump_on_partial_input_safety_timeout = 400,
  -- This can get _really_ slow if the window has a lot of content,
  -- turn it on only if your machine can always cope with it.
  highlight_unique_chars = false,
  grey_out_search_area = true,
  match_only_the_start_of_same_char_seqs = true,
  limit_ft_matches = 5,
  x_mode_prefix_key = '<c-x>',
  substitute_chars = { ['\r'] = '¬' },
  instant_repeat_fwd_key = nil,
  instant_repeat_bwd_key = nil,
  -- If no values are given, these will be set at runtime,
  -- based on `jump_to_first_match`.
  labels = nil,
  cycle_group_fwd_key = nil,
  cycle_group_bwd_key = nil,
}
```

You can also set options individually from the command line:
```Lua
lua require'lightspeed'.opts.jump_to_first_match = false
```

For a detailed description of the available options, see the docs: `:h
lightspeed-config`.

### Keymaps

Lightspeed aims to be part of an "extended native" layer, similar to the suite
of canonized Vim plugins including
[surround.vim](https://github.com/tpope/vim-surround),
[targets.vim](https://github.com/wellle/targets.vim), and Sneak, that maintain
some consistency between each other. Therefore it provides carefully thought-out
defaults, mapping to the following keys: `s`, `S` (Normal and Visual mode), `z`,
`Z`, `x`, `X` (Operator-pending mode), and - obviously, enhancing the built-in
motions - `f`, `F`, `t`, `T` (all modes).

(Note: Basic motions should have the absolute least friction among all commands,
since they are the most frequent. The native `s` and `S` both have comfortable
equivalents - `cl` and `cc`, respectively.)

That said, Lightspeed will check for conflicts with any custom mappings created
by you or other plugins, and will not overwite them, unless explicitly told so.
To set alternative keymaps, you can use the following `<Plug>` keys in all modes
(pattern length, direction, motion/operation semantics):

```
<Plug>Lightspeed_s  -  2-character  forward   /-like
<Plug>Lightspeed_S  -  2-character  backward  ?-like
<Plug>Lightspeed_x  -  2-character  forward   X-mode
<Plug>Lightspeed_X  -  2-character  backward  X-mode

<Plug>Lightspeed_f  -  1-character  forward   f-like
<Plug>Lightspeed_F  -  1-character  backward  F-like
<Plug>Lightspeed_t  -  1-character  forward   t-like
<Plug>Lightspeed_T  -  1-character  backward  T-like
```

(Note: `<Plug>` keys need to be mapped to recursively by design, do not use
`-noremap` for them.)

It is considered an exceptional request if one would like to revert to the
native behaviour of certain keys, that is, would not like to use some features
of the plugin at all; but in that case, all they has to do is to `unmap` the
relevant keys after the plugin has been sourced (e.g. `unmap t | unmap T`).

### Highlight groups

For customizing the highlight colors, see `:h lightspeed-highlight`.

#### Guidelines for colorscheme integrations

Dear fellow plugin authors, while letting your creativity fly, keep the
following points in mind:

* Tweak the colors, but aim to keep all the _attributes_ intact (bold,
  underline, filled/empty background, etc.), and also invariants like "shortcuts
  = inverse labels", even if you do not necessarily agree with the defaults.
  Lightspeed's highlighting scheme is very complex, and it is important to
  guarantee at least this level of consistency across themes, in order to not
  confuse users that switch between multiple ones regularly.

* `LightspeedMaskedChar` should be unobtrusive - barely noticeable ideally -,
  and in any case _much_ dimmer than the labels and shortcuts, otherwise the UI
  becomes too chaotic.

Note that even if a colorscheme does not aim to make any further modifications,
it might still make sense to link `LightspeedGreyWash` to `Comment`, provided
that the latter is some kind of neutral grey, without an own background color.

#### Enforce the default highlighting

If you - as a user - are not happy with a certain colorscheme's integration, you
could force reloading the default settings by calling
`lightspeed.init_highlight(true)`. The call can even be wrapped in an
autocommand to automatically re-init on every colorscheme change:

```Vim
autocmd ColorScheme * lua require'lightspeed'.init_highlight(true)
```

### User events

Lightspeed triggers `User` events on entering/exiting, so that you can set
up autocommands, e.g. to change the values of some editor options while the
plugin is active. For details, check `:h lightspeed-events`.

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
  rather elegant workaround for macros by [rktjmp](https://github.com/rktjmp):
  ```Vim
  nmap <expr> f reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_f" : "f"
  nmap <expr> F reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_F" : "F"
  nmap <expr> t reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_t" : "t"
  nmap <expr> T reg_recording() . reg_executing() == "" ? "<Plug>Lightspeed_T" : "T"
  ```
  For `:normal`, you could use the bang-version `:normal!`, although that disables
  all custom mappings, so that is only a half-measure.

## 📚 An in-depth introduction of the key features

### Jump on partial input

If you enter a character that is the only match in the search direction,
Lightspeed jumps to it directly, without waiting for a second input. To mitigate
accidents, a short timeout is set by default, until the second character in the
pair (and only that) is "swallowed". In operator-pending mode, the operated area
gets a temporary highlight (strikethrough for "destructive" operations - change
and delete -, colored background for others) until the next character is
entered.

![jumping to unique characters](../media/intro_img1_jump_to_unique.gif?raw=true)

As an opt-int feature, these unique characters in the search direction can be
highlighted beforehand;
[quick-scope](https://github.com/unblevable/quick-scope) is based on a similar
idea, but the intent here is not a "choose me!"-kind of preliminary
orientation (the assumpiton is that you _know_ where you want to go), more
like giving feedback for your brain _while_ you type.

### Ahead-of-time labeling

Target labels are shown ahead of time, _right after typing the first input
character_. This means you can often type without any serious break in the
flow, almost as if using 3-character search. It is a micro-optimisation, but
can mean the world - Lightspeed simply _feels_ different because of this.

![incremental labeling](../media/intro_img2_incremental_labeling.gif?raw=true)

### Shortcuts

Made possible by the above, Lightspeed has the concept of _shortcutable_
positions, where the assigned label itself is enough to determine the target:
those you can reach via typing the label character right after the first
input, bypassing the second one. This case is suprisingly frequent in
practice, and in case of harder-to-type sequences, when you're not rushing
with 200+ CPM, can work really well.

You can see that "shortcuts" are highlighted differently:

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
immediate next group is always shown ahead of time too, with a different
color, so your brain has a bit of time to process the label, even in case of a
distant group. If the target is right in the second group, you don't even have
to think about "switching groups" - a blue label just means it's
`{group-switch-key}{label-key}`. That means we have `2 * number-of-labels`
targets right away that are in the efficiently-reachable/low-cognitive-load
range.

![groups](../media/intro_img4_groups.gif?raw=true)

Note that Lightspeed keeps the invariant that a label consists of _exactly one
character_, that should _always stay in the same position_, once appeared. (No
rolling/flashing sequence of labels, like in case of Hop/EasyMotion.)

## 👀 Coming sooner or later

- There is a _huge_ feature in the making, but do not expect it to land anytime
  soon: the idea is that the target labels could be chosen, based on a given
  input sequence, in an optimal way that minimizes typing effort. (This should
  take the keyboard layout and the preferred fingering into account, obviously.)
  I am more or less in the planning phase of this, and this might very well turn
  out to be more complex than the rest of the plugin itself. (Any help is
  appreciated!)

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

### Ignore case for 2-character search?

Yep, that is a no-brainer, but unfortunately not _that_ trivial to implement
here - because we are not actually "searching" for the second character of the
pair -, and I guess it would complicate the codebase pretty significantly. (It
might be that I am missing something obvious though.) At the same time, note
that with the different shortcutting methods available, the lack of an "ignore
case" option is less of a problem for us: in this plugin, capitals _can_ very
frequently make you reach the target faster - so start using them!

### Arbitrary-length search pattern?

That is practically labeling `/?` matches, right? It is overkill for our
purposes, IMO. Again, we are optimizing for the common case. A 2-character
pattern, with the secondary group of matches displayed ahead of time, should be
enough for making an on-screen jump efficiently 99% of the time; in that
remaining 1%, please use `H`/`M`/`L`/`{`/`}` first, or just live with having to
press `Tab`/`Space` multiple times. (What the heck are you editing, on what size
of display, by the way?)

### Labeled matches for 1-character search?

That would be pretty pointless, for two reasons. First, the "pause" is
inevitable then, since it is physically impossible to show labels ahead of time.
Second, usually there are too many matches, so we should use multi-character
labels. (The closer ones you could probably reach with `sab` directly, instead
of `fa` + `l`.) Now, ask yourself the question: isn't it much better to type two
on-screen characters and then a "little bit surprising" label in one go - or
almost in one go - (`sabl`), than to type one on-screen character, and wait for
(most probably) two surprising characters to appear (`fa` + `lm`)?

In the not-too-frequent case it might end up being `fa` + `l` versus `sabl`,
where the former could technically be faster by a narrow margin (annoying pause
notwithstanding). But in general, if you need to start thinking about whether to
use `f` or `s`, scanning the context, then the whole thing is screwed already.
Minimal mental effort. That is the mantra of Lightspeed. 1-character search is
for very short distances, or when you can clearly count the number of
occurrences, and reach for `f` or `t` in a totally automatic way. In those cases
they are invaluable shortcuts, but for everything else, `s` should be the
default choice. The multiline enhancement has only been implemented because of
that annoying situation when there is a unique character just a couple of lines
above of below the current line, but we could not target it with the native
`f`/`t`.

### Bi-directional search?

Wontfix. When you aim for a target, you know the direction to go, that's not
something you have to consciously think about or something that slows you down
at all. Consequently, it's utterly wasteful _not_ to use this information to
ease our lives, by - on average - halving the search area and thus doubling the
number of available target labels, while creating less visual noise on screen.
(Note that bi-directional search also makes it impossible to automatically jump
to the first match, an extremely convenient feature.)

EasyMotion/Hop needs bi-directional search, simply because they do not have
enough keys to map to, as a result of their insistence on having a lot of
specialized targets (a fundamentally different approach). On the other hand,
Sneak/Lightspeed is a more organic extension of the native Vim toolkit: with
only one additional keypair, we can nicely stay in line with the native search
commands, that are all unidirectional: `<shift-{key}>` counterparts are obvious
and intuitive in Vim-land.

### Multi-window search?

That, in itself, is actually not that bad an idea. Maybe the only feature of
EasyMotion that I envy a bit. Would be fun to use together with Lightspeed's
incremental labeling. But it seems almost impossible to be implemented, by
design; it goes too much against Lightspeed's basic tenets. What about
directions? What do we do when there are not enough labels?

(In any case, I humbly suggest mapping `<C-w>h/j/k/l` to `<A-h/j/k/l>` first, if
you have not done that already.)

## ❕ Goals and non-goals

Lightspeed aims to do one thing in a close to perfect manner, that is, helping
to reach visible targets, while requiring minimal mental effort to operate:
every design decision has been made with this goal in mind. That means, it is
not intended to be a general search tool, and neither an EasyMotion-like plugin
offering a bunch of different commands for specific kinds of targets (lines,
word beginnings, 3rd-column-form-the-right-of-EOL-modulo-7). Still, I'm eager to
include any cool idea, if it (1) does not complicate the interface and usage in
significant ways, and (2) makes navigation actually faster.

## 🌜 Contributing

Every contribution is very welcome, be it a bug report, fix, or just a
discussion-initiating question - please do not feel intimidated. If you have any
problems with the documentation especially, do not hesitate to reach out.

Tip: besides the [issue
tracker](https://github.com/ggandor/lightspeed.nvim/issues), be sure to also
check/use [Discussions](https://github.com/ggandor/lightspeed.nvim/discussions)
for announcements, simple Q&A, and open-ended brainstorming.

Regarding feature requests and enhancements, consider the "goals" section above
first. If you have a different vision, feel free to fork the plugin and improve
upon it in ways you think are best - I am glad to help  -, but I'd like to keep
this version streamlined, and save it from feature creep. Of course, that
doesn't mean that I am not open for discussions.

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

