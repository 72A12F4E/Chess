//
//  ChessTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class ChessTests: XCTestCase {
    
    func testInitialBoardView() throws {
        let chess = Chess()
        var boardView = "" // Xcode formatting breaks multiline strings :-(
        boardView += "♖♘♗♕♔♗♘♖" + "\n"
        boardView += "♙♙♙♙♙♙♙♙" + "\n"
        boardView += "        " + "\n"
        boardView += "        " + "\n"
        boardView += "        " + "\n"
        boardView += "        " + "\n"
        boardView += "♟♟♟♟♟♟♟♟" + "\n"
        boardView += "♜♞♝♛♚♝♞♜"
        XCTAssertEqual(chess.boardView, boardView)
    }
}
