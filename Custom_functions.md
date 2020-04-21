### [<<< Back to  start](Readme.md)

[<< Previous: Pointers and casting]([Pointers_and_casting.md)

# Custom functions

Sometimes you need to perform a bunch of similar actions in multiple places and/or multiple actors. Usually you can simplify things by creating a custom function. Most functions will look like this:

```csharp
//pseudocode:
type name (arguments) {
	//what the function does
}
```

Let's revisit our **CacoSingleDad** for an actual example:

```csharp
Class CacoSingleDad : Cacodemon replaces Cacodemon {
	actor baby;
	void SpawnBaby() {		//defines a function that can be used by CacoSingleDad
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
	void AngerBaby() {
		if (baby) {
			baby.A_PlaySound("caco/active");
			baby.A_SetTranslation("BabyAngry");
			baby.speed *= 2; 
			baby.floatspeed*= 1.5;
			baby.bNOPAIN = true;
		}
	}
		
	states {
	Spawn:
		TNT1 A 0 NoDelay SpawnBaby();
		HEAD A 10 A_Look;
		wait;
	Death:
		TNT1 A 0 AngerBaby();
		goto super::Death;
	}
}
```

The code should be simple enough to understand: we defined two functions, `SpawnBaby` and `AngerBaby`. The first one spawns the baby Caco and performs all the stuff we need to do (sets color, health, speed, etc.), and the second one checks if baby exists and does the other stuff. 

There are two characteristics of this function to consider:

- This is a **void** function as specified by `void` before its name: this means the function has no **return value**. In other words, when we call this function, it simply *does stuff* but we can't use it to *obtain any data*. (Read on to learn more about return values.)

- This function has no **arguments**—i.e. nothing that we can add inside the parentheses.

As a result, this function isn't very flexible, and most cases you'll need to create something more complex. 

For example, let's say we want to create a universal "baby-spawning function" that allows us to manually specify the baby's class and health. For that we need to declare [variables](Variables_and_data_types.md) that will serve as arguments and then use them within a function:

```csharp
//defining the function:
void SpawnBabyFlexible(Class<Actor>	spawnclass, int babyhealth = 100, int babyspeed = 10, double babyscale = 0.5) {
	baby = Spawn(spawnclass,pos,NO_REPLACE);
	if (baby) {
		baby.Warp(self,64,0,0);
		baby.A_SetHealth(babyhealth);
		baby.speed = babyspeed;
		baby.A_SetScale(babyscale);
		baby.A_SetTranslation("BabyCalm");
	}
}

//using the function:
TNT1 A 0 NoDelay SpawnBabyFlexible("Cacodemon",800,12);
```

The arguments are defined in the same way as variables:

```csharp
type name = value
```

If you provide a **value**, this will be the **default value** for the corresponding argument. For example, `int babyspeed = 10` defines **babyspeed** as an optional argument: if you don't set a value when calling this function, then the default value will be used (which in the example above is 10). 

At the same time, `spawnclass` is not an optional argument: when using the function, you have to provide a name of the actor to spawn; there's no "default" actor that would spawn instead.

The arguments you defined can be used within a function as shown in the example, e.g. `baby.A_SetHealth(babyhealth);` will make the spawned actor's health equal to the number you provide when calling the function (in the example it's 800). We also provided a default value of 100 for the argument.

 

We could make this function a bit more universal by improving how it treats the default values:

```csharp
void SpawnBabyUniversal(Class<Actor> spawnclass, int babyhealth = 0, int babyspeed = 0, double babyscale = 0) {
	baby = Spawn(spawnclass,pos,NO_REPLACE);
	if (baby) {
		baby.Warp(self,64,0,0);
		if (babyhealth != 0)			//executes if 'babyhealth' is not equal to 0
			baby.A_SetHealth(babyhealth);
		if (babyspeed != 0)				//executes if 'babyspeed' is not equal to 0
			baby.speed = babyspeed;
		if (babyscale != 0)				//executes if 'babyscale' is not equal to 0
			baby.A_SetScale(babyscale);
		baby.A_SetTranslation("BabyCalm");
	}
}
```

In this version of the function the default values are 0 and they're treated as an instruction to use default values for the actor: unless you specify values for `health`, `speed` and `scale` explicitly, the spawned actor will simply use its own default values. So, for example, if you spawn a Mancubus instead of a Cacodemon, it'll have Mancubus' default `health` value; same goes for `scale` and `speed`.

It's up to you which arguments to make optional and which to leave compulsory (in `SpawnBabyUniversal()` above the only non-optional argument is `spawnclass`—the name of the actor to spawn); the only rule to remember is that non-optional arguments should be defined *first*—you can't have non-optional arguments defined after optional ones.

