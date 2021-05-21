🟢 [<<< BACK TO START](README.md)

🔵 [<< Previous: Custom functions](Custom_functions.md)

------

# Virtual functions

`Virtual` is a keyword that makes a function overridable. You can add it before the type of the function when defining it:

```csharp
virtual void MyCoolFunction()
```

There are two primary uses for it. First, a child class can override its parent's virtual function and make it do something else:

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

**SomeOtherCaco** above completely redefines `SpawnBaby` function to do something else: it also spawns a Cacodemon but it doesn't attach it to `baby` pointer; instead assigns SomeOtherCaco as the spawned Caco's master. So, SomeOtherCaco can still call the same function, but the effect of the function will be entirely different.

However, this doesn't seem especially useful, does it?

What is done more commonly with virtual functions is that they're overridden not to *replace* their contents, but rather to *add* some stuff to what they normally do:

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

`Super` is a pointer to the parent class, and using it like that makes it call the parent's version of the function. As a result, in the example above SomeOtherCaco *first* does everything the original `SpawnBaby()` function does, and after that it adds some changes: it modifies the spawned baby's `scale` and sets itself as the baby's `master`.



## ZScript Virtual Functions

While **virtual** is just a type of function, the one that you can even use yourself (as described above), much more often you'll be using (overriding) the existing virtual functions.

The base **Actor** class has a lot of virtual functions attached to it which it calls under certain conditions *outside* of states. Overriding them allows to add a bunch of effects to your actors that don't have to (or can't) be bound to a specific state.

One of the most common virtuals you'll be using this way is `Tick()`: a virtual function that is called by all actors every game tic. It performs everything actors need to do continuously: changes positions, velocity, checks for collision and a bunch of other things. You can add your own effects into that function:

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

Remember that `Tick()` is called even when the actor is frozen, so normally you need to add a check for that:

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
  - "freeze" cheat has been entered in the console;
  - the player has a PowerTimeFreezer powerup and the actor in question does *not* have a NOTIMEFREEZE flag;
  - naturally, there can be other scripts that for whatever reason freeze actors.
-  Boolean checks such as `if (bool == true)` can be shortened to `if (bool)`. And `!` means "not" and cab be used to invert any check. `if (!isFrozen())` is the same as `if (IsFrozen() == false)`.



There's a ton of things you can do this way. A common example when using Tick() is convenient is when your actor needs to continuously spawn some sort special effect every tick (such as a trail or an after-image). Here's a handy example of doing an after-image this way:

