### [<<< Back to  start](README.md)

[<< Previous: Variables and data types](Variables_and_data_types.md)

# Pointers and casting

## Basic pointers

One of the primary concepts you need to have a good grasp on to use ZScript is pointers. A **pointer** is, in essence, a type of variable that gives you *access* to something—usually an actor. 

DECORATE actually has pointers! But you are limited to using three of them: **master, target** and **tracer**. You’re probably familiar with them, but here’s a quick recap:

- `Target` is the most common pointer and it’s automatically used by monsters and projectiles:
  - In case of **monsters** a target is literally their current target—the actor they’ll be chasing and attacking (if there is one). Monsters acquire a target by calling `A_Look`, then chase it with `A_Chase`, and they aim at the target with `A_FaceTarget`.
  - In case of **projectiles** a `target` is (counter-intuitively) the **shooter** of the projectile. So, if it’s a player-spawned projectile, the player pawn will be its target. Why is it even tracked? Because the shooter has to get **kill credit**: it allows the game to track how many monsters the player killed, who killed whom in multiplayer, and print out obituary messages (such as "*Playername* stood in awe of Spider demon"). If for some reason the projectile loses its `target` pointer (which normally shouldn’t happen), the killer won’t get the credit. (There are other more obscure mechanics involved; for example, a projectile can’t hit its shooter as long as the shooter is the projectile’s `target`).
    - *Note*: if you’re wondering if a projectile has any pointer to its actual target, i.e. the monster that it'll hit, the answer is no. Projectiles don’t need pointers to actors they hit because they simply hit whatever they collide with. (They do get a pointer to what they hit briefly when the hit happens, but you can't access it in DECORATE; more on that later.)
- `Tracer` pointer is normally only used by seeker projectiles, such as **RevenantTracer**. Projectiles using seeking functions such as `A_Tracer` or `A_SeekerMissile` continuously face their tracer to change their direction towards it.
- `Master` pointer is not set by anything in vanilla Doom, but you might’ve set it yourself via `A_SpawnItemEx` which allows setting pointers manually via flags (`SXF_SETMASTER` in this case).

Pointers in DECORATE can be set manually mostly with `A_SpawnItemEx` by using the function’s flags. Doing this, you get access to functions such as `A_KillMaster` or `A_RemoveChildren` and such, which allow killing/removing actors from another actor that has a pointer to them. `A_FaceTarget` is also a common example of a function that interacts with a pointer, making the actor face its target (if it has one).

## Using pointers in ZScript

In ZScript pointers are much more flexible. The first difference is how you use them: you can use them as prefixes for calling functions and setting properties on a specific actor. For example, doing alpha = 0.5; will change the translucency of the actor that calls this code, but doing master.alpha = 0.5; will change the alpha of the actor’s master. 

You can use the same syntax to call functions on a specific actor from another actor, like so:

```csharp
Class GraciousImp : DoomImp {
	states {
	Death:
		TNT1 A 0 {
			if (target != null)					//checks that target exists before doing anything
				target.GiveInventory("Shell",20); //if so, give it 20 shells
		}
		goto super::Death;
	}
}
```

