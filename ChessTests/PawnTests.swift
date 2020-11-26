//
//  PawnTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class PawnTests: XCTestCase {

    func testPawnInvalidMove() throws {
        let whitePawn = Piece(kind: .pawn, color: .white, location: .d4)
        let blackPawn = Piece(kind: .pawn, color: .black, location: .e5)
        let board = [
            whitePawn,
            blackPawn,
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .white, location: .d4), destination: .d6)
        )
        
        XCTAssertThrowsError(try move.get())
    }
    
    func testPawnRegularMove() throws {
        let chess = Chess()
        let move1 = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .white, location: .e2), destination: .e3)
        )
        let move2 = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .black, location: .e7), destination: .e6)
        )
        
        XCTAssertNoThrow(try move1.get())
        XCTAssertNoThrow(try move2.get())
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
    
    func testWhitePawnCapture() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d4),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .white, location: .d4), destination: .e5)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testWhitePawnCaptureThrows() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d5),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .white, location: .d4), destination: .e5)
        )
        
        XCTAssertThrowsError(try move.get())
    }
    
    func testBlackPawnCapture() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d4),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        let chess = Chess(turn: .black, board: board)
        let move = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .black, location: .e5), destination: .d4)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testBlackPawnCaptureThrows() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d5),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        let chess = Chess(turn: .black, board: board)
        let move = chess.apply(
            Move(piece: Piece(kind: .pawn, color: .black, location: .e5), destination: .d5)
        )
        
        XCTAssertThrowsError(try move.get())
    }
}
