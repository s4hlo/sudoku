defmodule Sudoku do
  @moduledoc """
  Main module for solving Sudoku puzzles.
  
  Supports multiple solving algorithms. By default, uses backtracking.
  """

  @default_solver Sudoku.Backtracking

  @doc """
  Solves a Sudoku puzzle using the default solver (backtracking).
  """
  def solve(grid) when is_list(grid) do
    @default_solver.solve(grid)
  end

  @doc """
  Solves a Sudoku puzzle using a specific solver algorithm.
  """
  def solve(grid, solver) when is_list(grid) and is_atom(solver) do
    solver.solve(grid)
  end
end
