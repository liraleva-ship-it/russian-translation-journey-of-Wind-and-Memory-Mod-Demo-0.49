#==============================================================================
# ▼ Unified Input Patch — WASD toggle + Q/C remap + page scroll + edge-wrap fix
#   [ФИНАЛЬНАЯ ТОЧЕЧНАЯ ВЕРСИЯ — БЛОКИРОВКА СТРОГО В ИНВЕНТАРЕ + GHOST-FIX]
#==============================================================================

module Input
  class << self
    GETKEY = Win32API.new("user32", "GetAsyncKeyState", ["i"], "i")

    INVENTORY_SCENES = ["Scene_Item"]

    VK = {
      :W          => 0x57,
      :A          => 0x41,
      :S          => 0x53,
      :D          => 0x44,
      :Q          => 0x51,
      :C          => 0x43,
      :DOWN_ARROW => 0x28
    }

    # --- Карта "теневых" символов RGSS3 -------------------------------------
    # По умолчанию (без всяких патчей) эти физические клавиши приклеены
    # к этим символам движка. Когда включён WASD-режим, нужно их глушить,
    # иначе клавиша одновременно двигает/листает И дёргает родной символ
    # (это и было причиной бага с D => :Z в магазине).
    GHOST_SYMS = { :W => :R, :A => :X, :S => :Y, :D => :Z }

    def vk?(code)
      GETKEY.call(code) & 0x8000 != 0
    end

    def wasd_on?
      $game_system && $game_system.wasd_enabled?
    end

    alias lokwasd_update update
    def update
      lokwasd_update
      @phys ||= Hash.new(0)
      VK.each { |name, code| vk?(code) ? @phys[name] += 1 : @phys[name] = 0 }
    end

    def phys_trigger?(name)
      @phys ||= Hash.new(0)
      @phys[name] == 1
    end

    def phys_repeat?(name)
      @phys ||= Hash.new(0)
      t = @phys[name]
      t == 1 || (t >= 20 && t % 6 == 0)
    end

    #------------------------------------------------------------------------
    # ● press?
    #------------------------------------------------------------------------
    alias lokwasd_press? press?
    def press?(sym)
      if vk?(VK[:A]) && !wasd_on?
        return false
      end

      if vk?(VK[:C])
        return true  if sym == :L
        return false if [:C, :X, :Y, :Z].include?(sym)
      end
      if vk?(VK[:Q])
        return true  if sym == :X
        return false if [:C, :L, :R, :Y, :Z].include?(sym)
      end

      if wasd_on?
        return true  if sym == :UP    && vk?(VK[:W])
        return true  if sym == :DOWN  && vk?(VK[:S])
        return true  if sym == :LEFT  && vk?(VK[:A])
        return true  if sym == :RIGHT && vk?(VK[:D])
        return false if [:UP, :DOWN, :LEFT, :RIGHT].include?(sym)
        return true  if sym == :R     && vk?(VK[:DOWN_ARROW])

        GHOST_SYMS.each { |key, ghost| return false if sym == ghost && vk?(VK[key]) }
        return false if vk?(VK[:A])   && [:L, :X, :Y, :Z, :L2, :R2].include?(sym)
      else
        return true  if sym == :R     && vk?(VK[:S])
      end

      lokwasd_press?(sym)
    end

    #------------------------------------------------------------------------
    # ● trigger?
    #------------------------------------------------------------------------
    alias lokwasd_trigger? trigger?
    def trigger?(sym)
      if vk?(VK[:A]) && !wasd_on?
        return false
      end

      if vk?(VK[:C])
        return true  if sym == :L && phys_trigger?(:C)
        return false if [:C, :X, :Y, :Z].include?(sym)
      end
      if vk?(VK[:Q])
        return true  if sym == :X && phys_trigger?(:Q)
        return false if [:C, :L, :R, :Y, :Z].include?(sym)
      end

      if (sym == :UP || sym == :DOWN)
        current_scene_name = SceneManager.scene.class.name
        if INVENTORY_SCENES.include?(current_scene_name)
          return false
        end
      end

      if wasd_on?
        return phys_trigger?(:W)          if sym == :UP
        return phys_trigger?(:S)          if sym == :DOWN
        return phys_trigger?(:A)          if sym == :LEFT
        return phys_trigger?(:D)          if sym == :RIGHT
        return phys_trigger?(:DOWN_ARROW) if sym == :R

        GHOST_SYMS.each { |key, ghost| return false if sym == ghost && vk?(VK[key]) }
        return false if vk?(VK[:A]) && [:L, :X, :Y, :Z, :L2, :R2].include?(sym)
      else
        return phys_trigger?(:S)          if sym == :R
      end

      lokwasd_trigger?(sym)
    end

    #------------------------------------------------------------------------
    # ● repeat?
    #------------------------------------------------------------------------
    alias lokwasd_repeat? repeat?
    def repeat?(sym)
      if vk?(VK[:A]) && !wasd_on?
        return false
      end

      if vk?(VK[:C])
        return true  if sym == :L && phys_repeat?(:C)
        return false if [:C, :X, :Y, :Z].include?(sym)
      end
      if vk?(VK[:Q])
        return true  if sym == :X && phys_repeat?(:Q)
        return false if [:C, :L, :R, :Y, :Z].include?(sym)
      end

      if wasd_on?
        return phys_repeat?(:W)          if sym == :UP
        return phys_repeat?(:S)          if sym == :DOWN
        return phys_repeat?(:A)          if sym == :LEFT
        return phys_repeat?(:D)          if sym == :RIGHT
        return phys_repeat?(:DOWN_ARROW) if sym == :R

        GHOST_SYMS.each { |key, ghost| return false if sym == ghost && vk?(VK[key]) }
        return false if vk?(VK[:A]) && [:L, :X, :Y, :Z, :L2, :R2].include?(sym)
      else
        return phys_repeat?(:S)          if sym == :R
      end

      lokwasd_repeat?(sym)
    end

    #------------------------------------------------------------------------
    # ● dir4 / dir8
    #------------------------------------------------------------------------
    alias lokwasd_dir4 dir4
    def dir4
      if wasd_on?
        return 8 if vk?(VK[:W])
        return 2 if vk?(VK[:S])
        return 4 if vk?(VK[:A])
        return 6 if vk?(VK[:D])
        return 0
      end
      lokwasd_dir4
    end

    alias lokwasd_dir8 dir8
    def dir8
      if wasd_on?
        u = vk?(VK[:W]); d = vk?(VK[:S])
        l = vk?(VK[:A]); r = vk?(VK[:D])
        return 7 if u && l
        return 9 if u && r
        return 1 if d && l
        return 3 if d && r
        return dir4
      end
      lokwasd_dir8
    end
  end
end