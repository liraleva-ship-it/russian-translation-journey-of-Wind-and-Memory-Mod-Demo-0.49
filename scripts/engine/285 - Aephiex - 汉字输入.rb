#==============================================================================
# ◆ Ввод текста by Aephiex
#------------------------------------------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#------------------------------------------------------------------------------
#
#  Основные функции
#  ◎ При именовании персонажа можно вводить различные символы.
#     Включено около 6500 символов, удовлетворяя большинство потребностей.
#     Во время ввода нажатие shift выполняет backspace.
#  ◎ Добавлена вызываемая в событиях команда input_text(max_char = 8, default = "")
#     Запрашивает у игрока ввод текста длиной 8 символов, по умолчанию пусто.
#     Эта команда возвращает введённый игроком текст в качестве возвращаемого значения.
#     Можно использовать $game_variables[...] для его получения и затем в тексте событий
#     использовать \V[...] для вызова.
#
#==============================================================================
 
module AephiexConfig
 
  # Разрешить ввод греческих и русских букв
  # Обратите внимание: на некоторых шрифтах эти буквы могут отображаться как □
  GREEK_RUSSIAN   = true
 
  # Разрешить ввод специальных латинских букв (Á и т.п.)
  # Обратите внимание: на некоторых шрифтах эти буквы могут отображаться как □
  LATIN_SPECIAL   = true
 
end
 
module AephiexString
 
  # Названия команд на экране ввода
  NMI_ABC123           = "Латиница"
  NMI_GrRu             = "Греч/Рус"
  NMI_LatinSp          = "Спец. латиница"
  NMI_SPCHAR           = "Символы"
  NMI_OK               = "Готово"
  NMI_Back             = "←"
  NMI_Clear            = "Очистить"
  NMI_Reset            = "Сброс"
 
end
 
#==============================================================================
# □ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ¤ Скрипт: ввод текста
  #--------------------------------------------------------------------------
  def input_text(max_char = 8, default = "")
    return if $game_party.in_battle
    SceneManager.call(Scene_Name)
    SceneManager.scene.prepare(default, max_char)
    Fiber.yield
    val = $temp_input_string
    $temp_input_string = nil
    return val
  end
end
 
 
#==============================================================================
# □ Scene_Name
#==============================================================================
class Scene_Name
  #--------------------------------------------------------------------------
  # ● Запуск
  #--------------------------------------------------------------------------
  def start
    super
    @actor = @actor_id.is_a?(String) ? @actor_id : $game_actors[@actor_id]
    @edit_window = Window_NameEdit.new(@actor, @max_char)
    @command_window = Window_NameInput_Command.new(@edit_window)
    @command_window.set_handler(:command_ok, method(:char_selection))
    @command_window.set_handler(:ok, method(:on_input_ok))
    @char_window = Window_NameInput_Char.new(@command_window, @edit_window)
    @char_window.set_handler(:cancel, method(:command_selection))
    command_selection
  end
  #--------------------------------------------------------------------------
  # ● Ввод [Подтвердить]
  #--------------------------------------------------------------------------
  def on_input_ok
    if @actor.is_a?(String)
      $temp_input_string = @edit_window.name
    else
      @actor.name = @edit_window.name
    end
    return_scene
  end
  #--------------------------------------------------------------------------
  # ¤ Начало выбора команд
  #--------------------------------------------------------------------------
  def command_selection
    @char_window.select(-1)
    @char_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ¤ Начало выбора символов
  #--------------------------------------------------------------------------
  def char_selection
    @command_window.deactivate
    @char_window.select(0)
    @char_window.activate
  end
end
 
 
#==============================================================================
# □ Window_NameEdit
#==============================================================================
class Window_NameEdit
  #--------------------------------------------------------------------------
  # ● Инициализация объекта
  #--------------------------------------------------------------------------
  def initialize(actor, max_char)
    x = (Graphics.width - 360) / 2
    y = (Graphics.height - (fitting_height(4) + fitting_height(9) + 8)) / 2
    super(x, y, 360, fitting_height(4))
    @max_char = max_char
    if actor.is_a?(String)
      @actor = nil
      @default_name = @name = actor
    else
      @actor = actor
      @default_name = @name = actor.name[0, @max_char]
    end
    @index = @name.size
    deactivate
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Получение левой координаты для отрисовки имени
  #--------------------------------------------------------------------------
  def left
    if @left == nil
      if @actor
        name_center = (contents_width + face_width) / 2
        name_width = (@max_char + 1) * char_width
        v1 = name_center - name_width / 2
        v2 = contents_width - name_width
        @left = v1 < v2 ? v1 : v2
      else
        @left = (contents_width - @max_char * char_width) / 2
      end
    end
    return @left
  end
  #--------------------------------------------------------------------------
  # ● Получение ширины символа
  #--------------------------------------------------------------------------
  def char_width
    return @char_width ||= text_size("あ").width
  end
  #--------------------------------------------------------------------------
  # ○ Очистить
  #--------------------------------------------------------------------------
  def clear
    @name = ""
    @index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Обновление
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_face(@actor, 0, 0) if @actor
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    cursor_rect.set(item_rect(@index))
  end
  #--------------------------------------------------------------------------
  # ● Отрисовка символа
  #--------------------------------------------------------------------------
  def draw_char(index)
    rect = item_rect(index)
    rect.x -= 1
    rect.width += 4
    change_color(normal_color)
    draw_text(rect, @name[index] || "", 1)
  end
