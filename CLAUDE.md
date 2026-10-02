# CLAUDE.md

Autor: Mateusz Bartoszewicz

Plik kontekstowy dla Claude Code. Czytaj go na początku każdej sesji. Jeśli coś jest oznaczone jako **DO USTALENIA**, nie zgaduj: zapytaj albo zaproponuj opcje i poczekaj na decyzję.

---

## 1. Projekt

Gra 2D top-down w stylu Stardew Valley, ale **oryginalna** (nie klon). Spokojna pętla dzień → praca → zysk → rozwój, pixel art.

- Tytuł roboczy: **DO USTALENIA**
- Kierunek/świat (np. stacja kolejowa, latarnia, zaczarowany las, stacja kosmiczna, warsztat naprawczy): **DO USTALENIA**
- "Twist" mechaniczny, którego nie ma w Stardew: **DO USTALENIA**
- Zespół: 2 osoby. Mateusz (C/C++, systemy) i kolega (GDScript). Podział ról po systemach: **DO USTALENIA**
- Etap: przygotowanie i prototyp. Najpierw mikrogra na naukę silnika, potem projekt właściwy.

## 2. Status decyzji

**Ustalone (przez Mateusza):**
- Silnik: Godot.
- Zaczynamy od 2D, w przyszłości możliwe 3D (być może Unreal).
- Gra w stylu Stardew, ale oryginalna.
- Praca z kolegą, który pisze w GDScripcie.

**Rekomendowane (do potwierdzenia przez Mateusza):**
- GDScript ze statycznymi typami jako język bazowy.
- C++ (GDExtension) tylko punktowo, gdy profiler wskaże wąskie gardło.
- C# nie używamy (osobny runtime i edytor dla całego zespołu).
- Stan gry w danych, systemy jako autoloady, komunikacja sygnałami.

**Otwarte:**
- Dokładna wersja Godota (przypiąć jedną dla obu osób i wpisać niżej).
- Wybór kierunku gry i roli kolegi.
- Ustalenia między współpracownikami (podział przychodów, prawa do assetów, kto decyduje o designie).

Wersja Godota: **DO USTALENIA** (wymagana stabilna 4.x z `TileMapLayer`)

## 3. Zasady pracy dla Claude Code

- Komunikacja po polsku, technicznie precyzyjnie. Identyfikatory i nazwy w kodzie po angielsku.
- Odpowiedzi bezpośrednie i uporządkowane. Konkretne rozwiązania zamiast długich wyjaśnień.
- Na końcu większych odpowiedzi dodaj krótką sekcję **Autokrytyka** (co jest niepewne, czego nie sprawdzono, jakie są ryzyka).
- Każdy plik kodu z nagłówkiem `# Autor: Mateusz Bartoszewicz` (bez nazwy projektu czy firmy jako autora).
- Pracuj małymi krokami, z których każdy da się uruchomić i sprawdzić.
- Nie zgaduj API Godota. Sprawdzaj w dokumentacji dla wersji użytej w projekcie, bo API zmienia się między wydaniami.
- Nie dodawaj zależności, pluginów ani zmian w ustawieniach projektu bez zapytania.
- Preferuj sprawdzone, stabilne rozwiązania zamiast najnowszych.
- Jeśli coś jest niepewne albo nieprzetestowane, powiedz to wprost.
- Nie rozszerzaj zakresu. Nowe pomysły trafiają do backlogu, a nie do bieżącej pracy.

## 4. Stack

| Obszar | Wybór |
|---|---|
| Silnik | Godot 4.x, jedna przypięta wersja |
| Język | GDScript (typowany); C++ przez GDExtension punktowo |
| Repo | Git + GitHub, Git LFS dla binarnych assetów |
| Grafika | Aseprite lub LibreSprite; jeden rozmiar kafelka i jedna paleta ustalone na początku |
| Audio | Robi Mateusz; eksport `.ogg` |
| Zadania | GitHub Issues + Projects |
| Komunikacja | Discord |
| Dystrybucja | itch.io do playtestów, Steam później |
| CI | Opcjonalnie (GitHub Actions, eksport headless), dopiero gdy będzie co budować |

## 5. Struktura repo

```
/assets/{art,audio,fonts}
/data/{items,crops,recipes}     # Resources .tres
/scenes/{player,world,ui,npc}
/scripts/{core,systems,ui}
/docs/gdd.md
.gitattributes  .gitignore  README.md  CLAUDE.md
```

