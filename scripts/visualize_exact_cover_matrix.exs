puzzle = [
  [1, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0]
]

grid_size = length(puzzle)
box_size = Utils.calculate_box_size(grid_size)

matrix = Utils.AlgorithmX.build_exact_cover_matrix(puzzle, grid_size, box_size)

# Calculate total number of constraints (columns)
total_constraints = 4 * grid_size * grid_size

# Build binary matrix representation with triples
binary_matrix_with_triples = 
  Enum.map(matrix, fn {constraints, {r, c, n}} ->
    # Create a list of - and O for each row
    binary_row = for col <- 0..(total_constraints - 1) do
      if MapSet.member?(constraints, col), do: "O", else: "-"
    end
    {{r, c, n}, binary_row}
  end)

# Print header with dimensions and constraint order
m = length(binary_matrix_with_triples)
n = total_constraints
cell_end = grid_size * grid_size - 1
row_start = grid_size * grid_size
row_end = 2 * grid_size * grid_size - 1
col_start = 2 * grid_size * grid_size
col_end = 3 * grid_size * grid_size - 1
box_start = 3 * grid_size * grid_size
box_end = 4 * grid_size * grid_size - 1

IO.puts("#{m}x#{n}")
IO.puts("Constraint order: Cell (#{0}..#{cell_end}) | Row (#{row_start}..#{row_end}) | Column (#{col_start}..#{col_end}) | Box (#{box_start}..#{box_end})")

# Print the matrix with triples
Enum.each(binary_matrix_with_triples, fn {{r, c, n}, row} ->
  IO.puts("(#{r},#{c},#{n}) #{Enum.join(row, "")}")
end)
