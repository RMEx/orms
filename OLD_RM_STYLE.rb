# -*- coding: utf-8 -*-
#==============================================================================
# ** OLD_RM_TEXT  V. 1.0.2
#------------------------------------------------------------------------------
# Joke <joke@biloucorp.com>
#------------------------------------------------------------------------------
# Make a RM2K(3)-like game with RMVXAce!
# Use "Graphics/System/Font.png" and "Graphics/System/Font_color.png"
#==============================================================================

#==============================================================================
# ** Configuration
#------------------------------------------------------------------------------
#  "OLDSCHOOL_CHOICE_LIST" : Display choice list like RM2003 did!
#==============================================================================

module ORMS_CONFIG

# BITMAP_FONT:
  BITMAP_FONT           = true  # Use BMP Font if true

# BITMAP_FONT_OPTIONS:
  FONT_WIDTH            = 6     # See BMP Font character's width
  FONT_HEIGHT           = 14    # See BMP Font character's height
  DOUBLE_FONT_SIZE      = true  # Double the BMP Font Size if true
  LINE_HEIGHT           = 32    # Line height: VXAce: 24  2K(3): 32
  PADDING               = 16    # Padding:     VXAce: 12  2K(3): 16
  SHADOW                = true  # Draw text shadow using the last color in "Font_color.png"
  REWRITE_ALL_TEXTS     = false # Rewrite Bitmap.draw_text instead of Window_Base.draw_text
                                #   Try this only if you have problem of compatibility
                                #   Can create other problems... It's like blue/red pills!
# BOX_OPTIONS:
  OPAQUE_BOX            = false # Opaque text box if true
  CURSOR_BLINKING       = false # Stop cursor blinking if false
  OLDSCHOOL_CHOICE_LIST = true  # RM2K(3)-like choice list like if true

# SCREEN_OPTIONS:
  TOGGLE_SCREEN_INPUT   = false # RM2K(3)-like F4 and F5 input
  PIXELATE_SCREEN       = false # If you want fat pixels everywhere
  OLD_RESOLUTION        = false # Just set game resolution to 640*480

# RESSOURCES_OPTIONS
  USE_OLD_RM_BACKDROP   = false # Battlebacks1/2 auto-resized by two
  USE_OLD_RM_MONSTER    = false # Battlers auto-resized by two
  USE_OLD_RM_PANORAMA   = false # Parallaxes auto-resized by two
  USE_OLD_RM_PICTURE    = false # Pictures auto-resized by two
  USE_OLD_RM_TITLE      = false # Titles1/2 auto-resized by two
  USE_OLD_RM_CHARSET    = false # Characters auto-resized by two
  KILL_CHARSET_SHIFT_Y  = false # Does as if all "Characters" had "!" in their name
  FIX_CHARSET_DIRECTION = false # In VXAce's ressources, directions are "DOWN, LEFT, RIGHT, UP"
                                #   but in RM2k(3)'s ressources, it's "UP, RIGHT, DOWN, LEFT"
                                #   this fix allows you to use directly charsets from 2k(3)!
end

