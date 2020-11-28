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
        XCTAssertThrowsError(try Chess.isValidMove(
            board: board,
            move: Move(
                piece: Piece(kind: .pawn, color: .white, location: .d4),
                destination: .d6
            ),
            turn: .white,
            history: []
        ))
    }
    
    func testPawnRegularMove() throws {
        let pawn1 = Piece(kind: .pawn, color: .white, location: .e2)
        let pawn2 = Piece(kind: .pawn, color: .black, location: .e7)
        let board = [pawn1, pawn2]
        try [
            Move(piece: pawn1, destination: .e3),
            Move(piece: pawn2, destination: .e6),
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
        }
    }
    
    func testPawnOpeningMove() throws {
        let pawn1 = Piece(kind: .pawn, color: .white, location: .e2)
        let pawn2 = Piece(kind: .pawn, color: .black, location: .e7)
        let board = [pawn1, pawn2]
        try [
            Move(piece: pawn1, destination: .e4),
            Move(piece: pawn2, destination: .e5),
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
        }
    }
    
    func testWhitePawnCapture() throws {
        let pawn = Piece(kind: .pawn, color: .white, location: .d4)
        let board = [
            pawn,
            Piece(kind: .pawn, color: .black, location: .e5)
        ]
        try [
            Move(piece: pawn, destination: .e5)
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
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
            XCTAssertThrowsError(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
        }
    }
    
    func testBlackPawnCapture() throws {
        let pawn = Piece(kind: .pawn, color: .black, location: .e5)
        let board = [
            Piece(kind: .pawn, color: .white, location: .d4),
            pawn
        ]
        try [
            Move(piece: pawn, destination: .d4)
        ].forEach {
            XCTAssertNoThrow(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
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
            XCTAssertThrowsError(try Chess.isValidMove(board: board, move: $0, turn: $0.piece.color, history: []))
        }
    }
}
