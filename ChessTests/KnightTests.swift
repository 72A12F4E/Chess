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
    
    func testKnightInvalidMove() throws {
        let knight = Piece(kind: .knight, color: .white, location: .b1)
        let chess = Chess(turn: .white, board: [
            knight,
        ])
        let move = chess.apply(
            Move(piece: knight, destination: .b2)
        )
        XCTAssertThrowsError(try move.get())
    }
}