#==============================================================================
# ** BITMAP_FONT and USE_OLD_RM_*
#==============================================================================

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads graphics, creates bitmap objects, and retains them.
# Now it can double the size of bitmaps specified in ORMS_CONFIG at loading
# And it generates and retains the BITMAP_FONT
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Generate Bitmap Font
    #--------------------------------------------------------------------------
    def generate_bitmap_font
      mask  = Bitmap.new("Graphics/System/Font")
      color_set = Bitmap.new("Graphics/System/Font_color")
      bmp_font = Bitmap.new(mask.width, mask.height * 32)
      # draw shadow
      if ORMS_CONFIG::SHADOW
        shadow_color = color_set.get_pixel(127, 63)
        shadow = Bitmap.new(mask.width, mask.height)
        shadow.height.times do |y|
          shadow.width.times do |x|
            if mask.get_pixel(x, y).red == 255
              shadow.set_pixel(x, y, shadow_color)
            end
          end
        end
        32.times do |i|
          bmp_font.blt(1, i * mask.height + 1, shadow, mask.rect)
        end
      end
      # draw font
      mask.height.times do |y|
        mask.width.times do |x|
          if mask.get_pixel(x, y).red == 255
            32.times do |i|
              xc = i % 8 * 16 + x % ORMS_CONFIG::FONT_WIDTH
              yc = i / 8 * 16 + y
              bmp_font.set_pixel(x, y + i * mask.height, color_set.get_pixel(xc, yc))
            end
          end
        end
      end
      bmp_font
    end
    #--------------------------------------------------------------------------
    # * Get Bitmap Font
    #--------------------------------------------------------------------------
    def bitmap_font
      if @cache[:bitmap_font] && @cache[:bitmap_font].disposed?
        @cache[:bitmap_font] = generate_bitmap_font
      end
      @cache[:bitmap_font] ||= generate_bitmap_font
    end
    #--------------------------------------------------------------------------
    # * Load Bitmap
    #--------------------------------------------------------------------------
    alias_method :orms_load_bitmap, :load_bitmap
    def load_bitmap(*args)
      case args[0]
      when "Graphics/Battlebacks1/", "Graphics/Battlebacks2/"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_BACKDROP
      when "Graphics/Battlers/"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_MONSTER
      when "Graphics/Characters/"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_CHARSET
      when "Graphics/Parallaxes"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_PANORAMA
      when "Graphics/Pictures"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_PICTURE
      when "Graphics/Titles1", "Graphics/Titles2"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_TITLE
      end
      orms_load_bitmap(*args)
    end
    #--------------------------------------------------------------------------
    # * Load Bitmap to be resized by two
    #--------------------------------------------------------------------------
    def load_2k_bitmap(folder_name, filename, hue = 0)
      @cache ||= {}
      if filename.empty?
        empty_bitmap
      elsif hue == 0
        normal_2k_bitmap(folder_name + filename)
      else
        hue_changed_bitmap(folder_name + filename, hue)
      end
    end
    #--------------------------------------------------------------------------
    # * Create/Get Normal Bitmap resized by two
    #--------------------------------------------------------------------------
    def normal_2k_bitmap(path)
      unless include?(path)
        bmp = Bitmap.new(path)
        @cache[path] = Bitmap.new(bmp.width*2, bmp.height*2)
        @cache[path].stretch_blt(@cache[path].rect, bmp, bmp.rect)
      end
      @cache[path]
    end
  end
end

#==============================================================================
# ** BITMAP_FONT
#==============================================================================

if ORMS_CONFIG::BITMAP_FONT

#==============================================================================
# ** ORMS_Bitmap_Font
#------------------------------------------------------------------------------
#  This module writes texts using Cache.bitmap_font.
# It extends the behaviour of Window_Base  if REWRITE_ALL_TEXTS is FALSE
# It extends the behaviour of Bitmap class if REWRITE_ALL_TEXTS is TRUE
#==============================================================================

