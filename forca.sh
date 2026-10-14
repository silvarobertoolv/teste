#!/usr/bin/env bash
# Jogo da forca sobre a história do Brasil. Requer Bash 4 ou superior.

palavras=(COLONIZACAO PORTUGAL CABRAL INDIGENAS ESCRAVIDAO QUILOMBO PALMARES ZUMBI BANDEIRANTES MINERACAO INCONFIDENCIA TIRADENTES INDEPENDENCIA IMPERIO REPUBLICA ABOLICAO CANUDOS CANGACO VARGAS CONSTITUICAO)
dicas=(
  'Processo de ocupação e exploração portuguesa do território brasileiro.'
  'País europeu que colonizou o Brasil.'
  'Sobrenome do comandante da expedição portuguesa que chegou em 1500.'
  'Povos que já habitavam o território antes da chegada dos portugueses.'
  'Sistema de trabalho forçado abolido legalmente em 1888.'
  'Comunidade formada por pessoas que resistiam à escravização.'
  'Grande quilombo situado na região da atual Alagoas.'
  'Líder de Palmares, símbolo da resistência negra.'
  'Expedicionários que penetraram o interior e também escravizaram indígenas.'
  'Atividade de extração de ouro e pedras que marcou o século XVIII.'
  'Nome associado à conspiração mineira contra o domínio português em 1789.'
  'Apelido de Joaquim José da Silva Xavier.'
  'Ruptura política com Portugal proclamada em 1822.'
  'Regime político brasileiro entre 1822 e 1889.'
  'Regime proclamado no Brasil em 1889.'
  'Fim legal da escravidão, estabelecido pela Lei Áurea.'
  'Comunidade baiana destruída em uma guerra encerrada em 1897.'
  'Fenômeno de bandos armados do sertão, associado a Lampião.'
  'Sobrenome do presidente que chegou ao poder em 1930.'
  'Lei fundamental do país; a atual foi promulgada em 1988.'
)
# As respostas usam somente ASCII para funcionar em qualquer locale.

desenhar_forca() {
  local erros=$1 cabeca=' ' corpo=' ' esquerdo=' ' direito=' ' perna_e=' ' perna_d=' '
  (( erros >= 1 )) && cabeca=O
  (( erros >= 2 )) && corpo='|'
  (( erros >= 3 )) && esquerdo=/
  (( erros >= 4 )) && direito='\'
  (( erros >= 5 )) && perna_e=/
  (( erros >= 6 )) && perna_d='\'
  printf ' +---+\n |   |\n %s   |\n%s%s%s  |\n%s %s  |\n     |\n=====+\n' "$cabeca" "$esquerdo" "$corpo" "$direito" "$perna_e" "$perna_d"
}

jogar() {
  local indice=$((RANDOM % ${#palavras[@]})) palavra letra tentadas='' erros=0 exibicao completa i resposta
  palavra=${palavras[indice]}
  printf '\n=== Forca: História do Brasil ===\nDigite uma letra por vez, sem acentos. Use 0 para sair.\n'
  while :; do
    desenhar_forca "$erros"
    printf '\nDica: %s\n' "${dicas[indice]}"
    exibicao='' completa=1
    for ((i=0; i<${#palavra}; i++)); do
      letra=${palavra:i:1}
      if [[ $tentadas == *"$letra"* ]]; then
        exibicao+="$letra "
      else
        exibicao+='_ '
        completa=0
      fi
    done
    printf '\nPalavra: %s\nErros: %d/6 | Letras usadas: %s\n' "$exibicao" "$erros" "${tentadas:-nenhuma}"
    if (( completa )); then
      printf '\nVocê venceu! A palavra era %s.\n' "$palavra"
      return 0
    fi
    if (( erros >= 6 )); then
      printf '\nFim de jogo! A palavra era %s.\n' "$palavra"
      return 0
    fi
    if ! IFS= read -r -p 'Letra: ' resposta; then
      printf '\nEntrada encerrada. Até mais!\n'
      return 1
    fi
    [[ $resposta == 0 ]] && return 1
    if [[ ! $resposta =~ ^[a-zA-Z]$ ]]; then
      printf 'Digite apenas uma letra de A a Z.\n'
      continue
    fi
    letra=${resposta^^}
    if [[ $tentadas == *"$letra"* ]]; then
      printf 'Essa letra já foi usada.\n'
      continue
    fi
    tentadas+="$letra"
    [[ $palavra == *"$letra"* ]] || ((erros+=1))
  done
}

main() {
  local novamente
  while jogar; do
    if ! IFS= read -r -p 'Jogar novamente? [s/N]: ' novamente; then
      printf '\n'
      break
    fi
    [[ $novamente == s || $novamente == S ]] || break
  done
}

if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
  main
fi
