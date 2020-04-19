# Virtual functions

`Virtual` is a keyword that makes a function overridable. You can add it before the type of the function when defining it:

```csharp
virtual void MyCoolFunction()
```

There are two primary uses for it.

First, you can apply it to your own functions, like so:

```csharp
Class CacoSingleDad : Cacodemon {
	actor baby;
	virtual void SpawnBaby() {
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
}

Class SomeOtherCaco : CacoSingleDad {
	override void SpawnBaby() {
		actor a = Spawn("Cacodemon",pos,NO_REPLACE);
		if (a)
			a.master = self;
	}
}
```

**SomeOtherCaco** above completely redefines `SpawnBaby` function to do something else: it also spawns a Cacodemon but it doesn't attach it to `baby` pointer; instead assigns SomeOtherCaco as the spawned Caco's master. So, SomeOtherCaco can still use the same function, but the effect of the function will be entirely different.

However, this doesn't seem especially useful, does it?

What is done more commonly with virtual functions is that they're overridden not to replace their contents, but rather to *add* some stuff to what they normally do:

```csharp
Class CacoSingleDad : Cacodemon {
	actor baby;
	virtual void SpawnBaby() {
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
}

Class SomeOtherCaco : CacoSingleDad {
	override void SpawnBaby() {
		super.SpawnBaby();			//calls the original SpawnBaby() first
		if (baby) {
			baby.A_SetScale(0.4);
			baby.master = self;
		}
	}
}
```

`Super` is a pointer to the original function. In the example above SomeOtherCaco *first* does everything the original `SpawnBaby()` function does, and after that it adds some changes: it modifies the spawned baby's `scale` and sets itself as the baby's `master`.

## ZScript Virtual Functions

While **virtual** is just a type of function, the one that you can even use yourself (as described above), much more often you'll be using (overriding) the existing virtual functions.

The base **Actor** class has a lot of virtual functions attached to it which it calls under certain conditions *outside* of states. Overriding them allows to add a bunch of effects to your actors that don't have to (or can't) be bound to a specific state.

One of the most common virtuals you'll be using this way is `Tick()`: a virtual function that is called by all actors every game tick. It performs everything actors need to do continuously: changes positions, velocity, checks for collision and a bunch of other things. You can add your own effects into that function:

```csharp
Class TemporaryZombieman : Zombieman {
	Default {
		renderstyle 'Translucent';
	}
	override void Tick() {
		super.Tick();	//don't forget to call this! otherwise your actor will be frozen and won't interact with the world
		A_FadeOut(0.01);
	}
}
```

This Zombieman will continuously (and relatively quickly) fade out as it exists. Notice that we don't need to redefine any states for this effect. Neat!

Remember that `Tick()` is called even while the game is paused, so you should add a check for that:

```csharp
Class TemporaryZombieman : Zombieman {
	Default {
		renderstyle 'Translucent';
	}
	override void Tick() {		
		super.Tick();
		if (!isFrozen())
			A_FadeOut(0.01);
	}
}
```

Notes:

- `IsFrozen()` is a ZScript bool that returns `true` if the actor that calls it is currently frozen, which can happen when:
  - the game is paused (by opening main menu, console or pressing Pause in single player);
  - "freeze" cheat ahs been entered in the console;
  - the player has a PowerTimeFreezer powerup and the actor in question does *not* have a NOTIMEFREEZE flag.
-  `!` means "not", it's used to invert any check. `if (!isFrozen())` is the same as `if (IsFrozen() == false)`.



There's a ton of things you can do this way. A common example when using Tick() is convenient is when your actor needs to continuously spawn some sort special effect every tick (such as a trail or an after-image). Here's a handy example of doing an after-image this way:

```csharp
Class BlurryCacoBall : CacoDemonBall {
	override void Tick() {
		super.Tick();
		if (isFrozen())		//check if the actor is frozen
			return;			//if so, we stop here and don't do anything else
		actor img = Spawn("CacoBall_AfterImage",pos);	//spawn after image and cast it
		//transfer current actor's alpha, renderstyle and sprite frame to the spawned after-image
        if (img) {
			img.A_SetRenderstyle(alpha,GetRenderstyle());
			img.sprite = sprite;
			img.frame = frame;
        }
	}
}

Class CacoBall_AfterImage : Actor {
	Default {
		+NOINTERACTION //makes this actor non-interactive (no gravity or collision)
	}
	states {
	Spawn:
		#### # 1 {	//#### # means "use previous sprite & frame" (as set by BlurryCacoBall earlier)
			A_FadeOut(0.05);
			scale *= 0.95;
		}
		loop;
	}
}
```

