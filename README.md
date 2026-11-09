# Hackni chatbota · Dny AI 2026

Materiály z workshopu Deset AI o útocích na AI aplikace a obraně proti nim.

## Co tu je

- **`prezentace/`** – slajdy z workshopu. Otevřete `hackni-chatbota.html` v prohlížeči.
- **`carodej/`** – hra Hackni čaroděje. Vymámte z čaroděje heslo přes 7 úrovní obrany.
- **`utoky_na_llm.ipynb`** – notebook s útoky na Llama 3.2 1B: přímá injekce, obfuskace, multi-turn a útok projektovaným gradientem.

## Hra

```bash
cd carodej
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt -r requirements-mac.txt   # Linux + NVIDIA: requirements-nvidia.txt
./start.sh
```

Pak otevřete adresu z terminálu. Víc v `carodej/README.md`.

## Notebook

```bash
pip install transformers torch accelerate jupyter
hf auth login
jupyter notebook utoky_na_llm.ipynb
```

Všechny útoky míří na neškodný cíl, tajné heslo v promptu.

---

[deset.ai](https://deset.ai)
