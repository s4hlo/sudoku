defmodule Sudoku do
  def solve(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)
    solve(grid, box_size, grid_size)
  end

  defp solve(grid, box_size, max_num) do
    case Utils.find_empty_cell(grid) do
      nil -> grid
      {row, col} -> try_values(grid, row, col, 1, max_num, box_size)
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
end
