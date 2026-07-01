#==============================================================================
# Скрипт проверки длины строк в диалогах, выборах и прокручиваемом тексте
# Автоматически запускается при старте игры (если скрипт размещён в разделе ▼ Материалы)
# Отчёт сохраняется в файл LongDialogLines.txt в папке проекта.
#==============================================================================
=begin
module DialogLineChecker
  MAX_LEN = 51
  REPORT_FILE = "LongDialogLines.txt"

  def self.check_all_maps
    long_lines = []
    map_files = Dir.glob("Data/Map*.rvdata2").sort
    map_files.each do |file|
      if file =~ /Map(\d+)\.rvdata2$/
        map_id = $1.to_i
        map = load_data(file)
        check_map(map, map_id, long_lines)
      end
    end

    if long_lines.empty?
      msgbox "Все строки диалогов имеют длину не более #{MAX_LEN} символов."
    else
      save_report(long_lines)
      msgbox "Найдено #{long_lines.size} строк(и) длиной более #{MAX_LEN} символов. Отчёт сохранён в файл #{REPORT_FILE}."
    end
  rescue => e
    msgbox "Ошибка при проверке: #{e.message}\n#{e.backtrace.first}"
  end

  def self.check_map(map, map_id, long_lines)
    map.events.each do |_event_id, event|
      check_event(event, map_id, long_lines)
    end
  end

  def self.check_event(event, map_id, long_lines)
    event.pages.each do |page|
      list = page.list
      next if list.nil?
      i = 0
      while i < list.size
        case list[i].code
        when 101  # Показать текст
          i += 1
          while i < list.size && list[i].code == 401
            line = list[i].parameters[0]
            if line.is_a?(String) && line.length > MAX_LEN
              long_lines << "map#{map_id}: #{line} (длина: #{line.length})"
            end
            i += 1
          end
        when 102  # Показать выбор
          # Строки выбора находятся в параметре [0] команды 102 (массив строк)
          choices = list[i].parameters[0]
          if choices.is_a?(Array)
            choices.each do |choice|
              if choice.is_a?(String) && choice.length > MAX_LEN
                long_lines << "map#{map_id}: (выбор) #{choice} (длина: #{choice.length})"
              end
            end
          end
          i += 1
        when 105  # Прокручиваемый текст
          i += 1
          while i < list.size && list[i].code == 405
            line = list[i].parameters[0]
            if line.is_a?(String) && line.length > MAX_LEN
              long_lines << "map#{map_id}: (скролл) #{line} (длина: #{line.length})"
            end
            i += 1
          end
        else
          i += 1
        end
      end
    end
  end

  def self.save_report(lines)
    File.open(REPORT_FILE, "w:UTF-8") do |f|
      lines.each { |l| f.puts l }
    end
  end
end

# Автоматический запуск при старте игры (разместите скрипт в разделе ▼ Материалы)
class Scene_Title
  alias :dialog_checker_start :start
  def start
    dialog_checker_start
    DialogLineChecker.check_all_maps
  end
end
=end