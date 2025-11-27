defmodule Sudoku.Visualizer do
  @moduledoc """
  Module for visualizing Sudoku solving process with animated display.
  """

  @doc """
  Prints the sudoku board history as an animated sequence.

  Each state is displayed with beautiful box-drawing borders similar to Neovim plugins.

  ## Parameters
  - `history`: List of sudoku board states (from `solve_log`)
  - `opts`: Keyword list of options:
    - `:delay` - Delay between frames in milliseconds (default: 100)
    - `:clear_screen` - Whether to clear screen between frames (default: true)
  """
  def animate_history(history, opts \\ []) when is_list(history) do
    delay = Keyword.get(opts, :delay, 100)
    clear_screen = Keyword.get(opts, :clear_screen, true)

    history
    |> Enum.with_index(1)
    |> Enum.each(fn {state, index} ->
      # Build the complete board content first
      board_content = build_board_content(state, index, length(history))

      # Clear screen and print immediately in one operation to avoid flickering
      output =
        if clear_screen do
          IO.ANSI.clear() <> IO.ANSI.cursor(0, 0) <> board_content
        else
          board_content
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
    box_size = Utils.calculate_box_size(grid_size)

    # Calculate cell width (for numbers up to grid_size)
    # Use a fixed width of 3 for better visual appearance (1 char for number + 1 space on each side)
    cell_content_width = 3

    # Build the board first to get actual width
    lines = build_board_lines(grid, grid_size, box_size, cell_content_width)
    board_width = lines |> List.first() |> String.length()

    # Add frame info
    frame_info = "Frame #{frame_num}/#{total_frames}"
    header = build_header(frame_info, board_width)

    header <> "\n" <> Enum.join(lines, "\n") <> "\n"
  end

  defp build_header(frame_info, _board_width) do
    frame_info
  end

  defp build_board_lines(grid, grid_size, box_size, cell_width) do
    # Top border
    top_border = build_top_border(grid_size, box_size, cell_width)

    # Grid rows
    grid_lines =
      grid
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, row_idx} ->
        row_lines = build_row_lines(row, row_idx, grid_size, box_size, cell_width)

        # Add separator after each box (except last)
        separator =
          if rem(row_idx + 1, box_size) == 0 and row_idx < grid_size - 1 do
            [build_horizontal_separator(grid_size, box_size, cell_width)]
          else
            []
          end

        row_lines ++ separator
      end)

    # Bottom border
    bottom_border = build_bottom_border(grid_size, box_size, cell_width)

    [top_border] ++ grid_lines ++ [bottom_border]
  end

  defp build_top_border(grid_size, box_size, cell_width) do
    "╭" <>
      (0..(grid_size - 1)
       |> Enum.map(fn col_idx ->
         String.duplicate("─", cell_width) <>
           cond do
             rem(col_idx + 1, box_size) == 0 and col_idx < grid_size - 1 -> "┬"
             col_idx < grid_size - 1 -> "─"
             true -> ""
           end
       end)
       |> Enum.join("")) <>
      "╮"
  end

  defp build_bottom_border(grid_size, box_size, cell_width) do
    "╰" <>
      (0..(grid_size - 1)
       |> Enum.map(fn col_idx ->
         String.duplicate("─", cell_width) <>
           cond do
             rem(col_idx + 1, box_size) == 0 and col_idx < grid_size - 1 -> "┴"
             col_idx < grid_size - 1 -> "─"
             true -> ""
           end
       end)
       |> Enum.join("")) <>
      "╯"
  end

  defp build_horizontal_separator(grid_size, box_size, cell_width) do
    "├" <>
      (0..(grid_size - 1)
       |> Enum.map(fn col_idx ->
         String.duplicate("─", cell_width) <>
           cond do
             rem(col_idx + 1, box_size) == 0 and col_idx < grid_size - 1 -> "┼"
             col_idx < grid_size - 1 -> "─"
             true -> ""
           end
       end)
       |> Enum.join("")) <>
      "┤"
  end

  defp build_row_lines(row, _row_idx, grid_size, box_size, _cell_width) do
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
               rem(col_idx + 1, box_size) == 0 and col_idx < grid_size - 1 -> "│"
               col_idx < grid_size - 1 -> " "
               true -> ""
             end
         end)
         |> Enum.join("")) <>
        "│"

    [row_line]
  end
end
