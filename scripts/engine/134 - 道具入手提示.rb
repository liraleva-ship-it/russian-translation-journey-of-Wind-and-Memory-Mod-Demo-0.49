=begin #=======================================================================
  
◆◇ Получение информации + База картографических эффектов RGSS3 ◇◆ *порт от star
　★----- версия с дополнительной настройкой

◆Порт для VX Ace◆
◆DEICIDE ALMA
◆Рейне　
◆http://blog.goo.ne.jp/exa_deicide_alma

◆Настройка◆
◆Jun.A

★Изменения (портированная версия)

  Текст уведомления берётся из первой строки описания (справки).
  (Если указано <info:произвольная строка>, приоритет у неё)
  
  Если GET = true, то предмет, для которого показано уведомление, действительно выдаётся.
  (Предметы, оружие, броня, деньги)

★Изменения (настроенная версия / Jun.A)

  При включённом указанном переключателе, при получении или потере предметов,
  оружия, брони, навыков, денег, опыта автоматически выводится уведомление.
  
  При вызове из командного скрипта уведомление показывается независимо от переключателя.
  
  Также добавлена поддержка текстового вывода.
  Полезно для вывода простой информации.
  
  (Внимание)
    При вызове изменения опыта или изучения навыка через командный скрипт
    будет показано только уведомление, но само изменение/изучение не произойдёт.
    Для реального изменения/изучения нужен отдельный скрипт.
    При вызове через команды «Увеличение/уменьшение опыта» и «Изменение навыков»
    всё происходит автоматически.

◆Размещение
▼ В разделе материалов, выше main
  Из-за конфликта со скриптом всплывающих иконок от tomoaky,
  этот скрипт должен располагаться ниже, чем скрипт всплывающих иконок.

=end #=========================================================================
#==============================================================================
# ★RGSS2 
# STEMB_База картографических эффектов v0.8
# 
# ・Определение массивов для отображения эффектов, обновление кадра, привязка вьюпорта
#
#==============================================================================
# ★RGSS2 
# STR20_Получение информации v1.2 09/03/17
# 
# ・Уведомление, отображаемое на экране карты при получении предмета, изучении навыка и т.д.
# ・Содержимое: произвольный заголовок + название предмета + текст справки.
# ・Если в заметке предмета указать <info:произвольная строка>,
#   в уведомлении будет показана именно эта строка вместо обычного описания.
# [Особенность] Пока отображается уведомление, игрок может двигаться.
#               Если движение нежелательно, добавьте паузу.
#
#==============================================================================

# Дополнительный модуль
module CUSTOM_GET_WINDOW
  DISPLAY_FLAG = 22            # Переключатель отображения уведомлений
  GOLD_TEXT_ADD      = "Получено душ!"          # Текст при получении денег
  GOLD_TEXT_REMOVE   = "Потеряно душ…"          # Текст при потере денег
  ITEM_TEXT_ADD      = "Получен предмет!"       # Текст при получении предмета
  ITEM_TEXT_REMOVE   = "Потерян предмет…"       # Текст при потере предмета
  WEAPON_TEXT_ADD    = "Получено оружие!"       # Текст при получении оружия
  WEAPON_TEXT_REMOVE = "Потеряно оружие…"       # Текст при потере оружия
  ARMOR_TEXT_ADD     = "Получена броня!"        # Текст при получении брони
  ARMOR_TEXT_REMOVE  = "Потеряна броня…"        # Текст при потере брони
  SKILL_TEXT_ADD     = "Изучен навык!"          # Текст при изучении навыка
  SKILL_TEXT_REMOVE  = "Забыт навык…"           # Текст при забывании навыка
  EXP_TEXT_ADD       = "Получен EXP!"           # Текст при получении опыта
  EXP_TEXT_REMOVE    = "Потерян EXP…"           # Текст при потере опыта
end

