# ステ―ト詳細確認ウィンドウ
#
# 戦闘時、パーティコマンドに付与されているステートの詳細を確認するためのコマンド
# を追加します。

$imported_yana_scripts ||= {}
$imported_yana_scripts["StateHelpWindow"] = true

module StateHelp
  Buffs = {}
  States = []

# 请按照下面的描写进行备注

  Buffs[[0,:up]] = "HP+15%每级，最高2级\n"
  Buffs[[1,:up]] = "MP+15%每级，最高2级\n"
  Buffs[[2,:up]] = "物攻+15%每级，最高2级\n"
  Buffs[[3,:up]] = "物防+15%每级，最高2级\n"
  Buffs[[4,:up]] = "魔攻+15%每级，最高2级\n"
  Buffs[[5,:up]] = "魔防+15%每级，最高2级\n"
  Buffs[[6,:up]] = "敏捷+15%每级，最高2级\n"
  Buffs[[7,:up]] = "幸运+15%每级，最高2级\n"

  Buffs[[0,:down]] = "HP-15%每级，最高2级\n"
  Buffs[[1,:down]] = "MP-15%每级，最高2级\n"
  Buffs[[2,:down]] = "物攻-15%每级，最高2级\n"
  Buffs[[3,:down]] = "物防-15%每级，最高2级\n"
  Buffs[[4,:down]] = "魔攻-15%每级，最高2级\n"
  Buffs[[5,:down]] = "魔防-15%每级，最高2级\n"
  Buffs[[6,:down]] = "敏捷-15%每级，最高2级\n"
  Buffs[[7,:down]] = "幸运-15%每级，最高2级\n"

  States[1]  = "【无法战斗】：死亡"
  States[2]  = "XXX"
  States[3]  = "【盲目】：大幅降低命中 闪避 小幅降低敏捷"
  States[4]  = "【沉默】：无法使用技能"
  States[5]  = "【虚弱】：攻击能力减半 HP恢复无效 小幅降低敏捷"
  States[6]  = "【睡眠】：无法行动 巨幅降低回避 单次必被暴击 受到伤害时解除"
  States[7]  = "【麻痹】：无法行动 中幅降低闪避 反射 反击 暴击抗性 小幅降低敏捷
  小幅提高受到的伤害"
  States[8]  = "【眩晕】：无法行动 巨幅降低闪避 反射 反击 暴击抗性 小幅降低敏捷"
  States[9]  = "【恐惧】：无法闪避 防御效果减半"
  States[10]  = "【冻伤】：中幅降低魔法防御 中幅降低敏捷"
  States[11]  = "【冻结】：无法行动 巨幅降低闪避 反射 反击 暴击抗性 巨幅提高双防
  受到中幅伤害时解除"
  States[12]  = "【潮湿】：大幅提高火系抗性 中幅降低雷系 冰系抗性 小幅降低敏捷"
  States[13]  = "【油腻】：中幅提高炎抗性 巨幅降低燃烧抗性 巨幅提高潮湿抗性
  小幅降低敏捷"
  States[14]  = "【脆弱】：巨幅降低暴击抗性 中幅降低击溃抗性 必被暴击"
  States[15]  = "【燃烧】：HP持续减少 中幅降低物理防御"
  States[16]  = "【发狂】：HP持续减半 HP上限减半 巨幅提高攻击能力"
  States[17]  = "【打断】：无法行动 大幅降低闪避 反射 反击 暴击抗性 小幅降低敏捷"
  States[18]  = "【出血】：HP持续减少 小幅降低物理 吸收抗性 中幅降低大出血抗性"
  States[19]  = "【大出血】：HP持续减少提高 中幅降低物理 吸收抗性 免疫出血状态"
  States[20]  = "【中毒】：HP持续减少 小幅降低恢复效果比例 中幅降低剧毒抗性"
  States[21]  = "【剧毒】：HP持续减少提高 中幅降低恢复效果比例 免疫中毒状态"
  States[22]  = "【迷失者】：中幅降低HPMP上限 中幅降低防御效果"
  States[23]  = "不死之身XXX"
  States[24]  = "【减速】：中幅降低敏捷 小幅降低回避率 暴击抗性"
  States[25]  = "【破绽】：巨幅提高被击溃概率"
  States[26]  = "【大破绽】：超巨幅提高被击溃概率"
  States[27]  = "【炎之力】：小幅提高火系抗性 小幅提高攻击力 攻击小概率附加燃烧状态"
  States[28]  = "【雷之力】：小幅提高雷系抗性 小幅提高攻击力 攻击小概率附加麻痹状态"
  States[29]  = "【暗之力】：小幅提高暗系抗性 小幅提高攻击力 攻击小概率附加盲目状态"
  States[30]  = "【冰之力】：小幅提高冰系抗性 小幅提高攻击力
  攻击小概率附加冰冻冻伤状态"
  States[31]  = "【风之力】：小幅提高风系抗性 小幅提高攻击力 攻击小概率附加打断状态"
  States[32]  = "【神圣之力】：小幅提高神圣系抗性 小幅提高攻击力
  攻击小概率附加沉默状态"
  States[33]  = "【无法行动】：无法行动XXX"
  States[34]  = "【防御】：依据防御效率减免伤害 小幅提高敏捷
  大幅提高控制抗性和暴击抗性"
  States[35]  = "【反击】：受到攻击时反击"
  States[36]  = "【闪避】：小幅提高敏捷 大幅提高闪避"
  States[37]  = "【击溃无防备】：无法行动 巨幅提高受到伤害 巨幅降低闪避 反射 反击
  暴击抗性 中幅降低敏捷"
  States[38]  = "【强击溃无防备】：无法行动 超巨幅提高受到伤害 巨幅降低闪避 反射 反击
  暴击抗性 大幅降低敏捷"
  States[39]  = "【蓄能】：小幅提高攻击力和暴击率"
  States[40]  = "【加速】：中幅提高敏捷 攻击次数+1"
  States[41]  = "【神速】：巨幅提高敏捷 额外行动回合+1"
  States[42]  = "【魔法闪避】：巨幅提高魔法闪避率"
  States[43]  = "【魔法反射】：巨幅提高魔法反射率"
  States[44]  = "【振奋】：获得小幅伤害减免 HP持续恢复"
  States[45]  = "【反击姿态】：大幅提高全属性抗性 中幅提高控制抗性 中幅减少敏捷"
  States[46]  = "【招架姿态】：小幅提高全属性抗性 小幅提高控制抗性 小幅减少敏捷"
  States[47]  = "【时间叠影】：中幅提高受到伤害 中幅提高MP消耗 中幅减少闪避 暴击闪避"
  States[48]  = "【保护】：保护血量低于一定数值的友方角色 无法行动时解除"
  States[49]  = "【再生】：HP小幅持续恢复"
  States[50]  = "【天堂再生】：HP大幅持续恢复"
  States[51]  = "【圣言】：中幅降低物理闪避率 中幅降低敏捷"
  States[52]  = "剧情出血"
  States[53]  = "【驱逐】：HP小幅持续减少"
  States[54]  = "【HP缓慢恢复】：HP小幅持续恢复"
  States[55]  = "【MP缓慢恢复】：MP小幅持续恢复"
  States[56]  = "【HP恢复】：HP小幅持续恢复"
  States[57]  = "【MP恢复】：MP小幅持续恢复"
  States[58]  = "【全异常抗性】：中幅提高全部异常抗性"
  States[59]  = "【全异常免疫】：免疫全部异常状态"
  States[60]  = "【弱化抗性】：大幅提高盲目 虚弱 恐惧 冻伤 潮湿 油腻 脆弱抗性
  发狂 减速 破绽 大破绽抗性"
  States[61]  = "【控制抗性】：大幅提高睡眠 冻结 眩晕 麻痹 沉默 打断抗性"
  States[62]  = "【回避率+50%】：中幅提高物理闪避率"
  States[63]  = "【持续伤害抗性】：大幅提高燃烧 出血 大出血 中毒 剧毒抗性"
  States[64]  = "【陷入沼泽】：中幅降低敏捷"
  States[66]  = "【变成小动物】：巨幅减少攻击 魔力 大幅降低敏捷 变成一只兔子"
  States[76]  = "【流血】：HP持续减少 小幅降低物理 吸收抗性 中幅降低大出血抗性"
  States[101]  = "【固若金汤】：大幅降低受到物理伤害"
  States[102]  = "【无言之誓】：中幅提升物理攻击 暴击率 免疫决心"
  States[103]  = "【魔法盾】：大幅降低受到伤害"
  States[104]  = "【磐岩之躯】：巨幅提高眩晕 脆弱 击溃无防备 强击溃无防备抗性
  小幅降低敏捷 中幅提高物理防御"
  States[105]  = "【魔法盾】：中幅降低受到伤害 MP小幅持续减少"
  States[106]  = "【狂战士之怒】：HP小幅持续减少 小幅提高物理攻击 受到物理伤害 敏捷
  中幅提高睡眠 麻痹 眩晕 冻结 打断抗性 击溃无防备 强击溃无防备抗性 禁用防御"
  States[107]  = "【霸体护甲】：巨幅提高打断 击溃无防备 强击溃无防备抗性
  中幅降低受到物理伤害"
  States[108]  = "【抗争意志】：中幅提高暴击率 攻击力"
  States[109]  = "【鸱鸮之宴】：HP小幅持续减少"
  States[111]  = "【速度增加1】：小幅提高敏捷"
  States[112]  = "【速度增加2】：小幅提高敏捷"
  States[113]  = "【速度增加3】：小幅提高敏捷"
  States[114]  = "【速度增加4】：小幅提高敏捷"
  States[115]  = "【速度增加5】：小幅提高敏捷"
  States[116]  = "【速度增加6】：中幅提高敏捷"
  States[118]  = "【王庭之号令】：中幅提高暴击率 物理命中率"
  States[119]  = "【鉴定结果差评】：小幅降低攻击 防御 敏捷  幸运 物理命中率 暴击率
  闪避率 反击率 魔法反射率 防御效果比率 恢复效果比率"
  States[120]  = "【弱点暴露】：巨幅提高破绽 大破绽 击溃无防备 强击溃无防备 打断抗性 巨幅提高 伤害加成"
  States[121]  = "【圣光笼罩】：免疫 盲目 沉默 虚弱睡眠 麻痹 眩晕 恐惧  冻伤 冻结 潮湿 油腻 脆弱 燃烧 发狂 打断 出血 大出血 中毒 剧毒 减速"
  States[122]  = "【居合】：巨幅提高减伤率 巨幅减少闪避率 受击后发动强力反击"
  States[123]  = "【见切】：大幅提高闪避率 闪避后发动强力反击"
  States[124]  = "【燕返】：大幅提高闪避率 闪避后发动强力反击"
  States[125]  = "【魔力涌动】：魔力消耗减半 并且所有初级魔法释放不占用回合"
  States[126]  = "【开刃一阶段】：登龙成功概率50% 登龙威力增加并概率造成击溃"
  States[127]  = "【开刃二阶段】：登龙成功概率75% 登龙威力进一步增加并造成击溃"
  States[128]  = "【开刃三阶段】：登龙成功概率100% 登龙威力大幅增加并造成强击溃"
  States[130]  = "【青龙之势】：中幅提高魔力 暴击率 25%获得额外回合"
  States[131]  = "【白虎之势】：小幅提高攻击力 物理命中率 中幅提高反击率"
  States[132]  = "【朱雀之势】：小幅提高敏捷 闪避率 攻击次数+1"
  States[133]  = "【玄武之势】：小幅提高双防 异常状态抗性 中幅提高减伤率"
  States[134]  = "【麒麟之势】：小幅提高全属性"
  States[201]  = "一段"
  States[202]  = "二段"
  States[203]  = "三段"
  States[204]  = "【刻印】：中幅提高受到的暗系伤害"
  States[205]  = "【滑步闪避】：大幅提高闪避率 中幅提高敏捷"
  States[206]  = "【猎手标记】：大幅降低物理闪避率"
  States[207]  = "【钢铁意志】：大幅降低敏捷 大幅提高防御"
  States[208]  = "【追猎】：小幅提高物理命中率 物理闪避率 敏捷"
  States[209]  = "【弱点】：小幅降低防御 敏捷"
  States[210]  = "【武器附魔】：小幅提高暴击率 攻击"
  States[211]  = "【印记】：小幅降低防御 攻击"
  States[212]  = "【灼炎】：HP小幅持续减少 攻击附加燃烧状态"
  States[213]  = "衰退光环"
  States[214]  = "【衰退】：小幅降低敏捷 物理攻击"
  States[215]  = "气场红色幻影通用"
  States[216]  = "气场红色幻影冲击"
  States[217]  = "气场红色幻影闪动"
  States[218]  = "蓄力特效"
  States[219]  = "【HP恢复】：HP小幅持续恢复"
  States[220]  = "【法力恢复】：MP小幅持续恢复"
  States[221]  = "【咖啡时间】：大幅提高睡眠抗性 打断抗性"
  States[222]  = "【空之女神的加护】：超大幅提高命中 大幅提高回避 敏捷 双防 额外回合概率 增加攻击次数 免疫打断状态"
  States[223]  = "【海渊之蚀】：MP小幅持续减少 小幅减少HP上限
  攻击小概率附加海渊之蚀状态"
  States[224]  = "【海渊之蚀】：MP小幅持续减少 小幅减少HP上限"
  States[225]  = "【猎杀解放】：增加3次攻击次数 固定武器"
  States[226]  = "【残虐之影】：自动战斗"
  States[227]  = "猛砸（蓄力）"
  States[228]  = "【黄金的祝福】：本场战斗物品掉率提升1.5倍"
  States[229]  = "【白银的祝福】：本场战斗获得的魂+50%"
  States[230]  = "【坚守之势】：中幅降低受到伤害"
  States[231]  = "【回避+25%】：小幅提高物理闪避率"
  States[232]  = "【回避+100%】：大幅提高物理闪避率"
  States[233]  = "【暴击-50%】：中幅降低暴击率"
  States[234]  = "【暴击-25%】：小幅降低暴击率"
  States[235]  = "【暴击+25%】：小幅提高暴击率"
  States[236]  = "【命中+50%】：中幅提高物理命中率"
  States[237]  = "【命中-50%】：中幅降低物理命中率"
  States[238]  = "【辉耀】：HP小幅持续减少 小幅降低物理命中率"
  States[239]  = "【辉耀开启】：固定武器"
  States[240]  = "【暴击+30%】：中幅提高暴击率"
  States[241]  = "【暴击+50%】：中幅提高暴击率"
  States[242]  = "【磨砺】：小幅提高暴击率"
  States[243]  = "【痛苦磨砺】：小幅提高暴击率 免疫磨砺"
  States[244]  = "【暴击伤害+100%】：大幅提高暴击伤害"
  States[245]  = "【暴击伤害+200%】：巨幅提高暴击伤害"
  States[246]  = "【暴击伤害+300%】：巨幅提高暴击伤害"
  States[247]  = "【暴击伤害-50%】：中幅降低暴击伤害"
  States[248]  = "【霸气】：大幅提高眩晕抗性 打断抗性 小幅提高攻击 防御 HP上限 MP上限 敏捷
  幸运 物理命中率 物理闪避率 物理反击率 提高暴击率 暴击闪避率"
  States[249]  = "暴风率"
  States[250]  = "【血癫狂】：中幅提高暴击率 物理攻击 中幅降低防御
  攻击中概率附加出血状态 HP小幅持续减少"
  States[251]  = "誓约连携"
  States[252]  = "【崩坏】：HP小幅持续减少 小幅提高受到伤害"
  States[253]  = "【灰白约定】：免疫无法战斗"
  States[254]  = "【灰白约定-伤害减免】：中幅降低受到伤害"
  States[255]  = "【灵魂超速】：中幅降低敏捷 大幅增加再次行动率"
  States[256]  = "【MP增幅】：中幅提高魔法攻击 中幅增加MP消耗率"
  States[257]  = "【狂怒】：中幅提高敏捷 攻击 防御"
  States[258]  = "休息一回合"
  States[259]  = "【狂暴一击】：中幅提高攻击 敏捷 眩晕抗性 大出血抗性
  巨幅降低击溃无防备抗性 强击溃无防备抗性"
  States[260]  = "【盲目抗性】中幅提高盲目抗性"
  States[261]  = "【沉默抗性】中幅提高沉默抗性"
  States[262]  = "【虚弱抗性】中幅提高虚弱抗性"
  States[263]  = "【睡眠抗性】中幅提高睡眠抗性"
  States[264]  = "【麻痹抗性】中幅提高麻痹抗性"
  States[265]  = "【眩晕抗性】中幅提高眩晕抗性"
  States[266]  = "【恐惧抗性】中幅提高恐惧抗性"
  States[267]  = "【寒冷抗性】中幅提高寒冷抗性"
  States[268]  = "【污染抗性】中幅提高污染抗性"
  States[269]  = "【脆弱抗性】中幅提高脆弱抗性"
  States[270]  = "【燃烧抗性】中幅提高燃烧抗性"
  States[271]  = "【发狂抗性】中幅提高发狂抗性"
  States[272]  = "【打断抗性】中幅提高打断抗性"
  States[273]  = "【出血抗性】中幅提高出血抗性"
  States[274]  = "【中毒抗性】中幅提高中毒抗性"
  States[275]  = "【即死抗性】中幅提高即死抗性"
  States[276]  = "【减速抗性】中幅提高减速抗性"
  States[278]  = "初始模式"
  States[279]  = "解放模式"
  States[281]  = "1式形态「斩铁」"
  States[282]  = "2式形态「破空」"
  States[283]  = "3式形态「贯虹」"
  States[285]  = "【快速装填】：增加4次攻击次数 固定武器"
  States[286]  = "【重蓄力】：小幅提高暴击率 固定武器"
  States[287]  = "【海渊之隐】：小幅提高暴击率 大幅提高物理闪避率"
  States[288]  = "【瞬身】：小幅提高暴击率 大幅提高物理闪避率 固定武器"
  States[289]  = "惩戒模式"
  States[290]  = "致死模式"
  States[291]  = "破坏模式"
  States[292]  = "蓄能"
  States[293]  = "连射"
  States[294]  = "蓄能射击"
  States[295]  = "buff"
  States[296]  = "【醉意】：小幅提高暴击率 小幅减少命中率沙漏使用中"
  States[297]  = "【超重蓄力】：巨幅提高攻击力 超巨幅提高暴击伤害 攻击次数-20"
  States[298]  = "【攻击次数+20】：巨幅提高攻击力 超巨幅提高暴击伤害 攻击次数+20"
  States[299]  = "沙漏使用中"
  States[300]  = "【残心】：小幅提高物理命中 物理闪避"
  States[301]  = "【暴走】：中幅提高暴击率 增加额外攻击次数 大幅减少物理魔法防御"
  States[302]  = "【咒蚀】：小幅减少HP上限 HP回复 攻击概率附加咒蚀状态"
  States[303]  = "【咒蚀】：小幅减少全属性 可叠加4次"
  States[501]  = "【碎甲】：小幅降低神圣 出血特攻 暗 炎 雷 风 冰属性 侵蚀抗性
  小幅降低物理防御"
  States[502]  = "【装填弩箭】：巨幅降低击溃无防备抗性 强击溃无防备抗性"
  States[503]  = "【狂暴 全属1.5】：中幅提高敏捷 幸运 攻击 防御"
  States[504]  = "【狂暴 全属2】：大幅提高敏捷 幸运 攻击 防御"
  States[505]  = "赞美诗"
  States[506]  = "【光荣颂】：小幅提高物理攻击 物理防御 HP小幅持续恢复"
  States[507]  = "【蓄力 敏捷0.5】：中幅降低敏捷 巨幅降低击溃无防备抗性
  强击溃无防御抗性"
  States[508]  = "【处刑准备】：HP小幅持续恢复"
  States[509]  = "【侵蚀孢子】：大幅降低愈疗能力"
  States[510]  = "【神圣抗性降低】：中幅降低神圣抗性"
  States[511]  = "【狂暴免控】：中幅提高幸运 攻击 防御
  免疫沉默 麻痹 睡眠 打断 击溃无防备 强击溃无防备 冻结 虚弱 盲目"
  States[512]  = "【咬住】：小幅降低敏捷"
  States[513]  = "【诅咒】：中幅提高受到伤害"
  States[514]  = "【易燃】：中幅降低炎属性抗性 大幅降低燃烧抗性"
  States[515]  = "【滑腻躯体】：小幅提高物理闪避率 小幅降低雷属性抗性"
  States[516]  = "引爆"
  States[517]  = "【爆燃】：大幅提高物理 炎属性 燃烧 冻伤 冻结 潮湿抗性"
  States[518]  = "【欲血症】：中幅提高暴击率 物理攻击 中幅降低防御
  攻击中概率附加出血 HP小幅持续减少"
  States[519]  = "【垫步】：巨幅提高敏捷"
  States[520]  = "【缓速】：中幅降低敏捷"
  States[521]  = "【反击姿态-稻草人】：大幅降低闪避率 大幅提高物理反击率
  巨幅降低强击溃无防备 中幅多种抗性"
  States[522]  = "【断足伤】：中幅降低敏捷 添加技能自斩双腿"
  States[523]  = "【断足】：巨幅降低敏捷 大幅降低闪避率"
  States[524]  = "【发狂（敌）】：HP小幅持续减少 中幅提高攻击 小幅提高敏捷"
  States[525]  = "【反击姿态-波克】：大幅降低闪避率 大幅提高物理反击率 物理命中率"
  States[526]  = "【反击-反伤】：大幅降低闪避率 大幅提高物理反击率"
  States[527]  = "【蓄力 敏捷0.5】：中幅降低敏捷 巨幅降低击溃无防备 强击溃无防备抗性"
  States[528]  = "【蓄力 魔法反射】：大幅提高魔法反击率 巨幅降低击溃无防备
  强击溃无防备抗性"
  States[529]  = "【蓄力 双倍物防】：大幅提高物理防御 巨幅降低击溃无防备
  强击溃无防备抗性"
  States[530]  = "【蓄力 敏捷1.5物闪1】：中幅提高敏捷 大幅提高物理闪避率
  巨幅降低击溃无防备 强击溃无防备抗性"
  States[531]  = "Reload"
  States[532]  = "【协议III】：大幅降低受到伤害"
  States[533]  = "【限制解除】：小幅提高敏捷 中幅降低物理防御 中幅提高受到伤害"
  States[534]  = "【超极速】：巨幅提高敏捷"
  States[535]  = "【限制解除】：中幅提高敏捷 中幅降低物理防御 大幅提高受到伤害"
  States[536]  = "【反射助推】：中幅提高敏捷 中幅降低物理攻击"
  States[537]  = "【脓液】：HP小幅持续减少"
  States[538]  = "【高维化】：中幅提高敏捷"
  States[539]  = "【蓄力 敏捷3】：大幅提高敏捷 巨幅降低击溃无防备 强击溃无防备抗性"
  States[540]  = "【蓄力 敏捷免疫控制】：免疫打断 沉默  击溃无防备 强击溃无防备
  冻结 麻痹 眩晕 睡眠"
  States[541]  = "【蓄力 敏捷1.5】：中幅提高敏捷 巨幅降低击溃无防备抗性
  强击溃无防备抗性"
  States[542]  = "【未解构】：大幅降低受到伤害"
  States[543]  = "技能指示马甲"
  States[544]  = "血塑之花特效马甲"
  States[545]  = "【闭叶-反伤】：大幅降低闪避率 大幅提高物理反击率"
  States[546]  = "【血罂粟之种】：小幅降低出血特攻抗性 HP上限 药理知识"
  States[548]  = "【复仇反击（格挡）】：大幅降低闪避率 大幅提高物理反击率"
  States[549]  = "【速度增加1】：小幅提高敏捷"
  States[550]  = "【速度增加2】：中幅提高敏捷"
  States[551]  = "【速度增加3】：中幅提高敏捷"
  States[552]  = "【速度增加4】：中幅提高敏捷"
  States[553]  = "【速度增加5】：中幅提高敏捷"
  States[554]  = "【速度增加6】：大幅提高敏捷"
  States[556]  = "升温"
  States[557]  = "超升温"
  States[558]  = "【暴走】：中幅提高攻击 敏捷 中幅提高眩晕 大出血抗性"
  States[559]  = "【钢铁身躯】：小幅提高敏捷 大幅提高暴击率 巨幅提高物理防御
  中幅降低受到物理伤害"
  States[560]  = "【战术指挥】：中幅提高攻击 敏捷 大幅提高物理命中率
  小幅提高物理闪避率"
  States[561]  = "【战术突击】：中幅提高暴击率 中幅提高物理命中率 中幅提高闪避率"
  States[562]  = "【装填弩炮】：巨幅降低击溃无防备抗性 强击溃无防备抗性
  中幅提高物理防御"
  States[563]  = "【潜水状态】：大幅提高闪避率 中幅降低受到伤害 小幅提高敏捷"
  States[564]  = "【狂暴 全属3免控】：巨幅提高攻击 防御 敏捷 幸运
  免疫沉默 麻痹 睡眠 眩晕 打断 击溃无防备 强击溃无防备 冻结 虚弱 盲目"
  States[565]  = "【十倍生命】：巨幅提高HP上限"
  States[566]  = "咬紧牙关（敌）："
  States[567]  = "【渴血症】：大幅提高攻防敏 禁用魔法/特技 寻求建言
  大幅降低防御 HP中幅持续减少 增加行动次数"
  States[568]  = "死之预兆："
  States[569]  = "【命中率降低50%】：中幅降低物理命中率"
  States[570]  = "【扭曲的效果】：小幅提高闪避率 暴击闪避率 防御"
  States[571]  = "【诞生的效果】：中幅降低HP MP上限"
  States[572]  = "【腐化】：小幅降低炎 雷 冰属性 魔物特攻 人形特攻 物理抗性
  HP小幅持续减少"
  States[573]  = "极夜"
  States[574]  = "【镇魂歌（敌）】：免疫无法战斗"
  States[575]  = "【神之洞悉】：中幅降低闪避率 物理命中率 暴击闪避率 暴击率"
  States[576]  = "【原罪之缚】：中幅降低敏捷 MP小幅持续减少"
  States[577]  = "【枯竭】：中幅降低敏捷 MP上限 MP小幅持续减少"
  States[578]  = "【新生】：大概率增加行动次数 MP小幅持续恢复"
  States[579]  = "【伊甸之佑】：中幅降低受到伤害"
  States[580]  = "【亵渎】：中幅提高受到伤害"
  States[581]  = "【圣洁】：中幅降低受到伤害 HP小幅持续恢复"
  States[582]  = "【罪孽】：小幅降低防御 HP小幅持续减少"
  States[583]  = "无法行动（剧情用）："
  States[584]  = "【腐蚀发狂】：HP小幅持续减少 大幅提高攻击 防御"
  States[585]  = "【渔枪连携】：大幅降低物理闪避率 小幅降低敏捷 物理防御"
  States[586]  = "【熔金之耀】：大幅提高眩晕 打断抗性 暴击率 中幅提高攻击 幸运
  HP MP小幅持续恢复"
  States[587]  = "【古铁之誓】：大幅提高眩晕 打断抗性 防御 物理反击率
  中幅提高物理命中率 HP小幅持续恢复"
  States[588]  = "【苍银之约】：大幅提高眩晕 打断抗性 魔法反射率 中幅提高敏捷
  闪避率 暴击闪避率 MP小幅持续恢复"
  States[589]  = "【深渊狂暴免控】：巨幅提高攻击 敏捷 幸运 中幅降低防御 免疫沉默 麻痹 睡眠 眩晕 打断 击溃无防备 强击溃无防备
  冻结 虚弱 盲目 HP小幅持续减少"
  States[590]  = "【深海的凝视】：即将发动强力攻击 大幅提高魔法反射 大幅提高击溃概率"
  States[591]  = "【海渊之蚀】：小幅降低HP上限 物理防御 魔法防御 MP持续减少"
  States[602]  = "【致命缠绕】：巨幅减少 敏捷 闪避率 暴击闪避 反击率 中幅减少命中"
  States[603]  = "【绽放I】：小幅降低MP上限 小幅降低物理攻击"
  States[604]  = "【绽放II】：中幅降低MP上限 中幅降低物理攻击"
  States[605]  = "【绽放III】：大幅降低MP上限 大幅降低物理攻击"
  States[606]  = "【绽放IV】：巨幅降低MP上限 巨幅降低物理攻击"
  States[607]  = "【绽放V】：巨幅降低MP上限 巨幅降低物理攻击"
  States[608]  = "【快速隐蔽】：中幅提高暴击率 巨幅提高闪避率"
  States[609]  = "【潜入阴影】：中幅提高暴击率 巨幅提高闪避率 斩腿"
  States[610]  = "【时空加速】：大幅提高敏捷"
  States[611]  = "【时空减速】：大幅减少敏捷"
  States[612]  = "【时空回溯】：受到致命伤害时将清除此状态并完全恢复"
