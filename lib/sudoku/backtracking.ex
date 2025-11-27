defmodule Sudoku.Backtracking do
  @moduledoc """
  Solves Sudoku puzzles using backtracking (depth-first search) algorithm.
  """
  def solve(grid, grid_size, box_size) when is_list(grid) do
    case Utils.find_empty_cell(grid) do
      nil -> grid
      {row, col} -> try_values(grid, row, col, 1, grid_size, box_size)
    end
  end

  defp try_values(_grid, _row, _col, num, grid_size, _box_size) when num > grid_size, do: nil
  defp try_values(grid, row, col, num, grid_size, box_size) do
    if Validator.valid_move?(grid, row, col, num, box_size) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      case solve(new_grid, grid_size, box_size) do
        nil -> try_values(grid, row, col, num + 1, grid_size, box_size)
        solved -> solved
      end
    else
      try_values(grid, row, col, num + 1, grid_size, box_size)
    end
  end

  def solve_log(grid, grid_size, box_size) when is_list(grid) do
    case solve_with_history(grid, grid_size, box_size, []) do
      {nil, _history} -> nil
      {_solved, history} -> history
    end
  end

  defp solve_with_history(grid, grid_size, box_size, history) do
    case Utils.find_empty_cell(grid) do
      nil ->
        # Solved - add final state and return grid and history (reversed to show progression)
        final_history = [Utils.deep_copy(grid) | history]
        {grid, Enum.reverse(final_history)}

      {row, col} ->
        try_values_with_history(grid, row, col, 1, grid_size, box_size, history)
    end
  end

  defp try_values_with_history(_grid, _row, _col, num, grid_size, _box_size, history)
       when num > grid_size do
    {nil, history}
  end
  defp try_values_with_history(grid, row, col, num, grid_size, box_size, history) do
    if Validator.valid_move?(grid, row, col, num, box_size) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)
      # Add snapshot only when a number is actually placed
      updated_history = [Utils.deep_copy(new_grid) | history]

      case solve_with_history(new_grid, grid_size, box_size, updated_history) do
        {nil, final_history} ->
          try_values_with_history(grid, row, col, num + 1, grid_size, box_size, final_history)

        {solved, final_history} ->
          {solved, final_history}
      end
    else
      try_values_with_history(grid, row, col, num + 1, grid_size, box_size, history)
    end
  end
end
