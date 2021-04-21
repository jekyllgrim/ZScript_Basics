### [<<< Back to  start](README.md)

<< Previous: Arrays

**Disclaimer:** This chapter is work in progress. Things will be moved, amended and expanded. At least two more sections are planned.

# Flow Control

When you call functions, change values and do other things within a code block (an anonymous function, a virtual function override, etc.), these changes are executed in a certain order, following the specified conditions. To control this flow, you need to know how to use **statements** and **operators**.

## Operators and operands

**Operators** are symbols that define relationships and interactions between **operands**. In the expression `A + B` A and B are operands, while `+` is the <u>operator of addition</u>. In the expression `if (A == B)` A and B are operands, and `==` is a <u>relational operator</u> that checks if operands' values are equal to each other.

Operators used in ZScript are similar to the ones used in the C-family languages. They can be split into the following categories:

* Arithmetic operators
* Relational operators
* Logical operators
* Assignment operators
* Bitwise operators
* Miscellaneous operators



### Arithmetic operators

Basic arithmetic operations like addition, subtraction, multiplication, division, modulus operations, increment, and decrement. They're used to change the value of a numeric operand.

- `+` — **addition**:

  ```csharp
  int i = health + 100; //defines an integer variable i equal to the actor's current health value plus 100
  ```
  
```csharp
  A_SetHealth(health + target.health); //sets the actor's health to its current value plus the actor's target's current health value
```

- `-`  — **subtraction**:

  ```csharp
  SetZ(ceilingz - 1); //moves the actor vertically and places it 1 unit below the height of the current sector's ceiling
  ```

  ```csharp
  int i = pos.z - target.pos.z; //defines an integer variable i that is the difference between the absolute vertical positions of this actor and this actor's target
  ```

- `*` — **multiplication**:

  ```csharp
  scale = scale * 0.5; //changes the actor's current scale so that it's reduced by 50%
  ```

  ```csharp
  A_SetHealth(health * 0.8); //change's the actor's health value so that it's reduced by 20%
  ```