class Window_Getinfo < Window_Base
  # Настройки
  #G_ICON  = 260   # Индекс иконки для денег
  G_ICON  = 120   # Индекс иконки для денег
  T_ICON  = 125   # Индекс иконки для текстовых уведомлений
  Y_TYPE  = 1     # Позиция по Y (0 = верх, 1 = низ)
  Z       = 188   # Z-координата (не меняйте, если нет проблем)
  TIME    = 180   # Время отображения уведомления (1/60 сек)
  OPACITY = 32    # Скорость изменения прозрачности
  B_COLOR = Color.new(0, 0, 0, 160)        # Цвет фона уведомления
  INFO_SE = RPG::SE.new("magic1", 80, 80)  # Звук при появлении уведомления
  
  #STR20W  = /info\[\/(.*)\/\]/im          # Ключевое слово для заметки (VX)
  STR20W  = /<info:(.*?)>/im               # Ключевое слово для заметки
  
  GET = true # Получать ли предмет, для которого показано уведомление (кроме навыков)
end
#
if false
# ★ Вставьте следующий код в командный скрипт для вывода текстового уведомления ----★

# Тип / 0=предмет 1=оружие 2=броня 3=навык 4=деньги 5=текст (новое)
type = 0
# ID / для денег введите сумму
id   = 1
# Текст уведомления / для денег не используется
text = "Получен предмет!"
# Количество (число) / поддерживаются положительные и отрицательные значения
value = 1
e = $game_temp.streffect
e.push(Window_Getinfo.new(id, type, text, value))
# ★ Конец вставки ----------------------------------------------------------★
# □ Дополнительно: текстовая функция.

# Тип / 0=предмет 1=оружие 2=броня 3=навык 4=деньги 5=текст (новое)
type = 0
# ID / текст, который будет отображаться крупно
id   = "Тестовый комментарий"
# Текст / текст, который будет отображаться мелко
text = "Мини-информация"
# Значение не имеет значения, но обязательно укажите ноль
# ※ Без него мини-уведомление не отобразится
value = 0
#
e = $game_temp.streffect
e.push(Window_Getinfo.new(id, type, text))
# ★ Конец вставки ----------------------------------------------------------★
#
# ◇ При изучении навыка и т.п., если вписать имя актёра напрямую,
#    могут возникнуть проблемы в играх, где имя актёра можно менять.
#    Поэтому, возможно, стоит модифицировать текст, как показано ниже.
#
# Получение имени актёра с указанным ID
t = $game_actors[1].name 
text = t + " / Навык изучен!"
#
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● Открытые переменные экземпляра
  #--------------------------------------------------------------------------
  attr_accessor :streffect
  #--------------------------------------------------------------------------
  # ● Инициализация объекта
  #--------------------------------------------------------------------------
  alias initialize_stref initialize
  def initialize
    initialize_stref
    @streffect = []
  end
end

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● Создание эффектов
  #--------------------------------------------------------------------------
  def create_streffect
    $game_temp.streffect = []
  end
  #--------------------------------------------------------------------------
  # ● Освобождение эффектов
  #--------------------------------------------------------------------------
  def dispose_streffect
    (0...$game_temp.streffect.size).each do |i|
      $game_temp.streffect[i].dispose if $game_temp.streffect[i] != nil
    end
    $game_temp.streffect = []
  end
  #--------------------------------------------------------------------------
  # ● Обновление эффектов
  #--------------------------------------------------------------------------
  def update_streffect
    (0...$game_temp.streffect.size).each do |i|
      if $game_temp.streffect[i] != nil
        $game_temp.streffect[i].viewport = @viewport1
        $game_temp.streffect[i].update
        $game_temp.streffect.delete_at(i) if $game_temp.streffect[i].disposed?
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Создание параллакса (alias)
  #--------------------------------------------------------------------------
  alias create_parallax_stref create_parallax
  def create_parallax
    create_parallax_stref
    create_streffect
  end
  #--------------------------------------------------------------------------
  # ● Освобождение (alias)
  #--------------------------------------------------------------------------
  alias dispose_stref dispose
  def dispose
    dispose_streffect
    dispose_stref
  end
  #--------------------------------------------------------------------------
  # ● Обновление (alias)
  #--------------------------------------------------------------------------
  alias update_stref update
  def update
    update_stref
    update_streffect
  end
