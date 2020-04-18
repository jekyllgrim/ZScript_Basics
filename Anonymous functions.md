# Anonymous functions

This isn’t really a ZScript-only feature because it was available in DECORATE before ZScript became widely available. However, that was a brief period and many DECORATE users missed that; plus, Zandronum’s version of DECORATE doesn’t support this feature at all.

The concept is very simple: an anonymous function is when you combine a bunch of functions inside {curly braces} and make it a code block. This way you can execute multiple functions but attach them to a single frame. So, for example instead of this:

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



And that’s much cleaner and more convenient for multiple purposes. 

There are a few things you need to remember when using anonymous functions:

- *Both* in DECORATE and ZScript all functions used inside anonymous functions **must** end with a semicolon, and, if you don’t specify any parameters, you still need to include empty parentheses at the end `()`.
- You can use `if`/`else` and other types of conditions in anonymous functions.
- You can't use jump commands directly, and instead will have to use the `return` command

These aspects are described in more detail in the [**Flow Control**](#_Flow_Control) section.