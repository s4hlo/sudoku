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
    if valid_move?(grid, row, col, num) do
      new_grid = put_in(grid, [Access.at(row), Access.at(col)], num)

      case solve(new_grid) do
        nil -> try_values(grid, row, col, num + 1)
        solved -> solved
      end
    else
      try_values(grid, row, col, num + 1)
    end
  end

  # --------------------- validation functions ------------------------

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
