defmodule Sudoku.Utils do

  @spec deep_copy(list()) :: list()
  def deep_copy(grid) do
    Enum.map(grid, fn row -> Enum.map(row, & &1) end)
  end

  @spec find_empty_cell(list()) :: {non_neg_integer(), non_neg_integer()} | nil
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

  @spec calculate_order(list()) :: non_neg_integer()
  def calculate_order(grid) do
    grid_size = length(grid)
    trunc(:math.sqrt(grid_size))
  end

  @spec create_puzzle_from_solved(list(), float() | integer()) :: list()
  def create_puzzle_from_solved(solved_grid, reduction_percentage)
      when is_float(reduction_percentage) or is_integer(reduction_percentage) do
    grid_size = length(solved_grid)
    total_cells = grid_size * grid_size
    cells_to_zero = trunc(total_cells * reduction_percentage)

    # Generate list of all positions (row, col)
    all_positions =
      for row <- 0..(grid_size - 1),
          col <- 0..(grid_size - 1) do
        {row, col}
      end

    # Randomly select positions to zero out
    positions_to_zero =
      all_positions
      |> Enum.shuffle()
      |> Enum.take(cells_to_zero)

    # Create a map set for fast lookup
    zero_positions_map = MapSet.new(positions_to_zero)

    # Create the puzzle by zeroing out selected positions
    solved_grid
    |> Enum.with_index()
    |> Enum.map(fn {row, row_idx} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {value, col_idx} ->
        if MapSet.member?(zero_positions_map, {row_idx, col_idx}) do
          0
        else
          value
        end
      end)
    end)
  end
end
