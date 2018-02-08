# OLD_RM_STYLE
Make a RM2K(3)-like game with RMVXAce!

---

## INSTALLATION

- Add [the script](https://raw.githubusercontent.com/RMEx/OLD_RM_STYLE/master/OLD_RM_STYLE.rb) in your project
- Place [Font.png](https://raw.githubusercontent.com/RMEx/OLD_RM_STYLE/master/Font.png) and [Font_color.png](https://raw.githubusercontent.com/RMEx/OLD_RM_STYLE/master/Font_color.png) in the `Graphics/System/` folder

---

## CONFIGURATION

OLD_RM_STYLE is really versatile, see the first module **ORMS_CONFIG** to configure it.

---

## FEATURES

- Can use "Graphics/System/Font.png" and "Graphics/System/Font_color.png" to write awesome OldSchool texts
- Can make the window box opaque (like RM2K) and/or stop the cursor blinking
- Can display the choice list inside the dialogue like RM2K(3)
- Can set shortcuts F4: toggle fullscreen, F5: toggle AWESOME TINY WINDOW MODE

Example of tiny windows mode:

![Screenshot](https://cdn.discordapp.com/attachments/166299388799483904/409985784473583616/unknown.png)

- Can pixelate the screen display (for the care of the detail)
- Can set the resolution to 640*480 (okay, it's just one line BUT YES IT CAN)
- Can use RM2K(3) graphics directly (set all RESSOURCES_FEATURES to "true")
- Can deactivate the dash (shift)

All texts will be rendered using the two pictures below if `ORMS_CONFIG::BMP_FONT` is `true`:

![Font.png](Font.png)
![Font_color.png](Font_color.png)

---

## EXAMPLES

![Screenshot](https://cdn.discordapp.com/attachments/410124292244766741/410207355993849867/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/410124292244766741/410206525961797644/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/166299388799483904/409870616691212289/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/166299388799483904/409871176681127936/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/410183660520865793/410261416956657675/unknown.png)


---

## How to make my own Font.png

The Font.png is generated with the awesome tool [Fony](https://fony.en.softonic.com/#app-softonic-review)

For example :

1. load "Bilou2k3.fon" with Fony

![Fony](https://cdn.discordapp.com/attachments/409692938164240385/409863729895702528/unknown.png)

2. Use **Edit > resize** to make a smaller font in height

![Fony](https://cdn.discordapp.com/attachments/166299388799483904/410158056631173121/unknown.png)

![Fony](https://cdn.discordapp.com/attachments/166299388799483904/410158136566087680/unknown.png)

3. Use **Edit > Boldify**... why not?

![Fony](https://cdn.discordapp.com/attachments/166299388799483904/410158494935810048/unknown.png)

After that you need to have **all the bottom line transparent** for all the characters, to render the text shadow without trouble after

4. Select all the characters in the right pannel

![Fony](https://cdn.discordapp.com/attachments/166299388799483904/410158956892127232/unknown.png)

5. Then press the **"up"** button

![Fony](https://cdn.discordapp.com/attachments/166299388799483904/410159035229405195/unknown.png)

6. Save your new font, and do **File > Export > Bitmap**, save as "Font.png" in `Graphics/System/`

The you get A SHINY PERFECT NEW "FONT.PNG" YOU CAN EDIT BACK WITH FONY ULTRA QUICKLY ANYTIME!!

![Font](http://image.noelshack.com/fichiers/2018/06/1/1517860144-awesome-font.png)

Instead of **6\*14** like RM200(3), this one is **7\*11** (just count the pixels in fony), you can specify that in my script :

```
# BITMAP_FONT_FEATURE_OPTIONS:
  FONT_WIDTH            = 7     # See BMP Font character's width
  FONT_HEIGHT           = 11    # See BMP Font character's height
```
instead of :
```
# BITMAP_FONT_FEATURE_OPTIONS:
  FONT_WIDTH            = 6     # See BMP Font character's width
  FONT_HEIGHT           = 14    # See BMP Font character's height
```

And since the height is now smaller, you can also reduce the line height :
```
  LINE_HEIGHT           = 24    # Line height: VXAce: 24  2K(3): 32
```

---

## COMING SOON

Why not a tiny tool to convert RM2K(3)'s Chipset to VXAce's Tilesets? :)
