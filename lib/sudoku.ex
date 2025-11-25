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
  
  Can also accept a keyword list of options:
  - `:solver` - The solver algorithm to use (default: `Sudoku.Backtracking`)
  - `:return_history` - If `true`, returns a list of all states visited during solving (only works with backtracking)
  
  Examples:
      # Solve with specific solver
      Sudoku.solve(grid, Sudoku.Backtracking)
      
      # Solve with default solver and return history
      Sudoku.solve(grid, return_history: true)
      
      # Solve with backtracking and return history
      Sudoku.solve(grid, solver: Sudoku.Backtracking, return_history: true)
  """
  def solve(grid, solver) when is_list(grid) and is_atom(solver) do
    solver.solve(grid)
  end

  def solve_log(grid) when is_list(grid) do
    @default_solver.solve_log(grid)
  end

  def solve_log(grid, solver) when is_list(grid) and is_atom(solver) do
    solver.solve_log(grid)
  end

end