module ORMS_Bitmap_Font
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Included
    #     Callback invoked whenever the receiver is included in another module
    #     or class.
    #--------------------------------------------------------------------------
    def included(base)
      base.class_eval do
        #--------------------------------------------------------------------------
        # * Get Text Size
        #--------------------------------------------------------------------------
        def text_size(str)
          s = ORMS_CONFIG::DOUBLE_FONT_SIZE ? 2 : 1
          w = ORMS_CONFIG::FONT_WIDTH
          h = ORMS_CONFIG::FONT_HEIGHT
          Rect.new(0, 0, s * w * str.length, s * h)
        end
        #--------------------------------------------------------------------------
        # * Draw Text
        #     args : Same as Bitmap#draw_text. but in addition [, color_id] (default = 0)
        #--------------------------------------------------------------------------
        def draw_text(*args)
          if args.length.between?(2,4)
            x, y, width, text = args[0].x, args[0].y, args[0].width, args[1].to_s.clone
            align    = args[2] || 0
            color_id = args[3] || @color_id || 0
          else
            x, y, width, text = args[0], args[1], args[2], args[4].to_s.clone
            align    = args[5] || 0
            color_id = args[6] || @color_id || 0
          end
          if align == 1
            x = x + (width - text_size(text).width) / 2
          end
          if align == 2
            x = x + width - text_size(text).width
          end
          until text.empty?
            draw_char(text.slice!(0, 1), x, y, color_id)
            x += ORMS_CONFIG::FONT_WIDTH * (ORMS_CONFIG::DOUBLE_FONT_SIZE ? 2 : 1)
          end
        end
        #--------------------------------------------------------------------------
        # * Draw One Character
        #--------------------------------------------------------------------------
        def draw_char(char, x, y, color_id = 0)
          s = ORMS_CONFIG::DOUBLE_FONT_SIZE ? 2 : 1
          w = ORMS_CONFIG::FONT_WIDTH
          h = ORMS_CONFIG::FONT_HEIGHT
          dest = Rect.new(x, y, w * s, h * s)
          src  = Rect.new(char.ord * w, color_id * h, w, h)
          if ORMS_CONFIG::REWRITE_ALL_TEXTS
            stretch_blt(dest, Cache.bitmap_font, src)
          else
            contents.stretch_blt(dest, Cache.bitmap_font, src)
          end
        end
      end
    end
  end
end

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Get Text Color
  #     n : Text color number (0..31)
  #--------------------------------------------------------------------------
  def text_color(n)
    @color_id = n
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #     args : Same as Bitmap#draw_text.
  #--------------------------------------------------------------------------
  def draw_text(*args)
    args.push(0) if args.length == 2 || args.length == 5
    args.push(@color_id)
    contents.draw_text(*args)
  end
  #--------------------------------------------------------------------------
  # * Get Text Colors
  #--------------------------------------------------------------------------
  def system_color;      text_color(6);   end;    # System
  def crisis_color;      text_color(4);   end;    # Crisis
  def knockout_color;    text_color(11);  end;    # Knock out
  def mp_cost_color;     text_color(10);  end;    # MP cost
  def power_up_color;    text_color(9);   end;    # Equipment power up
  def power_down_color;  text_color(11);  end;    # Equipment power down
  def tp_cost_color;     text_color(9);   end;    # TP cost
  #--------------------------------------------------------------------------
  # * Change Text Drawing Color
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  def change_color(color, enabled = true)
    contents.font.color.set(enabled ? color : text_color(3))
  end
  #--------------------------------------------------------------------------
  # * Calculate Line Height
  #     (font_size is killed so it does not calculate anything)
  #--------------------------------------------------------------------------
  def calc_line_height(text, restore_font_size = true)
    return line_height
  end
  #--------------------------------------------------------------------------
  # * Get Line Height
  #--------------------------------------------------------------------------
  def line_height
    return ORMS_CONFIG::LINE_HEIGHT
  end
end

if ORMS_CONFIG::REWRITE_ALL_TEXTS
  Bitmap.send(:include, ORMS_Bitmap_Font)
else
  Window_Base.send(:include, ORMS_Bitmap_Font)
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message
  #--------------------------------------------------------------------------
  # * Draw Face Graphic
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  alias_method :orms_draw_face, :draw_face
  def draw_face(*args)
    args[2] = args[3] = (contents_height - 96) / 2
    orms_draw_face(*args)
  end
  #--------------------------------------------------------------------------
  # * Get New Line Position
  #--------------------------------------------------------------------------
  def new_line_x
    x = [96, height - standard_padding].max
    $game_message.face_name.empty? ? 0 : x
  end
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size
  #--------------------------------------------------------------------------
  def standard_padding
    return ORMS_CONFIG::PADDING
  end
end

#==============================================================================
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  This window displays party member status on the menu screen.
#==============================================================================

class Window_MenuStatus
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_face(actor, rect.x + 1, rect.y + 1, enabled)
    draw_actor_simple_status(actor, rect.x + 108, rect.y)
  end
end

#==============================================================================
# ** Window_TitleCommand
#------------------------------------------------------------------------------
#  This window is for selecting New Game/Continue on the title screen.
#==============================================================================

