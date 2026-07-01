#==============================================================================
#  ■移動用画面 for RGSS3 Ver1.06-β-fix
#　□作成者 kure
#
#　呼び出し方法 　SceneManager.call(Scene_ShortMove)
#
#==============================================================================

module KURE
  module ShortMove
    #初期設定(変更しないこと)  
    MOVE_LIST = []
    EXPLAN = []
    PLAYER_ICON = []
    CALL_COMMON = []
    ICONLIST = []
  
    
    #移動先設定(以下の設定は項目が対応している為注意)---------------------------
    #MOVE_LIST[0]、EXPLAN[0]、PLAYER_ICON[0]、CALL_COMMON[0]は対応しています。
    
      #表示名、移動先設定
      #MOVE_LIST[0～] = [[表示名,表示するスイッチ,選択可スイッチ,消去スイッチ] ,[マップID, x座標, y座標, 向き(2468)]]
      MOVE_LIST[0] = [["Временной коридор",116,0,0],[108,22,17,2]]
      MOVE_LIST[1] = [["Временной коридор",166,0,0],[150,22,20,2]]
      MOVE_LIST[2] = [["Временной коридор",168,0,0],[152,16,32,2]]
      MOVE_LIST[3] = [["·Временной коридор",170,0,0],[108,22,17,2]]
      MOVE_LIST[4] = [["·Временной коридор",172,0,0],[108,22,17,2]]
      MOVE_LIST[5] = [["Разлом пространства",118,0,0],[178,9,10,8]]
      MOVE_LIST[6] = [["Район Фрейда",120,0,0],[179,13,11,8]]
      MOVE_LIST[7] = [["Мэрия Н. Изумруда",124,0,0],[228,19,30,8]]
      MOVE_LIST[8] = [["Порт Джольет",150,0,0],[356,9,10,8]]
      MOVE_LIST[9] = [["Завод Рутры",152,0,0],[228,19,28,8]]
      MOVE_LIST[10] = [["Особый район",110,0,0],[98,4,74,8]]
      MOVE_LIST[11] = [["Крепость Пиркс",112,0,0],[298,83,97,8]]
      MOVE_LIST[12] = [["Изумрудный двор",162,0,0],[311,35,55,4]]
      MOVE_LIST[13] = [["Тронный зал",164,0,0],[228,19,28,8]]
      MOVE_LIST[14] = [["Национальный парк",152,0,0],[228,19,28,8]]
      MOVE_LIST[15] = [["Маяк Монток",154,0,0],[228,19,28,8]]
      MOVE_LIST[16] = [["Опустевший берег",156,0,0],[228,19,28,8]]
      MOVE_LIST[17] = [["Храм Сердца",158,0,0],[228,19,28,8]]
      MOVE_LIST[18] = [["Цветочный двор",122,0,0],[112,21,65,8]]
      MOVE_LIST[19] = [["Сумеречный путь",102,0,0],[173,7,10,8]]
      MOVE_LIST[20] = [["Деревня Виндекер",104,0,0],[32,24,16,8]]
      MOVE_LIST[21] = [["Золотой миг",136,0,0],[315,29,11,8]]
      MOVE_LIST[22] = [["Извивающиеся поля",160,0,0],[228,19,28,8]]
      MOVE_LIST[23] = [["Лагерь рыцарей",138,0,0],[320,19,17,8]]
      MOVE_LIST[24] = [["Город Читенанго",106,0,0],[40,10,23,8]]
      MOVE_LIST[25] = [["Канализация",140,0,0],[203,5,10,8]]
      MOVE_LIST[26] = [["Узел канализации",144,0,0],[323,31,10,8]]
      MOVE_LIST[27] = [["Буреломный лес",142,0,0],[197,11,18,8]]
      MOVE_LIST[28] = [["Рухнувший дом",108,0,0],[59,29,35,8]]
      MOVE_LIST[29] = [["Озеро Мур",146,0,0],[273,17,13,8]]
      MOVE_LIST[30] = [["Приозёрный городок",126,0,0],[141,17,43,8]]
      MOVE_LIST[31] = [["Кроличьи холмы",128,0,0],[146,12,18,8]]
      MOVE_LIST[32] = [["Пещера Карбан",130,0,0],[232,60,40,8]]
      MOVE_LIST[33] = [["Забытая бухта",132,0,0],[252,10,49,8]]
      MOVE_LIST[34] = [["Сумеречный лес",134,0,0],[253,49,23,8]]
      MOVE_LIST[35] = [["Глубь леса",148,0,0],[255,51,24,8]]
      
      #説明文の設定
      #EXPLAN[0～] = [説明1行目,説明2行目]
      EXPLAN[0] = ["Пространство, сотканное из мыслей и надежд", "В безмолвном мире воспоминания прошлого направят заблудшую душу на её путь"]
      EXPLAN[1] = ["Пространство, сотканное из мыслей и надежд", "В безмолвном мире воспоминания прошлого направят заблудшую душу на её путь"]
      EXPLAN[2] = ["Пространство, сотканное из мыслей и надежд", "В безмолвном мире воспоминания прошлого направят заблудшую душу на её путь"]
      EXPLAN[3] = ["Пространство, сотканное из мыслей и надежд", "В безмолвном мире воспоминания прошлого направят заблудшую душу на её путь"]
      EXPLAN[4] = ["Пространство, сотканное из мыслей и надежд", "В безмолвном мире воспоминания прошлого направят заблудшую душу на её путь"]
      EXPLAN[5] = ["Обломок мира, порождённый колебаниями времени", "Даже слабый свет способен озарить весь мир"]
      EXPLAN[6] = ["Важнейший деловой район Нового Изумрудного города", "Деловой квартал неустанно перерабатывает грузы с моря, словно кровеносная артерия, питающая огромный Дождливый город"]
      EXPLAN[7] = ["Внезапно заброшенный старый административный центр", "Пустые, захламлённые залы уже заняты бродягами и шумом дождя и ветра"]
      EXPLAN[8] = ["Огромный порт с множеством складов и причалов", "Оккупированный морскими тварями порт ждёт возвращения гигантского корабля, который вновь принесёт свободу"]
      EXPLAN[9] = ["Автоматический завод Рутры", "XXX"]
      EXPLAN[10] = ["Особый район Нового Изумрудного города, парящий над облаками", "XXX"]
      EXPLAN[11] = ["Огромный комплекс крепостей с башнями", "XXX"]
      EXPLAN[12] = ["Символ верховной власти Изумрудного города", "XXX"]
      EXPLAN[13] = ["Тронный зал", "XXX"]
      EXPLAN[14] = ["Национальный парк", "XXX"]
      EXPLAN[15] = ["Маяк Монток", "XXX"]
      EXPLAN[16] = ["Опустевший берег", "XXX"]
      EXPLAN[17] = ["Храм Святого Сердца", "XXX"]
      EXPLAN[18] = ["Прекрасный сад в глубине Моря Цветов, пропитанный сладковатым запахом крови", "Под красивым и опасным Морем Цветов погребены бесчисленные искажённые прошлые"]
      EXPLAN[19] = ["Лесная тропа, соединяющая Новый Изумрудный город и Читенанго", "Между мёртвыми ветвями и листьями слышен лишь шёпот ветра"]
      EXPLAN[20] = ["Деревня, поглощённая внезапным туманом", "Помрачённым жителям и невдомёк, что это был предрешённый конец"]
      EXPLAN[21] = ["Золотой поезд, навечно остановившийся в час заката", "Даже самый низкий железный цвет может окраситься в золото"]
      EXPLAN[22] = ["Шевелящееся поле"]
      EXPLAN[23] = ["Лагерь рыцарей Леймана", "Быть поглощённым туманом или утонуть в кровавой резне"]
      EXPLAN[24] = ["Некогда процветавший восточный город-государство, павший в безумии, сошедшем с небес", "Слепо приносите себя в жертву несуществующему божеству, и оно ответит вам"]
      EXPLAN[25] = ["Кровавые и жуткие подземные каналы Читенанго", "Важная часть системы циркуляции Читенанго, ставшая рассадником скверны и искажённых тварей"]
      EXPLAN[26] = ["Забытый древний центр техобслуживания подземных каналов", "Даже забытые, эти древние механизмы молча ждут дня своего запуска во тьме"]
      EXPLAN[27] = ["Лес, некогда уничтоженный гигантским ураганом", "На восточной оконечности — бесконечная буря"]
      EXPLAN[28] = ["Дом, упавший из заслонившего небо гигантского вихря", "Заброшенное жилище наводит на размышления... Пробудит ли странное чувство знакомства былые воспоминания?"]
      EXPLAN[29] = ["Огромное бездонное озеро, по легендам, связанное подземными водами с океаном за пределами континента", "Зловещая зелёная гниль, словно голодный монстр, пожирает всё в озере"]
      EXPLAN[30] = ["Городок у озера Мур, окутанный дождём", "XXX"]
      EXPLAN[31] = ["Холмы, по легендам, полные кроликов и сокровищ", "XXX"]
      EXPLAN[32] = ["Древняя пещера, хранящая тёмные тайны бездны", "XXX"]
      EXPLAN[33] = ["Забытая миром тихая бухта", "XXX"]
      EXPLAN[34] = ["Багровый лес, где некогда жила ведьма сумерек", "XXX"]
      EXPLAN[35] = ["В самой глубине Сумеречного леса скрывалась ведьма, славящаяся своей мудростью", "XXX"]

      #プレーヤーのアイコン(選択肢対応アイコン)
      #PLAYER_ICON[0～] = [アイコンタイプ,アイコンX,アイコンY]
      #アイコンタイプ
      # 0 → 隊列先頭のキャラクター 
      # PLAYER_ICON[0] = [0, x, y]
      #
      # 1 → 四角形
      # PLAYER_ICON[0] = [1, x, y, [size,red,green,blue]]
      #
      # 2 → 画像ファイル(Pictureフォルダに入れること)
      # PLAYER_ICON[0] = [2, x, y, filename]
      #
      
      PLAYER_ICON[0]= [0,436,56]
      PLAYER_ICON[1]= [0,435,56]
      PLAYER_ICON[2]= [0,435,56]
      PLAYER_ICON[3]= [0,435,56]
      PLAYER_ICON[4]= [0,435,56]
      PLAYER_ICON[5]= [0,280,200]
      PLAYER_ICON[6]= [0,200,200]
      PLAYER_ICON[7]= [0,230,190]
      PLAYER_ICON[8]= [0,200,220]
      PLAYER_ICON[9]= [0,264,187]
      PLAYER_ICON[10]= [0,105,90]
      PLAYER_ICON[11]= [0,10,10]
      PLAYER_ICON[12]= [0,10,10]
      PLAYER_ICON[13]= [0,236,143]
      PLAYER_ICON[14]= [0,266,155]
      PLAYER_ICON[15]= [0,264,139]
      PLAYER_ICON[16]= [0,281,158]
      PLAYER_ICON[17]= [0,309,148]
      PLAYER_ICON[18]= [0,312,198]
      PLAYER_ICON[19]= [0,330,210]
      PLAYER_ICON[20]= [0,330,173]
      PLAYER_ICON[21]= [0,320,146]
      PLAYER_ICON[22]= [0,338,140]
      PLAYER_ICON[23]= [0,384,195]
      PLAYER_ICON[24]= [0,406,150]
      PLAYER_ICON[25]= [0,410,172]
      PLAYER_ICON[26]= [0,408,170]
      PLAYER_ICON[27]= [0,408,121]
      PLAYER_ICON[28]= [0,426,89]
      PLAYER_ICON[29]= [0,367,277]
      PLAYER_ICON[30]= [0,373,239]
      PLAYER_ICON[31]= [0,394,256]
      PLAYER_ICON[32]= [0,404,275]
      PLAYER_ICON[33]= [0,420,280]
      PLAYER_ICON[34]= [0,378,280]
      PLAYER_ICON[35]= [0,367,277]

      #移動と同時に呼び出すコモンイベントのID
      #CALL_COMMON[0～] = [ID配列]
      CALL_COMMON[0] = [3]
      CALL_COMMON[1] = [3]
      CALL_COMMON[2] = [3]
      CALL_COMMON[3] = [3]
      CALL_COMMON[4] = [3]
      CALL_COMMON[5] = [3]
      CALL_COMMON[6] = [3]
      CALL_COMMON[7] = [3]
      CALL_COMMON[8] = [3]
      CALL_COMMON[9] = [3]
      CALL_COMMON[10] = [3]
      CALL_COMMON[11] = [3]
      CALL_COMMON[12] = [3]
      CALL_COMMON[13] = [3]
      CALL_COMMON[14] = [3]
      CALL_COMMON[15] = [3]
      CALL_COMMON[16] = [3]
      CALL_COMMON[17] = [3]
      CALL_COMMON[18] = [3]
      CALL_COMMON[19] = [3]
      CALL_COMMON[20] = [3]
      CALL_COMMON[21] = [3]
      CALL_COMMON[22] = [3]
      CALL_COMMON[23] = [3]
      CALL_COMMON[24] = [3]
      CALL_COMMON[25] = [3]
      CALL_COMMON[26] = [3]
      CALL_COMMON[27] = [3]
      CALL_COMMON[28] = [3]
      CALL_COMMON[29] = [3]
      CALL_COMMON[30] = [3]
      CALL_COMMON[31] = [3]
      CALL_COMMON[32] = [3]
      CALL_COMMON[33] = [3]
      CALL_COMMON[34] = [3]
      CALL_COMMON[35] = [3]
    #マップ上に表示するアイコンの設定-------------------------------------------
      #ICONLIST[0～] = [アイコンタイプ,アイコンX,アイコンY,表示スイッチ,消去スイッチ,各種設定]
      #必要な数に応じて項目を追加してください
      #アイコンタイプによる設定の違い
      # 0 → アクターを描画します
      # ICONLIST[0] = [0, x, y, switch_id, switch_id, actor_id]
      #　
      # 1 → 四角形
      # ICONLIST[1] = [1, x, y, switch_id, switch_id, [size,red,green,blue]]
      #
      # 2 → 画像ファイル(Pictureフォルダに入れること)
      # ICONLIST[1] = [2, x, y, switch_id, switch_id, filename]
      #
      

    
    #MAPDATA
    #png形式の画像データを「Picture」フォルダに入れること(380×296)
    MAPDATA = "map"
 
  end
