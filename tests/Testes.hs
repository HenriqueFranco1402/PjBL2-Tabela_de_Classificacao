testesCamada1 :: IO ()
testesCamada1 = do
  putStrLn "--- Camada 1: tipos e consultas ---"
  testar "resultadoPara mandante (perdeu 1x8)"
         (resultadoPara "Coritiba" partidaExemplo) (Just Derrota)
  testar "resultadoPara visitante (ganhou 8x1)"
         (resultadoPara "Athletico" partidaExemplo) (Just Vitoria)
  testar "resultadoPara time que nao jogou"
         (resultadoPara "Vasco" partidaExemplo) Nothing
  testar "resultadoPara empate"
         (resultadoPara "Gremio" (Partida 2 "Vasco" 0 0 "Gremio")) (Just Empate)
  testar "participou: jogou"
         (participou "Athletico" partidaExemplo) True
  testar "participou: nao jogou"
         (participou "Vasco" partidaExemplo) False
  testar "times do campeonato (sem repeticao, em ordem alfabetica)"
         (times campeonato)
         [ "Athletico", "Chapecoense", "Corinthians", "Coritiba"
         , "Flamengo", "Fluminense", "Gremio", "Vasco" ]
  testar "times de lista vazia" (times []) []

testesCamada2 :: IO ()
testesCamada2 = do
  putStrLn "--- Camada 2: classificacao ---"
  testar "pontos por resultado"
         (map pontos [Vitoria, Empate, Derrota]) [3, 1, 0]
  testar "linhaDoTime Flamengo"
         (linhaDoTime campeonato "Flamengo")
         (Linha "Flamengo" 8 5 3 0 14 7)
  testar "linhaDoTime de time inexistente (tudo zero)"
         (linhaDoTime campeonato "Inexistente")
         (Linha "Inexistente" 0 0 0 0 0 0)
  testar "pontosLinha Flamengo (5V + 3E)"
         (pontosLinha (linhaDoTime campeonato "Flamengo")) 18
  testar "saldo Athletico (18 pro - 8 contra)"
         (saldo (linhaDoTime campeonato "Athletico")) 10
  testar "aproveitamento Flamengo (18 de 24 pontos = 75%)"
         (aproveitamento (linhaDoTime campeonato "Flamengo")) 75.0
  testar "aproveitamento de time que nao jogou"
         (aproveitamento (Linha "X" 0 0 0 0 0 0)) 0.0

  testar "classificacao final completa"
         final
         [ Linha "Flamengo"    8 5 3 0 14  7
         , Linha "Gremio"      8 4 1 3 10  9
         , Linha "Coritiba"    8 4 1 3 10 13
         , Linha "Athletico"   8 3 3 2 18  8
         , Linha "Fluminense"  8 3 3 2 10  9
         , Linha "Corinthians" 8 2 2 4  7 10
         , Linha "Chapecoense" 8 2 2 4  6 11
         , Linha "Vasco"       8 1 1 6  2 10
         ]

  -- Desempates: Gremio x Coritiba (13 pts e 4 vitorias cada) -> decide o saldo
  let g = linhaDoTime campeonato "Gremio"
      c = linhaDoTime campeonato "Coritiba"
  testar "desempate Gremio x Coritiba: mesmos pontos e vitorias"
         ((pontosLinha g, vitorias g), (pontosLinha c, vitorias c))
         ((13, 4), (13, 4))
  testar "desempate Gremio x Coritiba: saldo decide (+1 contra -3)"
         (saldo g, saldo c) (1, -3)
  testar "Gremio fica a frente do Coritiba"
         (take 3 (map time final)) ["Flamengo", "Gremio", "Coritiba"]

  -- Athletico x Fluminense (12 pts e 3 vitorias cada) -> saldo (+10 contra +1)
  testar "desempate Athletico x Fluminense: saldo decide (+10 contra +1)"
         (take 2 (drop 3 (map time final))) ["Athletico", "Fluminense"]
  -- Corinthians x Chapecoense (8 pts e 2 vitorias cada) -> saldo (-3 contra -5)
  testar "desempate Corinthians x Chapecoense: saldo decide (-3 contra -5)"
         (take 2 (drop 5 (map time final))) ["Corinthians", "Chapecoense"]

  -- Tabela no meio do campeonato
  let ate3 = classificacao (ateRodada 3 campeonato)
  testar "ateRodada 3 mantem so partidas das rodadas 1 a 3"
         (length (ateRodada 3 campeonato)) 12
  testar "classificacao ate a rodada 3 (ordem dos times)"
         (map time ate3)
         [ "Athletico", "Gremio", "Fluminense", "Flamengo"
         , "Coritiba", "Corinthians", "Vasco", "Chapecoense" ]
  testar "classificacao ate a rodada 3 (pontos)"
         (map pontosLinha ate3) [7, 7, 6, 5, 4, 3, 1, 0]
  testar "linha do Athletico ate a rodada 3"
         (primeira ate3) (Just (Linha "Athletico" 3 2 1 0 11 2))
  testar "classificacao ate a rodada 3 difere da final"
         (map time ate3 /= map time final) True
  testar "lider ate a rodada 3 x lider final"
         (map time (take 1 ate3), map time (take 1 final))
         (["Athletico"], ["Flamengo"])
  testar "ateRodada 0 nao tem partidas" (ateRodada 0 campeonato) []

  -- Estatisticas e casos vazios
  testar "maiorGoleada do campeonato (8x1)"
         (maiorGoleada campeonato) (Just partidaExemplo)
  testar "mediaGols do campeonato (77 gols em 32 jogos)"
         (mediaGols campeonato) (Just 2.40625)
  testar "maiorGoleada []" (maiorGoleada []) Nothing
  testar "mediaGols []" (mediaGols []) Nothing
  testar "classificacao [] (campeonato vazio)" (classificacao []) []
  where
    primeira xs = case xs of
      (x : _) -> Just x
      []      -> Nothing

