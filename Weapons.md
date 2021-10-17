# Weapons, overlays and PSprite

Weapons (i.e. classes that inherit from the base `Weapon` class) feature a number of special behaviors that aren't found in other classes, and you need to be aware of those behaviors to use them effectively.

Here's a brief overview:

* `Weapon` and `CustomInventory` are the only two base classes that inherit from an internal `StateProvider` class, which allows them to draw stuff on the screen. This is how weapon animations are performed. These sprites drawn on the screen are themselves a special object called `PSprite` (the name is an abbreviation for "player sprite").
* Weapon sprites can be drawn in multiple layers with the help of `A_Overlay` and the related functions. Those sprites can be independently offset, scaled and rotated. Each of those layers is a separate PSprite.
* Most weapon functions, such as `A_FireBullets`, `A_WeaponReady` and other functions that are called from the States block, are actually executed by the `PlayerPawn` carrying that weapon rather than the weapon itself. For example, when you call `A_FireProjectile` from the weapon's `Fire` state sequence, it's actually the player pawn that fires the projectile in the world, not the weapon (because at that point the weapon isn't present in the world, it exists only in the player's inventory). That's why monster attack functions, such as `A_SpawnProjectile`, can't be used in weapons, and vice versa.
    * When you make custom weapon functions, if the function is meant to be called from a weapon state, it has to be prefixed with `action` keyword—this designates it as a function meant to be called from a weapon state.
* As a result, in the context of a weapon state `self` is not the weapon, but the player pawn carrying it.
* If you define a [variable](Variables_and_data_types.md) on a weapon, to access that same variable from a weapon state you have to put an `invoker.` prefix before it.



[TBA]
