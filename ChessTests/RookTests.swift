//
//  RookTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class RookTests: XCTestCase {
    
    func testRookInvalidMove() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let board = [
            rook,
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .g3)
        )
        
        XCTAssertThrowsError(try move.get())
    }
    
    func testRookMoveRank() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let board = [
            rook,
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .h1)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testRookMoveFile() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let board = [
            rook,
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .a8)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testRookCaptureRank() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let knight = Piece(kind: .knight, color: .black, location: .h1)
        let board = [
            rook,
            knight,
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .h1)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testRookCaptureFile() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let knight = Piece(kind: .knight, color: .black, location: .a8)
        let board = [
            rook,
            knight,
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .a8)
        )
        
        XCTAssertNoThrow(try move.get())
    }
    
    func testRookMoveRankBlocked() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let queen = Piece(kind: .queen, color: .black, location: .g1)
        let board = [
            rook,
            queen
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .h1)
        )
        
        XCTAssertThrowsError(try move.get())
    }
    
    func testRookMoveFileBlocked() throws {
        let rook = Piece(kind: .rook, color: .white, location: .a1)
        let queen = Piece(kind: .queen, color: .black, location: .a5)
        let board = [
            rook,
            queen
        ]
        let chess = Chess(turn: .white, board: board)
        let move = chess.apply(
            Move(piece: rook, destination: .a8)
        )
        
        XCTAssertThrowsError(try move.get())
    }
}