end

#==============================================================================
# ■ Scene_ShortMove
#------------------------------------------------------------------------------
# 　キャラクターメイキングの処理を行うクラスです。
#==============================================================================
class Scene_ShortMove < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_command_window
    create_map_window
    create_icon_window
    create_info_window
    create_popup_window
    
    set_window_task
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  def create_command_window
    #キャラクター選択ウィンドウを作成
    @command_window = Window_k_ShortMove_Command.new(0, 0)
    @command_window.height = Graphics.height
    @command_window.activate
    #呼び出しのハンドラをセット
    @command_window.set_handler(:ok,method(:select_command))
    @command_window.set_handler(:cancel,method(:on_cancel))
  end
  #--------------------------------------------------------------------------
  # ● アイコンウィンドウの作成
  #--------------------------------------------------------------------------
  def create_icon_window    
    x = @command_window.width
    y = 0
    ww = Graphics.width - x
    wh = Graphics.height - 24 * 4
    @icon_window = Window_k_ShortMove_Icon.new(x,y,ww,wh)
    @icon_window.z += 10
    @icon_window.opacity = 0
    @icon_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● マップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_map_window    
    x = @command_window.width
    y = 0
    ww = Graphics.width - x
    wh = Graphics.height - 24 * 4
    @map_window = Window_k_ShortMove_Map.new(x,y,ww,wh)
    @map_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● インフォメーションウィンドウの作成
  #--------------------------------------------------------------------------
  def create_info_window
    x = @command_window.width
    y = @map_window.height
    ww = Graphics.width - x
    wh = Graphics.height - y
    @info_window = Window_k_ShortMove_Info.new(x,y,ww,wh)
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウの作成
  #--------------------------------------------------------------------------
  def create_popup_window
    wx = (Graphics.width - 180)/2
    wy = (Graphics.height - 180)/2
    @popup_window = Window_k_ShortMove_Pop.new(wx, wy)
    @popup_window.unselect
    @popup_window.deactivate
    @popup_window.z  += 10
    @popup_window.hide 
    #ハンドラのセット
    @popup_window.set_handler(:cancel,   method(:pop_cancel))
    @popup_window.set_handler(:ok,   method(:pop_ok)) 
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウのセッティング処理
  #--------------------------------------------------------------------------
  def set_window_task
    @command_window.info_window = @info_window
    @command_window.map_window = @map_window
    @command_window.icon_window = @icon_window
    @command_window.select(0)
    
    @info_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウ[決定]
  #--------------------------------------------------------------------------
  def select_command
    pop_open
  end
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def on_cancel
    Cache.clear
    SceneManager.return
  end 
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[決定]
  #--------------------------------------------------------------------------
  def pop_ok
    case @popup_window.current_ext
    when 1
      #画像キャッシュをクリアしておく
      Cache.clear
      
      move_point = @command_window.current_ext
      map_id = move_point[0][1][0]
      x = move_point[0][1][1]
      y = move_point[0][1][2]
      dir = move_point[0][1][3]
      
      fadeout_all(300)
      $game_player.reserve_transfer(map_id, x, y, dir)
      $game_player.perform_transfer
      SceneManager.call(Scene_Map)
      $game_temp.recall_map_name = 1
      $game_map.autoplay
      
      call_common(move_point[1])
    when 2
      pop_close
    end
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[キャンセル]
  #--------------------------------------------------------------------------
  def pop_cancel
    pop_close
  end
  #--------------------------------------------------------------------------
  # ● コモンイベント呼び出し[キャンセル]
  #--------------------------------------------------------------------------
  def call_common(list)
    event = KURE::ShortMove::CALL_COMMON[list]
    event.each do |id|
      $game_temp.reserve_common_event(id)
    end
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[開く]
  #--------------------------------------------------------------------------
  def pop_open
    @popup_window.show
    @popup_window.select(1)
    @popup_window.activate
    @command_window.deactivate
  end
  #--------------------------------------------------------------------------
  # ● ポップアップウィンドウ[閉じる]
  #--------------------------------------------------------------------------
  def pop_close
    @popup_window.hide
    @popup_window.unselect
    @popup_window.deactivate
    @command_window.activate
  end
