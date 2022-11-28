# -*- coding: utf-8 -*-
#==============================================================================
# ** OLD_RM_STYLE  v1.1.3
#------------------------------------------------------------------------------
# By Joke @biloumaster <joke@biloucorp.com>
# GitHub: https://github.com/RMEx/OLD_RM_STYLE
#------------------------------------------------------------------------------
# Make a RM2K(3)-like game with RMVXAce!
# (or the oldschool overkill game that you dreamed for a long time)
# See the "ORMS_CONFIG" module below to see all the features and configure it!
# Go on the GitHub page to learn more about the bitmap fonts and the features!
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

    # BOX_FEATURES:
      OPAQUE_BOX            = false # Opaque text box if true
      STOP_CURSOR_BLINKING  = true  # Stop cursor blinking if true
      OLDSCHOOL_CHOICE_LIST = true  # RM2K(3)-like choice list like if true

    # SCREEN_FEATURES:
      OLD_RESOLUTION        = false # Just set game resolution to 640*480 (to simulate RM2k(3)'s 320*240)
      TOGGLE_FULLSCREEN     = :F4   # The shortcut (:F3..:F11) to toggle the fullscreen mode like RM2k(3)
      TOGGLE_WINDOW_MODE    = :F5   # The shortcut (:F3..:F11) to toggle to TINY 1x WINDOW MODE like RM2k(3)
                                    #   Re-define also the Fullscreen++ shortcuts if you use it too.
                                    #   If you use Fullscreen++, place Fullscreen++ right before orms!
                                    #
                                    # => Set the shortcut to 0 if you don't want the feature

      PIXELATE_SCREEN       = false # If you want fat pixels everywhere!
                                    #   This feature is a bit greedy, but it tries to optimize itself with
                                    #   a custom frame skipping method. This feature activate a custom FPS
                                    #   display (F2) that shows the real FPS, counting the frame skipping.

      PIXELATION_SHORTCUT   = :F6   # The shortcut (:F3..:F11) to activate/deactivate pixelation ingame.
                                    #   Don't forget to tell the player he can use this shortcut!
                                    #   An alternative is to use the "Orms.set(:pixelate_screen, false)" method
                                    #
                                    # => Set the shortcut to 0 if you don't want the feature

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

#==============================================================================
# ** Additional methods for the user:
#------------------------------------------------------------------------------
# - Orms.set(feature, state)  # Change the orms' features state when you want
#                               (example: Orms.set(:bitmap_font, false))
# - Orms.deactivate           # Deactivate all orms' features when you want
# - Orms.activate             # Reactivate all orms' features when you want
# - Orms.active?              # Check if orms is active
# - Orms.active?(feature)     # Check if orms and the given feature are active
#                               (example: Orms.active?(:pixelate_screen))
#==============================================================================

module Orms
  extend self
  #--------------------------------------------------------------------------
  # * Change the orms' features state when you want
  #--------------------------------------------------------------------------
  def set(feature, state)
    feature = feature.to_s.upcase.to_sym
    ORMS_CONFIG.const_set(feature, state)
    if Graphics.respond_to?(:orms_screen) && [feature, state] == [:PIXELATE_SCREEN, false]
      Graphics.orms_screen.dispose unless Graphics.orms_screen.nil?
    end
    if SceneManager.scene.is_a?(Scene_Map) || SceneManager.scene.is_a?(Scene_Battle)
      if [:BITMAP_FONT, :LINE_HEIGHT, :PADDING].include?(feature)
        SceneManager.scene.create_all_windows
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Deactivate all orms' features when you want
  #--------------------------------------------------------------------------
  def deactivate
    @active = false
    if Graphics.respond_to?(:orms_screen) && Graphics.orms_screen
      Graphics.orms_screen.dispose
    end
    if SceneManager.scene.is_a?(Scene_Map) || SceneManager.scene.is_a?(Scene_Battle)
      SceneManager.scene.create_all_windows
    end
  end
  #--------------------------------------------------------------------------
  # * Reactivate all orms' features when you want
  #--------------------------------------------------------------------------
  def activate
    @active = true
  end
  #--------------------------------------------------------------------------
  # * Check if orms and the given feature are active
  #--------------------------------------------------------------------------
  def active?(feature = true)
    @active = true if @active.nil?
    if feature.is_a?(Symbol)
      feature = feature.upcase
      feature = ORMS_CONFIG.const_get(feature)
    end
    @active && feature
  end
