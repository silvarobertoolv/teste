#!/usr/bin/env bash
# Cobrinha para terminais Linux. Requer Bash 4+ e stty.

largura=30
altura=15
intervalo=0.15

ocupa() {
  local i
  for ((i=0; i<${#xs[@]}; i++)); do
    [[ ${xs[i]} == "$1" && ${ys[i]} == "$2" ]] && return 0
  done
  return 1
}

sortear_maca() {
  (( ${#xs[@]} >= largura * altura )) && return 1
  while :; do
    maca_x=$((RANDOM % largura + 1))
    maca_y=$((RANDOM % altura + 1))
    ocupa "$maca_x" "$maca_y" || return 0
  done
}

iniciar() {
  xs=(5 4 3)
  ys=(8 8 8)
  dx=1 dy=0 pontos=0 resultado=''
  sortear_maca
}

mudar_direcao() {
  case "$1" in
    w|W|A) ((dy == 0)) && { dx=0; dy=-1; } ;;
    s|S|B) ((dy == 0)) && { dx=0; dy=1; } ;;
    a|D) ((dx == 0)) && { dx=-1; dy=0; } ;;
    d|C) ((dx == 0)) && { dx=1; dy=0; } ;;
  esac
  return 0
}

avancar() {
  local nx=$((xs[0] + dx)) ny=$((ys[0] + dy)) comer=0 limite i
  if (( nx < 1 || nx > largura || ny < 1 || ny > altura )); then
    resultado='Você bateu na parede!'
    return 1
  fi
  (( nx == maca_x && ny == maca_y )) && comer=1
  limite=${#xs[@]}
  # A cauda sai desta casa no mesmo movimento, exceto ao comer.
  (( comer )) || ((limite-=1))
  for ((i=0; i<limite; i++)); do
    if (( xs[i] == nx && ys[i] == ny )); then
      resultado='Você bateu no próprio corpo!'
      return 1
    fi
  done
  xs=("$nx" "${xs[@]}")
  ys=("$ny" "${ys[@]}")
  if (( comer )); then
    ((pontos+=10))
    if ! sortear_maca; then
      resultado='Você venceu: preencheu todo o tabuleiro!'
      return 1
    fi
  else
    unset 'xs[${#xs[@]}-1]' 'ys[${#ys[@]}-1]'
  fi
  return 0
}

desenhar() {
  local x y i linha borda='' quadro='' celula
  for ((x=0; x<largura+2; x++)); do borda+='#'; done
  quadro+="Cobrinha | Pontos: $pontos | Tamanho: ${#xs[@]}"$'\033[K\n'
  quadro+='WASD ou setas: mover | Q: sair'$'\033[K\n'
  quadro+="$borda"$'\033[K\n'
  for ((y=1; y<=altura; y++)); do
    linha='#'
    for ((x=1; x<=largura; x++)); do
      celula=' '
      ((x == maca_x && y == maca_y)) && celula='@'
      for ((i=0; i<${#xs[@]}; i++)); do
        if ((xs[i] == x && ys[i] == y)); then
          celula=o
          ((i == 0)) && celula=O
          break
        fi
      done
      linha+="$celula"
    done
    quadro+="$linha#"$'\033[K\n'
  done
  quadro+="$borda"$'\033[K\n'
  quadro+='Maçã: @ | Cabeça: O | Corpo: o'$'\033[K'
  printf '\033[H%s' "$quadro"
}

restaurar_terminal() {
  [[ -n ${terminal_original:-} ]] && stty "$terminal_original"
  printf '\033[?25h\033[?1049l'
}

main() {
  local tecla sequencia dimensoes linhas colunas
  if [[ ! -t 0 || ! -t 1 ]]; then
    printf 'Execute em um terminal interativo: bash cobrinha.sh\n' >&2
    return 1
  fi
  if ! command -v stty >/dev/null; then
    printf 'O comando stty é necessário para jogar.\n' >&2
    return 1
  fi
  dimensoes=$(stty size) || return 1
  read -r linhas colunas <<< "$dimensoes"
  if ((linhas < altura + 6 || colunas < 48)); then
    printf 'Aumente o terminal para pelo menos 48 colunas e %d linhas.\n' "$((altura + 6))" >&2
    return 1
  fi
  terminal_original=$(stty -g) || return 1
  trap restaurar_terminal EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM HUP
  stty -echo -icanon min 1 time 0 || return 1
  printf '\033[?1049h\033[?25l\033[2J'
  iniciar
  desenhar
  while :; do
    tecla=''
    IFS= read -rsn1 -t "$intervalo" tecla || :
    if [[ $tecla == $'\033' ]]; then
      sequencia=''
      IFS= read -rsn2 -t 0.05 sequencia || :
      case "$sequencia" in
        '[A'|'OA') tecla=A ;;
        '[B'|'OB') tecla=B ;;
        '[C'|'OC') tecla=C ;;
        '[D'|'OD') tecla=D ;;
        *) tecla='' ;;
      esac
    fi
    case "$tecla" in q|Q) resultado='Partida encerrada.'; break ;; esac
    mudar_direcao "$tecla"
    if ! avancar; then desenhar; break; fi
    desenhar
  done
  printf '\n%s Pontuação final: %d.\nPressione Enter para sair.' "$resultado" "$pontos"
  IFS= read -r || :
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  main
fi
