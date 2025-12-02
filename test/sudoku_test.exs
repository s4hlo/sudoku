defmodule SudokuTest do
  use ExUnit.Case
  doctest Sudoku

  @moduletag timeout: 300_000

  @valid_9x9_puzzle [
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

  @invalid_9x9_puzzle [
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

  @solved_9x9_puzzle [
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

  @valid_4x4_puzzle [
    [1, 2, 0, 0],
    [3, 4, 0, 0],
    [0, 0, 2, 1],
    [0, 0, 4, 3]
  ]

  describe "default solver (backtracking)" do
    test "solves valid 9x9 puzzle" do
      solution = Sudoku.solve(@valid_9x9_puzzle)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
    end

    test "returns nil for invalid puzzle" do
      solution = Sudoku.solve(@invalid_9x9_puzzle)

      assert is_nil(solution)
    end

    test "returns same puzzle when already solved" do
      solution = Sudoku.solve(@solved_9x9_puzzle)

      assert solution == @solved_9x9_puzzle
    end

    test "solves 4x4 puzzle" do
      solution = Sudoku.solve(@valid_4x4_puzzle)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
      assert length(solution) == 4
      assert length(hd(solution)) == 4
    end

    @tag timeout: 300_000
    test "solves 16x16 puzzle" do
      solved_16x16 = [
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

      puzzle_with_blanks =
        solved_16x16
        |> Enum.with_index()
        |> Enum.map(fn {row, row_idx} ->
          row
          |> Enum.with_index()
          |> Enum.map(fn {val, col_idx} ->
            if rem(row_idx * 16 + col_idx, 3) == 0, do: val, else: 0
          end)
        end)

      solution = Sudoku.solve(puzzle_with_blanks)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
      assert length(solution) == 16
      assert length(hd(solution)) == 16
    end
  end

  describe "backtracking solver" do
    test "solves valid 9x9 puzzle" do
      solution = Sudoku.solve(@valid_9x9_puzzle, Sudoku.Backtracking)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
    end

    test "returns nil for invalid puzzle" do
      solution = Sudoku.solve(@invalid_9x9_puzzle, Sudoku.Backtracking)

      assert is_nil(solution)
    end

    test "returns same puzzle when already solved" do
      solution = Sudoku.solve(@solved_9x9_puzzle, Sudoku.Backtracking)

      assert solution == @solved_9x9_puzzle
    end

    test "solves 4x4 puzzle" do
      solution = Sudoku.solve(@valid_4x4_puzzle, Sudoku.Backtracking)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
      assert length(solution) == 4
      assert length(hd(solution)) == 4
    end
  end

  describe "algorithm X solver" do
    test "solves valid 9x9 puzzle" do
      solution = Sudoku.solve(@valid_9x9_puzzle, Sudoku.AlgorithmX)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
    end

    test "returns nil for invalid puzzle" do
      solution = Sudoku.solve(@invalid_9x9_puzzle, Sudoku.AlgorithmX)

      assert is_nil(solution)
    end

    test "solves 4x4 puzzle" do
      puzzle = [
        [1, 2, 0, 0],
        [3, 4, 0, 0],
        [0, 3, 2, 1],
        [0, 0, 4, 3]
      ]

      solution = Sudoku.solve(puzzle, Sudoku.AlgorithmX)

      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
      assert length(solution) == 4
      assert length(hd(solution)) == 4
    end
  end

  describe "read_file" do
    test "reads valid 9x9 puzzle from sample.txt" do
      {:ok, grid} = Sudoku.File.read_file("sample.txt")

      assert grid == @valid_9x9_puzzle
    end

    test "reads valid file and can solve it" do
      {:ok, grid} = Sudoku.File.read_file("sample.txt")

      solution = Sudoku.solve(grid)
      assert not is_nil(solution)
      assert Sudoku.Validator.is_valid_solution?(solution)
    end

    test "reads valid 4x4 puzzle file" do
      # Create temporary file
      file_content = """
      2
      1200
      3400
      0021
      0043
      """

      tmp_file = System.tmp_dir!() |> Path.join("sudoku_4x4_test.txt")
      File.write!(tmp_file, file_content)

      try do
        {:ok, grid} = Sudoku.File.read_file(tmp_file)

        assert length(grid) == 4
        assert length(hd(grid)) == 4
        assert grid == @valid_4x4_puzzle
      after
        File.rm(tmp_file)
      end
    end

    test "returns error for invalid file" do
      tmp_file = System.tmp_dir!() |> Path.join("invalid_test.txt")
      File.write!(tmp_file, "invalid content")

      try do
        result = Sudoku.File.read_file(tmp_file)
        assert {:error, _} = result
      after
        File.rm(tmp_file)
      end
    end
  end
end
