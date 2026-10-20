---
name: codex-skill-routing
description: "Маршрутизация библиотеки Agent Skills для Codex и OpenCode: выбрать минимальный набор навыков, определить порядок или параллельность, разрешить конфликты и проверить качество активации. Использовать для настройки или аудита системы навыков, а не вместо точного предметного skill."
license: MIT
metadata:
  opencode/slash: "true"
---

# Codex Skill Routing

1. Для точного одиночного совпадения использовать нативный выбор навыка и не добавлять отдельный routing hop.
2. При неоднозначности применить `skill-router`: выбрать один основной и не более двух вспомогательных навыков.
3. Для составной задачи применить `workflow-router` и выбрать single, sequential, parallel, supervisor или handoff topology.
4. При несовместимых указаниях применить `skill-conflict-resolver`; пользовательский выбор, безопасность и границы разрешений имеют приоритет.
5. Для изменений metadata или каталога применить `routing-evaluator` и прогнать direct, indirect, follow-up, negative и boundary cases.
6. Полные тела навыков и references загружать только после shortlist. Отсутствие подходящего навыка — допустимый результат.

Формат решения описан в [`references/routing-contract.md`](references/routing-contract.md).