=begin 
  States[51]  = "蓄力(超加速)：弱击溃 速度+800%"
  States[52]  = "内在潜力：MP+50% 生命再生-30%"
  States[53]  = "法拉克斯：攻击力·防御力·魔法防御+50% 速度-30%\n 保护友方角色"
  States[54]  = "日蚀：防御力·魔法防御+25% 防御效率+100%"
  States[55]  = "虚弱：不受治疗效果影响"
  States[56]  = "恐怖：回避率-100% \n解除回避状态"
  States[57]  = "暴击：暴击率+100%"
  
  States[59]  = "咬紧牙关：受到致命伤害时保留1点HP"
  States[60]  = "弱化：攻击力·防御力·MP·魔法防御·速度·幸运-50%"
  States[61]  = "脆弱：受到的伤害+50%"
  States[62]  = "加速：速度+100% 行动回数追加+100% 无法行动时解除"
  States[63]  = "减速：速度-99% 无法行动时解除"
  States[64]  = "死刑宣告：速度-85% 防御力-50% 暴击回避率-100% \n解除镇魂歌"
  States[65]  = "致命守护：暴击回避率+100%"
  States[74]  = "愤怒(1)：攻击力·防御力·速度+30%"
  States[75]  = "愤怒(2)：攻击力·防御力·速度+30%"
  States[76]  = "愤怒(3)：攻击力·防御力·速度+30%"
  States[77]  = "愤怒(梦灵)：攻击力·防御力·MP·魔法防御·速度·幸运+50%\n行动回数追加+100% 无法行动时解除"
  States[78]  = "邪气：MP再生-10%"
  States[79]  = "拉莱耶的咒缚：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运-50%\n 容易被击溃"

  States[80]  = "1D1：无事发生"
  States[81]  = "1D2：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运+100%"
  States[82]  = "1D3：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运+200%"
  States[83]  = "1D4：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运+300%"
  States[84]  = "1D5：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运+400%"
  States[85]  = "1D6：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运+500%"
  States[86]  = "妨害：HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运-99%\n 解除大部分增益状态"
  States[95]  = "逆鳞：已达到最大蓄力"
  States[113]  = "高机动：速度+800% 行动回数追加+300%"
  States[116]  = "高机动：速度+100% 行动回数追加+100%"
  States[117]  = "黑猫华尔兹：速度+100% 行动回数追加+100% 回避率+100%"
  States[118]  = "触手守护：免疫击溃 根据防御效率减免伤害 防御效率+800%\n暴击回避率·反击率·魔法反射率+100% 物理·魔法DMG率-99%"
  States[119]  = "三段斩：速度+100% 攻击力+50% 暴击率+20%"
  States[120]  = "究极三段斩：速度+100% 攻击力+50% 暴击率+20%"
  States[121]  = "邪龙狩猎：速度+800% 攻击力+400% 暴击率+20% 命中率+100%"
  States[122]  = "行动次数增加：行动回数追加+200%"
  States[126]  = "处刑准备：暴击·反击率+40%"
  States[127]  = "屠宰：强化电锯武器的性能"
  States[128]  = "绝对必中：攻击绝对命中"
  States[129]  = "道具封印：道具使用不可"
  States[131]  = "至邪之气：MP上限-50% MP-75% MP再生-50% MP消耗率+400%"
  States[132]  = "完美反射：反射率+100% 魔法防御+400% 魔法DMG率-100%"
  States[133]  = "灵魂盾：防御效率+800%"
  States[134]  = "反魂曲：镇魂歌无效"
  States[135]  = "蓄力（?）：防御力·魔法防御+200% 速度+50%"
  States[136]  = "蓄力(击溃不可?)：速度+50%"
  States[137]  = "炎抗性-50%"
  States[138]  = "雷抗性-50%"
  States[139]  = "光抗性-50%"
  States[140]  = "暗抗性-50%"
  States[141]  = "防御上升：防御力+25%"
  States[142]  = "往日荣光：暴击率+100% 攻击附加睡眠"
  States[143]  = "不灭之炎：生命再生-15% 受到百分比伤害-100% 恢复效果-100% 镇魂歌无效"
  States[144]  = "HP再生： 生命再生+10%"

  States[145]  = "生命：免疫死亡 根据生命数量改变攻击模式"
  States[146]  = "生命：免疫死亡 根据生命数量改变攻击模式"
  States[147]  = "生命：免疫死亡 根据生命数量改变攻击模式"

  States[149]  = "深眠：无法行动 回避率-100% 受到伤害时解除 不会自动解除"
  States[150]  = "HP恢复(小)：生命再生+3%"
  States[151]  = "完美反击：物理回避·反击率+100% 防御力+400% 物理DMG率-100%"
  States[152]  = "完美反射：反射率+100% 魔法防御+400% 魔法DMG率-100%"
  States[153]  = "内在潜力：MP+400% 暴击率+100% 行动回数追加+100%"
  States[154]  = "抗性提升：攻击力·防御力·速度+150% 反击率+50% 生命再生+5%\n 物理·魔法DMG率-50% 击溃抗性增加"

  States[155]  = "呕吐物：速度-70% 禁用回避技能"
  States[156]  = "拘束：无法行动 速度-99% 解除封印·回避·镇魂歌 受到伤害时解除"
  States[157]  = "重力：速度-99% 解除封印·回避"
  States[158]  = "冥想：无法行动 速度+200% 生命再生+5%"
  States[159]  = "瘟疫万魔殿：道具使用不可 生命流失..."
  States[160]  = "屠灭病魔的天使歌声：攻击力·MP-100% HP恢复反转"
  States[161]  = "免疫击溃"
  States[162]  = "冻疮：冰抗性-50% 魔法防御-20%"
  States[163]  = "裂伤：攻击力·MP-15% 生命再生-2%"
  States[164]  = "洛德：攻击力·MP+100% 暴击·命中率+100% "
  States[165]  = "断腿：速度-100% 防御力-99% 解除回避 "
  States[167]  = "肉壁存活"
  States[168]  = "御旗：防御力·魔法防御+100% 生命再生+30% \n无法行动时解除"
  States[169]  = "觉醒：MP+100% 攻击力-100% 暴击率+100% 行动回数追加+100% \n无法行动时解除"
  States[170]  = "防御大师：根据防御效率减免伤害 防御力·魔法防御+800% 生命再生+100%\n 速度+150% 暴击回避率+100% 免疫眩晕·断腿"
  States[171]  = "镜之障壁：反击·反射率+100% 无法行动时解除"
  States[172]  = "剑气：攻击力+10%"
  States[173]  = "剑气：攻击力+10%"
  States[174]  = "剑气：攻击力+10%"
  States[175]  = "剑气：攻击力+10%"
  States[176]  = "剑气：攻击力+10%"
  States[177]  = "剑气：攻击力+10%"
  States[178]  = "剑气：攻击力+10%"

  States[190]  = "换弹：枪火击溃"
  States[191]  = "换弹：强枪火击溃"
  States[192]  = "换弹：全弹发射"
  States[194]  = "天使的宣告：死亡倒计时"
  States[196]  = "风行者：禁用普攻 防御力-70% 物理回避率-100%"
  States[197]  = "飓凤：速度-100% 解除防御·回避"
  States[198]  = "麻痹：无法行动"
  States[199]  = "完美反射：反射率+100% 魔法防御+400% 魔法DMG率-100%"
  States[200]  = "炉心溶解：暴击率-100% HP上限-90%"
  States[201]  = "制裁罪恶的魔狼：暗抗性-100% 暴击回避率-100%"
  States[203]  = "黑之领域-决斗审判：攻击力·MP+900% 攻击绝对命中 免疫死亡"

  States[204]  = "弱点"
  States[205]  = "弱点"
  States[206]  = "弱点"
  States[207]  = "弱点"

  States[209]  = "心眼刀：回避率+100% 回避时破空斩 无法行动时解除"
  States[210]  = "心眼刀：回避率+100% 回避时破空斩 无法行动时解除"
  States[211]  = "独角兽：必中攻击无效 强化不可"
  States[212]  = "狮子：技・魔法 使用不可"
  States[213]  = "舍弃防御：速度+50% 物理抗性-100% 物理·魔法DMG率+100%"
  States[215]  = "防御力-15% 回避率-15%"
  States[216]  = "防御力-30% 回避率-30%"
  States[217]  = "防御力-50% 回避率-45%"
  States[218]  = "防御力-70% 回避率-65%"
  States[219]  = "防御力-90% 回避率-85%"
  States[220]  = "防御力-100% 回避率-100%"
  States[222]  = "海兰里斯酒：行动回数追加+100%"
  States[223]  = "死灵之书：MP消耗率-100%"
  States[224]  = "时间停止：THE WORLD"

  States[225]  = "攻击力-100%"
  States[226]  = "防御力-100%"
  States[227]  = "MP-100%"
  States[228]  = "魔法防御-100%"

  States[229]  = "强化不可 防御力-15% 回避率-15%"
  States[230]  = "强化不可 防御力-30% 回避率-30%"
  States[231]  = "强化不可 防御力-50% 回避率-45%"
  States[232]  = "强化不可 防御力-70% 回避率-65%"
  States[233]  = "强化不可 防御力-90% 回避率-85%"
  States[234]  = "强化不可 防御力-100% 回避率-100%"

  States[235]  = "道具使用不可 HP上限-15% 速度-15%"
  States[236]  = "道具使用不可 HP上限-30% 速度-30%"
  States[237]  = "道具使用不可 HP上限-50% 速度-50%"
  States[238]  = "道具使用不可 HP上限-70% 速度-70%"
  States[239]  = "道具使用不可 HP上限-90% 速度-90%"
  States[240]  = "道具使用不可 HP上限-99% 速度-99%"

  States[241]  = "防御力·魔法防御-99% 异常状态抗性-100%"
  States[242]  = "行动回数追加+0%"
  States[243]  = "行动回数追加+100%"
  States[244]  = "行动回数追加+200%"
  States[245]  = "行动回数追加+300%"
  States[246]  = "行动回数追加+400%"
  States[247]  = "行动回数追加+500%"
  States[248]  = "HP上限·MP上限·攻击力·防御力·MP·魔法防御·速度·幸运-30%\n炎·雷·暗·光·冰抗性-100% 命中·回避·暴击率·暴击回避率-30%"
  States[249]  = "回避不可 防御不可"
  
  States[251]  = "反击：反击率+100% 弱击溃"
  States[252]  = "八相：反击率+100% 弱击溃"
  States[253]  = "魔法抵抗：炎·雷·暗·光·冰·吸收抗性+50%"
  States[254]  = "解析：炎·雷·暗·光·冰·吸收抗性-50% 魔法DMG率+50%"
  States[255]  = "镜之障壁：反射率+100% 无法行动时解除"
  States[256]  = "真内在潜力：MP+100% 暴击率+100% 行动回数追加+100%"
  States[257]  = "真妖精之舞：必中攻击无效 回避率+100% 生命再生+10%"
  
  States[260]  = "魔法盾：将受到的99%HP伤害转化为MP伤害"
  States[261]  = "红之惨剧：速度+8000% 防御力+800% 受到的伤害-50% \n物理闪避率+50% 暴击率+50% 行动次数追加+100%"

  States[265]  = "猎奇戏剧：一阵恶寒..."
  States[266]  = "洛德领域：受到伤害的波动取最小值"
  States[267]  = "破灭的预兆：受到伤害的波动必定大于平均值"
  States[268]  = "幸运：受到伤害的波动必定小于平均值"
  States[269]  = "均衡：受到的伤害不会波动"
  
  States[270]  = "白兔的祝福：技能CD减半"
  States[271]  = "予定的宽限：技能无CD"
  
  States[272]  = "使受到的伤害不超过最大生命值的1% 受到攻击时有3%概率解除\n防御效率+900% 根据防御效率减免伤害"
  States[273]  = "使受到的伤害不超过最大生命值的3% 受到攻击时有3%概率解除\n防御效率+650% 根据防御效率减免伤害"
  States[274]  = "使受到的伤害不超过最大生命值的5% 受到攻击时有3%概率解除\n防御效率+400% 根据防御效率减免伤害"
  States[275]  = "使受到的伤害不超过最大生命值的10% 受到攻击时有3%概率解除\n防御效率+150% 根据防御效率减免伤害"
  States[276]  = "使受到的伤害不超过最大生命值的十二分之一"
  States[277]  = "使受到的伤害不超过最大生命值的三分之一"
  
  States[280]  = "仿生泪滴"
  States[281]  = "托普斯的立场：将非绝对必中的攻击无效"
