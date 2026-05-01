#!/bin/bash

source "${BASH_TO_REQUIRE}"

if [ $# -lt 1 ]; then
  echo -e "Uso: $0 <START> [END=HEAD]"
  exit 1
fi

start_revision=$1

if [ $# -gt 1 ]; then
  end_revision=$2
else
  end_revision=HEAD
fi

function revisions_to_test {
  git rev-list "$start_revision..$end_revision" | tac
}

function test_revision {
  log_file="$(test_revision_log_path "$1")"
  cat /dev/null > $log_file
  echo "Construindo aplicação da revisão \"$1\" em \"$(workspace_path)\"..."
  build_workspace "$1" 2>&1 >> $log_file
  echo "Resetando base de dados de teste..."
  (cd "$(workspace_path)"; bundle exec rake db:reset db:migrate RAIL_ENV=test 2>&1 >> $log_file )
  echo "Testando..."
  set +e
  (cd "$(workspace_path)"; bundle exec rake test 2>&1 >> $log_file )
  set -e
  echo "Teste concluído"
  test_revision_result "$1" > "$(test_revision_result_path "$1")"
}

# Diretório raiz de cache
function test_revisions_cache {
  echo ~/.cache/test-git-revisions
}

# Caminho para o arquivo que armazena o resultado do teste.
function test_revision_result_path {
  echo "$(test_revisions_cache)/results/$1"
}

# Caminho para o arquivo que armazena o log do teste.
function test_revision_log_path {
  echo "$(test_revisions_cache)/logs/$1"
}

# Quantidade de falhas de uma revisão. 0 indica sem falhas.
function test_revision_failures {
  set +e
  failures=$(grep -o '[0-9]\+\s*failures,' "$(test_revision_log_path "$1")" | grep -o '^[0-9]\+')
  result=$?
  set -e
  if [ $result -eq 0 ]; then
    echo $failures
  else
    echo "Não foi possível verificar a quantidade de falhas do teste. Provavelmente isto " \
      "se deve a uma falha deste script."
    exit 2
  fi
}

# Extrai um atributo do resultado do teste (runs, assertions, failures, errors, ou skips)
# Retorna com falha se não conseguir extrair.
function test_revision_attribute_count {
  # $1: revisão
  # $2: atributo
  set +e
  failures=$(grep -o '[0-9]\+\s*'$2 "$(test_revision_log_path "$1")" | grep -o '^[0-9]\+')
  result=$?
  set -e
  if [ $result -eq 0 ]; then
    echo $failures
  else
    echo "Não foi possível verificar a quantidade do atributo \"$2\" do teste. Provavelmente isto " \
      "se deve a uma falha deste script."
    exit 2
  fi
}

function test_revision_result {
  failures=$(test_revision_attribute_count "$1" 'failures')
  errors=$(test_revision_attribute_count "$1" 'errors')
  if [ $failures -eq 0 ] && [ $errors -eq 0 ]; then
    echo '0'
  else
    echo '1'
  fi
}

# Diretório de cópia da aplicação para teste
function workspace_path {
  echo '/tmp/test-git-revisions'
}

# Arquivos não versionados (Ex.: config/database.yml)
function local_files {
  git clean -ndX | sed 's/^Would remove /\//g' | grep -v '/\(log/\|tmp/\)' | \
    grep -v '^/\(nbproject/\|\.project\|public/system\)' | \
    grep -v '\(.sqlite3\)$'
}

# Copia o código da revisão para o workspace.
function build_workspace {
  rm -rf "$(workspace_path)"
  mkdir -p "$(workspace_path)"
  git archive "$1" | tar -x -C "$(workspace_path)"
  local_files | xargs -IARQ cp -vr ".ARQ" "$(workspace_path)ARQ"
}

function check_revision {
  echo "-----------------------------------"
  revision_label "$1"
  if [ ! -f "$(test_revision_result_path "$1")" ]; then
    echo "Revisão ainda não testada"
    test_revision "$1"
  else
    echo "Revisão já testada anteriormente"
  fi
  echo "Caminho do log: $(test_revision_log_path "$1")"
  echo "Caminho do resultado: $(test_revision_result_path "$1")"
  result=$(cat "$(test_revision_result_path "$1")")
  if [ $result -eq 0 ]; then
    echo "Teste ok"
  else
    echo "Teste falhou"
    exit 1
  fi
}

function revision_label {
  git --no-pager log --pretty=oneline $1~1..$1
}

mkdir -p "$(test_revisions_cache)/results"
mkdir -p "$(test_revisions_cache)/logs"

echo "Start revision: $start_revision"
echo "End revision: $end_revision"

for rev in $(revisions_to_test); do
  check_revision $rev
done
