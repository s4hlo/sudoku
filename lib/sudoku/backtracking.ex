defmodule Sudoku.Backtracking do
  @spec solve(list()) :: list() | nil
  def solve(grid) when is_list(grid) do
    order = Sudoku.Utils.calculate_order(grid)
    case Sudoku.Utils.find_empty_cell(grid) do
      nil -> grid
      {row, col} -> try_values(grid, row, col, 1, order)
    end
  end

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

  @spec solve_log(list()) :: list() | nil
  def solve_log(grid) when is_list(grid) do
    initial_state = Sudoku.Utils.deep_copy(grid)
    case solve_with_history(grid, [initial_state]) do
      {nil, _history} -> nil
      {_solved, history} -> history
    end
  end

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
