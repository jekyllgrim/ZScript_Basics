### [<<< Back to  start](Readme.md)

# Why ZScript?

Before talking about variables, pointers and classes it’s a good idea to answer this simple question: why use ZScript at all? What if you’ve been doing relatively simple things and DECORATE + occasionally ACS have been working out fine for you? Should you still switch?

You see, the question should actually be reversed. ZScript is now the default in GZDoom; DECORATE is deprecated (meaning it’s supported but will never be developed or updated further). So, you should ask yourself this: **are there any reasons why I would *not* use ZScript?** Let’s take a brief look.

**ZScript is harder**

That’s incorrect. ZScript is a *tool*, it can’t be "hard" or "easy" on its own. How complex your code will be depends entirely on you. When you get the hang of it, ZScript is ultimately much easier to work with than DECORATE simply because the resulting code is cleaner and easier to read (and thus easier to get help with, by the way).

But even if you're starting completely fresh and have no experience with DECORATE, ZScript will not be harder for you. Since ZScript fully *includes* DECORATE, they both have the same skill floor. Naturally, ZScript has a much higher skill ceiling, but how complicated your code will be depends on how you use it and what you do with it.

**I’m used to doing stuff in DECORATE**

And you don’t have to let that go! Well, there are *some* DECORATE habits that you’d better eventually say goodbye to, but in essence you have to understand this: **DECORATE is fully included into ZScript**. There are some very simple syntax differences (such as having to use semicolons at the end of most strings), but otherwise you can write code in ZScript the same way you would do it in DECORATE. In other words, if you can code in DECORATE, you can already code in ZScript.

**But if I’m going to write the same code I would in DECORATE, what’s the point of switching?**

When you start using ZScript, eventually there will come a point when you decide to use a more advanced feature or create a custom function (or maybe even somebody will create it for you), or some other ZScript-only method. Or you feel like incorporating a new feature in your mod only to be told "It's very easy in ZScript but impossible in DECORATE." And when that moment comes, if you’ve been writing your code in ZScript up until that point, you’ll just be able to plug that new shiny feature into it. Whereas, if you’ve been using DECORATE, you’ll have to first at least partially translate your code into ZScript, which is *easy* but also tedious and takes a long time, and definitely not something you’re gonna want to do when the time comes.

**I’ve done too much stuff in DECORATE already**

Switching mid-project can be difficult. But don’t fret! You don’t actually have to do that immediately.

First, DECORATE and ZScript can be combined within one pk3 just fine. (Not within one file, though; DECORATE and ZScript have to be placed separately inside the eponymous files.) In fact, you can even write a custom function in ZScript and then use it within a DECORATE actor. The only thing you have to consider is that DECORATE is loaded last, which means that DECORATE actors can inherit from ZScript ones, but not the other way around. Still, this means you don’t have to convert everything right away.

Second, converting your own stuff may be one of the best ways to learn. First you can do simple conversion where you port the code directly, only changing the syntax, then you’ll start poking here and there, optimizing and adding stuff. In no time you’ll know the basics of ZScript.

**But I’m using Zandronum!**

…Oh. That. Well, that can’t be helped, unfortunately. Personally, for me sacrificing the ability to use ZScript in favor of Zandronum features is not an option, hence I went GZDoom-only, but your approach may be different. However, as I’m writing this, Zandronum hasn’t updated in like 3 years. Even its DECORATE is an ancient version that doesn’t support simple things like FloatBobStrength.

 

In short, by using DECORATE you’re limiting yourself without gaining anything. 

Still, even if it’s obvious that using DECORATE is pointless, it’s a good idea to take a look at some advantages of ZScript.

**Real variables**

If you’ve used ACS you probably have an idea of how variables work; otherwise there’s a chapter on them further on. The point is, any mildly complex DECORATE code is filled with dummy items that you use to check for various stuff. In ZScript you don’t have to do that because you can store that information in real variables attached to classes.

**No duplicates**

Your DECORATE code is likely filled with duplicate actors that replace various things, or actors that are basically identical but use a different function somewhere. A simple example would be special effects, like light halos. In ZScript you can say goodbye to duplicates because you’ll have tools at your disposal that allow to make the actor change according to conditions instead of making multiple versions of that actor. Case in point: you can create a single light halo actor and change its color upon spawning.

You also won’t have to duplicate the same code into multiple places.

**Custom functions and properties**

You can create custom functions in ZScript. You can even give them any name and it doesn’t have to start with "A_". And then you can use those functions throughout the mod (and even in DECORATE code if you have any).

**Changing properties and flags on the fly**

In DECORATE you’re limited to "setter" functions such as A_SetScale or A_SetRenderstyle when you want to change a property, and A_ChangeFlag for flags; thus, you can’t change anything that there isn’t a setter for. 

In ZScript you can. You can (will need to in certain situations) use those setters in ZScript as well, but a good portion of properties can be changed at any point. For example, you can change the ammo type used by a weapon, or an actor’s size (height and radius). You can the majority of flags on the fly as well, altering actors’ behavior.

**Interaction with map data**

ZScript can obtain and even change certain map-related data. While there are some reasonable limits to this, you can create pretty interesting stuff with that, such as a projectile that bounces off surfaces at correct angles, or explosives that "destroy" certain doors.

**Reduced performance impact**

With ZScript you’ll have tons of tools at your disposal to make your stuff more efficient. Even if you don’t do anything special, when you just follow some good basic rules of syntax and [flow control](Flow_Control.md) (more on those later), your code will *already* work much faster than something similar would in DECORATE.



### [>> Next: Classes instead of actors](Classes_instead_of_actors.md)