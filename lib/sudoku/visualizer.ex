defmodule Sudoku.Visualizer do
  @moduledoc """
  Module for visualizing Sudoku solving process with animated display.
  """

  @doc """
  Prints the sudoku board history as an animated sequence.

  Each state is displayed with beautiful box-drawing borders similar to Neovim plugins.

  ## Parameters
  - `history`: List of sudoku board states (from `solve_log`) or list of {grid, matrix} tuples
  - `opts`: Keyword list of options:
    - `:delay` - Delay between frames in milliseconds (default: 100)
    - `:clear_screen` - Whether to clear screen between frames (default: true)
  """
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
  Prints a single sudoku board state with beautiful borders.
  """
  def print_board(grid, frame_num \\ 1, total_frames \\ 1) when is_list(grid) do
    IO.write(build_board_content(grid, frame_num, total_frames))
  end

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

  defp build_header(frame_info, _board_width) do
    frame_info
  end

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

  ## Parameters
  - `matrix`: List of {constraints, {r, c, n}} tuples from Algorithm X
  - `order`: Order of the sudoku grid (box size)
  """
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

  # Build combined content showing board and matrix side by side
  defp build_combined_content(grid, matrix, frame_num, total_frames) do
    order = Utils.calculate_order(grid)
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

  # Build matrix lines for display
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

  # Pad lines to specified height
  defp pad_lines(lines, target_height, width) do
    current_height = length(lines)
    padding_needed = max(0, target_height - current_height)
    padding = List.duplicate(String.duplicate(" ", width), padding_needed)
    lines ++ padding
  end
end
