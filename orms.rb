# -*- coding: utf-8 -*-
#==============================================================================
# ** OLD_RM_STYLE  V. 1.0.4
#------------------------------------------------------------------------------
# By Joke @biloumaster <joke@biloucorp.com>
# GitHub: https://github.com/RMEx/OLD_RM_STYLE
#------------------------------------------------------------------------------
# Make a RM2K(3)-like game with RMVXAce!
#
# - Can use "Graphics/System/Font.png" and "Graphics/System/Font_color.png" to
#   write awesome OldSchool texts
# - Can make the window box opaque (like RM2K) and/or stop the cursor blinking
# - Can display the choice list inside the dialogue like RM2K(3)
# - Can set shortcuts F4: toggle fullscreen, F5: toggle AWESOME TINY WINDOW MODE
# - Can pixelate the screen display (for the care of the detail)
# - Can set the resolution to 640*480 (okay, it's just one line BUT YES IT CAN)
# - Can use RM2K(3) graphics directly (set all RESSOURCES_FEATURES to "true")
# - Can align the battlebacks to top (for RM2K backdrops)
# - Can deactivate the dash (shift)
#
# In short ... configure it!
#
#------------------------------------------------------------------------------
# ** Additional methods:
#------------------------------------------------------------------------------
# - Orms.set(feature, state)  # Change the features ingame
#                               (example: Orms.set(:bitmap_font, false))
# - Orms.deactivate           # Deactivate all the features
# - Orms.activate             # Activate all the features (active by default)
#==============================================================================

#==============================================================================
# ** CONFIGURATION
#==============================================================================

unless Module.const_defined?(:ORMS_CONFIG)

module ORMS_CONFIG  

  # BITMAP_FONT_FEATURE:
    BITMAP_FONT           = true  # Use the bitmap font picture to draw texts if true
  
  # BITMAP_FONT_FEATURE_OPTIONS:
    FONT_WIDTH            = 6     # See BMP Font character's width
    FONT_HEIGHT           = 14    # See BMP Font character's height
    DOUBLE_FONT_SIZE      = true  # Double the BMP Font Size if true
    LINE_HEIGHT           = 32    # Line height: VXAce: 24  2K(3): 32
    PADDING               = 16    # Padding:     VXAce: 12  2K(3): 16
    SHADOW                = true  # Draw text shadow using the last color in "Font_color.png"
    REWRITE_ALL_TEXTS     = true  # Rewrite Bitmap.draw_text instead of Window_Base.draw_text
                                  #   Try this only if you have problem of compatibility
                                  #   Can create other problems... It's like blue/red pills!
  # BOX_FEATURES:
    OPAQUE_BOX            = false # Opaque text box if true
    STOP_CURSOR_BLINKING  = true  # Stop cursor blinking if false
    OLDSCHOOL_CHOICE_LIST = true  # RM2K(3)-like choice list like if true
  
  # SCREEN_FEATURES:
    TOGGLE_SCREEN_INPUT   = true  # RM2K(3)-like F4 and F5 input (TINY WINDOW WITH F5!!!)
    PIXELATE_SCREEN       = false # If you want fat pixels everywhere
    OLD_RESOLUTION        = false # Just set game resolution to 640*480
  
  # RESSOURCES_FEATURES:
    USE_OLD_RM_BACKDROP   = false # Battlebacks1/2 auto-resized by two
    USE_OLD_RM_MONSTER    = false # Battlers auto-resized by two
    USE_OLD_RM_PANORAMA   = false # Parallaxes auto-resized by two
    USE_OLD_RM_PICTURE    = false # Pictures auto-resized by two
    USE_OLD_RM_TITLE      = false # Titles1/2 auto-resized by two
    USE_OLD_RM_CHARSET    = false # Characters auto-resized by two
    BACKDROP_ALIGN_TOP    = false # Align Battlebacks to top instead of center (for RM2K backdrops)
    KILL_CHARSET_SHIFT_Y  = false # Does as if all "Characters" had "!" in their name
    OLD_CHARSET_DIRECTION = false # In VXAce's ressources, directions are "DOWN, LEFT, RIGHT, UP"
                                  #   but in RM2k(3)'s ressources, it's "UP, RIGHT, DOWN, LEFT"
                                  #   this fix allows you to use directly charsets from 2k(3)!
  # DESTROY_NEW_RM_FEATURE:
    DEACTIVATE_DASH       = false # No dash when you press shift if true
  
