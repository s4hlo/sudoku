defmodule Sudoku.DLX do
  @moduledoc """
  Solves Sudoku puzzles using Knuth's DLX (Dancing Links X) algorithm.
  
  This implementation uses doubly-linked lists (dancing links) as described
  by Donald Knuth in his paper on Algorithm X. The doubly-linked structure
  allows efficient covering and uncovering of columns and rows.
  """

  def solve(grid) when is_list(grid) do
    grid_size = length(grid)
    box_size = Utils.calculate_box_size(grid_size)
    
    # Validate initial grid doesn't violate constraints
    if not Validator.valid_initial_grid?(grid, grid_size, box_size) do
      nil
    else
      # Build exact cover matrix and convert to DLX structure
      matrix = Utils.AlgorithmX.build_exact_cover_matrix(grid, grid_size, box_size)
      dlx_state = build_dlx(matrix, grid_size)
      
      # Solve using DLX
      case dlx_search(dlx_state, []) do
        nil -> nil
        solution -> Utils.AlgorithmX.solution_to_grid(solution, grid, grid_size)
      end
    end
  end

  # DLX State structure: %{root: root_id, nodes: %{id => node}, columns: [column_ids]}
  # Node structure: %{id: id, left: left_id, right: right_id, up: up_id, down: down_id, 
  #                   column: column_id, row_data: choice}
  # Column header: %{id: id, left: left_id, right: right_id, up: up_id, down: down_id,
  #                  size: count, name: constraint_index}

  defp build_dlx(matrix, grid_size) do
    num_constraints = 4 * grid_size * grid_size
    
    # Create column headers
    {columns, nodes} = create_columns(num_constraints)
    
    # Create nodes for each row in the matrix
    {row_nodes, nodes} = create_row_nodes(matrix, columns, nodes, 0)
    
    # Link nodes vertically in each column
    nodes = link_nodes_vertically(row_nodes, nodes)
    
    # Create root node that points to first column
    root_id = :root
    first_column_id = hd(columns)
    root_node = %{
      id: root_id,
      left: root_id,
      right: first_column_id,
      up: root_id,
      down: root_id,
      column: :root,
      row_data: :root
    }
    
    nodes = Map.put(nodes, root_id, root_node)
    
    %{root: root_id, nodes: nodes, columns: columns}
  end

  defp create_columns(num_constraints) do
    {columns, nodes, _} = 
      Enum.reduce(0..(num_constraints - 1), {[], %{}, nil}, fn i, {cols_acc, nodes_acc, prev_id} ->
        col_id = {:column, i}
        
        col_node = %{
          id: col_id,
          left: prev_id,
          right: nil,  # Will be set later
          up: col_id,
          down: col_id,
          column: col_id,
          size: 0,
          name: i
        }
        
        cols_acc = [col_id | cols_acc]
        nodes_acc = Map.put(nodes_acc, col_id, col_node)
        {cols_acc, nodes_acc, col_id}
      end)
    
    # Link columns horizontally (circular)
    columns = Enum.reverse(columns)
    nodes = link_columns_horizontally(columns, nodes)
    
    {columns, nodes}
  end

  defp link_columns_horizontally([], nodes), do: nodes

  defp link_columns_horizontally([col_id], nodes) do
    # Single column - link to itself
    update_node(nodes, col_id, &%{&1 | left: col_id, right: col_id})
  end

  defp link_columns_horizontally(columns, nodes) do
    # Link all columns in a circle
    {nodes, _} = 
      Enum.reduce(columns, {nodes, nil}, fn col_id, {nodes_acc, prev_id} ->
        node = nodes_acc[col_id]
        
        nodes_acc = 
          if prev_id == nil do
            # First column
            update_node(nodes_acc, col_id, &%{&1 | left: List.last(columns), right: col_id})
          else
            # Link to previous
            prev_node = nodes_acc[prev_id]
            nodes_acc = update_node(nodes_acc, prev_id, &%{&1 | right: col_id})
            update_node(nodes_acc, col_id, &%{&1 | left: prev_id, right: col_id})
          end
        
        {nodes_acc, col_id}
      end)
    
    # Link last to first
    first_id = hd(columns)
    last_id = List.last(columns)
    first_node = nodes[first_id]
    last_node = nodes[last_id]
    
    nodes = update_node(nodes, first_id, &%{&1 | left: last_id})
    update_node(nodes, last_id, &%{&1 | right: first_id})
  end

  defp create_row_nodes([], _columns, nodes, _node_id), do: {[], nodes}

  defp create_row_nodes([{constraints, choice} | rest], columns, nodes, node_id) do
    constraint_list = MapSet.to_list(constraints)
    
    # Create nodes for each constraint in this row
    {row_nodes, nodes, node_id} = 
      Enum.reduce(constraint_list, {[], nodes, node_id}, fn constraint_idx, {row_acc, nodes_acc, id_acc} ->
        column_id = Enum.at(columns, constraint_idx)
        node_id = {:node, id_acc}
        
        node = %{
          id: node_id,
          left: nil,  # Will be set when linking horizontally
          right: nil,
          up: nil,    # Will be set when linking vertically
          down: nil,
          column: column_id,
          row_data: choice
        }
        
        {[node_id | row_acc], Map.put(nodes_acc, node_id, node), id_acc + 1}
      end)
    
    row_nodes = Enum.reverse(row_nodes)
    
    # Link nodes horizontally (circular)
    nodes = link_row_horizontally(row_nodes, nodes)
    
    # Continue with rest of rows
    {rest_rows, nodes} = create_row_nodes(rest, columns, nodes, node_id)
    {[row_nodes | rest_rows], nodes}
  end

  defp link_row_horizontally([], nodes), do: nodes

  defp link_row_horizontally([node_id], nodes) do
    # Single node - link to itself
    update_node(nodes, node_id, &%{&1 | left: node_id, right: node_id})
  end

  defp link_row_horizontally(row_nodes, nodes) do
    # Link all nodes in a circle
    {nodes, _} = 
      Enum.reduce(row_nodes, {nodes, nil}, fn node_id, {nodes_acc, prev_id} ->
        nodes_acc = 
          if prev_id == nil do
            # First node
            update_node(nodes_acc, node_id, &%{&1 | left: List.last(row_nodes), right: node_id})
          else
            # Link to previous
            nodes_acc = update_node(nodes_acc, prev_id, &%{&1 | right: node_id})
            update_node(nodes_acc, node_id, &%{&1 | left: prev_id, right: node_id})
          end
        
        {nodes_acc, node_id}
      end)
    
    # Link last to first
    first_id = hd(row_nodes)
    last_id = List.last(row_nodes)
    
    first_node = nodes[first_id]
    last_node = nodes[last_id]
    
    nodes = update_node(nodes, first_id, &%{&1 | left: last_id})
    update_node(nodes, last_id, &%{&1 | right: first_id})
  end

  defp link_nodes_vertically([], nodes), do: nodes

  defp link_nodes_vertically(row_nodes_list, nodes) do
    # Group nodes by column
    nodes_by_column = 
      Enum.reduce(row_nodes_list, %{}, fn row_nodes, acc ->
        Enum.reduce(row_nodes, acc, fn node_id, acc2 ->
          node = nodes[node_id]
          column_id = node.column
          Map.update(acc2, column_id, [node_id], &[node_id | &1])
        end)
      end)
    
    # Link nodes vertically in each column
    Enum.reduce(nodes_by_column, nodes, fn {column_id, node_ids}, nodes_acc ->
      link_column_vertically(column_id, Enum.reverse(node_ids), nodes_acc)
    end)
  end

  defp link_column_vertically(column_id, [], nodes) do
    # Column header already points to itself
    nodes
  end

  defp link_column_vertically(column_id, node_ids, nodes) do
    column_node = nodes[column_id]
    
    # Link nodes vertically
    {nodes, _} = 
      Enum.reduce(node_ids, {nodes, column_id}, fn node_id, {nodes_acc, prev_id} ->
        node = nodes_acc[node_id]
        
        # Link node to previous (or column header)
        nodes_acc = update_node(nodes_acc, node_id, &%{&1 | up: prev_id})
        
        # Link previous to this node (or update column header)
        nodes_acc = 
          if prev_id == column_id do
            # First node - update column header's down pointer
            update_node(nodes_acc, column_id, &%{&1 | down: node_id})
          else
            # Update previous node's down pointer
            update_node(nodes_acc, prev_id, &%{&1 | down: node_id})
          end
        
        {nodes_acc, node_id}
      end)
    
    # Link last node back to column header
    last_node_id = List.last(node_ids)
    nodes = update_node(nodes, last_node_id, &%{&1 | down: column_id})
    nodes = update_node(nodes, column_id, &%{&1 | up: last_node_id})
    
    # Update column size
    update_node(nodes, column_id, &%{&1 | size: length(node_ids)})
  end

  # DLX Search Algorithm
  defp dlx_search(state, solution) do
    root_id = state.root
    nodes = state.nodes
    root_node = nodes[root_id]
    
    # If root.right == root, all columns are covered (solution found)
    if root_node.right == root_id do
      solution
    else
      # Choose column c (minimum remaining values heuristic)
      c_id = choose_column(root_id, nodes)
      
      if c_id == nil do
        nil
      else
        # Cover column c
        {nodes_after_cover, _} = cover_column(c_id, nodes)
        
        # Try each row r in column c
        result = try_rows_dlx(c_id, root_id, %{state | nodes: nodes_after_cover}, solution, nodes)
        
        # Uncover column c if no solution found (backtrack)
        if result == nil do
          nodes_after_uncover = uncover_column(c_id, nodes_after_cover)
          nil
        else
          result
        end
      end
    end
  end

  defp choose_column(root_id, nodes) do
    root_node = nodes[root_id]
    find_min_column(root_id, root_node.right, root_id, nodes, nil, :infinity)
  end

  defp find_min_column(root_id, current_id, root_id, _nodes, best_col, _best_size) do
    # Wrapped back to root
    best_col
  end

  defp find_min_column(root_id, current_id, _prev_id, nodes, best_col, best_size) do
    current_node = nodes[current_id]
    
    if current_node.size < best_size do
      find_min_column(root_id, current_node.right, current_id, nodes, current_id, current_node.size)
    else
      find_min_column(root_id, current_node.right, current_id, nodes, best_col, best_size)
    end
  end

  defp try_rows_dlx(column_id, root_id, state, solution, original_nodes) do
    nodes = state.nodes
    column_node = nodes[column_id]
    
    # Start from first node in column (below header)
    first_node_id = column_node.down
    
    if first_node_id == column_id do
      # No rows in this column - uncover and backtrack
      nodes = uncover_column(column_id, nodes)
      nil
    else
      try_rows_dlx_recursive(column_id, first_node_id, root_id, state, solution, original_nodes)
    end
  end

  defp try_rows_dlx_recursive(column_id, node_id, _root_id, state, _solution, _original_nodes) 
       when is_atom(node_id) and elem(node_id, 0) == :column do
    # Wrapped back to column header - all rows tried, uncover column and backtrack
    nodes = uncover_column(column_id, state.nodes)
    nil
  end

  defp try_rows_dlx_recursive(column_id, node_id, root_id, state, solution, original_nodes) do
    nodes = state.nodes
    node = nodes[node_id]
    
    # Include this row in solution
    row_data = node.row_data
    new_solution = [row_data | solution]
    
    # Cover all columns that this row satisfies
    {nodes_after_cover_row, _} = cover_row(node_id, nodes)
    
    # Recursively search
    result = dlx_search(%{state | nodes: nodes_after_cover_row}, new_solution)
    
    # If solution found, return it immediately
    if result != nil do
      result
    else
      # Uncover this row before trying next row
      nodes_after_uncover = uncover_row(node_id, nodes_after_cover_row)
      
      # Try next row
      next_node_id = node.down
      try_rows_dlx_recursive(column_id, next_node_id, root_id, %{state | nodes: nodes_after_uncover}, solution, original_nodes)
    end
  end

  # Cover column c: remove c from header list and remove all rows in c
  defp cover_column(column_id, nodes) do
    column_node = nodes[column_id]
    
    # Remove c from header list
    left_id = column_node.left
    right_id = column_node.right
    
    left_node = nodes[left_id]
    right_node = nodes[right_id]
    
    nodes = update_node(nodes, left_id, &%{&1 | right: right_id})
    nodes = update_node(nodes, right_id, &%{&1 | left: left_id})
    
    # Remove all rows in column c
    cover_column_rows(column_node.down, column_id, nodes)
  end

  defp cover_column_rows(node_id, column_id, nodes) when node_id == column_id do
    # Wrapped back to column header
    {nodes, :ok}
  end

  defp cover_column_rows(node_id, column_id, nodes) do
    # Cover this row (remove it from all its columns)
    {nodes, _} = cover_row(node_id, nodes)
    
    # Move to next node down
    node = nodes[node_id]
    cover_column_rows(node.down, column_id, nodes)
  end

  # Cover row r: remove all columns that this row satisfies
  defp cover_row(node_id, nodes) do
    node = nodes[node_id]
    # Start from node r and traverse right
    cover_row_columns(node.right, node_id, nodes)
  end

  defp cover_row_columns(node_id, start_node_id, nodes) when node_id == start_node_id do
    # Wrapped back to start
    {nodes, :ok}
  end

  defp cover_row_columns(node_id, start_node_id, nodes) do
    node = nodes[node_id]
    column_id = node.column
    
    # Cover the column this node belongs to
    {nodes, _} = cover_column_node(column_id, node_id, nodes)
    
    # Move to next node right
    cover_row_columns(node.right, start_node_id, nodes)
  end

  # Cover a single node in a column (remove node from column's vertical list)
  defp cover_column_node(column_id, node_id, nodes) do
    node = nodes[node_id]
    up_id = node.up
    down_id = node.down
    
    up_node = nodes[up_id]
    down_node = nodes[down_id]
    
    # Link up and down nodes together
    nodes = update_node(nodes, up_id, &%{&1 | down: down_id})
    nodes = update_node(nodes, down_id, &%{&1 | up: up_id})
    
    # Decrease column size
    column_node = nodes[column_id]
    nodes = update_node(nodes, column_id, &%{&1 | size: column_node.size - 1})
    
    {nodes, :ok}
  end

  # Uncover column c: restore c to header list and restore all rows
  defp uncover_column(column_id, nodes) do
    column_node = nodes[column_id]
    
    # Restore all rows in column c (in reverse order)
    nodes = uncover_column_rows(column_node.up, column_id, nodes)
    
    # Restore c to header list
    left_id = column_node.left
    right_id = column_node.right
    
    nodes = update_node(nodes, left_id, &%{&1 | right: column_id})
    update_node(nodes, right_id, &%{&1 | left: column_id})
  end

  defp uncover_column_rows(node_id, column_id, nodes) when node_id == column_id do
    # Wrapped back to column header
    nodes
  end

  defp uncover_column_rows(node_id, column_id, nodes) do
    # Move to next node up first (reverse order)
    node = nodes[node_id]
    nodes = uncover_column_rows(node.up, column_id, nodes)
    
    # Uncover this row (restore it to all its columns)
    uncover_row(node_id, nodes)
  end

  # Uncover row r: restore all columns that this row satisfies
  defp uncover_row(node_id, nodes) do
    node = nodes[node_id]
    # Start from node r and traverse left (reverse order)
    # Note: we start from left neighbor, not the node itself
    uncover_row_columns(node.left, node_id, nodes)
  end

  defp uncover_row_columns(node_id, start_node_id, nodes) when node_id == start_node_id do
    # Wrapped back to start
    nodes
  end

  defp uncover_row_columns(node_id, start_node_id, nodes) do
    # Move to next node left first (reverse order)
    node = nodes[node_id]
    nodes = uncover_row_columns(node.left, start_node_id, nodes)
    
    # Uncover the column this node belongs to
    uncover_column_node(node.column, node_id, nodes)
  end

  # Uncover a single node in a column (restore node to column's vertical list)
  defp uncover_column_node(column_id, node_id, nodes) do
    node = nodes[node_id]
    up_id = node.up
    down_id = node.down
    
    up_node = nodes[up_id]
    down_node = nodes[down_id]
    
    # Restore links
    nodes = update_node(nodes, up_id, &%{&1 | down: node_id})
    nodes = update_node(nodes, down_id, &%{&1 | up: node_id})
    
    # Increase column size
    column_node = nodes[column_id]
    update_node(nodes, column_id, &%{&1 | size: column_node.size + 1})
  end

  defp update_node(nodes, node_id, update_fun) do
    node = nodes[node_id]
    Map.put(nodes, node_id, update_fun.(node))
  end
end
