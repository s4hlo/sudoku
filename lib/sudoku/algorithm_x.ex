defmodule Sudoku.AlgorithmX do
  @moduledoc """
  Solves Sudoku puzzles using Algorithm X (exact cover) with dancing links.

  This implementation uses Donald Knuth's Algorithm X to solve Sudoku as an exact
  cover problem. Algorithm X is a recursive, nondeterministic, depth-first,
  backtracking algorithm that finds all solutions to the exact cover problem.

  ## How It Works

  Sudoku is transformed into an exact cover problem where:
  - Each row represents a choice (placing number `n` in cell `(r, c)`)
  - Each column represents a constraint that must be satisfied:
    - Cell constraint: each cell must have exactly one number
    - Row constraint: each row must contain each number exactly once
    - Column constraint: each column must contain each number exactly once
    - Box constraint: each box must contain each number exactly once

  The algorithm then finds a set of rows (choices) that cover all columns
  (constraints) exactly once.

  ## Algorithm Steps

  1. If the matrix is empty, the problem is solved; terminate successfully.
  2. Otherwise choose a column deterministically (minimum remaining values heuristic).
  3. Choose a row that covers this column (nondeterministically - tries all possibilities).
  4. Include the row in the partial solution.
  5. Delete all columns covered by this row and all rows that conflict with these columns.
  6. Repeat recursively on the reduced matrix.

  ## References

  - [Dancing Links (Wikipedia)](https://en.wikipedia.org/wiki/Dancing_Links)
  - [Algorithm X (Wikipedia)](https://en.wikipedia.org/wiki/Knuth%27s_Algorithm_X)
  - Knuth, Donald E. "Dancing links." *Millennial perspectives in computer science*, 2000.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> solved = Sudoku.AlgorithmX.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> grid = [
      ...>   [5, 3, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]
      iex> solved = Sudoku.AlgorithmX.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true
  """

  @doc """
  Solves a Sudoku puzzle using Algorithm X.

  Converts the Sudoku grid into an exact cover matrix and solves it using
  Algorithm X. Returns the solved grid or `nil` if no solution exists.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.

  ## Returns

    - `list()` - The solved grid as a list of lists, or `nil` if no solution exists.

  ## Examples

      iex> grid = [
      ...>   [5, 3, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]
      iex> solved = Sudoku.AlgorithmX.solve(grid)
      iex> Sudoku.Validator.is_valid_solution?(solved)
      true

      iex> unsolvable = [
      ...>   [5, 5, 0, 0, 7, 0, 0, 0, 0],
      ...>   [6, 0, 0, 1, 9, 5, 0, 0, 0],
      ...>   [0, 9, 8, 0, 0, 0, 0, 6, 0],
      ...>   [8, 0, 0, 0, 6, 0, 0, 0, 3],
      ...>   [4, 0, 0, 8, 0, 3, 0, 0, 1],
      ...>   [7, 0, 0, 0, 2, 0, 0, 0, 6],
      ...>   [0, 6, 0, 0, 0, 0, 2, 8, 0],
      ...>   [0, 0, 0, 4, 1, 9, 0, 0, 5],
      ...>   [0, 0, 0, 0, 8, 0, 0, 7, 9]
      ...> ]  # Invalid initial state (conflict in first row)
      iex> Sudoku.AlgorithmX.solve(unsolvable)
      nil
  """
  @spec solve(list()) :: list() | nil
  def solve(grid) when is_list(grid) do
    order = Sudoku.Utils.calculate_order(grid)
    matrix = Sudoku.Utils.AlgorithmX.build_exact_cover_matrix(grid, order)

    case algorithm_x(matrix, []) do
      nil -> nil
      solution -> Sudoku.Utils.AlgorithmX.solution_to_grid(solution, grid)
    end
  end

  @doc """
  Solves a Sudoku puzzle and returns the solving history with matrix states.

  Similar to `solve/1`, but returns a list of `{grid, matrix}` tuples representing
  each step of the solving process. The `matrix` represents the current exact cover
  matrix state at that step.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid. Empty cells are `0`.

  ## Returns

    - `list()` - A list of `{grid, matrix}` tuples, or `nil` if no solution exists.
      Each tuple contains:
      - `grid` - The current grid state (list of lists)
      - `matrix` - The current exact cover matrix (list of `{constraints, choice}` tuples)
      The first element is the initial state, and the last element has an empty matrix
      (indicating the solution is complete).

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.AlgorithmX.solve_log(grid)
      iex> length(history) > 0
      true
      iex> {first_grid, first_matrix} = List.first(history)
      iex> is_list(first_grid)
      true
      iex> is_list(first_matrix)
      true
      iex> {last_grid, last_matrix} = List.last(history)
      iex> last_matrix == []
      true
  """
  @spec solve_log(list()) :: list() | nil
  def solve_log(grid) when is_list(grid) do
    order = Sudoku.Utils.calculate_order(grid)
    matrix = Sudoku.Utils.AlgorithmX.build_exact_cover_matrix(grid, order)
    initial_history = [{Sudoku.Utils.deep_copy(grid), matrix}]

    case algorithm_x_with_history(matrix, [], grid, initial_history) do
      nil -> nil
      {_solution, history} -> Enum.reverse(history)
    end
  end

  @doc false
  # Algorithm X implementation following Knuth's algorithm.
  #
  # Implements the core Algorithm X recursive backtracking algorithm:
  # 1. If A is empty, the problem is solved; terminate successfully.
  # 2. Otherwise choose a column, c (deterministically).
  # 3. Choose a row, r, such that A[r, c] = 1 (nondeterministically).
  # 4. Include r in the partial solution.
  # 5. For each j such that A[r, j] = 1,
  #    delete column j from matrix A;
  #    for each i such that A[i, j] = 1,
  #    delete row i from matrix A.
  # 6. Repeat this algorithm recursively on the reduced matrix A.
  #
  # ## Parameters
  #
  #   - `matrix` - List of `{constraints, choice}` tuples where constraints is a MapSet.
  #   - `partial_solution` - List of choices (tuples `{r, c, n}`) accumulated so far.
  #
  # ## Returns
  #
  #   - `list()` - List of choices representing the solution, or `nil` if no solution exists.
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

  @doc false
  # Algorithm X with history tracking for visualization.
  #
  # Similar to `algorithm_x/2`, but tracks the solving history by recording
  # each grid state and matrix state at each step for visualization purposes.
  #
  # ## Parameters
  #
  #   - `matrix` - Current exact cover matrix.
  #   - `partial_solution` - Accumulated choices so far.
  #   - `original_grid` - Original grid to reconstruct states from.
  #   - `history` - Accumulated history of `{grid, matrix}` tuples.
  #
  # ## Returns
  #
  #   - `{list(), list()}` - `{solution, history}` tuple or `nil` if no solution exists.
  defp algorithm_x_with_history(matrix, partial_solution, original_grid, history) do
    # Step 1: If A is empty, the problem is solved; terminate successfully.
    if matrix == [] do
      # Convert final solution to grid and add to history
      final_grid = Sudoku.Utils.AlgorithmX.solution_to_grid(partial_solution, original_grid)
      final_history = [{Sudoku.Utils.deep_copy(final_grid), []} | history]
      {partial_solution, final_history}
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
            try_rows_with_history(
              matrix,
              rows_with_c,
              column_c,
              partial_solution,
              original_grid,
              history
            )
          end
      end
    end
  end

  @doc false
  # Chooses a column deterministically using the minimum remaining values heuristic.
  #
  # This heuristic selects the column with the fewest remaining rows that can
  # cover it, which helps prune the search space early by failing fast on
  # constraints that are difficult to satisfy.
  #
  # ## Parameters
  #
  #   - `matrix` - List of `{constraints, choice}` tuples.
  #
  # ## Returns
  #
  #   - `integer()` - Column index or `nil` if no columns remain.
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
      map when map == %{} ->
        nil

      _ ->
        {column, _count} = Enum.min_by(column_counts, fn {_k, v} -> v end)
        column
    end
  end

  @doc false
  # Finds all rows that cover the specified column.
  #
  # A row covers a column if the row's constraint set contains the column index.
  # These are the rows that can potentially satisfy the selected constraint.
  #
  # ## Parameters
  #
  #   - `matrix` - List of `{constraints, choice}` tuples.
  #   - `column_c` - Column index to find rows for.
  #
  # ## Returns
  #
  #   - `list()` - List of `{constraints, choice}` tuples that cover `column_c`.
  defp find_rows_with_column(matrix, column_c) do
    Enum.filter(matrix, fn {constraints, _choice} ->
      MapSet.member?(constraints, column_c)
    end)
  end

  @doc false
  # Tries each row that covers the selected column, recursively exploring solutions.
  #
  # This implements the nondeterministic choice step of Algorithm X by trying
  # all possible rows that cover the selected column. For each row, it includes
  # it in the partial solution, reduces the matrix, and recursively continues.
  #
  # ## Parameters
  #
  #   - `matrix` - Current exact cover matrix.
  #   - `rows_with_c` - List of rows that cover column c.
  #   - `column_c` - The selected column index.
  #   - `partial_solution` - Accumulated choices so far.
  #
  # ## Returns
  #
  #   - `list()` - List of choices representing the solution, or `nil` if no solution exists.
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

  @doc false
  # Tries each row that covers the selected column, with history tracking.
  #
  # Similar to `try_rows/4`, but records each attempt in the history for visualization.
  # Converts the partial solution to a grid state at each step and records both
  # the grid and the reduced matrix state.
  #
  # ## Parameters
  #
  #   - `matrix` - Current exact cover matrix.
  #   - `rows_with_c` - List of rows that cover column c.
  #   - `column_c` - The selected column index.
  #   - `partial_solution` - Accumulated choices so far.
  #   - `original_grid` - Original grid for state reconstruction.
  #   - `history` - Accumulated history.
  #
  # ## Returns
  #
  #   - `{list(), list()}` - `{solution, history}` tuple or `nil` if no solution exists.
  defp try_rows_with_history(
         _matrix,
         [],
         _column_c,
         _partial_solution,
         _original_grid,
         _history
       ),
       do: nil

  defp try_rows_with_history(
         matrix,
         [{constraints_r, choice} | rest],
         column_c,
         partial_solution,
         original_grid,
         history
       ) do
    # Step 4: Include r in the partial solution
    new_partial_solution = [choice | partial_solution]

    # Step 5: For each j such that A[r, j] = 1,
    #         delete column j from matrix A;
    #         for each i such that A[i, j] = 1,
    #         delete row i from matrix A.
    reduced_matrix = reduce_matrix(matrix, constraints_r)

    # Convert partial solution to grid and add to history with reduced matrix
    current_grid = Sudoku.Utils.AlgorithmX.solution_to_grid(new_partial_solution, original_grid)
    updated_history = [{Sudoku.Utils.deep_copy(current_grid), reduced_matrix} | history]

    # Step 6: Repeat this algorithm recursively on the reduced matrix A
    case algorithm_x_with_history(
           reduced_matrix,
           new_partial_solution,
           original_grid,
           updated_history
         ) do
      nil ->
        try_rows_with_history(
          matrix,
          rest,
          column_c,
          partial_solution,
          original_grid,
          history
        )

      result ->
        result
    end
  end

  @doc false
  # Reduces the matrix by deleting columns and conflicting rows.
  #
  # When a row is chosen, all columns it covers must be deleted (as they are
  # satisfied), and all rows that also cover any of those columns must be deleted
  # (as they conflict with the chosen row).
  #
  # ## Parameters
  #
  #   - `matrix` - Current exact cover matrix.
  #   - `columns_to_delete` - MapSet of column indices to delete.
  #
  # ## Returns
  #
  #   - `list()` - Reduced matrix with deleted columns removed from remaining rows.
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