end

end

module Orms
  extend self
  def set(feature, state)
    feature = feature.to_s.upcase.to_sym
    ORMS_CONFIG.const_set(feature, state)
    unless Graphics.orms_screen.nil? || Graphics.orms_screen.disposed?
      Graphics.orms_screen.dispose if [feature, state] == [:PIXELATE_SCREEN, false]
    end
    if SceneManager.scene.is_a?(Scene_Map) || SceneManager.scene.is_a?(Scene_Battle)
      SceneManager.scene.create_all_windows
    end
  end
  def deactivate
    @active = false
    unless Graphics.orms_screen.nil? || Graphics.orms_screen.disposed?
      Graphics.orms_screen.dispose
    end
    if SceneManager.scene.is_a?(Scene_Map) || SceneManager.scene.is_a?(Scene_Battle)
      SceneManager.scene.create_all_windows
    end
  end
  def activate
    @active = true
  end
  def active?
    @active = true if @active.nil?
    @active
  end
end

#==============================================================================
# ** BITMAP_FONT and USE_OLD_RM_*
#------------------------------------------------------------------------------
#  BITMAP_FONT: Use the bitmap font picture to draw texts
#  USE_OLD_RM_*: See ORMS_CONFIG > RESSOURCES_FEATURES above
#==============================================================================

#==============================================================================
# ** Cache
#------------------------------------------------------------------------------
#  This module loads graphics, creates bitmap objects, and retains them.
# Now it can double the size of bitmaps specified in ORMS_CONFIG at loading
# and it generates and retains the BITMAP_FONT
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
      when "Graphics/Parallaxes/"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_PANORAMA
      when "Graphics/Pictures/"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_PICTURE
      when "Graphics/Titles1/", "Graphics/Titles2/"
        return load_2k_bitmap(*args) if ORMS_CONFIG::USE_OLD_RM_TITLE
      end
      orms_load_bitmap(*args)
    end
    #--------------------------------------------------------------------------
    # * Load Bitmap to be resized by two
    #--------------------------------------------------------------------------
    def load_2k_bitmap(folder_name, filename, hue = 0)
      return load_bitmap(folder_name, filename, hue) unless Orms.active?
      @cache ||= {}
      if filename.empty?
        empty_bitmap
      elsif hue == 0
        normal_2k_bitmap(folder_name + filename)
      else
        hue_changed_2k_bitmap(folder_name + filename, hue)
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
        bmp.dispose
      end
      @cache[path]
    end
    #--------------------------------------------------------------------------
    # * Create/Get Hue-Changed Bitmap resized by two
    #--------------------------------------------------------------------------
    def hue_changed_2k_bitmap(path, hue)
      key = [path, hue]
      unless include?(key)
        bmp = Bitmap.new(path)
        bmp.hue_change(hue)
        @cache[key] = Bitmap.new(bmp.width*2, bmp.height*2)
        @cache[key].stretch_blt(@cache[key].rect, bmp, bmp.rect)
        bmp.dispose
      end
      @cache[key]
    end
  end
end

if ORMS_CONFIG::BACKDROP_ALIGN_TOP

#==============================================================================
# ** Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # * Move Sprite to Screen Center
  #--------------------------------------------------------------------------
  def center_sprite(sprite)
    sprite.ox = sprite.bitmap.width / 2
    sprite.x = Graphics.width / 2
  end
end

end

