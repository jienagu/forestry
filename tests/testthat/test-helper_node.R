##################################################
###  tree helper Tests  #################
##################################################

library(testthat)
library(here)
library(data.tree)
context("test tree node are functioning properly")


testthat::test_that(
  "create_nodes() produces expected", {
    result <-  create_nodes("cells", 3, colors = c("red", "yellow", "blue"), value = c(1,NA,3) )
    result$count %>%
      expect_equal(3)
    as.character(result$Get("colors") ) %>%
      expect_equal(c(NA, "red", "yellow", "blue"))
  }
)

testthat::test_that(
  "create_tree() produces expected", {
    data(test_df)
    test_node <- data.tree::as.Node(test_df)
    tree_test_leaf <- create_tree(test_node$children, "new_tree")
    names(tree_test_leaf$children) %>%
      expect_equal(c("1", "2", "3"))
    tree_test_leaf$count %>%
      expect_equal(3)
  }
)


testthat::test_that(
  "fix_items() produces expected", {
    cell_node2 <- Node$new("cell2")
    cell_node2$AddChild("B")
    cell_node2$AddChild("C")
    cell_node2$Set(class = c(NA, "B1", "C1"))
   result <- fix_items(fix_vector = c("A", "B", "C", "D"), input_node = cell_node2)
   names(result$children) %>%
     expect_equal(c("A", "B", "C", "D" ))
  }
)

testthat::test_that(
  "children_sort() produces expected", {
    data(test_df)
    test_node <- data.tree::as.Node(test_df)
    result <- children_sort(
      input_node = test_node,
      input_order = c("groupB", "groupA"),
      mismatch_last = T)
    names(result$children) %>%
      expect_equal(c("groupB", "groupA", "groupC" ))
  }
)


testthat::test_that(
  "cumsum_across_level() produces expected", {
    data(test_df)
    test_node <- data.tree::as.Node(test_df)
    result <- cumsum_across_level(input_node = test_node, attri_name = "hc", level_num = 3)
    as.numeric(result$Get("cumsum_number")) %>%
      expect_equal(c(NA, NA,  80, 177,  NA, 221, 258,  NA, 339, 385 ))
  }
)

testthat::test_that(
  "pre_get_array() produces expected", {
    new_node <- create_nodes(tree_name = "tree1", add_children_count = 3, class = c("A", "B", "C"))
    result <- pre_get_array(as.list(new_node) )
    names(result) %>%
      expect_equal(NULL)
  }
)


testthat::test_that(
  "fill_NA_level() produces expected", {
    new_node <- create_nodes(tree_name = "tree1", add_children_count = 3, hc = c(1, 2, NA))
    result <- fill_NA_level(input_node = new_node, field_name = "hc", by_level = 2, fill_with = 0 )
    as.numeric(result$Get("hc")) %>%
      expect_equal(c(NA, 1, 2, 0))
  }
)
