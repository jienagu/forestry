
#' create a tree with assigned name, children and fields
#'
#' @param tree_name assign name of tree
#' @param add_children_count assign number of chidren to this tree
#' @param ... parameters that will be passed as fields of this tree
#'
#' @return a tree with assigned name, children and fields
#' @examples create_nodes(tree_name = "tree1", add_children_count = 3, class = c("A", "B", "C"))
#' @export

create_nodes <- function(tree_name, add_children_count, ...) {
  cell_node <- data.tree::Node$new(tree_name)
  eval(lapply(1:add_children_count, cell_node$AddChild))
  arg_list <- list(...)
  if(length(arg_list) != 0){
    for (i in 1:length(arg_list)) {
      if(length(arg_list[[i]]) != add_children_count)stop(
        "Please note that every field (attribute) length should be the same as children count!"
      )
      for (j in 1:add_children_count) {
        cell_node$children[[j]][[names(arg_list[i])]] <- arg_list[[i]][[j]]
      }
    }
  }
  return(cell_node)
}


#' Add children node
#'
#' @param main_tree the parent tree to be appended with children node
#' @param x xth child
#' @param assign_node appended node as child
#'
#' @return reshaped tree with children assigned
#' @examples
#' data("test_df")
#' data("exercise_df")
#' test_node <- data.tree::as.Node(test_df)
#' test_exercise <- data.tree::as.Node(exercise_df)
#' add_child(main_tree = test_node, x = 4, assign_node = test_exercise )
#' print(test_node)
#' @export

add_child <- function(main_tree, x, assign_node) {
  main_tree$AddChild(x)
  main_tree[[as.character(x)]]$AddChildNode(assign_node)
}

#' create tree appended with each element of input list as a child
#'
#' @param input_list input list to be made for a tree
#' @param node_name name of the tree
#'
#' @return a tree with each item of the list as each child
#'
#' @examples
#' data("test_df")
#' test_node <- data.tree::as.Node(test_df)
#' new_shape <- create_tree(test_node$children,"new_tree")
#' print(new_shape, "hc")
#'
#' @export


create_tree <- function(input_list, node_name){
  if(!is.list(input_list) )stop("Hmm... It seems like input_list is not a list!")
  parent_tree = data.tree::Node$new(node_name)
  for (i in 1:length(input_list)){
    add_child(main_tree = parent_tree,
              x = i,
              assign_node = input_list[[i]])
  }
  # return(parent_tree)
  return(unlist(parent_tree) )
}

#' numericalize children numeric name to convert JSON object to JSON array
#'
#' @param x input
#'
#' @return unname numeric names list
#' @examples fixnames(list("1" = 1, "2" = 2))
#'
#' @export

fixnames <- function(x) {
  if (1 %in% names(x)) {
    x <- unname(x)
  }
  x
}

#' numericalize children numeric name to convert JSON object to JSON array
#'
#' @param x input list
#'
#' @return unname numeric names list which is prepared to convert to JSON array
#' @examples
#' demo_list <- list("1" = 1, "2" = 2, list("1" = 1, "2" = 2))
#' pre_get_array(demo_list)
#'
#' @export

pre_get_array <- function(x) {
  if (is.list(x)) lapply(fixnames(x), pre_get_array) else x
}

#' assign certain children nodes and fill NA for empty fields
#'
#' @param fix_vector children node names to be assigned
#' @param input_node the node to be exapnded with children's names
#'
#' @return a node expanded with certain children nodes
#' @examples
#' cell_node2 <- data.tree::Node$new("cell2")
#' cell_node2$AddChild("B")
#' cell_node2$AddChild("C")
#' cell_node2$Set(class = c(NA, "B1", "C1"))
#' print(cell_node2, "class")
#' cell_fixed_items <- fix_items(fix_vector = c("A", "B", "C", "D"), input_node = cell_node2)
#' print(cell_fixed_items, "class")
#' @export

fix_items <- function(fix_vector, input_node){
  if(!all(names(input_node$children) %in% fix_vector))stop(
    "Hmm... It looks like some children do not exist in your fix_vector!"
    )
  cell_node <- data.tree::Node$new(paste(input_node$name))
  eval(lapply(fix_vector, cell_node$AddChild))
  for (i in 1:cell_node$count){
    child_name <- cell_node$children[[i]]$name
    if (child_name %in% names(input_node$children)){
      cell_node$children[[i]] <- assign_attr(cell_node$children[[i]],
                                             input_node$children[[as.character(child_name)]] )
    }
  }
  return(cell_node)
}



#' assign attributes to node; work with fix_items function
#'
#' @param node_from assigned attributes from
#' @param node_to assigned attributes to
#'
#' @return a node assigned attributes
#' @examples
#' cell_node1 <- data.tree::Node$new("cell1")
#' cell_node1$AddChild("A")
#' cell_node2 <- data.tree::Node$new("cell2")
#' cell_node2$AddChild("A")
#' cell_node2$Set(group = c(NA, "A1"))
#' print(assign_attr(node_from = cell_node1$A, node_to = cell_node2$A), "group")
#'
#' @export

