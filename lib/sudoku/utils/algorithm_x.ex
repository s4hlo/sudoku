defmodule Sudoku.Utils.AlgorithmX do
  @moduledoc """
  Utility functions for Algorithm X implementation.

  This module provides helper functions for converting Sudoku puzzles into
  exact cover problem matrices and converting solutions back to grid format.
  These functions are used internally by `Sudoku.AlgorithmX` to implement
  Donald Knuth's Algorithm X for solving Sudoku puzzles.
  """

  @doc """
  Builds an exact cover matrix representation of a Sudoku puzzle.

  Converts a Sudoku grid into a binary matrix where:
  - Each row represents a possible choice (placing number `n` in cell `(r, c)`)
  - Each column represents a constraint that must be satisfied
  - A matrix entry `A[r, c] = 1` means row `r` satisfies constraint `c`

  The matrix is represented as a list of `{constraints, choice}` tuples where:
  - `constraints` is a `MapSet` of column indices (constraints) that this choice satisfies
  - `choice` is a tuple `{r, c, n}` representing placing number `n` in cell `(r, c)`

  Only valid choices are included:
  - If a cell is empty (0), all numbers 1..grid_size are possible choices
  - If a cell has a value, only that specific choice is included

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.
    - `order` - The order (box size) of the Sudoku grid.

  ## Returns

    - `list()` - A list of `{constraints, choice}` tuples where:
      - `constraints` is a `MapSet` of constraint column indices
      - `choice` is a tuple `{r, c, n}` representing a valid placement

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> matrix = Sudoku.Utils.AlgorithmX.build_exact_cover_matrix(grid, 2)
      iex> length(matrix) > 0
      true
      iex> {constraints, {0, 0, 1}} = List.first(matrix)
      iex> MapSet.size(constraints)
      4

  ## Constraint Structure

  The exact cover matrix has `4 × grid_size²` columns representing four types
  of constraints:

  1. **Cell constraints** (columns 0..grid_size²-1): Each cell must have exactly one number
  2. **Row constraints** (columns grid_size²..2×grid_size²-1): Each row must contain each number exactly once
  3. **Column constraints** (columns 2×grid_size²..3×grid_size²-1): Each column must contain each number exactly once
  4. **Box constraints** (columns 3×grid_size²..4×grid_size²-1): Each box must contain each number exactly once

  Each choice `{r, c, n}` satisfies exactly 4 constraints (one of each type).
  """
  @spec build_exact_cover_matrix(list(), non_neg_integer()) :: list()
  def build_exact_cover_matrix(grid, order) do
    grid_size = order * order
    # Generate all possible choices (rows)
    rows =
      for r <- 0..(grid_size - 1),
          c <- 0..(grid_size - 1),
          n <- 1..grid_size,
          into: [] do
        # Check if this choice is already fixed in the grid
        current_value = grid |> Enum.at(r) |> Enum.at(c)

        if current_value == 0 or current_value == n do
          {r, c, n}
        else
          nil
        end
      end
      |> Enum.filter(&(&1 != nil))

    # Build binary matrix: list of {constraints, choice} where constraints is a MapSet of column indices
    Enum.map(rows, fn {r, c, n} = choice ->
      constraints = calculate_constraints(r, c, n, order)
      {constraints, choice}
    end)
  end

  @doc false
  # Calculates the constraint column indices for a given choice.
  #
  # For a choice `{r, c, n}` (placing number `n` in cell `(r, c)`), this function
  # calculates the four constraint columns that this choice satisfies:
  #
  # 1. Cell constraint: cell `(r, c)` must have a number
  #    Column index: `r × grid_size + c`
  #
  # 2. Row constraint: row `r` must have number `n`
  #    Column index: `grid_size² + r × grid_size + (n - 1)`
  #
  # 3. Column constraint: column `c` must have number `n`
  #    Column index: `2 × grid_size² + c × grid_size + (n - 1)`
  #
  # 4. Box constraint: the box containing `(r, c)` must have number `n`
  #    Column index: `3 × grid_size² + box_index × grid_size + (n - 1)`
  #
  # ## Parameters
  #
  #   - `r` - Row index (0-based)
  #   - `c` - Column index (0-based)
  #   - `n` - Number to place (1..grid_size)
  #   - `order` - Order of the Sudoku grid
  #
  # ## Returns
  #
  #   - `MapSet.t()` - A MapSet containing the four constraint column indices
  defp calculate_constraints(r, c, n, order) do
    grid_size = order * order
    cell_constraint = r * grid_size + c
    row_constraint = grid_size * grid_size + r * grid_size + (n - 1)
    col_constraint = 2 * grid_size * grid_size + c * grid_size + (n - 1)

    box_row = div(r, order)
    box_col = div(c, order)
    box_index = box_row * order + box_col
    box_constraint = 3 * grid_size * grid_size + box_index * grid_size + (n - 1)

    MapSet.new([cell_constraint, row_constraint, col_constraint, box_constraint])
  end

  @doc """
  Converts an Algorithm X solution back to Sudoku grid format.

  Takes a solution (list of `{r, c, n}` tuples representing choices) and
  reconstructs the complete Sudoku grid. Cells not present in the solution
  retain their original values from the input grid.

  ## Parameters

    - `solution` - A list of `{r, c, n}` tuples representing the choices
      made by Algorithm X. Each tuple means "place number `n` in cell `(r, c)`".
    - `original_grid` - The original Sudoku grid before solving. Used to
      preserve any cells not modified by the solution.

  ## Returns

    - `list()` - A complete Sudoku grid (list of lists) with all cells filled.

  ## Examples

      iex> solution = [{0, 2, 3}, {0, 3, 4}, {1, 0, 3}, {1, 1, 4}, {2, 2, 4}, {2, 3, 3}, {3, 0, 4}, {3, 1, 3}]
      iex> original = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> solved = Sudoku.Utils.AlgorithmX.solution_to_grid(solution, original)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> solution = []
      iex> original = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> Sudoku.Utils.AlgorithmX.solution_to_grid(solution, original)
      [[1, 2, 3, 4], [3, 4, 1, 2], [2, 1, 4, 3], [4, 3, 2, 1]]
  """
  @spec solution_to_grid(list(), list()) :: list()
  def solution_to_grid(solution, original_grid) do
    order = Sudoku.Utils.calculate_order(original_grid)
    grid_size = order * order
    # Create a map from (r, c) to n
    solution_map =
      Enum.reduce(solution, %{}, fn {r, c, n}, acc ->
        Map.put(acc, {r, c}, n)
      end)

    # Build grid
    for r <- 0..(grid_size - 1) do
      for c <- 0..(grid_size - 1) do
        # Use solution value if available, otherwise use original grid value
        Map.get(solution_map, {r, c}, original_grid |> Enum.at(r) |> Enum.at(c))
      end
    end
  end
end
