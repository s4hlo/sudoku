defmodule Sudoku do
  @moduledoc """
  Main module for solving Sudoku puzzles.

  This module provides a unified interface for solving Sudoku puzzles using
  different algorithms. It supports both standard solving and solving with
  history tracking for visualization purposes.

  ## Supported Algorithms

  - `Sudoku.Backtracking` - Depth-first search with backtracking (default)
  - `Sudoku.AlgorithmX` - Donald Knuth's Algorithm X for exact cover problems

  ## Grid Format

  The grid is represented as a list of lists, where each inner list represents
  a row. Empty cells are represented as `0`. For example, a 9x9 grid would be:

      [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0]
      ]

  ## Examples

      iex> grid = [
      ...>   [5, 3, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]
      iex> solved = Sudoku.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.solve(grid, Sudoku.AlgorithmX)
      [[1, 2, 3, 4], [3, 4, 1, 2], [2, 1, 4, 3], [4, 3, 2, 1]]
  """

  @default_solver Sudoku.Backtracking

  @doc """
  Solves a Sudoku puzzle using the default backtracking algorithm.

  The grid is validated before solving. If the initial grid is invalid
  (contains conflicting values), `nil` is returned.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.

  ## Returns

    - `list()` - The solved grid as a list of lists, or `nil` if no solution exists
      or the initial grid is invalid.

  ## Examples

      iex> grid = [
      ...>   [5, 3, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]
      iex> solved = Sudoku.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> invalid_grid = [
      ...>   [5, 5, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]  # Conflicting values in first row
      iex> Sudoku.solve(invalid_grid)
      nil
  """
  @spec solve(list()) :: list() | nil
  def solve(grid) when is_list(grid) do
    validate_and_solve(grid, @default_solver, :solve)
  end

  @doc """
  Solves a Sudoku puzzle using a specified solver algorithm.

  The grid is validated before solving. If the initial grid is invalid
  (contains conflicting values), `nil` is returned.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.
    - `solver` - The solver module to use. Must be `Sudoku.Backtracking` or
      `Sudoku.AlgorithmX`.

  ## Returns

    - `list()` - The solved grid as a list of lists, or `nil` if no solution exists
      or the initial grid is invalid.

  ## Examples

      iex> grid = [
      ...>   [5, 3, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]
      iex> solved = Sudoku.solve(grid, Sudoku.AlgorithmX)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> grid = [
      ...>   [5, 3, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]
      iex> solved = Sudoku.solve(grid, Sudoku.Backtracking)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true
  """
  @spec solve(list(), atom()) :: list() | nil
  def solve(grid, solver) when is_list(grid) and is_atom(solver) do
    validate_and_solve(grid, solver, :solve)
  end

  @doc """
  Solves a Sudoku puzzle and returns the solving history.

  Returns a list of grid states representing each step of the solving process.
  This is useful for visualization and understanding how the algorithm works.

  The grid is validated before solving. If the initial grid is invalid
  (contains conflicting values), `nil` is returned.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.

  ## Returns

    - `list()` - A list of grid states (each state is a list of lists), or `nil`
      if no solution exists or the initial grid is invalid. The first element
      is the initial state, and the last element is the solved grid.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.solve_log(grid)
      iex> length(history) > 0
      true
      iex> List.first(history)
      [[1, 2, 0, 0], [0, 0, 1, 2], [2, 1, 0, 0], [0, 0, 2, 1]]
      iex> solved = List.last(history)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true
  """
  @spec solve_log(list()) :: list() | nil
  def solve_log(grid) when is_list(grid) do
    validate_and_solve(grid, @default_solver, :solve_log)
  end

  @doc """
  Solves a Sudoku puzzle using a specified solver and returns the solving history.

  Returns a list of grid states representing each step of the solving process.
  For `Sudoku.AlgorithmX`, the history contains tuples of `{grid, matrix}` where
  `matrix` is the current exact cover matrix state.

  The grid is validated before solving. If the initial grid is invalid
  (contains conflicting values), `nil` is returned.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.
    - `solver` - The solver module to use. Must be `Sudoku.Backtracking` or
      `Sudoku.AlgorithmX`.

  ## Returns

    - `list()` - A list of grid states or `{grid, matrix}` tuples, or `nil`
      if no solution exists or the initial grid is invalid. The first element
      is the initial state, and the last element is the solved grid.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.solve_log(grid, Sudoku.Backtracking)
      iex> length(history) > 0
      true

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.solve_log(grid, Sudoku.AlgorithmX)
      iex> {grid_state, _matrix} = List.first(history)
      iex> is_list(grid_state)
      true
  """
  @spec solve_log(list(), atom()) :: list() | nil
  def solve_log(grid, solver) when is_list(grid) and is_atom(solver) do
    validate_and_solve(grid, solver, :solve_log)
  end

  @doc false
  # Validates the grid and solves it using the specified solver and operation type.
  #
  # This is a helper function that validates the initial grid before solving.
  # If the grid is invalid (contains conflicts), returns `nil` without attempting
  # to solve. Otherwise, delegates to the specified solver.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `solver` - The solver module to use (`Sudoku.Backtracking` or `Sudoku.AlgorithmX`).
  #   - `:solve` - Operation type indicating to return only the solved grid.
  #
  # ## Returns
  #
  #   - `list() | nil` - Solved grid or `nil` if invalid or unsolvable.
  defp validate_and_solve(grid, solver, :solve) do
    if Sudoku.Validator.valid_initial_grid?(grid) do
      solver.solve(grid)
    else
      nil
    end
  end

  @doc false
  # Validates the grid and solves it with history tracking.
  #
  # Similar to `validate_and_solve/3` with `:solve`, but returns the solving history
  # instead of just the final solution.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `solver` - The solver module to use (`Sudoku.Backtracking` or `Sudoku.AlgorithmX`).
  #   - `:solve_log` - Operation type indicating to return the solving history.
  #
  # ## Returns
  #
  #   - `list() | nil` - List of grid states or `nil` if invalid or unsolvable.
  defp validate_and_solve(grid, solver, :solve_log) do
    if Sudoku.Validator.valid_initial_grid?(grid) do
      solver.solve_log(grid)
    else
      nil
    end
  end
end
