#==============================================================================
# ◆ 汉字输入 by Aephiex
#------------------------------------------------------------------------------
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#------------------------------------------------------------------------------
#
#  主要机能
#  ◎ 给角色命名时可以输入汉字。
#     先选择汉字的读音，再列出符合该读音的汉字，供用户选择。
#     收录约6500个汉字，包括日常汉字和某些教学用汉字，满足大部分起名需求。
#     选择汉字读音期间可通过 pageup 和 pagedown 快速翻页跳转到想要的读音。
#     输入汉字期间，按 shift 可以退格。
#  ◎ 增加在事件可调用的脚本指令 input_text(max_char = 8, default = "")
#     要求玩家输入长度8的文本，默认为空。
#     该指令会将玩家输入的文本作为返回值返回。
#     可以用一个 $game_variables[...] 接收它，从而可以在事件文本中用 \V[...] 调用。
#
#  特别注意
#  ◎ 请务必确保随赠的 "Kanji_CHS.dat" 已放在 Data 目录中。
#
#==============================================================================
 
module AephiexConfig
 
  # 是否允许输入希腊字母和俄语字母
  # 注意在有些字体下这些字母会显示为□
  GREEK_RUSSIAN   = true
 
  # 是否允许输入特殊字母（Á之类的戴帽子的英文字母等）
  # 注意在有些字体下这些字母会显示为□
  LATIN_SPECIAL   = true
 
end
 
module AephiexString
 
  # 汉字输入画面的指令名
  NMI_ABC123           = "英／数"
  NMI_GrRu             = "希／俄"
  NMI_LatinSp          = "特殊字母"
  NMI_SPCHAR           = "特殊字符"
  NMI_Kanji            = "汉字[拼音]"
  NMI_Kanji2           = "汉字[快捷]"
  NMI_OK               = "完成"
  NMI_Back             = "退格"
  NMI_Clear            = "清空"
  NMI_Reset            = "重置"
 
end
 