```csharp
Class BlurryCacoBall : CacoDemonBall {
	override void Tick() {
		super.Tick();
		if (isFrozen())		//check if the actor is frozen
			return;			//if so, we stop here and don't do anything else
		actor img = Spawn("CacoBall_AfterImage",pos);	//spawn after-image and cast it
	//transfer current actor's alpha, renderstyle and sprite frame to the spawned after-image
        if (img) {
			img.A_SetRenderstyle(alpha,GetRenderstyle());
			img.sprite = sprite;	//sprite is the current sprite, such as "BAL2"
			img.frame = frame;		//frame is a frame letter, such as A, B, C
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

The result is a pretty cool trail that is very easy to implement: notice, we didn't have to edit the states of BlurryCacoBall *at all*. 

This principle applies to most virtual functions. Here's another example with `PostBeginPlay()`, a function that is called as soon as the actor is spawned and placed in the world but before its Spawn state starts:

```csharp
//pseudocode:
Class MyActor : Actor {
	int myvalue;
	override void PostBeginPlay() {
		super.PostBeginPlay();
		myvalue = 10;
	}
}
```

As explained earlier, when you declare class-scope variables, like `myvalue` above, you can't immediately give them a value. You either have to turn it into a property, or set that value somewhere. `PostBeginPlay()` is a good place to do that. Notice, that `PostBeginPlay()` is not like `Tick()`: it's called only once, so there's no need to check if the actor is frozen. If your actor has some sort of an attached "companion" actor (for example, a fireball that spawns an actor-based light flare around itself), it's also a good place to spawn them.



There are many, many other virtual functions that you will need to override. And remember: you won't always need to call **super** on them; sometimes you'll need to completely fill in what the function does, without calling its original version. Let's take a quick look at `ModifyDamage()` — an **Inventory** function used by protective items such as PowerProtection (a power-up that reduces incoming damage). This function gets the damage that is supposed to be dealt to the owner of the item, and then uses `newdamage` argument to tell the game how much damage to actually deal:

```csharp
Class CustomProtection : Inventory {
	Default {
		inventory.maxamount 1;
	}
	
	override void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor = null, Actor source = null, int flags = 0) {
        //check if the inflictor has a MISSILE flag:
		if (inflictor.bMISSILE) {
			newdamage = damage * 0.5;
		}
		//otherwise check if the inflictor has ISMONSTER but not FRIENDLY, and is alive:
		else if (inflictor.bISMONSTER && !inflictor.bFRIENDLY && inflictor.health > 0) {
			newdamage = damage * 0.1;
		}
	}
}
```

The overridden `ModifyDamage()` above first checks the source of the damage: whether it a missile or a monster itself (i.e. a monster's melee attack). For missiles the damage will be cut in half, while for monsters it'll be reduced by 90%.

`ModifyDamage()` gets a bunch of pointers, and we use them to decide what to do. Inflictor is an actor pointer to the object that dealt the damage directly (projectile, puff or a monster in case of a melee attack).



Notice that both `Tick()` and `PostBeginPlay()` are **void** functions (they have no return value) and they have no arguments.` ModifyDamage()` has arguments but it's also a void function. But that's not true for all virtual functions. 

A good example of that is `SpecialMissileHit()` — an integer function that is called by projectiles when they collide with an actor. When a projectile collides with an actor, it calls `SpecialMissileHit()`, which returns an integer number that tells the projectile what to do: 

- `-1` (default) will make the projectile do what it does normally (explode, rip through if it has +RIPPER flag, etc.); 
- `1` will make the projectile pass through the actor (it doesn't need a +RIPPER flag for that, it'll simply fly through instead of colliding);
- `0` will destroy the projectile (remove it completely without doing anything else).

This function is used in Hexen by MageStaffFX2—a homing projectile fired by Bloodscourge, the most powerful Mage weapon:

```csharp
//you can find this code in gzdoom.pk3/zscript/actors/hexen/magestaff.zs

