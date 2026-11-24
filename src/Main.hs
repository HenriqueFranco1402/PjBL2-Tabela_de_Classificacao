-- Camada 1: Tipos e Dados do Campeonato
import Data.List (nub, sort , sortBy , maximumBy)
import Data.Ord (Down (..), comparing)
import Data.Char (isSpace)
import Data.Either (lefts, rights)
import Text.Read (readMaybe)

type Time = String

data Resultado = Vitoria | Empate | Derrota
  deriving (Show, Eq)
  
data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)
  
data Linha = Linha
  { time      :: Time
  , jogos     :: Int
  , vitorias  :: Int
  , empates   :: Int
  , derrotas  :: Int
  , gols_pro  :: Int
  , gols_contra :: Int
  } deriving (Show, Eq)
  
-- t == mandante p compara e dá True se o time for o mandante
-- t == visitante p compara e da True se o time for o visitante
participou :: Time -> Partida -> Bool
participou t p = t == mandante p || t == visitante p 

resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | t == mandante p   = Just (comparar (golsMandante p ) (golsVisitante p))
  | t == visitante p  = Just (comparar (golsVisitante p ) (golsMandante p))
  | otherwise         = Nothing
  where
    comparar pro contra
      | pro > contra  = Vitoria
      | pro == contra = Empate
      | otherwise     = Derrota
      
-- o sort vai ordenar né
-- o nub remove os itens repetidos da lista
-- o concatMap é a junção do map (que aplica a condição a todos da lista)
-- e o concat junta um conjunto de listas em uma lista só
times :: [Partida] -> [Time]
times ps = sort (nub (concatMap (\p -> [mandante p, visitante p]) ps))

-- fiz com 8 times e 8 rodadas 
campeonato :: [Partida]
campeonato =
  [ -- Rodada 1
    Partida 1 "Coritiba"    1 8 "Athletico"
  , Partida 1 "Corinthians" 2 1 "Chapecoense"
  , Partida 1 "Flamengo"    2 0 "Fluminense"
  , Partida 1 "Gremio"      1 0 "Vasco"
    -- Rodada 2
  , Partida 2 "Coritiba"    2 1 "Corinthians"
  , Partida 2 "Athletico"   1 1 "Flamengo"
  , Partida 2 "Chapecoense" 0 3 "Fluminense"
  , Partida 2 "Vasco"       0 0 "Gremio"
    -- Rodada 3
  , Partida 3 "Coritiba"    1 1 "Flamengo"
  , Partida 3 "Athletico"   2 0 "Corinthians"
  , Partida 3 "Chapecoense" 1 2 "Gremio"
  , Partida 3 "Fluminense"  1 0 "Vasco"
    -- Rodada 4
  , Partida 4 "Coritiba"    2 0 "Fluminense"
  , Partida 4 "Athletico"   1 1 "Chapecoense"
  , Partida 4 "Corinthians" 0 1 "Vasco"
  , Partida 4 "Flamengo"    3 2 "Gremio"
    -- Rodada 5
  , Partida 5 "Coritiba"    0 1 "Chapecoense"
  , Partida 5 "Athletico"   2 2 "Fluminense"
  , Partida 5 "Corinthians" 1 0 "Gremio"
  , Partida 5 "Flamengo"    2 1 "Vasco"
    -- Rodada 6
  , Partida 6 "Coritiba"    1 2 "Gremio"
  , Partida 6 "Athletico"   3 0 "Vasco"
  , Partida 6 "Corinthians" 1 1 "Fluminense"
  , Partida 6 "Chapecoense" 0 2 "Flamengo"
    -- Rodada 7
  , Partida 7 "Coritiba"    2 0 "Vasco"
  , Partida 7 "Athletico"   1 2 "Gremio"
  , Partida 7 "Corinthians" 2 2 "Flamengo"
  , Partida 7 "Chapecoense" 1 1 "Fluminense"
    -- Rodada 8
  , Partida 8 "Chapecoense" 1 0 "Vasco"
  , Partida 8 "Fluminense"  2 1 "Gremio"
  , Partida 8 "Athletico"   0 1 "Coritiba"
  , Partida 8 "Corinthians" 0 1 "Flamengo"
  ]
  

-- Camada 2: Classificação 

-- | 3 pela vitória , 1 pelo empate , 0 pela derrota.
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

-- | gols (pró , contra) de um time em uma partidaem que ele jogou.
golsDoTime :: Time -> Partida -> (Int, Int)
golsDoTime t p 
  | t == mandante p = (golsMandante p, golsVisitante p)
  | otherwise       = (golsVisitante p, golsMandante p)

