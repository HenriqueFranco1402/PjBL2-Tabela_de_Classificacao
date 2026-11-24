# PjBL2 - Tabela de Classificação de Campeonato em Haskell

Projeto desenvolvido em Haskell aplicando programação funcional pura (tipos algébricos, funções de ordem superior e tratamento de erros com as mônadas `Maybe` e `Either`) para processar resultados de partidas e gerar a tabela de classificação e estatísticas de um campeonato de futebol.

## Ambiente Utilizado

- **Compilador / Ambiente:** GHC (via GHCup) / compatível com [Haskell Playground](https://play.haskell.org/).
- **Bibliotecas:** Apenas módulos da biblioteca padrão (`base`): `Data.List`, `Data.Ord`, `Data.Char`, `Data.Either` e `Text.Read`.

## Estrutura do Projeto

```text
projeto/
├── Main.hs          # Implementação completa dividida nas 3 camadas, dados de teste e main
├── Testes.hs        # Suíte de testes automatizados cobrindo as 3 camadas e casos de borda
├── docs/
│   └── decisoes.md  # Justificativas das decisões de modelagem e limitações conhecidas
└── README.md        # Instruções de compilação, execução e estrutura
