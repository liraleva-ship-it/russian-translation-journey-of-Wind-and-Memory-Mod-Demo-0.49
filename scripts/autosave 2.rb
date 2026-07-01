#==============================================================================
# ** Система Автосохранения (С защитой от крашей и ломания сюжета)
#==============================================================================
module AUTOSAVE_CONFIG
  INTERVAL = 300
  FILE_NAME = "Autosave%d.rvdata2"
  MAX_SLOTS = 16
  SHORT_NAME = "Авто"
end

#------------------------------------------------------------------------------
# * Расширение DataManager
#------------------------------------------------------------------------------
module DataManager
  class << self
    alias_method :autosave_original_load_header, :load_header unless method_defined?(:autosave_original_load_header)
    alias_method :autosave_original_load_game, :load_game unless method_defined?(:autosave_original_load_game)
  end

  def self.load_game(index)
    result = autosave_original_load_game(index)
    if result && $game_system
      $game_system.reset_autosave_timer 
    end
    return result
  end
  
  def self.load_header(index)
    if $game_system && $game_system.in_autosave_mode
      filename = sprintf(AUTOSAVE_CONFIG::FILE_NAME, index + 1)
      return nil unless File.exist?(filename)
      File.open(filename, "rb") { |file| Marshal.load(file) } rescue nil
    else
      autosave_original_load_header(index)
    end
  end

  def self.make_autosave
    $game_system.autosave_index = 0 if $game_system.autosave_index.nil?
    $game_system.autosave_index = ($game_system.autosave_index % AUTOSAVE_CONFIG::MAX_SLOTS) + 1
    filename = sprintf(AUTOSAVE_CONFIG::FILE_NAME, $game_system.autosave_index)
    File.open(filename, "wb") do |file|
      $game_system.on_before_save if $game_system.respond_to?(:on_before_save)
      Marshal.dump(make_save_header, file)
      Marshal.dump(make_save_contents, file)
    end
    $game_system.reset_autosave_timer
    return true
  rescue
    return false
  end

  def self.load_autosave(index)
    filename = sprintf(AUTOSAVE_CONFIG::FILE_NAME, index)
    return false unless File.exist?(filename)
    
    File.open(filename, "rb") do |file|
      Marshal.load(file)
      extract_save_contents(Marshal.load(file))
    end
    
    if $game_system
      $game_system.reset_autosave_timer 
      
      if $game_system.respond_to?(:force_borderless)
        $game_system.force_borderless($game_system.borderless_full?)
      elsif $game_system.respond_to?(:set_borderless)
        $game_system.set_borderless($game_system.borderless_full?)
      end
    end
    
    reload_map_if_updated
    return true
  rescue
    return false
  end
end

#------------------------------------------------------------------------------
# * Game_System
#------------------------------------------------------------------------------
class Game_System
  attr_accessor :autosave_index, :autosave_pending, :in_autosave_mode
  alias autosave_init initialize
  def initialize
    autosave_init
    @autosave_index = 0
    @autosave_pending = false
    @in_autosave_mode = false
    reset_autosave_timer
  end
  
  def reset_autosave_timer
    @last_autosave_time = Time.now.to_i
    @autosave_pending = false
  end
  
  def update_autosave_timer
    return if @last_autosave_time.nil?
    
    can_save = true
    can_save = false if $game_system.save_disabled       # Запрет сохранений ивентом
    can_save = false if $game_system.menu_disabled       # Запрет вызова меню
    can_save = false if $game_party.in_battle            # Идет битва
    can_save = false if $game_map.interpreter.running?   # Работает любой ивент/диалог
    can_save = false if !$game_player.movable?           # Игрок не может ходить
    
    can_save = false if respond_to?(:save_enabled) && !save_enabled
    
    if Time.now.to_i - @last_autosave_time >= AUTOSAVE_CONFIG::INTERVAL
      @autosave_pending = true
    end
    
    if @autosave_pending && can_save
      DataManager.make_autosave
    end
  end
end

#------------------------------------------------------------------------------
# * Scene_Map
#------------------------------------------------------------------------------
class Scene_Map < Scene_Base
  alias autosave_update update
  def update
    autosave_update
    $game_system.update_autosave_timer if $game_system
  end
end

#------------------------------------------------------------------------------
# * Window_SaveFile
#------------------------------------------------------------------------------
class Window_SaveFile < Window_Base
  alias autosave_refresh refresh
  def refresh
    autosave_refresh
    if $game_system && $game_system.in_autosave_mode
      name = "#{AUTOSAVE_CONFIG::SHORT_NAME} #{@file_index + 1}"
      contents.font.color = normal_color
      draw_text(4, 0, 200, line_height, name)
    end
  end
end

#------------------------------------------------------------------------------
# * Scene_Load
#------------------------------------------------------------------------------
class Scene_Load < Scene_File
  # Исправляем пропущенный перехват оригинального метода подтверждения выбора файла:
  alias_method :autosave_on_savefile_ok, :on_savefile_ok unless method_defined?(:autosave_on_savefile_ok)

  alias autosave_create_help_window create_help_window
  def create_help_window
    autosave_create_help_window
    update_autosave_help
  end

  def update_autosave_help
    return unless @help_window
    text = $game_system.in_autosave_mode ? "Загрузка автосейва. [Shift] — Обычные файлы." : "Загрузка файла. [Shift] — Автосейвы."
    @help_window.set_text(text)
  end

  alias autosave_update_savefile_selection update_savefile_selection
  def update_savefile_selection
    if Input.trigger?(:A) # Shift
      Sound.play_ok
      $game_system.in_autosave_mode = !$game_system.in_autosave_mode
      update_autosave_help
      @savefile_windows.each { |w| w.refresh }
      return
    end
    autosave_update_savefile_selection
  end

  def on_savefile_ok
    if $game_system.in_autosave_mode
      if DataManager.load_autosave(@index + 1)
        Sound.play_load
        fadeout_all
        $game_system.on_after_load if $game_system.respond_to?(:on_after_load)
        SceneManager.goto(Scene_Map)
      else
        Sound.play_buzzer
      end
    else
      autosave_on_savefile_ok # Теперь этот вызов отработает корректно!
    end
  end

  alias autosave_terminate terminate
  def terminate
    $game_system.in_autosave_mode = false if $game_system
    autosave_terminate
  end
end