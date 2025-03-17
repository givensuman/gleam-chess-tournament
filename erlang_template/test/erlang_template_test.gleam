// import gleeunit
// import gleeunit/should

import erlang_template/board.{new_board, print_board}

pub fn main() {
  // gleeunit.main()
  let board = new_board()
  print_board(board)
}

// // gleeunit test functions end in `_test`
// pub fn hello_world_test() {
//   1
//   |> should.equal(1)
// }
