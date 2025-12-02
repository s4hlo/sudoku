defmodule Sudoku.File do
  @spec read_file(String.t()) :: {:ok, list()} | {:error, String.t()}
  def read_file(file_path) do
    case File.read(file_path) do
      {:ok, content} -> parse_file_content(content)
      {:error, reason} -> {:error, "Failed to read file: #{inspect(reason)}"}
    end
  end

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

  defp remove_trailing_empty(lines) do
    lines
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == ""))
    |> Enum.reverse()
  end

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