end

#==============================================================================
# ** BITMAP_FONT cache and USE_OLD_RM_*
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
          return orms_text_size(str) unless Orms.active?(:bitmap_font)
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
          unless Orms.active?(:bitmap_font)
            args.pop if args.length == 4 || args.length == 7
            return orms_draw_text(*args)
          end
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
          bmp  = Cache.bitmap_font
          char = 1 if char.ord > bmp.width / w - 1
          dest = Rect.new(x, y, w * s, h * s)
          src  = Rect.new(char.ord * w, color_id * h, w, h)
          if ORMS_CONFIG::REWRITE_ALL_TEXTS
            stretch_blt(dest, bmp, src)
          else
            contents.stretch_blt(dest, bmp, src)
          end
        end
      end
    end
  end
end

#==============================================================================
# ** ORMS_Bitmap
#------------------------------------------------------------------------------
#  can draw with the bitmap font!
#==============================================================================

class ORMS_Bitmap < Bitmap
  alias_method :orms_draw_text, :draw_text
  alias_method :orms_text_size, :text_size
  include ORMS_Bitmap_Font
end

if ORMS_CONFIG::BITMAP_FONT

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
      return orms_draw_text(*args) unless Orms.active?(:bitmap_font)
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
      return orms_change_color(color, enabled) unless Orms.active?(:bitmap_font)
      contents.font.color.set(enabled ? color : text_color(3))
    end
    #--------------------------------------------------------------------------
    # * Calculate Line Height
    #--------------------------------------------------------------------------
    alias_method :orms_calc_line_height, :calc_line_height
    def calc_line_height(text, restore_font_size = true)
      unless Orms.active?(:bitmap_font)
        return orms_calc_line_height(text, restore_font_size)
      end
      line_height
    end
    #--------------------------------------------------------------------------
    # * Get Line Height
    #--------------------------------------------------------------------------
    alias_method :orms_line_height, :line_height
    def line_height
      return orms_line_height unless Orms.active?(:bitmap_font)
      ORMS_CONFIG::LINE_HEIGHT
    end
  end

  #==============================================================================
  # ** REWRITE ALL TEXTS or Window_Base only
  #==============================================================================

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
  # ** Window_NameEdit
  #==============================================================================

  class Window_NameEdit
    #--------------------------------------------------------------------------
    # * Get Line Height
    #--------------------------------------------------------------------------
    def line_height
      24
    end
  end

  #==============================================================================
  # ** Window_NameInput
  #==============================================================================

  class Window_NameInput
    #--------------------------------------------------------------------------
    # * Write "Pge" instead of "Page"
    #--------------------------------------------------------------------------
    LATIN1[88] = 'Nx'
    LATIN2[88] = 'Pr'
    #--------------------------------------------------------------------------
    # * Get Line Height
    #--------------------------------------------------------------------------
    def line_height
      24
    end
  end

  #==============================================================================
  # ** Window_EquipStatus
  #==============================================================================

  class Window_EquipStatus
    #--------------------------------------------------------------------------
    # * Draw Right Arrow
    #--------------------------------------------------------------------------
    def draw_right_arrow(x, y)
      change_color(system_color)
      draw_text(x, y, 22, line_height, " >", 1)
    end
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
      return orms_draw_face(*args) unless Orms.active?(:bitmap_font)
      args[2] = args[3] = (contents_height - 96) / 2
      orms_draw_face(*args)
    end
    #--------------------------------------------------------------------------
    # * Get New Line Position
    #--------------------------------------------------------------------------
    alias_method :orms_new_line_x, :new_line_x
    def new_line_x
      return orms_new_line_x unless Orms.active?(:bitmap_font)
      x = [96, height - standard_padding].max
      $game_message.face_name.empty? ? 0 : x
    end
    #--------------------------------------------------------------------------
    # * Get Standard Padding Size
    #--------------------------------------------------------------------------
    alias_method :orms_standard_padding, :standard_padding
    def standard_padding
      return orms_standard_padding unless Orms.active?(:bitmap_font)
      ORMS_CONFIG::PADDING
    end
  end
  class Window_ActorCommand
    alias_method :orms_standard_padding, :standard_padding
    def standard_padding
      return orms_standard_padding unless Orms.active?(:bitmap_font)
      ORMS_CONFIG::PADDING
    end
  end
  class Window_BattleStatus
    alias_method :orms_standard_padding, :standard_padding
    def standard_padding
      return orms_standard_padding unless Orms.active?(:bitmap_font)
      ORMS_CONFIG::PADDING
    end
  end
  class Window_BattleEnemy
    alias_method :orms_standard_padding, :standard_padding
    def standard_padding
      return orms_standard_padding unless Orms.active?(:bitmap_font)
      ORMS_CONFIG::PADDING
    end
  end
  class Window_PartyCommand
    alias_method :orms_standard_padding, :standard_padding
    def standard_padding
      return orms_standard_padding unless Orms.active?(:bitmap_font)
      ORMS_CONFIG::PADDING
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
      return orms_draw_item(index) unless Orms.active?(:bitmap_font)
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
      return orms_window_width unless Orms.active?(:bitmap_font)
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
      self.back_opacity = 255 if Orms.active?(:opaque_box)
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
  # ** Window_Selectable
  #==============================================================================

  class Window_Selectable
    #--------------------------------------------------------------------------
    # * The cursor's blink status
    #--------------------------------------------------------------------------
    alias_method :orms_active, :active
    def active
      return orms_active unless Orms.active?(:stop_cursor_blinking)
      @active
    end
    alias_method :orms_blink_active, :active=
    def active=(index)
      return orms_blink_active(index) unless Orms.active?(:stop_cursor_blinking)
      orms_blink_active(false)
      @active = index
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
      if Orms.active?(:oldschool_choice_list)
        self.windowskin = Cache.system("Window").clone
        self.windowskin.fill_rect(Rect.new(0,0,168,64), Color.new(0,0,0,0))
      end
    end
    #--------------------------------------------------------------------------
    # * Start Input Processing
    #--------------------------------------------------------------------------
    alias_method :orms_start, :start
    def start
      if Orms.active?(:oldschool_choice_list)
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
      orms_update_placement unless Orms.active?(:oldschool_choice_list)
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
      return orms_update_src_rect unless Orms.active?(:old_charset_direction)
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
      if Orms.active?(:old_charset_direction)
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
      return orms_shift_y unless Orms.active?(:kill_charset_shift_y)
      0
    end
  end

