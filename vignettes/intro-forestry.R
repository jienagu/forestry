## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  warning = FALSE, message = FALSE, echo = TRUE,
  comment = "#>"
)

## ----create_node--------------------------------------------------------------
library(data.tree)
library(forestry)
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         class = c("A", "B", "C") )
print(new_node, "class")

## ----create_node11------------------------------------------------------------
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         hc = c(1, 2, NA))
print(new_node, "hc" )

## ----create_node12------------------------------------------------------------
result <- fill_NA_level(input_node = new_node, 
                        field_name = "hc", 
                        by_level = 2, 
                        fill_with = 0)
print(result, "hc")

## ----create_node2-------------------------------------------------------------
data(test_df)
test_node <- data.tree::as.Node(test_df)
print(test_node$children)

## ----create_node3-------------------------------------------------------------
library(data.tree)
test_node <- as.Node(test_df)
new_shape <- create_tree(test_node$children,"new_tree")
print(new_shape, "hc")

## ----create_node4_pre---------------------------------------------------------
cell_node2 <- Node$new("cell2")
cell_node2$AddChild("B")
cell_node2$AddChild("C")
cell_node2$Set(class = c(NA, "B1", "C1"))
print(cell_node2, "class")

## ----create_node5-------------------------------------------------------------
cell_fixed_items <- fix_items(fix_vector = c("A", "B", "C", "D"), 
                              input_node = cell_node2)
print(cell_fixed_items, "class")

## ----create_node6-------------------------------------------------------------
data(test_df)
test_node <- data.tree::as.Node(test_df)
sorted_node <- children_sort(
  input_node = test_node, 
  input_order = c("groupB", "groupA"),
  mismatch_last = T)
print(sorted_node)

## ----create_node7-------------------------------------------------------------
data(exercise_df)
exercise_node <- as.Node(exercise_df)
test <- forestry::cumsum_across_level(input_node = exercise_node, 
                              attri_name = "exercise_time", 
                              level_num = 3)
print(test, "cumsum_number", "exercise_time", "level")

## ----create_node8-------------------------------------------------------------
data(exercise_df)
exercise_node <- as.Node(exercise_df)
exercise_node$Do(function(node) node$exercise_time <- Aggregate(node, 
                                                   attribute = "exercise_time", 
                                                   aggFun = sum), 
             traversal = "post-order")
print(exercise_node,  "exercise_time")

exercise_node_test <- cumsum_across_level(input_node = exercise_node, 
                              attri_name = "exercise_time", 
                              level_num = "All")
print(exercise_node_test,"exercise_time", "cumsum_number", "level")

## ----create_node9-------------------------------------------------------------
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         class = c("A", "B", "C"))
print(as.list(new_node) )

## ----create_node10------------------------------------------------------------
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         class = c("A", "B", "C"))
print(pre_get_array(as.list(new_node) ) )

