#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
#  Модуль, определяющий термины и сообщения. Помимо непосредственного
#  определения сообщений константами, получает данные терминов из
#  глобальной переменной $data_system.
#==============================================================================

module Vocab

  # Экран магазина
  ShopBuy         = "Купить"
  ShopSell        = "Продать"
  ShopCancel      = "Отмена"
  Possession      = "В наличии"

  # Экран статуса
  ExpTotal        = "Текущий опыт"
  ExpNext         = "До следующего %s осталось"

  # Экран сохранения / загрузки
  SaveMessage     = "Записать в файл?"
  LoadMessage     = "Загрузить из файла?"
  File            = "Файл"

  # Отображение при нескольких членах
  PartyName       = "%s и компания"

  # Базовые сообщения битвы
  Emerge          = "Появляется %s!"
  Preemptive      = "%s атакует первым!"
  Surprise        = "%s захвачен врасплох!"
  EscapeStart     = "%s убегает!"
  EscapeFailure   = "Побег не удался!"

  # Сообщения об окончании битвы
  Victory         = "%s победил!"
  Defeat          = "%s повержен."
  ObtainExp       = "Получено %s опыта!"
  ObtainGold      = "Получено %s\G душ!"
  ObtainItem      = "Вы получили %s!"
  LevelUp         = "%s достиг %s %s!"
  ObtainSkill     = "Выучен навык %s!"

  # Использование предмета
  UseItem         = "%s использует %s!"

  # Критический удар
  CriticalToEnemy = "Критический удар!!"
  CriticalToActor = "Сокрушительный удар!!"

  # Результаты действий по актёру
  ActorDamage     = "%s получает %s урона!"
  ActorRecovery   = "%s восстанавливает %s на %s!"
  ActorGain       = "%s увеличивает %s на %s!"
  ActorLoss       = "%s уменьшает %s на %s!"
  ActorDrain      = "%s поглощает %s у %s!"
  ActorNoDamage   = "%s не получает урона!"
  ActorNoHit      = "Промах! %s не получает урона!"

  # Результаты действий по врагу
  EnemyDamage     = "Нанесено %s урона %s!"
  EnemyRecovery   = "%s восстанавливает %s на %s!"
  EnemyGain       = "%s увеличивает %s на %s!"
  EnemyLoss       = "%s уменьшает %s на %s!"
  EnemyDrain      = "%s поглощает %s у %s!"
  EnemyNoDamage   = "%s не получает урона!"
  EnemyNoHit      = "Промах! %s не получает урона!"

  # Уклонение / отражение
  Evasion         = "%s уклоняется!"
  MagicEvasion    = "%s уклоняется от магии!"
  MagicReflection = "%s отражает магию!"
  CounterAttack   = "%s контратакует!"
  Substitute      = "%s защищает %s!"

  # Усиление / ослабление
  BuffAdd         = "%s повышает %s!"
  DebuffAdd       = "%s понижает %s!"
  BuffRemove      = "%s восстанавливает %s!"

  # Навык / предмет не возымели эффекта
  ActionFailure   = "Не действует на %s!"

  # Сообщения об ошибках
  PlayerPosError  = "Не задана начальная позиция игрока."
  EventOverflow   = "Превышен лимит вызовов общих событий."

  # Базовые характеристики
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # Параметры
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # Типы экипировки
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # Команды
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # Денежная единица
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # Уровень
  def self.level_a;     basic(1);     end   # Уровень (коротко)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (коротко)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (коротко)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (коротко)
  def self.fight;       command(0);   end   # Сражаться
  def self.escape;      command(1);   end   # Сбежать
  def self.attack;      command(2);   end   # Атаковать
  def self.guard;       command(3);   end   # Защищаться
  def self.item;        command(4);   end   # Предмет
  def self.skill;       command(5);   end   # Навык
  def self.equip;       command(6);   end   # Экипировка
  def self.status;      command(7);   end   # Статус
  def self.formation;   command(8);   end   # Порядок
  def self.save;        command(9);   end   # Сохранить
  def self.game_end;    command(10);  end   # Выход из игры
  def self.weapon;      command(12);  end   # Оружие
  def self.armor;       command(13);  end   # Броня
  def self.key_item;    command(14);  end   # Важное
  def self.equip2;      command(15);  end   # Сменить экип.
  def self.optimize;    command(16);  end   # Лучшая экип.
  def self.clear;       command(17);  end   # Снять всё
  def self.new_game;    command(18);  end   # Новая игра
  def self.continue;    command(19);  end   # Продолжить
  def self.shutdown;    command(20);  end   # Завершить
  def self.to_title;    command(21);  end   # В заглавие
  def self.cancel;      command(22);  end   # Отмена
  #--------------------------------------------------------------------------
end