class MyFullscreenHUD : BaseStatusBar
{
	HUDFont my_BigFont;
	double my_BigFontHeight;
	HUDFont my_BigFontMono; //monospaced version of BigFont
	
	array< class<Ammo> > my_ammoToDisplay;
	
	InventoryBarState my_invbar;
	double my_invbarSelectOfsX;
	
	My_LinearValueInterpolatorUI my_healthIntr;
	
	const MY_WEAPONSWAPTIME = 20;
	double my_WeaponSwapTics;
	Weapon my_currentWeapon;

	// Delta time:
	double my_prevMSTimeF;
	double my_deltaTime;
	const MY_DELTAFREQ = 1000.0 / TICRATE;

	// Compass:
	double my_prevPlayerAngle;
	double my_currPlayerAngle;

	override void Init()
	{
		Super.Init();

		// Make health bar interpolator:
		my_healthIntr = My_LinearValueInterpolatorUI.Create(100, 1);

		// Make inventory bar:
		my_invbar = InventoryBarState.Create();
		my_invbarSelectOfsX = my_invbar.selectofs.x;

		// Make font:
		Font f = Font.FindFont('BigFont');
		if (f)
		{
			// Create normal version:
			my_BigFont = HUDFont.Create(f);
			my_BigFontHeight = f.GetHeight();
			// Now create monospaced version, where every
			// character has the same width as the "0" character:
			my_BigFontMono = HUDFont.Create(f, f.GetCharWidth("0"), Mono_CellLeft);
		}
	}

	override void Draw(int state, double TicFrac)
	{
		Super.Draw(state, TicFrac);
		if (state == HUD_None || state == HUD_AltHUD)
		{
			return;
		}

		BeginHUD();
		// Update delta time first:
		My_UpdateDeltaTime();
		// Draw health and armor:
		if (CPlayer.mo)
		{
			my_healthIntr.Update(CPlayer.mo.health, my_deltaTime);
			My_DrawHealthArmor((4, 0), DI_SCREEN_LEFT_BOTTOM);
		}
		// Draw current ammo:
		My_DrawCurrentAmmo((-4, 0), DI_SCREEN_RIGHT_BOTTOM);
		// Draw weapon icon:
		My_DrawWeaponIcon((-144, -24), DI_SCREEN_RIGHT_BOTTOM, (32, 24));
		// Draw keys:
		My_DrawKeys((-(12 + 1)*3, 0), DI_SCREEN_RIGHT_TOP, (12, 12), 1);
		// Draw all possessed ammo:
		My_DrawAllAmmo((-2,0), DI_SCREEN_RIGHT_CENTER, (8, 8));
		// Draw inventory bar:
		if (!level.NoInventoryBar)
		{
			if (isInventoryBarVisible())
			{
				DrawInventoryBar(my_invbar, (0, -40), 7, DI_SCREEN_CENTER_BOTTOM);
			}
			Inventory selectedItem = CPlayer.mo.InvSel;
			if (selectedItem)
			{
				DrawInventoryIcon(selectedItem,
					(80, -2),
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_BOTTOM
				);
				DrawString(my_BigFont,
					String.Format("%d", selectedItem.amount),
					(80, -34),
					DI_SCREEN_LEFT_BOTTOM|DI_TEXT_ALIGN_CENTER,
					scale: (0.5, 0.5)
				);
			}

			if (my_invbar.selectofs.x > my_invbarSelectOfsX)
			{
				my_invbar.selectofs.x -= min(2.0 * TicFrac, abs(my_invbar.selectofs.x) - abs(my_invbarSelectOfsX));
			}
			else if (my_invbar.selectofs.x < my_invbarSelectOfsX)
			{
				my_invbar.selectofs.x += min(2.0 * TicFrac, abs(my_invbar.selectofs.x) - abs(my_invbarSelectOfsX));
			}
		}

		My_DrawCompass((0,20), DI_SCREEN_CENTER_TOP, TicFrac);
	}

	override void Tick()
	{
		Super.Tick();

		if (CPlayer.mo)
		{
			my_prevPlayerAngle = my_currPlayerAngle;
			my_currPlayerAngle = CPlayer.mo.angle;
		}
	}

	void My_UpdateDeltaTime()
	{
		double curMSTimeF = MSTimeF();
		if (my_prevMSTimeF == 0)
		{
			my_prevMSTimeF = curMSTimeF;
		}

		double msdiff = curMSTimeF - my_prevMSTimeF;
		my_deltaTime = msdiff / MY_DELTAFREQ;
		my_prevMSTimeF = curMSTimeF;
	}

