defmodule Sudoku.Backtracking do
  @moduledoc """
  Solves Sudoku puzzles using backtracking (depth-first search) algorithm.
  """

  def solve(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)
    solve(grid, box_size, grid_size)
  end

  def solve_log(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)
    {_result, history} = solve_with_history(grid, box_size, grid_size, [])
    history
  end

  defp solve(grid, box_size, max_num) do
    case Utils.find_empty_cell(grid) do
      nil -> grid
      {row, col} -> try_values(grid, row, col, 1, max_num, box_size)
    end
  end

  defp solve_with_history(grid, box_size, max_num, history) do
    # Add current state to history
    current_history = [deep_copy(grid) | history]
    
    case Utils.find_empty_cell(grid) do
      nil -> 
        # Solved - return grid and history (reversed to show progression)
        {grid, Enum.reverse(current_history)}
      {row, col} -> 
        try_values_with_history(grid, row, col, 1, max_num, box_size, current_history)
    end
  end

  defp try_values(_grid, _row, _col, num, max_num, _box_size) when num > max_num, do: nil

  defp try_values(grid, row, col, num, max_num, box_size) do
    if Validator.valid_move?(grid, row, col, num, box_size) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      case solve(new_grid, box_size, max_num) do
        nil -> try_values(grid, row, col, num + 1, max_num, box_size)
        solved -> solved
      end
    else
      try_values(grid, row, col, num + 1, max_num, box_size)
    end
  end

  defp try_values_with_history(_grid, _row, _col, num, max_num, _box_size, history) when num > max_num do
    {nil, history}
  end

  defp try_values_with_history(grid, row, col, num, max_num, box_size, history) do
    if Validator.valid_move?(grid, row, col, num, box_size) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      case solve_with_history(new_grid, box_size, max_num, history) do
        {nil, updated_history} -> 
          try_values_with_history(grid, row, col, num + 1, max_num, box_size, updated_history)
        {solved, updated_history} -> 
          {solved, updated_history}
      end
    else
      try_values_with_history(grid, row, col, num + 1, max_num, box_size, history)
    end
  end

  # Deep copy helper to ensure each state in history is independent
  defp deep_copy(grid) do
    Enum.map(grid, fn row -> List.to_tuple(row) end)
    |> Enum.map(&Tuple.to_list/1)
  end
end