=end
end
class Game_BattlerBase
  attr_reader :buffs
end

class Window_State < Window_Selectable
  def initialize(help_window)
    super(0,0,32,32)
     #self.x = [Graphics.width / 2 - self.width / 2,0].max
     #self.y = [Graphics.height / 2 - self.height / 2,help_window.height].max
    self.openness = 0
    @help_window = help_window
    refresh
  end
  def all_battle_members;($game_party.battle_members + $game_troop.members).select{|m| m.exist? };end
  def row_max;all_battle_members.size;end
  def col_max
    m = all_battle_members.max_by{|a| a.state_icons.size + a.buff_icons.size }
    [m.state_icons.size + m.buff_icons.size,1].max
  end
  def item_max;row_max*col_max;end
  def item_height; line_height + 2 ; end
  def item_width; line_height + 2 ; end

  def fitting_window
    self.height = item_height * row_max + standard_padding*2
    self.width = 144+(col_max*item_width) + standard_padding*2
    self.x = [Graphics.width / 2 - self.width / 2,0].max
    self.y = [Graphics.height / 2 - self.height / 2,help_window.height].max
  end
  
    def refresh
    fitting_window
    make_data
    create_contents
    all_battle_members.each_with_index{|a,i|
      draw_actor_name(a,0,i*item_height+1)
      draw_text(128,i*item_height+1,20,line_height,":")
      draw_icons(a, 144, i*item_height+1, contents.width - 144)
      draw_turns(a, 144, i*item_height+1, contents.width - 144)}
    end

  
  def draw_icons(subject, x, y, width = 96)
    icons = (subject.state_icons + subject.buff_icons)[0, width / item_width]
    icons.each_with_index {|n, i| draw_icon(n, x + item_width * i, y) }
  end
  