You can notice that this function doesn't actually cover everything we used in CacoSingleDad originally (such as modifying the baby's `floatspeed`), but you can easily expand it. It will also only work on actors that actually have a `baby` variable defined—so, if you want to create multiple custom functions, it may be a good idea to put them all inside your own version of the base Actor class and have your classes inherit from it.

 

A note on **function names**: you can give your functions any names you like, but in general it's a good idea to not use DECORATE's naming convention (which would be `A_FunctionName`) simply to avoid confusing yourself: this way you'll be able to tell at a glance that it's not a DECORATE function. However, it *can* be a good idea to use some sort of a custom prefix, such as your mod's initials.

## Non-void functions and return values

Void functions are the functions that do stuff and don't return any data. But there are many cases when you need to retrieve some sort of data using a function. Here's a very basic example:

```csharp
int GetTargetHealth() {
	if (target)
		return target.health;
	else
		return null;
}
```

This function checks if the actor that called it has a `target`, and if so, returns the amount of health it has. If there's no target, it doesn't return anything. (`null` means no data; note that it's *not* the same as 0, it's literally nothing—if you try to print it out, you'll either get nothing or useless garbage data) 

Note that you *have to* include a null-check here, as well as cover all possible cases: there has to be a return value for the case where target doesn't exist, that's why we must provide `return null`. If we don't, the function won't know what to do. (Nothing terrible will happen, GZDoom simply won't start. Bad stuff will happen if you skip the null-check, however, since it can cause a VM abort due to a null pointer).

It can also be slightly simplified:

```csharp
int GetTargetHealth() {
	if (target)
		return target.health;
	return null;
}
```

We don't need to use `else` here because the function cuts off at the point where you use `return;` so, if the target exists, the function will return its health and immediately stop doing anything else.

 

Function types are the same as variable types: they can hold numeric values, pointers, coordinates, etc. Here's an example of a custom version of `A_MonsterRefire` that is a `state` function:

```csharp
Class ChaingunGuyWithAMagazine : ChaingunGuy {
	int monstermag;	//this variable holds the number of "ammo" in monster's magazine
	property monstermag : monstermag;
	Default {
        ChaingunGuyWithAMagazine.monstermag 40;
    }
	state CustomMonsterRefire(int ChanceToEnd = 0, statelabel endstate = "See") { 
		if (monstermag == 0)				//check how much "ammo" is left
			return ResolveState("Reload");	//if 0, goto Reload state
		else if (ChanceToEnd > random(0,100))//otherwise check ChanceToEnd against a random value
			return ResolveState(endstate);	//if true, go to end state
		return ResolveState(null);			//otherwise don't do anything
	}
	states {
	Missile:
		CPAS F 2 A_CPosAttack;
		CPAS E 2 A_FaceTarget;
		CPAS F 2 A_CPosAttack;
		CPAS E 2 A_FaceTarget();
		TNT1 A 0 A_MonsterRefire(5,"AttackEnd");
		loop;
	AttackEnd:
		CPAS A 20;
		goto See;
	Reload:
		CPAS A 40 {
			monstermag = 40;
		}
		goto See;
	}
}
```

This function is designed for monsters that have "magazines" and need to reload their weapons. The monster in question doesn't use actual items for ammo, instead there's a variable that holds how much ammo it has.

This function works as a state jump, such as `A_Jump`: when the function is called in a monster's state, it tells the state machine where to go. Specifically, it does the following:

- Checks if the monster has run out of "ammo" (`monstermag` is 0). If so, it returns "Reload" state where other stuff happens (`monstermag` gets reset to whatever value is considered as full magazine).
- Otherwise it checks its argument `ChanceToEnd` (by default it's 0): if it's greater than 0, there's a randomized chance that the monster stops firing. In the example above the monster uses the value of 5.
  - It jumps to a state provided in the second argument of the function. By default, it's "See" but in the example above it's "AttackEnd". (I.e. this monster has a custom animation for stopping the attack, but other monsters using this function may not and they just jump to "See".)
- Finally, if none of the checks go through, the function returns nothing. `ResolveState()` is the correct way to return states in ZScript (you can't directly put in a state name). `ResolveState` will be covered in more detail in [Flow Control](#_Flow_Control_1).
  - In this case, if the function returns null, the state machine will continue going through the state. In the example above it'll show frame `CPAS E` for 1 tic and then it'll hit `loop` and go back to the beginning of the state.



[>> Next: Virtual Functions](Virtual_functions.md)