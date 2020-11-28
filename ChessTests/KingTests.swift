//
//  KingTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/27/20.
//

import XCTest
@testable import Chess

class KingTests: XCTestCase {
    func testNormalMove() throws {
        let king = Piece(kind: .king, color: .white, location: .c4)
        let board = [
            king
        ]
        let destinations: [BoardLocation] = [
            .b3, .b4, .b5,
            .c3,      .c5,
            .d3, .d4, .d5,
        ]
        
        try destinations.map {
            Move(piece: king, destination: $0)
        }.forEach {
            XCTAssertNoThrow(try Chess.isValidMove(
                board: board,
                move: $0,
                turn: .white,
                history: [])
            )
        }
    }
    
    func testEscapingCheck() throws {
        let king = Piece(kind: .king, color: .white, location: .c4)
        let rook = Piece(kind: .rook, color: .black, location: .c8)
        let board = [
            king,
            rook
        ]
        let destinations: [BoardLocation] = [
            .b3, .b4, .b5,
            
            .d3, .d4, .d5,
        ]
        
        try destinations.map {
            Move(piece: king, destination: $0)
        }.forEach {
            XCTAssertNoThrow(try Chess.isValidMove(
                board: board,
                move: $0,
                turn: .white,
                history: [])
            )
        }
    }
    
    func testCastlingWhite() throws {
        let king = Piece(kind: .king, color: .white, location: .e1)
        let rook1 = Piece(kind: .rook, color: .white, location: .h1)
        let rook2 = Piece(kind: .rook, color: .white, location: .a1)
        let board = [
            king,
            rook1,
            rook2,
        ]
        let destinations: [BoardLocation] = [.g1, .c1]
        try destinations.map {
            Move(piece: king, destination: $0)
        }.forEach {
            XCTAssertNoThrow(try Chess.isValidMove(
                board: board,
                move: $0,
                turn: .white,
                history: [])
            )
        }
    }
    
    func testCastlingBlack() throws {
        let king = Piece(kind: .king, color: .black, location: .e8)
        let rook1 = Piece(kind: .rook, color: .black, location: .h8)
        let rook2 = Piece(kind: .rook, color: .black, location: .a8)
        let board = [
            king,
            rook1,
            rook2,
        ]
        let destinations: [BoardLocation] = [.g8, .c8]
        try destinations.map {
            Move(piece: king, destination: $0)
        }.forEach {
            XCTAssertNoThrow(try Chess.isValidMove(
                board: board,
                move: $0,
                turn: .black,
                history: [])
            )
        }
    }
    
    func testCastlingKingMovedPreviously() throws {
        let king = Piece(kind: .king, color: .white, location: .e1)
        let rook1 = Piece(kind: .rook, color: .white, location: .h1)
        let rook2 = Piece(kind: .rook, color: .white, location: .a1)
        let board = [
            king,
            rook1,
            rook2,
        ]
        let destinations: [BoardLocation] = [.g1, .c1]
        let history = [
            Move(piece: Piece(kind: .king, color: .white, location: .e1), destination: .f2),
            Move(piece: Piece(kind: .king, color: .white, location: .f2), destination: .e1)
        ]
        try destinations.map {
            Move(piece: king, destination: $0)
        }.forEach {
            XCTAssertThrowsError(try Chess.isValidMove(
                board: board,
                move: $0,
                turn: .white,
                history: history)
            )
        }
    }
    
    func testCastlingRookMovedPreviously() throws {
        let king = Piece(kind: .king, color: .white, location: .e1)
        let rook1 = Piece(kind: .rook, color: .white, location: .h1)
        let rook2 = Piece(kind: .rook, color: .white, location: .a1)
        let board = [
            king,
            rook1,
            rook2,
        ]
        let destinations: [BoardLocation] = [.g1, .c1]
        let history = [
            Move(piece: rook1, destination: .h5),
            Move(piece: Piece(kind: .rook, color: .white, location: .h5), destination: .h1),
            Move(piece: rook2, destination: .a5),
            Move(piece: Piece(kind: .rook, color: .white, location: .a5), destination: .a1)
        ]
        try destinations.map {
            Move(piece: king, destination: $0)
        }.forEach {
            XCTAssertThrowsError(try Chess.isValidMove(
                board: board,
                move: $0,
                turn: .white,
                history: history)
            )
        }
    }
}
