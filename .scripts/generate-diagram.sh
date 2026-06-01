#!/bin/bash
# Se qualquer comando falhar, aborta o commit (não quero comitar diagrama quebrado)
set -euo pipefail

# Pasta onde os PNGs dos diagramas vão parar
OUTPUT_DIR="./docs/images"

# Garante que a pasta para salvar a imagem exista
mkdir -p "$OUTPUT_DIR"

# Meus ambientes e o sufixo que vai no nome do arquivo de cada um
ENVIRONMENTS=("Development" "Staging" "Production")
declare -A SUFFIX=( ["Development"]="dev" ["Staging"]="stg" ["Production"]="prd" )

# Pego só o que está no stage do commit (adicionado/modificado/renomeado)
# pra descobrir quais ambientes preciso de fato regerar
CHANGED=$(git diff --cached --name-only --diff-filter=ACMR || true)

gerar_diagrama() {
    local env="$1"
    local out="$OUTPUT_DIR/arquitetura-aws-${SUFFIX[$env]}.png"

    # Só baixo os módulos se ainda não tiver feito init nesse ambiente.
    # Se eu mexer em módulo, basta apagar a .terraform/ que ele baixa de novo.
    if [ ! -d "$env/.terraform" ]; then
        echo "📥 [$env] Baixando módulos remotos (Terraform Init)..."
        # O -backend=false garante que ele NÃO mude nada no meu estado (S3/DynamoDB) remoto, só baixa o código
        terraform -chdir="$env" init -backend=false -get=true -input=false > /dev/null
    fi

    echo "📊 [$env] Gerando/Atualizando diagrama com Inframap..."
    # Gera o mapa e joga para o Graphviz (dot) cuspir o PNG
    inframap generate "$env" --connections | dot -Tpng -o "$out"

    # Adiciona o novo desenho ao commit atual
    git add "$out"
    echo "✅ [$env] Diagrama atualizado em $out"
}

# Roda em paralelo só os ambientes que tiveram .tf no stage
# (commit que não toca em terraform não paga o custo)
PIDS=()
for env in "${ENVIRONMENTS[@]}"; do
    if echo "$CHANGED" | grep -q "^$env/.*\.tf$"; then
        gerar_diagrama "$env" &
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
