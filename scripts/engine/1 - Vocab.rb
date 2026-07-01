#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab

  # ショップ画面
  ShopBuy         = "购入"
  ShopSell        = "卖出"
  ShopCancel      = "取消"
  Possession      = "所持数"

  # ステータス画面
  ExpTotal        = "现在的经验值"
  ExpNext         = "到下一%s还有"

  # セーブ／ロード画面
  SaveMessage     = "要记录到哪个档案？"
  LoadMessage     = "要读取哪个档案？"
  File            = "档案"

  # 複数メンバーの場合の表示
  PartyName       = "%s一行"

  # 戦闘基本メッセージ
  Emerge          = "%s出现了！"
  Preemptive      = "%s先制攻击！"
  Surprise        = "%s被偷袭了！"
  EscapeStart     = "%s逃跑！"
  EscapeFailure   = "但是没有逃掉！"

  # 戦闘終了メッセージ
  Victory         = "%s胜利！"
  Defeat          = "%s战败了。"
  ObtainExp       = "获得了 %s 点经验！"
  ObtainGold      = "获得了 %s\\G 魂！"
  ObtainItem      = "获得了%s！"
  LevelUp         = "%s提高到了%s %s ！"
  ObtainSkill     = "学会了%s！"

  # アイテム使用
  UseItem         = "%s使用了%s！"

  # クリティカルヒット
  CriticalToEnemy = "会心一击！！"
  CriticalToActor = "痛恨一击！！"

  # アクター対象の行動結果
  ActorDamage     = "%s受到了 %s 点伤害！"
  ActorRecovery   = "%s的%s恢复了 %s ！"
  ActorGain       = "%s的%s增加了 %s ！"
  ActorLoss       = "%s的%s减少了 %s ！"
  ActorDrain      = "%s的%s被夺取了 %s ！"
  ActorNoDamage   = "%s没有受到伤害！"
  ActorNoHit      = "没有命中！　%s没有受到伤害！"

  # 敵キャラ対象の行動結果
  EnemyDamage     = "对%s造成了 %s 点伤害！"
  EnemyRecovery   = "%s的%s恢复了 %s ！"
  EnemyGain       = "%s的%s增加了 %s ！"
  EnemyLoss       = "%s的%s减少了 %s ！"
  EnemyDrain      = "%s的%s被夺取了 %s ！"
  EnemyNoDamage   = "%s沒有受到伤害！"
  EnemyNoHit      = "沒命中！　%s没有受到伤害！"

  # 回避／反射
  Evasion         = "%s闪避了攻击！"
  MagicEvasion    = "%s闪避了魔法！"
  MagicReflection = "%s反弹了魔法！"
  CounterAttack   = "%s进行反击！"
  Substitute      = "%s在保护%s！"

  # 能力強化／弱体
  BuffAdd         = "%s的%s上升！"
  DebuffAdd       = "%s的%s下降！"
  BuffRemove      = "%s的%s复原了！"

  # スキル、アイテムの効果がなかった
  ActionFailure   = "对%s沒有效果！"

  # エラーメッセージ
  PlayerPosError  = "プレイヤーの初期位置が設定されていません。"
  EventOverflow   = "コモンイベントの呼び出しが上限を超えました。"

  # 基本ステータス
  def self.basic(basic_id)
    $data_system.terms.basic[basic_id]
  end

  # 能力値
  def self.param(param_id)
    $data_system.terms.params[param_id]
  end

  # 装備タイプ
  def self.etype(etype_id)
    $data_system.terms.etypes[etype_id]
  end

  # コマンド
  def self.command(command_id)
    $data_system.terms.commands[command_id]
  end

  # 通貨単位
  def self.currency_unit
    $data_system.currency_unit
  end

  #--------------------------------------------------------------------------
  def self.level;       basic(0);     end   # レベル
  def self.level_a;     basic(1);     end   # レベル (短)
  def self.hp;          basic(2);     end   # HP
  def self.hp_a;        basic(3);     end   # HP (短)
  def self.mp;          basic(4);     end   # MP
  def self.mp_a;        basic(5);     end   # MP (短)
  def self.tp;          basic(6);     end   # TP
  def self.tp_a;        basic(7);     end   # TP (短)
  def self.fight;       command(0);   end   # 戦う
  def self.escape;      command(1);   end   # 逃げる
  def self.attack;      command(2);   end   # 攻撃
  def self.guard;       command(3);   end   # 防御
  def self.item;        command(4);   end   # アイテム
  def self.skill;       command(5);   end   # スキル
  def self.equip;       command(6);   end   # 装備
  def self.status;      command(7);   end   # ステータス
  def self.formation;   command(8);   end   # 並び替え
  def self.save;        command(9);   end   # セーブ
  def self.game_end;    command(10);  end   # ゲーム終了
  def self.weapon;      command(12);  end   # 武器
  def self.armor;       command(13);  end   # 防具
  def self.key_item;    command(14);  end   # 大事なもの
  def self.equip2;      command(15);  end   # 装備変更
  def self.optimize;    command(16);  end   # 最強装備
  def self.clear;       command(17);  end   # 全て外す
  def self.new_game;    command(18);  end   # ニューゲーム
  def self.continue;    command(19);  end   # コンティニュー
  def self.shutdown;    command(20);  end   # シャットダウン
  def self.to_title;    command(21);  end   # タイトルへ
  def self.cancel;      command(22);  end   # やめる
  #--------------------------------------------------------------------------
end