end
 
 
#==============================================================================
# ■ Window_NameInput_Command
#------------------------------------------------------------------------------
# Окно команд для переключения страниц символов.
#==============================================================================
class Window_NameInput_Command < Window_Command
  #--------------------------------------------------------------------------
  # ¤ Константы класса
  #--------------------------------------------------------------------------
  LATIN1 = [ 'A','B','C','D','E',  'a','b','c','d','e',
             'F','G','H','I','J',  'f','g','h','i','j',
             'K','L','M','N','O',  'k','l','m','n','o',
             'P','Q','R','S','T',  'p','q','r','s','t',
             'U','V','W','X','Y',  'u','v','w','x','y',
             'Z','[',']','^','_',  'z','{','}','|','~',
             '0','1','2','3','4',  '!','#','$','%','&',
             '5','6','7','8','9',  '(',')','*','+','-',
             '/','=','@','<','>',  ':',';',' ']
  LATIN2 = [ 'Α','Β','Γ','Δ','Ε',  'α','β','γ','δ','ε',
             'Ζ','Η','Θ','Ι','Κ',  'ζ','η','θ','ι','κ',
             'Λ','Μ','Ν','Ξ','Ο',  'λ','μ','ν','ξ','ο',
             'Π','Ρ','Σ','Τ','Υ',  'π','ρ','σ','τ','υ',
             'Φ','Χ','Ψ','Ω','℩',  'φ','χ','ψ','ω','ς',
             'А','Б','В','Г','Д',  'а','б','в','г','д',
             'Е','Ё','Ж','З','И',  'е','ё','ж','з','и',
             'Й','К','Л','М','Н',  'й','к','л','м','н',
             'О','П','Р','С','Т',  'о','п','р','с','т',
             'У','Ф','Х','Ц','Ч',  'у','ф','х','ц','ч',
             'Ш','Щ','Ъ','Ы','Ь',  'ш','щ','ъ','ы','ь',
             'Э','Ю','Я',' ',' ',  'э','ю','я',' ',' ']
  LATIN3 = [ 'Á','É','Í','Ó','Ú',  'á','é','í','ó','ú',
             'À','È','Ì','Ò','Ù',  'à','è','ì','ò','ù',
             'Â','Ê','Î','Ô','Û',  'â','ê','î','ô','û',
             'Ä','Ë','Ï','Ö','Ü',  'ä','ë','ï','ö','ü',
             'Ā','Ē','Ī','Ō','Ū',  'ā','ē','ī','ō','ū',
             'Ã','Å','Æ','Ç','Ð',  'ã','å','æ','ç','ð',
             'Ñ','Õ','Ø','Š','Ŵ',  'ñ','õ','ø','š','ŵ',
             'Ý','Ŷ','Ÿ','Ž','Þ',  'ý','ÿ','ŷ','ž','þ',
             'Ĳ','Œ','ĳ','œ','∀',  '«','»',' ']
  SPCHAR = [ '·','～','—','☆','★',  'ー','＝' ]
  #--------------------------------------------------------------------------
  # ¤ Переменные экземпляра
  #--------------------------------------------------------------------------
  attr_accessor :char_window
  attr_accessor :edit_window
  #--------------------------------------------------------------------------
  # ▲ Инициализация объекта
  #--------------------------------------------------------------------------
  def initialize(edit_window)
    @edit_window = edit_window
    super(edit_window.x - 60, edit_window.y + edit_window.height + 8)
    @index = 0
    refresh
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ▲ Получение ширины окна
  #--------------------------------------------------------------------------
  def window_width
    return 120
  end
  #--------------------------------------------------------------------------
  # ▲ Получение высоты окна
  #--------------------------------------------------------------------------
  def window_height
    return fitting_height(9)
  end
  #--------------------------------------------------------------------------
  # ¤ Создание списка команд
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(AephiexString::NMI_ABC123, :command_ok, true, LATIN1)
    add_command(AephiexString::NMI_GrRu, :command_ok, true, LATIN2) if AephiexConfig::GREEK_RUSSIAN
    add_command(AephiexString::NMI_LatinSp, :command_ok, true, LATIN3) if AephiexConfig::LATIN_SPECIAL
    add_command(AephiexString::NMI_SPCHAR, :command_ok, true, SPCHAR)
    add_command(AephiexString::NMI_Back, :backspace, true)
    add_command(AephiexString::NMI_Clear, :clear, true)
    add_command(AephiexString::NMI_Reset, :reset, true)
    add_command(AephiexString::NMI_OK, :name_ok, true)
  end
  #--------------------------------------------------------------------------
  # ▲ Получение количества видимых строк
  #--------------------------------------------------------------------------
  def visible_line_number
    return 9
  end
  #--------------------------------------------------------------------------
  # ▲ Отрисовка элемента
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color((@list[index][:ext] ? normal_color : system_color))
    draw_text(item_rect_for_text(index), command_name(index), 1)
  end
  #--------------------------------------------------------------------------
  # ▲ Обработка нажатий (подтверждение, отмена и т.д.)
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_back     if Input.trigger?(:A)
    return process_ok       if Input.trigger?(:C)
    return process_cancel   if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # ¤ Удалить один символ (backspace)
  #--------------------------------------------------------------------------
  def process_back
    if @edit_window.back
      Sound.play_cancel
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ▲ Обработка нажатия кнопки подтверждения
  #--------------------------------------------------------------------------
  def process_ok
    case current_symbol
    when :backspace
      process_back
    when :clear
      @edit_window.clear
      Sound.play_ok
    when :reset
      @edit_window.restore_default
      Sound.play_ok
    when :name_ok
      if @edit_window.name.empty?
        if @edit_window.restore_default
          Sound.play_ok
        else
          Sound.play_buzzer
        end
      else
        Sound.play_ok
        call_ok_handler
      end
    when :command_ok
      # Перед вызовом супер обновим список символов в окне
      if @char_window
        @char_window.char_list = current_ext
      end
      super
    end
  end
  #--------------------------------------------------------------------------
  # ▲ Обработка нажатия кнопки отмены
  #--------------------------------------------------------------------------
  def process_cancel
    # Пусто - просто возврат
  end
  #--------------------------------------------------------------------------
  # ▲ Установка индекса (добавляем обновление списка символов)
  #--------------------------------------------------------------------------
  alias set_index_original index=
  def index=(index)
    set_index_original(index)
    if @char_window
      @char_window.char_list = current_ext
    end
  end