end

class Window_Getinfo < Window_Base
  #--------------------------------------------------------------------------
  # ● Инициализация объекта
  #--------------------------------------------------------------------------
  def initialize(id, type, text = "", value)
    #super(-16, 0, 544 + 32, 38 + 32)
    super(-16, 0, 640 + 32, 38 + 32)
    self.z = Z
    self.contents_opacity = 0
    self.back_opacity = 0
    self.opacity = 0
    @value = value
    @count = 0
    @i = $game_temp.getinfo_size.index(nil)
    @i = $game_temp.getinfo_size.size if (@i == nil)
    if Y_TYPE == 0
      self.y = -14 + (@i * 40)
    else
      #self.y = 418 - 58 - (@i * 40)
      self.y = 480 - 58 - (@i * 40)
    end
    $game_temp.getinfo_size[@i] = true 
    refresh(id, type, text, @value)
    # Воспроизведение звука. Проверка типа: 0–3 смотрят value, 4 (деньги) – id
    case type
    when 0..3
      if @value >= 1
        INFO_SE.play
      elsif @value <= -1
        #Sound.play_evasion # при потере звук не проигрывается
      end
    when 4
      if id >= 1
        Audio.se_play("Audio/SE/magic1", 80, 80)
      elsif id <= -1
        #Sound.play_evasion
      end
    when 5
        Audio.se_play('Audio/SE/Chime1', 80)
    when 6
      if @value >= 1
        INFO_SE.play
      elsif @value <= -1
        #Sound.play_evasion
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Освобождение
  #--------------------------------------------------------------------------
  def dispose
    $game_temp.getinfo_size[@i] = nil
    super
  end
  #--------------------------------------------------------------------------
  # ● Обновление кадра
  #--------------------------------------------------------------------------
  def update
    self.viewport = nil
    @count += 1
    unless @count >= TIME
      self.contents_opacity += OPACITY
    else
      if Y_TYPE == 0
        self.y -= 1
      else
        self.y += 1
      end
      self.contents_opacity -= OPACITY
      dispose if self.contents_opacity == 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Обновление содержимого
  #--------------------------------------------------------------------------
  def refresh(id, type, text = "", value)
    case type
    when 0 ; data = $data_items[id]
    when 1 ; data = $data_weapons[id]
    when 2 ; data = $data_armors[id]
    when 3 ; data = $data_skills[id]
    when 4 ; data = id
    when 5 ; data = id  # принудительно помещаем текстовые данные в data
    when 6 ; data = id  # фактическое значение изменения опыта
    else   ; p "Неверное значение type!><;"
    end
    c = B_COLOR
    #self.contents.fill_rect(0, 14, 544, 24, c)
    self.contents.fill_rect(0, 14, 644, 24, c)
    case type # ветвление по типу
    when 0..2 # предмет, оружие, броня
      draw_item_name(data, 4, 14)
      self.contents.draw_text(204, 14, 18, line_height, "х")
      self.contents.draw_text(220, 14, 36, line_height, value)
      self.contents.draw_text(258, 14, 382, line_height, description(data))
    when 3 # навык
      draw_item_name(data, 4, 14)
      self.contents.draw_text(204, 14, 436, line_height, description(data))
    when 4 # деньги
      draw_icon(G_ICON, 4, 14)
      self.contents.draw_text(28, 14, 176, line_height, 
      data.to_s + Vocab.currency_unit)
      $game_party.gain_gold(id) if GET
    when 5 # текстовый вывод
      draw_icon(T_ICON, 4, 14)
      self.contents.draw_text(28, 14, 612, line_height, data)
    when 6 # опыт
      self.contents.draw_text(16, 14, 48, line_height, "Опыт：")
      self.contents.draw_text(56, 14, 584, line_height, data)
    end
    self.contents.font.size = 14
    w = self.contents.text_size(text).width
    self.contents.fill_rect(0, 0, w + 4, 14, c)
    self.contents.draw_text_f(4, 0, 340, 14, text)
    # Получение / потеря предмета
    $game_party.gain_item(data,@value) if type <= 2 && GET && @value >= 1  # получение
    $game_party.gain_item(data,@value,true) if type <= 2 && GET && @value <= -1 # потеря
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● Получение поясняющего текста
  #--------------------------------------------------------------------------
  def description(data)
    if data.note =~ /#{STR20W}/
      return $1
    end
    text = data.description.dup
    text.sub!(/[\r\n]+.*/m, "")
    return text
  end
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● Открытые переменные экземпляра
  #--------------------------------------------------------------------------
  attr_accessor :getinfo_size
  #--------------------------------------------------------------------------
  # ● Инициализация объекта
  #--------------------------------------------------------------------------
  alias initialize_str20 initialize
  def initialize
    initialize_str20
    @getinfo_size = []
  end
