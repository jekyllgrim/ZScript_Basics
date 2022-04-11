# Player and PlayerPawn

## Overview

The concept of the "player" is represented in ZScript by several different entities, and it's important to understand what is what when interacting with player data in any way.

Aside from you, the actual physical person playing the game, in the context of ZScript the term "player" primarily refers to one of two things:

1. **PlayerPawn**: `PlayerPawn` is a base ZScript class, a special subclass of `Actor` that is specifically designed to be controlled by the player. Every game supported by GZDoom defines its own variation: `DoomPlayer`, `HereticPlayer`, `FighterPlayer`, etc. (see [the wiki](https://zdoom.org/wiki/Classes:PlayerPawn)). Player pawns are somewhat similar to monsters, having state sequences like Spawn, See, Missile, Death, yet they have no AI and their actions are controlled by the input from the player.

2. The **player** struct: this is a special object attached to the player pawn, which mostly serves as a container for various player-specific data. The player struct contains such data as controls input, field of vision, player health, sprites being drawn on the screen, currently selected weapon, and so on.

The interaction between these two entities can at times be confusing, especially because some of the values initially defined in the player pawn (such as health) are only initialized through it, while being actually handled and modified by the player struct.

This chapter will cover the basics of this relationship.

## Data access

Player pawns have access to their player structs, and vice versa. Some specific classes also have pointers to one of these.

* Every player pawn has a `player` pointer that points to the player struct that controls it. The data type of the pointer is `PlayerInfo` (a special type not used for anything else).

* Conversely, every `player` has a `mo` pointer to its player pawn ("mo" stands for "map object"). The data type of the pointer is `PlayerPawn`.

* Within the context of states that are handled by PSprites, Weapon and CustomInventory classes have a `self` pointer to the PlayerPawn that carries them. Thus, `self.player` or just `player` is a pointer to the controlling `player`.

Many other classes will have a relative pointer to the player pawn: for example, it'll be the `owner` of the items in its inventory or the `target` of the monsters that attack it. However, all those pointers are generic Actor pointers, they don't contain any PlayerPawn-specific data. But it's still possible to reach the `player` struct from those pointers. For example, you can use the following to check that the item is held by a player (not a monster):

```csharp
class TestItem : Inventory
{
    override void DoEffect()
    {
        super.DoEffect();
        if (owner && owner.player)
        {
            // This is entered only if the owner has a 'player'
            // field, which means it's a player pawn.
        }
    }
}
```

You can use this to get access to data stored in `player`. For example, you can read the `readyweapon` field which contains the pointer to the currently selected player weapon:

```csharp
class WeaponWeightControl : Inventory
{
    override void DoEffect()
    {
        super.DoEffect();
        // Do nothing if there's no owner:
        if (!owner)
            return;
        // Check if the owner is a player and has a Chaingun selected:
        if (owner.player && owner.player.readyweapon == "Chaingun")
        {
            // If so, set their speed to 80% of default:
            owner.speed = owner.default.speed * 0.8;
        }
        else
        {
            // Otherwise reset their speed to default:
            owner.speed = owner.default.speed;
        }
    }
}
```

This is a very basic example of an "encumberance" system, where the player's maximum movement speed is reduced when they're holding a specific weapon.

Note:

* `readyweapon` is a `player`-specific field, so we need a `player` pointer to access it; as a result the item needs to check for `owner.player.readyweapon`

* In contrast, `speed` is an actor property, and it's also defined in the base Actor class, so, to access it we don't need to get access to the `player` or to cast the `owner` as PlayerPawn, we can just use `owner.speed` directly.

## Player and PlayerPawn: what stores what

As 
