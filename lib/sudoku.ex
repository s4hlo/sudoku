defmodule Sudoku do
  @moduledoc """
  Main module for solving Sudoku puzzles.

  Supports multiple solving algorithms. By default, uses backtracking.
  """

  @default_solver Sudoku.Backtracking

  def solve(grid, solver) when is_list(grid) and is_atom(solver) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)

    if not Validator.valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      solver.solve(grid, grid_size, box_size)
    end
  end

  def solve(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)

    if not Validator.valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      @default_solver.solve(grid, grid_size, box_size)
    end
  end

  def solve_log(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)

    if not Validator.valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      @default_solver.solve_log(grid, grid_size, box_size)
    end
  end

  def solve_log(grid, solver) when is_list(grid) and is_atom(solver) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)

    if not Validator.valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      solver.solve_log(grid, grid_size, box_size)
    end
  end

end
