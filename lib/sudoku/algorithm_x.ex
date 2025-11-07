defmodule Sudoku.AlgorithmX do
  @moduledoc """
  Solves Sudoku puzzles using Algorithm X (exact cover) with dancing links.
  
  This implementation uses Donald Knuth's Algorithm X to solve Sudoku as an exact cover problem.
  """

  def solve(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)
    
    # Validate initial grid doesn't violate constraints
    if not valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      # Build exact cover matrix from initial grid
      matrix = build_exact_cover_matrix(grid, grid_size, box_size)
      
      # Solve using Algorithm X
      case algorithm_x(matrix, []) do
        nil -> nil
        solution -> solution_to_grid(solution, grid, grid_size)
      end
    end
  end

  # Validate that initial grid doesn't violate Sudoku constraints
  defp valid_initial_grid?(grid, grid_size, box_size) do
    # Check for duplicates in rows, columns, and boxes
    valid_rows?(grid, grid_size) and
      valid_cols?(grid, grid_size) and
      valid_boxes?(grid, grid_size, box_size)
  end

  defp valid_rows?(grid, _grid_size) do
    Enum.all?(grid, fn row ->
      filled = Enum.filter(row, &(&1 != 0 and &1 != nil))
      length(filled) == length(Enum.uniq(filled))
    end)
  end

  defp valid_cols?(grid, grid_size) do
    Enum.all?(0..(grid_size - 1), fn col ->
      col_data = Enum.map(grid, &Enum.at(&1, col))
      filled = Enum.filter(col_data, &(&1 != 0 and &1 != nil))
      length(filled) == length(Enum.uniq(filled))
    end)
  end

  defp valid_boxes?(grid, grid_size, box_size) do
    num_boxes = div(grid_size, box_size)
    
    Enum.all?(0..(num_boxes - 1), fn box_row ->
      Enum.all?(0..(num_boxes - 1), fn box_col ->
        start_row = box_row * box_size
        start_col = box_col * box_size
        
        box_data =
          for r <- start_row..(start_row + box_size - 1),
              c <- start_col..(start_col + box_size - 1) do
            grid |> Enum.at(r) |> Enum.at(c)
          end
        
        filled = Enum.filter(box_data, &(&1 != 0 and &1 != nil))
        length(filled) == length(Enum.uniq(filled))
      end)
    end)
  end

  # Build exact cover matrix representation
  # Each row represents a choice (placing number n in cell r,c)
  # Each column represents a constraint
  defp build_exact_cover_matrix(grid, grid_size, box_size) do
    # Generate all possible choices and their constraints
    for r <- 0..(grid_size - 1),
        c <- 0..(grid_size - 1),
        n <- 1..grid_size,
        into: [] do
      # Check if this choice is already fixed in the grid
      current_value = grid |> Enum.at(r) |> Enum.at(c)
      
      if current_value == 0 or current_value == n do
        # Calculate constraint indices
        constraints = calculate_constraints(r, c, n, grid_size, box_size)
        {r, c, n, constraints}
      else
        nil
      end
    end
    |> Enum.filter(&(&1 != nil))
  end

  # Calculate constraint indices for a choice (r, c, n)
  # Constraints are:
  # 1. Cell constraint: cell (r, c) must have a number (0..grid_size²-1)
  # 2. Row constraint: row r must have number n (grid_size²..2*grid_size²-1)
  # 3. Column constraint: column c must have number n (2*grid_size²..3*grid_size²-1)
  # 4. Box constraint: box containing (r, c) must have number n (3*grid_size²..4*grid_size²-1)
  defp calculate_constraints(r, c, n, grid_size, box_size) do
    cell_constraint = r * grid_size + c
    row_constraint = grid_size * grid_size + r * grid_size + (n - 1)
    col_constraint = 2 * grid_size * grid_size + c * grid_size + (n - 1)
    
    box_row = div(r, box_size)
    box_col = div(c, box_size)
    box_index = box_row * div(grid_size, box_size) + box_col
    box_constraint = 3 * grid_size * grid_size + box_index * grid_size + (n - 1)
    
    MapSet.new([cell_constraint, row_constraint, col_constraint, box_constraint])
  end

  # Algorithm X implementation
  defp algorithm_x(matrix, partial_solution) do
    cond do
      # Base case: all constraints are covered (matrix is empty)
      matrix == [] ->
        partial_solution
      
      # Find constraint with minimum choices
      true ->
        case select_constraint(matrix) do
          nil -> nil
          selected_constraint ->
            # Find all rows that cover this constraint
            covering_rows = find_rows_covering_constraint(matrix, selected_constraint)
            
            if covering_rows == [] do
              # No way to cover this constraint - backtrack
              nil
            else
              # Try each row
              try_rows(matrix, covering_rows, partial_solution)
            end
        end
    end
  end

  # Select constraint column with minimum choices (minimum remaining values heuristic)
  defp select_constraint(matrix) do
    # Count how many choices cover each constraint
    constraint_counts =
      Enum.reduce(matrix, %{}, fn {_r, _c, _n, constraints}, acc ->
        Enum.reduce(constraints, acc, fn constraint, acc2 ->
          Map.update(acc2, constraint, 1, &(&1 + 1))
        end)
      end)
    
    # Find constraint with minimum count (but > 0)
    case constraint_counts do
      map when map == %{} -> nil
      _ -> 
        {constraint, _count} = Enum.min_by(constraint_counts, fn {_k, v} -> v end)
        constraint
    end
  end

  # Find all rows (choices) that cover a given constraint
  defp find_rows_covering_constraint(matrix, constraint) do
    Enum.filter(matrix, fn {_r, _c, _n, constraints} ->
      MapSet.member?(constraints, constraint)
    end)
  end

  # Try each row that covers the selected constraint
  defp try_rows(_matrix, [], _partial_solution), do: nil

  defp try_rows(matrix, [row | rest], partial_solution) do
    {r, c, n, constraints} = row
    
    # Remove all rows that conflict with this row (share any constraint)
    # This includes the row itself
    new_matrix = remove_conflicting_rows(matrix, constraints)
    
    # Add this row to partial solution
    new_partial_solution = [{r, c, n} | partial_solution]
    
    # Recursively solve
    case algorithm_x(new_matrix, new_partial_solution) do
      nil -> try_rows(matrix, rest, partial_solution)
      solution -> solution
    end
  end

  # Remove rows that conflict with the selected row (share any constraint)
  defp remove_conflicting_rows(matrix, constraints_to_remove) do
    Enum.reject(matrix, fn {_r, _c, _n, constraints} ->
      # Remove if this row shares any constraint with constraints_to_remove
      MapSet.intersection(constraints, constraints_to_remove) != MapSet.new()
    end)
  end

  # Convert solution (list of {r, c, n} tuples) back to grid format
  defp solution_to_grid(solution, original_grid, grid_size) do
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
