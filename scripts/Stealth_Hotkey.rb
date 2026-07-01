module Stealth_Hotkey
  #========================================================================
  # ТОЧНЫЕ ID ИЗ БАЗЫ ДАННЫХ
  #========================================================================
  SKILL_ID = 7   # Навык "Невидимость"
  ITEM_ID  = 5   # Предмет "Персиковая косточка..."
  #========================================================================

  VKEY_API = Win32API.new("user32", "GetAsyncKeyState", ["i"], "i")

  def self.update_map_input
    if (VKEY_API.call(0x45) & 0x8000 != 0) && !scene_busy?
      return if @e_pressed_last_frame
      @e_pressed_last_frame = true

      leader = $game_party.leader
      skill = $data_skills[SKILL_ID]
      item = $data_items[ITEM_ID]
      
      # 1. ПРИОРИТЕТ: Навык
      if leader.skill_learn?(skill) && leader.usable?(skill) && leader.mp >= leader.skill_mp_cost(skill)
        leader.mp -= leader.skill_mp_cost(skill)
        Sound.play_use_skill
        execute_stealth_system(skill)
        show_notification(skill.id, true)
        
      # 2. ОЧЕРЕДЬ: Предмет
      elsif $game_party.item_number(item) > 0
        $game_party.lose_item(item, 1)
        Sound.play_use_item
        execute_stealth_system(item)
        show_notification(item.id, false)
      else
        Sound.play_buzzer
      end
    else
      if (VKEY_API.call(0x45) & 0x8000 == 0)
        @e_pressed_last_frame = false
      end
    end
  end

  def self.scene_busy?
    $game_message.busy? || SceneManager.scene_is?(Scene_Menu)
  end

  def self.execute_stealth_system(object)
    # Совместимость со сторонними плагинами: имитируем использование для обработчиков UsableItems
    if $game_party.leader.respond_to?(:use_item)
      begin
        $game_party.leader.use_item(object)
      rescue
        # Игнорируем внутренние ошибки, если плагины требуют боевого контекста
      end
    end

    # Прямой безопасный запуск Общего События [隐身]
    object.effects.each do |effect|
      if effect.code == 44 # Код вызова Common Event
        # Резервируем событие в глобальной очереди
        $game_temp.reserve_common_event(effect.data_id)
        # Принудительно заставляем игровой интерпретатор переключиться на список команд этого события
        $game_map.interpreter.setup($data_common_events[effect.data_id].list)
      end
    end
    
    # Принудительное обновление графики игрока на карте
    $game_player.refresh
    $game_map.need_refresh = true
  end

  def self.show_notification(db_id, is_skill)
    if Object.const_defined?(:Window_Getinfo)
      txt = "Невидимость активирована!"
      type = is_skill ? 3 : 0 
      $game_temp.streffect.push(Window_Getinfo.new(db_id, type, txt, 1))
    end
  end
end

# Перехватываем обновление сцены карты
class Scene_Map < Scene_Base
  alias stealth_hotkey_update update
  def update
    stealth_hotkey_update
    Stealth_Hotkey.update_map_input if @map_name_window
  end
end