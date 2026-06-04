#!/bin/bash
set -euo pipefail

OUTPUT_DIR="./docs/images"

mkdir -p "$OUTPUT_DIR"

declare -A TARGETS=(
    ["Environments/Development"]="dev"
    ["Environments/Staging"]="stg"
    ["Environments/Production"]="prd"
)

CHANGED=$(git diff --cached --name-only --diff-filter=ACMR || true)

gerar_diagrama() {
    local dir="$1"
    local suffix="$2"
    local out="$OUTPUT_DIR/arquitetura-aws-${suffix}.png"

    # Checa módulos especificamente — .terraform pode existir sem os módulos baixados
    if [ ! -d "$dir/.terraform/modules" ]; then
        echo "📥 [$dir] Baixando módulos (terraform init)..."
        terraform -chdir="$dir" init -backend=false -get=true -input=false
    fi

    echo "📊 [$dir] Gerando diagrama com Inframap..."

    local dot_src
    dot_src=$(inframap generate "$dir" --connections 2>&1)

    # Inframap retornou grafo vazio — evita gerar PNG em branco
    if [ -z "$dot_src" ] || echo "$dot_src" | grep -qE "^digraph \{[[:space:]]*\}$"; then
        echo "⚠️  [$dir] Inframap não encontrou recursos para mapear. Diagrama ignorado."
        echo "   Output do inframap: $dot_src"
        return 1
    fi

    echo "$dot_src" | dot -Tpng -o "$out"
    echo "✅ [$dir] Diagrama atualizado em $out"
}

PIDS=()
OUTS=()
for dir in "${!TARGETS[@]}"; do
    if echo "$CHANGED" | grep -qE "^${dir}/.*\.tf$"; then
        suffix="${TARGETS[$dir]}"
        OUTS+=("$OUTPUT_DIR/arquitetura-aws-${suffix}.png")
        gerar_diagrama "$dir" "$suffix" &
        PIDS+=($!)
    fi
done

if [ ${#PIDS[@]} -eq 0 ]; then
    echo "ℹ️  [Pre-Commit] Nenhum .tf modificado, pulando geração de diagramas."
    exit 0
fi

FAIL=0
for pid in "${PIDS[@]}"; do
    wait "$pid" || FAIL=1
done

if [ $FAIL -eq 0 ]; then
    git add "${OUTS[@]}"
fi

exit $FAIL
