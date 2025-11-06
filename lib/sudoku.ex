defmodule Sudoku do
  def solve(grid) when is_list(grid) do
    case find_empty_cell(grid) do
      nil -> grid
      {row, col} -> try_values(grid, row, col, 1)
    end
  end

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

  defp try_values(_grid, _row, _col, num) when num > 9, do: nil

  defp try_values(grid, row, col, num) do
    if Validator.valid_move?(grid, row, col, num, 3) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      case solve(new_grid) do
        nil -> try_values(grid, row, col, num + 1)
        solved -> solved
      end
    else
      try_values(grid, row, col, num + 1)
    end
  end
end
