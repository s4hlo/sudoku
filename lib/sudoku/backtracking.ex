defmodule Sudoku.Backtracking do
  @moduledoc """
  Solves Sudoku puzzles using backtracking (depth-first search) algorithm.

  This module implements a classic backtracking algorithm for solving Sudoku puzzles.
  The algorithm uses depth-first search with constraint checking to find a valid solution.

  ## How It Works

  1. Find the first empty cell in the grid (scanning left-to-right, top-to-bottom).
  2. Try placing numbers 1 through grid_size in that cell.
  3. For each number, check if it's valid according to Sudoku rules:
     - Must not appear in the same row
     - Must not appear in the same column
     - Must not appear in the same box
  4. If valid, place the number and recursively solve the rest of the grid.
  5. If the recursive call fails (returns `nil`), try the next number.
  6. If all numbers fail, backtrack by returning `nil`.
  7. If no empty cells remain, the puzzle is solved.

  ## Time Complexity

  In the worst case, the algorithm explores all possible combinations, making it
  exponential. However, constraint checking prunes many invalid branches early.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> solved = Sudoku.Backtracking.solve(grid)
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
      iex> solved = Sudoku.Backtracking.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true
  """

  @doc """
  Solves a Sudoku puzzle using backtracking.

  Finds the first empty cell and tries placing valid numbers recursively.
  Returns the solved grid or `nil` if no solution exists.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.

  ## Returns

    - `list()` - The solved grid as a list of lists, or `nil` if no solution exists.

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
      iex> solved = Sudoku.Backtracking.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> unsolvable = [
      ...>   [5, 5, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]  # Invalid initial state (conflict in first row)
      iex> Sudoku.Backtracking.solve(unsolvable)
      nil
  """
  @spec solve(list()) :: list() | nil
  def solve(grid) when is_list(grid) do
    order = Sudoku.Utils.calculate_order(grid)
    case Sudoku.Utils.find_empty_cell(grid) do
      nil -> grid
      {row, col} -> try_values(grid, row, col, 1, order)
    end
  end

  @doc false
  # Tries placing numbers in a cell, backtracking when necessary.
  #
  # Recursively tries placing numbers 1 through grid_size in the specified cell.
  # If a number is valid, it places it and recursively solves the rest. If the
  # recursive call fails, it tries the next number. If all numbers fail, returns nil.
  #
  # ## Parameters
  #
  #   - `grid` - Current grid state.
  #   - `row` - Row index of the cell to fill.
  #   - `col` - Column index of the cell to fill.
  #   - `num` - Current number to try (starts at 1).
  #   - `order` - Order of the Sudoku grid (box size).
  #
  # ## Returns
  #
  #   - `list()` - Solved grid or `nil` if no solution exists.
  defp try_values(_grid, _row, _col, num, order) when num > order * order, do: nil
  defp try_values(grid, row, col, num, order) do
    if Sudoku.Validator.valid_move?(grid, row, col, num) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      case solve(new_grid) do
        nil -> try_values(grid, row, col, num + 1, order)
        solved -> solved
      end
    else
      try_values(grid, row, col, num + 1, order)
    end
  end

  @doc """
  Solves a Sudoku puzzle and returns the solving history.

  Similar to `solve/1`, but returns a list of grid states representing each step
  of the solving process. Each state shows the grid after placing a number.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.

  ## Returns

    - `list()` - A list of grid states (each state is a list of lists), or `nil`
      if no solution exists. The first element is the initial state, and the
      last element is the solved grid.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.Backtracking.solve_log(grid)
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
    initial_state = Sudoku.Utils.deep_copy(grid)
    case solve_with_history(grid, [initial_state]) do
      {nil, _history} -> nil
      {_solved, history} -> history
    end
  end

  @doc false
  # Solves the grid with history tracking.
  #
  # Similar to `solve/1`, but accumulates grid states at each step for visualization.
  # Returns both the solved grid and the complete history of states.
  #
  # ## Parameters
  #
  #   - `grid` - Current grid state.
  #   - `history` - Accumulated list of grid states.
  #
  # ## Returns
  #
  #   - `{list(), list()}` - `{solved_grid, history}` tuple or `{nil, history}` if no solution exists.
  defp solve_with_history(grid, history) do
    order = Sudoku.Utils.calculate_order(grid)
    case Sudoku.Utils.find_empty_cell(grid) do
      nil ->
        # Solved - add final state and return grid and history (reversed to show progression)
        final_history = [Sudoku.Utils.deep_copy(grid) | history]
        {grid, Enum.reverse(final_history)}

      {row, col} ->
        try_values_with_history(grid, row, col, 1, order, history)
    end
  end

  @doc false
  # Tries placing numbers in a cell with history tracking.
  #
  # Similar to `try_values/5`, but records each grid state in the history when
  # a number is successfully placed.
  #
  # ## Parameters
  #
  #   - `grid` - Current grid state.
  #   - `row` - Row index of the cell to fill.
  #   - `col` - Column index of the cell to fill.
  #   - `num` - Current number to try (starts at 1).
  #   - `order` - Order of the Sudoku grid (box size).
  #   - `history` - Accumulated history of grid states.
  #
  # ## Returns
  #
  #   - `{list(), list()}` - `{solved_grid, history}` tuple or `{nil, history}` if no solution exists.
  defp try_values_with_history(_grid, _row, _col, num, order, history)
       when num > order * order do
    {nil, history}
  end
  defp try_values_with_history(grid, row, col, num, order, history) do
    if Sudoku.Validator.valid_move?(grid, row, col, num) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)
      # Add snapshot only when a number is actually placed
      updated_history = [Sudoku.Utils.deep_copy(new_grid) | history]

      case solve_with_history(new_grid, updated_history) do
        {nil, final_history} ->
          try_values_with_history(grid, row, col, num + 1, order, final_history)

        {solved, final_history} ->
          {solved, final_history}
      end
    else
      try_values_with_history(grid, row, col, num + 1, order, history)
    end
  end
end
