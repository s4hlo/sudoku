puzzle = [
  [1, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0]
]

order = trunc(:math.sqrt(length(puzzle)))

matrix = Sudoku.Utils.AlgorithmX.build_exact_cover_matrix(puzzle, order)

Sudoku.Visualizer.visualize_exact_cover_matrix(matrix, order)