-- | Incrementa o contador (vitórias/empates/derrotas) do resultado.
contabiliza :: Resultado -> Linha -> Linha
contabiliza Vitoria l = l { vitorias = vitorias l + 1 }
contabiliza Empate  l = l { empates  = empates  l + 1 }
contabiliza Derrota l = l { derrotas = derrotas l + 1 }

-- | Passo da dobra: incorpora uma partida à linha do time.
acumular :: Time -> Linha -> Partida -> Linha
acumular t l p = case resultadoPara t p of
  Nothing -> l
  Just r  ->
    let (pro, contra) = golsDoTime t p
    in (contabiliza r l)
         { jogos       = jogos l + 1
         , gols_pro    = gols_pro l + pro
         , gols_contra = gols_contra l + contra
         }

-- | Linha da tabela de um time, acumulada com foldl.
linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldl (acumular t) (Linha t 0 0 0 0 0 0) (filter (participou t) ps)

-- | Pontos ganhos por uma linha.
pontosLinha :: Linha -> Int
pontosLinha l =
    pontos Vitoria * vitorias l
  + pontos Empate  * empates l
  + pontos Derrota * derrotas l
  
-- | Saldo de gols (gols pró menos gols contra).
saldo :: Linha -> Int
saldo l = gols_pro l - gols_contra l

-- | Percentual (0 a 100) dos pontos disputados que o time conquistou; 0 se não jogou.
aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise    = 100 * fromIntegral (pontosLinha l)
                       / fromIntegral (pontos Vitoria * jogos l)

-- | Critério: pontos, vitórias, saldo, gols pró (todos decrescentes) e, por fim, nome.
criterio :: Linha -> Linha -> Ordering
criterio =
     comparing (Down . pontosLinha)
  <> comparing (Down . vitorias)
  <> comparing (Down . saldo)
  <> comparing (Down . gols_pro)
  <> comparing time
  
-- | Tabela completa, ordenada pelo critério acima.
classificacao :: [Partida] -> [Linha]
classificacao ps = sortBy criterio (map (linhaDoTime ps) (times ps))

-- | Apenas as partidas até a rodada informada (inclusive).
ateRodada :: Int -> [Partida] -> [Partida]
ateRodada n = filter ((<= n) . rodada)

-- | Diferença absoluta de gols de uma partida.
diferenca :: Partida -> Int
diferenca p = abs (golsMandante p - golsVisitante p)

-- | Partida com a maior diferença de gols (em empate, a mais antiga); Nothing se vazia.
maiorGoleada :: [Partida] -> Maybe Partida
maiorGoleada [] = Nothing
maiorGoleada ps = Just (maximumBy (comparing diferenca <> comparing (Down . rodada)) ps)

-- | Média de gols por partida; Nothing se vazia.
mediaGols :: [Partida] -> Maybe Double
mediaGols [] = Nothing
mediaGols ps = Just (fromIntegral totalGols / fromIntegral (length ps))
  where
    totalGols = sum (map (\p -> golsMandante p + golsVisitante p) ps)

-- Camada 3: Leitura (Maybe, Either e formatação)

data Erro
  = CamposInvalidos Int
  | NumeroInvalido Int
  | PlacarNegativo Int
  | MesmoTime Int
  | TimeRepetidoNaRodada Int
  deriving (Show, Eq)

-- | Remove espaços em branco no início e no fim de uma String.
trim :: String -> String
trim = dropWhile isSpace . reverse . dropWhile isSpace . reverse

-- | Quebra uma linha nos separadores usando foldr (sem recursão explícita).
separar :: Char -> String -> [String]
separar sep = foldr passo [[]]
  where
    passo c acc@(x:xs)
      | c == sep  = [] : acc
      | otherwise = (c : x) : xs
    passo _ [] = [[]]

-- | Converte String para Int usando readMaybe e Maybe como functor (<$>).
lerInteiro :: Int -> String -> Either Erro Int
lerInteiro numLinha txt =
  maybe (Left (NumeroInvalido numLinha)) Right ((+ 0) <$> readMaybe (trim txt))

-- | Valida se um valor inteiro não é negativo.
validarNaoNegativo :: Int -> Int -> Either Erro Int
validarNaoNegativo numLinha n
  | n < 0     = Left (PlacarNegativo numLinha)
  | otherwise = Right n
  