	void My_DrawWeaponIcon(Vector2 pos, int flags, Vector2 box)
	{
		Weapon selected = CPlayer.readyWeapon;
		if (!selected) return;

		double vertOfs = 0;
		if (my_WeaponSwapTics > 0)
		{
			if (my_WeaponSwapTics >= MY_WEAPONSWAPTIME * 0.5)
			{
				vertOfs = box.y * My_Math.LinearMap(my_WeaponSwapTics, MY_WEAPONSWAPTIME, MY_WEAPONSWAPTIME * 0.5, 0.0, 1.0, true);
			}
			else
			{
				vertOfs = box.y * My_Math.LinearMap(my_WeaponSwapTics, MY_WEAPONSWAPTIME * 0.5, 0, 1.0, 0.0, true);
			}
		}
		Fill(0xffcccc00, pos.x - 1, pos.y + vertOfs - 1, box.x + 2, box.y + 2, flags);
		DrawInventoryIcon(selected,
			pos + box*0.5 + (0, vertOfs),
			flags|DI_ITEM_CENTER,
			boxsize: box
		);

		Weapon pending = CPlayer.pendingWeapon;
		if (!my_currentWeapon)
		{
			my_currentWeapon = selected;
		}
		else if (pending && pending != WP_NOCHANGE && pending != my_currentWeapon)
		{
			my_currentWeapon = pending;
			my_WeaponSwapTics = MY_WEAPONSWAPTIME;
		}
		else if (my_WeaponSwapTics > 0)
		{
			my_WeaponSwapTics -= 1.0 * my_deltaTime;
		}
	}

	Color My_GetInterColor(Color from, Color to, double distance)
	{
		distance = clamp(distance, 0.0, 1.0);
		// Get a color between 'from' and 'to' based on
		// the provided 'distance' value:
		Color finalColor = Color(
			int(round(from.a + (to.a - from.a)*distance)),
			int(round(from.r + (to.r - from.r)*distance)),
			int(round(from.g + (to.g - from.g)*distance)),
			int(round(from.b + (to.b - from.b)*distance))
		);
		return finalColor;
	}

	void My_DrawHealthBar(Vector2 pos, int width, int height, int flags)
	{
		Fill(0xffffffff, pos.x, pos.y, width, height, flags);
		width -= 2;
		height -= 2;
		pos.x += 1;
		pos.y += 1;

		Fill(0xff151515, pos.x, pos.y, width, height, flags);

		double health = CPlayer.mo.health;
		if (health > 0)
		{
			double maxHealth = CPlayer.mo.GetMaxHealth();
			double interFrac = clamp(my_healthIntr.GetValue () / maxHealth, 0.0, 1.0);
			Fill(0xffcccccc, pos.x, pos.y, int(round( width * interFrac )), height, flags);

			double frac = clamp(health / maxhealth, 0.0, 1.0);
			Color healthColor = My_GetInterColor(0xffff0000, 0xff00ff00, frac);
			width = int(round( width * frac ));
			Fill(healthColor, pos.x, pos.y, width, height, flags);
		}
	}

	// Gets the font color to be used for armor numbers,
	// based on the current armor's savepercent value:
	int My_GetArmorColor(double savepercent)
	{
		if (savepercent >= 0.8) //80% or more (doesn't exist in vanilla Doom)
		{
			return Font.CR_Red;
		}
		else if (savepercent >= 0.5) //50% or more (blue armor)
		{
			return Font.CR_Blue;
		}
		// this will catch the rest (including green armor);
		return Font.CR_Green;
	}

	int My_GetHealthColor(int health)
	{
		if (health <= 20)
		{
			return Font.CR_Red;
		}
		else if (health <= 50)
		{
			return Font.CR_Orange;
		}
		else if (health <= 75)
		{
			return Font.CR_Yellow;
		}
		else if (health <= 100)
		{
			return Font.CR_Green;
		}
		return Font.CR_Blue;
	}

	TextureID My_GetHealthIcon()
	{
		TextureID tex;
		tex.SetInvalid();
		let type = GameInfo.GameType;
		if (type & GAME_DoomChex)
		{
			if (CPlayer.mo.FindInventory('PowerStrength'))
			{
				tex= TexMan.CheckForTexture("PSTRA0");
			}
			else
			{
				tex = TexMan.CheckForTexture("MEDIA0");
			}
		}
		else if (type & GAME_Raven)
		{
			tex = TexMan.CheckForTexture("PTN1A0");
		}
		else if (type & GAME_Strife)
		{
			tex = TexMan.CheckForTexture("MDKTA0");
		}
		return tex;
	}

