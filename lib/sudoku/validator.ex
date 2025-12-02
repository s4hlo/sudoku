defmodule Sudoku.Validator do
  @moduledoc """
  Validates Sudoku grids and moves according to Sudoku rules.

  This module provides functions to validate:
  - Initial grids (checking for conflicts in given values)
  - Individual moves (checking if a number can be placed in a cell)
  - Complete solutions (verifying all constraints are satisfied)

  ## Sudoku Rules

  A valid Sudoku grid must satisfy these constraints:
  1. Each row must contain the numbers 1 through grid_size exactly once
  2. Each column must contain the numbers 1 through grid_size exactly once
  3. Each box (order×order subgrid) must contain the numbers 1 through grid_size exactly once
  4. No cell can be empty in a complete solution

  ## Examples

      iex> grid = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> Sudoku.Validator.is_valid_solution?(grid)
      true

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.Validator.valid_initial_grid?(grid)
      true

      iex> grid = [
      ...>   [1, 1, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]  # Conflict in row
      iex> Sudoku.Validator.valid_initial_grid?(grid)
      false
  """

  @doc """
  Validates that an initial grid has no conflicting values.

  Checks that all filled cells in the grid satisfy Sudoku constraints.
  Empty cells (0 or nil) are allowed and not validated.

  This is useful for validating puzzle inputs before solving.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.

  ## Returns

    - `boolean()` - `true` if the grid has no conflicts, `false` otherwise.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.Validator.valid_initial_grid?(grid)
      true

      iex> grid = [
      ...>   [1, 1, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]  # Duplicate in row
      iex> Sudoku.Validator.valid_initial_grid?(grid)
      false

      iex> grid = [
      ...>   [1, 0, 0, 0],
      ...>   [1, 0, 0, 0],
      ...>   [0, 0, 0, 0],
      ...>   [0, 0, 0, 0]
      ...> ]  # Duplicate in column
      iex> Sudoku.Validator.valid_initial_grid?(grid)
      false
  """
  @spec valid_initial_grid?(list()) :: boolean()
  def valid_initial_grid?(grid) do
    order = Sudoku.Utils.calculate_order(grid)
    grid_size = order * order
    # Check each filled cell to ensure it doesn't violate constraints
    Enum.all?(0..(grid_size - 1), fn row ->
      Enum.all?(0..(grid_size - 1), fn col ->
        value = grid |> Enum.at(row) |> Enum.at(col)

        # Empty cells (0 or nil) are always valid
        if value == 0 or value == nil do
          true
        else
          # Temporarily remove this cell's value to check if placing it is valid
          temp_grid = remove_cell_value(grid, row, col)
          Sudoku.Validator.valid_move?(temp_grid, row, col, value)
        end
      end)
    end)
  end

  # Removes a cell's value from the grid (sets it to 0) for validation purposes.
  #
  # This is used to check if a value can be placed in a cell by temporarily
  # removing it and checking if placing it would be valid.
  #
  # Parameters:
  #   - grid: Current grid state
  #   - row: Row index
  #   - col: Column index
  #
  # Returns: New grid with the specified cell set to 0
  defp remove_cell_value(grid, row, col) do
    grid
    |> Enum.with_index()
    |> Enum.map(fn {row_data, r} ->
      if r == row do
        row_data
        |> Enum.with_index()
        |> Enum.map(fn {cell_value, c} ->
          if c == col, do: 0, else: cell_value
        end)
      else
        row_data
      end
    end)
  end

  @doc """
  Checks if placing a number in a cell is valid according to Sudoku rules.

  Validates that the number doesn't violate any constraints:
  - Not already present in the same row
  - Not already present in the same column
  - Not already present in the same box

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.
    - `row` - Row index (0-based) where the number would be placed.
    - `col` - Column index (0-based) where the number would be placed.
    - `num` - The number (1 to grid_size) to check.

  ## Returns

    - `boolean()` - `true` if the move is valid, `false` otherwise.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.Validator.valid_move?(grid, 0, 2, 3)
      true

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.Validator.valid_move?(grid, 0, 2, 1)  # Already in row
      false

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> Sudoku.Validator.valid_move?(grid, 2, 0, 1)  # Already in column
      false
  """
  @spec valid_move?(list(), non_neg_integer(), non_neg_integer(), pos_integer()) :: boolean()
  def valid_move?(grid, row, col, num) do
    valid_in_row?(grid, row, num) and
      valid_in_col?(grid, col, num) and
      valid_in_box?(grid, row, col, num)
  end

  @doc false
  # Checks if a number is valid in a specific row (not already present).
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `row` - Row index (0-based).
  #   - `num` - The number to check.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if the number is not in the row, `false` otherwise.
  defp valid_in_row?(grid, row, num) do
    row_data = Enum.at(grid, row)
    not Enum.member?(row_data, num)
  end

  @doc false
  # Checks if a number is valid in a specific column (not already present).
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `col` - Column index (0-based).
  #   - `num` - The number to check.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if the number is not in the column, `false` otherwise.
  defp valid_in_col?(grid, col, num) do
    col_data = Enum.map(grid, &Enum.at(&1, col))
    not Enum.member?(col_data, num)
  end

  @doc false
  # Checks if a number is valid in a specific box (not already present).
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `row` - Row index (0-based) of the cell.
  #   - `col` - Column index (0-based) of the cell.
  #   - `num` - The number to check.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if the number is not in the box, `false` otherwise.
  defp valid_in_box?(grid, row, col, num) do
    order = Sudoku.Utils.calculate_order(grid)
    box_start_row = div(row, order) * order
    box_start_col = div(col, order) * order

    box_data =
      for r <- box_start_row..(box_start_row + order - 1),
          c <- box_start_col..(box_start_col + order - 1) do
        grid |> Enum.at(r) |> Enum.at(c)
      end

    not Enum.member?(box_data, num)
  end

  @doc """
  Validates that a grid is a complete and valid Sudoku solution.

  Checks that the grid satisfies all Sudoku rules:
  1. All cells are filled (no empty cells)
  2. Each row contains the numbers 1 through grid_size exactly once
  3. Each column contains the numbers 1 through grid_size exactly once
  4. Each box contains the numbers 1 through grid_size exactly once

  This function is more comprehensive than `valid_initial_grid?/1` as it
  verifies that the grid is completely solved, not just that it has no conflicts.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.

  ## Returns

    - `boolean()` - `true` if the grid is a complete valid solution, `false` otherwise.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> Sudoku.Validator.is_valid_solution?(grid)
      true

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]  # Incomplete
      iex> Sudoku.Validator.is_valid_solution?(grid)
      false

      iex> grid = [
      ...>   [1, 1, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]  # Duplicates
      iex> Sudoku.Validator.is_valid_solution?(grid)
      false
  """
  @spec is_valid_solution?(list()) :: boolean()
  def is_valid_solution?(grid) do
    grid_size = length(grid)
    order = trunc(:math.sqrt(grid_size))

    all_filled?(grid) and
      all_rows_valid?(grid, order) and
      all_cols_valid?(grid, order) and
      all_boxes_valid?(grid, order)
  end

  @doc false
  # Checks if all cells in the grid are filled (non-zero and non-nil).
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if all cells are filled, `false` otherwise.
  defp all_filled?(grid) do
    Enum.all?(grid, fn row ->
      Enum.all?(row, &(&1 != 0 and &1 != nil))
    end)
  end

  @doc false
  # Validates that all rows contain the numbers 1 through grid_size exactly once.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `order` - The order (box size) of the Sudoku grid.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if all rows are valid, `false` otherwise.
  defp all_rows_valid?(grid, order) do
    grid_size = order * order
    Enum.all?(grid, fn row ->
      Enum.sort(row) == Enum.to_list(1..grid_size)
    end)
  end

  @doc false
  # Validates that all columns contain the numbers 1 through grid_size exactly once.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `order` - The order (box size) of the Sudoku grid.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if all columns are valid, `false` otherwise.
  defp all_cols_valid?(grid, order) do
    grid_size = order * order
    Enum.all?(0..(grid_size - 1), fn col ->
      col_data = Enum.map(grid, &Enum.at(&1, col))
      Enum.sort(col_data) == Enum.to_list(1..grid_size)
    end)
  end

  @doc false
  # Validates that all boxes contain the numbers 1 through grid_size exactly once.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `order` - The order (box size) of the Sudoku grid.
  #
  # ## Returns
  #
  #   - `boolean()` - `true` if all boxes are valid, `false` otherwise.
  defp all_boxes_valid?(grid, order) do
    grid_size = order * order
    num_boxes = order

    Enum.all?(0..(num_boxes - 1), fn box_row ->
      Enum.all?(0..(num_boxes - 1), fn box_col ->
        start_row = box_row * order
        start_col = box_col * order

        box_data =
          for r <- start_row..(start_row + order - 1),
              c <- start_col..(start_col + order - 1) do
            grid |> Enum.at(r) |> Enum.at(c)
          end

        Enum.sort(box_data) == Enum.to_list(1..grid_size)
      end)
    end)
  end
end