-- | Valida se a rodada é positiva (> 0).
validarRodadaPositiva :: Int -> Int -> Either Erro Int
validarRodadaPositiva numLinha r
  | r <= 0    = Left (NumeroInvalido numLinha)
  | otherwise = Right r

-- | Valida se uma String de texto (nome do time) não está vazia.
validarNome :: Int -> String -> Either Erro Time
validarNome numLinha nome
  | null limpo = Left (CamposInvalidos numLinha)
  | otherwise  = Right limpo
  where
    limpo = trim nome

-- | Converte uma linha numerada em Partida usando a mônada Either (notação do).
lerPartida :: Int -> String -> Either Erro Partida
lerPartida numLinha linha =
  case separar ';' linha of
    [rStr, mStr, gmStr, gvStr, vStr] -> do
      r  <- lerInteiro numLinha rStr >>= validarRodadaPositiva numLinha
      gm <- lerInteiro numLinha gmStr >>= validarNaoNegativo numLinha
      gv <- lerInteiro numLinha gvStr >>= validarNaoNegativo numLinha
      m  <- validarNome numLinha mStr
      v  <- validarNome numLinha vStr
      if m == v
        then Left (MesmoTime numLinha)
        else Right (Partida r m gm gv v)
    _ -> Left (CamposInvalidos numLinha)

-- | Filtra linhas em branco e comentários (#), preservando o número original da linha.
linhasValidasNumeradas :: String -> [(Int, String)]
linhasValidasNumeradas =
  filter (not . ignorar . snd) . zip [1..] . lines
  where
    ignorar s =
      let limpo = trim s
      in null limpo || take 1 limpo == "#"

-- | Verifica se algum time joga mais de uma vez na mesma rodada.
validarRodadas :: [Partida] -> Either Erro [Partida]
validarRodadas ps =
  case errosRodada ps of
    (err : _) -> Left err
    []        -> Right ps

-- | Encontra todos os erros de times repetidos na mesma rodada (usado em lerCampeonato e todosOsErros).
errosRodada :: [Partida] -> [Erro]
errosRodada ps =
  concatMap verificarRodada rodadasUnicas
  where
    rodadasUnicas = nub (map rodada ps)
    verificarRodada r =
      let partidasR = filter ((== r) . rodada) ps
          escalados = concatMap (\p -> [mandante p, visitante p]) partidasR
      in if length escalados /= length (nub escalados)
           then [TimeRepetidoNaRodada r]
           else []

-- | Lê o texto inteiro, parando no primeiro erro (via traverse), e valida rodadas.
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  partidas <- traverse (uncurry lerPartida) (linhasValidasNumeradas texto)
  validarRodadas partidas

-- | Relatório com todos os erros do texto (erros de linha + erros de rodada).
todosOsErros :: String -> [Erro]
todosOsErros texto =
  let resultados = map (uncurry lerPartida) (linhasValidasNumeradas texto)
      errosLinha = lefts resultados
      partidasOk = rights resultados
  in errosLinha ++ errosRodada partidasOk

-- | Alinha texto à esquerda ou à direita para formatar colunas da tabela.
padDir :: Int -> String -> String
padDir n s = s ++ replicate (max 0 (n - length s)) ' '

padEsq :: Int -> String -> String
padEsq n s = replicate (max 0 (n - length s)) ' ' ++ s

-- | Formata uma única linha da classificação com sua posição.
formatarLinha :: (Int, Linha) -> String
formatarLinha (pos, l) =
     padEsq 3 (show pos) ++ " | "
  ++ padDir 14 (time l) ++ " | "
  ++ padEsq 3 (show (pontosLinha l)) ++ " | "
  ++ padEsq 3 (show (jogos l)) ++ " | "
  ++ padEsq 3 (show (vitorias l)) ++ " | "
  ++ padEsq 3 (show (empates l)) ++ " | "
  ++ padEsq 3 (show (derrotas l)) ++ " | "
  ++ padEsq 4 (show (saldo l))

-- | Formata a tabela completa pronta para impressão.
tabelaFormatada :: [Linha] -> String
tabelaFormatada ls =
  unlines (cabecalho : separador : map formatarLinha (zip [1..] ls))
  where
    cabecalho = "Pos | Time           | Pts |   J |   V |   E |   D |   SG"
    separador = "----+----------------+-----+-----+-----+-----+-----+-----"


-- Dados: campeonato de teste

dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# Campeonato de Teste - 8 times e 8 rodadas"
  , "# rodada; mandante; gols mandante; gols visitante; visitante"
  , ""
  , "# Rodada 1"
  , "1; Coritiba; 1; 8; Athletico"
  , "1; Corinthians; 2; 1; Chapecoense"
  , "1; Flamengo; 2; 0; Fluminense"
  , "1; Gremio; 1; 0; Vasco"
  , ""
  , "# Rodada 2"
  , "2; Coritiba; 2; 1; Corinthians"
  , "2; Athletico; 1; 1; Flamengo"
  , "2; Chapecoense; 0; 3; Fluminense"
  , "2; Vasco; 0; 0; Gremio"
  , ""
  , "# Rodada 3"
  , "3; Coritiba; 1; 1; Flamengo"
  , "3; Athletico; 2; 0; Corinthians"
  , "3; Chapecoense; 1; 2; Gremio"
  , "3; Fluminense; 1; 0; Vasco"
  , ""
  , "# Rodada 4"
  , "4; Coritiba; 2; 0; Fluminense"
  , "4; Athletico; 1; 1; Chapecoense"
  , "4; Corinthians; 0; 1; Vasco"
  , "4; Flamengo; 3; 2; Gremio"
  , ""
  , "# Rodada 5"
  , "5; Coritiba; 0; 1; Chapecoense"
  , "5; Athletico; 2; 2; Fluminense"
  , "5; Corinthians; 1; 0; Gremio"
  , "5; Flamengo; 2; 1; Vasco"
  , ""
  , "# Rodada 6"
  , "6; Coritiba; 1; 2; Gremio"
  , "6; Athletico; 3; 0; Vasco"
  , "6; Corinthians; 1; 1; Fluminense"
  , "6; Chapecoense; 0; 2; Flamengo"
  , ""
  , "# Rodada 7"
  , "7; Coritiba; 2; 0; Vasco"
  , "7; Athletico; 1; 2; Gremio"
  , "7; Corinthians; 2; 2; Flamengo"
  , "7; Chapecoense; 1; 1; Fluminense"
  , ""
  , "# Rodada 8"
  , "8; Chapecoense; 1; 0; Vasco"
  , "8; Fluminense; 2; 1; Gremio"
  , "8; Athletico; 0; 1; Coritiba"
  , "8; Corinthians; 0; 1; Flamengo"
  ]

