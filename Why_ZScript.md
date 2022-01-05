### 🟢 [<<< BACK TO START](README.md)

------

# Why ZScript?

* [The times are changing](#the-times-are-changing)
* [So, why ZScript?](#so--why-zscript-)
* [The advantages](#the-advantages)



## The times are changing

Everyone is talking about ZScript. *DECORATE is dead*, they say. *You should be using ZScript*, they say. *I’m not gonna help you with your awful hacky DECORATE code,* they say.

You look around, confused. You’ve been using DECORATE for years now. You check ZDoom Wiki, and it’s still almost all about DECORATE. ZScript is barely documented. They tell you to look into ZScript code in gzdoom.pk3, and when you do, it makes your head spin. DECORATE is plain and simple, and with ZScript you don’t understand what’s going on at all.

Confusion leads to frustration, frustration leads to resentment. All the cool kids are playing with ZScript, and you don’t even know how and where to start. You wonder if your Doom modding career is over.

Sounds familiar?

That’s where lots of DECORATE users (some of them—known and respected modders even) have been finding themselves ever since ZScript became a thing. The reason is simple: ZScript is basically a programming language, and DECORATE has barely anything to do with that concept. As a result, there are *plenty* of people who’ve been doing just fine with DECORATE, and just a *handful* of people with previous programming experience who find it much easier to use ZScript. And it’s not surprising, ZScript *is* easier to use (more on that later) but it’s not easy for a non-programmer to begin.

I decided to write this short entry guide to help alleviate exactly that: it covers some basic programming concepts in simple terms which will help you to *get started*. Starting, after all, is the hardest part.



## So, why ZScript?

Before talking about variables, pointers and classes it’s a good idea to answer this simple question: why use ZScript at all? What if you’ve been doing relatively simple things and DECORATE + occasionally ACS have been working out fine for you? Should you still switch?

You see, the question should actually be reversed. ZScript is now the default in GZDoom; DECORATE is deprecated (meaning it’s supported but will never be developed or updated further). So, the question should be: **are there any reasons why I would *not* use ZScript?** Let’s take a brief look.



**Isn't ZScript harder?**

No. It's important to understand that DECORATE is not a separate coding language; DECORATE is a *subset* of ZScript. In other words, it's the same thing as ZScript, just significantly cut down in terms of features. 

ZScript and DECORATE have an identical set of basic features and nearly identical basic syntax. Since ZScript fully *includes* DECORATE, they both have the same skill floor. ZScript offers more features, but having more options doesn't make it harder to use, it just offers more *potential* options to achieve your goals. 

How complex your code will be, depends entirely on you. While you might've seen other people create some really complicated code, there's absolutely no reason for you to immediately start doing that. It's perfectly fine to code basic stuff, the same way you would do it in DECORATE.

Moreover, the more complicated is the stuff that you want to create, the *easier* ZScript becomes to use in comparison to DECORATE. There are plenty of examples where a specific system or a mechanic (for example, a universal bleeding system, like [the one I created in 2021](https://github.com/jekyllgrim/SimpleBleeding)) are trivial to implement in ZScript, but if you try to do them in DECORATE, you end up with very complicated, overly long code that is hard to read and debug. (And, obviously, on top of that there's a multitude of things that simply can't be done at all in DECORATE).



**I’m just used to doing stuff in DECORATE**

And you don’t have to let that go! Well, there are *some* DECORATE habits that you’d better eventually say goodbye to, but remember: DECORATE is a part of ZScript, it's not a separate language. There are some very simple syntax differences (such as having to use semicolons at the end of most strings), but otherwise you can write code in ZScript the same way you would do it in DECORATE. In other words, **if you can code in DECORATE, you by definition can already code in ZScript**.



**But if I’m going to write the same code I would in DECORATE, what’s the point of switching?**

When you start using ZScript, eventually there will come a point when you decide to use a more advanced feature or create a custom function (or maybe even somebody will create it for you), or some other ZScript-only method. Or maybe you'll feel like incorporating a new feature in your mod only to be told "It's very easy in ZScript but impossible in DECORATE." And when that moment comes, if you’ve been writing your code in ZScript up until that point, you’ll just be able to plug that new shiny feature right into it. Whereas, if you’ve been using DECORATE, you’ll have to first at least partially translate your code into ZScript, which is *easy* but also tedious and takes a long time, and definitely not something you’re gonna want to do when the time comes.



**I’ve done too much stuff in DECORATE already**

Switching mid-project can be difficult. But don’t fret! You don’t actually have to do that immediately.

First, DECORATE and ZScript can be combined within one pk3 just fine. (Not within one file, though; DECORATE and ZScript have to be placed in `decorate` and `zscript` files respectively.) In fact, you can even write a custom function in ZScript and then use it within a DECORATE actor. The only thing you have to consider is that DECORATE is loaded last, which means that DECORATE actors can inherit from ZScript ones, but not the other way around. Still, this means you don’t have to convert everything right away.

Second, converting your own stuff may be one of the best ways to learn. First you can do simple conversion where you port the code directly, only changing the syntax, then you’ll start poking here and there, optimizing and adding stuff. In no time you’ll know the basics of ZScript.



**But I’m using Zandronum!**

…Oh. Well, unfortunately Zandronum does not support ZScript (and even its DECORATE code base is significantly older than the one used in GZDoom). If it's important for you to have client/server functionality with an ability to drop in and out of games at any time, this can't be helped. However, if your project is not multiplayer-oriented, or using peer2peer multiplayer (which is very well supported by GZDoom) is enough for you, then I'd consider switching over to GZDoom.



##  The advantages

In short, by using DECORATE you’re limiting yourself without actually gaining anything in return. You're not making things easier for yourself and you're not getting access to any features (while losing access to many).

By now it should be clear that using DECORATE in GZDoom is pretty much pointless. But in addition to that it's a good idea to take a look at some advantages of ZScript.



**Real variables**

If you’ve used ACS you probably have an idea of how variables work; otherwise there’s a chapter on them further on. The point is, any mildly complex DECORATE code is filled with dummy items and a bunch of `A_JumpInventory` that you use to check for various stuff. In ZScript you don’t have to do that because you can store that information in real variables attached to classes.



**No duplicates**

Your DECORATE code is likely filled with duplicate actors that replace various things, or actors that are basically identical but use a different function somewhere. A simple example would be special effects, like light halos. In ZScript you can say goodbye to duplicates because you’ll have tools at your disposal that allow to make the actor change according to conditions instead of making multiple versions of that actor. Case in point: you can create a single light halo actor and change its color upon spawning.

You also won’t have to duplicate the same code into multiple places just because you need the same actor to replace multiple vanilla actors.



**Custom functions and properties**

You can create custom functions in ZScript. (You can even give them any name and it doesn’t have to start with "A_", if you like.) And then you can use those functions throughout the mod (and even in DECORATE code, if you have any).



**Changing properties and flags on the fly**

In DECORATE you’re limited to "setter" functions such as `A_SetScale` or `A_SetRenderstyle` when you want to change a property, and `A_ChangeFlag` for flags; thus, you can’t change anything that there isn’t a setter for. 

In ZScript you can. You can (will need to in certain situations) use those setters in ZScript as well, but a good portion of properties can be changed at any point. For example, you can change the ammo type used by a weapon, or an actor’s size (height and radius). You can change the majority of flags on the fly as well, altering actors’ behavior.



**Interaction with map data**

ZScript can obtain and even change certain map-related data. While there are some reasonable limits to this, you can create pretty interesting stuff with that, such as a projectile that bounces off surfaces at correct angles, or explosives that "destroy" certain doors.



**Reduced performance impact**

With ZScript you’ll have tons of tools at your disposal to make your stuff more efficient. Even if you don’t do anything special, when you just follow some good basic rules of syntax and [flow control](Flow_Control.md) (more on those later), your code will *already* work much faster than something similar would in DECORATE.

------

🔵 [>> Next: Classes instead of actors](Classes_instead_of_actors.md)