# Understanding Your Fish Shell Config

Written 27 July 2026, after fixing a bug where the Zed editor could not start its
Java language server.

This document explains, in plain language, what your shell configuration does, what
was wrong with it, and what I changed. **No prior knowledge assumed.** If you already
know a section, skip it.

---

## Part 0 — How to read this

Read Parts 1 to 3 first. They teach the four ideas you need. Part 4 tells the story of
the actual bug, which will make the ideas click. Part 5 lists every change I made.

Anything in a grey box like `this` is something you could literally type into your
terminal.

---

## Part 1 — The basics

### What is a shell?

When you open your terminal app (Ghostty, in your case), you see a prompt waiting for
you to type. The program listening for what you type is called a **shell**.

Its job is simple: you type the name of a program, it finds that program on your
computer, runs it, and shows you the output.

You type `git status` → the shell finds the `git` program → runs it → prints the result.

**fish** is your shell. Other common shells are **bash** and **zsh**. They all do the
same job; they differ in convenience features and in the exact words you use to write
instructions for them.

### What is `config.fish`?

Every time a new shell starts, fish looks for a file of instructions and runs everything
in it, top to bottom, before handing control to you.

That file is `config.fish`. It is how you make settings stick. Without it, you would
have to re-type your setup every time you opened a terminal.

Think of it as a **checklist the shell runs before you arrive**.

### Where your files actually live

This part confused even me at first, and it is worth understanding.

Fish expects its config at:

```
~/.config/fish/config.fish
```

But your actual file lives in your dotfiles folder:

```
~/dotfiles/fish/config.fish
```

These are connected by a **symlink**. A symlink is a signpost: a file that contains
nothing but the message "the real thing is over there." When fish opens
`~/.config/fish/config.fish`, macOS silently redirects it to `~/dotfiles/fish/config.fish`.

You did this so all your settings live in one folder you can track with git. It is a
good setup. Two things in your system work this way:

| What fish/Zed looks for | Where it really is |
|---|---|
| `~/.config/fish/config.fish` | `~/dotfiles/fish/config.fish` (single file) |
| `~/.config/zed/` | `~/dotfiles/zed/` (whole folder) |

The second one has a side effect worth knowing: when I edited your Zed settings earlier,
that edit landed inside your dotfiles git repository automatically, because the whole
folder is a signpost.

> **Note for later:** symlinks are also why one of my searches failed. I searched
> `~/.config/fish/` for the text "JAVA_HOME" and found nothing — because the search tool
> I used does not follow signposts. The text was there all along, in the real file.

---

## Part 2 — The single most important idea: two kinds of shell

This is the concept behind the bug. Everything else follows from it.

### Kind 1: an interactive shell

This is what you picture when you think "terminal." You open Ghostty, a prompt appears,
you type things, you read the output. A human is present.

### Kind 2: a non-interactive shell

Here is the part most people never think about: **programs start shells too.**

When some other program needs to run a command, it quietly starts a shell, hands it one
instruction, collects the answer, and throws the shell away. No window appears. No human
types anything. This happens constantly, all day, invisibly.

Examples on your machine:

- A script file you run.
- Your code editor asking "what version of node is installed?"
- A build tool running a compile step.
- **Zed, at startup, asking "what does this user's environment look like?"**

That last one is the villain of our story.

### The guard

Your old config started with this line:

```fish
if status is-interactive
    ...everything...
end
```

In plain English: **"Only do the following if a human is typing."**

Everything between that line and the matching `end` was skipped entirely for
non-interactive shells.

That is correct for *some* things. It is wrong for others. Knowing which is which is the
whole lesson:

| Belongs inside the guard | Belongs outside the guard |
|---|---|
| Your colourful prompt (starship) | Where to find programs (PATH) |
| Shortcuts like `gs` for `git status` | Settings other programs need to read |
| Turning off the welcome message | Which Java to use |

Why the split? A prompt is pointless when no human is looking — that is pure waste. But
"which Java should I use" is something a *program* needs to know, and programs are
exactly what runs in non-interactive shells.

**Your old config had everything inside the guard.** That is the root problem.

---

## Part 3 — Environment variables and PATH

### Environment variables

An **environment variable** is a named note that a shell hands to every program it
starts. The program can read the note and change its behaviour.

For example, `EDITOR` is a note saying "when you need me to edit text, open this."
When git needs you to write a commit message, it reads the `EDITOR` note and opens
whatever it says. Yours says `zed --wait`.

Setting one in fish looks like this:

```fish
set -gx EDITOR "zed --wait"
```

- `set` — create a variable
- `-g` — **global**: available everywhere in this shell (more on this in Part 6)
- `-x` — **exported**: hand this note to programs I start. Without `-x` the note stays
  private to the shell and no program ever sees it.

### PATH — the most important variable

When you type `git`, how does the shell find the git program? Your Mac has hundreds of
thousands of files.

It uses `PATH`: **an ordered list of folders to look in.** The shell checks each folder
in order and uses the first match it finds. If it reaches the end without a match, you
get `command not found`.

Order matters enormously. If two folders both contain a program called `psql`, whichever
folder is listed first wins. The other is invisible.

Your PATH includes folders like:

```
/opt/homebrew/bin                          ← things installed by Homebrew
/Users/mengkhaiteow/.cargo/bin             ← things installed by Rust
/Users/mengkhaiteow/go/bin                 ← things installed by Go
/usr/bin                                   ← things Apple ships
```

`fish_add_path` is fish's command for adding a folder to this list.

### JAVA_HOME

`JAVA_HOME` is a note that says **"the Java installation to use lives in this folder."**

You have two Java versions installed:

| Version | Location |
|---|---|
| Java 21 | `/Library/Java/JavaVirtualMachines/jdk-21.jdk/Contents/Home` |
| Java 17 | `/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home` |

Java tools read `JAVA_HOME` to decide which one to use. Whichever it points at, wins.

macOS ships a helper that answers "where is Java?":

```
/usr/libexec/java_home          → picks the newest you have installed (Java 21)
/usr/libexec/java_home -v 17    → picks Java 17 specifically
```

---

## Part 4 — The bug, step by step

Now the four ideas come together.

**Step 1.** Your old config contained this line, inside the interactive guard:

```fish
set -gx JAVA_HOME (/usr/libexec/java_home -v 17)
```

The `-v 17` says "specifically Java 17." At some point you or a tool wrote this, and it
was probably correct at the time. You then stopped writing Java for a while, installed
Java 21, and never revisited the line. It sat there quietly pointing at the old version.

**Step 2.** You opened a Java file in Zed. Zed needs a "language server" — a background
program providing autocomplete and error checking. The Java one is called **jdtls**.

**Step 3.** jdtls requires Java 21 or newer. It refuses to start on anything older.

**Step 4.** To find out which Java to use, Zed started a **non-interactive** shell and
asked it for the environment. That shell ran your config, hit the `JAVA_HOME` line, and
reported **Java 17**.

**Step 5.** jdtls saw Java 17, said "too old," and refused to start. That was the error
message on your screen.

### Why this took so long to find

Two traps, both worth knowing because they will recur.

**Trap 1 — I looked in the wrong place.** I searched your fish folder for "JAVA_HOME"
and found nothing, so I concluded fish never set it. But the file was a signpost
(Part 1), and my search tool did not follow signposts. I was searching an empty room.

**Trap 2 — my test was not the same as Zed's test.** I ran a non-interactive shell and
asked for `JAVA_HOME`. It came back empty, which seemed to confirm fish was innocent.

But it came back empty *because of the guard*. My test shell was not interactive, so it
skipped the whole block, including the `JAVA_HOME` line.

Zed's shell is both **login and interactive** — it asks fish to behave as though a human
were present. So Zed ran the block and got Java 17, while my test skipped the block and
got nothing. Same file, opposite answers.

That is the lesson worth keeping: **when a GUI program disagrees with your terminal
about a setting, the two are probably not reading the same environment.**

---

## Part 5 — Every change I made, and why

### Change 1 — Moved settings out of the interactive guard

**The big one.** Environment variables and PATH now run for *every* shell. Only the
prompt, the shortcuts, and interactive tools stay behind the guard.

**Before:** a script you ran had no `JAVA_HOME`, no `PNPM_HOME`, and could not even find
Homebrew programs. Anything you typed by hand worked; the same command inside a script
mysteriously failed.

**After:** both behave identically. This is what actually fixed the Zed bug, and it
prevents a whole family of "works when I type it, breaks when a tool runs it" problems.

### Change 2 — Removed the hardcoded Java version

```diff
- set -gx JAVA_HOME (/usr/libexec/java_home -v 17)
+ set -l _java_home (/usr/libexec/java_home 2>/dev/null)
+ if test -n "$_java_home"
+     set -gx JAVA_HOME $_java_home
+ end
```