override int SpecialMissileHit (Actor victim)
{
	if (victim != target && !victim.player && !victim.bBoss)
	{
		victim.DamageMobj (self, target, 10, 'Fire');
		return 1;	// Keep going
	}
	return -1;
}
```

Notice that `SpecialMissileHit()` also gets a pointer `victim` of type actor: this is a pointer to the actor that the projectile touches (and then the virtual function decides whether it should explode or do something else). 

In the example above the projectile does the following:

1. Checks that the `victim` isn't the `target` (shooter of the projectile*), or a player (any player) or a boss (has +BOSS flag)
   1. *If you wonder why you need to check if the projectile didn't hit the shooter—it's because when spawned, projectiles basically spawn "inside" the player and they *will* collide with them, unless this check is added.
2. If all checks pass, it deals damage to the victim by calling `DamageMobj()` function (see below) and keeps going.
3. Otherwise (i.e. If the victim is the shooter, *or* a player, *or* a boss), the projectile explodes.



As you can see, virtual functions are already attached to actors, and you can mix your own stuff into them to add various effects. However, you can also *call* them just like you call regular actor functions. A common example of a function that you may often need to both override and call is `DamageMobj()`:

**int DamageMobj (Actor inflictor, Actor source, int damage, Name mod, int flags = 0, double angle = 0)**

Called by the actor whenever it takes damage.

- **inflictor** - The actor pointer dealing the damage. Missiles are used here, with their owners being the *source*.
- **source** - The actor pointer which claims responsibility for the damage, responsible for causing infighting.
- **damage** - The amount of damage to deal out.
- **mod** - The 'means of death', or the damagetype.

(See the rest [on ZDoom wiki](https://zdoom.org/wiki/ZScript_virtual_functions#Actor))

The function is called on actors when they would receive damage (but before it's actually dealt). It gets a bunch of information, including the pointers to actors that deal the damage, and the raw damage value (as `damage`) before it's modified by various resistances.

When the base `DamageMobj()` is called, it'll *deal* the damage. (As with other virtual functions, if you override it, then to call the *base* function you need to call `super.DamageMobj`).

Apart from dealing damage, it also *returns* an integer number: normally it should be the same as the amount of damage dealt.

Here's an example of how this override is used:

```csharp
Class ZombieTroopman : Zombieman {
	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle) {
		if (source && source is "Zombieman")
			return 0;
		return super.DamageMobj(inflictor, source, Damage, mod, flags, angle);		
	}
}
```

This version of Zombieman checks whether the `source` of the attack was another Zombieman (or an actor inheriting from Zombieman). If so, it *doesn't* call `super.DamageMobj` and returns 0. In all other cases it deals damage normally and returns the amount of damage that was dealt.

As mentioned above, you can also *call* `DamageMobj` to—you guessed it—damage an actor. You can even do it from a `DamageMobj` override:

```csharp
Class RetaliatingZombieman : Zombieman {
	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle) {
		if (source)
			source.DamageMobj(self,self,damage,'normal'); //deals damage to whatever damaged it
		return super.DamageMobj(inflictor, source, Damage, mod, flags, angle);		
	}	
}
```

This annoying Zombieman calls `DamageMobj` on the actor that dealt damage to them (such as the player), and deals exactly the same amount of damage. Notice that, since there are no projectiles involved, both `inflictor` and `source` in this call are `self`, i.e. the Zombieman itself.



`DamageMobj` can be called from anywhere; in fact, it's actually probably the most common basic function used to deal damage.

Let's say you want to create a projectile that can pierce enemies and damage them, but don't want to use +RIPPER flag, since with this flag projectile will damage the enemy continuously, as it's flying through them. Instead, you want the projectile to always damage the enemy once and only once. That can be achieved with `SpecialMissileHit` we just talked about, and `DamageMobj`:

```csharp
Class PenetratingBullet : FastProjectile {
	actor hitvictim; //this custom pointer will store the last actor hit by the projectile
	Default {
		speed 85;	
		damage 0; //we need this to be 0 since we'll be dealing damage manually
		radius 2;
		height 2;
		scale 0.2;
		obituary "%o was shot down.";
	}	
    override int SpecialMissileHit(actor victim) {
		//check that the victim (the actor hit) is NOT the same as hitvictim (last actor hit):
        if (victim && target && victim != target && victim != hitvictim) {	
			victim.DamageMobj(self,target,10,'normal'); //deal exactly 10 damage to victim
			hitvictim = victim;			//store the vicitm we just damaged as 'hitvictim'
		}
		return 1;						//keep flying
	}
	states {			//we're just reusing Rocket sprites
	Spawn:
		MISL A 1;
		loop;
	Death:
		TNT1 A 1;
		stop;
	}
}
```

Thanks to `SpecialMissileHit` we don't even need RIPPER. Instead of `10` you can, of course, supply any random expression you like as damage, for example `5*random(1,8)` will make it behave similarly to Doom, where projectiles deal randomized damage multiplied between 1 and 8.

Notice, that the `inflictor` in this case is `self` (the projectile itself), while the `source` is `target`— that is the projectile's `target`, which, as we remember is whoever shot the projectile.



## Common ZScript virtual functions

A non-comprehensive of some of the most common virtual functions you'll be overriding in your mods:

**Actor:**

- `void Tick()` — Called by all actors every tic to handle collision, movement and everything else.
- `void BeginPlay()` — Called after the actor is created, before any default properties are established. Can be used to set default values to custom variables. Do NOT destroy actors here!
- `void PostBeginPlay()` — Called after the actor is been created but before the first tic is played or any state called. A good place to do stuff like spawning another accompanying actors nearby (e.g. a lamp and a light halo), and anything else you'd normally do in the first frame of Spawn.
- `bool CanCollideWith (Actor other, bool passive)` — Called when two actors collide, depending on who ran into whom.
- `int SpecialMissileHit (Actor victim)` — Called by projectiles whenever they collide with an actor (including the shooter of the projectile!).

**Inventory:**

- `void DoEffect()` — Called every tic by inventory items that are inside an actor's inventory. Use it instead of Tick() to continuously do stuff on items.
- `void AttachToOwner(Actor other)` — Called by items when they are placed in an actor's inventory. After this call the `other` (the actor the item gets attached to) becomes `owner`, and the item can use the `owner` pointer.
- `void DetachFromOwner()` — Called anytime the item is fully removed from owner's inventory, whether by being tossed, destroyed or taken away entirely.
- `void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor = null, Actor source = null, int flags = 0)` — Called by items capable of modifying the owner's incoming damage, such as PowerProtection.

A more detailed list can be found on the [ZDoom Wiki](https://zdoom.org/wiki/ZScript_virtual_functions#Actor).

------

🔵 [>> Next: Event Handlers](Event_Handlers.md)