	void My_DrawHealthArmor(Vector2 pos, int flags)
	{
		// Icon size:
		Vector2 iconSize = (my_BigFontHeight, my_BigFontHeight);
		// Icon offsets:
		Vector2 iconOfs = (iconSize.x * 0.5, iconSize.y * -0.5);

		// Draw health icon:
		TextureID healthIcon = My_GetHealthIcon();
		if (healthIcon.IsValid())
		{
			DrawTexture(healthIcon,
				pos + iconOfs,
				flags|DI_ITEM_CENTER,
				box: iconSize
			);
		}
		else
		{
			Vector2 crossPos = pos + iconOfs;
			double crossWidth = 4;
			double crossLength = 10;
			Fill(0xffffffff,
				crossPos.x - crossLength*0.5,
				crossPos.y - crossWidth*0.5,
				crossLength,
				crossWidth,
				flags);
			Fill(0xffffffff,
				crossPos.x - crossWidth*0.5,
				crossPos.y - crossLength*0.5,
				crossWidth,
				crossLength,
				flags);
		}
		My_DrawHealthBar(
			(pos.x + iconSize.x + 4, pos.y - iconSize.y*0.75),
			72,
			iconSize.y*0.5,
			flags
		);
		DrawString(my_BigFont,
			String.Format("%d", CPlayer.health),
			pos + (iconSize.x + 40, -my_BigFontHeight*0.7),
			flags|DI_TEXT_ALIGN_CENTER,
			scale: (0.5, 0.5)
		);
		// Draw health text:
		/*DrawString(my_BigFont,
			String.Format("%d", CPlayer.health),
			pos + (iconSize.x + 4, -my_BigFontHeight*0.75),
			flags,
			translation: My_GetHealthColor(CPlayer.health)
		);*/

		pos.y -= iconSize.y;

		// Find BasicArmor in player's inventory:
		let armr = BasicArmor(CPlayer.mo.FindInventory('BasicArmor', true));
		// If there's no armor (for some reason), or there is
		// but its amount is 0, stop here and do nothing else:
		if (!armr || armr.amount <= 0) return;

		// Draw armor icon:
		DrawTexture(armr.icon,
			pos + iconOfs,
			flags|DI_ITEM_CENTER,
			box: iconSize
		);
		// Draw armor text:
		DrawString(my_BigFont,
			String.Format("%d", armr.amount),
			pos + (iconSize.x + 4, -my_BigFontHeight*0.75),
			flags,
			translation: My_GetArmorColor(armr.savepercent) //get color from our new function
		);
	}

	String My_GetAmmoColorCode(int amount, int maxamount)
	{
		if (amount >= maxamount*0.5)
		{
			return "\cd"; //green
		}
		else if (amount >= maxamount*0.25)
		{
			return "\ck"; //yellow
		}
		else if (amount > 0)
		{
			return "\cg"; //red
		}
		return "\cr"; //dark red
	}


