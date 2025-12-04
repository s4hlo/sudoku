# Sudoku Solver

Solver de Sudoku em Elixir que implementa dois algoritmos diferentes para resolver quebra-cabeças Sudoku.

## Algoritmos

- **Backtracking**: Busca em profundidade com backtracking (padrão)
- **Algorithm X**: Algoritmo X de Donald Knuth para problemas de exact cover

## Requisitos

- Elixir ~> 1.17

## Instalação

Clone o repositório e instale as dependências:

```bash
mix deps.get
```

## Scripts

O projeto inclui vários scripts de exemplo e teste na pasta `scripts/`:

- `example_backtracking.exs` - Exemplo usando backtracking
- `example_algorithm_x.exs` - Exemplo usando Algorithm X
- `test_visualizer.exs` - Testa visualização do processo de resolução
- `test_visualizer_algorithm_x.exs` - Testa visualização com Algorithm X
- `test_history.exs` - Testa histórico de resolução
- `visualize_exact_cover_matrix.exs` - Visualiza matriz de exact cover

### Executar Scripts

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

```bash
mix test
```

by Rafael Magno 
