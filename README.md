# 🌌 lightspeed.nvim

Lightspeed is the next evolutionary step in the quest for making on-screen
navigation as quick and efficient as possible: a minimal and opinionated motion
plugin for [Neovim](https://neovim.io/), with a small interface and lots of
automagic, that can be considered as a spiritual successor to
[Sneak](https://github.com/justinmk/vim-sneak). It is built around 2-character
search, and aims to maximize speed while minimizing cognitive load and breaks in
the flow.

### A short pitch

[EasyMotion](https://github.com/easymotion/vim-easymotion) and its derivatives
([Hop](https://github.com/phaazon/hop.nvim), or
[Avy](https://github.com/abo-abo/avy) for Emacs) are like a bunch of different -
however sophisticated - railway networks, with pre-built stations: you have to
think about which train to take, which exit point is the closest to your goal,
etc. A user of Sneak, on the other hand, embraces a different philosophy: it is
like having a _jetpack_ on you all the time.

Lightspeed, in particular, is like having a jetpack _with a GPS_. It is all
about processing the input incrementally - analyzing the available information
after _each_ keystroke, to assist the user and offer shortcuts:

* **target labels are assigned and displayed ahead of time, right after the
  first input:** the key idea behind Lightspeed, that eliminates the major
  problem of all of the current, general-purpose motion plugins, including Sneak
  itself - the inevitable pause between entering the search pattern and
  selecting the target. Once you try it, you will never look back.
* **shortcut-labels:** often you can type the target label right after the first
  input, as if doing 1-character search
* **jump based on partial input:** 2-character search can jump right after the
  first input, if the character is unique in the search direction

Other quality-of-life features:

* having a choice between automatically jumping to the first match (Sneak-like -
  default) or allowing for more comfortable target labels (EasyMotion-like)
* **full-inclusive mode** extends the operated area to the end of the match
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

Last but not least (bonus):

* **multiline 1-character (f/t-like) search modes**, with _instant-repeat_
  available (similar to [clever-f](https://github.com/rhysd/clever-f.vim) or
  Sneak's "clever" modes)

## 🚀 Getting started

### Requirements

* Neovim >= 0.5.0

### Installation

#### [vim-plug](https://github.com/junegunn/vim-plug)
```Vim
Plug 'ggandor/lightspeed.nvim'
```

#### [packer](https://github.com/wbthomason/packer.nvim)
```Lua
use 'ggandor/lightspeed.nvim'
```

### Usage

Command sequence for 2-character search in Normal mode, with the default
settings:

`{s,S}<c-x>?{char1}{char2}?{<tab>,<s-tab>}*{label}?`

That is, 
- invoke in the forward (`s`) or backward (`S`) direction
- optionally turn on "full-inclusive" mode (moves the cursor to the end of the
  match)
- enter 1st character of the search pattern (might short-circuit after this, if
  the character is unique in the search direction)
- enter 2nd character of the search pattern (might short-circuit after this, if
  there is only one match)
- optionally cycle through the groups of targets that can be labeled at once
- choose a labeled target to jump to (in the current group)

`f`, `F`, `t`, `T` work as their native counterparts, but are not limited to the
current line. In Normal and Visual mode, the motion can be repeated via pressing
the same key (`f` for `f`, etc.) or one of the others (changing the direction or
the inclusiveness on the fly) - this "instant-repeat" mode is active until you
type any other character. (If you want to keep using `;` and `,` to trigger
repeat, you can configure that manually - see
`:h lightspeed-custom-ft-repeat-mappings`.)

Pressing `<enter>` after invoking any of Lightspeed's commands searches with the
previous input (1- and 2-character searches are saved separately).

For more details, see `:h lightspeed-usage` and `:h lightspeed-default-mappings`.

### Configuration

Lightspeed exposes a configuration table, that can be set directly, or via a
`setup` function that updates the current settings with the values given in its
argument table.

```Lua
lua require'lightspeed'.setup {
  jump_to_first_match = true,
  jump_on_partial_input_safety_timeout = 400,
  -- This can get _really_ slow if the window has a lot of content,
  -- turn it on only if your machine can always cope with it.
  highlight_unique_chars = false,
  grey_out_search_area = true,
  match_only_the_start_of_same_char_seqs = true,
  limit_ft_matches = 5,
  full_inclusive_prefix_key = '<c-x>',
  -- By default, the values of these will be decided at runtime,
  -- based on `jump_to_first_match`.
  labels = nil,
  cycle_group_fwd_key = nil,
  cycle_group_bwd_key = nil,
}
```

You can also set options individually from the command line:
```Lua
lua require'lightspeed'.opts['jump_to_first_match'] = false
```

For a detailed description of the available options, see the docs: `:h
lightspeed-config`.

### Notes

* While the plugin is active, the actual cursor is down on the command line, but
  its position in the window is kept highlighted, using the attributes of the
  built-in `Cursor` highlight group - should you experience any issues, you
  should check the settings of that first. Alternatively, you can tweak the
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

Lightspeed's closest ancestor is the beloved
[Sneak](https://github.com/justinmk/vim-sneak) plugin, in that they share the
same basic assumptions, namely, that (1) we need _one_ command that is flexible
enough to do the job all the time, and can be invoked/operated with _total
automatism_, (2) unidirectional 1- or 2-character search is the simplest and
most adequate building block most of the time, (3) the interface should be
optimized for the _common case_.

While keeping that minimalist approach, Lightspeed nonetheless has a bunch of
brand-new features, blurring the boundary between one- and two-character search,
and offering some additional help at every single keypress:

- If you enter a character that is the only match in the search direction,
  Lightspeed jumps to it directly, without waiting for a second input.
  To mitigate accidents, a short timeout is set by default, until the second
  character in the pair (and only that) is "swallowed". 

  ![jumping to unique characters](../media/intro_img1_jump_to_unique.gif?raw=true)

  As an opt-int feature, these unique characters in the search direction can be
  highlighted beforehand;
  [quick-scope](https://github.com/unblevable/quick-scope) is based on a similar
  idea, but the intent here is not a "choose me!"-kind of preliminary
  orientation (the assumpiton is that you _know_ where you want to go), more
  like giving feedback for your brain _while_ you type.

- Target labels are shown ahead of time, _right after typing the first input
  character_. This means you can often type without any serious break in the
  flow, almost as if using 3-character search. It is a micro-optimisation, but
  can mean the world - Lightspeed simply _feels_ different because of this.

  ![incremental labeling](../media/intro_img2_incremental_labeling.gif?raw=true)

- Made possible by the above, Lightspeed has the concept of _shortcutable_
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

- When there is a large number of targets, we cycle through groups instead of
  trying to label everything at once (just like Sneak does it). However, the
  immediate next group is always shown ahead of time too, with a different
  color, so your brain has a bit of time to process the label, even in case of a
  distant group. If the target is right in the second group, you don't even have
  to think about "switching groups" - a blue label just means it's
  `{prefix-key}{label-key}`. That means we have `2 * number-of-labels` targets
  right away that are in the efficiently-reachable/low-cognitive-load range.

  ![groups](../media/intro_img4_groups.gif?raw=true)

  Note that Lightspeed keeps the invariant that a label consists of _exactly one
  character_, that should _always stay in the same position_, once appeared. (No
  rolling/flashing sequence of labels, like in case of Hop/EasyMotion.)

Moreover, you can choose between jumping to the first match automatically (like
Sneak does), or always having to select a label (Hop/EasyMotion). As both have
their pros and cons (the latter allows for a lot more - and more comfortable -
labels to use), there is no clear winner here I guess, and this is best left to
user preference.

## 👀 Coming sooner or later

- Provided that auto-jumping to the first target is turned off, we could
  frequently use the on-screen character that follows the pair instead of a
  label. Even if that turns out to be a bit harder to type than the assigned
  label would have been, _zero_ surprise - when the characters are already
  loaded into your brain even before you start typing - cannot be beaten. This
  requires quite a bit of refactoring though, but that would be for the better
  anyway.

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

### Arbitrary(-length) search pattern?

That is practically labeling `/?` matches, right? It is overkill for our
purposes, IMO. Again, we are optimizing for the common case. A 2-character
pattern, with the secondary group of targets displayed ahead of time, should be
enough for making an on-screen jump efficiently 99% of the time; in that
remaining 1%, please use `H/M/L/{/}` first, and if that's still not enough, just
live with having to press `Tab/Space` multiple times. (What the heck are you
editing, on what size of display, by the way?)

For regex patterns specifically, I have yet to find a compelling use case in
this context. Couldn't we just type the exact characters on the screen? (See
also _Start/end of line as a special target?_ below.)

### Start/end of line as a special target?

I am addressing these cases particularly, because these are the only ones among
the on-screen jumps that cannot always be replaced by 2-character search, and
thus might appear as legitimate requests at first sight.

The question you should ask is, however: _why_ do you want to go there in the
first place (especially if there is only whitespace there, at the beginning)?
What operation do you want to do there that is not _linewise_, and neither about
a word/WORD? If you want to start to insert from the beginning, use `I` instead
of `i` after landing. If you want to append to the very end, there is `A`
instead of `a`. If you want to delete/yank/change from the beginning/end up to
somewhere in the middle, then target that somewhere-in-the-middle column,
instead of the other way around.  (Protip: `map Y y$`.) If you want to comment
out an entire line, you should definitely use some plugin that offers a
dedicated command, or make your own mapping, instead of doing it by hand. And so
on...

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

Lightspeed aims to do one thing in a close to prefect manner, that is, helping
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

Regarding feature requests and enhancements, consider the "goals" section above
first. If you have a different vision, feel free to fork the plugin and improve
upon it in ways you think are best - I am glad to help  -, but I'd like to keep
this version streamlined, and save it from feature creep. Of course, that
doesn't mean that I am not open for discussions.

Lightspeed is written in [Fennel](https://fennel-lang.org/), and compiled to Lua
ahead of time. I am aware that using Fennel might limit the number of available
contributors, but compile-time macros, pattern matching, and a bunch of other
features are simply too much of a convenience.

As for "building", the plugin is really just one `.fnl` file at the moment, that
you can compile into the `lua` folder with the Fennel executable.

## 💡 Inspired by

As always, we are standing on the shoulders of giants:

- [Sneak](https://github.com/justinmk/vim-sneak): a big fan of this - absolute
  respect for Justin M. Keyes, besides his work on Neovim, for making a motion
  plugin that I have considered to be close to perfect for a long time
- [Hop](https://github.com/phaazon/hop.nvim): a promising take on EasyMotion in
  the Neovim-era
- [EasyMotion](https://github.com/easymotion/vim-easymotion): the venerable one,
  of course
- [clever-f](https://github.com/rhysd/clever-f.vim)
- [quick-scope](https://github.com/unblevable/quick-scope)

