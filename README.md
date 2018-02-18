[Join us on Discord!](https://discord.gg/yRUZcdQ)

# [![RMEx](http://rmex.github.io/images/rmex-shortcut.png)](http://rmex.github.io) [ORMS : Old RPG Maker Style](https://github.com/RMEx/orms/blob/master/orms.rb) v1.1.0
> Make a RM2K(3)-like game with RMVXAce!

![Screenshot](http://image.noelshack.com/fichiers/2018/08/1/1518996809-rm-fucking-vx-ace.gif)

***

# ChangeLog

> - `v1.0.0 => 06/02/2018` First release
> - `v1.0.1 => 08/02/2018` RME + Fullscreen++ compatibility
> - `v1.0.3 => 09/02/2018` Change RME issue + clean `TOGGLE_SCREEN_INPUT` + add wrong version number \o/
> - `v1.0.4 => 16/02/2018` Fix transitions + missing update for `PIXELATE_SCREEN`
 - `v1.1.0 => 18/02/2018`**[Current]**
    - Fix `USE_OLD_RM_...` (did not double the size when the HUE was changed)
    - Fix `OLDSCHOOL_CHOICE_LIST` (the box wasn't displayed when there were no message displayed before)
    - Add `Orms.set(feature, state)`, `Orms.activate` and `Orms.deactivate` ingame methods for users
    - Change `TOGGLE_SCREEN_INPUT` to new `TOGGLE_FULLSCREEN` and `TOGGLE_WINDOW_MODE` features that allow to specify which shortcut you want to set
    - The shortcuts defined above now change also the `Fullscreen++` shortcuts
    - Implement dynamic frame skipping for the `PIXELATE_SCREEN` feature!
    - Implement additional FPS displayer which takes into account the dynamic frame skipping! Display it with `F2`!
    - Add `PIXELATION_SHORTCUT` to set a shortcut that activate/deactivate the screen pixelation ingame!

***

# Installation

- Add [the script](https://raw.githubusercontent.com/RMEx/orms/master/orms.rb) in your project
- Place [Font.png](https://raw.githubusercontent.com/RMEx/orms/master/Font.png) and [Font_color.png](https://raw.githubusercontent.com/RMEx/orms/master/Font_color.png) in the `Graphics/System/` folder

---

# Configuration

OLD_RM_STYLE is really versatile, see the first module **ORMS_CONFIG** to configure it.

---

# Features

All the features are **optional**, just activate the features you want in **ORMS_CONFIG** and enjoy!

## BITMAP_FONT

Use the bitmaps **Font** and **Font_color** to draw texts

Image name | Example
--- | ---
Font.png | ![Font.png](Font.png)
Font_color.png | ![Font_color.png](Font_color.png)

## BITMAP_FONT OPTIONS:
Option | Description | Default value
--- | --- | ---
**FONT_WIDTH<br>FONT HEIGHT** | The character size of your font bitmap | 6 x 14
**DOUBLE_FONT_SIZE** | Double the size of the bitmap font/text | true
**LINE_HEIGHT** | Change the line height | 32
**PADDING** | Change the padding of the message and battle windows | 16
**SHADOW** | Draw text shadow using the last color in "Font_color.png" | true
**REWRITE_ALL_TEXTS** | Rewrite Bitmap.draw_text instead of Window_Base.draw_text | true

## BOX_FEATURES:
Feature | Description | Default value
--- | --- | ---
**OPAQUE_BOX** | Opaque text box if true | false
**STOP_CURSOR_BLINKING** | Stop cursor blinking if true | true
**OLDSCHOOL_CHOICE_LIST** | RM2K(3)-like choice list like if true | true

## SCREEN_FEATURES:
Feature | Description | Default value
--- | --- | ---
**OLD_RESOLUTION** | Just set game resolution to 640*480 (to simulate RM2k(3)'s 320*240) | false
**TOGGLE_FULLSCREEN** | The shortcut (:F3..:F11) to toggle the fullscreen mode like RM2k(3).<br><br>Set the shortcut to 0 if you want none. | :F4
**TOGGLE_WINDOW_MODE** | The shortcut (:F3..:F11) to toggle to TINY 1x WINDOW MODE like RM2k(3).<br><br>Set the shortcut to 0 if you want none. | :F5
**PIXELATE_SCREEN** | If you want fat pixels everywhere!<br><br>This feature is a bit greedy, but it tries to optimize itself with a custom frame skipping method.<br><br>This feature activate a custom FPS display (F2) that shows the real FPS, counting the frame skipping. | false
**PIXELATION_SHORTCUT** | The shortcut (:F3..:F11) to activate/deactivate pixelation ingame.<br><br>Set the shortcut to 0 if you want none.<br><br>Don't forget to tell the player he can use this shortcut! An alternative is to use the `Orms.set(:pixelate_screen, false)` method. | :F6

### NOTE:
**TOGGLE_FULLSCREEN** and **TOGGLE_WINDOW_MODE** re-define also the Fullscreen++ shortcuts if you use it too. If you use Fullscreen++, place Fullscreen++ right before orms!

[Get Fullscreen++](https://forums.rpgmakerweb.com/index.php?threads/fullscreen.14081/)

## RESSOURCES_FEATURES:
Use these features if you want to directly use RM2k(3) ressources!

Feature | Description | Default value
--- | --- | ---
**USE_OLD_RM_BACKDROP** | Battlebacks1/2 auto-resized by two | false
**USE_OLD_RM_MONSTER** | Battlers auto-resized by two | false
**USE_OLD_RM_PANORAMA** | Parallaxes auto-resized by two | false
**USE_OLD_RM_PICTURE** | Pictures auto-resized by two | false
**USE_OLD_RM_TITLE** | Titles1/2 auto-resized by two | false
**USE_OLD_RM_CHARSET** | Characters auto-resized by two | false
**BACKDROP_ALIGN_TOP** | Align Battlebacks to top instead of center (for RM2K backdrops) | false
**KILL_CHARSET_SHIFT_Y** | Does as if all "Characters" had "!" in their name | false
**OLD_CHARSET_DIRECTION** | In VXAce's ressources, directions are "DOWN, LEFT, RIGHT, UP" but in RM2k(3)'s ressources, it's "UP, RIGHT, DOWN, LEFT"<br><br>this fix allows you to use directly charsets from 2k(3)! | false

## DESTROY_NEW_RM_FEATURE:
Feature | Description | Default value
--- | --- | ---
**DEACTIVATE_DASH** | No dash when you press shift if true | false


---

# Examples

![Screenshot](https://cdn.discordapp.com/attachments/410124292244766741/410207355993849867/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/410124292244766741/410206525961797644/unknown.png)

> Example of the **OLDSCHOOL_CHOICE_LIST** and **TOGGLE_WINDOW_MODE** features

![Screenshot](https://cdn.discordapp.com/attachments/166299388799483904/409870616691212289/unknown.png)

> Example of the **DOUBLE_FONT_SIZE** feature (false)

![Screenshot](https://cdn.discordapp.com/attachments/166299388799483904/409871176681127936/unknown.png)

> Example of the default menu displayed with the **BITMAP_FONT** feature

![Screenshot](https://cdn.discordapp.com/attachments/410183660520865793/413601725966974976/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/410183660520865793/413601891281272832/unknown.png)
![Screenshot](https://cdn.discordapp.com/attachments/410183660520865793/413601963465375744/unknown.png)

> Examples of a game using orms and Luna Engine (by **JosephSeraph**)

![Screenshot](https://cdn.discordapp.com/attachments/410183660520865793/410261416956657675/unknown.png)

> Example of a **customized** bitmap font (by **JosephSeraph**)

---

# HOW TO MAKE YOUR OWN AWESOME BITMAP FONT

The **Font.png** is generated by the awesome tool [Fony](https://fony.en.softonic.com/#app-softonic-review)

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

**NOTE :** You also need to have **all the right column transparent** for all the characters, to render the text shadow without trouble!

Use the same method as above, but with the **"left"** button!

6. Save your new font, and do **File > Export > Bitmap**, save as "Font.png" in `Graphics/System/`

Then you get A SHINY PERFECT NEW "FONT.PNG" YOU CAN EDIT BACK WITH FONY ULTRA QUICKLY ANYTIME!!

![Font](http://image.noelshack.com/fichiers/2018/06/1/1517860144-awesome-font.png)

Instead of **6\*14** like RM200(3), this one is **7\*11** (just count the pixels in Fony), you can specify that in my script :

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

# CUSTOM FONT ISSUES WITH FONY

Of course you can edit the font you want with Fony, ".fon" or not. But there is some important things to verify before the bitmap exportation!

* You **must** have a **blank row** at the bottom and a **blank column** at the right

  ![Screenshot](http://image.noelshack.com/fichiers/2018/07/7/1518994050-fony-blank-row-column.png)

  If not, just select all the characters into the right pannel and use the arrows button.

* In **Edit > Properties** (Ctrl + H), you **must** set the **First char** to 0, tue **Last char** to 255 and check **Monospaced**

  ![Screenshot](http://image.noelshack.com/fichiers/2018/07/7/1518993684-fony-properties.png)

---

# COMING SOON!

**TODO LIST:**

- [x] **Fix** `OLDSCHOOL_CHOICE_LIST` (no box when no message is displayed before the choice list)
- [x] **Verify/fix** compatibility between `PIXELATE_SCREEN` and some nervous scripts
    - [x] RME (camera commands)
    - [x] Luna Engine
    - [ ] Theo's Sideview battle system
    - [ ] MGC's mode 7
- [x] **Add** methods to deactivate/activate the features ingame... like `Orms.switch(:pixelate_screen, false)`
- [x] **Add** the feature `BACKDROP_ALIGN_TOP` to use RM2K backdrops that are cut at the bottom (actually the backdrop is centered in RMVXA)
- [x] **Change** the scope of `PADDING` to change the main battle box padding too (to fit the previous feature)
- [x] **Implement** dynamic frame skipping for `PIXELATE_SCREEN`
- [x] **Add** the parameter `TOGGLE_SHORTCUT` to `PIXELATE_SCREEN` to add a shortcut (for instance F7) for the player to toggle pixelation ON/OFF (pop a tiny discrete message like "pixelation OFF")
- [x] **Add** the parameters `FULLSCREEN_SHORTCUT` and `CHANGE_MODE_SHORTCUT` to `TOGGLE_SCREEN_INPUT`to change the default shortcuts (F4/F5), change Fulscreen++ shortcuts as well. (And find a better name for `toogle_screen_input`)
- [ ] **Add** methods to set a `start_transition` and a `end_transition` in events for teleports and... reproduce all RM(2)K3 start/end transitions? :D
- [ ] **Change** `STOP_CURSOR_BLINKING` to fancy new `OLD_RM_CURSOR_BLINKING` (use a new system picture to make oldschool blink like RM2k(3) (graphical switch blinking))
- [ ] **Add** the feature `ICONS_FOR_ALL_TEXTS` to use `\I[id]` code like in dialogues, but for everything (name/description of objects, skills, etc) like RM2K(3) did with glyphs
- [ ] **Add** the feature `NO_MAP_SHADOWS` to deactivate the VXA shadow display in maps ingame.
- [ ] [orms-converter](https://github.com/RMEx/orms-converter)
- [ ] Sleep
- [ ] Any suggestion? ...Bug report? Feel free to [create an issue](https://github.com/RMEx/orms-converter/issues) or contact me [on Discord!](https://discord.gg/yRUZcdQ)