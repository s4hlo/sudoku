defmodule Sudoku.AlgorithmX do
  @moduledoc """
  Solves Sudoku puzzles using Algorithm X (exact cover) with dancing links.
  
  This implementation uses Donald Knuth's Algorithm X to solve Sudoku as an exact cover problem.
  """

  def solve(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)
    
    # Validate initial grid doesn't violate constraints
    if not Validator.valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      # Build exact cover matrix from initial grid
      matrix = Utils.AlgorithmX.build_exact_cover_matrix(grid, grid_size, box_size)
      
      # Solve using Algorithm X
      case algorithm_x(matrix, []) do
        nil -> nil
        solution -> Utils.AlgorithmX.solution_to_grid(solution, grid, grid_size)
      end
    end
  end

  def solve_log(grid) when is_list(grid) do
    # Algorithm X doesn't support history tracking as it doesn't play the game step by step
    # It solves the exact cover problem directly, so we just return the solution
    solve(grid)
  end

  # Algorithm X implementation following the paper's logic:
  # 1. If A is empty, the problem is solved; terminate successfully.
  # 2. Otherwise choose a column, c (deterministically).
  # 3. Choose a row, r, such that A[r, c] = 1 (nondeterministically).
  # 4. Include r in the partial solution.
  # 5. For each j such that A[r, j] = 1,
  #    delete column j from matrix A;
  #    for each i such that A[i, j] = 1,
  #    delete row i from matrix A.
  # 6. Repeat this algorithm recursively on the reduced matrix A.
  defp algorithm_x(matrix, partial_solution) do
    # Step 1: If A is empty, the problem is solved; terminate successfully.
    if matrix == [] do
      partial_solution
    else
      # Step 2: Choose a column, c (deterministically).
      case choose_column(matrix) do
        nil ->
          # No columns left or no solution possible
          nil
        
        column_c ->
          # Step 3: Find all rows r such that A[r, c] = 1
          rows_with_c = find_rows_with_column(matrix, column_c)
          
          if rows_with_c == [] do
            # No row covers this column - backtrack
            nil
          else
            # Try each row r (nondeterministically - we try all possibilities)
            try_rows(matrix, rows_with_c, column_c, partial_solution)
          end
      end
    end
  end

  # Choose a column deterministically (using minimum remaining values heuristic)
  defp choose_column(matrix) do
    # Count how many rows cover each column
    column_counts =
      Enum.reduce(matrix, %{}, fn {constraints, _choice}, acc ->
        Enum.reduce(constraints, acc, fn column, acc2 ->
          Map.update(acc2, column, 1, &(&1 + 1))
        end)
      end)
    
    # Find column with minimum count (but > 0)
    case column_counts do
      map when map == %{} -> nil
      _ ->
        {column, _count} = Enum.min_by(column_counts, fn {_k, v} -> v end)
        column
    end
  end

  # Find all rows r such that A[r, c] = 1
  defp find_rows_with_column(matrix, column_c) do
    Enum.filter(matrix, fn {constraints, _choice} ->
      MapSet.member?(constraints, column_c)
    end)
  end

  # Try each row r that covers column c
  defp try_rows(_matrix, [], _column_c, _partial_solution), do: nil

  defp try_rows(matrix, [{constraints_r, choice} | rest], column_c, partial_solution) do
    # Step 4: Include r in the partial solution
    new_partial_solution = [choice | partial_solution]
    
    # Step 5: For each j such that A[r, j] = 1,
    #         delete column j from matrix A;
    #         for each i such that A[i, j] = 1,
    #         delete row i from matrix A.
    reduced_matrix = reduce_matrix(matrix, constraints_r)
    
    # Step 6: Repeat this algorithm recursively on the reduced matrix A
    case algorithm_x(reduced_matrix, new_partial_solution) do
      nil -> try_rows(matrix, rest, column_c, partial_solution)
      solution -> solution
    end
  end

  # Reduce matrix by deleting columns and rows as specified in the algorithm
  # For each j such that A[r, j] = 1:
  #   - delete column j from matrix A
  #   - for each i such that A[i, j] = 1, delete row i from matrix A
  defp reduce_matrix(matrix, columns_to_delete) do
    # Find all rows that need to be deleted (rows that have any column in columns_to_delete)
    # A row i is deleted if A[i, j] = 1 for any j in columns_to_delete
    matrix
    |> Enum.reject(fn {constraints, _choice} ->
      # Delete row if it shares any column with columns_to_delete
      MapSet.intersection(constraints, columns_to_delete) != MapSet.new()
    end)
    |> Enum.map(fn {constraints, choice} ->
      # Remove deleted columns from this row's constraints
      new_constraints = MapSet.difference(constraints, columns_to_delete)
      {new_constraints, choice}
    end)
  end

end
