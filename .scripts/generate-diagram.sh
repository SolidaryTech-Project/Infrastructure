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
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # Garante limpeza do tmp mesmo em caso de erro
    trap "rm -rf '$tmp_dir'" RETURN

    # Copia os .tf sem o backend.tf — graph não precisa de estado remoto
    find "$dir" -maxdepth 1 -name "*.tf" ! -name "backend.tf" -exec cp {} "$tmp_dir/" \;

    # Reutiliza providers e módulos já baixados para não re-baixar tudo
    if [ -d "$dir/.terraform" ]; then
        cp -r "$dir/.terraform" "$tmp_dir/"
    fi
    [ -f "$dir/.terraform.lock.hcl" ] && cp "$dir/.terraform.lock.hcl" "$tmp_dir/"

    # Baixa módulos apenas se ainda não tiver
    if [ ! -d "$tmp_dir/.terraform/modules" ]; then
        echo "📥 [$dir] Baixando módulos (terraform init)..."
        terraform -chdir="$tmp_dir" init -backend=false -get=true -input=false
    fi

    echo "📊 [$dir] Gerando diagrama (terraform graph)..."
    local dot_src
    dot_src=$(terraform -chdir="$tmp_dir" graph 2>&1)

    if echo "$dot_src" | grep -q "^╷"; then
        echo "❌ [$dir] Erro no terraform graph:"
        echo "$dot_src"
        return 1
    fi

    echo "$dot_src" | dot -Tpng -o "$out"
    echo "✅ [$dir] Diagrama salvo em $out"
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
