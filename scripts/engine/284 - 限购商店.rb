#==============================================================================
# 〓 限购商店 〓  <VA>       Author :芯☆淡茹水
#==============================================================================
=begin
  #--------------------------------------------------------------------------
  〓 说明 〓
  #--------------------------------------------------------------------------
  1，该限购商店是以 第一个 出售的物品为标志。
     当 第一个 出售的物品确定为限购商店的标志时，这个物品不会出现在出售列表中。
     标志物品的设置见下文。
  #--------------------------------------------------------------------------
  2，支持存取档的继承以及游戏中的数量补充。支持剩余数量的获取。
  
  #--------------------------------------------------------------------------
  3，商品 第一个 不是 限购商店标志物品 的，为默认商店。
  
  #--------------------------------------------------------------------------
  4，限购商店标志物品可依照下面格式随意设置，
     限购商店的各种脚本操作就以这个标志的ID（物品ID）为基准。
  
  #--------------------------------------------------------------------------
  〓 限购商店标志物品的设置 〓
  #--------------------------------------------------------------------------
  1，限购商店的标志物品（以下简称为“商标”）类型为：数据库 - 物品 。
  #--------------------------------------------------------------------------
  2，限购商店的标志和对应初始限购数量，
     在 商标 的 说明 里写：<RealShopData:n1,n2,n3,,,>
     
     n1,n2,n3,,, ，表示该商店出售的道具的初始限购数量。以出售时的序号排列，
     除 商标 外，第一个出售的道具数量对应 n1 ；第二个对应 n2 ... 以此类推。
     中间用半角逗号 , 相隔，不留空。
     
     也可以缺省设置：比如共 4 件出售道具，只设置前 2 件限购 => <RealShopData:n1,n2>
     也可以只设置 1 和 3 限购 => <RealShopData:n1,,n3>
     注意中间缺省几个的，就补几个半角逗号 ,  。
     
     例1：<RealShopData:20,99,10,35> 
          #=> 前 4 件道具的初始限购数量分别为：20,99,10,35 ；后面的不限购。
          
     例2：<RealShopData:55,,,30,15>
          #=> 前 5 件道具的初始限购数量分别为：55,不限,不限,30,15 ；后面的不限购。
     
  #--------------------------------------------------------------------------
  〓 脚本命令 〓
  #--------------------------------------------------------------------------
  1，事件 - 脚本 ： setup_sell_nums(id)  
     #=> 以 商标 的ID为基准，还原一个限购商店的数量为初始状态。
     
     id :商标（数据库-物品）的 ID。
     
     例：还原以 3 号 商标 为标志的限购商店的初始数量
         #=> setup_sell_nums(3)
  #--------------------------------------------------------------------------
  2，事件 - 脚本 ： shop_stock(id, index, num, type) 
     #=> 以 商标 的ID为基准，给限购商店的某个出售道具“进货”。
     
     id    :商标（数据库-物品）的 ID。
     index :需要加货的道具的排列序号。（除 商标 外，第一个道具为 1）
     num   :加货的数量（可以为 负数）。
     type  :加货的方式（可缺省）。
            方式1: 累加。 缺省时默认该方式。
            方式2：指定。 type 参数写 "Set" ，即为该方式。
            
            累加 与 指定 的区别：
            例: 剩余 10 ，累加 20  => 共 30
                剩余 10 ，指定 20  => 共 20
            
     注意: 若初始某道具无购买数量的限制，使用这条命令给其加数量后，
           该道具会变成有数量限制的道具。使用第 1 条脚本命令可恢复。
              
           
     例1: 给 5 号 商标 的限制商店第 4 个道具“进货” 50 
          #=> shop_stock(5, 4, 50)
     
     例2: 指定 8 号 商标 的限制商店第 2 个道具的数量为 20 
          #=> shop_stock(8, 2, 20, "Set")
  #--------------------------------------------------------------------------
  〓 数量的获取与判断 〓
  #--------------------------------------------------------------------------
  事件 - 脚本：rs_limit_num(id, index)
  #=> 获取以 商标 的ID为基准的限购商店的某个道具的剩余数量。
  
  id    :商标（数据库-物品）的 ID。
  index :道具在商店的排列序号。
  
  例1：条件判断 7 号 商标 的限购商店的 3 号道具剩余数量是否大于 10
       #=>  事件 - 条件 - 脚本： rs_limit_num(7, 3) > 10
       
  例2：将 1 号 商标 的限购商店的 12 号道具剩余数量代入变量
       #=>  事件 - 变量代入 - 脚本： rs_limit_num(1, 12)
       
  注意:由于需要条件判断，无 数量限制 的道具获取这个值时为 1000000 。
  #--------------------------------------------------------------------------
