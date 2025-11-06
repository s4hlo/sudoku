# Sudoku

Sudoku solver supporting multiple solving algorithms. Currently implements backtracking (depth-first search). Supports various grid sizes (4x4, 9x9, 16x16, etc.).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sudoku` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sudoku, "~> 0.1.0"}
  ]
end
```

## Usage

### Compile the project

```bash
mix compile
```

### Run tests

```bash
mix test
```

### Run in interactive shell (IEx)

```bash
iex -S mix
```

Then you can use the solver:

### Using the default solver (backtracking)

```elixir
puzzle = [
  [5, 3, 0, 0, 7, 0, 0, 0, 0],
  [6, 0, 0, 1, 9, 5, 0, 0, 0],
  [0, 9, 8, 0, 0, 0, 0, 6, 0],
  [8, 0, 0, 0, 6, 0, 0, 0, 3],
  [4, 0, 0, 8, 0, 3, 0, 0, 1],
  [7, 0, 0, 0, 2, 0, 0, 0, 6],
  [0, 6, 0, 0, 0, 0, 2, 8, 0],
  [0, 0, 0, 4, 1, 9, 0, 0, 5],
  [0, 0, 0, 0, 8, 0, 0, 7, 9]
]

Sudoku.solve(puzzle)
```

### Using a specific solver

```elixir
# Explicitly use backtracking solver
Sudoku.solve(puzzle, Sudoku.Backtracking)
```

## Solvers

- **Backtracking** (`Sudoku.Backtracking`) - Depth-first search with backtracking algorithm

### Format code

```bash
mix format
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sudoku>.