end

#==============================================================================
# ** PIXELATE_SCREEN
#------------------------------------------------------------------------------
#  If you want fat pixels everywhere
#==============================================================================

if ORMS_CONFIG::PIXELATE_SCREEN

  #==============================================================================
  # ** ORMS_FPS
  #------------------------------------------------------------------------------
  #  Calculate the FPS of the RGSS processing and the screen refreshing
  #==============================================================================

  module ORMS_FPS
    extend self
    #--------------------------------------------------------------------------
    # * Public instance variables
    #--------------------------------------------------------------------------
    attr_reader :fps, :ups, :ups2, :visible
    attr_accessor :previous_time
    #--------------------------------------------------------------------------
    # * Update rate: Number of times the FPS is calculated per second
    #--------------------------------------------------------------------------
    UPDATE_RATE = 2.0
    #--------------------------------------------------------------------------
    # * Update
    #--------------------------------------------------------------------------
    def update
      update_ups
      update_ups2
    end
    #--------------------------------------------------------------------------
    # * Graphics.updates per second calculation
    #--------------------------------------------------------------------------
    def update_ups
      @frame_count ||= 0
      @frame_count += 1
      dt = Time.now - @previous_time
      if dt >= 1.0 / UPDATE_RATE
        @ups = (@frame_count / dt).round
        @ups = [@ups, Graphics.frame_rate + 10].min
        update_fps(dt)
        @frame_count = 0
        @previous_time = Time.now
        update_counter
      end
    end
    #--------------------------------------------------------------------------
    # * Graphics.updates real time frequency
    #--------------------------------------------------------------------------
    def update_ups2
      @previous_time2 ||= @previous_time
      dt = Time.now - @previous_time2
      if dt >= 1.0 / Graphics.frame_rate
        @ups2 = (1.0 / dt).round
        @previous_time2 = Time.now
      end
    end
    #--------------------------------------------------------------------------
    # * Pixelated frames per second
    #--------------------------------------------------------------------------
    def update_fps(dt)
      if Orms.active?(:pixelate_screen)
        sframe_count = Graphics.frame_counter || Graphics.frame_rate
        @fps = (sframe_count / dt).round
      else
        @fps = @ups
      end
      Graphics.frame_counter = 0
    end
    #--------------------------------------------------------------------------
    # * Initialize the displayed counter
    #--------------------------------------------------------------------------
    def initialize_counter
      @background = Sprite.new(Viewport.new(4, 4, 200, 30))
      @background.viewport.z = 600
      @background.bitmap = Bitmap.new(1, 1)
      @background.bitmap.set_pixel(0, 0, Color.new(0, 0, 0, 127))
      @counter = Sprite.new(@background.viewport)
      begin
        @counter.bitmap = ORMS_Bitmap.new(200, 30)
      rescue
        @counter.bitmap = Bitmap.new(200, 30)
      end
      @counter.x = 2
      @counter.y = -4
      @counter.z = 10
    end
    #--------------------------------------------------------------------------
    # * Update the displayed counter
    #--------------------------------------------------------------------------
    def update_counter
      @visible ||= false
      return unless @visible
      if @counter.nil? || @counter.disposed?
        @visible ? initialize_counter : return
      end
      text = [@ups, @fps].uniq
      size  = @counter.bitmap.text_size(text.join("~"))
      size2 = @counter.bitmap.text_size(text[0].to_s) if text.length == 2
      @background.zoom_x = size.width  + 4
      @background.zoom_y = size.height - 6
      @counter.bitmap.clear
      color = 9
      color = 4  if text[0] <= 30
      color = 11 if text[0] <= 15
      @counter.bitmap.draw_text(size, text[0].to_s, 0, color)
      if text.length == 2
        size.x = size2.width
        size.width -= size2.width
        @counter.bitmap.draw_text(size, "~" + text[1].to_s, 0, 3)
      end
    end
    #--------------------------------------------------------------------------
    # * Toggle the counter display
    #--------------------------------------------------------------------------
    def toggle_display
      initialize_counter if @counter.nil? || @counter.disposed?
      @visible = !@visible
      visible = @visible
    end
    def visible=(v)
      return if @counter.nil? || @counter.disposed?
      @counter.visible = @background.visible = v
    end
  end

  #==============================================================================
  # ** ORMS_MESSAGE
  #------------------------------------------------------------------------------
  #  Display messages at top/right screen corner (used for "pixelation ON/OFF")
  #==============================================================================

  module ORMS_MESSAGE
    extend self
    #--------------------------------------------------------------------------
    # * Update the displayed message
    #--------------------------------------------------------------------------
    def update
      create_message_sprite if @message.nil? || @message.disposed?
      @timer ||= 0
      @message.opacity == 0 ? @timer = 0 : @timer += 1
      @message.opacity -= 20 if @timer > 30
    end
    #--------------------------------------------------------------------------
    # * Create the sprite
    #--------------------------------------------------------------------------
    def create_message_sprite
      @message = Sprite.new(Viewport.new(Graphics.width - 200, 4, 204, 30))
      @message.viewport.z = 600
      @message.x = -4
      @message.y = -2
      @message.z = 10
    end
    #--------------------------------------------------------------------------
    # * Display a message
    #--------------------------------------------------------------------------
    def display(text, color)
      @message.bitmap = get_message_bitmap(text, color)
      @message.opacity = 255
    end
    #--------------------------------------------------------------------------
    # * Get the Bitmap corresponding to the message and cache it
    #--------------------------------------------------------------------------
    def get_message_bitmap(text, color)
      @texts ||= Hash.new
      if @texts[text].nil? || @texts[text].is_a?(Bitmap) && @texts[text].disposed?
        begin
          @texts[text] = ORMS_Bitmap.new(200, 30)
        rescue
          @texts[text] = Bitmap.new(200, 30)
        end
        draw_message(@texts[text], text, color)
      end
      @texts[text]
    end
    #--------------------------------------------------------------------------
    # * Draw the message into the Bitmap
    #--------------------------------------------------------------------------
    def draw_message(bmp, text, color)
      size = bmp.text_size(text)
      size.x = 200 - 4 - size.width
      size.width  += 4
      size.height += 4
      rect = bmp.rect
      rect.width -= 2
      bmp.fill_rect(size, Color.new(0, 0, 0, 127))
      bmp.draw_text(rect, text, 2, color)
    end
    #--------------------------------------------------------------------------
    # * Hide/Show the message
    #--------------------------------------------------------------------------
    def visible=(v)
      return if @message.nil? || @message.disposed?
      @message.visible = v
    end
  end

  #==============================================================================
  # ** Graphics
  #==============================================================================

  class << Graphics
    #--------------------------------------------------------------------------
    # * Public instance variables
    #--------------------------------------------------------------------------
    attr_accessor :orms_screen, :frame_counter
    #--------------------------------------------------------------------------
    # * Update the screen display
    #--------------------------------------------------------------------------
    alias_method :orms_graphics_update, :update
    def update
      ORMS_FPS.previous_time ||= Time.now
      @skip = ORMS_FPS.ups && ORMS_FPS.ups < (frame_rate - 10) && ORMS_FPS.ups2 < (frame_rate / 2)
      unless @skip
        if respond_to?(:zeus_fullscreen_update)
          update_screen_display
          release_alt if Disable_VX_Fullscreen and Input.trigger?(Input::ALT)
          zeus_fullscreen_update
        else
          update_screen_display
          orms_graphics_update
        end
      else
        frame_reset
      end
      ORMS_FPS.update
      ORMS_MESSAGE.update
    end
    #--------------------------------------------------------------------------
    # * Dynamic frame skipping for performance issues
    #  Kill the default frame skipping while the RGSS FPS < 50
    #--------------------------------------------------------------------------
    def update_screen_display
      return unless Orms.active?(:pixelate_screen)
      @timer ||= 0
      ups = ORMS_FPS.ups || frame_rate
      ups = [ups, frame_rate].min
      @timer = 0 if @timer >= (frame_rate.to_f / [ups, 20].max).round
      if @timer == 0
        pixelate_screen
        @frame_counter ||= 0
        @frame_counter += 1
      end
      @timer += 1
    end
    #--------------------------------------------------------------------------
    # * Pixelate the screen
    #--------------------------------------------------------------------------
    def pixelate_screen
      return unless Orms.active?(:pixelate_screen)
      if respond_to?(:screen) && screen
        esc = [screen.blur, screen.motion_blur, screen.pixelation, screen.zoom]
        if esc && esc != [0, 0, 1, 100]
          screen.update_filters
          return @orms_screen && !@orms_screen.disposed? && @orms_screen.visible = false
        else
          @orms_screen && !@orms_screen.disposed? && @orms_screen.visible = true
        end
      end
      w, h = Graphics.width / 2, Graphics.height / 2
      if @orms_screen.nil? || @orms_screen.disposed?
        @orms_screen = Sprite.new
        @orms_screen.zoom_x = 2
        @orms_screen.zoom_y = 2
        @orms_screen.bitmap = Bitmap.new(w, h)
        @orms_screen.viewport = Viewport.new
        @orms_screen.viewport.z = 500
      end
      @orms_screen.visible = ORMS_FPS.visible = ORMS_MESSAGE.visible = false
      snap = snap_to_bitmap
      @orms_screen.bitmap.stretch_blt(Rect.new(0, 0, w, h), snap, snap.rect)
      snap.dispose
      @orms_screen.visible = ORMS_MESSAGE.visible = true
      ORMS_FPS.visible = ORMS_FPS.visible
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

  #==============================================================================
  # ** Avoid missing graphical update after window close processing
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

