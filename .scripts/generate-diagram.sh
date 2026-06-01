#!/bin/bash
# Se qualquer comando falhar, aborta o commit (não quero comitar diagrama quebrado)
set -euo pipefail

# Pasta onde os PNGs dos diagramas vão parar
OUTPUT_DIR="./docs/images"

# Garante que a pasta para salvar a imagem exista
mkdir -p "$OUTPUT_DIR"

# Cada alvo: caminho do diretório Terraform => sufixo que vai no nome do PNG
declare -A TARGETS=(
    ["Bootstrap"]="bootstrap"
    ["Environments/Development"]="dev"
    ["Environments/Staging"]="stg"
    ["Environments/Production"]="prd"
)

# Pego só o que está no stage do commit (adicionado/modificado/renomeado)
# pra descobrir quais alvos preciso de fato regerar
CHANGED=$(git diff --cached --name-only --diff-filter=ACMR || true)

gerar_diagrama() {
    local dir="$1"
    local suffix="$2"
    local out="$OUTPUT_DIR/arquitetura-aws-${suffix}.png"

    # Só baixo os módulos se ainda não tiver feito init nesse diretório.
    # Se eu mexer em módulo, basta apagar a .terraform/ que ele baixa de novo.
    if [ ! -d "$dir/.terraform" ]; then
        echo "📥 [$dir] Baixando módulos remotos (Terraform Init)..."
        # O -backend=false garante que ele NÃO mude nada no meu estado (S3/DynamoDB) remoto, só baixa o código
        terraform -chdir="$dir" init -backend=false -get=true -input=false > /dev/null
    fi

    echo "📊 [$dir] Gerando/Atualizando diagrama com Inframap..."
    # Gera o mapa e joga para o Graphviz (dot) cuspir o PNG
    inframap generate "$dir" --connections | dot -Tpng -o "$out"

    # Adiciona o novo desenho ao commit atual
    git add "$out"
    echo "✅ [$dir] Diagrama atualizado em $out"
}

# Roda em paralelo só os alvos que tiveram .tf no stage
# (commit que não toca em terraform não paga o custo)
PIDS=()
for dir in "${!TARGETS[@]}"; do
    if echo "$CHANGED" | grep -qE "^${dir}/.*\.tf$"; then
        gerar_diagrama "$dir" "${TARGETS[$dir]}" &
        PIDS+=($!)
    fi
done

# Se nada de terraform mudou, não tenho o que fazer
if [ ${#PIDS[@]} -eq 0 ]; then
    echo "ℹ️ [Pre-Commit] Nenhum .tf modificado, pulando geração de diagramas."
    exit 0
fi

# Espero todos os jobs paralelos; se algum quebrar, aborto o commit
FAIL=0
for pid in "${PIDS[@]}"; do
    wait "$pid" || FAIL=1
done
exit $FAIL