=end
#==============================================================================
module XdRs_Rs
  #--------------------------------------------------------------------------
# 〓 设置 〓
  #--------------------------------------------------------------------------
  # 数量提示窗口字体大小。
  Hint_Size = 18
  
  #--------------------------------------------------------------------------
  # 数量提示窗口在商店界面的 X 坐标。
  Hint_X = 260
  
  #--------------------------------------------------------------------------
  # 数量提示窗口在商店界面的 Y 坐标。
  Hint_Y = 75
  
  #--------------------------------------------------------------------------
  # 数量提示窗口背景的透明度（0 - 255）。
  Hint_Opacity = 255
  
  #--------------------------------------------------------------------------
  # 商店物品剩余数量的用语。
  Num_Word = "Ост:"
  
  #--------------------------------------------------------------------------
  # 商店物品没有剩余数量限制时，是否显示数量提示窗口？（是：true ；否：false） 。
  Show_Infinite = true
  
  #--------------------------------------------------------------------------
  # 非限购商店，是否显示数量提示窗口？（是：true ；否：false） 。
  Show_Nt_Limit = false
  
  #--------------------------------------------------------------------------
  # 商店物品没有剩余数量限制时，数量提示窗口显示的数量用语。
  Infinite_Word = "∞"
  
end
#==============================================================================
class Game_System
  #--------------------------------------------------------------------------
  attr_accessor :real_shop_data
  #--------------------------------------------------------------------------
  alias xr_rs_initialize initialize
  def initialize
    xr_rs_initialize
    @real_shop_data = 0
    @surplus_num_data = [nil]
  end
  #--------------------------------------------------------------------------
  def shop_surplus_nums(id=nil)
    id ||= @real_shop_data
    return id == 0 ? nil : remaining_amount(id)
  end
  #--------------------------------------------------------------------------
  def remaining_amount(id)
    save = @surplus_num_data[id]
    base = base_sell_nums(id)
    return base if save.nil?
    data = []
    size = [save.size, base.size].max
    size.times{|i| data.push(save[i] || base[i])}
    return data
  end
  #--------------------------------------------------------------------------
  def base_sell_nums(id)
    $data_items[id].description.match(/<RealShopData:(\S*)>/)
    return $1.split(",").map{|n| n == "" ? nil : n.to_i}
  end
  #--------------------------------------------------------------------------
  def record_rest_nums(data)
    @surplus_num_data[@real_shop_data] = data
  end
  #--------------------------------------------------------------------------
  def shop_stock(id, index, num, type)
    return if num == 0 && type == "Add"
    @surplus_num_data[id] ||= []
    if type == "Set"
      @surplus_num_data[id][index] = num
    else
      @surplus_num_data[id][index] ||= base_sell_nums(id)[index]
      @surplus_num_data[id][index] += num
    end
    @surplus_num_data[id][index] = [@surplus_num_data[id][index], 0].max
  end
  #--------------------------------------------------------------------------
  def setup_sell_nums(id)
    @surplus_num_data[id] = nil if @surplus_num_data[id]
    @surplus_num_data.all?{|d| !d} && @surplus_num_data.clear
  end
end
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  def steup_real_shop
    return if @params[0] != 0 || 
    !$data_items[@params[1]].description.match(/<RealShopData:(\S*)>/)
    $game_system.real_shop_data = @params[1]
  end
  #--------------------------------------------------------------------------
  alias xr_rs_command_302 command_302
  def command_302
    !$game_party.in_battle && steup_real_shop
    xr_rs_command_302
  end
  #--------------------------------------------------------------------------
  def shop_stock(id, index, num, type="Add")
    $game_system.shop_stock(id, index-1, num, type)
  end
  #--------------------------------------------------------------------------
  def setup_sell_nums(id)
    $game_system.setup_sell_nums(id)
  end
  #--------------------------------------------------------------------------
  def rs_limit_num(id, index)
    data = $game_system.shop_surplus_nums(id)
    return (!data || !data[index-1]) ? 1e6 : data[index-1]
  end