	void My_DrawCurrentAmmo(Vector2 pos, int flags)
	{
		let [am1, am2, am1amt, am2amt] = GetCurrentAmmo();
		// Stop here if there's no current ammo:
		if (!am1 && !am2) return;

		// Icon size and offsets:
		Vector2 iconSize = (my_BigFontHeight, my_BigFontHeight);
		Vector2 iconOfs = (iconSize.x * 0.5, iconSize.y * 0.5);

		// Find out which of the current ammo types has the
		// biggest maximum amount:
		int biggestAmt = max (am1? am1.maxamount : 0, am2? am2.maxamount : 0);
		// Construct a dummy "current/max" string using that amount:
		String dummyString = String.Format("%d/%d", biggestAmt, biggestAmt);
		// And get that string's pixel width in our font:
		int ammoStringWidth = my_BigFontMono.mFont.GetCharWidth("0") * dummyString.Length();
		// Shift draw position left by ammo string width + icon width:
		pos.x -= ammoStringWidth + iconSize.x;

		// Check how many ammo types we have:
		int ammoTypes;
		if (am1) ammoTypes++;
		if (am2) ammoTypes++;
		// Shift draw position up by icon height multiplied by ammo types:
		pos.y -= iconSize.y * ammoTypes;

		// Calculate how much we'll need to pad strings based
		// on the length of the largest amount string:
		int padding = String.Format("%d", biggestAmt).Length();

		// Check if ammo 1 is valid:
		if (am1)
		{
			// Draw an icon:
			DrawTexture(am1.icon,
				pos + iconOfs,
				flags|DI_ITEM_CENTER,
				box: iconSize);
			// Draw the amounts, colorized and padded:
			DrawString(my_BigFontMono,
				String.Format("%s%*d\cu/\cc%*d", My_GetAmmoColorCode(am1amt, am1.maxamount), padding, am1amt, padding, am1.maxamount),
				pos + (iconsize.x, my_BigFontHeight*0.25),
				flags);
				
			// Shift vertical position for the next ammo type:
			pos.y += iconSize.x;
		}
		// Draw ammo 2's icon and text the same way:
		if (am2)
		{
			DrawTexture(am2.icon,
				pos + iconOfs,
				flags|DI_ITEM_CENTER,
				box: iconSize);
			// Draw the amounts, colorized and padded:
			DrawString(my_BigFontMono,
				String.Format("%s%*d\cu/\cc%*d", My_GetAmmoColorCode(am2amt, am2.maxamount), padding, am2amt, padding, am2.maxamount),
				pos + (iconsize.x, my_BigFontHeight*0.25),
				flags);
		}
	}

	void My_DrawKeys(Vector2 pos, int flags, Vector2 iconSize, int indent = 0)
	{
		Vector2 kpos = pos;
		Vector2 iconOfs = iconSize*0.5;
		int column = 1;
		for (int i = 0; i < Key.GetKeyTypeCount(); i++)
		{
			class<Key> keyclass = Key.GetKeyType(i);
			let k = CPlayer.mo.FindInventory(keyclass);
			// check if player has this key:
			if (k)
			{
				// If so, obtain its sprite (skip the icon):
				TextureID tex = GetInventoryIcon(k, DI_SKIPICON);
				// And draw that sprite:
				DrawTexture(tex, kpos + iconOfs, flags|DI_ITEM_CENTER, box: iconSize);
			}
			if (column < 3)
			{
				kpos.x += iconSize.x + indent;
				column++;
			}
			else
			{
				kpos.x = pos.x;
				kpos.y += iconSize.y + indent;
				column = 1;
			}
		}
	}

	void My_UpdateAmmoClasses()
	{
		if (my_ammoToDisplay.Size() > 0) return;

		let weapSlots = CPlayer.weapons;
			
		for (int slot = 1; slot <= 10; slot++)
		{
			if (slot == 10) slot = 0;

			int slotSize = weapSlots.SlotSize(slot);
			if (slotSize <= 0)
			{
				if (slot == 0)
				{
					break;
				}
				else
				{
					continue;
				}
			}

			for (int slotId = 0; slotId < slotSize; slotId++)
			{
				class<Weapon> weapCls = weapSlots.GetWeapon(slot, slotId);
				if (weapCls)
				{
					class<Ammo> am1cls, am2cls;
					let weap = Weapon(CPlayer.mo.FindInventory(weapcls));
					if (weap)
					{
						am1cls = weap.ammotype1;
						am2cls = weap.ammotype2;
					}
					else
					{
						let weapDef = GetDefaultByType(weapcls);
						am1cls = weapDef.ammotype1;
						am2cls = weapDef.ammotype2;
					}
					if (am1cls && my_ammoToDisplay.Find(am1cls) == my_ammoToDisplay.Size())
					{
						my_ammoToDisplay.Push(am1cls);
					}
					if (am2cls && am2cls != am1cls && my_ammoToDisplay.Find(am2cls) == my_ammoToDisplay.Size())
					{
						my_ammoToDisplay.Push(am2cls);
					}
				}
			}
			if (slot == 0)
			{
				break;
			}
		}
	}


