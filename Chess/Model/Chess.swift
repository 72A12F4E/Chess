//
//  Chess.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation
import SwiftUI
import Combine

class Chess: ObservableObject {
    @Published var turn: Color
    @Published var board: [Piece]
    @Published var history: [Move]
    @Published var inCheck: Color?
    
    init(
        turn: Color = .white,
        board: [Piece] = initialBoardState,
        history: [Move] = []
    ) {
        self.turn = turn
        self.board = board
        self.history = history
    }
    
    func apply(_ move: Move) throws {
        try Self.isValidMove(board: board, move: move, turn: turn, history: history)
        
        history.append(move)
        // If move is a capture, remove old piece
        if let capturedIndex = board.firstIndex(where: { $0.location == move.destination }) {
            board.remove(at: capturedIndex)
        }
        // Replace existing piece with the one that just moved
        if let index = board.firstIndex(of: move.piece) {
            board[index] = Piece(
                kind: move.piece.kind,
                color: move.piece.color,
                location: move.destination
            )
        } else {
            panic([
                "message": "attempted to replace moved piece and failed",
                "board": boardView,
                "move": move.description
            ])
        }
        self.inCheck = board.first(where: {
            $0.kind == .king && Self.isThreatened(piece: $0, board: board)}
        )?.color
        turn = turn == .white ? .black : .white
    }
    
    private func panic(_ dictionary: [String: String]) -> Never {
        fatalError(dictionary.description)
    }
}

// MARK: Piece Querys

extension Chess {
    func piece(for boardLocation: BoardLocation) -> Piece? {
        return board.first(where: { $0.location == boardLocation })
    }
}

// MARK: Debug Output

extension Chess: CustomDebugStringConvertible {
    var boardView: String {
        var string = ""
        for rank: Int in 1...8  {
            for file: Int in 1...8 {
                let piece = board.first { (piece) -> Bool in
                    piece.location == BoardLocation(file: file, rank: rank)
                }
                if let piece = piece {
                    string.append(piece.description)
                } else {
                    string.append(" ")
                }
            }
            string.append("\n")
        }
        return string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var debugDescription: String {
        boardView
    }
}

let initialBoardState: [Piece] = [
    Piece(kind: .rook, color: .white, location: .init(file: 1, rank: 1)),
    Piece(kind: .knight, color: .white, location: .init(file: 2, rank: 1)),
    Piece(kind: .bishop, color: .white, location: .init(file: 3, rank: 1)),
    Piece(kind: .queen, color: .white, location: .init(file: 4, rank: 1)),
    Piece(kind: .king, color: .white, location: .init(file: 5, rank: 1)),
    Piece(kind: .bishop, color: .white, location: .init(file: 6, rank: 1)),
    Piece(kind: .knight, color: .white, location: .init(file: 7, rank: 1)),
    Piece(kind: .rook, color: .white, location: .init(file: 8, rank: 1)),
    Piece(kind: .pawn, color: .white, location: .init(file: 1, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 2, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 3, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 4, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 5, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 6, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 7, rank: 2)),
    Piece(kind: .pawn, color: .white, location: .init(file: 8, rank: 2)),
    Piece(kind: .pawn, color: .black, location: .init(file: 1, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 2, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 3, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 4, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 5, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 6, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 7, rank: 7)),
    Piece(kind: .pawn, color: .black, location: .init(file: 8, rank: 7)),
    Piece(kind: .rook, color: .black, location: .init(file: 1, rank: 8)),
    Piece(kind: .knight, color: .black, location: .init(file: 2, rank: 8)),
    Piece(kind: .bishop, color: .black, location: .init(file: 3, rank: 8)),
    Piece(kind: .queen, color: .black, location: .init(file: 4, rank: 8)),
    Piece(kind: .king, color: .black, location: .init(file: 5, rank: 8)),
    Piece(kind: .bishop, color: .black, location: .init(file: 6, rank: 8)),
    Piece(kind: .knight, color: .black, location: .init(file: 7, rank: 8)),
    Piece(kind: .rook, color: .black, location: .init(file: 8, rank: 8)),
]
