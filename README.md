# Jogos em Bash

## Forca: História do Brasil

Jogo de terminal com 20 palavras e dicas sobre a história do Brasil.

## Executar no Linux

Requer Bash 4 ou superior. Não precisa instalar dependências.

```bash
bash forca.sh
```

Digite uma letra por vez, sem acentos. Você pode cometer até seis erros.
Letras repetidas e entradas inválidas não gastam tentativas. Digite `0`
para sair. Ao terminar, digite `s` para jogar novamente.

## Cobrinha

```bash
bash cobrinha.sh
```

Execute em um terminal Linux interativo com pelo menos 48 colunas e 21
linhas. Requer Bash 4 ou superior e `stty`, normalmente disponível no Linux.
Use **WASD** ou as **setas** para mover e **Q** para sair.

A maçã aparece como `@`. Cada maçã vale **10 pontos** e aumenta a cobrinha
em um segmento. Bater na parede ou no próprio corpo encerra a partida.
Não é permitido inverter diretamente a direção. Preencher o tabuleiro
inteiro vence o jogo. A pontuação e o tamanho aparecem acima do tabuleiro.
