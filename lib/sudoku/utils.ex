defmodule Sudoku.Utils do
  @moduledoc """
  Utility functions for Sudoku grid manipulation and calculations.

  This module provides helper functions used throughout the Sudoku solving
  library for common operations such as finding empty cells, calculating grid
  properties, and creating puzzles from solved grids.
  """

  @doc """
  Creates a deep copy of a Sudoku grid.

  This function creates a completely independent copy of the grid structure,
  ensuring that modifications to the returned grid do not affect the original.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.

  ## Returns

    - `list()` - A new grid that is a deep copy of the input grid.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> copy = Sudoku.Utils.deep_copy(grid)
      iex> copy == grid
      true
      iex> copy !== grid
      true
  """
  @spec deep_copy(list()) :: list()
  def deep_copy(grid) do
    Enum.map(grid, fn row -> Enum.map(row, & &1) end)
  end

  @doc """
  Finds the first empty cell in the Sudoku grid.

  Searches the grid from top-left to bottom-right (row by row) and returns
  the coordinates of the first cell containing `0` (empty cell).

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.

  ## Returns

    - `{row, col}` - A tuple with the row and column indices (0-based) of the
      first empty cell, or `nil` if no empty cells are found.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.Utils.find_empty_cell(grid)
      {0, 2}

      iex> grid = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> Sudoku.Utils.find_empty_cell(grid)
      nil
  """
  @spec find_empty_cell(list()) :: {non_neg_integer(), non_neg_integer()} | nil
  def find_empty_cell(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce_while(nil, fn {row, row_idx}, _acc ->
      case Enum.find_index(row, &(&1 == 0)) do
        nil -> {:cont, nil}
        col_idx -> {:halt, {row_idx, col_idx}}
      end
    end)
  end

  @doc """
  Calculates the order (box size) of a Sudoku grid.

  The order is the square root of the grid size. For example:
  - A 9×9 grid has order 3 (since 3×3 = 9)
  - A 4×4 grid has order 2 (since 2×2 = 4)
  - A 16×16 grid has order 4 (since 4×4 = 16)

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.

  ## Returns

    - `non_neg_integer()` - The order of the grid (box size).

  ## Examples

      iex> grid = [[1, 2, 3, 4], [2, 1, 4, 3], [3, 4, 1, 2], [4, 3, 2, 1]]
      iex> Sudoku.Utils.calculate_order(grid)
      2

      iex> grid = List.duplicate(List.duplicate(0, 9), 9)
      iex> Sudoku.Utils.calculate_order(grid)
      3
  """
  @spec calculate_order(list()) :: non_neg_integer()
  def calculate_order(grid) do
    grid_size = length(grid)
    trunc(:math.sqrt(grid_size))
  end

  @doc """
  Creates a puzzle from a solved Sudoku grid by removing a percentage of cells.

  This function takes a completely solved Sudoku grid and randomly removes
  a specified percentage of cells (sets them to 0) to create a puzzle. The
  positions to remove are selected randomly using `Enum.shuffle/1`.

  ## Parameters

    - `solved_grid` - A completely solved Sudoku grid (list of lists).
    - `reduction_percentage` - A float or integer between 0 and 1 representing
      the percentage of cells to remove. For example, `0.5` removes 50% of cells.

  ## Returns

    - `list()` - A new grid with the specified percentage of cells set to 0.

  ## Examples

      iex> solved = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> puzzle = Sudoku.Utils.create_puzzle_from_solved(solved, 0.5)
      iex> # Approximately 50% of cells will be 0
      iex> length(Enum.filter(List.flatten(puzzle), &(&1 == 0)))
      8

      iex> solved = [[1, 2, 3, 4], [2, 1, 4, 3], [3, 4, 1, 2], [4, 3, 2, 1]]
      iex> puzzle = Sudoku.Utils.create_puzzle_from_solved(solved, 0.25)
      iex> length(Enum.filter(List.flatten(puzzle), &(&1 == 0)))
      4
  """
  @spec create_puzzle_from_solved(list(), float() | integer()) :: list()
  def create_puzzle_from_solved(solved_grid, reduction_percentage)
      when is_float(reduction_percentage) or is_integer(reduction_percentage) do
    grid_size = length(solved_grid)
    total_cells = grid_size * grid_size
    cells_to_zero = trunc(total_cells * reduction_percentage)

    # Generate list of all positions (row, col)
    all_positions =
      for row <- 0..(grid_size - 1),
          col <- 0..(grid_size - 1) do
        {row, col}
      end

    # Randomly select positions to zero out
    positions_to_zero =
      all_positions
      |> Enum.shuffle()
      |> Enum.take(cells_to_zero)

    # Create a map set for fast lookup
    zero_positions_map = MapSet.new(positions_to_zero)

    # Create the puzzle by zeroing out selected positions
    solved_grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {value, col_idx} ->
        if MapSet.member?(zero_positions_map, {row_idx, col_idx}) do
          0
        else
          value
        end
      end)
    end)
  end
end
