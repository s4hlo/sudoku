defmodule Sudoku do
  @default_solver Sudoku.Backtracking
  @spec solve(list()) :: list() | nil
  def solve(grid) when is_list(grid) do
    validate_and_solve(grid, @default_solver, :solve)
  end

  @spec solve(list(), atom()) :: list() | nil
  def solve(grid, solver) when is_list(grid) and is_atom(solver) do
    validate_and_solve(grid, solver, :solve)
  end

  @spec solve_log(list()) :: list() | nil
  def solve_log(grid) when is_list(grid) do
    validate_and_solve(grid, @default_solver, :solve_log)
  end

  @spec solve_log(list(), atom()) :: list() | nil
  def solve_log(grid, solver) when is_list(grid) and is_atom(solver) do
    validate_and_solve(grid, solver, :solve_log)
  end

  defp validate_and_solve(grid, solver, :solve) do
    if Sudoku.Validator.valid_initial_grid?(grid) do
      solver.solve(grid)
    else
      nil
    end
  end

  defp validate_and_solve(grid, solver, :solve_log) do
    if Sudoku.Validator.valid_initial_grid?(grid) do
      solver.solve_log(grid)
    else
      nil
    end
  end
end