#==============================================================================
# ** BITMAP_FONT
#------------------------------------------------------------------------------
#  Use the bitmap font picture to draw texts
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
    #--------------------------------------------------------------------------
    def included(base)
      base.class_eval do
        #--------------------------------------------------------------------------
        # * Get Text Size
        #--------------------------------------------------------------------------
        def text_size(str)
          return orms_text_size(str) unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
          s = ORMS_CONFIG::DOUBLE_FONT_SIZE ? 2 : 1
          w = ORMS_CONFIG::FONT_WIDTH
          h = ORMS_CONFIG::FONT_HEIGHT
          return Rect.new(0, 0, s * w, s * h) unless str
          Rect.new(0, 0, s * w * str.length, s * h)
        end
        #--------------------------------------------------------------------------
        # * Draw Text
        #--------------------------------------------------------------------------
        def draw_text(*args)
          return orms_draw_text(*args) unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
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
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Get Text Color
  #--------------------------------------------------------------------------
  def text_color(n)
    @color_id = n
    windowskin.get_pixel(64 + (n % 8) * 8, 96 + (n / 8) * 8)
  end
  #--------------------------------------------------------------------------
  # * Draw Text
  #--------------------------------------------------------------------------
  alias_method :orms_draw_text, :draw_text
  def draw_text(*args)
    return orms_draw_text(*args) unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
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
  #--------------------------------------------------------------------------
  alias_method :orms_change_color, :change_color
  def change_color(color, enabled = true)
    unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
      return orms_change_color(color, enabled)
    end
    contents.font.color.set(enabled ? color : text_color(3))
  end
  #--------------------------------------------------------------------------
  # * Calculate Line Height
  #--------------------------------------------------------------------------
  alias_method :orms_calc_line_height, :calc_line_height
  def calc_line_height(text, restore_font_size = true)
    unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
      return orms_calc_line_height(text, restore_font_size)
    end
    return line_height
  end
  #--------------------------------------------------------------------------
  # * Get Line Height
  #--------------------------------------------------------------------------
  alias_method :orms_line_height, :line_height
  def line_height
    return orms_line_height unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    return ORMS_CONFIG::LINE_HEIGHT
  end
end

if ORMS_CONFIG::REWRITE_ALL_TEXTS
  class Bitmap
    alias_method :orms_draw_text, :draw_text
    alias_method :orms_text_size, :text_size
  end
  Bitmap.send(:include, ORMS_Bitmap_Font)
else
  Window_Base.send(:include, ORMS_Bitmap_Font)
end

#==============================================================================
# ** Window_Message
#==============================================================================

class Window_Message
  #--------------------------------------------------------------------------
  # * Draw Face Graphic
  #--------------------------------------------------------------------------
  alias_method :orms_draw_face, :draw_face
  def draw_face(*args)
    return orms_draw_face(*args) unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    args[2] = args[3] = (contents_height - 96) / 2
    orms_draw_face(*args)
  end
  #--------------------------------------------------------------------------
  # * Get New Line Position
  #--------------------------------------------------------------------------
  alias_method :orms_new_line_x, :new_line_x
  def new_line_x
    return orms_new_line_x unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    x = [96, height - standard_padding].max
    $game_message.face_name.empty? ? 0 : x
  end
  #--------------------------------------------------------------------------
  # * Get Standard Padding Size
  #--------------------------------------------------------------------------
  alias_method :orms_standard_padding, :standard_padding
  def standard_padding
    return orms_standard_padding unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    return ORMS_CONFIG::PADDING
  end
end
class Window_ActorCommand
  alias_method :orms_standard_padding, :standard_padding
  def standard_padding
    return orms_standard_padding unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    return ORMS_CONFIG::PADDING
  end
end
class Window_BattleStatus
  alias_method :orms_standard_padding, :standard_padding
  def standard_padding
    return orms_standard_padding unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    return ORMS_CONFIG::PADDING
  end
end
class Window_BattleEnemy
  alias_method :orms_standard_padding, :standard_padding
  def standard_padding
    return orms_standard_padding unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    return ORMS_CONFIG::PADDING
  end
end
class Window_PartyCommand
  alias_method :orms_standard_padding, :standard_padding
  def standard_padding
    return orms_standard_padding unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
    return ORMS_CONFIG::PADDING
  end
end

#==============================================================================
# ** Window_MenuStatus
#==============================================================================

