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
        let knight1 = Piece(kind: .knight, color: .white, location: .b1)
        let knight2 = Piece(kind: .knight, color: .black, location: .g8)
        let board = [knight1, knight2]
        try [
            Move(piece: knight1, destination: .c3),
            Move(piece: knight2, destination: .f6)
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
        }
    }
    
    func testKnightInvalidMove() throws {
        let knight = Piece(kind: .knight, color: .white, location: .b1)
        let board = [knight]
        XCTAssertThrowsError(
            try Chess.isValidMove(
                board: board,
                move: Move(piece: knight, destination: .b2),
                turn: .white,
                history: []
            )
        )
    }
}
