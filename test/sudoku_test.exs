defmodule SudokuTest do
  use ExUnit.Case
  doctest Sudoku

  test "solves a valid sudoku puzzle" do
    puzzle = [
      [5, 3, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9]
    ]

    solution = Sudoku.solve(puzzle)

    assert solution != nil
    assert Validator.is_valid_solution?(solution)
  end

  test "returns nil for unsolvable puzzle" do
    # Invalid puzzle with duplicate numbers in same row
    invalid_puzzle = [
      [5, 5, 0, 0, 7, 0, 0, 0, 0],
      [6, 0, 0, 1, 9, 5, 0, 0, 0],
      [0, 9, 8, 0, 0, 0, 0, 6, 0],
      [8, 0, 0, 0, 6, 0, 0, 0, 3],
      [4, 0, 0, 8, 0, 3, 0, 0, 1],
      [7, 0, 0, 0, 2, 0, 0, 0, 6],
      [0, 6, 0, 0, 0, 0, 2, 8, 0],
      [0, 0, 0, 4, 1, 9, 0, 0, 5],
      [0, 0, 0, 0, 8, 0, 0, 7, 9]
    ]

    solution = Sudoku.solve(invalid_puzzle)
    assert solution == nil
  end

  test "handles already solved puzzle" do
    solved = [
      [5, 3, 4, 6, 7, 8, 9, 1, 2],
      [6, 7, 2, 1, 9, 5, 3, 4, 8],
      [1, 9, 8, 3, 4, 2, 5, 6, 7],
      [8, 5, 9, 7, 6, 1, 4, 2, 3],
      [4, 2, 6, 8, 5, 3, 7, 9, 1],
      [7, 1, 3, 9, 2, 4, 8, 5, 6],
      [9, 6, 1, 5, 3, 7, 2, 8, 4],
      [2, 8, 7, 4, 1, 9, 6, 3, 5],
      [3, 4, 5, 2, 8, 6, 1, 7, 9]
    ]

    solution = Sudoku.solve(solved)
    assert solution == solved
  end

  test "solves 4x4 sudoku with 2x2 boxes" do
    # Valid 4x4 puzzle with 2x2 boxes
    puzzle = [
      [1, 2, 0, 0],
      [3, 4, 0, 0],
      [0, 0, 2, 1],
      [0, 0, 4, 3]
    ]

    solution = Sudoku.solve(puzzle)

    assert solution != nil
    assert Validator.is_valid_solution?(solution)
    assert length(solution) == 4
    assert length(hd(solution)) == 4
  end

  @tag timeout: 300_000
  test "solves 16x16 sudoku with 4x4 boxes" do
    # A simpler 16x16 puzzle with more clues for faster solving
    puzzle = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
      [5, 6, 7, 8, 1, 2, 3, 4, 13, 14, 15, 16, 9, 10, 11, 12],
      [9, 10, 11, 12, 13, 14, 15, 16, 1, 2, 3, 4, 5, 6, 7, 8],
      [13, 14, 15, 16, 9, 10, 11, 12, 5, 6, 7, 8, 1, 2, 3, 4],
      [2, 1, 4, 3, 6, 5, 8, 7, 10, 9, 12, 11, 14, 13, 16, 15],
      [6, 5, 8, 7, 2, 1, 4, 3, 14, 13, 16, 15, 10, 9, 12, 11],
      [10, 9, 12, 11, 14, 13, 16, 15, 2, 1, 4, 3, 6, 5, 8, 7],
      [14, 13, 16, 15, 10, 9, 12, 11, 6, 5, 8, 7, 2, 1, 4, 3],
      [3, 4, 1, 2, 7, 8, 5, 6, 11, 12, 9, 10, 15, 16, 13, 14],
      [7, 8, 5, 6, 3, 4, 1, 2, 15, 16, 13, 14, 11, 12, 9, 10],
      [11, 12, 9, 10, 15, 16, 13, 14, 3, 4, 1, 2, 7, 8, 5, 6],
      [15, 16, 13, 14, 11, 12, 9, 10, 7, 8, 5, 6, 3, 4, 1, 2],
      [4, 3, 2, 1, 8, 7, 6, 5, 12, 11, 10, 9, 16, 15, 14, 13],
      [8, 7, 6, 5, 4, 3, 2, 1, 16, 15, 14, 13, 12, 11, 10, 9],
      [12, 11, 10, 9, 16, 15, 14, 13, 4, 3, 2, 1, 8, 7, 6, 5],
      [16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
    ]

    # Convert to puzzle format (replace some values with 0)
    puzzle_with_blanks =
      puzzle
      |> Enum.with_index()
      |> Enum.map(fn {row, row_idx} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {val, col_idx} ->
          # Keep about 30% of values as clues
          if rem(row_idx * 16 + col_idx, 3) == 0, do: val, else: 0
        end)
      end)

    solution = Sudoku.solve(puzzle_with_blanks)

    assert solution != nil
    assert Validator.is_valid_solution?(solution)
    assert length(solution) == 16
    assert length(hd(solution)) == 16
  end
end
