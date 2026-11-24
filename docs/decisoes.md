# Decisões de Modelagem e Limitações Conhecidas

## 1. Decisões de Modelagem

### Camada 1: Tipos Algébricos e Records
- **Uso de Records (`Partida` e `Linha`):** Optou-se por definir `Partida` e `Linha` como *records* com campos nomeados em vez de tuplas posicionais. Isso evita a troca acidental entre campos do mesmo tipo (como `golsMandante` e `golsVisitante` ou `gols_pro` e `gols_contra`), tornando o código autodocumentado e seguro em tempo de compilação.
- **Tipo Soma (`Resultado`):** A modelagem de `Resultado` como `Vitoria | Empate | Derrota` fecha o domínio de resultados possíveis, eliminando representações frágeis baseadas em `String` ou `Int` e permitindo verificação exaustiva de padrões pelo compilador (`-Wall`).
- **Tipo `Maybe` em `resultadoPara`:** Como um time pode não ter participado de uma partida específica, o retorno `Maybe Resultado` força quem consome a função a tratar explicitamente a ausência de resultado (`Nothing`), evitando funções parciais.
- **Campeonato de Teste:** Foi modelado um campeonato com 8 times e 8 rodadas (32 partidas), contemplando empate em `0 x 0` (`Vasco 0 x 0 Gremio` na 2ª rodada), goleada com diferença superior a 3 gols (`Coritiba 1 x 8 Athletico` na 1ª rodada) e empate final em pontos e vitórias (`Athletico` e `Chapecoense`, ambos com 11 pontos e 3 vitórias, desempatados pelo saldo de gols).

### Camada 2: Funções de Ordem Superior e Totalidade
- **Acumulação com `foldl` em `linhaDoTime`:** A construção da `Linha` de cada time foi feita filtrando suas partidas (`filter (participou t)`) e aplicando uma dobra à esquerda (`foldl`) a partir de uma linha zerada. Como a lista de partidas de um campeonato é finita e cada partida é processada estritamente para somar contadores associativos/comutativos, `foldl` expressa de forma natural o acúmulo sequencial rodada a rodada.
- **Composição de Critérios de Desempate (`Monoid Ordering`):** Em vez de encadear múltiplas chamadas de ordenação, utilizou-se `sortBy` com um único comparador composto pelo operador `<>` (`comparing (Down . pontosLinha) <> comparing (Down . vitorias) <> comparing (Down . saldo) <> comparing (Down . gols_pro) <> comparing time`). Isso garante estabilidade e clareza na hierarquia de desempate: Pontos > Vitórias > Saldo de Gols > Gols Pró > Ordem Alfabética.
- **Segurança contra Listas Vazias:** Funções como `maiorGoleada` e `mediaGols` fazem casamento de padrão explícito para `[]` retornando `Nothing`, evitando exceções em tempo de execução causadas por funções parciais como `maximumBy` ou divisão por zero.
- **Conversão Numérica Explícita:** Em `aproveitamento` e `mediaGols`, utilizou-se `fromIntegral` para converter valores `Int` em `Double` antes da divisão fracionária (`/`), além de tratar `jogos == 0` retornando `0`.

### Camada 3: Leitura, Validação e Mônadas
- **Parsing Puro com `foldr` (`separar`):** A quebra de campos por `;` foi implementada com `foldr`, preservando campos vazios entre delimitadores consecutivos (ex.: `"1;;2;1;TimeB"`) para que sejam devidamente capturados como `CamposInvalidos`.
- **Encadeamento Monádico com `Either` e `Maybe`:** Em `lerPartida`, o bloco `do` na mônada `Either` permite interromper a validação no primeiro campo inválido sem aninhamento de `case`. A conversão numérica usa `readMaybe` combinado com `maybe` e o operador functor `<$>` (`(+ 0) <$> readMaybe (trim txt)`), eliminando qualquer risco de exceção de parsing (`Prelude.read: no parse`).
- **Coleta Completa de Erros (`todosOsErros`):** Enquanto `lerCampeonato` usa `traverse` para falhar rapidamente no primeiro erro (`fail-fast`), `todosOsErros` utiliza `map` junto com `lefts` e `rights` (de `Data.Either`) para reportar todos os erros sintáticos/semânticos de linha e, sobre as partidas válidas, verificar inconsistências de rodada (`TimeRepetidoNaRodada`).
- **Separação entre Núcleo Puro e `IO`:** Toda a lógica de domínio, cálculo e parsing é pura. Apenas `main` realiza `IO`, lendo os dados embutidos em `String` para compatibilidade total com ambientes sem entrada padrão (`play.haskell.org`).

---

## 2. Limitações Conhecidas

1. **Prioridade de Erro na Mesma Linha:** Em `lerPartida`, os campos numéricos (`rodada`, `golsMandante`, `golsVisitante`) são validados antes dos nomes dos times (`mandante` e `visitante`). Se uma mesma linha contiver simultaneamente um placar não numérico e times iguais, apenas o primeiro erro encontrado na sequência do bloco `do` (`NumeroInvalido`) será reportado.
2. **Granularidade de `TimeRepetidoNaRodada`:** Quando um mesmo time é escalado mais de uma vez na mesma rodada (ou múltiplos times repetem na mesma rodada), `errosRodada` emite um único construtor `TimeRepetidoNaRodada r` identificando o número da rodada, sem apontar o nome específico do time duplicado ou o número exato da linha.
3. **Sensibilidade a Maiúsculas/Minúsculas nos Nomes dos Times:** A comparação de times (`m == v` e `participou`) diferencia maiúsculas de minúsculas e acentuação (ex.: `"Coritiba"` e `"coritiba"` são tratados como equipes distintas).
4. **Entrada via Texto Embutido:** Para garantir execução determinística no playground online (onde `getLine` falha com EOF), os dados do campeonato residem diretamente no código-fonte (`dadosCampeonato`), exigindo recompilação caso novos jogos sejam inseridos manualmente.