dadosComErros :: String
dadosComErros = unlines
  [ "# Entrada com erros propositais para demonstracao"
  , "1; Coritiba; 2; 1"
  , "1; Athletico; dois; 0; Flamengo"
  , "2; Gremio; -1; 2; Vasco"
  , "2; Coritiba; 1; 1; Coritiba"
  , "3; Flamengo; 2; 0; Fluminense"
  , "3; Flamengo; 1; 1; Vasco"
  ]

-- Testes

-- | Compara o valor obtido com o esperado e imprime [OK] ou [FALHA].
testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("  [OK]    " ++ nome)
  | otherwise          = putStrLn ("  [FALHA] " ++ nome
                                   ++ "\n          esperado: " ++ show esperado
                                   ++ "\n          obtido:   " ++ show obtido)

-- | Partida usada nos testes: a maior goleada do campeonato (rodada 1, 1x8).
partidaExemplo :: Partida
partidaExemplo = Partida 1 "Coritiba" 1 8 "Athletico"

-- | Classificação final do campeonato de exemplo.
final :: [Linha]
final = classificacao campeonato

-- Main

main :: IO ()
main = do
  putStrLn "=== 1. LEITURA E CLASSIFICACAO FINAL ==="
  case lerCampeonato dadosCampeonato of
    Left err -> putStrLn ("Erro ao ler campeonato: " ++ show err)
    Right ps -> do
      putStrLn (tabelaFormatada (classificacao ps))

      putStrLn "=== 2. CLASSIFICACAO APOS A 3a RODADA ==="
      putStrLn (tabelaFormatada (classificacao (ateRodada 3 ps)))

      putStrLn "=== 3. ESTATISTICAS DO CAMPEONATO ==="
      putStrLn ("Maior goleada: " ++ show (maiorGoleada ps))
      putStrLn ("Media de gols: " ++ show (mediaGols ps))

  putStrLn "\n=== 4. TRATAMENTO DE ENTRADA COM ERROS ==="
  putStrLn ("lerCampeonato (para no primeiro erro): " ++ show (lerCampeonato dadosComErros))
  putStrLn "todosOsErros (lista todos os problemas):"
  mapM_ print (todosOsErros dadosComErros)
  putStrLn "\n=== 5. TESTES ==="
  rodarTestes
