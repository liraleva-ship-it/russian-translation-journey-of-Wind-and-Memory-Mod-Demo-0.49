# ============= ModLoaderData =============
class ModLoaderData
  attr_accessor :shared_data
  
  DATA_FILENAME = "ModLoaderData.rvdata2"
  
  def initialize
    @shared_data = {}
  end
  
  def []=(key, value)
    @shared_data[key] = value
    save_database
  end
  
  def [](key)
    @shared_data[key]
  end
  
  def save_database
    save_data(self, DATA_FILENAME)
  end
  
  def self.load_database
    if File.exist?(DATA_FILENAME)
      load_data(DATA_FILENAME)
    else
      db = ModLoaderData.new
      db.shared_data[:sys_volume] = { :sfx => 100, :bgs => 100, :bgm => 100 }
      db.save_database
      db
    end
  end
end

# ============= DataManager =============
module DataManager
  class << self
    alias mlnvram_orig_load_normal_database load_normal_database
  end

  def self.load_normal_database
    mlnvram_orig_load_normal_database
    $data_mod_loader = ModLoaderData.load_database
    # Сразу же применяем громкость к аудиомикшеру при старте игры
    apply_initial_volumes
  end
  
  def self.apply_initial_volumes
    return unless $data_mod_loader[:sys_volume]
    # Настройка дефолтных значений для Yanfly System Options, если скрипт активен
    if defined?(YEA::SYSTEM)
      RPG::BGM.init_volume rescue nil
      RPG::BGS.init_volume rescue nil
      RPG::SE.init_volume  rescue nil
    end
  end
end

# ============= Game_System =============
class Game_System
  alias permanent_opts_init_volume_control initialize
  def initialize
    permanent_opts_init_volume_control
    init_volume_control
  end

  def init_volume_control
    $data_mod_loader[:sys_volume] ||= {}
    $data_mod_loader[:sys_volume][:sfx] ||= 100
    $data_mod_loader[:sys_volume][:bgs] ||= 100
    $data_mod_loader[:sys_volume][:bgm] ||= 100
  end

  def volume(type)
    init_volume_control if $data_mod_loader[:sys_volume][type].nil?
    return [[$data_mod_loader[:sys_volume][type].to_i, 0].max, 100].min
  end
  
  def volume_change(type, increment)
    init_volume_control if $data_mod_loader[:sys_volume][type].nil?
    $data_mod_loader[:sys_volume][type] += increment
    $data_mod_loader[:sys_volume][type] = [[$data_mod_loader[:sys_volume][type], 0].max, 100].min
    $data_mod_loader.save_database
  end
end

# ============= Scene_System =============
class Scene_System
  alias sysopts_permanent_orig_start start
  alias sysopts_permanent_orig_command_to_title command_to_title
  alias sysopts_permanent_orig_command_shutdown command_shutdown
  
  def start
    sysopts_permanent_dup_options
    sysopts_permanent_orig_start
  end
  
  def return_scene
    sysopts_permanent_save_options
    super
  end
  
  def command_to_title
    sysopts_permanent_save_options
    sysopts_permanent_orig_command_to_title
  end
  
  def command_shutdown
    sysopts_permanent_save_options
    sysopts_permanent_orig_command_shutdown
  end
  
  def sysopts_permanent_dup_options
    $data_mod_loader.init_volume_control rescue nil
    @old_options = $data_mod_loader[:sys_volume] ? $data_mod_loader[:sys_volume].dup : {}
  end
  
  def sysopts_permanent_save_options
    return if @old_options == $data_mod_loader[:sys_volume]
    $data_mod_loader.save_database
  end
end