end

class Bitmap
  unless public_method_defined?(:draw_text_f)
    #--------------------------------------------------------------------------
    # ● Отрисовка текста с обводкой
    #--------------------------------------------------------------------------
    def draw_text_f(x, y, width, height, str, align = 0, color = Color.new(64,32,128))
      shadow = self.font.shadow
      b_color = self.font.color.dup
      outline = self.font.outline
      self.font.outline = false
      font.shadow = false
      font.color = color
      draw_text(x + 1, y, width, height, str, align) 
      draw_text(x - 1, y, width, height, str, align) 
      draw_text(x, y + 1, width, height, str, align) 
      draw_text(x, y - 1, width, height, str, align) 
      font.color = b_color
      draw_text(x, y, width, height, str, align)
      font.shadow = shadow
      self.font.outline = outline
    end
    def draw_text_f_rect(r, str, align = 0, color = Color.new(64,32,128)) 
      draw_text_f(r.x, r.y, r.width, r.height, str, align, color) 
    end
  end
end

#--------------------------------------------------------------------------
# ★ Дополнение – при включённом переключателе автоматически показывать уведомления
#    о получении предметов, оружия, брони, навыков, текста.
#--------------------------------------------------------------------------

class Game_Interpreter
  
  #--------------------------------------------------------------------------
  # override method: command_125 // изменение денег
  #--------------------------------------------------------------------------
  alias game_interpreter_command_125_ew command_125
  def command_125
    #game_interpreter_command_125_ew # не используем алиас (избегаем многократного сложения)
    value = operate_value(@params[0], @params[1], @params[2])
    
    if value >= 1 # деньги увеличиваются
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG] # проверка переключателя
        type = 4
        id = value
        text = CUSTOM_GET_WINDOW::GOLD_TEXT_ADD
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_gold(value)
      end
    elsif value <= -1  # деньги уменьшаются
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 4
        id = value
        text = CUSTOM_GET_WINDOW::GOLD_TEXT_REMOVE
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_gold(value)
      end
    end
  end  
  #--------------------------------------------------------------------------
  # override method: command_126 // изменение предметов
  #--------------------------------------------------------------------------
  alias game_interpreter_command_126_ew command_126
  def command_126
    value = operate_value(@params[1], @params[2], @params[3])
    
    if value >= 1 # предметов прибавилось
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 0
        id = @params[0]
        text = CUSTOM_GET_WINDOW::ITEM_TEXT_ADD
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_item($data_items[@params[0]], value)
      end
    elsif value <= -1  # предметов убавилось
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 0
        id = @params[0]
        text = CUSTOM_GET_WINDOW::ITEM_TEXT_REMOVE
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_item($data_items[@params[0]], value)
      end
    end
  end  
  #--------------------------------------------------------------------------
  # override method: command_127 // изменение оружия
  #--------------------------------------------------------------------------
  alias game_interpreter_command_127_ew command_127
  def command_127
    value = operate_value(@params[1], @params[2], @params[3])
    
    if value >= 1 # оружия прибавилось
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 1
        id = @params[0]
        text = CUSTOM_GET_WINDOW::WEAPON_TEXT_ADD
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
      end
    elsif value <= -1  # оружия убавилось
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 1
        id = @params[0]
        text = CUSTOM_GET_WINDOW::WEAPON_TEXT_REMOVE
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_item($data_weapons[@params[0]], value, @params[4])
      end
    end
  end  
  #--------------------------------------------------------------------------
  # override method: command_128 // изменение брони
  #--------------------------------------------------------------------------
  alias game_interpreter_command_128_ew command_128
  def command_128
    
    value = operate_value(@params[1], @params[2], @params[3])
    
    if value >= 1 # брони прибавилось
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 2
        id = @params[0]
        text = CUSTOM_GET_WINDOW::ARMOR_TEXT_ADD
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_item($data_armors[@params[0]], value, @params[4])
      end
    elsif value <= -1  # брони убавилось
      if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
        type = 2
        id = @params[0]
        text = CUSTOM_GET_WINDOW::ARMOR_TEXT_REMOVE
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      else
        $game_party.gain_item($data_armors[@params[0]], value, @params[4])
      end
    end
  end
  #--------------------------------------------------------------------------
  # override method command_318 // изменение навыков
  #--------------------------------------------------------------------------
  alias game_interpreter_command_318_ew command_318
  def command_318
    # Найти актёра и изучить/забыть указанный навык
    # @params[1] = ID актёра / $data_actors[] ID в базе
    # @params[2] = изучить (0) или забыть (1)
    # @params[3] = ID навыка
    iterate_actor_var(@params[0], @params[1]) do |actor|
      if @params[2] == 0
        actor.learn_skill(@params[3])
      else
        actor.forget_skill(@params[3])
      end
    end
    
    if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
      if @params[2] == 0 # изучение
        type = 3
        id = @params[3]
        actor_name = $data_actors[@params[1]].name 
        text = actor_name + " / " + CUSTOM_GET_WINDOW::SKILL_TEXT_ADD
        value = 1 # флаг получения
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      elsif @params[2] == 1 # забывание
        type = 3
        id = @params[3]
        actor_name = $data_actors[@params[1]].name 
        text = actor_name + " / " + CUSTOM_GET_WINDOW::SKILL_TEXT_REMOVE
        value = -1 # флаг потери
        e = $game_temp.streffect
        e.push(Window_Getinfo.new(id, type, text, value))
      end
    end
  end
  #--------------------------------------------------------------------------
  # override method command_315 // изменение опыта
  #--------------------------------------------------------------------------
  def command_315
    value = operate_value(@params[2], @params[3], @params[4])
    iterate_actor_var(@params[0], @params[1]) do |actor|
      actor.change_exp(actor.exp + value, @params[5])
    end
    #p @params[1] # указан ли конкретный персонаж (0 или 1)
    #p @params[14] # номер персонажа или значение переменной (при переменной) ★
    #p @params[2] # увеличение (0) или уменьшение (1) ★
    #p @params[3] # константа (0) или переменная (1)
    #p @params[4] # фактическое значение ★
    #p @params[5] # показывать ли повышение уровня? ★
    
    if $game_switches[CUSTOM_GET_WINDOW::DISPLAY_FLAG]
      type = 6
      if @params[1] == 0  # вся партия (0) или отдельный персонаж (1～)
        actor_name = "Вся партия"
      else
        actor_name = $data_actors[@params[1]].name
      end
      if @params[2] == 0  # увеличение (0) или уменьшение (1)
        text = actor_name + " / " + CUSTOM_GET_WINDOW::EXP_TEXT_ADD
        value = 1 # флаг получения
        id = @params[4] # в ID записываем значение изменения
      elsif @params[2] == 1
        text = actor_name + " / " + CUSTOM_GET_WINDOW::EXP_TEXT_REMOVE
        value = -1 # флаг потери
        id = @params[4] * -1
      end
      e = $game_temp.streffect
      e.push(Window_Getinfo.new(id, type, text, value))
    end
  end
end