class Window_MenuStatus
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  alias_method :orms_draw_item, :draw_item
  def draw_item(index)
    return orms_draw_item(index) unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
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
#==============================================================================

class Window_TitleCommand
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  alias_method :orms_window_width, :window_width
  def window_width
    return orms_window_width unless Orms.active? && ORMS_CONFIG::BITMAP_FONT
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
#------------------------------------------------------------------------------
#  Opaque text box
#==============================================================================

if ORMS_CONFIG::OPAQUE_BOX

#==============================================================================
# ** Window_Base
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :orms_opaque_initialize, :initialize
  def initialize(*args)
    orms_opaque_initialize(*args)
    self.back_opacity = 255 if Orms.active? && ORMS_CONFIG::OPAQUE_BOX
  end
end

end

#==============================================================================
# ** STOP_CURSOR_BLINKING
#------------------------------------------------------------------------------
#  Stop cursor blinking
#==============================================================================

if ORMS_CONFIG::STOP_CURSOR_BLINKING

#==============================================================================
# ** Window
#==============================================================================

class Window
  #--------------------------------------------------------------------------
  # * The cursor's blink status
  #--------------------------------------------------------------------------
  alias_method :orms_active, :active
  def active
    return orms_active unless Orms.active? && ORMS_CONFIG::STOP_CURSOR_BLINKING
    @active
  end
  alias_method :orms_blink_active, :active=
  def active=(index)
    return orms_blink_active(index) unless Orms.active? && ORMS_CONFIG::STOP_CURSOR_BLINKING
    orms_blink_active(false)
    @active = index
  end
  #--------------------------------------------------------------------------
  # * The cursor box (Rect)
  #--------------------------------------------------------------------------
  alias_method :orms_blink_cursor_rect, :cursor_rect
  def cursor_rect
    orms_blink_active(false) if Orms.active? && ORMS_CONFIG::STOP_CURSOR_BLINKING
    orms_blink_cursor_rect
  end
end

end

#==============================================================================
# ** OLDSCHOOL_CHOICE_LIST
#------------------------------------------------------------------------------
#  RM2K(3)-like choice list like
#==============================================================================

if ORMS_CONFIG::OLDSCHOOL_CHOICE_LIST

#==============================================================================
# ** Window_Base
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :line_number
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :orms_choice_initialize, :initialize
  def initialize(*args)
    orms_choice_initialize(*args)
    @line_number = 0
  end
end

#==============================================================================
# ** Window_Message
#==============================================================================

class Window_Message
  #--------------------------------------------------------------------------
  # * New Page
  #--------------------------------------------------------------------------
  alias_method :orms_choice_new_page, :new_page
  def new_page(text, pos)
    orms_choice_new_page(text, pos)
    @line_number = text.split("\n").length
  end
end

#==============================================================================
# ** Window_ChoiceList
#==============================================================================

class Window_ChoiceList
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias_method :oldschool_choice_initialize, :initialize
  def initialize(message_window)
    oldschool_choice_initialize(message_window)
    if Orms.active? && ORMS_CONFIG::OLDSCHOOL_CHOICE_LIST
      self.windowskin = Cache.system("Window").clone
      self.windowskin.fill_rect(Rect.new(0,0,168,64), Color.new(0,0,0,0))
    end
  end
  #--------------------------------------------------------------------------
  # * Start Input Processing
  #--------------------------------------------------------------------------
  alias_method :orms_start, :start
  def start
    if Orms.active? && ORMS_CONFIG::OLDSCHOOL_CHOICE_LIST
      if @message_window.openness == 0
        @message_window.create_contents
        @message_window.line_number = 0
        @message_window.open
      end
      if (@message_window.line_number + $game_message.choices.size >
          @message_window.visible_line_number)
        @message_window.input_pause
        @message_window.new_page("", {x:0, y:0, new_x:0, height:0})
      end
    end
    orms_start
  end
  #--------------------------------------------------------------------------
  # * Update Window Position
  #--------------------------------------------------------------------------
  alias_method :orms_update_placement, :update_placement
  def update_placement
    orms_update_placement unless Orms.active? && ORMS_CONFIG::OLDSCHOOL_CHOICE_LIST
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
# ** OLD_CHARSET_DIRECTION
#------------------------------------------------------------------------------
#  In VXAce's ressources, directions are "DOWN, LEFT, RIGHT, UP"
# but in RM2k(3)'s ressources, it's "UP, RIGHT, DOWN, LEFT"
# this fix allows you to use directly charsets from 2k(3)!
#==============================================================================