Dropping `-v 17` means "use the newest Java I have installed" rather than "use Java 17
forever." Install Java 22 next year and this follows automatically.

**This directly answers your question: no, you do not have to maintain this by hand.**
You only pin a specific version when a project genuinely requires an old one — and when
that day comes, pin it *for that project*, not for your whole machine. Tools like
`mise`, `jenv`, or `SDKMAN` exist for exactly that.

The extra three lines are a safety check. If the lookup ever fails, `JAVA_HOME` is left
unset instead of being set to empty text. An unset note means "I don't know, figure it
out yourself," which programs handle sensibly. An empty note means "the Java
installation is located at: nowhere," which produces baffling errors.

### Change 3 — Homebrew setup

```diff
- eval (/opt/homebrew/bin/brew shellenv)
+ if not set -q HOMEBREW_PREFIX
+     /opt/homebrew/bin/brew shellenv fish | source
+ end
```

Two improvements.

*Native language.* `brew shellenv fish` asks Homebrew to write its instructions in fish's
own language directly, instead of writing them generically and translating with `eval`.
Fewer moving parts.

*The `if not set -q` check.* This means "only if this has not already been done."

Why it matters: Homebrew's setup **adds** its folder to the front of your PATH. If a
shell starts another shell (which happens more than you would think), the setup runs
again and adds it a second time. Then a third. Your PATH slowly fills with duplicates and
every command lookup gets slower.

`HOMEBREW_PREFIX` is a note Homebrew leaves behind. Child shells inherit their parent's
notes, so a nested shell sees "already done" and skips it.

### Change 4 — `fish_add_path` now uses `-g`

This is the sneaky one. See Part 6 for the full explanation — it needs its own section.

### Change 5 — Deleted a hidden, forgotten PATH entry

Also Part 6.

### Change 6 — Added `VISUAL`

```fish
set -gx VISUAL $EDITOR
```

Some programs read `EDITOR` to decide which text editor to open; others read `VISUAL`.
There is no logic to which does what — it is a historical accident. Setting both to the
same thing means every program behaves the way you expect.

### Change 7 — `reload` now restarts the shell properly

```diff
- alias reload="source ~/.config/fish/config.fish; ..."
+ alias reload="echo 'Reloading fish config! 🚀'; exec fish"
```

The old version **re-read** the config on top of your current session. That works for
adding things, but it cannot *remove* anything.

Concretely: delete a shortcut from your config, run the old `reload`, and the shortcut is
still there — because re-reading the file only adds instructions, it never undoes what
the previous run did. You would think your edit failed.

`exec fish` replaces your session with a completely fresh shell. Whatever the config says
now is exactly what you get.

### Change 8 — Moved the welcome-message setting into the config

Turning off fish's greeting was stored in a hidden system file rather than in your
config. On a new laptop, your dotfiles would not have reproduced it. Now they will.

### Change 9 — A warning comment

```fish
alias gnah="git reset --hard HEAD && git clean -fd"  # DESTRUCTIVE: discards all uncommitted work
```

Behaviour unchanged. This command permanently throws away every uncommitted edit, with no
undo. It deserves a label.

### Deliberately left alone

**`fnm` (your node version manager) stays inside the interactive guard.** This looks
inconsistent with Change 1, so here is the reasoning: every time `fnm` sets itself up, it
creates a small folder to track that specific shell. Running it for every invisible
background shell would create thousands of junk folders. Zed asks fish to behave
interactively anyway, so your editor still finds node correctly. The cost outweighs the
benefit here.

**All your shortcuts.** They are your personal preference and none were broken.

**The OrbStack line at the bottom.** Written by OrbStack itself; I confirmed it is valid.

**`~/.zshenv`.** I wrongly blamed this file in an earlier explanation. It is a config file
for zsh, a shell you do not use interactively. It was never involved in the bug. I left
it untouched.

---

## Part 6 — Fish's two kinds of memory

This deserves its own section because it caused a genuinely invisible problem.

Fish can store a setting in two different ways.

**Global** — lives only in the currently running shell. When the shell closes, it is
gone. Every new shell rebuilds it by reading your config. Your config file is the single
source of truth.

**Universal** — written to a hidden file on disk (`~/.config/fish/fish_variables`) and
shared by every fish shell, immediately, forever. It survives restarts.

Universal sounds better. It is usually worse, for one reason: **it is invisible.** It is
not in your config file, so it is not in git, and reading your config no longer tells you
the truth about your setup.

### What went wrong

The command `fish_add_path` defaults to **universal**. Your old config said:

