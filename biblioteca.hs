import Data.Time (Day, fromGregorian, getCurrentTime, utctDay)

-- Tipos de Dados
type Pessoa = String
type Livro = String
type PalavraChave = String
type DataEmprestimo = Day
type BancodeDados = [(Pessoa, Livro, [PalavraChave], DataEmprestimo)]

-- Base de Dados (Exemplo de teste)
teste :: BancodeDados
teste =
    [ ("Paulo", "A Mente Nova do Rei", ["psicologia", "rei"], fromGregorian 2024 11 15),
      ("Ana", "O Segredo de Luiza", ["negocios", "empreendedorismo"], fromGregorian 2024 11 10),
      ("Paulo", "O Pequeno Principe", ["infantil", "filosofia"], fromGregorian 2024 11 20),
      ("Mauro", "O Capital", ["economia", "marxismo"], fromGregorian 2024 11 05),
      ("Francisco", "O Auto da Compadecida", ["teatro", "comedia"], fromGregorian 2024 11 01),
      ("Ana", "O Principe", ["politica", "filosofia"], fromGregorian 2024 11 10),
      ("Paulo", "O Senhor dos Aneis", ["fantasia", "aventura"], fromGregorian 2024 11 15)
    ]

-- Máximo de livros que uma pessoa pode tomar emprestado
maxLivros :: Int
maxLivros = 3

-- Funções de Consulta

-- 1. Livros emprestados por uma pessoa
livrosEmprestados :: BancodeDados -> Pessoa -> [Livro]
livrosEmprestados [] _ = []
livrosEmprestados ((pessoa, livro, _, _):resto) fulano
    | pessoa == fulano = livro : livrosEmprestados resto fulano
    | otherwise = livrosEmprestados resto fulano

-- 2. Todas as pessoas que pegaram um determinado livro
quemPegouLivro :: BancodeDados -> Livro -> [Pessoa]
quemPegouLivro [] _ = []
quemPegouLivro ((pessoa, livro, _, _):resto) titulo
    | livro == titulo = pessoa : quemPegouLivro resto titulo
    | otherwise = quemPegouLivro resto titulo

-- 3. Verificar se um livro está emprestado
estaEmprestado :: BancodeDados -> Livro -> Bool
estaEmprestado [] _ = False
estaEmprestado ((_, livro, _, _):resto) titulo
    | livro == titulo = True
    | otherwise = estaEmprestado resto titulo

-- 4. Quantidade de livros emprestados por uma pessoa
quantidadeEmprestimos :: BancodeDados -> Pessoa -> Int
quantidadeEmprestimos [] _ = 0
quantidadeEmprestimos ((pessoa, _, _, _):resto) fulano
    | pessoa == fulano = 1 + quantidadeEmprestimos resto fulano
    | otherwise = quantidadeEmprestimos resto fulano

-- Funções de Atualização

-- 5. Emprestar um livro
tomaEmprestado :: BancodeDados -> Pessoa -> Livro -> [PalavraChave] -> DataEmprestimo -> BancodeDados
tomaEmprestado dBase pessoa livro palavras dataEmprestimo
    | quantidadeEmprestimos dBase pessoa >= maxLivros = error "Limite de empréstimos atingido!"
    | otherwise = (pessoa, livro, palavras, dataEmprestimo) : dBase

-- 6. Devolver um livro
devolveLivro :: BancodeDados -> Pessoa -> Livro -> Day -> BancodeDados
devolveLivro [] _ _ _ = error "Nenhum livro emprestado para devolver."
devolveLivro ((pessoa, titulo, palavras, dataEmp):resto) fulano livro hoje
    | pessoa == fulano && titulo == livro =
        if hoje > dataEmp
            then error "O livro está sendo devolvido após o limite do empréstimo!"
            else resto
    | otherwise = (pessoa, titulo, palavras, dataEmp) : devolveLivro resto fulano livro hoje

-- 7. Buscar livros por palavra-chave
buscaPorPalavraChave :: BancodeDados -> PalavraChave -> [Livro]
buscaPorPalavraChave [] _ = []
buscaPorPalavraChave ((_, livro, palavras, _):resto) palavra
    | palavra `elem` palavras = livro : buscaPorPalavraChave resto palavra
    | otherwise = buscaPorPalavraChave resto palavra

-- 8. Verificar livros vencidos
livrosVencidos :: BancodeDados -> Day -> [(Pessoa, Livro)]
livrosVencidos [] _ = []
livrosVencidos ((pessoa, livro, _, dataEmp):resto) hoje
    | dataEmp < hoje = (pessoa, livro) : livrosVencidos resto hoje
    | otherwise = livrosVencidos resto hoje

-- Programa Principal para Testes
main :: IO ()
main = do
    let hoje = fromGregorian 2024 12 2 -- Data atual simulada
    putStrLn "Livros emprestados por Paulo:"
    print $ livrosEmprestados teste "Paulo"

    putStrLn "\nQuem pegou o livro 'O Capital':"
    print $ quemPegouLivro teste "O Capital"

    putStrLn "\nO livro 'O Pequeno Principe' está emprestado?"
    print $ estaEmprestado teste "O Pequeno Principe"

    putStrLn "\nQuantidade de livros emprestados por Paulo:"
    print $ quantidadeEmprestimos teste "Paulo"

    putStrLn "\nBuscando livros com a palavra-chave 'teatro':"
    print $ buscaPorPalavraChave teste "teatro"

    putStrLn "\nLivros vencidos até hoje:"
    print $ livrosVencidos teste hoje

    putStrLn "\nAdicionando novo empréstimo para Ana:"
    let novoTeste = tomaEmprestado teste "Ana" "Clean Code" ["programacao", "engenharia"] (fromGregorian 2024 12 01)
    print novoTeste

    putStrLn "\nDevolvendo livro 'O Segredo de Luiza' para Ana:"
    let atualizadoTeste = devolveLivro novoTeste "Ana" "O Segredo de Luiza" hoje
    print atualizadoTeste