#==============================================================================
# □ Game_Interpreter
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ¤ スクリプト：テキスト入力
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
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    @actor = @actor_id.is_a?(String) ? @actor_id : $game_actors[@actor_id]
    @edit_window = Window_NameEdit.new(@actor, @max_char)
    @command_window = Window_NameInput_Command.new(@edit_window, @@kanji_data ||= load_data("Data/Kanji_CHS.dat"))
    @command_window.set_handler(:command_ok, method(:char_selection))
    @command_window.set_handler(:ok, method(:on_input_ok))
    @char_window = Window_NameInput_Char.new(@command_window, @edit_window)
    @char_window.set_handler(:cancel, method(:command_selection))
    command_selection
  end
  #--------------------------------------------------------------------------
  # ● 入力［決定］
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
  # ¤ コマンド選択開始
  #--------------------------------------------------------------------------
  def command_selection
    @char_window.select(-1)
    @char_window.deactivate
    @command_window.activate
  end
  #--------------------------------------------------------------------------
  # ¤ 文字選択開始
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
  # ● オブジェクト初期化
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
  # ● 名前を描画する左端の座標を取得
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
  # ● 文字の幅を取得
  #--------------------------------------------------------------------------
  def char_width
    return @char_width ||= text_size("あ").width
  end
  #--------------------------------------------------------------------------
  # ○ クリア
  #--------------------------------------------------------------------------
  def clear
    @name = ""
    @index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_actor_face(@actor, 0, 0) if @actor
    @max_char.times {|i| draw_underline(i) }
    @name.size.times {|i| draw_char(i) }
    cursor_rect.set(item_rect(@index))
  end
  #--------------------------------------------------------------------------
  # ● 文字を描画
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
# 文字ページを入れ替えるコマンドウィンドウ。
#==============================================================================
class Window_NameInput_Command < Window_Command
  #--------------------------------------------------------------------------
  # ¤ クラス定数
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
  CHINA  = []
  CHINA1 = [ '格','诺','渡','比','尔',  '希','夏','帽','子','哈',
             '梅','星','王','贞','德',  '人','鱼','林','大','阳',
             '卡','雷','塞','特','亚',  '双','露','玛','公','主',
             '雏','鸟','兹','莱','妮',  '沙','易','芙','兰','华',
             '米','瓦','发','火','普',  '仙','度','瑞','光','羊',
             '飞','登','丽','塔','赫',  '罗','伊','娜','三','月',
             '艾','海','龟','白','兔',  '之','里','菲','南','瓜',
             '班','达','斯','奈','奇',  '睡','鼠','山','加','布',
             '维','多','汉','路','雅',  '眠','刘','威','耶','路',
             '贾','巴','沃','克','苏',  '鲁','亚','爱','铠','甲',
             '谢','冬','钟','罪','舞',  '真','龙','我','装','置',
             '莉','拉','拜','伦','丝',  '芙','小','鸭','古','熊',
             '辛','楠','骑','不','死',  '士','者','灰','心','利',
             '因','葛','圣','猎','李',  '恶','魔','黑','暗','剑',
             '犹','张','的','贝','青',  '武','萨','缇','神','琪',
             '鸡','肉','君','奥','丑',  '梦','风','只','死','狼',
             '多','工','茜','明','蛙',  '师','契','托','北','方',
             '中','红','温','长','女',  '坦','战','安','尤','老',
             '台','凯','狮','伯','阿',  '法','假','荷','丁','留']
  #--------------------------------------------------------------------------
  # ¤ インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :char_window
  attr_accessor :edit_window
  attr_accessor :kanji_mode
  #--------------------------------------------------------------------------
  # ▲ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(edit_window, kanji_data)
    @kanji_data = kanji_data
    @edit_window = edit_window
    super(edit_window.x - 60, edit_window.y + edit_window.height + 8)
    @index = 0
    refresh
    update_cursor
  end
  #--------------------------------------------------------------------------
  # △ インデックスセッター
  #--------------------------------------------------------------------------
  alias index_setter＠Window_NameInput_Command index=
  def index=(value)
    last_index = @index
    index_setter＠Window_NameInput_Command(value)
    if @char_window && @index != last_index
      @char_window.char_list = current_ext
    end
  end
  #--------------------------------------------------------------------------
  # ▲ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 120
  end
  #--------------------------------------------------------------------------
  # ▲ ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    return fitting_height(9)
  end
  #--------------------------------------------------------------------------
  # ¤ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    if !@kanji_mode
      add_command(AephiexString::NMI_Kanji2, :command_ok, true, CHINA1)
      add_command(AephiexString::NMI_Kanji, :kanji_mode, true, CHINA)
      add_command(AephiexString::NMI_ABC123, :command_ok, true, LATIN1)
      add_command(AephiexString::NMI_GrRu, :command_ok, true, LATIN2) if AephiexConfig::GREEK_RUSSIAN
      add_command(AephiexString::NMI_LatinSp, :command_ok, true, LATIN3) if AephiexConfig::LATIN_SPECIAL
      add_command(AephiexString::NMI_SPCHAR, :command_ok, true, SPCHAR)
      add_command(AephiexString::NMI_Back, :backspace, true)
      add_command(AephiexString::NMI_Clear, :clear, true)
      add_command(AephiexString::NMI_Reset, :reset, true)
      add_command(AephiexString::NMI_OK, :name_ok, true)
    else
      @kanji_data.keys.each do |key|
        add_command(key.to_s, :command_ok, true, @kanji_data[key])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 9
  end
  #--------------------------------------------------------------------------
  # ▲ 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    change_color((@list[index][:ext] ? normal_color : system_color))
    draw_text(item_rect_for_text(index), command_name(index), 1)
  end
  #--------------------------------------------------------------------------
  # ▲ 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_back     if Input.trigger?(:A)
    return process_ok       if Input.trigger?(:C)
    return process_cancel   if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # ¤ 一つ戻す
  #--------------------------------------------------------------------------
  def process_back
    if @edit_window.back
      Sound.play_cancel
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    case current_symbol
    when :kanji_mode
      Sound.play_ok
      @kanji_mode = true
      refresh
      self.top_row = 0
      self.index = 0
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
      super
    end
  end
  #--------------------------------------------------------------------------
  # ▲ キャンセルボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_cancel
    if @kanji_mode
      Sound.play_cancel
      @kanji_mode = nil
      refresh
      self.top_row = 0
      self.select_symbol(:kanji_mode)
    end
  end
end
 
 
#==============================================================================
# ■ Window_NameInput_Char
#------------------------------------------------------------------------------
# 文字を選択し入力するウィンドウ。
#==============================================================================
class Window_NameInput_Char < Window_Command
  #--------------------------------------------------------------------------
  # ¤ インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :command_window
  attr_accessor :edit_window
  attr_accessor :char_list
  #--------------------------------------------------------------------------
  # ▲ オブジェクト初期化
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
  # ¤ チャーリストセッター
  #--------------------------------------------------------------------------
  def char_list=(value)
    @char_list = value
    self.top_row = 0
    self.index = -1
    refresh
  end
  #--------------------------------------------------------------------------
  # ▲ ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return @edit_window.width
  end
  #--------------------------------------------------------------------------
  # ▲ 表示行数の取得
  #--------------------------------------------------------------------------
  def visible_line_number
    return 9
  end
  #--------------------------------------------------------------------------
  # ▲ 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 10
  end
  #--------------------------------------------------------------------------
  # ▲ アライメントの取得
  #--------------------------------------------------------------------------
  def alignment
    return 1
  end
  #--------------------------------------------------------------------------
  # ▲ コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    if @char_list && @char_list.size > 0
      @char_list.each {|c| add_command(c, :on_char_ok) }
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_back     if Input.trigger?(:A)
    return process_ok       if Input.trigger?(:C)
    return process_cancel   if Input.trigger?(:B)
  end
  #--------------------------------------------------------------------------
  # ¤ 一つ戻す
  #--------------------------------------------------------------------------
  def process_back
    if @edit_window.back
      Sound.play_cancel
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ▲ 決定ボタンが押されたときの処理
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
  # ▲ 項目を描画する矩形の取得
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