class Window_TitleCommand
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    s = ORMS_CONFIG::DOUBLE_FONT_SIZE ? 2 : 1
    max = @list.map {|i| i[:name].length * ORMS_CONFIG::FONT_WIDTH * s}.max
    max + 2 * standard_padding + 8
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  def update_placement
    self.x = (Graphics.width - width) / 2
    self.y = 296 * Graphics.height / 480 #RM2k(3) style, OK?
  end
end

end

#==============================================================================
# ** OPAQUE_BOX
#==============================================================================

if ORMS_CONFIG::OPAQUE_BOX

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :orms_opaque_initialize, :initialize
  def initialize(*args)
    orms_opaque_initialize(*args)
    self.back_opacity = 255
  end
end

end

#==============================================================================
# ** CURSOR_BLINKING
#==============================================================================

if !ORMS_CONFIG::CURSOR_BLINKING

#==============================================================================
# ** Window
#------------------------------------------------------------------------------
#  The game window class. Created internally from multiple sprites.
#==============================================================================

class Window
  #--------------------------------------------------------------------------
  # * The cursor's blink status. If TRUE, the cursor is blinking.
  #     The default is TRUE, but this hack turn this FALSE anytime.
  #--------------------------------------------------------------------------
  def active
    @active
  end
  alias_method :orms_blink_active, :active=
  def active=(index)
    orms_blink_active(false)
    @active = index
  end
  #--------------------------------------------------------------------------
  # * The cursor box (Rect).
  #     Specifies a rectangle with coordinates based on the window's contents.
  #--------------------------------------------------------------------------
  alias_method :orms_blink_cursor_rect, :cursor_rect
  def cursor_rect
    orms_blink_active(false)
    orms_blink_cursor_rect
  end
end

end

#==============================================================================
# ** OLDSCHOOL_CHOICE_LIST
#==============================================================================

if ORMS_CONFIG::OLDSCHOOL_CHOICE_LIST

#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Public instance variables
  #--------------------------------------------------------------------------
  attr_reader :line_number
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :orms_choice_initialize, :initialize
  def initialize(*args)
    orms_choice_initialize(*args)
    @line_number = 0
  end
  #--------------------------------------------------------------------------
  # * New Line Character Processing
  #--------------------------------------------------------------------------
  alias_method :orms_choice_process_new_line, :process_new_line
  def process_new_line(text, pos)
    orms_choice_process_new_line(text, pos)
    @line_number += 1
  end
end

#==============================================================================
# ** Window_Message
#------------------------------------------------------------------------------
#  This message window is used to display text.
#==============================================================================

class Window_Message
  #--------------------------------------------------------------------------
  # * New Page
  #--------------------------------------------------------------------------
  alias_method :orms_choice_new_page, :new_page
  def new_page(text, pos)
    orms_choice_new_page(text, pos)
    @line_number = 0
  end
end

#==============================================================================
# ** Window_ChoiceList
#------------------------------------------------------------------------------
#  This window is used for the event command [Show Choices].
#==============================================================================

class Window_ChoiceList
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :oldschool_choice_initialize, :initialize
  def initialize(message_window)
    oldschool_choice_initialize(message_window)
    self.windowskin = Cache.system("Window").clone
    self.windowskin.fill_rect(Rect.new(0,0,168,64), Color.new(0,0,0,0))
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  def update_placement
    if (@message_window.line_number + $game_message.choices.size > 4)
      @message_window.input_pause
      @message_window.new_page("", {x:0, y:0, new_x:0, height:0})
    end
    self.x = @message_window.new_line_x + 6
    self.y = @message_window.y + @message_window.line_number * @message_window.line_height
    self.width = @message_window.width - self.x - 10
    self.height = fitting_height($game_message.choices.size)
    self.viewport ||= Viewport.new
    self.viewport.z = 200
  end
end

end

#==============================================================================
# ** FIX_CHARSET_DIRECTION
#==============================================================================

if ORMS_CONFIG::FIX_CHARSET_DIRECTION

