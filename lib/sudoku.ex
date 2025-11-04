defmodule Sudoku do
  @moduledoc """
  Sudoku solver using depth-first search (backtracking algorithm).
  """

  @doc """
  Solves a sudoku puzzle using depth-first search.

  Receives a 9x9 grid as a list of lists where:
  - 0 or nil represents an empty cell
  - 1-9 represents a filled cell

  Returns the solved sudoku if a solution exists, nil otherwise.

  ## Examples

      iex> puzzle = [
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
      iex> solution = Sudoku.solve(puzzle)
      iex> solution != nil
      true

  """
  def solve(grid) when is_list(grid) do
    grid
    |> normalize_grid()
    |> dfs_solve()
  end

  # Normalizes the grid: converts nil to 0 and ensures proper format
  defp normalize_grid(grid) do
    Enum.map(grid, fn row ->
      Enum.map(row, fn cell -> if cell == nil, do: 0, else: cell end)
    end)
  end

  # Depth-first search solver using backtracking
  defp dfs_solve(grid) do
    case find_empty_cell(grid) do
      nil -> grid  # No empty cells, puzzle is solved
      {row, col} -> try_values(grid, row, col, 1)
    end
  end

  # Finds the next empty cell (value 0)
  defp find_empty_cell(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce_while(nil, fn {row, row_idx}, _acc ->
      case Enum.find_index(row, &(&1 == 0)) do
        nil -> {:cont, nil}
        col_idx -> {:halt, {row_idx, col_idx}}
      end
    end)
  end

  # Tries values 1-9 for a given cell using DFS
  defp try_values(_grid, _row, _col, num) when num > 9, do: nil

  defp try_values(grid, row, col, num) do
    if valid_move?(grid, row, col, num) do
      # Make the move
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      # Recurse with DFS
      case dfs_solve(new_grid) do
        nil -> try_values(grid, row, col, num + 1)  # Backtrack: try next number
        solved -> solved  # Solution found
      end
    else
      # Invalid move, try next number
      try_values(grid, row, col, num + 1)
    end
  end


  # validation moves
  defp valid_move?(grid, row, col, num) do
    valid_in_row?(grid, row, num) and
      valid_in_col?(grid, col, num) and
      valid_in_box?(grid, row, col, num)
  end

  defp valid_in_row?(grid, row, num) do
    row_data = Enum.at(grid, row)
    not Enum.member?(row_data, num)
  end

  defp valid_in_col?(grid, col, num) do
    col_data = Enum.map(grid, &Enum.at(&1, col))
    not Enum.member?(col_data, num)
  end

  defp valid_in_box?(grid, row, col, num) do
    box_start_row = div(row, 3) * 3
    box_start_col = div(col, 3) * 3

    box_data =
      for r <- box_start_row..(box_start_row + 2),
          c <- box_start_col..(box_start_col + 2) do
        grid |> Enum.at(r) |> Enum.at(c)
      end

    not Enum.member?(box_data, num)
  end
end