end

#==============================================================================
# ** TOGGLE_SCREEN_INPUT
#------------------------------------------------------------------------------
#  RM2K(3)-like F4 and F5 input (TINY WINDOW WITH F5!!!)
#==============================================================================

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
    SetWindowPos         = Win32API.new 'user32', 'SetWindowPos', 'iiiiiii', 'i'
    GetWindowRect        = Win32API.new 'user32', 'GetWindowRect', 'ip', 'i'
    GetClientRect        = Win32API.new 'user32', 'GetClientRect', 'ip', 'i'
    GetKeyState          = Win32API.new 'user32', 'GetKeyState', 'p', 'i'
    KeybdEvent           = Win32API.new 'user32.dll', 'keybd_event', 'iill', 'v'
    FindWindow           = Win32API.new'user32', 'FindWindow', 'pp', 'i'
    HWND                 = FindWindow.call 'RGSS Player', 0
    #--------------------------------------------------------------------------
    # * Get key code (:F5 => 0x74)
    #--------------------------------------------------------------------------
    def get_key_code(sym)
      return 0 unless sym.is_a?(Symbol)
      sym = sym.to_s.upcase
      sym.slice!(0)
      0x6F + sym.to_i
    end
    #--------------------------------------------------------------------------
    # * Initialize the given shortcuts
    #--------------------------------------------------------------------------
    def initialize_shortcuts
      return if @tf_sc
      @tf_sc ||= get_key_code(ORMS_CONFIG::TOGGLE_FULLSCREEN)
      @tw_sc ||= get_key_code(ORMS_CONFIG::TOGGLE_WINDOW_MODE)
      @ps_sc ||= get_key_code(ORMS_CONFIG::PIXELATION_SHORTCUT)
    end
    #--------------------------------------------------------------------------
    # * Check keyboard state and toggle
    #--------------------------------------------------------------------------
    def check_input
      initialize_shortcuts
      # check_fullscreen_shortcut
      if ![0,1].include?(GetKeyState.call(@tf_sc)) && Orms.active?(:toggle_fullscreen)
        toggle_fullscreen unless @tf
        @tf = true
      else
        @tf = false
      end
      # check_window_mode_shortcut
      if ![0,1].include?(GetKeyState.call(@tw_sc)) && Orms.active?(:toggle_window_mode)
        toggle_size unless @tw || @fullscreen
        @tw = true
      else
        @tw = false
      end
      # check_pixelation_shortcut
      if ![0,1].include?(GetKeyState.call(@ps_sc)) && Orms.active?(:pixelation_shortcut)
        toggle_pixelation unless @ps
        @ps = true
      else
        @ps = false
      end
      # check_fps_display_shortcut
      if ![0,1].include?(GetKeyState.call(0x71)) && Module.const_defined?(:ORMS_FPS)
        ORMS_FPS.toggle_display unless @fp
        @fp = true
      else
        @fp = false
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
      @fullscreen = !@fullscreen
    end
    #--------------------------------------------------------------------------
    # * Toggle screen_pixelation ON/OFF
    #--------------------------------------------------------------------------
    def toggle_pixelation
      return unless Module.const_defined?(:ORMS_MESSAGE)
      if ORMS_CONFIG::PIXELATE_SCREEN
        ORMS_MESSAGE.display("pixelation OFF", 11)
        Orms.set(:pixelate_screen, false)
      else
        ORMS_MESSAGE.display("pixelation ON", 9)
        Orms.set(:pixelate_screen, true)
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
      !Orms.active?(:deactivate_dash) && orms_dash?
    end
  end

