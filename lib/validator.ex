defmodule Validator do
  def is_valid_solution?(grid) do
    all_filled?(grid) and
      all_rows_valid?(grid) and
      all_cols_valid?(grid) and
      all_boxes_valid?(grid)
  end

  defp all_filled?(grid) do
    Enum.all?(grid, fn row ->
      Enum.all?(row, &(&1 != 0 and &1 != nil))
    end)
  end

  defp all_rows_valid?(grid) do
    Enum.all?(grid, fn row ->
      Enum.sort(row) == Enum.to_list(1..9)
    end)
  end

  defp all_cols_valid?(grid) do
    Enum.all?(0..8, fn col ->
      col_data = Enum.map(grid, &Enum.at(&1, col))
      Enum.sort(col_data) == Enum.to_list(1..9)
    end)
  end

  defp all_boxes_valid?(grid) do
    Enum.all?(0..2, fn box_row ->
      Enum.all?(0..2, fn box_col ->
        start_row = box_row * 3
        start_col = box_col * 3

        box_data =
          for r <- start_row..(start_row + 2),
              c <- start_col..(start_col + 2) do
            grid |> Enum.at(r) |> Enum.at(c)
          end

        Enum.sort(box_data) == Enum.to_list(1..9)
      end)
    end)
  end
end
