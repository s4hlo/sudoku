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

history = Sudoku.solve_log(puzzle, Sudoku.Backtracking)

if history do
  formatted = 
    history
    |> Enum.with_index(1)
    |> Enum.map(fn {state, index} ->
      rows = 
        state
        |> Enum.map(fn row ->
          row_string = 
            row
            |> Enum.map(&Integer.to_string/1)
            |> Enum.join(", ")
          "    [#{row_string}],"
        end)
        |> Enum.join("\n")
      
      if index < length(history) do
        "  [\n#{rows}\n  ],"
      else
        "  [\n#{rows}\n  ]"
      end
    end)
    |> Enum.join("\n")
  
  result = "[\n#{formatted}\n]"
  
  IO.puts(result)
  File.write!("history_output.exs", result)
else
  :error
end
