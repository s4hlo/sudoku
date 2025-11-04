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
    assert is_valid_solution?(solution)
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

  # Helper function to validate a complete sudoku solution
  defp is_valid_solution?(grid) do
    all_filled?(grid) and
      all_rows_valid?(grid) and
      all_cols_valid?(grid) and
      all_boxes_valid?(grid)
  end

  defp all_filled?(grid) do
    Enum.all?(grid, fn row ->
      Enum.all?(row, &(&1 != 0 and &1 != nil))
    end)
  end

  defp all_rows_valid?(grid) do
    Enum.all?(grid, fn row ->
      Enum.sort(row) == Enum.to_list(1..9)
    end)
  end

  defp all_cols_valid?(grid) do
    Enum.all?(0..8, fn col ->
      col_data = Enum.map(grid, &Enum.at(&1, col))
      Enum.sort(col_data) == Enum.to_list(1..9)
    end)
  end

  defp all_boxes_valid?(grid) do
    Enum.all?(0..2, fn box_row ->
      Enum.all?(0..2, fn box_col ->
        start_row = box_row * 3
        start_col = box_col * 3

        box_data =
          for r <- start_row..(start_row + 2),
              c <- start_col..(start_col + 2) do
            grid |> Enum.at(r) |> Enum.at(c)
          end

        Enum.sort(box_data) == Enum.to_list(1..9)
      end)
    end)
  end
end
