	Vector3 RGBtoHSV(Color c)
	{
		double r = c.r / 255.0;
		double g = c.g / 255.0;
		double b = c.b / 255.0;

		double maxVal = max(r, max(g, b));
		double minVal = min(r, min(g, b));
		double delta = maxVal - minVal;

		double h = 0.0;
		double s = 0.0;
		double v = maxVal;

		// Compute Hue
		if (delta > 0.0)
		{
			if (maxVal == r)
			{
				h = 60.0 * ((g - b) / delta);
				if (h < 0.0) h += 360.0;
			}
			else if (maxVal == g)
			{
				h = 60.0 * ((b - r) / delta + 2.0);
			}
			else // maxVal == b
			{
				h = 60.0 * ((r - g) / delta + 4.0);
			}
		}
		else
		{
			h = 0.0; // undefined hue, achromatic
		}

		// Compute Saturation
		if (maxVal > 0.0)
		{
			s = delta / maxVal;
		}
		else
		{
			s = 0.0;
		}

		return (h, s, v);
	}

	Color HSVtoRGB(Vector3 hsv)
	{
		double h = hsv.x;
		double s = clamp(hsv.y, 0.0, 1.0);
		double v = clamp(hsv.z, 0.0, 1.0);

		double r = 0.0;
		double g = 0.0;
		double b = 0.0;

		if (s == 0.0)
		{
			// Achromatic (grey)
			r = g = b = v;
		}
		else
		{
			h = h - 360.0 * floor(h / 360.0);
			if (h < 0.0) h += 360.0;

			double sector = h / 60.0;
			int i = int(floor(sector));
			double f = sector - i;

			double p = v * (1.0 - s);
			double q = v * (1.0 - s * f);
			double t = v * (1.0 - s * (1.0 - f));

			if (i == 0) {
				r = v; g = t; b = p;
			} else if (i == 1) {
				r = q; g = v; b = p;
			} else if (i == 2) {
				r = p; g = v; b = t;
			} else if (i == 3) {
				r = p; g = q; b = v;
			} else if (i == 4) {
				r = t; g = p; b = v;
			} else {
				r = v; g = p; b = q;
			}
		}

		return Color(
			255,                              // Alpha
			int(round(clamp(r * 255.0, 0.0, 255.0))),
			int(round(clamp(g * 255.0, 0.0, 255.0))),
			int(round(clamp(b * 255.0, 0.0, 255.0)))
		);
	}

	Color My_GetInterColor(Color from, Color to, double distance)
	{
		distance = clamp(distance, 0.0, 1.0);
	
		// Interpolate alpha linearly
		int a = int(round(from.a + (to.a - from.a) * distance));
	
		// Convert RGB to HSV
		Vector3 hsvFrom = RGBtoHSV(from);
		Vector3 hsvTo   = RGBtoHSV(to);
	
		// Interpolate Hue (circular interpolation)
		double h1 = hsvFrom.x;
		double h2 = hsvTo.x;
	
		if (abs(h2 - h1) > 180.0)
		{
			if (h2 > h1)
				h1 += 360.0;
			else
				h2 += 360.0;
		}
	
		double temp = h1 + (h2 - h1) * distance;
		double h = temp - 360.0 * floor(temp / 360.0);
		if (h < 0.0) h += 360.0;
	
		// Interpolate Saturation and Value linearly
		double s = hsvFrom.y + (hsvTo.y - hsvFrom.y) * distance;
		double v = hsvFrom.z + (hsvTo.z - hsvFrom.z) * distance;
	
		// Convert back to RGB
		Color rgb = HSVtoRGB((h, s, v));
	
		return color(a, rgb.r, rgb.g, rgb.b);
	}