end


#==============================================================================
# ■ Window_k_ShortMove_Command
#==============================================================================
class Window_k_ShortMove_Command < Window_Command
  attr_accessor :info_window
  attr_accessor :map_window
  attr_accessor :icon_window
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 140
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置の設定
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    update_cursor
    call_update_help
    
    @info_window.select = current_ext if @info_window
    @map_window.select = current_ext if @map_window
    @icon_window.select = current_ext if @icon_window
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    master = KURE::ShortMove::MOVE_LIST
    for i in 0..master.size - 1
      if visible?(master[i])
        add_command(master[i][0][0], :ok, selectable?(master[i]), [master[i],i])
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 表示の可否
  #--------------------------------------------------------------------------
  def visible?(list)
    return false if list[0][3] != 0 && $game_switches[list[0][3]]
    if list[0][3] == 0
      return true if list[0][1] == 0
      return true if $game_switches[list[0][1]] 
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ● 選択の可否
  #--------------------------------------------------------------------------
  def selectable?(list)
    return true if list[0][2] == 0
    return true if $game_switches[list[0][2]]
    return false
  end
end

#==============================================================================
# ■ Window_k_ShortMove_Map
#==============================================================================
class Window_k_ShortMove_Map < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @select = nil
  end
  #--------------------------------------------------------------------------
  # ● 選択中のMAPデータを更新
  #--------------------------------------------------------------------------
  def select=(select)
    return if @select == select
    @select = select
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    
    bitmap = Cache.picture(KURE::ShortMove::MAPDATA)
    #描画
    self.contents.blt(0, 0, bitmap, bitmap.rect)
  end
