# Грузит SpriteDisposeFix.dll из корня игры. Идемпотентно.
# Ставь как можно выше в списке скриптов (над Main, желательно первым в Materials),
# чтобы хуки встали до создания первых спрайтов.
module SpriteDisposeFixLoader
  DLL = "SpriteDisposeFix.dll"

  def self.load!
    return if @loaded
    @loaded = true
    h = Win32API.new("kernel32", "LoadLibraryA", ["p"], "i").call(DLL)
    if h == 0
      err = Win32API.new("kernel32", "GetLastError", [], "i").call
      msg = "SpriteDisposeFix: LoadLibrary('#{DLL}') failed, err=#{err}"
      defined?(msgbox) ? msgbox(msg) : p(msg)
    end
    # DllMain уже поставил хуки синхронно. Явный вызов не нужен, но если захочешь
    # триггерить вручную — раскомментируй (DLL экспортирует InstallSpriteDisposeFix):
    # Win32API.new(DLL, "InstallSpriteDisposeFix", [], "v").call if h != 0
  end
end

SpriteDisposeFixLoader.load!