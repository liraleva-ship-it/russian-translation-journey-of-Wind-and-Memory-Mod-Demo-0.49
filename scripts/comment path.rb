# =============================================================================
# Одноразовый скрипт для исправления ярлыков через запуск игры (F5)
# Вставлять в F11 строго НАД секцией Main!
# =============================================================================
=begin
module RPG
  # Внутри редактора классы уже определены, нам нужен только EventCommand
  class EventCommand; end
end

module NameTagFixer
  NW_PREFIX        = 'NW'
  CODE_COMMENT     = 108
  CODE_SHOW_TEXT   = 101
  BG_NORMAL_WINDOW = 0

  module_function

  def nw_comment?(cmd)
    cmd && cmd.code == CODE_COMMENT && cmd.parameters[0].is_a?(String) && cmd.parameters[0].lstrip.start_with?(NW_PREFIX)
  end

  def nw_comment_above(list, i)
    prev = list[i - 1] if i > 0
    nw_comment?(prev) ? prev.parameters[0] : nil
  end

  def build_name_comment(text, indent)
    RPG::EventCommand.new(CODE_COMMENT, indent, [text.dup])
  end

  def process_list(list)
    return 0 unless list.is_a?(Array)
    inserted = 0
    last_name = nil
    i = 0
    while i < list.size
      cmd = list[i]
      if cmd.is_a?(RPG::EventCommand) && cmd.code == CODE_SHOW_TEXT
        if cmd.parameters[2] == BG_NORMAL_WINDOW
          own = nw_comment_above(list, i)
          if own
            last_name = own
          elsif last_name
            list.insert(i, build_name_comment(last_name, cmd.indent))
            inserted += 1
            i += 1
          end
        else
          last_name = nil
        end
      end
      i += 1
    end
    inserted
  end

  def each_command_list(data)
    if data.is_a?(RPG::Map)
      data.events.each_value do |event|
        next unless event && event.pages
        event.pages.each { |page| yield page.list if page && page.list }
      end
    elsif data.is_a?(RPG::Troop)
      data.pages.each { |page| yield page.list if page && page.list } if data.pages
    elsif data.is_a?(Array)
      data.each { |ce| yield ce.list if ce && ce.respond_to?(:list) && ce.list }
    end
  end

  def process_file(path)
    data = File.open(path, 'rb') { |f| Marshal.load(f) }
    total = 0
    each_command_list(data) { |list| total += process_list(list) }
    if total > 0
      File.rename(path, "#{path}.bak") unless File.exist?("#{path}.bak")
      File.open(path, 'wb') { |f| Marshal.dump(data, f) }
    end
    total
  end

  def start_fix
    # Папка Data находится прямо в корне проекта, откуда запускается игра
    data_dir = "Data" 
    targets = Dir.glob(File.join(data_dir, 'Map*.rvdata2')).reject { |p| File.basename(p) =~ /\AMapInfos/i }
    targets += Dir.glob(File.join(data_dir, 'CommonEvents.rvdata2'))
    targets += Dir.glob(File.join(data_dir, 'Troops.rvdata2'))

    grand_total = 0
    targets.sort.each do |path|
      grand_total += process_file(path)
    end
    
    # Показываем виндовое окошко с результатом выполнения
    print "Успешно добавлено ярлыков: #{grand_total} шт.\nИгра автоматически закроется."
    exit
  end
end

# Запускаем исправление прямо при инициализации игры
NameTagFixer.start_fix
=end