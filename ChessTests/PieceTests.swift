//
//  PieceTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class PieceTests: XCTestCase {
    func testPieceDescription() throws {
        [
            (Piece(kind: .king, color: .white, location: .a1), "♔"),
            (Piece(kind: .queen, color: .white, location: .a1), "♕"),
            (Piece(kind: .bishop, color: .white, location: .a1), "♗"),
            (Piece(kind: .knight, color: .white, location: .a1), "♘"),
            (Piece(kind: .rook, color: .white, location: .a1), "♖"),
            (Piece(kind: .pawn, color: .white, location: .a1), "♙"),
            (Piece(kind: .king, color: .black, location: .a1), "♚"),
            (Piece(kind: .queen, color: .black, location: .a1), "♛"),
            (Piece(kind: .bishop, color: .black, location: .a1), "♝"),
            (Piece(kind: .knight, color: .black, location: .a1), "♞"),
            (Piece(kind: .rook, color: .black, location: .a1), "♜"),
            (Piece(kind: .pawn, color: .black, location: .a1), "♟"),
        ].forEach {
            XCTAssertEqual($0.0.description, $0.1)
        }
    }
}
