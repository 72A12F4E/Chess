//
//  ChessTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class ChessTests: XCTestCase {

    func testPawnRegularMove() throws {
        let chess = Chess()
        let move1 = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .white, location: .e2), destination: .e3)
        )
        let move2 = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .black, location: .e7), destination: .e6)
        )
        let boardState =
        """
        ♖♘♗♕♔♗♘♖
        ♙♙♙♙ ♙♙♙
            ♙
                
                
            ♟
        ♟♟♟♟ ♟♟♟
        ♜♞♝♛♚♝♞♜

        """
        XCTAssertNoThrow(try move1.get())
        XCTAssertNoThrow(try move2.get())
        XCTAssertEqual(boardState, chess.boardView)
    }
    
    func testPawnOpeningMove() throws {
        let chess = Chess()
        let move1 = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .white, location: .e2), destination: .e4)
        )
        let move2 = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .black, location: .e7), destination: .e5)
        )
        XCTAssertNoThrow(try move1.get())
        XCTAssertNoThrow(try move2.get())
    }
    
    func testPawnCapture() throws {
        
    }

    func testKnightsOpeningMove() throws {
        let chess = Chess()
        let move1 = chess.apply(
            Move(piece: Piece(kind: .knight, color: .white, location: .b1), destination: .c3)
        )
        let move2 = chess.apply(
            Move(piece: Piece(kind: .knight, color: .black, location: .g8), destination: .f6)
        )
        XCTAssertNoThrow(try move1.get())
        XCTAssertNoThrow(try move2.get())
    }
}
