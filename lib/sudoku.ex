defmodule Sudoku do
  @moduledoc """
  Main module for solving Sudoku puzzles.

  Supports multiple solving algorithms. By default, uses backtracking.
  """

  @default_solver Sudoku.Backtracking

  defp validate_and_solve(grid, solver, :solve) do
    if Validator.valid_initial_grid?(grid) do
      solver.solve(grid)
    else
      nil
    end
  end

  defp validate_and_solve(grid, solver, :solve_log) do
    if Validator.valid_initial_grid?(grid) do
      solver.solve_log(grid)
    else
      nil
    end
  end

  def solve(grid, solver) when is_list(grid) and is_atom(solver) do
    validate_and_solve(grid, solver, :solve)
  end

  def solve(grid) when is_list(grid) do
    validate_and_solve(grid, @default_solver, :solve)
  end

  def solve_log(grid) when is_list(grid) do
    validate_and_solve(grid, @default_solver, :solve_log)
  end

  def solve_log(grid, solver) when is_list(grid) and is_atom(solver) do
    validate_and_solve(grid, solver, :solve_log)
  end

end