# ============= Window_TitleCommand =============
class Window_TitleCommand
  alias sysopts_permanent_orig_make_command_list make_command_list
  
  def make_command_list
    add_command(Vocab::new_game, :new_game)
    add_command(Vocab::continue, :continue, continue_enabled)
    
    if defined?(YEA::MENU::COMMANDS)
      for command in YEA::MENU::COMMANDS
        case command
        when :grathnode
          next unless $imported["KRX-GrathnodeInstall"]
          process_custom_command(command)
        when :gogototori
          next unless $imported["KRX-AlchemicSynthesis"]
          process_custom_command(command)
        else
          process_custom_command(command)
        end
      end
    end
    
    add_command(Vocab::shutdown, :shutdown)
  end
  
  def process_custom_command(command)
    return unless YEA::MENU::CUSTOM_COMMANDS.include?(command)
    text = YEA::MENU::CUSTOM_COMMANDS[command][0]
    add_command(text, command, true)
  end
end

# ============= Scene_Title =============
class Scene_Title
  alias sysopts_permanent_orig_create_command_window create_command_window
  
  def create_command_window
    sysopts_permanent_orig_create_command_window
    process_custom_commands if defined?(YEA::MENU::COMMANDS)
  end
  
  def process_custom_commands
    for command in YEA::MENU::COMMANDS
      next unless YEA::MENU::CUSTOM_COMMANDS.include?(command)
      called_method = YEA::MENU::CUSTOM_COMMANDS[command][3]
      @command_window.set_handler(command, method(called_method))
    end
  end
  
  def command_system
    SceneManager.call(Scene_System)
  end
end

# ============= Переводы локализации =============
if defined?(YEA::MENU::CUSTOM_COMMANDS) && YEA::MENU::CUSTOM_COMMANDS[:game_options]
  YEA::MENU::CUSTOM_COMMANDS[:game_options][0] = "Настройки"
end

if defined?(YEA::SYSTEM::COMMAND_VOCAB)
  YEA::SYSTEM::COMMAND_VOCAB[:volume_bgm][0] = "Громкость музыки"
  YEA::SYSTEM::COMMAND_VOCAB[:volume_bgm][3] = "Изменить громкость музыки, играющей на фоне.\nЗажмите shift для изменения сразу на +-10"
    
  YEA::SYSTEM::COMMAND_VOCAB[:volume_bgs][0] = "Громкость звуков"
  YEA::SYSTEM::COMMAND_VOCAB[:volume_bgs][3] = "Изменить громкость звуков, играющих на фоне.\nЗажмите shift для изменения сразу на +-10"
    
  YEA::SYSTEM::COMMAND_VOCAB[:volume_sfx][0] = "Громкость спецэффектов"
  YEA::SYSTEM::COMMAND_VOCAB[:volume_sfx][3] = "Изменить громкость звуковых эффектов.\nЗажмите shift для изменения сразу на +-10"
    
  YEA::SYSTEM::COMMAND_VOCAB[:autodash][0] = "Авто-бег"
  YEA::SYSTEM::COMMAND_VOCAB[:autodash][1] = "Ходьба"
  YEA::SYSTEM::COMMAND_VOCAB[:autodash][2] = "Бег"
  YEA::SYSTEM::COMMAND_VOCAB[:autodash][3] = "Автоматически бежать без зажатия кнопки бега."

  YEA::SYSTEM::COMMAND_VOCAB[:instantmsg][0] = "Мгновенный текст"
  YEA::SYSTEM::COMMAND_VOCAB[:instantmsg][1] = "Обычный"
  YEA::SYSTEM::COMMAND_VOCAB[:instantmsg][2] = "Мгновенный"
  YEA::SYSTEM::COMMAND_VOCAB[:instantmsg][3] = "Выводить символы в тексте один за другим или мгновенно."

  YEA::SYSTEM::COMMAND_VOCAB[:animations][0] = "Анимации битвы"
  YEA::SYSTEM::COMMAND_VOCAB[:animations][1] = "Скрыть"
  YEA::SYSTEM::COMMAND_VOCAB[:animations][2] = "Показывать"
  YEA::SYSTEM::COMMAND_VOCAB[:animations][3] = "Скрыть анимации во время битвы для её ускорения?"
end