This gracious Imp gives the target some shells when it dies (hence, if you killed it, it'll be you).

*Notes on the example:*

- `if (target != null)` checks if `target` exists. This is called **null-checking** (because it checks if a pointer isn't null), and you *have* to do it before trying to call anything on the `target`. 

  - If you don't do the null-check, and for some reason the actor doesn't exist (in this case it can happen when the target is already dead), the game will close with an error (this is known as a **VM abort**).
  - You can simplify this check to `if (target)` — it'll work the same way.

- `GiveInventory` is an internal ZScript version of `A_GiveInventory` and it works basically the same way.

- You might've noticed there are no curly braces after around the **target.GiveInventory** block. You can do that when there’s only **one line** after the condition. However, if there are 2 or more lines, you can’t do that:

  ```csharp
  //this is OK:
  if (target) {
  	target.GiveInventory("Shell",20);
  }
  
  //this is also OK and will do the same thing:
  if (target)
  	target.GiveInventory("Shell",20);
  
  //this is OK:
  if (target) {
  	target.GiveInventory("Shotgun",1)
  	target.GiveInventory("Shell",20);
  }
  
  //THIS IS NOT OK!
  if (target)
  	target.GiveInventory("Shotgun",1)
  	target.GiveInventory("Shell",20); //this will ignore the null-check
  ```

  

Now let's make something more advanced. We'll use a tracer pointer that is normally not used by monsters. But first, to make it a bit more colorful, we'll create a TRNSLATE lump and add some translations:

**TRNSLATE:**

```csharp
//a desaturated color translation that tints the actor red:
BabyAngry = "0:255=%[0.85,0.00,0.00]:[2.00,1.96,1.39]" 

//a similar translation but it tints the actor blue:
BabyCalm = "0:255=%[0.05,0.01,0.84]:[1.39,1.96,2.00]"
```

 

**ZSCRIPT:**

```csharp
//This is a smaller version of Cacodemon that has x2 health and is blue:
Class CacoBaby : Cacodemon {
	Default {
		health 800;
		radius 16;
		height 30;
		speed 12;
		floatspeed 6;
		scale 0.5;
		Translation "BabyCalm";			//translation as defined in TRNSLATE lump
	}
}

Class CacoDaddy : Cacodemon {
	states {
	Spawn:
		//spawn Cacobaby: SXF_ISTRACER will make it CacoDaddy's tracer
		TNT1 A 0 NoDelay A_SpawnItemEx("Cacobaby",64,flags:SXF_ISTRACER);	
		HEAD A 10 A_Look;
		wait;	//loops the last frame instead of the whole state, in contrast to loop
	Death:
		TNT1 A 0 {
			if (tracer) {							//null-check tracer
				tracer.A_PlaySound("caco/active");	//play Cacodemon "wake up" sound on tracer
				tracer.A_SetTranslation("BabyAngry");//change translation, as defined in TRNSLATE
				tracer.speed *= 2;					//multiply tracer's speed by 2 
				tracer.floatspeed*= 1.5;			//multiply tracer's floatspeed by 1.5
				tracer.bNOPAIN = true;				//set tracer's NOPAIN flag to true
			}
		}
		goto super::Death;							//continue to default Cacodemon death
	}
}
```

[^*Note*]: Don't forget that you have to use **NoDelay** if you want to do something in the very first frame of the Spawn state. Otherwise Doom skips that function.

The daddy Caco spawns a baby Caco when it appears, and makes the baby its `tracer`. When the daddy dies, it checks if its `tracer` still exists, and if so, does a bunch of stuff **on the** **tracer**: plays a sound, changes its `translation` and `speed`, and removes its ability to enter Pain state. The baby is out for blood.

We use `tracer.` as a prefix to execute functions on it and change its properties. As mentioned earlier, **it's very important to null-check all pointers you use** to avoid the risk of causing a VM abort. A simple example why it could happen here is that the daddy spawns its baby 64 units in front of itself; if the daddy Caco is initially placed facing some other actor or a wall, it won't spawn the baby at all (because `A_SpawnItemEx` checks for free space before spawning something).

## Casting and custom pointers

But casting and custom pointers is where the actual fun begins. **Casting** is creating a variable and attaching something to it (usually an instance of an actor). In other words, casing basically means creating a custom pointer. There are two main cases when you need to use casting:

- To create a custom pointer that doesn't take place of `master`, `target` or `tracer`. As I mentioned earlier, you should avoid using these pointers when you can, since there's a lot of implicit behavior attached to them (for example, monsters will target their attacks at their `target` pointer).
- To get access to **class-specific variables**, which includes your custom variables. This concerns any custom variables you may have created as well

First, creating the pointers. Just like any variables, they can be class-wide or local. Let's modify our daddy Cacodemon slightly:

```csharp
Class CacoDaddy : Cacodemon {
	actor baby;	//create a variable baby (notice its type is actor)
	states {
	Spawn:
		TNT1 A 0 NoDelay {
			baby = Spawn("CacoBaby",pos);	
		}
		HEAD A 10 A_Look;
		wait;
	Death:
		TNT1 A 0 {
			if (baby) {
				baby.A_PlaySound("caco/active");
				baby.A_SetTranslation("BabyAngry");
				baby.speed *= 2; 
				baby.floatspeed*= 1.5;
				baby.bNOPAIN = true;
			}
		}
		goto super::Death;
	}
}
```

*Notes on the example:*

- `Spawn("actorname",position)` is a ZScript function that simply spawns something at the coordinates you provide. The position is a `vector3`.
- `pos` is a vector3 expression that simply contains the actor's own coordinates. We use it as a second argument of `Spawn` to spawn CacoBaby at CacoDaddy's position.

The behavior barely changes, but we're now using a custom pointer baby instead of pre-existing tracer. This frees up the tracer pointer to be used somewhere else (perhaps by one of the existing functions, who knows). 

What exactly happens: `baby = Spawn("CacoBaby",pos)` spawns an actor named CacoBaby at the position `pos` (CacoDaddy's position) *and* casts CacoBaby to the variable `baby`. 

You may wonder why we're not using `A_SpawnItemEx` here. That's because ZScript `Spawn` function not only spawns an actor but also tells us what actor was spawned—as a result, we can immediately cast it to the variable. `A_SpawnItemEx`, however, spawns an actor but does not return any data. (See [Custom Functions](Custom_Functions.md) to learn more about return values.)

One minor downside is that `Spawn` uses global offsets, not relative, so we can't spawn CacoBaby 64 units in front of CacoDaddy. But that's not a problem, since we can spawn it and then immediately move it using `Warp` (a ZScript function similar to `A_Warp`):

```csharp
Spawn:
	TNT1 A 0 NoDelay {
		baby = Spawn("CacoBaby",pos);
		if (baby)			//don't forget to immediately null-check the pointer!
			baby.Warp(self,64,0,0); //moves the spawned baby 64 units in front of self (CacoDaddy)
	}
	HEAD A 10 A_Look;
	wait;
```

[^*Note*]: For this simple example, we're not checking the position here at all, so if CacoDaddy was in front of a wall, the baby can end up inside a wall.

`Self`, as you probably already guessed, is a pointer to the current actor; since we're calling this from CacoDaddy, `self` is CacoDaddy. The full syntax for `Warp` is **Warp(pointer, xoffsets, yoffsets, zoffsets)**, and the offsets are relative, just like with `A_Warp`, so we move the spawned baby 64 units in front of `self` (CacoDaddy).  (`Self` is an existing pointer, you don't need to define or cast it.)

 

Now, we can go even further with this. Instead of using two different actors, we can use only one and modify it on the fly to make it look different:

```csharp
//don't try to use 'replaces Cacodemon', or they'll be spawning each other continuously:
Class CacoSingleDad : Cacodemon { 	
	actor baby;
	states {
	Spawn:
		TNT1 A 0 NoDelay {
			baby = Spawn("Cacodemon",pos);
			if (baby) {
				baby.Warp(self,64,0,0);
				baby.A_SetHealth(800);
				baby.A_SetSize(16,30);
				baby.speed = 12;
				baby.floatspeed = 6;
				baby.A_SetScale(0.5);
				baby.A_SetTranslation("BabyCalm");
			}
		}
		HEAD A 10 A_Look;
		wait;
	Death:
		TNT1 A 0 {
			if (baby) {
				baby.A_PlaySound("caco/active");
				baby.A_SetTranslation("BabyAngry");
				baby.speed *= 2; 
				baby.floatspeed*= 1.5;
				baby.bNOPAIN = true;
			}
		}
		goto super::Death;
	}
}
```

[^*Note*]: Some properties, such as `speed` can be set directly on an actor, but others are read-only and require a "setter" function, such as `A_SetSize`. If you try to modify something, but GZDoom tells you that "expression must be a modifiable value", this often means you can't modify that value directly, look for a setter function.

By doing the above, we spawn the baby Cacodemon and immediately set all of properties: `health`, `speed`, `translation`, etc. Obviously, now you can't use this CacoSingleDad to directly replace Cacodemons, because if you do that, you'll end up with an endless cycle of CacoSingleDads spawning each other. There are several ways we could go around it. For example, we could do this in Spawn:

  ```csharp
Spawn:
	TNT1 A 0 NoDelay {
		if (!master) {	//the following block will only execute if the actor does NOT have a master
			baby = Spawn("Cacodemon",pos);
			if (baby) {
				baby.master = self;	//we set the spawning actor as the master of the spawnee
				baby.Warp(self,64,0,0);
				baby.A_SetHealth(800);
				baby.A_SetSize(16,30);
				baby.speed = 12;
				baby.floatspeed = 6;
				baby.A_SetScale(0.5);
				baby.A_SetTranslation("BabyCalm");
			}
		}
	}
	HEAD A 10 A_Look;
	wait;
  ```

 …But while this method *can* be useful in certain situations, in this case we can do it much simpler:

```csharp
Spawn:
	TNT1 A 0 NoDelay {
		baby = Spawn("Cacodemon",pos,NO_REPLACE);
		if (baby) {
			baby.Warp(self,64,0,0);
			baby.A_SetHealth(800);
			baby.A_SetSize(16,30);
			baby.speed = 12;
			baby.floatspeed = 6;
			baby.A_SetScale(0.5);
			baby.A_SetTranslation("BabyCalm");
		}
	}
	HEAD A 10 A_Look;
	wait;
```

`NO_REPLACE` flag of the `Spawn` function spawns an actor, blocking attempts to replace it. This is what `BossBrain` in Icon of Sin uses to spawn Rocket explosions that always look the same even if a mod replaces the Rocket actor.

Actually, let's take a look at that! (Don't worry that you don't understand all of it, it's a bit advanced)

```csharp
private static void BrainishExplosion(vector3 pos)	//defines a function for BossBrain to use
{
	Actor boom = Actor.Spawn("Rocket", pos, NO_REPLACE); //spawns a Rocket and cast it to boom
	if (boom)
	{
		boom.DeathSound = "misc/brainexplode";			//changes rocket explosion sound
		boom.Vel.z = random[BrainScream](0, 255)/128.;	//randomizes vertical velocity
		boom.SetStateLabel ("Brainexplode");		//sets Rocket to speical Brainexplode state
		boom.bRocketTrail = false;					//disables rocket trail used in GZDoom
		boom.SetDamage(0);							//disables collision since it's not needed
		boom.tics -= random[BrainScream](0, 7);		//changes duration of the frames randomly
		if (boom.tics < 1) boom.tics = 1;			//makes sure duration isn't less than 1
}
```

There's a lot of stuff in this example we haven't covered yet, like creating custom functions, but now you should be able to mostly understand what's happening: the function creates a rocket, changes its explosion sound, disables rocket trail and damage and slightly randomizes its animation speed. On the whole, Icon of Sin's death effect is more complicated than that (and it only works at specific map coordinates, by the way), but you get the gist.

## Type casting

There's one other case of casting that you'll need to use when working with classes that use custom variables or functions. 

Let's say we want to make a version of Baron of Hell that drops a big Soulsphere when it's killed: this Soulsphere should set our health to 300 instead giving 100 HP limited to 200. Of course, we could create a new Soulsphere actor, but since we now know about casting, we try do this:

```csharp
//Doesn't actually work:
Class PrinceOfHell : BaronOfHell {
	states {
	Death:
		TNT1 A 0 {
			actor orb = Spawn("Soulsphere",pos);
			if (orb) {
				orb.amount = 300;
				orb.maxamount = 300;
				orb.pickupmessage = "Overcharge!";
				orb.scale = (1.5,1.5);
			}
		}
		goto super::death;
	}
}
```

But if you run the code above, you'll get "Unknown identifier" script errors about `amount`, `maxamount` and `pickupmessage`.

The reason is simple: we're casting Soulsphere as **actor**, but properties like `amount` and `maxamount` are *not* defined in the `Actor` class; they're actually defined in the `Inventory` class. To avoid the error that, we need to cast it explicitly as `Inventory`. And this is what's called **type casting**:

```csharp
//this will work:
Class PrinceOfHell : BaronOfHell {
	states {
	Death:
		TNT1 A 0 {
			inventory orb = Inventory(Spawn("Soulsphere",pos));
			if (orb) {
				orb.amount = 300;
				orb.maxamount = 300;
				orb.pickupmessage = "Overcharge!";
				orb.scale = (1.5,1.5);
			}
		}
		goto super::death;
	}
}
```

In this case inventory orb creates a variable orb of type `Inventory`, then casts it to an `Inventory` class and spawns it. You'll need to use this method whenever you're trying to get access to variables, properties and functions defined only for a specific class. 

You can simplify type casting by using the word `let`:

```csharp
let orb = Inventory(Spawn("Soulsphere",pos));
```

`Let` automatically sets the variable's type to what you're casting it to: in example above `orb` will automatically be cast to `Inventory`. Usually there's no reason not to use that, since it's very convenient, but manually specifying the variable type arguably makes the code more readable: you'll be able to immediately tell what type it is.



You'll need to use type casting for your own custom actors and their functions as well. Let's take a more advanced example: say, you created a sprite light halo and you want to attach it to torches. You have 3 versions of a halo (red, green, blue) and you don't want to define separate actors for each; instead you want to have only one actor and you want it to change its color depending on which torch spawned it. You can do this:

--- TO DO ---



### [>> Next: Custom functions](Custom_functions.md)