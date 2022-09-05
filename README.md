# Star Engine

A simple, modular, *cherry-pickable* framework for creating RPG-like games in [Godot Engine](https://godotengine.org/).
 
Star Engine is the engine used in my ([@mrpedrobraga](https://twitter.com/mrpedrobraga) game *'Inner Voices'*.
It contains components backported from it but made to be completely agnostic to it.

## The idea behind it

With Star Engine, you can use it entirely (with integration addons) OR cherry-pick which classes you want and copy those to your project -- many classes are built to work on their own, making this possible.

The framework contains:
- Classes for typically 'RPGish' things such as `DialogBox`, `SceneEvent`, `Character`, etc.
- General classes such for making games such as `Movement2D`, `ResourceMap`, `Menu`, `SpriteSheet`.
- Core classes for handling several aspects of your game such as Audio, Progression and Save/Load.

I created Star Engine inspired/in spite of RPG-making tools I used when I was little.
I found myself **empowered by them, being able to create something I couldn't otherwise**...

...then, whenever I wanted to implemented something the engine wasn't specifically built for -- no hope.
I'd have to hack it or fight against it.

Star Engine is **friendly** -- it gives you the possibility of making your game faster, but **doesn't stand in your way**.

**Ultimately, you have complete control of what happens in your game.**

Star Engine also **doesn't enforce controls, memory usage, visual style**. Most classes won't even have a visual representation, not even for examples, instead, templates will be on their own repository -- to save space.

You have classes and scenes for many cases, but you're not forced to use them.
And if you want different ones, you can extend and/or modify their code -- in fact, Star Engine invites you to extend classes for it to even work.

It is designed as a **Multi-level API**. This means you can choose to let Star do the work for you, but it's not ALL or nothing -- you can choose exactly how much and in which ways Star takes control. In programmin lingo, you have a steady chain from low-level to high-level that you can intercept anywhere.

And lastly, but not leastly(...?), it contains the beautiful StarScript -- a domain-specific language for writing dialogs for Star. 
Its parser is wonderfully generic, so you can add your own commands.

# How to use Star Engine

## Preparation

- First, you'll need Godot Engine and be basically acquainted to it.

> Note that Star Engine is built for Godot 4 (currently at alpha 15).

- You'll need to be learn GDScript.

> You can use any programming language you want, but Star classes are written in GDScript so it's good to learn it.
> 
> Don't worry, it's super easy.

## Download

Go to your project's folder and download the repository there inside a folder.

If you want to get updates quickly add it as a git submodule.
```bash
git submodule add https://github.com/mr-pedro-braga/star-engine-core.git <your_subfolder_name_of_choice>
```

> If you are unfamiliar with git, you should learn it.
> Please learn version control software.
> 
> You don't want to lose your game if your computer falls or gets wet.
> 
> This is the advice of someone who has been through many things...

## How to Use

There are four types of additions that Star provies.

- Components :: Add them to the scene tree, set them up with hierarchy and signals or use them with code. They do something to extend another Node's capabilities.
  - For example, the `Movement2D` gives movement to a `CharacterBody2D` keeping the movement script and your character scripts properly separated.
  - The `Menu` component, also, manages its own menu state and can be used to create menus easily -- but is visual-agnostic so you can create your own Menu handlers that use them.
- Classes :: Normal classes that you can use in code for various purposes -- `GameSaveData`, `ResourceMap`, they have one use and you use them if you need to.
- Cores :: Implementations of classes packaged together to create servers for typical situations -- `DialogCutsceneCore` handles calling Dialogs, `AudioCore` handles audio, etc.

You literally just pick which ones you want to use -> That's the meaning of *cherry-picking*.

For most Components and Classes there are no requirements -- just get the ones that are helpful and use them.

For Cores, however, you'll need to...

- Set up an implementation of `Game.gd` as a singleton named `Game`.

That's it!

## Workflow

I previously mentioned Star is a multi-level API. But what does that mean?

Let's suppose you want to add dialogues to your game.

### Level 0

You might use Godot's original tools to make it yourself.
You handle all of the dialogue code yourself.

### Level 1

Star conveniently provides `SmartRichTextLabel`.
It supports BBCode but also typewriting with special mid-text events such as pauses, waiting for inputs, or any generic events you might need.

```bbcode
Hey, I'm a[pause=3] dialogue! I am happy[expression=sad] and now I'm sad oh no.
```

You still have to call `write` on your dialog box for it to work.

### Level 2

Star provides a `DialogCutsceneCore` which handles dialogues for you.
As you assign one of it to the `Game` singleton, you can call `Game.DC.dialog( my_dialog )` from anywhere.

```gdscript
Game.DC.dialog( "Hey buckaroo, this is a dialogue!!!" )
```

No need to manually call dialogues or keep references to the dialogue box!

### Level 3

Star provides a `Shell` class to be extended.

When added as a singleton, it can be called from anywhere to `execute` sequences of commands.

Now, not only can you do several dialogues in succession, but intercept them with waiting, choices, or any arbitrary
commands you write your Shell to do.

For example, give an item to a character mid dialogue.

```gdscript
Shell.execute_block(
 [
  {"key": "dialog", "speaker": "claire", "content": "Can I get an apple?"},
  {"key": "item", "mode": "give", "target": "Claire", "item": "apple", "amount": 3},
  {"key": "dialog", "speaker": "claire", "content": "Thanks."},
 ]
)
```

This is very convenient... but, oh, yikes, this looks terrible. What a mouthful to write.
I had to write this passage for this very readme and it took me, what, 5 minutes?

### Level 4

```markdown
- claire : Can I get an apple?
item give claire apple 3
- claire : Thanks.
```

This is StarScript, a language made to interact with the Shell.
It gets parsed by `StarScriptParser` into a format you can easily read in the Shell.

Implementing your own commands in the shell is very worth it when you use StarScript.

But also, it comes with a dialogue syntax (- name :) that's very handy.

Sometimes, instead of writing in paper, I write my scenes directly in StarScript with
dialogues and comments -- then add the gamey commands later.

And not only can you write your commands as Strings...

```gdscript
var s: String = "give claire apple 3"
Shell.execute_block( s )
```
...but, with the integration addon, you can create `.ssh` files with StarScript in them.
Those files get parsed before in editor-time, before your game ever runs, so no parsing hiccups.

> You can also edit those files in an external editor, like, for example, VSCode, for which I just so happen to be writing a StarScript extension.

And since there's `StarScriptEvent` that calls a StarScript file when it's triggered in the world. This means after you code the base of your game, the level designer *may never need to touch GDScript.*

# Contributing

You can contribute by opening issues, pull requests (for solving issues), proposals...
You can also contribute by giving me money, with which I'll pay bills and be alive to make more things for Star Engine and other Star projects.

[Patreon not yet available]
Buy me a coffee : [https://ko-fi.com/mrpedrobraga]

In another, stranger, way, you can also contributing by sharing what you've built with Star.

I made this project for people, after all.

You see, anyone can pick up a game and draw.
Anyone can touch a drum and make music.

But games, one of the most powerful forms of art...
The medium that's a mix of visual, auditory, interactive media into one...

You need to be a programming expert to make them even run.
**It's such a miracle a single game gets released.**

So, the reason why I made this project is...

I want the bar for making games to be so low, that anyone will be able to put all of those creations that have been sitting on the back of their minds out in the world. Not necessarily to publish it, but just to... have it, play it, enjoy, send it to friends as a meme.

And most of the games won't win any awards -- but I believe there's something special in games made with heart.

Make games as little gifts for your friends,<br/>
Get something out of your chest and never show anyone ever,<br/>
Ask someone out on a date...<br/>

or idk, make the next AAA.

I'd love to see *that*.

Regards,
Pedro Braga.
