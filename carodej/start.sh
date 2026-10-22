#!/usr/bin/env bash
# Spustí oba modely a pak hru. Ctrl+C ukončí všechno.
#   Mac (Apple Silicon): modely běží přes MLX (mlx_lm.server)
#   Linux / WSL2 s NVIDIA: modely běží přes vLLM
# Modely se při prvním spuštění samy stáhnou z Hugging Face.
set -e
cd "$(dirname "$0")"
trap 'kill 0' EXIT

if [[ "$(uname)" == "Darwin" ]]; then
  export BIG_MODEL="${BIG_MODEL:-mlx-community/Llama-3.2-3B-Instruct-4bit}"
  export HUGE_MODEL="${HUGE_MODEL:-mlx-community/Meta-Llama-3.1-8B-Instruct-4bit}"
  echo "Mac: spouštím modely přes MLX…"
  mlx_lm.server --model "$BIG_MODEL"  --port 8002 &
  mlx_lm.server --model "$HUGE_MODEL" --port 8003 &
else
  export BIG_MODEL="${BIG_MODEL:-meta-llama/Llama-3.2-3B-Instruct}"
  export HUGE_MODEL="${HUGE_MODEL:-meta-llama/Llama-3.1-8B-Instruct}"
  echo "Linux: spouštím modely přes vLLM…"
  # Paměť GPU: dohromady pod 1.0. Při chybě "out of memory" obě čísla snižte.
  vllm serve "$BIG_MODEL"  --port 8002 --max-model-len 4096 --gpu-memory-utilization 0.30 &
  vllm serve "$HUGE_MODEL" --port 8003 --max-model-len 4096 --gpu-memory-utilization 0.60 &
fi

echo "Čekám, až se modely stáhnou a načtou (poprvé to může trvat i několik minut)…"
up() { [[ "$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$1/v1/models")" != "000" ]]; }
until up 8002 && up 8003; do sleep 3; done

python app.py