testesCamada3 :: IO ()
testesCamada3 = do
  putStrLn "--- Camada 3: leitura e validacao ---"
  testar "separar divide nos separadores"
         (separar ';' "a;b;;c") ["a", "b", "", "c"]
  testar "separar de String vazia" (separar ';' "") [""]

  testar "lerCampeonato da entrada valida devolve Right (igual a Camada 1)"
         (lerCampeonato dadosCampeonato) (Right campeonato)
  testar "lerCampeonato ignora comentarios e linhas em branco"
         (lerCampeonato "# comentario\n\n1;A;1;0;B\n")
         (Right [Partida 1 "A" 1 0 "B"])
  testar "lerCampeonato de texto vazio" (lerCampeonato "") (Right [])

  -- Um teste para cada construtor de Erro
  testar "CamposInvalidos (faltam campos)"
         (lerPartida 7 "1;Coritiba;2;1") (Left (CamposInvalidos 7))
  testar "NumeroInvalido (placar \"dois\")"
         (lerPartida 3 "1;Athletico;dois;0;Flamengo") (Left (NumeroInvalido 3))
  testar "NumeroInvalido (rodada 0)"
         (lerPartida 1 "0;A;1;1;B") (Left (NumeroInvalido 1))
  testar "PlacarNegativo"
         (lerPartida 4 "2;Gremio;-1;2;Vasco") (Left (PlacarNegativo 4))
  testar "MesmoTime (time contra si mesmo)"
         (lerPartida 5 "2;Coritiba;1;1;Coritiba") (Left (MesmoTime 5))
  testar "TimeRepetidoNaRodada (Flamengo duas vezes na rodada 3)"
         (lerCampeonato "3;Flamengo;2;0;Fluminense\n3;Flamengo;1;1;Vasco\n")
         (Left (TimeRepetidoNaRodada 3))

  testar "lerCampeonato para no primeiro erro"
         (lerCampeonato dadosComErros) (Left (CamposInvalidos 2))
  testar "todosOsErros lista todos os erros (5 problemas)"
         (todosOsErros dadosComErros)
         [ CamposInvalidos 2, NumeroInvalido 3, PlacarNegativo 4
         , MesmoTime 5, TimeRepetidoNaRodada 3 ]
  testar "todosOsErros da entrada valida" (todosOsErros dadosCampeonato) []

  -- Formatacao da tabela
  let linhasTabela = lines (tabelaFormatada final)
  testar "tabelaFormatada tem cabecalho, separador e 8 linhas"
         (length linhasTabela) 10
  testar "tabelaFormatada: primeira linha de dados e o Flamengo"
         (map words (take 1 (drop 2 linhasTabela)))
         [["1", "|", "Flamengo", "|", "18", "|", "8", "|", "5", "|", "3", "|", "0", "|", "7"]]

rodarTestes :: IO ()
rodarTestes = do
  testesCamada1
  testesCamada2
  testesCamada3
