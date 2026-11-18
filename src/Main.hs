-- Camada 1: Tipos e Dados do Campeonato
import Data.List (nub, sort)

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



-- Camada 3: Leitura (Maybe, Either e formatação)


-- Dados: campeonato de teste


-- Main 