end

#==============================================================================
# ■ Window_k_ShortMove_Icon
#==============================================================================
class Window_k_ShortMove_Icon < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @select = nil
  end
  #--------------------------------------------------------------------------
  # ● 選択中のMAPデータを更新
  #--------------------------------------------------------------------------
  def select=(select)
    return if @select == select[1]
    @select = select[1]
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    return unless @select
    
    draw_list = KURE::ShortMove::ICONLIST
    
    draw_list.each do |list|
      next if list == [] 
      #描画判定
      if list[3] != 0
        next unless $game_switches[list[3]]
      end
      
      if list[4] != 0
        next if $game_switches[list[4]]
      end
      
      #アイコンタイプ
      case list[0]
      #アクター描画
      when 0
        actor = $game_actors[list[5]]
        next unless actor
    
        x = list[1]
        y = list[2]
        draw_character(actor.character_name, actor.character_index , x, y)
      #四角形描画  
      when 1
        size = 7 ; size2 = 3
        red = 0 ; green = 0 ; blue = 0
        if list[5] 
          if list[5][0]
            size = list[5][0]
            size2 = (list[5][0] / 2).truncate
          end
          if list[5][1] && list[5][2] && list[5][3]
            red = list[5][1]
            green = list[5][2]
            blue = list[5][3]
          end
        end
        
        rect = Rect.new(list[1] - size2,list[2] - size2,size,size)
        color = Color.new(red, green, blue) 
        contents.fill_rect(rect, color)
      #画像描画
      when 2
        next unless list[5]
        bitmap = Cache.picture(list[5])
        self.contents.blt(list[1], list[2], bitmap, bitmap.rect) 
      end
      
    end
    
    player = KURE::ShortMove::PLAYER_ICON[@select]
    case player[0]
    #アクター描画
    when 0
      actor = $game_party.battle_members[0]
      return unless actor
    
      x = player[1]
      y = player[2]
      draw_character(actor.character_name, actor.character_index , x, y)
    #四角形
    when 1
        size = 7 ; size2 = 3
        red = 0 ; green = 0 ; blue = 0
        if player[3] 
          if player[3][0]
            size = player[3][0]
            size2 = (player[3][0] / 2).truncate
          end
          if player[3][1] && player[3][2] && player[3][3]
            red = player[3][1]
            green = player[3][2]
            blue = player[3][3]
          end
        end
        
        rect = Rect.new(player[1] - size2,player[2] - size2,size,size)
        color = Color.new(red, green, blue) 
        contents.fill_rect(rect, color)
    #画像描画
    when 2
      return unless player[3]
      bitmap = Cache.picture(player[3])
      self.contents.blt(player[1], player[2], bitmap, bitmap.rect) 
      
    end
    
  end