#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes an instance of the
# Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
      direction = [2, 3, 1, 0][@character.direction / 2 - 1]
      index = @character.character_index
      pattern = @character.pattern < 3 ? @character.pattern : 1
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + direction) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
end

#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class handles events. Functions include event page switching via
# condition determinants and running parallel process events. Used within the
# Game_Map class.
#==============================================================================

class Game_Event
  alias_method :orms_setup_page_setting, :setup_page_settings
  #--------------------------------------------------------------------------
  # * Set Up Event Page Settings
  #--------------------------------------------------------------------------
  def setup_page_settings
    orms_setup_page_setting
    @original_direction = @direction = [8, 6, 2, 4][@page.graphic.direction / 2 - 1]
  end
end

end

#==============================================================================
# ** KILL_CHARSET_SHIFT_Y
#==============================================================================

if ORMS_CONFIG::KILL_CHARSET_SHIFT_Y

#==============================================================================
# ** Game_CharacterBase
#------------------------------------------------------------------------------
#  This base class handles characters. It retains basic information, such as 
# coordinates and graphics, shared by all characters.
#==============================================================================

class Game_CharacterBase
  #--------------------------------------------------------------------------
  # * Get Number of Pixels to Shift Up from Tile Position
  #--------------------------------------------------------------------------
  def shift_y
    return 0
  end
end

end

#==============================================================================
# ** PIXELATE_SCREEN and TOGGLE_SCREEN_INPUT
#==============================================================================

#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  This class performs the title screen processing.
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # * Close Command Window
  #     an "update" was missing, oooooh...
  #--------------------------------------------------------------------------
  def close_command_window
    @command_window.close
    update until @command_window.close?
    update
  end
end

#==============================================================================
# ** Graphics
#------------------------------------------------------------------------------
#  The module that carries out graphics processing.
#==============================================================================

class << Graphics
  alias_method :orms_graphics_update, :update
  #--------------------------------------------------------------------------
  # * Close Command Window
  #--------------------------------------------------------------------------
  def update
    Toggle_Screen.check_input if ORMS_CONFIG::TOGGLE_SCREEN_INPUT
    pixelate_screen           if ORMS_CONFIG::PIXELATE_SCREEN
    orms_graphics_update
  end
  #--------------------------------------------------------------------------
  # * Close Command Window
  #--------------------------------------------------------------------------
  def pixelate_screen
    w, h = Graphics.width / 2, Graphics.height / 2
    if @screen.nil? || @screen.disposed?
      @screen = Sprite.new
      @screen.zoom_x = 2
      @screen.zoom_y = 2
      @screen.bitmap = Bitmap.new(w, h)
      @screen.viewport = Viewport.new
      @screen.viewport.z = 500
    end
    snap = snap_to_bitmap
    @screen.visible = false
    @screen.bitmap.stretch_blt(Rect.new(0, 0, w, h), snap, snap.rect)
    @screen.visible = true
    snap.dispose
  end
end

#==============================================================================
# ** Toggle Screen
#------------------------------------------------------------------------------
#  The module that carries out screen mode switching.
#==============================================================================

