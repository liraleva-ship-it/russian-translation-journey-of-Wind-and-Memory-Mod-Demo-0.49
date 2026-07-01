class Window_Base < Window
  
  def draw_actor_nickname(actor, x, y)
    n = $1.to_i if /<称号颜色 (\d+?)>/i =~ actor.note
    n = ItemLevelDrawer::ColorSet[n.to_i] if n != nil
    
    if n.nil?
      change_color(normal_color)
    elsif n.is_a?(Color)
      change_color(n) # Если это уже готовый Color, применяем его напрямую
    else
      change_color(Color.new(n[0], n[1], n[2])) # Если это массив [R,G,B]
    end
    
    draw_text(x, y, width, line_height, actor.nickname)
  end
  
  def draw_spirit_name(actor, x, y, enabled=true, width = 112)
    n = $1.to_i if /<誓约颜色 (\d+?)>/i =~ actor.note
    n = ItemLevelDrawer::ColorSet[n.to_i] if n != nil
    
    if n.nil?
      change_color(normal_color)
    elsif n.is_a?(Color)
      change_color(n) # Если это уже готовый Color, применяем его напрямую
    else
      change_color(Color.new(n[0], n[1], n[2])) # Если это массив [R,G,B]
    end
    
    draw_text(x, y, width, line_height, actor.name)
  end
  
end