end
 
 
#==============================================================================
# ■ Window_NameInput_Char
#------------------------------------------------------------------------------
# Окно для выбора и ввода символов.
#==============================================================================
class Window_NameInput_Char < Window_Command
  #--------------------------------------------------------------------------
  # ¤ Переменные экземпляра
  #--------------------------------------------------------------------------
  attr_accessor :command_window
  attr_accessor :edit_window
  attr_accessor :char_list
  #--------------------------------------------------------------------------
  # ▲ Инициализация объекта
  #--------------------------------------------------------------------------
  def initialize(command_window, edit_window)
    @command_window = command_window
    command_window.char_window = self
    @edit_window = edit_window
    super(edit_window.x + 60, edit_window.y + edit_window.height + 8)
    self.char_list = command_window.current_ext
    update_cursor
    deactivate
  end
  #--------------------------------------------------------------------------
  # ¤ Сеттер списка символов
  #--------------------------------------------------------------------------
  def char_list=(value)
    @char_list = value
    self.top_row = 0
    self.index = -1
    refresh
  end
  #--------------------------------------------------------------------------
  # ▲ Получение ширины окна
  #--------------------------------------------------------------------------
  def window_width
    return @edit_window.width
  end
  #--------------------------------------------------------------------------
  # ▲ Получение количества видимых строк
  #--------------------------------------------------------------------------
  def visible_line_number
    return 9
  end
  #--------------------------------------------------------------------------
  # ▲ Получение количества колонок
  #--------------------------------------------------------------------------
  def col_max
    return 10
  end
  #--------------------------------------------------------------------------
  # ▲ Получение выравнивания
  #--------------------------------------------------------------------------
  def alignment
    return 1
  end
  #--------------------------------------------------------------------------
  # ▲ Создание списка команд
  #--------------------------------------------------------------------------
  def make_command_list
    if @char_list && @char_list.size > 0
      @char_list.each {|c| add_command(c, :on_char_ok) }
    end
  end
  #--------------------------------------------------------------------------
  # ▲ Обработка нажатий (подтверждение, отмена и т.д.)
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_back     if Input.trigger?(:A)
    return process_ok       if Input.trigger?(:C)
    return process_cancel   if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # ¤ Удалить один символ (backspace)
  #--------------------------------------------------------------------------
  def process_back
    if @edit_window.back
      Sound.play_cancel
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ▲ Обработка нажатия кнопки подтверждения
  #--------------------------------------------------------------------------
  def process_ok
    if current_data
      if @edit_window.add(current_data[:name])
        Sound.play_ok
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲ Получение прямоугольника для отрисовки элемента
  #--------------------------------------------------------------------------
  def item_rect(index)
    if index >= 0
      rect = Rect.new
      rect.x = index % 10 * 32 + index % 10 / 5 * 16
      rect.y = index / 10 * line_height
      rect.width = 32
      rect.height = line_height
      return rect
    else
      return Rect.new(0, 0, 0, 0)
    end
  end
end