if ORMS_CONFIG::OLD_CHARSET_DIRECTION

#==============================================================================
# ** Sprite_Character
#==============================================================================

class Sprite_Character
  #--------------------------------------------------------------------------
  # * Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  alias_method :orms_update_src_rect, :update_src_rect
  def update_src_rect
    return orms_update_src_rect unless Orms.active? && ORMS_CONFIG::OLD_CHARSET_DIRECTION
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
#==============================================================================

class Game_Event
  #--------------------------------------------------------------------------
  # * Set Up Event Page Settings
  #--------------------------------------------------------------------------
  alias_method :orms_setup_page_setting, :setup_page_settings
  def setup_page_settings
    orms_setup_page_setting
    if Orms.active? && ORMS_CONFIG::OLD_CHARSET_DIRECTION
      @original_direction = @direction = [8, 6, 2, 4][@page.graphic.direction / 2 - 1]
    end
  end
end

end

#==============================================================================
# ** KILL_CHARSET_SHIFT_Y
#------------------------------------------------------------------------------
#  Does as if all "Characters" had "!" in their name
#==============================================================================

if ORMS_CONFIG::KILL_CHARSET_SHIFT_Y
class Game_CharacterBase
  alias_method :orms_shift_y, :shift_y
  def shift_y
    return orms_shift_y unless Orms.active? && ORMS_CONFIG::KILL_CHARSET_SHIFT_Y
    return 0
  end
end
end

#==============================================================================
# ** PIXELATE_SCREEN and TOGGLE_SCREEN_INPUT
#------------------------------------------------------------------------------
#  PIXELATE_SCREEN: If you want fat pixels everywhere
#  TOGGLE_SCREEN_INPUT: RM2K(3)-like F4 and F5 input (TINY WINDOW WITH F5!!!)
#==============================================================================

if ORMS_CONFIG::PIXELATE_SCREEN

#==============================================================================
# ** Avoid missing graphical update after window close processing
#  Not notable without screen pixelation
#==============================================================================
class Window_Base
  #--------------------------------------------------------------------------
  # * Update Close Processing
  #--------------------------------------------------------------------------
  alias_method :orms_update_close, :update_close
  def update_close
    orms_update_close
    Graphics.pixelate_screen if close?
  end
end
#==============================================================================
# ** Graphics
#==============================================================================

class << Graphics
  #--------------------------------------------------------------------------
  # * Public instance variables
  #--------------------------------------------------------------------------
  attr_accessor :orms_screen
  #--------------------------------------------------------------------------
  # * Update the screen display
  #--------------------------------------------------------------------------
  alias_method :orms_graphics_update, :update
  def update
    @skip ||= 0
    @skip %= 2
    pixelate_screen if @skip == 0
    @skip += 1
    orms_graphics_update
  end
  #--------------------------------------------------------------------------
  # * Pixelate the screen
  #--------------------------------------------------------------------------
  def pixelate_screen
    return unless Orms.active? && ORMS_CONFIG::PIXELATE_SCREEN
    w, h = Graphics.width / 2, Graphics.height / 2
    if @orms_screen.nil? || @orms_screen.disposed?
      @orms_screen = Sprite.new
      @orms_screen.zoom_x = 2
      @orms_screen.zoom_y = 2
      @orms_screen.bitmap = Bitmap.new(w, h)
      @orms_screen.viewport = Viewport.new
      @orms_screen.viewport.z = 500
    end
    @orms_screen.visible = false
    snap = snap_to_bitmap
    @orms_screen.bitmap.stretch_blt(Rect.new(0, 0, w, h), snap, snap.rect)
    snap.dispose
    @orms_screen.visible = true
  end
  #--------------------------------------------------------------------------
  # * Make a transition
  #--------------------------------------------------------------------------
  alias_method :orms_transition, :transition
  def transition(*args)
    pixelate_screen
    orms_transition(*args)
  end
