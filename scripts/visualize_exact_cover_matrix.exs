puzzle = [
  [1, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0]
]

grid_size = length(puzzle)
box_size = Utils.calculate_box_size(grid_size)

matrix = Utils.AlgorithmX.build_exact_cover_matrix(puzzle, grid_size, box_size)

Sudoku.Visualizer.visualize_exact_cover_matrix(matrix, grid_size)