module Toggle_Screen
  #--------------------------------------------------------------------------
  # * Singleton
  #--------------------------------------------------------------------------
  class << self
    #--------------------------------------------------------------------------
    # * Public instance variables
    #--------------------------------------------------------------------------
    attr_reader :toggle_size
    #--------------------------------------------------------------------------
    # * Win32API methods
    #--------------------------------------------------------------------------
    SetWindowPos 	       = Win32API.new 'user32', 'SetWindowPos', 'iiiiiii', 'i'
    SystemParametersInfo = Win32API.new 'user32', 'SystemParametersInfo', 'iipi', 'i'
    GetWindowRect        = Win32API.new 'user32', 'GetWindowRect', 'ip', 'i'
    GetClientRect        = Win32API.new 'user32', 'GetClientRect', 'ip', 'i'
    KeybdEvent 		       = Win32API.new 'user32.dll', 'keybd_event', 'iill', 'v'
    FindWindow           = Win32API.new'user32', 'FindWindow', 'pp', 'i'
    GetKeyState          = Win32API.new 'user32', 'GetKeyState', 'p', 'i'
    HWND                 = FindWindow.call 'RGSS Player', 0
    #--------------------------------------------------------------------------
    # * Check F4 and F5 keyboard state and toggle
    #--------------------------------------------------------------------------
    def check_input
      if GetKeyState.call(0x73) < 0
        toggle_fullscreen unless @f4
        @f4 = true
      else
        @f4 = false
      end
      if GetKeyState.call(0x74) < 0
        toggle_size unless @f5 || @toggle_fullscreen
        @f5 = true
      else
        @f5 = false
      end
    end
    #--------------------------------------------------------------------------
    # * Get borders_size (from the frame of the window)
    #--------------------------------------------------------------------------
    def borders_size
      GetWindowRect.call(HWND, wrect = [0, 0, 0, 0].pack('l4'))
      GetClientRect.call(HWND, crect = [0, 0, 0, 0].pack('l4'))
      wrect, crect = wrect.unpack('l4'), crect.unpack('l4')
      Rect.new(0, 0, wrect[2]-wrect[0]-crect[2], wrect[3]-wrect[1]-crect[3])
    end
    #--------------------------------------------------------------------------
    # * Get work area rect (position and dimensions of the game window screen)
    #--------------------------------------------------------------------------
    def workarea_rect
      SystemParametersInfo.call(0x30, 0, rect = [0, 0, 0, 0].pack('l4'), 0)
      rect = rect.unpack('l4')
      Rect.new(rect[0], rect[1], rect[2]-rect[0], rect[3]-rect[1])
    end
    #--------------------------------------------------------------------------
    # * Resize the game window (and stretch the content)
    #--------------------------------------------------------------------------
    def resize_window(w, h)
      @borders_size  ||= borders_size
      @workarea_rect ||= workarea_rect
      w += @borders_size.width
      h += @borders_size.height
      x = @workarea_rect.x + (@workarea_rect.width  - w) / 2
      y = @workarea_rect.y + (@workarea_rect.height - h) / 2
      z = -2
      SetWindowPos.call(HWND, z, x, y, w, h, 0)
    end
    #--------------------------------------------------------------------------
    # * Toggle the size of the game window
    #--------------------------------------------------------------------------
    def toggle_size
      w, h = Graphics.width, Graphics.height
      @toggle_size ? resize_window(w, h) : resize_window(w / 2, h / 2)
      @toggle_size = !@toggle_size
    end
    #--------------------------------------------------------------------------
    # * Toggle to fullscreen (simulate fullscreen shortcut)
    #--------------------------------------------------------------------------
    def toggle_fullscreen
      KeybdEvent.call 0xA4, 0, 0, 0
      KeybdEvent.call 13, 0, 0, 0
      KeybdEvent.call 13, 0, 2, 0
      KeybdEvent.call 0xA4, 0, 2, 0
      @toggle_fullscreen = !@toggle_fullscreen
    end
  end
end

#==============================================================================
# ** Fix mouse position when the screen is switched to tiny size for RME users
#==============================================================================

begin

#==============================================================================
# ** Devices
#------------------------------------------------------------------------------
#  Devices collection
#==============================================================================

module Devices

  #==============================================================================
  # ** Mouse
  #------------------------------------------------------------------------------
  #  Concret Mouse representation
  #==============================================================================

  class Mouse
    alias_method :orms_mouse_update_position, :update_position
    #--------------------------------------------------------------------------
    # * Position update
    #--------------------------------------------------------------------------
    def update_position
      orms_mouse_update_position
      if Graphics::toggle_size
        @point.x *= 2.0
        @point.y *= 2.0
        update_square if SceneManager.scene.is_a?(Scene_Map)
      end
    end
  end
end

rescue

  # GO INSTALL RME, IT'S WAY TOO COOL!!!
  # http://rmex.github.io/

end

#==============================================================================
# ** OLD_RESOLUTION (for the slackers)
#==============================================================================

Graphics.resize_screen(640, 480) if ORMS_CONFIG::OLD_RESOLUTION