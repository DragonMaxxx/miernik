# miernik

Projekt w Godot 4 (GDScript) z agentem Claude do code review.

## Uruchomienie

Otwórz folder w Godot 4.4 lub nowszym (Import → `project.godot`) i uruchom projekt (F5).

## Code review agenta

- `.github/workflows/claude-review.yml` uruchamia review przy każdym PR (poza draftami).
- `.github/workflows/claude.yml` odpowiada na `@claude` w komentarzach do PR-ów i issue.
- Zasady review są w `CLAUDE.md`, w sekcji "Zasady code review".

### Wymagana konfiguracja

1. Zainstaluj [Claude GitHub App](https://github.com/apps/claude) na repo.
2. Dodaj sekret `ANTHROPIC_API_KEY` w Settings → Secrets and variables → Actions.
3. Pliki workflow muszą być na domyślnym branchu repo. Akcja odrzuca workflow, którego treść różni się od wersji na domyślnym branchu.
4. Na PR-ach z forków sekrety nie są dostępne, więc review tam nie zadziała.