W `.gitignore` obowiązkowo `.godot/`. W `.gitattributes` Git LFS dla `*.png`, `*.aseprite`, `*.ogg`, `*.wav`.

## 6. Architektura

Warstwy: **dane → systemy → widok**.

- **Stan gry trzymamy w danych, nie w węzłach.** Pole z uprawą to wpis w słowniku (`Vector2i → stan`), nie osobny węzeł.
- **Systemy** (zegar, uprawy, zapis, inwentarz) jako autoloady. Autoloadów ma być mało (zegar, zapis, zdarzenia, system upraw).
- **Komunikacja przez sygnały.** Widok słucha systemów, systemy słuchają zegara. Brak twardych referencji w górę.
- **Data-driven.** Przedmioty, rośliny, receptury jako `Resource` (`.tres`). Nowa roślina to nowy plik, a nie nowy kod.
- **Czas gry oddzielony od czasu rzeczywistego.** Zegar gry emituje `day_changed`, a reszta tylko reaguje.
- **Zapis** to serializacja modelu (JSON z polem `version`), nie drzewa scen.
- Ruch i kolizje w `_physics_process`, logika zależna od czasu mnożona przez `delta`.
- Maszyny stanów dla gracza, NPC i UI zamiast łańcuchów `if`.
- Wejście przez `InputMap` (akcje), nie sztywne klawisze.

### Granica GDScript / C++

Domyślnie wszystko w GDScripcie. C++ (GDExtension) dopiero, gdy profiler pokaże konkretny system jako wąskie gardło (np. symulacja tysięcy obiektów, pathfinding, generowanie świata). Klasa z C++ ma wyglądać dla GDScriptu jak zwykły typ Godota, z udokumentowanym API w `docs/`. Wersje `godot-cpp` i silnika muszą się zgadzać.

## 7. Konwencje kodu (GDScript)

- Statyczne typy wszędzie: `var hp: int = 10`, `func grow(days: int) -> void`.
- `snake_case` dla zmiennych i funkcji, `PascalCase` dla `class_name`, `UPPER_CASE` dla stałych.
- Kolejność w pliku: `class_name`, `extends`, sygnały, stałe, `@export`, zmienne, `_ready`, metody publiczne, metody prywatne (`_nazwa`).
- Jeden skrypt, jedna odpowiedzialność. Krótkie, niezależne systemy łatwiej później przepisać na C++.
- Komentarze tłumaczą "dlaczego", a nie "co".
- Ustalony wspólny styl obowiązuje obie osoby. Jeśli ustalicie narzędzie do lintowania, wpisz je tutaj: **DO USTALENIA**

## 8. Git i współpraca

- `main` zawsze się uruchamia.
- Krótkie branche `feat/...`, `fix/...`, PR do `main`, druga osoba zerka i scala.
- **Jedną scenę `.tscn` edytuje jedna osoba naraz.** Pliki scen źle się scalają.
- Sceny dziel na małe podsceny (gracz, uprawa, UI) zamiast jednej wielkiej sceny świata.
- Binarki (grafika, dźwięk) tylko przez LFS. Skompilowanych bibliotek GDExtension nie commitujemy do historii (CI albo lokalny build).
- Zakres: nowa funkcja najpierw do backlogu.

## 9. Komendy

Nazwa binarki Godota zależy od instalacji (`godot`, `godot4` lub ścieżka do pliku). Poniższe przykłady zweryfikuj flagami `--help` w używanej wersji:

```bash
# Szybki test, czy projekt się ładuje (headless)
godot --headless --path . --quit

# Uruchomienie projektu
godot --path .
```

Komendy eksportu i testów: **DO USTALENIA** (zależą od wybranych narzędzi).

## 10. Kolejność prac (plan)

0. Mikrogra (Pong lub Flappy Bird), cały cykl do końca, żeby poznać silnik.
1. Szkielet projektu: struktura folderów, `.gitignore`, `.gitattributes`, przypięta wersja Godota.
2. `GameClock` (autoload): czas gry, `day_changed`, sen jako koniec dnia.
3. `CropData` (Resource) i pierwszy plik rośliny.
4. `FarmSystem` (autoload): sadzenie, podlewanie, wzrost dzienny, zbiór.
5. Widok upraw na `TileMapLayer` (kafelek = etap wzrostu).
6. Interakcja gracza z kafelkiem przed nim.
7. `SaveSystem`: zapis i wczytanie z `version`.
8. Tryb debug: przeskok dnia, dodawanie przedmiotów, teleport.
9. Dopiero potem: inwentarz, pasek narzędzi, NPC, dialogi, sklep, pory roku.

