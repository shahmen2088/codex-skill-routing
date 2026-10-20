# Routing contract

Маршрутизатор возвращает компактное решение, а не выполняет предметную работу.

```yaml
request_summary: краткая цель пользователя
route:
  primary: skill-name | null
  supporting:
    - optional-skill
topology: single | sequential | parallel | supervisor | handoff
confidence: high | medium | low
reasons:
  - связь запроса с выбранным skill
excluded:
  - skill: rejected-skill
    reason: почему он не подходит
order:
  - skill-name
constraints_preserved:
  - явный выбор пользователя
  - разрешения и границы side effects
verification:
  - наблюдаемая проверка результата
clarification: null | один вопрос, без которого маршрут существенно изменится
```

## Инварианты

- `primary` — не более одного.
- `supporting` — обычно не более двух.
- `null` допустим, если подходящего навыка нет.
- `parallel` допустим только для независимых чтений или изолированных выходов.
- Записи и внешние действия с общим состоянием выполняются последовательно.
- Низкая уверенность не маскируется числом; указывается причина и, при необходимости, один уточняющий вопрос.

