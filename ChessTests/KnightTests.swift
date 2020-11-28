//
//  KnightTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class KnightTests: XCTestCase {
    func testKnightsOpeningMove() throws {
        try [
            Move(piece: Piece(kind: .knight, color: .white, location: .b1), destination: .c3),
            Move(piece: Piece(kind: .knight, color: .black, location: .g8), destination: .f6)
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: initialBoardState, move: $0, turn: $0.piece.color))
        }
    }
    
    func testKnightInvalidMove() throws {
        let knight = Piece(kind: .knight, color: .white, location: .b1)
        let board = [knight]
        XCTAssertThrowsError(
            try Chess.isValidMove(
                board: board,
                move: Move(piece: knight, destination: .b2),
                turn: .white
            )
        )
    }
}
