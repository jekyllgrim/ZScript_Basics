🟢 [<<< BACK TO START](README.md)

🔵[<< Previous: Classes instead of actors](Classes_instead_of_actors.md)

------

# Anonymous functions

- [Anonymous functions](#anonymous-functions)
- [Features of anonymous functions](#features-of-anonymous-functions)
  * [Using parentheses](#using-parentheses)
  * [Variables and conditions inside anonymous functions](#variables-and-conditions-inside-anonymous-functions)
  * [Jumps in anonymous functions](#jumps-in-anonymous-functions)
- [Flow control](#flow-control)

Arguably the first thing you need to get used to when coding in ZScript is anonymous functions. They're not, strictly speaking, necessary, but using them is the primary way to make your code cleaner and prettier.

Also, anonymous functions, technically, aren't a ZScript-only feature because they were introduced a little earlier than ZScript. But that was a brief period, and besides anonymous functions are not supported by Zandronum's version of DECORATE at all, so most of the DECORATE modders aren't closely familiar with this feature.

Technically, an "anonymous" function is a function without a name. In the context of ZScript/DECORATE it's a trick that allows you to combine a bunch of different functions together into one action, essentially creating a custom function on the spot. So, for example instead of this:

```csharp
TNT1 A 0 A_GunFlash
TNT1 A 0 A_Recoil(2)
TNT1 A 0 A_SpawnItemEx("EmptyCasing")
TNT1 A 0 A_FireBullets(5,5,1,8);
```

…You can do this:

```csharp
TNT1 A 0 
{
	A_GunFlash();
	A_Recoil(2);
	A_SpawnItemEx("EmptyCasing");
	A_FireBullets(5,5,1,8);
}
```

This way you're basically creating a custom function that calls `A_GunFlash`, `A_Recoil`, `A_SpawnItemEx` and `A_FireBullets` at once, with the parameters you provided.

And that’s much cleaner and more convenient for multiple purposes. 

# Features of anonymous functions

Here I'll briefly cover some of the points you need to be aware of when using anonymous functions. Please note, most of these will be covered in more detail later on in the guide, so don't worry if you can't immediately fully understand something. This section is mostly an outline what we'll be talking about later.

## Using parentheses

Let's take a look at the example above again:

```cs
TNT1 A 0 
{
	A_GunFlash();
	A_Recoil(2);
	A_SpawnItemEx("EmptyCasing");
	A_FireBullets(5,5,1,8);
}
```

Notice how we're calling `A_GunFlash()` and not `A_GunFlash`? Even though we're not using any arguments of the function, when it's called from inside an anonymous functions, you *have to* use the parentheses (aka round brackets).

In ZScript (as opposed to DECORATE) you can also do this when calling it *outside* of an anonymous function, but there it's optional:

```cs
// This is valid:
TNT1 A 0 A_GunFlash;

//This is also valid:
TNT1 A 0 A_GunFlash();
```

However, inside an anonymous function it's *not* optional:

```cs
// This is valid:
TNT1 A 0
{
	A_GunFlash();
}

// This is NOT valid and will not work!
TNT1 A 0
{
	A_GunFlash;
}
```

For simplicity's sake, you can simply use parentheses in all contexts, then you'll never make a mistake.

## Variables and conditions inside anonymous functions

Anonymous functions are independent code blocks. That means you can define variables in them and add extra conditions. This is covered in more detail further in the guide, but here's a simple example. Let's say you want to make your weapon deal more damage if the player has [PowerStrength](https://zdoom.org/wiki/Classes:PowerStrength) (the powerup given by Berserk). In DECORATE you would have to use `A_JumpIfInventory` shenanigans, but in ZScript you can use [`FindInventory`](https://zdoom.org/wiki/FindInventory) and an `if/else` block:

```cs
TNT1 A 0 
{
	A_GunFlash();
	A_Recoil(2);
	A_SpawnItemEx("EmptyCasing");
	if (FindInventory("PowerStrength"))
	{
		A_FireBullets(5,5,1,80);
	}
	else
	{
		A_FireBullets(5,5,1,8);
	}
}
```

As a result the weapon will fire and deal 80 damage if you have PowerStrength, and only 8 otherwise (aside from Doom's built in randomization, of course, which you can disable using `FBF_NORANDOM` flag—see [`A_FireBullets` on the wiki](https://zdoom.org/wiki/A_FireBullets)).

Conditions and other statements are covered in detail in the [Flow Control chapter](Flow_Control.md#conditional-blocks), and you will find more examples further in the guide as well.

You can also simplify the code above by using a variable:

```cs
TNT1 A 0 
{
	A_GunFlash();
	A_Recoil(2);
	A_SpawnItemEx("EmptyCasing");
	int dmg = 8; //define an integer variable 'dmg' equal to 8
	if (FindInventory("PowerStrength"))
	{
		dmg *= 10; //if PowerStrength is in inventory, multiply dmg by 10
	}
	A_FireBullets(5,5,1,dmg); //pass 'dmg' as the damage value to the attack function
}
```

If you're not familiar with variables, don't worry, they will be covered in the [Variables and Data Types](Variables_and_data_types.md) chapter and in other parts of the guide, so keep reading!

## Jumps in anonymous functions

This is a "beginner trap" of sorts: there are many A_Jump* functions covered on the wiki, such as [`A_JumpIfInventory`](https://zdoom.org/wiki/A_JumpIfInventory) or [`A_JumpIf`](https://zdoom.org/wiki/A_JumpIf), but if you try to use them directly inside an anonymous function, they simply don't work.

Let's say you have a monster with two separate attacks and you want it to randomly execute one or another. So, after it calls `A_FaceTarget`, you want it to either continue or jump to "Missile2" state sequence:

```cs
class ZombiemanWithTwoAttacks : Zombieman
{
	States
	{
	Missile:
		POSS E 10 
		{
			A_FaceTarget();
			A_Jump(128, "Missile2"); //But this doesn't seem to work...
		}
		POSS F 8 A_PosAttack;
		POSS E 8;
		goto see;
	Missile2:
		POSS F 8 A_Spawnprojectile("PlasmaBall");
		POSS E 8;
		goto see;
	}
}
```

...But it doesn't work; it never seems to fire that plasmaball.

To make jump functions work in anonymous functions, they need a `return` keyword:

```cs
class ZombiemanWithTwoAttacks : Zombieman
{
	States
	{
	Missile:
		POSS E 10 
		{
			A_FaceTarget();
			return A_Jump(128, "Missile2"); //Jumps to Missile2 with 50% chance
		}
		POSS F 8 A_Spawnprojectile("PlasmaBall");
		POSS E 8;
		goto see;
	Missile2:
		POSS F 8 A_PosAttack;
		POSS E 8;
		goto see;
	}
}
```

The reason for this is that anonymous functions are, well, functions, and they need to have a return value. That value is the next state they need to go to (which by default is simply the next state, i.e. the next frame in the state sequence). If that explanation made no sense, then for now you have to just remember that any sort of jump functions require a `return` keyword if they're used in an anonymous function.

It's also important to know that with anonymous functions using `A_Jump*` and other DECORATE methods is not actually the best approach. Instead of you can use `return ResolveState("Statename")`, which allows creating multiple conditional jumps. That, however, is explained in more detail in the [State Control section of the Flow Control chapter](Flow_Control.md#State-control).

# Flow control

The way conditional blocks are define and executed is referred to as "flow control." You don't need to learn everything about it right away, however, there's a whole separate chapter on this topic in this guide: [Flow Control](Flow_Control.md). I recommend keeping that chapter open while reading, so that you can consult it from time to time.

------

🔵 [>> Next: Variables and data types](Variables_and_data_types.md)