#==============================================================================
# ▼ WASD Control Patch — System Options Integration Only
#   [ОЧИЩЕН ОТ КОНФЛИКТНОГО МОДУЛЯ INPUT]
#==============================================================================

module YEA
  module SYSTEM
    unless COMMANDS.include?(:wasd)
      idx = COMMANDS.index(:instantmsg) || -1
      COMMANDS.insert(idx, :wasd)
    end

    COMMAND_VOCAB[:wasd] = [
      "Управление",      
      "Стрелки",        
      "WASD",           
      "Полное переключение управления между стрелками и WASD." 
    ]
  end
end

class Game_System
  alias wasd_init initialize
  def initialize
    wasd_init
    @wasd_enabled = false
  end

  def wasd_enabled?
    @wasd_enabled ||= false
  end

  def set_wasd(value)
    @wasd_enabled = value
  end
end

class Window_SystemOptions < Window_Command
  alias wasd_make_command_list make_command_list
  def make_command_list
    wasd_make_command_list
    unless @list.any? { |cmd| cmd[:symbol] == :wasd }
      add_command(YEA::SYSTEM::COMMAND_VOCAB[:wasd][0], :wasd)
      @help_descriptions[:wasd] = YEA::SYSTEM::COMMAND_VOCAB[:wasd][3]
    end
  end

  alias wasd_draw_item draw_item
  def draw_item(index)
    if @list[index][:symbol] == :wasd
      draw_wasd(item_rect(index))
    else
      wasd_draw_item(index)
    end
  end

  def draw_wasd(rect)
    name = YEA::SYSTEM::COMMAND_VOCAB[:wasd][0]
    draw_text(0, rect.y, contents.width/2, line_height, name, 1)

    enabled = $game_system.wasd_enabled?
    dx = contents.width/2
    
    change_color(normal_color, !enabled)
    draw_text(dx, rect.y, contents.width/4, line_height, YEA::SYSTEM::COMMAND_VOCAB[:wasd][1], 1)

    dx += contents.width/4
    change_color(normal_color, enabled)
    draw_text(dx, rect.y, contents.width/4, line_height, YEA::SYSTEM::COMMAND_VOCAB[:wasd][2], 1)
  end

  alias wasd_cursor_change cursor_change
  def cursor_change(direction)
    if current_symbol == :wasd
      if direction == :left || direction == :right
        value = (direction == :right)
        old_val = $game_system.wasd_enabled?
        $game_system.set_wasd(value)
        Sound.play_cursor if old_val != value
        draw_item(index)
      end
    else
      wasd_cursor_change(direction)
    end
  end
end