def draw_turns(subject, x, y, width = 96)
  last_font = contents.font.clone
  contents.font.size = 19
  contents.font.bold = true
  contents.font.color = crisis_color

  turns = (subject.state_turns + subject.buff_turns)[0, width / item_width]
  turns.each_with_index do |t, i|
    next if t <= 0
    draw_text(x + item_width * i, y, item_width, line_height, t.to_s, 2)
  end

  contents.font = last_font
end


  def item_rect(index)
    rect = Rect.new
    rect.width = item_width
    rect.height = item_height
    rect.x = index % col_max * item_width + 143
    rect.y = index / col_max * item_height
    rect
  end
  
  def update_help
    @help_window.set_text(description)
  end

  def make_data
    @data = all_battle_members.inject([]){|r,m|
      a = []
      a += m.states.select{|st| st.icon_index != 0 }
      bf = []
      m.buffs.each_with_index{|b,i| bf.push([i,b > 0 ? :up : :down]) if b != 0}
      a += bf
      a += Array.new(col_max - a.size){nil} if col_max > a.size
      r += a
    }
  end

  def description
    return "" unless @data[index]
    if @data[index].is_a?(Array)
      return StateHelp::Buffs[@data[index]]
    else
      return StateHelp::States[@data[index].id]
    end
  end
  def cursor_down(wrap = false)
    return if @data.compact.empty?
    loop do
      select((index + col_max) % item_max)
      break if @data[index]
    end
  end
  def cursor_up(wrap = false)
    return if @data.compact.empty?
    loop do
      select((index - col_max + item_max) % item_max)
      break if @data[index]
    end
  end
  def cursor_right(wrap = false)
    return if @data.compact.empty?
    loop do
      select((index + 1) % item_max)
      break if @data[index]
    end
  end
  def cursor_left(wrap = false)
    return if @data.compact.empty?
    loop do
      select((index - 1 + item_max) % item_max)
      break if @data[index]
    end
  end
  def smooth_select
    return select(0) if @data.compact.empty?
    @data.each_with_index{|d,i|
      if d
        select(i)
        return
      end
    }
  end
end


class Window_ActorCommand < Window_Command
  alias _ex_state_make_command_list make_command_list
  def make_command_list
    _ex_state_make_command_list
    add_command(["状态查看", nil], :state, true)
  end
end

class Scene_Battle < Scene_Base
  alias _ex_state_create_all_windows create_all_windows
  def create_all_windows
    _ex_state_create_all_windows
    create_state_window
  end
  alias _ex_state_create_actor_command_window create_actor_command_window
  def create_actor_command_window
    _ex_state_create_actor_command_window
    @actor_command_window.set_handler(:state, method(:command_state))
  end

  def create_state_window
    @state_window = Window_State.new(@help_window)
    @state_window.set_handler(:ok,  method(:command_state_cancel))
    @state_window.set_handler(:cancel, method(:command_state_cancel))
    @state_window.unselect
  end

  def command_state
    @actor_command_window.deactivate
    @state_window.refresh
    @state_window.open.activate.smooth_select
    @help_window.show
  end


  def command_state_cancel
    @state_window.deactivate.close.unselect
    @actor_command_window.activate
    @help_window.hide
  end
end
