### [<<< Back to  start](README.md)

<< Previous: Arrays

# Flow Control

When you call functions, change values and do other things within a code block (an anonymous function, a virtual function override, etc.), these changes are executed in a certain order, following the specified conditions. To control this flow, you need to know how to use **statements** and **operators**.

## Operators

**Operators** are symbols that define relationships and interactions between **operands**. In the expression `A + B` A and B are operands, while `+` is the operator of addition. In the expression `if (A == B)` A and B are operands, and `==` is a relational operator that checks if operands' values are equal to each other.

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
	double projvel = Distance3D(target) / 35; //defines a double value 'projvel that is equal to the distance to target divided by 35 
	```

	(If a projectile is then fired at the `target` with velocity `projvel`, it'll reach the goal within 35 tics, i.e. a second)

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

	For all intents and purposes this check is the same as `if (vel == (0,0,0))`, however it's less resource intensive because the precision of the check will be slightly lower. It's recommended to use this operator instead of `==` for similar checks if they're used often. It doesn't work with integer values.

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

* `||` — logical OR. This operator is used to check if *any* of the operands/statements is true:

	```csharp
	if (target is "PlayerPawn" || target.bISMONSTER)
	// This check will return true both if the target of the calling actor is a player pawn (a player-controlled actor) or if it has a ISMONSTER flag (i.e. is likely a monster)
	```
	
	```csharp
	if (vel ~== (0,0,0) || pos.z <= floorz)
	// Returns true if the calling actor is not moving or if it's on the floor (or, for some reason, below it)
	```
	
	OR checks are faster than AND checks: the game will return false and won't execute more checks if the first check is false, whereas with AND checks the game will always unconditionally check all of them. As such, if you have multiple conditions for a block, sometimes you can invert them and optimize your check:
	
	```csharp
	//slower version:
	override void PostBeginPlay() {
	super.PostBeginPlay();
		if (master && target && target.bISMONSTER) {
			target.GiveInventory("FXControl",1);
		}
	}
	
	//faster version:
	override void PostBeginPlay() {
		super.PostBeginPlay();
		if (!master || !target || !target.bISMONSTER) {
			return;
		}
	    target.GiveInventory("FXControl",1);
	}
	```
	
	In this example with the faster version the game will run one check and immediately stop if it's false; and only if the first check is true will it go to the second check. Which means the cutoff in the sequence of checks may happen as soon as after one or two checks, whereas in the slower versions all three checks are called every time. This is a good practice to follow, since when something like this is performed very often, it may be relevant for performance.
	
	(Note that if `!target` check is false, this by definition means `target` isn't null, so you don't need to add an extra null-check before checking `target.bISMONSTER`.)
	
* `!` — logical NOT. This operator allows to **invert** *any* check or even a whole statement. For example:

	```csharp
	if (!target) // Checks if target pointer is null, same as 'if (target == null)'
	```

	```csharp
	if (!(vel == (0,0,0) || !bNOGRAVITY)
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

* `&` — **bitwise AND**. There are many bitwise operators, but most of the time you'll only need this one. You'll need it to check values of bitwise fields. One common example of such as field is keys that are currently being pressed by the player—if you have a pointer to the player, the pointer to the key field is `player.cmd.buttons`. If you want to check if the player is pressing a specific key, you're not checking *all* keys, you're just checking if the specific key you need is included in the field:

	```csharp
	if (player.cmd.buttons & BT_FIRE)
	//will return true if the player is currently pressing the Fire key, among others
	```

* `?` — **ternary operator**, functions as a shorter version of an if/else block. Doesn't affect performance and is only used for convenience. 

	The syntax for using a ternary operator is as follows:

	```csharp
	booleanvalue ? valueiftrue : valueiffalse
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

	

## Statements

TBA