assign_attr <- function(node_from, node_to){
  field_all <- node_to$fieldsAll
  for (i in 1:length(field_all)){
    node_from[[ as.character(field_all[i]) ]] <- node_to[[ as.character(field_all[i]) ]]
  }
  return(node_from)
}

#' Sort chidren nodes with certain order
#'
#' @param input_node input node
#' @param input_order children node order
#' @param mismatch_last TRUE: mismatched children nodes are at the bottom; FALSE: mismatched nodes are at the top
#'
#' @return tree with children nodes sorted with certian order
#' @examples
#' data(test_df)
#' test_node <- data.tree::as.Node(test_df)
#' sorted_node <- children_sort(
#'   input_node = test_node,
#'   input_order = c("groupB", "groupA"),
#'   mismatch_last = TRUE)
#' print(sorted_node)
#' @export

children_sort <- function(input_node, input_order, mismatch_last = T){
  if(!all(input_order %in% names(input_node$children)))stop(
    "Hmm... It looks like some of assigned children node order (input_order) do not exist in the node!"
  )
  string_order <- match(names(input_node$children), input_order)

  if(mismatch_last){
    string_order[is.na(string_order)] <- (max(string_order, na.rm = T)+1)
  }else{
    string_order[is.na(string_order)] <- 0
  }

  input_node$Set( node_children_order = string_order,
                  filterFun = function(x) x$level == 2 )

  input_node_arrange <- data.tree::Sort(input_node,
                             "node_children_order",
                             decreasing = F,
                             recursive = T)
  return(input_node_arrange)
}


#' cumulative calculation
#'
#' @param input_node tree
#' @param attri_name name of this cummulative count field
#' @param level_num calculate cummulative value cross the level
#'
#' @return tree with cummulative count
#' @examples
#' data(exercise_df)
#' exercise_node <- data.tree::as.Node(exercise_df)
#' test <- cumsum_across_level(input_node = exercise_node,
#'                             attri_name = "exercise_time",
#'                             level_num = 3)
#' print(test, "cumsum_number", "exercise_time", "level")
#' @export

cumsum_across_level <- function(input_node, attri_name, level_num){
  if(level_num == "All"){
    if(anyNA(input_node$Get(as.character(attri_name))[-1] )) message(
      "A friendly reminder that your field has missing value(s), this might return NA!"
      )
    for(i in 1:input_node$height){
      if(i>1){
        input_node$Set(
          cumsum_number = cumsum_by_level(input_node, i, attri_name),
          filterFun = function(x) x$level == i
        )
      }
    }
  }else{
    input_node$Set(
      cumsum_number = cumsum_by_level(input_node, level_num, attri_name),
      filterFun = function(x) x$level == level_num
    )
  }
  return(input_node)
}

#' calculate cumsum for input level
#'
#' @param input_tree input tree
#' @param level_num level of tree for cumsum
#' @param attri_name name of this cummulative count field
#'
#' @return tree with calculated cumsum for input level
#' @examples
#' data(exercise_df)
#' exercise_node <- data.tree::as.Node(exercise_df)
#' cumsum_by_level(exercise_node, 3, "exercise_time")
#'
#' @export

cumsum_by_level <- function(input_tree, level_num, attri_name){
  cumsum(
    input_tree$Get(
      attri_name,
      filterFun = function(x) x$level == level_num
    )
  )
}

#' fill missing value of a field across a level with 0
#'
#' @param input_node input node
#' @param field_name field for this operation
#' @param by_level across this level
#' @param fill_with fill missing value with this value
#'
#' @return node with NA filled for the input field at input level
#' @examples
#' data(exercise_df)
#' exercise_node <- data.tree::as.Node(exercise_df)
#' result <- fill_NA_level(input_node = exercise_node,
#'                         field_name = "exercise_time",
#'                         by_level = 2,
#'                         fill_with = "quarterly")
#' print(result, "exercise_time")
#'
#' @export

fill_NA_level <- function(input_node, field_name, by_level, fill_with = 0){

  level_field_value <- input_node$Get(as.character(field_name),
                                      filterFun = function(x) x$level == by_level)
  if(all(is.na(level_field_value))){
    input_node$Do(
      function(node) {
      if(node$level== by_level){
        node[[as.character(field_name)]] <- fill_with
        }
      }
    )
  }else{
   input_node$Do(
     function(node){
      if(is.na(node[[as.character(field_name)]])|is.null(node[[as.character(field_name)]])){
         node[[as.character(field_name)]] <- fill_with
         }
        },
        filterFun = function(x) x$level == by_level
     )
  }
  return(input_node)
}
