defmodule Validator do
  def valid_initial_grid?(grid, grid_size, box_size) do
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
          Validator.valid_move?(temp_grid, row, col, value, box_size)
        end
      end)
    end)
  end

  # Remove a cell's value from the grid (set to 0) for validation purposes
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

  def valid_move?(grid, row, col, num, box_size) do
    valid_in_row?(grid, row, num) and
      valid_in_col?(grid, col, num) and
      valid_in_box?(grid, row, col, num, box_size)
  end

  defp valid_in_row?(grid, row, num) do
    row_data = Enum.at(grid, row)
    not Enum.member?(row_data, num)
  end

  defp valid_in_col?(grid, col, num) do
    col_data = Enum.map(grid, &Enum.at(&1, col))
    not Enum.member?(col_data, num)
  end

  defp valid_in_box?(grid, row, col, num, box_size) do
    box_start_row = div(row, box_size) * box_size
    box_start_col = div(col, box_size) * box_size

    box_data =
      for r <- box_start_row..(box_start_row + box_size - 1),
          c <- box_start_col..(box_start_col + box_size - 1) do
        grid |> Enum.at(r) |> Enum.at(c)
      end

    not Enum.member?(box_data, num)
  end

  def is_valid_solution?(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)

    all_filled?(grid) and
      all_rows_valid?(grid, grid_size) and
      all_cols_valid?(grid, grid_size) and
      all_boxes_valid?(grid, box_size, grid_size)
  end

  defp all_filled?(grid) do
    Enum.all?(grid, fn row ->
      Enum.all?(row, &(&1 != 0 and &1 != nil))
    end)
  end

  defp all_rows_valid?(grid, grid_size) do
    Enum.all?(grid, fn row ->
      Enum.sort(row) == Enum.to_list(1..grid_size)
    end)
  end

  defp all_cols_valid?(grid, grid_size) do
    Enum.all?(0..(grid_size - 1), fn col ->
      col_data = Enum.map(grid, &Enum.at(&1, col))
      Enum.sort(col_data) == Enum.to_list(1..grid_size)
    end)
  end

  defp all_boxes_valid?(grid, box_size, grid_size) do
    num_boxes = div(length(grid), box_size)

    Enum.all?(0..(num_boxes - 1), fn box_row ->
      Enum.all?(0..(num_boxes - 1), fn box_col ->
        start_row = box_row * box_size
        start_col = box_col * box_size

        box_data =
          for r <- start_row..(start_row + box_size - 1),
              c <- start_col..(start_col + box_size - 1) do
            grid |> Enum.at(r) |> Enum.at(c)
          end

        Enum.sort(box_data) == Enum.to_list(1..grid_size)
      end)
    end)
  end
end
