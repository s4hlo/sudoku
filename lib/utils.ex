defmodule Utils do
  def find_empty_cell(grid) do
    grid
    |> Enum.with_index()
    |> Enum.reduce_while(nil, fn {row, row_idx}, _acc ->
      case Enum.find_index(row, &(&1 == 0)) do
        nil -> {:cont, nil}
        col_idx -> {:halt, {row_idx, col_idx}}
      end
    end)
  end

  def calculate_box_size(grid_size) do
    trunc(:math.sqrt(grid_size))
  end
end
