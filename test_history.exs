# puzzle = [
#   [1, 4, 0, 0],
#   [3, 4, 0, 0],
#   [0, 0, 0, 1],
#   [0, 0, 4, 0]
# ]


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

IO.puts("Testing history feature...")
history = Sudoku.solve_log(puzzle, Sudoku.Backtracking)

if history do
  IO.puts("✓ History returned successfully")
  IO.puts("Number of states: #{length(history)}")
  IO.puts("\nAll states:")
  IO.puts(String.duplicate("=", 50))
  
  history
  |> Enum.with_index(1)
  |> Enum.each(fn {state, index} ->
    IO.puts("\nState #{index}:")
    state
    |> Enum.each(fn row ->
      row
      |> Enum.map(&Integer.to_string/1)
      |> Enum.join(" ")
      |> IO.puts()
    end)
  end)
else
  IO.puts("✗ No solution found")
end
