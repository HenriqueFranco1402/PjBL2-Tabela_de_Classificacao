# PjBL2 - Tabela de Classificação de Campeonato em Haskell

Projeto desenvolvido em Haskell aplicando programação funcional pura (tipos algébricos, funções de ordem superior e tratamento de erros com as mônadas `Maybe` e `Either`) para processar resultados de partidas e gerar a tabela de classificação e estatísticas de um campeonato de futebol.

## Ambiente Utilizado

- **Compilador / Ambiente:** GHC (via GHCup) / compatível com [Haskell Playground](https://play.haskell.org/).
- **Bibliotecas:** Apenas módulos da biblioteca padrão (`base`): `Data.List`, `Data.Ord`, `Data.Char`, `Data.Either` e `Text.Read`.

## Estrutura do Projeto

```text
projeto/
├── Main.hs          # Implementação completa dividida nas 3 camadas, dados de teste e main
├── Testes.hs        # Testes com resultados esperados cobrindo as 3 camadas e casos de borda
├── docs/
│   └── decisoes.md  # Justificativas das decisões de modelagem e limitações conhecidas
└── README.md        # Instruções de compilação, execução e estrutura
```

### Organização do `Main.hs`

O código está dividido em três camadas, em um único arquivo:

| Camada | Conteúdo | Principais funções |
|--------|----------|--------------------|
| **1. Tipos e Dados** | Tipos `Time`, `Resultado`, `Partida` e `Linha`; campeonato de exemplo com 8 times e 8 rodadas | `participou`, `resultadoPara`, `times`, `campeonato` |
| **2. Classificação** | Cálculo de pontos, saldo, aproveitamento, ordenação da tabela e estatísticas | `linhaDoTime`, `classificacao`, `ateRodada`, `maiorGoleada`, `mediaGols` |
| **3. Leitura** | Leitura de texto no formato CSV com `Maybe`/`Either`, validação, relatório de erros e formatação da tabela | `lerPartida`, `lerCampeonato`, `todosOsErros`, `tabelaFormatada` |

## Pré-requisitos

É necessário ter o **GHC** instalado (versão 8.10 ou superior é suficiente, pois só são usados módulos da `base`). A forma mais simples de instalar é pelo [GHCup](https://www.haskell.org/ghcup/):

```bash
ghcup install ghc
```

Para conferir se está instalado:

```bash
ghc --version
```

## Compilação

Na pasta do projeto, execute:

```bash
ghc Main.hs -o campeonato
```

Isso gera o executável `campeonato` (ou `campeonato.exe` no Windows), além de arquivos intermediários (`Main.hi` e `Main.o`).

Para compilar com avisos adicionais e otimização (opcional):

```bash
ghc -Wall -O2 Main.hs -o campeonato
```

## Execução

### Executável compilado

```bash
./campeonato          # Linux / macOS
campeonato.exe        # Windows
```

### Sem compilar (interpretado)

```bash
runghc Main.hs
```

### Pelo GHCi (modo interativo)

```bash
ghci Main.hs
```

Dentro do GHCi é possível chamar as funções individualmente:

```haskell
ghci> main
ghci> putStrLn (tabelaFormatada (classificacao campeonato))
ghci> maiorGoleada campeonato
ghci> mediaGols campeonato
ghci> lerCampeonato dadosComErros
```

### Haskell Playground

1. Acesse [play.haskell.org](https://play.haskell.org/).
2. Cole o conteúdo de `Main.hs` no editor.
3. Clique em **Run**.

## Saída esperada

Ao executar, o programa imprime quatro seções:

1. **Leitura e classificação final:** tabela completa do campeonato (posição, time, pontos, jogos, vitórias, empates, derrotas e saldo de gols).
2. **Classificação após a 3ª rodada:** a mesma tabela, considerando apenas as partidas até a rodada 3.
3. **Estatísticas do campeonato:** a maior goleada e a média de gols por partida.
4. **Tratamento de entrada com erros:** demonstração de `lerCampeonato` (que para no primeiro erro) e de `todosOsErros` (que lista todos os problemas encontrados).

Exemplo do formato da tabela:

```text
Pos | Time           | Pts |   J |   V |   E |   D |   SG
----+----------------+-----+-----+-----+-----+-----+-----
```

## Testes

O arquivo `Testes.hs` reúne os testes com os **resultados esperados** de cada camada. Cada teste compara o valor obtido com o valor esperado, no formato:

```haskell
testar "descrição do teste" (valorObtido) (valorEsperado)
```

| Função | O que testa |
|--------|-------------|
| `testesCamada1` | `resultadoPara`, `participou` e `times` (incluindo time que não jogou e lista vazia) |
| `testesCamada2` | Pontos, saldo, aproveitamento, classificação final, critérios de desempate, tabela parcial por rodada, maior goleada e média de gols |
| `testesCamada3` | `separar`, leitura de entrada válida, um teste para cada tipo de `Erro`, `todosOsErros` e `tabelaFormatada` |
| `rodarTestes` | Executa as três camadas em sequência |

O `Testes.hs` não é um programa independente: ele usa as definições do `Main.hs` (como `classificacao`, `lerCampeonato` e `dadosCampeonato`), além dos auxiliares `testar`, `partidaExemplo` e `final`.

Para executar os testes, mantenha o conteúdo do `Testes.hs` junto com o do `Main.hs` (por exemplo, colado ao final do mesmo arquivo, o que também funciona no Haskell Playground) e chame `rodarTestes` no `main`:

```haskell
main :: IO ()
main = do
  -- ... demonstração existente ...
  rodarTestes
```

Em seguida, execute normalmente com `runghc Main.hs` ou com o executável compilado.

## Formato dos dados de entrada

As partidas são lidas de um texto, uma por linha, com campos separados por `;`:

```text
rodada; mandante; gols mandante; gols visitante; visitante
```

Exemplo:

```text
1; Flamengo; 2; 0; Fluminense
```

Regras da leitura:

- Linhas em branco e linhas iniciadas por `#` são ignoradas (comentários).
- Espaços ao redor dos campos são removidos.
- Cada erro informa o número da linha original no texto.

| Erro | Causa |
|------|-------|
| `CamposInvalidos` | Quantidade de campos diferente de 5 ou nome de time vazio |
| `NumeroInvalido` | Rodada ou placar que não é número inteiro, ou rodada menor ou igual a zero |
| `PlacarNegativo` | Gols com valor negativo |
| `MesmoTime` | Mandante e visitante iguais |
| `TimeRepetidoNaRodada` | Um time aparece mais de uma vez na mesma rodada |

## Critérios de classificação

A tabela é ordenada pelos seguintes critérios, nesta ordem:

1. Pontos (vitória = 3, empate = 1, derrota = 0)
2. Número de vitórias
3. Saldo de gols
4. Gols pró
5. Nome do time (ordem alfabética)
