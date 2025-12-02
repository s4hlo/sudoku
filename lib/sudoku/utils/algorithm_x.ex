defmodule Sudoku.Utils.AlgorithmX do
  # Build binary matrix A where:
  # - Each row represents a choice (placing number n in cell r,c)
  # - Each column represents a constraint
  # - A[r, c] = 1 means row r satisfies constraint c
  def build_exact_cover_matrix(grid, order) do
    grid_size = order * order
    # Generate all possible choices (rows)
    rows =
      for r <- 0..(grid_size - 1),
          c <- 0..(grid_size - 1),
          n <- 1..grid_size,
          into: [] do
        # Check if this choice is already fixed in the grid
        current_value = grid |> Enum.at(r) |> Enum.at(c)

        if current_value == 0 or current_value == n do
          {r, c, n}
        else
          nil
        end
      end
      |> Enum.filter(&(&1 != nil))

    # Build binary matrix: list of {constraints, choice} where constraints is a MapSet of column indices
    Enum.map(rows, fn {r, c, n} = choice ->
      constraints = calculate_constraints(r, c, n, order)
      {constraints, choice}
    end)
  end

  # Calculate constraint indices (columns) for a choice (r, c, n)
  # Constraints are:
  # 1. Cell constraint: cell (r, c) must have a number (0..grid_size²-1)
  # 2. Row constraint: row r must have number n (grid_size²..2*grid_size²-1)
  # 3. Column constraint: column c must have number n (2*grid_size²..3*grid_size²-1)
  # 4. Box constraint: box containing (r, c) must have number n (3*grid_size²..4*grid_size²-1)
  defp calculate_constraints(r, c, n, order) do
    grid_size = order * order
    cell_constraint = r * grid_size + c
    row_constraint = grid_size * grid_size + r * grid_size + (n - 1)
    col_constraint = 2 * grid_size * grid_size + c * grid_size + (n - 1)

    box_row = div(r, order)
    box_col = div(c, order)
    box_index = box_row * order + box_col
    box_constraint = 3 * grid_size * grid_size + box_index * grid_size + (n - 1)

    MapSet.new([cell_constraint, row_constraint, col_constraint, box_constraint])
  end

  # Convert solution (list of {r, c, n} tuples) back to grid format
  def solution_to_grid(solution, original_grid) do
    order = Sudoku.Utils.calculate_order(original_grid)
    grid_size = order * order
    # Create a map from (r, c) to n
    solution_map =
      Enum.reduce(solution, %{}, fn {r, c, n}, acc ->
        Map.put(acc, {r, c}, n)
      end)

    # Build grid
    for r <- 0..(grid_size - 1) do
      for c <- 0..(grid_size - 1) do
        # Use solution value if available, otherwise use original grid value
        Map.get(solution_map, {r, c}, original_grid |> Enum.at(r) |> Enum.at(c))
      end
    end
  end
end
