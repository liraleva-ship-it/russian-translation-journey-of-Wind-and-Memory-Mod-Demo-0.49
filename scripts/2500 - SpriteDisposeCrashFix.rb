#==============================================================================
# ■ SpriteDisposeCrashFix
#------------------------------------------------------------------------------
#  Фикс случайного вылета движка (RGSS301.dll, 0xC0000005) при входе в бой.
#
#  Причина: несколько скриптов в dispose освобождают Viewport РАНЬШЕ, чем
#  спрайт/plane/tilemap, который на него ссылается. При уничтожении спрайта
#  движок отвязывает его от viewport'а (идёт по внутреннему z-списку viewport'а
#  через std::find). Если viewport уже освобождён — чтение мёртвой памяти =
#  access violation. Падает "через раз", потому что зависит от переиспользования
#  кучи (а скрипт 121 - 内存清理 с фоновым GC.start этот эффект усиливает).
#
#  Правило фикса: сначала уничтожить объект (super / .dispose), и только ПОТОМ
#  освободить его viewport. Поведение эффектов не меняется.
#
#  Чинит: 217 - SF显示, 262 - 显示图片, 228 - 阳炎效果.
#==============================================================================

$imported ||= {}
unless $imported["IDL-SpriteDisposeFix"]
$imported["IDL-SpriteDisposeFix"] = 1.0

# --- 217 - SF显示.rb -------------------------------------------------------
# SignalDisplayRear_Sprite / Middle / Front — у каждого свой выделенный viewport.
# ВАЖНО: классы расписаны явно (не циклом с общим блоком) — иначе Ruby 1.9.2
# выдаёт "super from singleton method defined to multiple classes".
if Object.const_defined?(:SignalDisplayRear_Sprite)
  class SignalDisplayRear_Sprite < Sprite
    def dispose
      return if disposed?
      vp = self.viewport          # захватываем ДО super (после dispose читать нельзя)
      super                       # отвязка спрайта от живого viewport'а
      vp.dispose if vp && !vp.disposed?
    end
  end
end

if Object.const_defined?(:SignalDisplayMiddle_Plane)
  class SignalDisplayMiddle_Plane < Plane
    def dispose
      return if disposed?
      vp = self.viewport
      super
      vp.dispose if vp && !vp.disposed?
    end
  end
end

if Object.const_defined?(:SignalDisplayFront_Plane)
  class SignalDisplayFront_Plane < Plane
    def dispose
      return if disposed?
      vp = self.viewport
      super
      vp.dispose if vp && !vp.disposed?
    end
  end
end

# --- 262 - 显示图片.rb -----------------------------------------------------
# Sprite_4j ($test_sprite) — диспозится в Scene_Map/Scene_Battle#terminate.
if Object.const_defined?(:Sprite_4j)
  class Sprite_4j < Sprite
    def dispose
      return if disposed?
      bmp = self.bitmap
      vp  = self.viewport
      super                       # сначала корректно отвязываем спрайт
      bmp.dispose if bmp && !bmp.disposed?
      vp.dispose  if vp  && !vp.disposed?
    end
  end
end

# --- 228 - 阳炎效果.rb -----------------------------------------------------
# Heat_Haze: tilemap И character_sprites используют ОДИН общий viewport.
# Оригинал освобождал viewport первым -> двойной UAF. Правильный порядок:
# сначала все потребители viewport'а, viewport — последним.
if Object.const_defined?(:Heat_Haze)
  class Heat_Haze
    def dispose_heat_haze_map
      vp = @tilemap ? @tilemap.viewport : nil
      if @character_sprites
        @character_sprites.each { |sprite| sprite.dispose if sprite && !sprite.disposed? }
        @character_sprites = nil
      end
      @tilemap.dispose if @tilemap && !@tilemap.disposed?
      @tileset = nil
      vp.dispose if vp && !vp.disposed?
    end
  end
end

# --- Доп. защита: убрать форсированный GC на переходе сцен (скрипт 121) -----
# Сам по себе он не баг, но переиспользует кучу прямо в момент перехода в бой
# и превращает латентный UAF в стабильный вылет. После фикса dispose это уже
# безопасно, но отключаем как страховку. Подавляем warning о переопределении.
if defined?(GC_CLEAR) && GC_CLEAR.const_defined?(:GC_TRANSITION)
  _v = $VERBOSE; $VERBOSE = nil
  GC_CLEAR.const_set(:GC_TRANSITION, false)
  $VERBOSE = _v
end

end # unless $imported["IDL-SpriteDisposeFix"]