end

#==============================================================================
# ** Fullscreen++ (Zeus81) compatibility
#------------------------------------------------------------------------------
#  Get Fullscreen++:
# https://forums.rpgmakerweb.com/index.php?threads/fullscreen.14081/
#==============================================================================

if $imported && $imported[:Zeus_Fullscreen]
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
      unless Module.const_defined?(:ORMS_MESSAGE)
        def update
          release_alt if Disable_VX_Fullscreen and Input.trigger?(Input::ALT)
          zeus_fullscreen_update
        end
      end
    end
    module Toggle_Screen
      def self.toggle_size
        Graphics.toggle_ratio
      end
      def self.toggle_fullscreen
        Graphics.toggle_fullscreen
      end
    end
  rescue
  end
end

#==============================================================================
# ** RME (RMEx) ScreenEffects compatibility
#------------------------------------------------------------------------------
#  Get RME:
# https://github.com/RMEx/RME
#==============================================================================

if Module.const_defined?(:RME)
  if ORMS_CONFIG::PIXELATE_SCREEN
    module ScreenEffects
      class Screen
        def update
          return if disposed?
          update_transitions
          if !SceneManager.scene_is?(Scene_Map) || [@blur, @motion_blur, @pixelation, @zoom] == [0, 0, 1, 100]
            return self.visible = false
          end
        end
        def update_filters
          update_zoom_target
          update_capture_rect
          update_pixelation
          update_bitmap
        end
      end
    end
  end
  if ORMS_CONFIG::REWRITE_ALL_TEXTS
    module Gui
      module Components
        class Text_Field
          def create_sprite
            @sprite = Sprite.new
            @sprite.bitmap = Bitmap.new(1,1)
            @sprite.bitmap.font = @font
            @split_format = 640 / @sprite.bitmap.orms_text_size("W").width
          end
          def create_viewport
            @h = @sprite.bitmap.orms_text_size("W").height
            @viewport = Viewport.new(@x,@y,@w,@h)
            @sprite.viewport = @viewport
          end
          def update_bitmap
            text = value
            text = " " if text.empty?
            rect = @sprite.bitmap.orms_text_size(text)
            @sprite.bitmap.dispose
            @sprite.bitmap = Bitmap.new(rect.width, rect.height)
            @sprite.bitmap.font = @font
            last_x = 0
            text.split_each(@split_format).each do |a_text|
              rect = @sprite.bitmap.orms_text_size(a_text)
              rect.x = last_x
              @sprite.bitmap.orms_draw_text(rect, a_text)
              last_x += rect.width
            end
          end
          def update_cursor_pos
            @cursor_timer = 0
            pos = @text.virtual_position
            if pos == 0
              @cursor.x = 1
            else
              @cursor.x = @sprite.bitmap.orms_text_size(value[0...pos]).width
            end
          end
          def update_selection_rect
            pos = @text.selection_start
            if pos == 0
              @selection_rect.x = 1
            else
              @selection_rect.x = @sprite.bitmap.orms_text_size(value[0...pos]).width
            end
            delta = @cursor.x - @selection_rect.x
            @selection_rect.zoom_x = delta.abs
            @selection_rect.x += delta if delta < 0
          end
          def approach(a, x, memoa=a, memob=0)
            bound = a.bound(0,value.length)
            return bound if bound != a
            b = @sprite.bitmap.orms_text_size(value[0...a]).width
            return a if (b-x) == 0 || (b-x)==(x-memob)
            return memoa if (b-x).abs > (memob-x).abs
            approach(a + (0 <=> (b-x)), x, a, b)
          end
        end
      end
      class Label
        def initialize_text(txt)
          return unless @sprite_text
          txt ||= ""
          fon = @style[:font]
          bmp = Bitmap.new(1,1)
          bmp.font = fon
          size = bmp.orms_text_size(txt)
          @sprite_text.bitmap = Bitmap.new(size.width, size.height)
          @sprite_text.bitmap.font = fon
          @sprite_text.bitmap.orms_draw_text(size, txt)
          @style[:width]  = size.width
          @style[:height] = size.height
        end
      end
    end
  end
end
