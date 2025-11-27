puzzle = [
  [1, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0]
]

history = Sudoku.solve_log(puzzle, Sudoku.AlgorithmX)

if history do
  Sudoku.Visualizer.animate_history(history, delay: 300)
else
  IO.puts("No solution found")
end