end
#==============================================================================
class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  def dispose
    @num_hint && @num_hint.dispose
    super
  end
  #--------------------------------------------------------------------------
  def setup_nums_data(data)
    @nums_data = data
    need_hint_window? && create_num_hint
  end
  #--------------------------------------------------------------------------
  def need_hint_window?
    return @nums_data || XdRs_Rs::Show_Nt_Limit
  end
  #--------------------------------------------------------------------------
  def rect_count
    bitmap = Bitmap.new(32,32)
    size = XdRs_Rs::Hint_Size
    bitmap.font.size = size
    w = bitmap.text_size(XdRs_Rs::Num_Word).width + 32 + size * 2
    h = size + 24
    bitmap.dispose
    return w, h
  end
  #--------------------------------------------------------------------------
  def create_num_hint
    w, h = rect_count
    @num_hint = Window_Base.new(XdRs_Rs::Hint_X,XdRs_Rs::Hint_Y,w,h)
    @num_hint.hide
    @num_hint.opacity = XdRs_Rs::Hint_Opacity
    @num_hint.z = 999
    draw_limit_num
  end
  #--------------------------------------------------------------------------
  def draw_limit_num
    @num_hint.contents.clear
    @old_num = limit_num(@index)
    size = XdRs_Rs::Hint_Size; x = 0
    @num_hint.contents.font.size = size
    @num_hint.contents.font.bold = true
    text = limit_num(@index) ? limit_num(@index).to_s : XdRs_Rs::Infinite_Word
    @num_hint.change_color(system_color)
    cw = @num_hint.contents.text_size(XdRs_Rs::Num_Word).width + 4
    @num_hint.draw_text(x,0,cw,size,XdRs_Rs::Num_Word)
    @num_hint.change_color(is_sold_out(@index) ? knockout_color : normal_color)
    @num_hint.draw_text(x+cw,0,size*2+4,size,text,2)
  end
  #--------------------------------------------------------------------------
  def can_hint_show?
    return self.active && (XdRs_Rs::Show_Infinite || !!limit_num(@index))
  end
  #--------------------------------------------------------------------------
  alias xr_rs_enable? enable?
  def enable?(item)
    return !is_sold_out(@data.index(item)) && xr_rs_enable?(item)
  end
  #--------------------------------------------------------------------------
  def is_sold_out(n)
    return limit_num(n) && limit_num(n) == 0
  end
  #--------------------------------------------------------------------------
  def limit_num(n)
    return @nums_data ? @nums_data[n] : nil
  end
  #--------------------------------------------------------------------------
  def update
    super
    @num_hint && update_num_hint
  end
  #--------------------------------------------------------------------------
  def update_num_hint
    @num_hint.visible = can_hint_show?
    @old_num != limit_num(@index) && draw_limit_num
  end
end
#==============================================================================
class Scene_Shop
  #--------------------------------------------------------------------------
  alias xr_rs_prepare prepare
  def prepare(goods, purchase_only)
    xr_rs_prepare(goods, purchase_only)
    init_nums_data
  end
  #--------------------------------------------------------------------------
  def init_nums_data
    $game_system.real_shop_data > 0 && @goods.shift
    @sell_nums = $game_system.shop_surplus_nums
    @is_sold = false
  end
  #--------------------------------------------------------------------------
  def is_real_sold?
    return $game_system.real_shop_data > 0 && @is_sold
  end
  #--------------------------------------------------------------------------
  alias xr_rs_terminate terminate
  def terminate
    xr_rs_terminate
    is_real_sold? && $game_system.record_rest_nums(@sell_nums)
    $game_system.real_shop_data = 0
  end
  #--------------------------------------------------------------------------
  alias xr_rs_create_buy_window create_buy_window
  def create_buy_window
    xr_rs_create_buy_window
    @buy_window.setup_nums_data(@sell_nums)
  end
  #--------------------------------------------------------------------------
  alias xr_rs_do_buy do_buy
  def do_buy(number)
    xr_rs_do_buy(number)
    @is_sold = true
    limit_num && @sell_nums[@buy_window.index] -= number
  end
  #--------------------------------------------------------------------------
  alias xr_rs_max_buy max_buy
  def max_buy
    max = xr_rs_max_buy
    return limit_num ? [limit_num, max].min : max
  end
  #--------------------------------------------------------------------------
  def limit_num
    return @sell_nums ? @sell_nums[@buy_window.index] : nil
  end
end
#==============================================================================