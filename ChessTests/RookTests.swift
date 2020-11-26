//
//  RookTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class RookTests: XCTestCase {
    func testRookMoveRank() throws {
        let board = [
            Piece(kind: .rook, color: .white, location: .a1),
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .black, location: .e5), destination: .d4)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testRookMoveFile() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRookCaptureRank() throws {
        
    }
    
    func testRookCaptureFile() throws {
        
    }
}
