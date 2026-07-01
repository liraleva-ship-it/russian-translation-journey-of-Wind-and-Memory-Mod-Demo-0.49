#==============================================================================
# ▼ Fullscreen Control Patch (Borderless Mode for YEA System Options)
#==============================================================================

module YEA
  module SYSTEM
    # Регистрируем команду в списке
    unless COMMANDS.include?(:borderless)
      # Вставляем после WASD или в конец
      idx = COMMANDS.index(:wasd) || -1
      COMMANDS.insert(idx + 1, :borderless)
    end

    # Локализация
    COMMAND_VOCAB[:borderless] = [
      "Экран",                 # Название опции
      "Окно",                  # OFF
      "Полный",                # ON
      "Переключение между оконным и полноэкранным режимом." # Описание
    ]
  end
end

#----------------------------------------------------------------
# Graphics - Модуль управления окном
#----------------------------------------------------------------
module Graphics
  HWND_TOP       = 0
  SWP_SHOWWINDOW = 0x0040
  WS_POPUP       = 0x80000000
  GWL_STYLE      = -16

  def self.set_borderless(enabled)
    @is_full = enabled
    hwnd = Win32API.new('user32', 'GetActiveWindow', [], 'L').call
    set_window_long = Win32API.new('user32', 'SetWindowLong', 'LLL', 'L')
    get_window_long = Win32API.new('user32', 'GetWindowLong', 'LL', 'L')
    set_window_pos  = Win32API.new('user32', 'SetWindowPos', 'LLIIIII', 'I')
    sm_cx = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I').call(0)
    sm_cy = Win32API.new('user32', 'GetSystemMetrics', 'I', 'I').call(1)

    if enabled
      @old_style = get_window_long.call(hwnd, GWL_STYLE)
      set_window_long.call(hwnd, GWL_STYLE, WS_POPUP)
      set_window_pos.call(hwnd, HWND_TOP, 0, 0, sm_cx, sm_cy, SWP_SHOWWINDOW)
    else
      return if @old_style.nil?
      set_window_long.call(hwnd, GWL_STYLE, @old_style)
      # Возврат к стандартному размеру (обычно 544x416 или 640x480)
      w = 640 ; h = 480 # Замени на свои, если менял разрешение проекта
      x = (sm_cx - w) / 2 ; y = (sm_cy - h) / 2
      set_window_pos.call(hwnd, HWND_TOP, x, y, w, h, SWP_SHOWWINDOW)
    end
  end
end

#----------------------------------------------------------------
# Game_System - Хранение состояния
#----------------------------------------------------------------
class Game_System
  alias borderless_init initialize
  def initialize
    borderless_init
    @borderless_full = false
  end

  def borderless_full?
    @borderless_full ||= false
  end

  def set_borderless(value)
    return if @borderless_full == value
    @borderless_full = value
    Graphics.set_borderless(value)
  end
  
  # Новый метод: принудительное применение БЕЗ проверки на равенство старого значения
  def force_borderless(value)
    @borderless_full = value
    Graphics.set_borderless(value)
  end
end

#----------------------------------------------------------------
# Scene_Load - Активация фуллскрина при загрузке сейва
#----------------------------------------------------------------
class Scene_Load < Scene_File
  
  alias borderless_on_load_success on_load_success
  def on_load_success
    borderless_on_load_success
    # Если в загруженном сейве включен фуллскрин — принудительно его включаем
    if $game_system.borderless_full?
      $game_system.force_borderless(true)
    end
    # Если в сейве стоит "Окно" (false) — мы ничего не делаем, 
    # тем самым поведение оконного режима не меняется.
  end
end

#----------------------------------------------------------------
# Window_SystemOptions - Отрисовка и логика
#----------------------------------------------------------------
class Window_SystemOptions < Window_Command

  alias borderless_make_command_list make_command_list
  def make_command_list
    borderless_make_command_list
    unless @list.any? { |cmd| cmd[:symbol] == :borderless }
      add_command(YEA::SYSTEM::COMMAND_VOCAB[:borderless][0], :borderless)
      @help_descriptions[:borderless] = YEA::SYSTEM::COMMAND_VOCAB[:borderless][3]
    end
  end

  alias borderless_draw_item draw_item
  def draw_item(index)
    if @list[index][:symbol] == :borderless
      draw_borderless_option(item_rect(index))
    else
      borderless_draw_item(index)
    end
  end

  def draw_borderless_option(rect)
    change_color(normal_color) 
    name = YEA::SYSTEM::COMMAND_VOCAB[:borderless][0]
    draw_text(0, rect.y, contents.width/2, line_height, name, 1)
    
    enabled = $game_system.borderless_full?
    dx = contents.width/2
    
    # Цвет для варианта "Окно"
    change_color(normal_color, !enabled)
    draw_text(dx, rect.y, contents.width/4, line_height, YEA::SYSTEM::COMMAND_VOCAB[:borderless][1], 1)
    
    # Цвет для варианта "Полный"
    dx += contents.width/4
    change_color(normal_color, enabled)
    draw_text(dx, rect.y, contents.width/4, line_height, YEA::SYSTEM::COMMAND_VOCAB[:borderless][2], 1)
  end

  alias borderless_cursor_change cursor_change
  def cursor_change(direction)
    if current_symbol == :borderless
      if direction == :left || direction == :right
        value = (direction == :right)
        old_val = $game_system.borderless_full?
        $game_system.set_borderless(value)
        Sound.play_cursor if old_val != value
        draw_item(index)
      end
    else
      borderless_cursor_change(direction)
    end
  end
end