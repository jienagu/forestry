

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/forestry)](https://cran.r-project.org/package=forestry)
[![Rdoc](http://www.rdocumentation.org/badges/version/forestry)](http://www.rdocumentation.org/packages/forestry) 
[![Download](https://cranlogs.r-pkg.org/badges/grand-total/forestry)](https://cranlogs.r-pkg.org/badges/grand-total/forestry)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

# forestry <img src="forestry_hex2.png"  width="180px" align="right"/>

forestry is an R package with a series of utility functions to help with
reshaping hierarchy of data tree, and reform the structure of data tree.

## Installation

You can install the cran version of forestry:

``` r
install.packages("forestry")
```

## Introduction

Built on the top of
[data.tree](https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html),
a Node (tree) is an R6 object that is especially useful when we are
facing *hierarchical data*. The **forestry** package helps to reshape or
create tree objects. This package is a series of utility functions to
help with nested data. Since
[data.tree](https://cran.r-project.org/web/packages/data.tree/vignettes/data.tree.html)
has the capability to convert a tree to JSON using `toJSON()` after
converting to a list using `as.list()`, the **forestry** package is
particularly useful when creating a specific JSON object for building
htmlwidgets. The **forestry** package aims to reshape or create tree
objects with a specific format.

## Create a Node with Assigned Attributes

`create_nodes()` creates a Node object. `tree_name` is to assign the
name of this Node. `add_children_count` is to assign the number of
children to this Node, it will be listed in numerical order. To assign
values to each node, simply put the appropriate variable as a parameter
with a vector containing the values. The name of the parameter will be
the variable name and the values in the vector will be assigned to each
node respectively.

``` r
library(data.tree)
library(forestry)
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         class = c("A", "B", "C") )
print(new_node, "class")
#>   levelName class
#> 1     tree1      
#> 2      ¦--1     A
#> 3      ¦--2     B
#> 4      °--3     C
```

## Fill Missing Values Across a Level

The `fill_NA_level()` function will fill missing values across the
desired level with desired value (default as 0). For example, `new_node`
is a tree with missing value in hc field.

``` r
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         hc = c(1, 2, NA))
print(new_node, "hc" )
#>   levelName hc
#> 1     tree1 NA
#> 2      ¦--1  1
#> 3      ¦--2  2
#> 4      °--3 NA
```

We apply `fill_NA_level()` to `new_node`, simply put `new_node` as
`input_node`, assign the `field_name` with `hc`, and assign `by_level
= 2`, we will fill the `NA` in hc field with 0 across level 2.

``` r
result <- fill_NA_level(input_node = new_node, 
                        field_name = "hc", 
                        by_level = 2, 
                        fill_with = 0)
print(result, "hc")
#>   levelName hc
#> 1     tree1 NA
#> 2      ¦--1  1
#> 3      ¦--2  2
#> 4      °--3  0
```

## Create a Tree From a List

`create_tree()` creates a new tree from a list. It appends each item of
the input list as a numbered child in the new tree. This is useful when
we convert a Node to a JSON array.

For instance, let’s use `test_node$children` (a list) as an example. We
can see a list of groupA, groupB and groupC.

``` r
data(test_df)
test_node <- data.tree::as.Node(test_df)
print(test_node$children)
#> $groupA
#>    levelName
#> 1 groupA    
#> 2  ¦--Male  
#> 3  °--Female
#> 
#> $groupB
#>    levelName
#> 1 groupB    
#> 2  ¦--Male  
#> 3  °--Female
#> 
#> $groupC
#>    levelName
#> 1 groupC    
#> 2  ¦--Male  
#> 3  °--Female
```

Now we see that this list is reshaped into a list, *new\_tree*, with
each item in `test_node$children` added as a child. The index of each
item in the list is assigned as the name of each child.

``` r
library(data.tree)
test_node <- as.Node(test_df)
new_shape <- create_tree(test_node$children,"new_tree")
print(new_shape, "hc")
#>             levelName hc
#> 1  new_tree           NA
#> 2   ¦--1              NA
#> 3   ¦   °--groupA     NA
#> 4   ¦       ¦--Male   80
#> 5   ¦       °--Female 97
#> 6   ¦--2              NA
#> 7   ¦   °--groupB     NA
#> 8   ¦       ¦--Male   44
#> 9   ¦       °--Female 37
#> 10  °--3              NA
#> 11      °--groupC     NA
#> 12          ¦--Male   81
#> 13          °--Female 46
```

## Expand Children Nodes

`fix_items()` creates a tree with fixed children nodes from another
tree. It automatically copies fields to the tree and fills missing
values with `NA`. Similar to left joining to a tree with certian
children nodes.

This function is to make sure the tree has the desired children nodes.

See *cell\_node2*, it has only B and C.

``` r
cell_node2 <- Node$new("cell2")
cell_node2$AddChild("B")
cell_node2$AddChild("C")
cell_node2$Set(class = c(NA, "B1", "C1"))
print(cell_node2, "class")
#>   levelName class
#> 1     cell2      
#> 2      ¦--B    B1
#> 3      °--C    C1
```

Now we put `fix_vector = c("A", "B", "C", "D")` and assign to a new
tree, `cell_fixed_items`. We can see that `cell_fixed_items` has all of
the nodes from `fix_vector` and still inherits the fields from
`cell_node2`.

``` r
cell_fixed_items <- fix_items(fix_vector = c("A", "B", "C", "D"), 
                              input_node = cell_node2)
print(cell_fixed_items, "class")
#>   levelName class
#> 1     cell2      
#> 2      ¦--A      
#> 3      ¦--B    B1
#> 4      ¦--C    C1
#> 5      °--D
```

## Sort Chidren Nodes

`children_sort()` function sorts the children nodes into a desired
order. If there are children nodes not listed in the `input_order`, we
can set the `mismatch_last` parameter (default is `T`) to put the
mismatched children nodes to the top or bottom.

``` r
data(test_df)
test_node <- data.tree::as.Node(test_df)
sorted_node <- children_sort(
  input_node = test_node, 
  input_order = c("groupB", "groupA"),
  mismatch_last = T)
print(sorted_node)
#>         levelName
#> 1  tree1         
#> 2   ¦--groupB    
#> 3   ¦   ¦--Male  
#> 4   ¦   °--Female
#> 5   ¦--groupA    
#> 6   ¦   ¦--Male  
#> 7   ¦   °--Female
#> 8   °--groupC    
#> 9       ¦--Male  
#> 10      °--Female
```

## Cumulative Sum Across a Level

`cumsum_across_level()` gets the cumulative value across a level, the
cumulative value will be added to the `cumsum_number` field.

In this example, it calculates the cumulative `exercise_time` field
across level 3.

``` r
data(exercise_df)
exercise_node <- as.Node(exercise_df)
test <- forestry::cumsum_across_level(input_node = exercise_node, 
                              attri_name = "exercise_time", 
                              level_num = 3)
print(test, "cumsum_number", "exercise_time", "level")
#>      levelName cumsum_number exercise_time level
#> 1  Year                   NA            NA     1
#> 2   ¦--Q1                 NA            NA     2
#> 3   ¦   ¦--Jan          0.83          0.83     3
#> 4   ¦   ¦--Feb          1.14          0.31     3
#> 5   ¦   °--Mar          1.98          0.84     3
#> 6   ¦--Q2                 NA            NA     2
#> 7   ¦   ¦--Apr          2.17          0.19     3
#> 8   ¦   ¦--May          2.18          0.01     3
#> 9   ¦   °--Jun          2.45          0.27     3
#> 10  ¦--Q3                 NA            NA     2
#> 11  ¦   ¦--Jul          2.56          0.11     3
#> 12  ¦   ¦--Aug          3.54          0.98     3
#> 13  ¦   °--Sep          4.30          0.76     3
#> 14  °--Q4                 NA            NA     2
#> 15      ¦--Oct          4.49          0.19     3
#> 16      ¦--Nov          5.25          0.76     3
#> 17      °--Dec          5.54          0.29     3
```

In addition, `level_num = "All"` will get the cumulative value across
all levels. Please note that there should be no missing values in the
appropriate level when we apply `cumsum_across_level()`.

``` r
data(exercise_df)
exercise_node <- as.Node(exercise_df)
exercise_node$Do(function(node) node$exercise_time <- Aggregate(node, 
                                                   attribute = "exercise_time", 
                                                   aggFun = sum), 
             traversal = "post-order")
print(exercise_node,  "exercise_time")
#>      levelName exercise_time
#> 1  Year                 5.54
#> 2   ¦--Q1               1.98
#> 3   ¦   ¦--Jan          0.83
#> 4   ¦   ¦--Feb          0.31
#> 5   ¦   °--Mar          0.84
#> 6   ¦--Q2               0.47
#> 7   ¦   ¦--Apr          0.19
#> 8   ¦   ¦--May          0.01
#> 9   ¦   °--Jun          0.27
#> 10  ¦--Q3               1.85
#> 11  ¦   ¦--Jul          0.11
#> 12  ¦   ¦--Aug          0.98
#> 13  ¦   °--Sep          0.76
#> 14  °--Q4               1.24
#> 15      ¦--Oct          0.19
#> 16      ¦--Nov          0.76
#> 17      °--Dec          0.29

exercise_node_test <- cumsum_across_level(input_node = exercise_node, 
                              attri_name = "exercise_time", 
                              level_num = "All")
print(exercise_node_test,"exercise_time", "cumsum_number", "level")
#>      levelName exercise_time cumsum_number level
#> 1  Year                 5.54            NA     1
#> 2   ¦--Q1               1.98          1.98     2
#> 3   ¦   ¦--Jan          0.83          0.83     3
#> 4   ¦   ¦--Feb          0.31          1.14     3
#> 5   ¦   °--Mar          0.84          1.98     3
#> 6   ¦--Q2               0.47          2.45     2
#> 7   ¦   ¦--Apr          0.19          2.17     3
#> 8   ¦   ¦--May          0.01          2.18     3
#> 9   ¦   °--Jun          0.27          2.45     3
#> 10  ¦--Q3               1.85          4.30     2
#> 11  ¦   ¦--Jul          0.11          2.56     3
#> 12  ¦   ¦--Aug          0.98          3.54     3
#> 13  ¦   °--Sep          0.76          4.30     3
#> 14  °--Q4               1.24          5.54     2
#> 15      ¦--Oct          0.19          4.49     3
#> 16      ¦--Nov          0.76          5.25     3
#> 17      °--Dec          0.29          5.54     3
```

## Prepare for JSON array

The `pre_get_array()` function changes the numeric item name in a list
into a format that is compatible with the JSON array standard. As
mentioned earlier, when converting a tree to JSON, we need to save the
tree as a list using `as.list()` then use `htmlwidgets:::toJSON()` to
convert the list to JSON data.

For example, `new_node` is a tree with numeric children nodes.

``` r
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         class = c("A", "B", "C"))
print(as.list(new_node) )
#> $name
#> [1] "tree1"
#> 
#> $`1`
#> $`1`$class
#> [1] "A"
#> 
#> 
#> $`2`
#> $`2`$class
#> [1] "B"
#> 
#> 
#> $`3`
#> $`3`$class
#> [1] "C"
```

We can see the numeric children node names are listed. If we apply
`pre_get_array()` to this list, we can change all numeric names so the
nodes can be saved as a JSON array instead of JSON objects after we use
`htmlwidgets:::toJSON()`.

``` r
new_node <- create_nodes(tree_name = "tree1", 
                         add_children_count = 3, 
                         class = c("A", "B", "C"))
print(pre_get_array(as.list(new_node) ) )
#> [[1]]
#> [1] "tree1"
#> 
#> [[2]]
#> [[2]]$class
#> [1] "A"
#> 
#> 
#> [[3]]
#> [[3]]$class
#> [1] "B"
#> 
#> 
#> [[4]]
#> [[4]]$class
#> [1] "C"
```
