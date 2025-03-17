import gleam/list
import gleam/string
import gleam/option.{type Option, None, Some}
import iv.{type Array}

pub type Board {
  Board(Array(Array(Space)))
}

pub type Space {
  Space(Option(Piece))
}

pub type Piece {
  Pawn(Color)
  Knight(Color)
  Bishop(Color)
  Rook(Color)
  Queen(Color)
  King(Color)
}

pub type Color {
  White
  Black
}

pub fn new_board() -> Board {
  let rows = list.range(0, 8)
  |> list.map(fn (_row) {
    let cols = list.range(0, 8)
    |> list.map(fn (_col) {
      Space(None)
    })
    iv.from_list(cols)
  })
  Board(iv.from_list(rows))
}

fn process_fen_char(char: String, row: Array(Space), col_idx: Int) -> #(Array(Space), Int) {
  case char {
    "1" -> #(row, col_idx + 1)
    "2" -> #(row, col_idx + 2)
    "3" -> #(row, col_idx + 3)
    "4" -> #(row, col_idx + 4)
    "5" -> #(row, col_idx + 5)
    "6" -> #(row, col_idx + 6)
    "7" -> #(row, col_idx + 7)
    "8" -> #(row, col_idx + 8)
    piece -> {
      let piece = case piece {
        "P" -> Some(Pawn(White))
        "p" -> Some(Pawn(Black))
        "N" -> Some(Knight(White))
        "n" -> Some(Knight(Black))
        "B" -> Some(Bishop(White))
        "b" -> Some(Bishop(Black))
        "R" -> Some(Rook(White))
        "r" -> Some(Rook(Black))
        "Q" -> Some(Queen(White))
        "q" -> Some(Queen(Black))
        "K" -> Some(King(White))
        "k" -> Some(King(Black))
        _ -> None
      }
      case iv.set(row, col_idx, Space(piece)) {
        Ok(updated_row) -> #(updated_row, col_idx + 1)
        Error(_) -> #(row, col_idx + 1)
      }
    }
  }
}

/// Fill the board from a FEN string, which may look like
/// "1k1r4/pp1b1R2/3q2pp/4p3/2B5/4Q3/PPP2B2/2K5 b - -"
pub fn fill_board_from_fen(board: Board, fen: String) -> Board {
  let Board(rows) = board
  let fen_parts = string.split(fen, " ")
  let board_fen = case list.first(fen_parts) {
    Ok(res) -> res
    _ -> ""
  }
  
  let board_rows = string.split(board_fen, "/")
  let updated_rows = list.index_map(board_rows, fn(row_str, row_idx) {
    let row = case iv.get(rows, row_idx) {
      Ok(row) -> row
      Error(_) -> iv.from_list([])
    }
    
    let #(updated_row, _) = list.fold(
      string.to_graphemes(row_str),
      #(row, 0),
      fn(acc, char) {
        let #(current_row, current_idx) = acc
        process_fen_char(char, current_row, current_idx)
      },
    )
    updated_row
  })
  
  Board(iv.from_list(updated_rows))
}

pub fn print_board(board: Board) -> String {
  let Board(rows) = board
  let board_rows = iv.to_list(rows)
    |> list.map(fn(row) {
      let spaces = iv.to_list(row)
        |> list.map(fn(space) {
          case space {
            Space(None) -> "."
            Space(Some(piece)) -> {
              case piece {
                Pawn(White) -> "P"
                Pawn(Black) -> "p"
                Knight(White) -> "N" 
                Knight(Black) -> "n"
                Bishop(White) -> "B"
                Bishop(Black) -> "b"
                Rook(White) -> "R"
                Rook(Black) -> "r"
                Queen(White) -> "Q"
                Queen(Black) -> "q"
                King(White) -> "K"
                King(Black) -> "k"
              }
            }
          }
        })
      string.join(spaces, " ")
    })
  
  string.join(board_rows, "\n")
}

