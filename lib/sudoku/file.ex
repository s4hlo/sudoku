defmodule Sudoku.File do
  @moduledoc """
  Module for reading and parsing Sudoku puzzle files.

  This module provides functionality to read Sudoku puzzles from text files
  and parse them into the internal grid format used by the solving algorithms.

  ## File Format

  The file format is simple and human-readable:

  1. **First line**: The order (box size) of the Sudoku grid.
     - For a standard 9x9 Sudoku, the order is `3` (since 3×3 = 9)
     - For a 4x4 Sudoku, the order is `2` (since 2×2 = 4)
     - The grid size is `order × order`

  2. **Subsequent lines**: Each line represents one row of the puzzle.
     - Values are written together without spaces
     - Empty cells are represented as `0`
     - Each row must have exactly `grid_size` characters

  ## Example File

      ```
      3
      530070000
      600195000
      098000060
      800060003
      400803001
      700020006
      060000280
      000419005
      000080079
      ```

  ## Error Handling

  The module validates the file format and returns descriptive error messages
  for common issues such as:
  - Empty files
  - Invalid order values
  - Missing or extra rows
  - Rows with incorrect length
  - Non-numeric characters
  - Empty rows

  ## Examples

      iex> {:ok, grid} = Sudoku.File.read_file("puzzle.txt")
      iex> length(grid)
      9
      iex> length(List.first(grid))
      9

      iex> Sudoku.File.read_file("nonexistent.txt")
      {:error, "Failed to read file: :enoent"}
  """

  @doc """
  Reads a Sudoku puzzle from a file.

  Parses the file according to the format described in the module documentation.
  Validates the file structure and returns either a parsed grid or an error tuple.

  ## Parameters

    - `file_path` - Path to the file containing the Sudoku puzzle.

  ## Returns

    - `{:ok, grid}` - On success, returns a tuple with the parsed grid (list of lists).
    - `{:error, reason}` - On failure, returns an error tuple with a descriptive message.

  ## Examples

      iex> File.write("test_puzzle.txt", "2\\n1200\\n0012\\n2100\\n0021")
      iex> {:ok, grid} = Sudoku.File.read_file("test_puzzle.txt")
      iex> grid
      [[1, 2, 0, 0], [0, 0, 1, 2], [2, 1, 0, 0], [0, 0, 2, 1]]
      iex> File.rm("test_puzzle.txt")

      iex> Sudoku.File.read_file("nonexistent.txt")
      {:error, "Failed to read file: :enoent"}

      iex> File.write("invalid.txt", "invalid")
      iex> Sudoku.File.read_file("invalid.txt")
      {:error, "Invalid order: not a number"}
      iex> File.rm("invalid.txt")
  """
  @spec read_file(String.t()) :: {:ok, list()} | {:error, String.t()}
  def read_file(file_path) do
    case File.read(file_path) do
      {:ok, content} -> parse_file_content(content)
      {:error, reason} -> {:error, "Failed to read file: #{inspect(reason)}"}
    end
  end

  @doc false
  # Parses the file content into a grid structure.
  #
  # Splits the content into lines, parses the order from the first line, and
  # then parses the remaining lines as grid rows.
  #
  # ## Parameters
  #
  #   - `content` - Raw file content as a string.
  #
  # ## Returns
  #
  #   - `{:ok, list()}` - Parsed grid on success.
  #   - `{:error, String.t()}` - Error tuple with descriptive message on failure.
  defp parse_file_content(content) do
    lines =
      content
      |> String.split("\n")
      |> Enum.map(&String.trim/1)

    # Remove trailing empty lines
    lines = remove_trailing_empty(lines)

    case lines do
      [] ->
        {:error, "File is empty"}

      [order_str | row_lines] ->
        case parse_order(order_str) do
          {:ok, order} ->
            grid_size = order * order
            parse_rows(row_lines, grid_size)

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  @doc false
  # Removes trailing empty lines from a list of lines.
  #
  # ## Parameters
  #
  #   - `lines` - List of strings.
  #
  # ## Returns
  #
  #   - `list()` - List of strings with trailing empty lines removed.
  defp remove_trailing_empty(lines) do
    lines
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
  end

  @doc false
  # Parses the order (box size) from the first line of the file.
  #
  # Validates that the order is a positive integer and returns an error if
  # the format is invalid or the value is non-positive.
  #
  # ## Parameters
  #
  #   - `order_str` - String containing the order value.
  #
  # ## Returns
  #
  #   - `{:ok, integer()}` - Parsed order on success.
  #   - `{:error, String.t()}` - Error tuple with descriptive message on failure.
  defp parse_order(order_str) do
    case Integer.parse(order_str) do
      {order, ""} when order > 0 ->
        {:ok, order}

      {order, _} when order > 0 ->
        {:error, "Invalid order format: contains non-numeric characters"}

      {order, _} when order <= 0 ->
        {:error, "Order must be positive, got: #{order}"}

      :error ->
        {:error, "Invalid order: not a number"}
    end
  end

  @doc false
  # Parses the row lines into a grid structure.
  #
  # Validates that there are exactly `grid_size` non-empty rows and that
  # each row has the correct length. Returns descriptive errors for common issues.
  #
  # ## Parameters
  #
  #   - `row_lines` - List of strings representing grid rows.
  #   - `grid_size` - Expected size of the grid (order × order).
  #
  # ## Returns
  #
  #   - `{:ok, list()}` - Parsed grid on success.
  #   - `{:error, String.t()}` - Error tuple with descriptive message on failure.
  defp parse_rows(row_lines, grid_size) do
    # Check for empty rows first (before filtering)
    empty_row_nums =
      row_lines
      |> Enum.with_index(1)
      |> Enum.filter(fn {line, _} -> line == "" end)
      |> Enum.map(fn {_, num} -> num end)

    if length(empty_row_nums) > 0 do
      {:error, "Row #{hd(empty_row_nums)} is empty"}
    else
      # Filter out empty lines (trailing ones)
      non_empty_lines =
        row_lines
        |> Enum.with_index(1)
        |> Enum.reject(fn {line, _} -> line == "" end)

      expected_non_empty = grid_size

      if length(non_empty_lines) != expected_non_empty do
        {:error, "Expected #{expected_non_empty} rows, got #{length(non_empty_lines)}"}
      else
        rows =
          non_empty_lines
          |> Enum.map(fn {row_str, row_num} -> parse_row(row_str, grid_size, row_num) end)

        case Enum.find(rows, &match?({:error, _}, &1)) do
          nil ->
            grid = Enum.map(rows, fn {:ok, row} -> row end)
            {:ok, grid}

          {:error, reason} ->
            {:error, reason}
        end
      end
    end
  end

  @doc false
  # Parses a single row string into a list of cell values.
  #
  # Converts each character in the row string to an integer and validates
  # that the row has the expected length.
  #
  # ## Parameters
  #
  #   - `row_str` - String representing a single row.
  #   - `expected_length` - Expected number of cells in the row.
  #   - `row_num` - Row number (1-based) for error messages.
  #
  # ## Returns
  #
  #   - `{:ok, list()}` - List of cell values on success.
  #   - `{:error, String.t()}` - Error tuple with descriptive message on failure.
  defp parse_row(row_str, expected_length, row_num) do
    if row_str == "" do
      {:error, "Row #{row_num} is empty"}
    else
      row =
        row_str
        |> String.graphemes()
        |> Enum.map(fn char -> parse_cell(char, row_num) end)

      case Enum.find(row, &match?({:error, _}, &1)) do
        nil ->
          cell_values = Enum.map(row, fn {:ok, val} -> val end)

          if length(cell_values) != expected_length do
            {:error,
             "Row #{row_num} has length #{length(cell_values)}, expected #{expected_length}"}
          else
            {:ok, cell_values}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  @doc false
  # Parses a single cell character into an integer value.
  #
  # Validates that the character is a valid digit (0-9) and returns an error
  # if the character is non-numeric or contains invalid content.
  #
  # ## Parameters
  #
  #   - `char` - Single character string representing a cell value.
  #   - `row_num` - Row number (1-based) for error messages.
  #
  # ## Returns
  #
  #   - `{:ok, integer()}` - Cell value (0-9) on success.
  #   - `{:error, String.t()}` - Error tuple with descriptive message on failure.
  defp parse_cell(char, row_num) do
    case Integer.parse(char) do
      {value, ""} when value >= 0 ->
        {:ok, value}

      {value, _} when value >= 0 ->
        {:error, "Row #{row_num} contains invalid character: #{char}"}

      :error ->
        {:error, "Row #{row_num} contains non-numeric character: #{char}"}
    end
  end
end
