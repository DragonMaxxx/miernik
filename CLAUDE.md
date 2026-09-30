# miernik

Repo: `DragonMaxxx/miernik` (GitHub). Cel: projekt w Godot 4 z agentem do code review na pull requestach.

## Stan na 2026-09-30

- Repo jest puste: brak kodu, brak `project.godot`, brak `.github/`.
- Nic nie zostało jeszcze zbudowane. Poniższy plan NIE jest zatwierdzony przez właściciela.
- Pracę prowadzimy na branchu `claude/friendly-lovelace-tbx807`. PR-ów nie zakładamy bez wyraźnej prośby.

## Proponowany plan

1. Szkielet projektu Godot 4: `project.godot`, `.gitignore` dla Godota, `README.md`.
2. Workflow GitHub Actions z agentem code review (`anthropics/claude-code-action`) uruchamianym na PR-ach, z promptem pod GDScript (sygnały, `@onready`, wycieki węzłów, typowanie, `_process` vs `_physics_process`).
3. Konwencje projektu dopisać tutaj, w `CLAUDE.md`.
4. Wymagany sekret repo: `ANTHROPIC_API_KEY` (lub token OAuth). Ustawia go właściciel w Settings → Secrets.

## Otwarte pytania do właściciela

- Jaka to gra/aplikacja (2D czy 3D)?
- GDScript czy C#?
- Agent ma komentować PR-y automatycznie, czy na komendę (np. `@claude review`)?

## Jak wznowić na innym urządzeniu

- Ta sama sesja w chmurze: https://claude.ai/code/session_017T9SmfKcht2uN2LSc2ns2K
- Albo nowa sesja na branchu `claude/friendly-lovelace-tbx807` i polecenie: "przeczytaj CLAUDE.md i kontynuuj".
