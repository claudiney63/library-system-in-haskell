from datetime import date

# Tipos de Dados
Pessoa = str
Livro = str
PalavraChave = str
DataEmprestimo = date
BancodeDados = list[tuple[Pessoa, Livro, list[PalavraChave], DataEmprestimo]]

# Base de Dados (Exemplo de teste)
teste: BancodeDados = [
    ("Paulo", "A Mente Nova do Rei", ["psicologia", "rei"], date(2024, 11, 15)),
    ("Ana", "O Segredo de Luiza", ["negocios", "empreendedorismo"], date(2024, 11, 10)),
    ("Paulo", "O Pequeno Principe", ["infantil", "filosofia"], date(2024, 11, 20)),
    ("Mauro", "O Capital", ["economia", "marxismo"], date(2024, 11, 5)),
    ("Francisco", "O Auto da Compadecida", ["teatro", "comedia"], date(2024, 11, 1)),
]

# Máximo de livros que uma pessoa pode tomar emprestado
MAX_LIVROS = 3

# Funções de Consulta

# 1. Livros emprestados por uma pessoa
def livros_emprestados(banco: BancodeDados, pessoa: Pessoa) -> list[Livro]:
    return [livro for p, livro, _, _ in banco if p == pessoa]

# 2. Todas as pessoas que pegaram um determinado livro
def quem_pegou_livro(banco: BancodeDados, livro: Livro) -> list[Pessoa]:
    return [p for p, l, _, _ in banco if l == livro]

# 3. Verificar se um livro está emprestado
def esta_emprestado(banco: BancodeDados, livro: Livro) -> bool:
    return any(l == livro for _, l, _, _ in banco)

# 4. Quantidade de livros emprestados por uma pessoa
def quantidade_emprestimos(banco: BancodeDados, pessoa: Pessoa) -> int:
    return sum(1 for p, _, _, _ in banco if p == pessoa)

# Funções de Atualização

# 5. Emprestar um livro
def toma_emprestado(
    banco: BancodeDados, pessoa: Pessoa, livro: Livro, palavras: list[PalavraChave], data: DataEmprestimo
) -> BancodeDados:
    if quantidade_emprestimos(banco, pessoa) >= MAX_LIVROS:
        raise ValueError("Limite de empréstimos atingido!")
    return [(pessoa, livro, palavras, data)] + banco

# 6. Devolver um livro
def devolve_livro(banco: BancodeDados, pessoa: Pessoa, livro: Livro) -> BancodeDados:
    if not any(p == pessoa and l == livro for p, l, _, _ in banco):
        raise ValueError("Nenhum livro emprestado para devolver.")
    return [(p, l, palavras, data) for p, l, palavras, data in banco if not (p == pessoa and l == livro)]

# 7. Buscar livros por palavra-chave
def busca_por_palavra_chave(banco: BancodeDados, palavra: PalavraChave) -> list[Livro]:
    return [livro for _, livro, palavras, _ in banco if palavra in palavras]

# 8. Verificar livros vencidos
def livros_vencidos(banco: BancodeDados, hoje: DataEmprestimo) -> list[tuple[Pessoa, Livro]]:
    return [(p, livro) for p, livro, _, data in banco if data < hoje]

# Programa Principal para Testes
if __name__ == "__main__":
    hoje = date(2024, 11, 25)  # Data atual simulada

    print("Livros emprestados por Paulo:")
    print(livros_emprestados(teste, "Paulo"))

    print("\nQuem pegou o livro 'O Capital':")
    print(quem_pegou_livro(teste, "O Capital"))

    print("\nO livro 'O Pequeno Principe' está emprestado?")
    print(esta_emprestado(teste, "O Pequeno Principe"))

    print("\nQuantidade de livros emprestados por Paulo:")
    print(quantidade_emprestimos(teste, "Paulo"))

    print("\nBuscando livros com a palavra-chave 'teatro':")
    print(busca_por_palavra_chave(teste, "teatro"))

    print("\nLivros vencidos até hoje:")
    print(livros_vencidos(teste, hoje))

    print("\nAdicionando novo emprestimo para Ana:")
    novo_teste = toma_emprestado(teste, "Ana", "Clean Code", ["programacao", "engenharia"], date(2024, 12, 1))
    print(novo_teste)

    print("\nDevolvendo livro 'O Segredo de Luiza' para Ana:")
    atualizado_teste = devolve_livro(novo_teste, "Ana", "O Segredo de Luiza")
    print(atualizado_teste)