Testy ręczne po kroku 8: bez podlewania nic nie rośnie; podlanie + przeskok dnia zwiększa etap; po wymaganej liczbie podlanych dni uprawa jest dojrzała i zbiór ją usuwa; zapis → zmiana stanu → wczytanie przywraca stan; to samo po restarcie gry.

## 11. Czego unikać

- C# w projekcie.
- Logiki gry w węzłach widoku.
- Dużej architektury w mikrogrze (warstwy i autoloady dopiero przy farmie).
- Przedwczesnej optymalizacji i wczesnego C++.
- Nadużywania autoloadów i globalnego stanu.
- Dopracowywania grafiki, zanim mechanika jest sprawdzona w prototypie na klockach.
- Rozbudowy zakresu (NPC, relacje, wydarzenia) przed działającym MVP.
- Cudzych assetów bez sprawdzenia licencji.

## 12. Otwarte pytania

1. Który kierunek gry wybieramy i jaki jest twist mechaniczny?
2. Jaka jest rola kolegi poza kodem w GDScripcie i jak dzielimy systemy?
3. Jaka dokładnie wersja Godota?
4. Czy potwierdzamy GDScript jako bazę i C++ tylko punktowo?
5. Ustalenia organizacyjne: przychody, prawa do assetów, decyzje projektowe.

## 13. Zasady code review (agent w GitHub Actions)

Agent z `.github/workflows/claude-review.yml` czyta ten plik przy każdym PR i sprawdza zgodność z sekcjami 3, 6, 7, 8 i 11. Kolejność ważności: błędy i crashe > zgodność z architekturą > wydajność > czytelność.

Czego nie komentować: formatowania (to robi `gdformat`), szumu w `.tscn` (uid, offsety, `load_steps`) oraz braku decyzji oznaczonych **DO USTALENIA**. Zgłaszaj tylko kod, który taką decyzję zgaduje (np. na stałe wpisany rozmiar kafelka albo wersja Godota).

Błędy GDScript/Godot:

- Brak typów w zmiennych, parametrach i zwracanych wartościach.
- `get_node`/`$Node` w `_process`/`_physics_process` zamiast `@onready`. Zależność od kolejności dzieci (`get_child(0)`).
- Dostęp do węzła, który mógł zostać zwolniony, bez `is_instance_valid()`. `await` na sygnale węzła, który może zniknąć.
- Sygnały: podłączone wielokrotnie, brak rozłączenia przy zwalnianiu odbiorcy, literówki w nazwach sygnałów i metod (stringi).
- `free()` zamiast `queue_free()` na węźle w drzewie. `Node.new()` niedodany do drzewa i niezwolniony.
- `load()` w pętli lub `_process` zamiast `preload()`/cache. Alokacje w gorącej ścieżce.
- Nieotypowane `@export`.

Architektura (sekcja 6):

- Logika gry w węzłach widoku. Stan gry jako węzły zamiast danych.
- Twarde referencje w górę zamiast sygnałów. Nowy autoload (zgłoś jako ostrzeżenie, ma być ich mało).
- Czas gry zależny od czasu rzeczywistego zamiast od zegara gry (`day_changed`).
- Zapis serializujący drzewo scen albo bez pola `version`.
- Ruch i kolizje w `_process` zamiast `_physics_process`, brak `delta`.
- Sztywne klawisze zamiast `InputMap`. Łańcuchy `if` zamiast maszyny stanów (gracz, NPC, UI).
- Przedmioty, rośliny, receptury wpisane w kod zamiast w `Resource` (`.tres`).

Zasady projektu (sekcje 3, 8, 11):

- Nowy plik `.gd` bez nagłówka `# Autor: Mateusz Bartoszewicz`.
- C# w projekcie. Nowa zależność, plugin albo zmiana `project.godot` (renderer, rozdzielczość, wersja) bez uzasadnienia w opisie PR.
- Binarki (`*.png`, `*.aseprite`, `*.ogg`, `*.wav`) poza Git LFS. Skompilowane biblioteki GDExtension. Katalog `.godot/`. Assety bez znanej licencji.
- Zakres PR większy niż jeden krok z planu (sekcja 10). Dużej architektury w mikrogrze.

Format odpowiedzi: komentarz inline przy konkretnej linii, z poziomem ważności (błąd / ostrzeżenie / sugestia) i proponowaną poprawką. Na końcu jedno krótkie podsumowanie. Nie zatwierdzaj i nie merguj PR-ów.
