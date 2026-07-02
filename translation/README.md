# Перевод (`.trans` проекты Translator++)

Здесь лежат исходные проекты перевода `rvdata2`-файлов игры в формате
**Translator++** (`.trans`). Сами `rvdata2` в репозиторий не входят.

> Игра: Demo **v0.49**.

## Формат

`.trans` — минифицированный JSON-проект Translator++, хранится через **git-lfs**
(см. `.gitattributes`). Коммитить в минифицированном виде (импорт 1:1). GitHub его
не рендерит — это норма, ревью ведётся в Translator++.

## Кто что переводит

Файлы у переводчиков **непересекающиеся**. Финальный импорт собирается из всех частей.

| Файл | Переводчик | Охват (`rvdata2`) |
|------|------------|-------------------|
| `supplementary.trans` | toilettrauma | Classes, Items, Weapons, Skills, States, System, … |
| `events_and_enemies.trans` | Lev Lira | CommonEvents, Enemies |
| `troops.trans` | Lev Lira | Troops |

## Готовый перевод

Собранный архив с переводом для игроков распространяется через **Releases**
репозитория, а не хранится в дереве исходников.