end

end

#==============================================================================
# ** TOGGLE_SCREEN_INPUT
#------------------------------------------------------------------------------
#  RM2K(3)-like F4 and F5 input (TINY WINDOW WITH F5!!!)
#==============================================================================

if ORMS_CONFIG::TOGGLE_SCREEN_INPUT

#==============================================================================
# ** Input
#==============================================================================

module Input
  class << self
    alias_method :orms_input_update, :update
    def update
      orms_input_update
      Toggle_Screen.check_input
    end
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
    attr_reader :tiny_window
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
    # * Get the window rect
    #--------------------------------------------------------------------------
    def window_rect
      GetWindowRect.call(HWND, wr = [0, 0, 0, 0].pack('l4'))
      wr = wr.unpack('l4')
      Rect.new(wr[0], wr[1], wr[2] - wr[0], wr[3] - wr[1])
    end
    #--------------------------------------------------------------------------
    # * Get the dimensions of the window, excluding the frame
    #--------------------------------------------------------------------------
    def client_rect
      GetClientRect.call(HWND, cr = [0, 0, 0, 0].pack('l4'))
      cr = cr.unpack('l4')
      Rect.new(*cr)
    end
    #--------------------------------------------------------------------------
    # * Resize the game window (and stretch the content)
    #--------------------------------------------------------------------------
    def resize_window(w, h)
      wr = window_rect
      cr = client_rect
      w += wr.width  - cr.width
      h += wr.height - cr.height
      x = wr.x - (w - wr.width ) / 2
      y = wr.y - (h - wr.height) / 2
      SetWindowPos.call(HWND, 0, x, y, w, h, 0x0200)
    end
    #--------------------------------------------------------------------------
    # * Toggle the size of the game window
    #--------------------------------------------------------------------------
    def toggle_size
      w, h = Graphics.width, Graphics.height
      @tiny_window ? resize_window(w, h) : resize_window(w / 2, h / 2)
      @tiny_window = !@tiny_window
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

end

#==============================================================================
# ** OLD_RESOLUTION (for the slackers)
#------------------------------------------------------------------------------
#  Just set game resolution to 640*480
#==============================================================================

Graphics.resize_screen(640, 480) if ORMS_CONFIG::OLD_RESOLUTION

#==============================================================================
# ** DEACTIVATE_DASH
#------------------------------------------------------------------------------
#  No dash when you press shift
#==============================================================================

if ORMS_CONFIG::DEACTIVATE_DASH

#==============================================================================
# ** Game_Player
#==============================================================================

class Game_Player
  #--------------------------------------------------------------------------
  # * Determine if Dashing
  #--------------------------------------------------------------------------
  alias_method :orms_dash?, :dash?
  def dash?
    return orms_dash? unless Orms.active? && ORMS_CONFIG::DEACTIVATE_DASH
    return false
  end
end

end

#==============================================================================
# ** Fullscreen++ (Zeus81) compatibility
#------------------------------------------------------------------------------
#  Get Fullscreen++:
# https://forums.rpgmakerweb.com/index.php?threads/fullscreen.14081/
#==============================================================================

if ORMS_CONFIG::TOGGLE_SCREEN_INPUT

begin
  class << Graphics
    alias_method :zeus_save_fullscreen_settings, :save_fullscreen_settings
    def save_fullscreen_settings
      @half = @windowed_ratio = 1 if @windowed_ratio == 0.5
      zeus_save_fullscreen_settings
      @windowed_ratio = 0.5 if @half == 1
      @half = 0
    end
    alias_method :zeus_set_ratio, :ratio=
    def ratio=(r)
      r = 0.5 if ratio == 0 unless fullscreen?
      r = 1 if r == 1.5
      zeus_set_ratio(r)
    end
  end
  module Toggle_Screen
    def self.check_input
    end
  end
rescue
end

end