- `/` — **division**:

  ```csharp
  double projvel = Distance3D(target) / 35; //defines a double value 'projvel' that is equal to the distance to target divided by 35 
  ```

  (If a projectile is then fired at the `target` with velocity `projvel`, it'll reach the goal within 35 tics, i.e. a second)

  **IMPORTANT NOTE:** In many programming languages there are two separate division operators: one for integer division and one for float-point (or double) division. In ZScript there's only one, which means that if both numbers are integers, the result will be an integer as well, and the part of the number after the point will be automatically truncated (removed). So, for example, `5 / 2` in ZScript equals `2`, not `2.5`.

  This can be avoided by making sure that one or both operands are doubles, by doing one of the following:

  - giving it a point, optionally followed by a zero, i.e. `5.0` or `5.`;
  - explicitly defining it as a double by doing `double(5)`.

  So, `5. / 2`, as well as `5 / 2.` equals `2.5`.

- `%`  — **modulus operation** returns the remainder after dividing the first operand by the second operand:

	```csharp
	if (level.time % 35 == 0) 
	//this check will return true every time the current level.time can be divided by 35 without a remainder, i.e. every 35 tics (1 second)
	```

- `++` — **increments** the value (adds 1 to it):

	```csharp
	int steps;	//defines an integer variable 'steps'
	if (steps < 10) {	//checks if the value of 'steps' is under 10
		steps++;	//if true, adds 1 to the current value of 'steps'
	}
	```

	(`steps++` is the same as doing `steps = steps + 1`)

- `--` — **decrements** the value (decreases it by 1):

	```csharp
	int steps;	//defines an integer variable 'steps'
	if (steps > 0) {	//checks if the value of 'steps' is over 0
		steps--;	//if true, subtracts 1 from the current value of 'steps'
	}
	```

	(`steps--` is the same as doing `steps = steps - 1`)

#### Note on placement of increment/decrement operators

Operators of incrementation can be placed both after and before a value. So, both `value++` and `++value` are correct. The difference only occurs if you perform multiple operations, such as incrementing and checking the value at the same time. For example:

```csharp
int myVal = 5;
bool isBigger = myVal++ > 5;
```

In the above example `myVal` is *first* checked against 5, and *after that* `myVal` is incremented. As a result, boolean `isBigger` will be false, because at the moment of checking `myVal` will still be equal to 5.

Compare:

```csharp
int myVal = 5;
bool isBigger = ++myVal > 5;
```

In this example `myVal` is *first* incremented, and *after that* checked against 5. As such, `isBigger` will be true, because `myVal` will be equal to 6 before the check.

It's a relatively niche case, but it's something important to be aware of.



### Assignment operators

Assignment operators are used to *set* a value. They don't check or compare, they simply change the value. You'll normally use them to change the values of variables.

* `=` — **assigns** a certain value to the operand:

	```csharp
	int i = 10; //defines integer variable i and sets its value to 10
	```

	```csharp
	gravity = 0.4; //sets the calling actor's gravity to 0.4
	```

	```csharp
	mass = health; //sets the calling actor's mass to be equal to their current health value
	```

* `+=` — **adds** a value to the current value of the operand:

	```csharp
	mass += 1000; //adds 1000 to the current mass value of the calling actor
	```

	```csharp
	vel.z += frandom(1,4); //increases the calling actor's current vertical velocity by a random double value betweem 1.0 and 4.0
	```

	`a += b`is a shorter version `a = a + b`:

	```csharp
	//These do the same things:
	
	gravity += 0.5;
	
	gravity = gravity + 0.5;
	```
	
* `-=` — **subtracts** a value from the current value of the operand:

	```csharp
	angle -= 45; //decreases the calling actor's angle by 45, which will turn the actor 45 degrees to the left
	```

* `*=` — **multiplies** the current value of the operand by the given value:

	```csharp
	scale *= 0.99; //decreases the calling actor's scale (sprite size) by 1%
	```

* `/=` — **divides** the current value of the operand by the given value:

	```csharp
	alpha /= 2; //reduces the calling actor's alpha (translucency) by 50%
	
	//same as doing this:
	alpha *= 0.5;
	```

	Note: changing alpha will only work on if actor's `renderstyle` is of type that supports translucency (e.g. `'add'` or `'translucent'`).

* `%=` — gives the **remainder** of dividing the first operator by the second operand:

	```csharp
	int i = 10;
	i %= 2; 
	//i will be equal to 0, because 10 equals 2 * 5 without remainder
	```

	```csharp
	int i = 10;
	i %= 3;
	//i will be equal to 1, because 10 equals 3 * 3 plus 1 as remainder
	```

	

### Relational operators

Used to *check* whether two values are equal, or whether one is greater than, less than, greater than or equal to, or less than or equal to one another. These operators are used in checks, such as `if`, `while`, `for`, etc. (more on those below).

* `==` — checks if operands are **equal** to each other. This can be used for integers, doubles, bools and pointers.

  * For numeric (**integer** and **double**) values this operator check the actual numbers against each other:

  ```csharp
  if (health == 100) 
  //returns true if health value is exactly equal to 100
  ```

  With **boolean** values this operator can be used to check if they're `true` or `false`:

  ```csharp
  if (target.bISMONSTER == true)
  // Returns true if the calling actor's target has ISMONSTER flag
  ```

  ```csharp
  bool mybool;
  if (mybool == false) {
  	mybool = true;
  }
  ```

  Note that true/false checks can be shortened as follows:

  ```csharp
  if (target.bISMONSTER) //this is the same as if (target.bISMONSTER == true)
  ```

  This operator can also be used with [pointers](Pointers_and_casting.md) to check if they're the pointers to the same actor:

  ```csharp
  if (victim == target)
  // This check is used in SpecialMissileHit overrides to check if 'victim' (the actor hit by the projectile) is the same as projectiles 'target' (the actor who shot it). It makes sure projectiles can never hit their shooters.
  ```

  Checking pointers against `null` allows to check if that pointer is empty (you already know this as null-checking):

  ```csharp
  if (target == null)
  // Will return true if the calling actor doesn't have a target
  ```

  Note: make sure you do NOT confuse `==` with with `=` — an operator used to actually *change* values. (See Assignment Operators above.)

* `!=` — checks if operands are **not equal** to each other (the inverse of the above):

  ```csharp
  if (mass != 0)
  // Will return true when the mass of the calling actor isn't equal to 0
  ```

  ```csharp
  if (master != target.master)
  // Will return true if the calling actor's master is not the same 
  ```

  This operator is often used in null-checks:

  ```csharp
  if (target != null) {
  	//this block will be executed if the calling actor has a target
  ```

  Note that null-checks can be shortened, just like boolean checks, as follows:

  ```csharp
  if (target)	//this is the same as if (taget != null)
  if (!target)	//this is the same as if (target == null)
  ```

  `!` is actually separate operator that is covered below, under Logical operators.

* `~==` — checks if the first operand is ***approximately* equal to** the second one: this is the same check as `==` but it can be used with doubles to add a very small margin of error to the check. It's very often used with velocity checks (as you remember, `vel` is a vector3 that consists of 3 doubles):

  ```csharp
  if (vel ~== (0,0,0))
  // Will return true if the calling actor's velocity is approximately equal to zero
  ```

  For all intents and purposes this check is pretty much the same as `if (vel == (0,0,0))`, but edge cases are possible, so for doubles it's recommended. It's slightly less performance efficient than `==`, but most of the time the difference is negligible.

  Doesn't work with integer values.

* `>` — checks if the first operand is **greater than** the second:

	```csharp
	if (health > 0)
	```

* `<` — checks if the first operand is **less than** the second:

	```csharp
	if (mass < 500)
	```

* `>=` — checks if the first operand is **greater than or equal to** the second:

	```csharp
	int i = pos.z - target.pos.z;
	if (i >= 0) {
		//execute this block if the calling actor's vertical position is above or equal to the target's position
	}
	else {
		//otherwise execute this block
	}
	```

* `<=` — checks if the first operand is **less than or equal to** the second:

	```csharp
	if (pos.z <= 0) {
		destroy();
	}
	// This will destroy the calling actor if their position is at or under the current sector's floor
	```



### Logical operators

These operators are used to combine multiple checks.

* `&&` — logical AND. This operator is used to check if *all* operands or statements are true:

	```csharp
	if (target && target.health > 0)
	// Returns true if the calling actor has a target and that target's health is above 0
	```

	```csharp
	if (i > 0 && i <= 100)
	// Returns true if the (previously defined) variable i is above zero and under or equal to 100
	```

Note, in case there are multiple checks, the game won't proceed to the next check unless the previous one is true. So, for example in this case:

```cs
override void DoEffect() {
	super.DoEffect();
    if (owner && owner is "PlayerPawn") {
        [...]
    }
}
```

...if `owner` is null, the string of checks will stop there. As such, the following `owner is "PlayerPawn"` check will not result in a VM abort, because if `owner` is null, the next check simply won't be executed.

What it means, always put the most important and the simplest check first, because this will be both safe *and* more performance efficient.

* `||` — logical OR. This operator is used to check if *any* of the operands/statements is true:

	```csharp
	if (target is "PlayerPawn" || target.bISMONSTER)
	// This check will return true both if the target of the calling actor is a player pawn (a player-controlled actor) or if it has a ISMONSTER flag (i.e. is likely a monster)
	```
	
	```csharp
	if (vel ~== (0,0,0) || pos.z <= floorz)
	// Returns true if the calling actor is not moving or if it's on the floor (or, for some reason, below it)
	```
	
	OR checks work the same way as AND checks, just inverted. Which means, if the first condition is true, it won't proceed to the second condition.
	
* `!` — logical NOT. This operator allows to **invert** *any* check or even a whole statement. For example:

	```csharp
	if (!target) // Checks if target pointer is null, same as 'if (target == null)'
	```

	```csharp
	if (!(vel == (0,0,0)) || !bNOGRAVITY)
	// Returns true if the calling actor's velocity is NOT zero OR the calling actor does not have a NOGRAVITY flag
	```

	```csharp
	if (!master && target))
	// This will true if the calling actor does NOT have a master but does have a target
	```


All logical operators can be combined with the help of parentheses:

```csharp
if (target && !target.bKILLED && (target is "PlayerPawn" || target.bISMONSTER))
// This check will pass if target exists, AND target isn't killed (doesn't have KILLED flag), AND it's either a PlayerPawn OR a monster
```

```csharp
if ((target && target is "PlayerPawn") || (master && master.target && master.target is "PlayerPawn"))
// This will pass if the calling actor has a target and that target is PlayerPawn, OR if the calling actor has a master, that master has a target, and the master's target is PlayerPawn.
```



### Miscellaneous Operators

* `is` — checks whether the operand is a specific class *or* is a class that inherits from the given class:

	```csharp
	Class Imp1 : DoomImp { }
	
	
	//in some other place in the code:
	actor a = Spawn("Imp1",pos);
	if (a is "DoomImp") {
		//this check will return true because the spawned Imp1 inherits from DoomImp
	}
	```

	A restrictive alternative to this operator is `GetClassName()` function which returns true only if the operand is the specific class provided:

	```csharp
	Class Imp1 : DoomImp { }
	
	
	//in some other place in the code:
	actor a = Spawn("Imp1",pos);
	if (a.GetClassName() == "DoomImp") {
		//this will return false because Imp1 and DoomImp are different class names
	}
	else if (a is "DoomImp") {
		//this will return true
	}
	```

* `?` — **ternary operator**, functions as a shorter version of an if/else block. Doesn't affect performance and is only used for convenience. 

	The syntax for using a ternary operator is as follows:

	```csharp
	booleanvalue = condition ? valueiftrue : valueiffalse
	```

	Examples:

	```csharp
	//regular if/else block:
	int i;
	if (bNOGRAVITY) {
	    i = 10;	//sets the value to 10 if the calling actor has +NOGRAVITY flag
	}
	else {
	    i = 5;	//otherwise sets the value to 5
	}
	
	//ternary operator:
	int i = bNOGRAVITY ? 10 : 5;
	```

	Among other things, using it can be convenient in function arguments:

	```csharp
	//all three variants below will set the calling actor's mass to 1000 if they have +BOSS flag, otherwise the mass will be set to 100
	
	//basic if/else:
	if (bBOSS) {
	    A_SetMass(1000);
	}
	else {
	    A_SetMass(100);
	}
	
	//a more versatile but longer version:
	int i;
	if (bBOSS) {
	    i = 1000;
	}
	else {
	    i = 100;
	}
	A_SetMass(i);
	
	//ternary operator:
	A_SetMass(bBOSS ? 1000 : 100);
	```


### Bitwise operators

Bitwise operators are used to deal with **[bit fields](https://en.wikipedia.org/wiki/Bit_field**). Many of them are likely to appear only in rather advanced code, but it's still important to understand at least the general concepts behind them, and some of these operators are actually very useful and common.

Bit fields are a specific type of data structure. In GZDoom their primary application is function flags. For example, `A_WeaponReady` supports various flags, such as `WRF_NOPRIMARY`, `WRF_NOSECONDARY`, `WRF_NOSWITCH`. The flags argument is special, because it's a single argument that can have multiple values combined in any order and number. It's possible because the flags argument is actually an integer value that functions as a **bit field**: what it means is that internally each flag is a number, those numbers are added to each when you define the flags, and the final number tells the game which combination of flags to use. The flag names, such as "WRF_NOPRIMARY", are just aliases for the actual numeric values.

It's important to know that, because as a result you can't use operators such as `==` with flags; instead they need special **bitwise operators** that can interact with the bit field that contains the flags.

Another common example of a bit field is player input: whenever player presses a button, the bit field that contains the inputs is changed. Obviously, multiple buttons can be pressed at the same time, so the field dynamically stores those values. You can get access to the player's input bit field either by using `GetPlayerInput()` function or just by accessing the `cmd.buttons` field when you have a pointer to the player (so, for example, from a weapon state it'll be `player.cmd.buttons`).

* `|` — **bitwise OR**. Most commonly used to combine flags together, for example:

	```csharp
	A_WeaponReady(WRF_NOSECONDARY|WRF_NOSWITCH); //this will make the weapon ready for fire but won't let you either fire the secondary attack or switch the weapon
	```

* `|=` — a combination of OR and a setter, it's primarily used to set flags. It functions by appending flags to the bit field, so that you can set multiple flags this way without clearing the field:

	```csharp
	action void CustomWeaponReady (int flags = 0) {
		if (invoker.ammo1 && invoker.ammo2 && (invoker.ammo2 != invoker.ammo1) && (invoker.ammo2.amount > 0) && (invoker.ammo1.amount < invoker.ammo1.maxamount))
			flags |= WRF_ALLOWRELOAD;
		A_WeaponReady (flags);
	}
	```

	This custom version of `A_WeaponReady` is designed to work with weapons that use `ammotype1` for magazine ammo and `ammotype2` for reserve ammo. It defines a custom `flags` bit field. Then it performs a long string of checks: it checks whether `ammotype1` and `ammotype2` are defined; then checks that those aren't the same ammo class; then checks if the player has more than 0 but less than maximum amount of secondary ammo; finally, if all those checks pass it'll append the `WRF_ALLOWRELOAD` flag to the field, and *then* call the classic `A_WeaponReady` with the flags you defined.

	What's nice is that you can also pass the other existing A_WeaponReady flags to it, for example `CustomWeaponReady(WRF_NOSECONDARY)` will work as well: if you do that and the string of checks returns true, it'll call `A_WeaponReady(WRF_NOSECONDARY|WRF_ALLOWRELOAD)`.

* `&` — **bitwise AND**. Most commonly used to check if a value is present in the bit field. For example:

	```csharp
	if (player.cmd.buttons & BT_FIRE)
	//will return true if the player is currently pressing the Fire key, among others
	```

	As mentioned above, `==` won't work here because the `cmd.buttons` field contains all currently pressed keys. By using `&` you check if the player is pressing anything *as well as* the key you're checking for.

* `&=` — a combination of bitwise AND and a setter. It's most common application is to unset flags in combination with `~` (see below).

* `~`  — **bitwise NOT**. It's most commonly used in combination with `&=` to unset flags as follows:

	```csharp
	action void CustomFireBullets(double spread_xy, double spread_z, int numbullets, int damageperbullet, class<Actor> pufftype = "BulletPuff", int flags = 1, double range = 0, class<Actor> missile = null, double Spawnheight = 32, double Spawnofs_xy = 0) {
	    if (random(0,10) > 8)
	        flags &= ~FBF_USEAMMO;
	    A_FireBullets(spread_xy, spread_z, numbullets, damageperbullet, pufftype, flags, range, missile, Spawnheight, Spawnofs_xy);
	}
	```

	This function is identical to `A_FireBullets`, except it'll randomly (with about a 80% chance) *unset* the FBF_USEAMMO flag, and then it'll call `A_FireBullets` with all the other arguments as you defined them.

	*Note:* This is an awkward example purely for illustrative purposes, and I wouldn't actually recommend using it. In practice the use of this operator most commonly appears in custom functions with custom bit fields.

## Statements

TBA