```fish
fish_add_path $HOME/.cargo/bin
```

Your (very reasonable) comment read *"fish_add_path is smart: it won't add the same path
twice."* True — but it hid the fact that the folder was being written permanently to
that hidden file.

The consequence: **removing a line from your config does not remove the folder from your
PATH.** The line is gone; the hidden file still lists it; every new shell still loads it.
You would edit your config, see no change, and have no idea why.

### The proof

Your hidden file contained:

```
/opt/homebrew/opt/postgresql@16/bin
```

That folder appears **nowhere in your config**. It is a leftover from an old edit — you
removed the line at some point, but the hidden copy stayed, and PostgreSQL 16 has been
silently on your PATH ever since.

### The fix

Adding `-g` makes `fish_add_path` use global memory instead:

```diff
- fish_add_path $HOME/.cargo/bin
+ fish_add_path -g $HOME/.cargo/bin
```

Now each folder is added fresh on every shell start, straight from your config. Delete a
line, and it is genuinely gone.

I also **erased the hidden universal list**, which was necessary for the above to take
effect — otherwise the stale copy would keep being applied on top.

**Side effect you should know about:** this removed `postgresql@16` from your PATH. You
have both 16 and 18 installed, and 18 was already the one winning, so `psql` still works
exactly as before. If you ever need 16 back, add this line to your config:

```fish
fish_add_path -g /opt/homebrew/opt/postgresql@16/bin
```

---

## Part 7 — How to check any of this yourself

Useful commands, with what they answer.

**Which Java am I using right now?**
```
echo $JAVA_HOME
java -version
javac -version
```
All three should now say 21.

**Where does my shell look for programs?**
```
echo $PATH | tr ' ' '\n'
```
One folder per line, in search order.

**Which program actually runs when I type a name?**
```
command -v psql
```

**What does a program-started (non-interactive) shell see?** This is the test that
matters when a GUI app misbehaves:
```
fish -c 'echo $JAVA_HOME'
```

**What does an editor-style (login + interactive) shell see?**
```
fish -l -i -c 'echo $JAVA_HOME'
```

> **The key trick:** if those last two disagree, something is hiding behind the
> interactive guard. That single comparison would have found this bug in one minute.

**Reload after editing your config**
```
reload
```

---

## Part 8 — How to undo everything

All changes are in git, so nothing is permanent.

Undo the shell config only:
```
git -C ~/dotfiles checkout fish/config.fish
```

See exactly what changed:
```
git -C ~/dotfiles show
```

The one thing git cannot restore is the erased hidden variable list, because it never
lived in git. If you need PostgreSQL 16 back, use the `fish_add_path -g` line from
Part 6.

---

## Part 9 — What was verified

I did not just edit the file and hope. Checked after the change:

| Check | Result |
|---|---|
| Config has no syntax errors | passed |
| Program-started shell knows about Java | Java 21 — was **nothing** before |
| Editor-style shell knows about Java | Java 21 — was **Java 17** before |
| `java` and `javac` versions | both 21.0.5 — `javac` was 17.0.14 |
| All 7 of your folders on PATH | present |
| Duplicate PATH entries | none |
| Nested shells growing PATH | fixed |
| Shortcuts work when typing | yes |
| Shortcuts stay out of scripts | yes |

The `javac` line matters for your Crafting Interpreters project. Your notes say the
project targets Java 21, and Chapter 5 plans to use language features that only exist in
Java 21. Before this fix, your terminal was compiling with Java 17 and would have
rejected that code with confusing errors — while Zed showed no problem at all. Editor and
compiler now agree.

---

## Part 10 — One loose end for you

Your dotfiles repository tracks a file called
`zed/prompts/prompts-library-db.0.mdb/lock.mdb`. That is a database lock file belonging
to Zed — a temporary bookkeeping file that changes constantly on its own. It is committed
here because you asked me to commit everything, but files like this normally do not
belong in version control; they create noise in every commit.

If it becomes annoying, tell me and I will remove it from tracking and add it to
`.gitignore`. Not urgent.

---

## Summary in five sentences

1. Your config told every shell to use **Java 17**, but only when a human was typing.
2. Zed asked a shell what Java to use, got 17, and refused to start its Java support.
3. I removed the version pin so it now follows whatever the newest installed Java is.
4. I moved environment settings out of the "only if a human is typing" section, so
   programs and humans now get identical answers.
5. I switched PATH handling from hidden permanent storage to your config file, so what
   you read in the file is genuinely what you get.
