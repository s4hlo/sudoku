# Sudoku Solver

Solver de Sudoku em Elixir que implementa dois algoritmos diferentes para resolver quebra-cabeças Sudoku.

## Algoritmos

Implementações de algoritmos para resolver quebra-cabeças Sudoku.

- **Backtracking**: Busca em profundidade com backtracking (padrão)
- **Algorithm X**: Algoritmo X de Donald Knuth para problemas de exact cover


## Documentação

Gera documentação HTML usando ExDoc a partir dos comentários no código.

Para gerar a documentação, execute:

```bash
mix docs
```

A documentação será gerada na pasta `doc/`. Para visualizar, abra o arquivo `doc/index.html` no seu navegador.

## Requisitos

Dependências e versões necessárias para executar o projeto.

- Elixir ~> 1.17

## Instalação

Passos para configurar o projeto localmente.

Clone o repositório e instale as dependências:

```bash
mix deps.get
```

## Scripts

Scripts de exemplo e teste disponíveis na pasta `scripts/`.

O projeto inclui vários scripts na pasta `scripts/`:

- `example_backtracking.exs` - Exemplo usando backtracking
- `example_algorithm_x.exs` - Exemplo usando Algorithm X
- `test_visualizer.exs` - Testa visualização do processo de resolução
- `test_visualizer_algorithm_x.exs` - Testa visualização com Algorithm X
- `test_history.exs` - Testa histórico de resolução
- `visualize_exact_cover_matrix.exs` - Visualiza matriz de exact cover

### Executar Scripts

Formas de executar os scripts disponíveis no projeto.

Use os aliases do Mix:

```bash
mix example_backtracking
mix example_algorithm_x
mix test_visualizer
mix test_visualizer_algorithm_x
mix test_history
mix visualize_exact_cover_matrix
```

Ou execute diretamente:

```bash
mix run scripts/example_backtracking.exs
mix run scripts/example_algorithm_x.exs
```

## Uso

Exemplos de como usar o solver de Sudoku no código.

```elixir
# Grid representado como lista de listas (0 = célula vazia)
grid = [
  [5, 3, 0, 0, 7, 0, 0, 0, 0],
  [6, 0, 0, 1, 9, 5, 0, 0, 0],
  [0, 9, 8, 0, 0, 0, 0, 6, 0],
  # ... resto do grid
]

# Resolver com backtracking (padrão)
solution = Sudoku.solve(grid)

# Resolver com Algorithm X
solution = Sudoku.solve(grid, Sudoku.AlgorithmX)

# Obter histórico de resolução
history = Sudoku.solve_log(grid)
```

## Testes

Executa a suíte de testes do projeto.

```bash
mix test
```

## Uso de IA

Registro de contribuições feitas com auxílio de IA durante o desenvolvimento.

- Criação da documentação para gerar o exDoc
- Criação de massa de teste
- Alguns ajustes nas funções do módulo de Visualizer referentes a:
    - adicionar bordas estilizadas no tabuleiro
    - animar corretamente a sequência de tabuleiros no terminal
    - animação em paralelo do board com a matriz de cobertura lado a lado no caso do Algorithm X
    
by Rafael Magno 