end

#==============================================================================
# ■ Window_k_ShortMove_Info
#==============================================================================
class Window_k_ShortMove_Info < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #-------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    @select = nil
  end
  #--------------------------------------------------------------------------
  # ● 選択中のMAPデータを更新
  #--------------------------------------------------------------------------
  def select=(select)
    return if @select == select[1]
    @select = select[1]
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    return unless @select
    contents.clear
    
    title = KURE::ShortMove::MOVE_LIST[@select][0][0]
    explan = KURE::ShortMove::EXPLAN[@select]
    
    draw_text(0, 0, contents_width, line_height, title)
    
    return unless explan
      draw_text(0, line_height * 1, contents_width, line_height, explan[0]) if explan[0]
      draw_text(0, line_height * 2, contents_width, line_height, explan[1]) if explan[1]
    end
end


#==============================================================================
# ■ Window_k_ShortMove_Pop
#==============================================================================
class Window_k_ShortMove_Pop < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    return 180
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ高さの取得
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command("Переместиться", :ok, true, 1)
    add_command("Отмена", :ok, true, 2)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    clear_command_list
    make_command_list
    create_contents
    self.height = window_height
    select(0)
    super
  end
end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :recall_map_name             # 場所移動時のフェードタイプ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_shotmove_initialize initialize
  def initialize
    k_before_shotmove_initialize
    @recall_map_name = 0
  end
end

#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理(エイリアス再定義)
  #--------------------------------------------------------------------------
  alias k_before_shotmove_start start
  def start
    k_before_shotmove_start
    recall_map_name_window
  end
  #--------------------------------------------------------------------------
  # ● マップ名表示処理(追加定義)
  #--------------------------------------------------------------------------
  def recall_map_name_window
    if $game_temp.recall_map_name == 1
      @map_name_window.open
      $game_temp.recall_map_name = 0
    end
  end
end