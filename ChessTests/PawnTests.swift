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
        let result = Chess.isValidMove(
            board: board,
            move: Move(
                piece: Piece(kind: .pawn, color: .white, location: .d4),
                destination: .d6
            ),
            turn: .white
        )
        
        XCTAssertThrowsError(try result.get())
    }
    
    func testPawnRegularMove() throws {
        try [
            Move(piece: Piece(kind: .pawn, color: .white, location: .e2), destination: .e3),
            Move(piece: Piece(kind: .pawn, color: .black, location: .e7), destination: .e6),
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: initialBoardState, move: $0, turn: $0.piece.color).get())
        }
    }
    
    func testPawnOpeningMove() throws {
        try [
            Move(piece: Piece(kind: .pawn, color: .white, location: .e2), destination: .e4),
            Move(piece: Piece(kind: .pawn, color: .black, location: .e7), destination: .e5),
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: initialBoardState, move: $0, turn: $0.piece.color).get())
        }
    }
    
    func testWhitePawnCapture() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d4),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        try [
            Move(piece: Piece(kind: .pawn, color: .white, location: .d4), destination: .e5)
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color).get())
        }
    }
    
    func testWhitePawnCaptureThrows() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d5),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        try [
            Move(piece: Piece(kind: .pawn, color: .white, location: .d4), destination: .e5)
        ].forEach {
            XCTAssertThrowsError(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color).get())
        }
    }
    
    func testBlackPawnCapture() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d4),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        try [
            Move(piece: Piece(kind: .pawn, color: .black, location: .e5), destination: .d4)
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color).get())
        }
    }
    
    func testBlackPawnCaptureThrows() throws {
        let board = [
            Piece(kind: .pawn, color: .white, location: .d5),
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        try [
            Move(piece: Piece(kind: .pawn, color: .black, location: .e5), destination: .d5)
        ].forEach {
            XCTAssertThrowsError(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color).get())
        }
    }
}
