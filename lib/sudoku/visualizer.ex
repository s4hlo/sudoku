defmodule Sudoku.Visualizer do
  @moduledoc """
  Module for visualizing Sudoku solving process with animated display.

  This module provides functions to visualize and animate the Sudoku solving
  process. It supports displaying both simple grid states and combined views
  showing both the grid and the exact cover matrix (for Algorithm X).

  ## Features

  - Animated display of solving history with customizable frame delay
  - Beautiful box-drawing borders using Unicode characters
  - Support for both backtracking and Algorithm X visualization
  - Combined view showing grid and exact cover matrix side-by-side
  - Single board printing for static display

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.solve_log(grid)
      iex> Sudoku.Visualizer.animate_history(history, delay: 200)

      iex> grid = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> Sudoku.Visualizer.print_board(grid)
  """

  @doc """
  Prints the Sudoku board history as an animated sequence.

  Displays each state in the solving history with beautiful box-drawing borders
  using Unicode characters. The animation can be customized with options for
  frame delay and screen clearing.

  For Algorithm X histories (containing `{grid, matrix}` tuples), the function
  automatically detects this format and displays both the grid and the exact
  cover matrix side-by-side.

  ## Parameters

    - `history` - A list of grid states from `Sudoku.solve_log/1` or
      `Sudoku.solve_log/2`. Can be:
      - A list of grids (for backtracking): `[grid1, grid2, ...]`
      - A list of `{grid, matrix}` tuples (for Algorithm X): `[{grid1, matrix1}, ...]`
    - `opts` - A keyword list of options:
      - `:delay` - Delay between frames in milliseconds (default: `100`)
      - `:clear_screen` - Whether to clear the screen between frames (default: `true`)

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.Backtracking.solve_log(grid)
      iex> Sudoku.Visualizer.animate_history(history, delay: 50, clear_screen: true)

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> history = Sudoku.AlgorithmX.solve_log(grid)
      iex> Sudoku.Visualizer.animate_history(history)
  """
  @spec animate_history(list(), keyword()) :: :ok
  def animate_history(history, opts \\ []) when is_list(history) do
    delay = Keyword.get(opts, :delay, 100)
    clear_screen = Keyword.get(opts, :clear_screen, true)

    # Check if history contains {grid, matrix} tuples or just grids
    has_matrix = Enum.any?(history, fn state ->
      is_tuple(state) and tuple_size(state) == 2
    end)

    history
    |> Enum.with_index(1)
    |> Enum.each(fn {state, index} ->
      # Build the complete content
      content = if has_matrix and is_tuple(state) do
        {grid, matrix} = state
        build_combined_content(grid, matrix, index, length(history))
      else
        build_board_content(state, index, length(history))
      end

      # Clear screen and print immediately in one operation to avoid flickering
      output =
        if clear_screen do
          IO.ANSI.clear() <> IO.ANSI.cursor(0, 0) <> content
        else
          content
        end

      # Use IO.write to properly handle Unicode characters
      IO.write(output)

      Process.sleep(delay)
    end)
  end

  @doc """
  Prints a single Sudoku board state with beautiful borders.

  Displays a single grid state with Unicode box-drawing characters. Useful for
  displaying a static view of a grid without animation.

  ## Parameters

    - `grid` - A list of lists representing the Sudoku grid.
    - `frame_num` - Frame number to display (default: `1`). Used for header display.
    - `total_frames` - Total number of frames (default: `1`). Used for header display.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 3, 4],
      ...>   [3, 4, 1, 2],
      ...>   [2, 1, 4, 3],
      ...>   [4, 3, 2, 1]
      ...> ]
      iex> Sudoku.Visualizer.print_board(grid)
      Frame 1/1
      ╭───┬───┬───┬───╮
      │ 1 │ 2 │ 3 │ 4 │
      ├───┼───┼───┼───┤
      │ 3 │ 4 │ 1 │ 2 │
      ├───┼───┼───┼───┤
      │ 2 │ 1 │ 4 │ 3 │
      ├───┼───┼───┼───┤
      │ 4 │ 3 │ 2 │ 1 │
      ╰───┴───┴───┴───╯

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
      iex> Sudoku.Visualizer.print_board(grid, 5, 10)
  """
  @spec print_board(list(), non_neg_integer(), non_neg_integer()) :: :ok
  def print_board(grid, frame_num \\ 1, total_frames \\ 1) when is_list(grid) do
    IO.write(build_board_content(grid, frame_num, total_frames))
  end

  @doc false
  # Builds the complete board content string with header and borders.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `frame_num` - Current frame number.
  #   - `total_frames` - Total number of frames.
  #
  # ## Returns
  #
  #   - `String.t()` - Complete formatted board string.
  defp build_board_content(grid, frame_num, total_frames) when is_list(grid) do
    grid_size = length(grid)
    order = trunc(:math.sqrt(grid_size))

    # Calculate cell width (for numbers up to grid_size)
    # Use a fixed width of 3 for better visual appearance (1 char for number + 1 space on each side)
    cell_content_width = 3

    # Build the board first to get actual width
    lines = build_board_lines(grid, order, cell_content_width)
    board_width = lines |> List.first() |> String.length()

    # Add frame info
    frame_info = "Frame #{frame_num}/#{total_frames}"
    header = build_header(frame_info, board_width)

    header <> "\n" <> Enum.join(lines, "\n") <> "\n"
  end

  @doc false
  # Builds the header line for the board display.
  #
  # ## Parameters
  #
  #   - `frame_info` - Frame information string.
  #   - `board_width` - Width of the board (unused but kept for consistency).
  #
  # ## Returns
  #
  #   - `String.t()` - Header string.
  defp build_header(frame_info, _board_width) do
    frame_info
  end

  @doc false
  # Builds all board lines including borders and grid content.
  #
  # ## Parameters
  #
  #   - `grid` - A list of lists representing the Sudoku grid.
  #   - `order` - The order (box size) of the Sudoku grid.
  #   - `cell_width` - Width of each cell in characters.
  #
  # ## Returns
  #
  #   - `list()` - List of strings representing board lines.
  defp build_board_lines(grid, order, cell_width) do
    grid_size = order * order
    # Top border
    top_border = build_top_border(order, cell_width)

    # Grid rows
    grid_lines =
      grid
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, row_idx} ->
        row_lines = build_row_lines(row, row_idx, order, cell_width)

        # Add separator after each box (except last)
        separator =
          if rem(row_idx + 1, order) == 0 and row_idx < grid_size - 1 do
            [build_horizontal_separator(order, cell_width)]
          else
            []
          end

        row_lines ++ separator
      end)

    # Bottom border
    bottom_border = build_bottom_border(order, cell_width)

    [top_border] ++ grid_lines ++ [bottom_border]
  end

  @doc false
  # Builds the top border of the board using Unicode box-drawing characters.
  #
  # ## Parameters
  #
  #   - `order` - The order (box size) of the Sudoku grid.
  #   - `cell_width` - Width of each cell in characters.
  #
  # ## Returns
  #
  #   - `String.t()` - Top border string.
  defp build_top_border(order, cell_width) do
    grid_size = order * order
    "╭" <>
      (0..(grid_size - 1)
       |> Enum.map(fn col_idx ->
         String.duplicate("─", cell_width) <>
           cond do
             rem(col_idx + 1, order) == 0 and col_idx < grid_size - 1 -> "┬"
             col_idx < grid_size - 1 -> "─"
             true -> ""
           end
       end)
       |> Enum.join("")) <>
      "╮"
  end

  @doc false
  # Builds the bottom border of the board using Unicode box-drawing characters.
  #
  # ## Parameters
  #
  #   - `order` - The order (box size) of the Sudoku grid.
  #   - `cell_width` - Width of each cell in characters.
  #
  # ## Returns
  #
  #   - `String.t()` - Bottom border string.
  defp build_bottom_border(order, cell_width) do
    grid_size = order * order
    "╰" <>
      (0..(grid_size - 1)
       |> Enum.map(fn col_idx ->
         String.duplicate("─", cell_width) <>
           cond do
             rem(col_idx + 1, order) == 0 and col_idx < grid_size - 1 -> "┴"
             col_idx < grid_size - 1 -> "─"
             true -> ""
           end
       end)
       |> Enum.join("")) <>
      "╯"
  end

  @doc false
  # Builds a horizontal separator line between boxes.
  #
  # ## Parameters
  #
  #   - `order` - The order (box size) of the Sudoku grid.
  #   - `cell_width` - Width of each cell in characters.
  #
  # ## Returns
  #
  #   - `String.t()` - Horizontal separator string.
  defp build_horizontal_separator(order, cell_width) do
    grid_size = order * order
    "├" <>
      (0..(grid_size - 1)
       |> Enum.map(fn col_idx ->
         String.duplicate("─", cell_width) <>
           cond do
             rem(col_idx + 1, order) == 0 and col_idx < grid_size - 1 -> "┼"
             col_idx < grid_size - 1 -> "─"
             true -> ""
           end
       end)
       |> Enum.join("")) <>
      "┤"
  end

  @doc false
  # Builds the lines for a single row of the grid.
  #
  # ## Parameters
  #
  #   - `row` - A list of cell values for the row.
  #   - `_row_idx` - Row index (unused but kept for consistency).
  #   - `order` - The order (box size) of the Sudoku grid.
  #   - `_cell_width` - Width of each cell (unused but kept for consistency).
  #
  # ## Returns
  #
  #   - `list()` - List of strings representing row lines.
  defp build_row_lines(row, _row_idx, order, _cell_width) do
    grid_size = order * order
    # Convert row values to strings with proper padding
    cells =
      row
      |> Enum.map(fn value ->
        cell_str = if value == 0, do: "·", else: Integer.to_string(value)
        # Center the content in the cell (cell_width is 3)
        case String.length(cell_str) do
          1 -> " " <> cell_str <> " "
          2 -> cell_str <> " "
          _ -> cell_str
        end
      end)

    # Build the row line with vertical separators
    row_line =
      "│" <>
        (cells
         |> Enum.with_index()
         |> Enum.map(fn {cell, col_idx} ->
           cell <>
             cond do
               rem(col_idx + 1, order) == 0 and col_idx < grid_size - 1 -> "│"
               col_idx < grid_size - 1 -> " "
               true -> ""
             end
         end)
         |> Enum.join("")) <>
        "│"

    [row_line]
  end

  @doc """
  Visualizes the exact cover matrix used by Algorithm X.

  Prints a textual representation of the exact cover matrix, showing which
  constraints each choice satisfies. Each row represents a choice `{r, c, n}`
  (placing number `n` in cell `(r, c)`), and each column represents a constraint.
  The matrix is displayed as a binary matrix where:
  - `O` indicates the choice satisfies that constraint
  - `-` indicates the choice does not satisfy that constraint

  ## Parameters

    - `matrix` - A list of `{constraints, {r, c, n}}` tuples from Algorithm X,
      where `constraints` is a `MapSet` of constraint column indices.
    - `order` - The order (box size) of the Sudoku grid.

  ## Examples

      iex> grid = [
      ...>   [1, 2, 0, 0],
      ...>   [0, 0, 1, 2],
      ...>   [2, 1, 0, 0],
      ...>   [0, 0, 2, 1]
      ...> ]
      iex> order = 2
      iex> matrix = Sudoku.Utils.AlgorithmX.build_exact_cover_matrix(grid, order)
      iex> Sudoku.Visualizer.visualize_exact_cover_matrix(matrix, order)
      7x64
      Constraint order: Cell | Row | Column | Box
      (0,0,1) O---O---O---O---
      ...
  """
  @spec visualize_exact_cover_matrix(list(), non_neg_integer()) :: :ok
  def visualize_exact_cover_matrix(matrix, order) do
    grid_size = order * order
    # Calculate total number of constraints (columns)
    total_constraints = 4 * grid_size * grid_size

    # Build binary matrix representation with triples
    binary_matrix_with_triples =
      Enum.map(matrix, fn {constraints, {r, c, n}} ->
        # Create a list of - and O for each row
        binary_row =
          for col <- 0..(total_constraints - 1) do
            if MapSet.member?(constraints, col), do: "O", else: "-"
          end

        {{r, c, n}, binary_row}
      end)

    # Print header with dimensions and constraint order
    m = length(binary_matrix_with_triples)
    n = total_constraints

    IO.puts("#{m}x#{n}")
    IO.puts("Constraint order: Cell | Row | Column | Box")

    # Print the matrix with triples
    Enum.each(binary_matrix_with_triples, fn {{r, c, n}, row} ->
      IO.puts("(#{r},#{c},#{n}) #{Enum.join(row, "")}")
    end)
  end

  @doc false
  # Builds combined content showing board and matrix side by side.
  #
  # Used when visualizing Algorithm X solving history, which contains both
  # grid states and exact cover matrix states.
  #
  # ## Parameters
  #
  #   - `grid` - Current grid state.
  #   - `matrix` - Current exact cover matrix state.
  #   - `frame_num` - Current frame number.
  #   - `total_frames` - Total number of frames.
  #
  # ## Returns
  #
  #   - `String.t()` - Combined formatted string.
  defp build_combined_content(grid, matrix, frame_num, total_frames) do
    order = Sudoku.Utils.calculate_order(grid)
    # Build board content
    board_lines = build_board_lines(grid, order, 3)
    board_width = board_lines |> List.first() |> String.length()

    # Build matrix content
    matrix_lines = build_matrix_lines(matrix, order)

    # Find maximum height
    max_height = max(length(board_lines), length(matrix_lines))

    # Pad both to same height
    padded_board = pad_lines(board_lines, max_height, board_width)
    padded_matrix = pad_lines(matrix_lines, max_height, 0)

    # Combine side by side
    frame_info = "Frame #{frame_num}/#{total_frames}"
    header = frame_info <> String.duplicate(" ", board_width + 5 - String.length(frame_info)) <> "Matrix"

    combined_lines =
      Enum.zip(padded_board, padded_matrix)
      |> Enum.map(fn {board_line, matrix_line} ->
        board_line <> "   " <> matrix_line
      end)

    header <> "\n" <> Enum.join(combined_lines, "\n") <> "\n"
  end

  @doc false
  # Builds matrix lines for display in the combined view.
  #
  # Converts the exact cover matrix into a readable text format showing
  # which constraints each choice satisfies.
  #
  # ## Parameters
  #
  #   - `matrix` - List of `{constraints, {r, c, n}}` tuples.
  #   - `order` - The order (box size) of the Sudoku grid.
  #
  # ## Returns
  #
  #   - `list()` - List of strings representing matrix lines.
  defp build_matrix_lines(matrix, order) do
    if matrix == [] do
      ["(empty matrix)"]
    else
      grid_size = order * order
      total_constraints = 4 * grid_size * grid_size

      # Build binary matrix representation with triples
      binary_matrix_with_triples =
        Enum.map(matrix, fn {constraints, {r, c, n}} ->
          binary_row =
            for col <- 0..(total_constraints - 1) do
              if MapSet.member?(constraints, col), do: "O", else: "-"
            end

          {{r, c, n}, binary_row}
        end)

      m = length(binary_matrix_with_triples)
      n = total_constraints

      # Header lines
      header_lines = [
        "#{m}x#{n}",
        "Cell|Row|Col|Box"
      ]

      # Matrix rows (limit to reasonable number for display)
      # For small grids (4x4), show more rows and don't truncate columns
      max_rows = if grid_size <= 4, do: 50, else: 20
      max_cols = if grid_size <= 4, do: total_constraints, else: 60
      
      matrix_rows =
        binary_matrix_with_triples
        |> Enum.take(max_rows)
        |> Enum.map(fn {{r, c, n}, row} ->
          row_str = Enum.join(row, "")
          # For small grids, show full row; for larger, truncate
          display_row = if grid_size <= 4 do
            row_str
          else
            if String.length(row_str) > max_cols, do: String.slice(row_str, 0..(max_cols - 1)) <> "...", else: row_str
          end
          "(#{r},#{c},#{n}) #{display_row}"
        end)

      final_matrix_rows = if length(binary_matrix_with_triples) > max_rows do
        matrix_rows ++ ["... (#{length(binary_matrix_with_triples) - max_rows} more rows)"]
      else
        matrix_rows
      end

      header_lines ++ final_matrix_rows
    end
  end

  @doc false
  # Pads lines to a specified height with empty strings.
  #
  # Used to align board and matrix displays when showing them side by side.
  #
  # ## Parameters
  #
  #   - `lines` - List of strings to pad.
  #   - `target_height` - Target number of lines.
  #   - `width` - Width of padding (for consistent spacing).
  #
  # ## Returns
  #
  #   - `list()` - Padded list of strings.
  defp pad_lines(lines, target_height, width) do
    current_height = length(lines)
    padding_needed = max(0, target_height - current_height)
    padding = List.duplicate(String.duplicate(" ", width), padding_needed)
    lines ++ padding
  end
end
