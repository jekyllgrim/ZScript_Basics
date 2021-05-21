🟢 [<<< BACK TO START](README.md)

🔵[<< Previous: Classes instead of actors](Classes_instead_of_actors.md)

------

# Anonymous functions

This isn’t really a ZScript-only feature because it was available in DECORATE before ZScript became widely available. However, that was a brief period and many DECORATE users missed that; plus, Zandronum’s version of DECORATE doesn’t support this feature at all.

Technically, an "anonymous" function is a function without a name. In the context of ZScript/DECORATE it's a method that allows you to combine a bunch of different functions together into one action, essentially creating a custom function on the spot. So, for example instead of this:

```csharp
TNT1 A 0 A_GunFlash
TNT1 A 0 A_Recoil(2)
TNT1 A 0 A_SpawnItemEx("EmptyCasing")
TNT1 A 0 A_FireBullets(5,1,1,0)
```

…You can do this:

```csharp
TNT1 A 0 {
	A_GunFlash();
	A_Recoil(2);
	A_SpawnItemEx("EmptyCasing");
	A_FireBullets(5,1,1,0);
}
```

This way you're basically creating a custom function that calls `A_GunFlash`, `A_Recoil`, `A_SpawnItemEx` and `A_FireBullets` at once, with the parameters you provided.

And that’s much cleaner and more convenient for multiple purposes. 

There are a few things you need to remember when using anonymous functions:

- *Both* in DECORATE and ZScript all functions used inside anonymous functions **must** end with a semicolon, and, if you don’t specify any parameters, you still need to include empty parentheses at the end `()`.
- You can use `if`/`else` and other types of conditions in anonymous functions.
- You can't use jump commands directly, and instead will have to use the `return` command

These aspects are described in more detail in the [**Flow Control**](#_Flow_Control) section.

------

🔵 [>> Next: Variables and data types](Variables_and_data_types.md)