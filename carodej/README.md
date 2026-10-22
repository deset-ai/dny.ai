# Hackni čaroděje

Jednoduchá hra na prompt injection pro workshop. Hráči chatují s čarodějem a snaží se
z něj vylákat tajné heslo. Každý hráč má pro každou úroveň **vlastní náhodné heslo**,
úrovně se odemykají postupně a každá přidává jednu obranu z přednášky.

| # | Úroveň | Model | Obrana |
|---|---|---|---|
| 1 | Učeň | Llama 3.2 3B | žádná |
| 2 | Tovaryš | 3B | zákaz v promptu |
| 3 | Mistr | 3B | zákaz v promptu · filtr výstupu (přesná shoda) |
| 4 | Strážce | 3B | zpevněný prompt · oddělení dat od pokynů · filtr výstupu (i po písmenech a pozpátku) |
| 5 | Hlídač brány | 3B | zpevněný prompt · filtr vstupu (zakázaná slova) · filtr výstupu |
| 6 | Soudce | 3B | zpevněný prompt · AI soudce vstupu · filtr výstupu · AI soudce výstupu |
| 7 | Arcimág | Llama 3.1 8B | všechno výše + oddělení dat + krátké odpovědi |

AI soudce běží na 3B modelu. Hráč u každé zablokované odpovědi vidí, která obrana zasáhla.

## Dvě varianty spuštění

Hra potřebuje jen server, který s modelem mluví přes rozhraní ve stylu OpenAI. `start.sh`
sám pozná, na čem běží, a vybere správnou variantu. Modely se v obou případech stahují
z Hugging Face.

| | **Mac (Apple Silicon M1–M4)** | **Linux / Windows WSL2 s NVIDIA** |
|---|---|---|
| Server | MLX (`mlx_lm.server`) | vLLM |
| Modely | `mlx-community/Llama-3.2-3B-Instruct-4bit`, `mlx-community/Meta-Llama-3.1-8B-Instruct-4bit` | `meta-llama/Llama-3.2-3B-Instruct`, `meta-llama/Llama-3.1-8B-Instruct` |
| Velikost ke stažení | cca 6,5 GB | cca 23 GB |
| Paměť | stačí 16 GB RAM | cca 24 GB VRAM |
| Souběh hráčů | víc hráčů naráz, ale pomaleji | víc hráčů naráz, nejrychleji |

### Varianta A: Mac

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt -r requirements-mac.txt
./start.sh
```

MLX verze modelů (`mlx-community/…`) nejsou zamčené, token není potřeba. Model 8B je pomalejší, ale běží jen na poslední úrovni, kam se dostane málokdo.

### Varianta B: Linux nebo Windows (WSL2) s kartou NVIDIA

Použijte Python 3.12 (pro nejnovější Python vLLM často nemá hotový balíček a instalace selže).

```bash
python3.12 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt -r requirements-nvidia.txt
hf auth login          # nebo: export HF_TOKEN=hf_...
./start.sh
```

Modely `meta-llama/…` jsou na Hugging Face zamčené: na stránkách
[Llama-3.2-3B-Instruct](https://huggingface.co/meta-llama/Llama-3.2-3B-Instruct) a
[Llama-3.1-8B-Instruct](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct) nejdřív
odsouhlaste licenci. Při chybě „out of memory“ snižte ve `start.sh` hodnoty
`--gpu-memory-utilization` a `--max-model-len`.

### Po spuštění

`start.sh` spustí oba modely, počká, až se stáhnou a načtou, a pak spustí hru.
V terminálu se vypíše adresa pro hráče, např. `http://192.168.1.20:8080`. Ctrl+C vypne všechno.
První spuštění udělejte **den předem na rychlém internetu**, ať se modely stáhnou.

### Jiné modely

Jiný model z Hugging Face nastavíte bez úprav kódu:

```bash
BIG_MODEL=mlx-community/Qwen2.5-3B-Instruct-4bit HUGE_MODEL=mlx-community/Qwen2.5-7B-Instruct-4bit ./start.sh
```

Na Macu musí jít o MLX verzi (`mlx-community/…`), na Linuxu o běžný model pro vLLM.

### Hodně hráčů na Macu

Aktuální `mlx-lm` zpracuje víc dotazů naráz, Mac je ale pomalejší než herní grafická karta.
Pokud se při 30+ lidech odpovědi zpomalí, snižte v `app.py` u úrovní `max_tokens`
(např. na 120) a zvyšte `MIN_SECONDS_BETWEEN_MESSAGES`.

## QR kód v prezentaci

Slajd „Hackni čaroděje“ si adresu a QR kód načte sám z `http://localhost:8080/api/board`,
pokud prezentace běží **na stejném notebooku** jako hra. Jinak v `index.html` prezentace
vyplňte `window.GAME.url` (např. `'http://192.168.1.20:8080'`).

Pokud se adresa zjistí špatně (víc síťových karet, VPN), nastavte ji ručně:

```bash
PUBLIC_URL=http://192.168.1.20:8080 ./start.sh
```

## Síť: na co si dát pozor

- Telefony hráčů musí být **ve stejné síti** jako notebook.
- Veřejné a konferenční Wi-Fi často zakazují spojení mezi zařízeními („client isolation“).
  Nejjistější je **vlastní router nebo hotspot**. Jeho jméno a heslo dejte do `WIFI` v `app.py`
  a prezentace ukáže i QR kód na Wi-Fi.
- Firewall notebooku musí povolit příchozí spojení na port **8080**.

## Zátěžový test (kolik hráčů to zvládne)

```bash
UNLOCK_ALL=1 ./start.sh        # 1. terminál: modely + hra s odemčenými úrovněmi
python loadtest.py             # 2. terminál: 40 simulovaných hráčů na 2 minuty
```

Test vypíše, jak dlouho hráči čekají na odpověď (medián, 90 % a nejhorší případ),
zvlášť pro každou úroveň, a krátký verdikt. Počet hráčů a délku změníte přes
`--players 60 --minutes 3`. Po testu hru restartujte bez `UNLOCK_ALL`.

## Zkouška bez GPU

```bash
python mock_llm.py     # v jednom terminálu: falešný model, který vždy řekne heslo
python app.py          # ve druhém: hra
```

Otevřete `http://localhost:8080`. Je hned vidět, které obrany na kterých úrovních zasahují.

## Úpravy

Všechno je v horní části `app.py` v sekci **NASTAVENÍ**:

- `LEVELS` – názvy úrovní, model, systémový prompt a zapnuté obrany.
- `WORDS` – slova, ze kterých se losují hesla.
- `FORBIDDEN_WORDS` – zakázaná slova pro filtr vstupu.
- `MODELS` – adresy modelů; názvy se berou ze `start.sh` (`BIG_MODEL` = 3B, `HUGE_MODEL` = 8B).
  Chcete-li jen 3B model, nastavte u úrovně 7 `model="big"` a ve `start.sh` smažte řádek
  s velkým modelem (a jeho kontrolu `up 8003`).
- `MIN_SECONDS_BETWEEN_MESSAGES` – ochrana proti spamu.

Stav hráčů je jen v paměti: po restartu serveru začínají všichni znovu.

Čaroděj odpovídá anglicky: Llama 3.2 nebyla na češtinu trénovaná. Hráči mu můžou psát
česky i anglicky, odpovídat bude anglicky. Ovládání hry zůstává v češtině.
Chcete-li jiný jazyk, upravte větu „Always reply in English…“ v `PERSONA` v `app.py`.
