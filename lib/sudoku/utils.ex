defmodule Sudoku.Utils do
  def deep_copy(grid) do
    Enum.map(grid, fn row -> Enum.map(row, & &1) end)
  end

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

  def calculate_order(grid) do
    grid_size = length(grid)
    trunc(:math.sqrt(grid_size))
  end

  def create_puzzle_from_solved(solved_grid, reduction_percentage)
      when is_float(reduction_percentage) or is_integer(reduction_percentage) do
    grid_size = length(solved_grid)
    total_cells = grid_size * grid_size
    cells_to_zero = trunc(total_cells * reduction_percentage)

    # Gera lista de todas as posições (row, col)
    all_positions =
      for row <- 0..(grid_size - 1),
          col <- 0..(grid_size - 1) do
        {row, col}
      end

    # Seleciona aleatoriamente as posições a zerar
    positions_to_zero =
      all_positions
      |> Enum.shuffle()
      |> Enum.take(cells_to_zero)

    # Cria um mapa com as posições a zerar para busca rápida
    zero_positions_map = MapSet.new(positions_to_zero)

    # Cria o puzzle zerando as posições selecionadas
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