	void My_DrawAllAmmo(Vector2 pos, int flags, Vector2 iconSize)
	{
		if (!CPlayer.mo.FindInventory('Ammo', true)) return;
		My_UpdateAmmoClasses();
		if (my_ammoToDisplay.Size() == 0) return;

		int biggestAmt;
		for (int i = 0; i < my_ammoToDisplay.Size(); i++)
		{
			class<Ammo> amcls = my_ammoToDisplay[i];
			if (!amcls) continue;

			let am = Ammo(CPlayer.mo.FindInventory(amcls));
			if (am)
			{
				biggestAmt = max(biggestAmt, am.maxamount);
			}
		}

		double fontscale = iconSize.y / my_BigFontHeight;
		String dummyString = String.Format("%d/%d", biggestAmt, biggestAmt);
		int ammoStringWidth = my_BigFontMono.mFont.GetCharWidth("0") * dummyString.Length();
		pos.x -= ammoStringWidth * fontscale + iconSize.x;
		int padding = String.Format("%d", biggestAmt).Length();

		for (int i = 0; i < my_ammoToDisplay.Size(); i++)
		{
			class<Ammo> amcls = my_ammoToDisplay[i];
			if (!amcls) continue;

			Ammo ownedAmmo = Ammo(CPlayer.mo.FindInventory(amcls));
			if (!ownedAmmo) continue;
			
			DrawInventoryIcon(ownedAmmo,
				pos + iconSize*0.5,
				flags|DI_ITEM_CENTER,
				boxSize: iconSize
			);

			DrawString(my_BigFontMono,
				String.Format("%*d/%*d", padding, ownedAmmo.amount, padding, ownedAmmo.maxamount),
				pos + (iconsize.x + 1, my_BigFontHeight*fontscale*0.25),
				flags,
				scale: (fontscale, fontscale)
			);
			pos.y += iconSize.y;
		}
	}

	void My_DrawCompass(Vector2 pos, int flags, double TicFrac)
	{
		double lerpedAngle = my_prevPlayerAngle + (my_currPlayerAngle - my_prevPlayerAngle) * TicFrac;
		double pAngle = -lerpedAngle + 90;

		Vector2 cScale = (4, 4);
		if (hud_aspectscale == true)
		{
			cScale.y *= 1.2;
			pos.y /= 1.2;
		}

		DrawImageRotated("graphics/myHudCompass.png",
			pos,
			flags,
			pAngle,
			scale: cScale
		);
	}

	void My_CycleInvBarRight()
	{
		if (!my_invbar) return;

		my_invbar.selectofs.x -= my_invbar.boxsize.x;
	}

	void My_CycleInvBarLeft()
	{
		if (!my_invbar) return;

		my_invbar.selectofs.x += my_invbar.boxsize.x;
	}
}

class My_Math
{
	static clearscope double LinearMap(double val, double source_min, double source_max, double out_min, double out_max, bool clampResult = false) 
	{
		double sourceDiff = source_max - source_min;
		if (sourceDiff == 0)
		{
			return 0;
		}
		double d = (val - source_min) * (out_max - out_min) / sourceDiff + out_min;
		if (clampResult)
		{
			double truemax = out_max > out_min ? out_max : out_min;
			double truemin = out_max > out_min ? out_min : out_max;
			d = Clamp(d, truemin, truemax);
		}
		return d;
	}
}

class My_HudHandler : EventHandler
{
	override bool InputProcess (InputEvent e)
	{
		if (e.Type != InputEvent.Type_KeyDown)
		{
			return false;
		}

		let myhud = MyFullscreenHUD(statusbar);
		if (!myhud) return false;

		array<int> buttons;
		Bindings.GetAllKeysForCommand(buttons, "invnext");
		if(buttons.Find(e.keyScan) != buttons.Size())
		{
			myhud.My_CycleInvBarRight();
		}
		buttons.Clear();
		Bindings.GetAllKeysForCommand(buttons, "invprev");
		if(buttons.Find(e.keyScan) != buttons.Size())
		{
			myhud.My_CycleInvBarLeft();
		}
		return false;
	}
}

class My_LinearValueInterpolatorUI : Object
{
	double mCurrentValue;
	double mMaxChange;

	static My_LinearValueInterpolatorUI Create(double startval, double maxchange)
	{
		let v = new("My_LinearValueInterpolatorUI");
		v.mCurrentValue = startval;
		v.mMaxChange = maxchange;
		return v;
	}

	void Reset(double value)
	{
		mCurrentValue = value;
	}

	void Update(double destvalue, double deltatime = 1.0)
	{
		if (mCurrentValue > destvalue)
		{
			mCurrentValue = max(destvalue, mCurrentValue - mMaxChange * deltatime);
		}
		else
		{
			mCurrentValue = min(destvalue, mCurrentValue + mMaxChange * deltatime);
		}
	}
	
	double, int GetValue()
	{
		return mCurrentValue, int(round(mCurrentValue));
	}
}