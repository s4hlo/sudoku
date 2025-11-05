# Sudoku

Sudoku solver using depth-first search (backtracking algorithm). Solves 9x9 sudoku puzzles.

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

### Format code

```bash
mix format
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sudoku>.

