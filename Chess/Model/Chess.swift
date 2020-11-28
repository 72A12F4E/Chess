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
    
    init(
        turn: Color = .white,
        board: [Piece] = initialBoardState,
        history: [Move] = []
    ) {
        self.turn = turn
        self.board = board
        self.history = history
    }
    
    @discardableResult
    func apply(_ move: Move) -> Result<Void, MoveError> {
        let result = Self.isValidMove(board: board, move: move, turn: turn)
        guard case .success = result else {
            return result
        }
        
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
        turn = turn == .white ? .black : .white
        return result
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
    
    func piece(rank: Int, file: Int) -> Piece? {
        return piece(for: BoardLocation(file: file, rank: rank))
    }
}

// MARK: Move Validation

extension Chess {
    static func isValidMove(board: [Piece], move: Move, turn: Color) -> Result<Void, MoveError> {
        // You can't move if its not your turn
        guard turn == move.piece.color else {
            return .failure(.wrongTurn)
        }
        
        // You can't move to the same spot.
        guard move.piece.location != move.destination else {
            return .failure(.moveToSameLocation)
        }
        
        // You can't move a piece that doesn't exist
        guard board.contains(move.piece) else {
            return .failure(.noPieceAtLocation)
        }
        
        // You can't capture your own piece
        guard !Set(board.filter {
                $0.color == move.piece.color
            }.map(\.location))
            .contains(move.destination) else {
            return .failure(.noCaptureOwnPiece)
        }
        
        // If a move would place your own king in check, its not a valid move
        let isOwnKingThreatened = board
            .first(where: { $0.kind == .king && $0.color == turn })
            .flatMap {
                var newBoardState = board
                // If move is a capture, remove old piece
                if let capturedIndex = board.firstIndex(where: { $0.location == move.destination }) {
                    newBoardState.remove(at: capturedIndex)
                }
                // Replace existing piece with the one that just moved
                if let index = newBoardState.firstIndex(of: move.piece) {
                    newBoardState[index] = Piece(
                        kind: move.piece.kind,
                        color: move.piece.color,
                        location: move.destination
                    )
                }
                return isThreatened(piece: $0, board: newBoardState)
            } ?? false
        guard !isOwnKingThreatened else {
            return .failure(.placesKingInCheck)
        }
        
        switch move.piece.kind {
        case .king:
            return Self.isValidMoveKing(board: board, move: move)
        case .queen:
            return Self.isValidMoveQueen(board: board, move: move)
        case .bishop:
            return Self.isValidMoveBishop(board: board, move: move)
        case .knight:
            return Self.isValidMoveKnight(board: board, move: move)
        case .rook:
            return Self.isValidMoveRook(board: board, move: move)
        case .pawn:
            return Self.isValidMovePawn(board: board, move: move)
        }
    }
    
    static func isValidMoveKing(board: [Piece], move: Move) -> Result<Void, MoveError> {
        if abs(move.destination.rank - move.piece.location.rank) <= 1 &&
            abs(move.destination.file - move.piece.location.file) <= 1 {
            return .success(())
        }
        return .failure(.invalidMove)
    }
    
    static func isValidMoveQueen(board: [Piece], move: Move) -> Result<Void, MoveError> {
        // A queen is just a combination of a Rook & Bishop
        // so we can re-use their validation rules :-)
        let result1 = isValidMoveRook(board: board, move: move)
        if case .success = result1 {
            return result1
        }
        let result2 = isValidMoveBishop(board: board, move: move)
        if case .success = result2 {
            return result2
        }
        
        return .failure(.invalidMove)
    }
    
    static func isValidMoveBishop(board: [Piece], move: Move) -> Result<Void, MoveError> {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        
        // Bishops can only move along a diagonal
        guard abs(sourceRank - destRank) == abs(sourceFile - destFile) else {
            return .failure(.invalidMove)
        }
        
        let minFile = min(sourceFile, destFile) + 1 //no freakin idea why a +1 needs to be here...
        let maxFile = max(sourceFile, destFile)
        let fileSpan = sourceFile < destFile ?
            AnyCollection((minFile..<maxFile)) :
            AnyCollection((minFile..<maxFile).reversed())
        
        let minRank = min(sourceRank, destRank) + 1
        let maxRank = max(sourceRank, destRank)
        let rankSpan = sourceRank < destRank ?
            AnyCollection((minRank..<maxRank)) :
            AnyCollection((minRank..<maxRank).reversed())
        
        // Validate that there aren't any pieces blocking the movement.
        // Generate the span betwen the source & destination, then validate
        // no pieces are in between.
        guard Set(zip(fileSpan, rankSpan).map {
            BoardLocation(file: $0, rank: $1)
        }).intersection(board.map(\.location)).isEmpty else {
            return .failure(.invalidMove)
        }
        
        return .success(())
    }
    
    static func isValidMoveKnight(board: [Piece], move: Move) -> Result<Void, MoveError>  {
        let source = move.piece.location
        let isValid = [
            (source.file + 1, source.rank + 2),
            (source.file + 2, source.rank + 1),
            (source.file - 1, source.rank + 2),
            (source.file + 2, source.rank - 1),
            (source.file + 1, source.rank - 2),
            (source.file - 2, source.rank + 1),
            (source.file - 1, source.rank - 2),
            (source.file - 2, source.rank - 1),
        ].filter { (1...8).contains($0.0) && (1...8).contains($0.1) }
        .map {
            BoardLocation(file: $0.0, rank: $0.1)
        }.contains(move.destination)
        
        if isValid {
            return .success(())
        }
        
        return .failure(.invalidMove)
    }
    
    static func isValidMoveRook(board: [Piece], move: Move) -> Result<Void, MoveError> {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        // Rooks can only move along their current rank & file
        guard sourceRank == destRank || sourceFile == destFile else {
            return .failure(.invalidMove)
        }
        
        // Validate that there aren't any pieces blocking the movement.
        // Generate the span betwen the source & destination & validate no pieces are in between.
        // Note the `..<` on the range operator to make sure we don't
        // accidentally check the destination, which might be a capture
        if sourceRank == destRank {
            let minFile = min(sourceFile, destFile)
            let maxFile = max(sourceFile, destFile)
            let span = (minFile..<maxFile).map {
                BoardLocation(file: $0, rank: sourceRank)
            }
            if Set(board.map(\.location)).intersection(span).count == 1 {
                return .success(())
            }
        } else {
            let minRank = min(sourceRank, destRank)
            let maxRank = max(sourceRank, destRank)
            let span = (minRank..<maxRank).map {
                BoardLocation(file: sourceFile, rank: $0)
            }
            if Set(board.map(\.location)).intersection(span).count == 1 {
                return .success(())
            }
        }
        
        return .failure(.invalidMove)
    }
    
    static func isValidMovePawn(board: [Piece], move: Move) -> Result<Void, MoveError> {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        if move.piece.color == .white {
            // Standard pawn move
            if sourceFile == destFile &&
                sourceRank == destRank - 1 &&
                !board.map(\.location).contains(move.destination) {
                return .success(())
            }
            // Pawn opening double move
            else if sourceRank == 2 &&
                sourceFile == destFile &&
                sourceRank == destRank - 2 {
                return .success(())
            }
            // Pawn Capture
            else if (sourceFile == destFile - 1 || sourceFile == destFile + 1) &&
                sourceRank == destRank - 1 &&
                board.map(\.location).contains(move.destination) {
                return .success(())
            }
            //TODO: en passant
            // invalid move
            return .failure(.invalidMove)
        } else {
            // Standard pawn move
            if sourceFile == destFile &&
                sourceRank == destRank + 1 &&
                !board.map(\.location).contains(move.destination) {
                return .success(())
            }
            // Pawn opening double move
            else if sourceRank == 7  &&
                sourceFile == destFile &&
                sourceRank == destRank + 2 {
                return .success(())
            }
            // Pawn Capture
            else if (sourceFile == destFile - 1 || sourceFile == destFile + 1) &&
                sourceRank == destRank + 1 &&
                board.map(\.location).contains(move.destination) {
                return .success(())
            }
            //TODO: en passant
            // invalid move
            return .failure(.invalidMove)
        }
    }
}

extension Chess {
    static func isThreatened(piece: Piece, board: [Piece]) -> Bool {
        // A piece is threatened if the opponent has a piece on the board
        // that can legally move to the described location.
        let opponentsPieces = board.filter {
            $0.color != piece.color
        }
        
        return opponentsPieces.contains {
            let result: Result<(), MoveError>
            let move = Move(piece: $0, destination: piece.location)
            switch $0.kind {
            case .king:
                result = Self.isValidMoveKing(board: board, move: move)
            case .queen:
                result = Self.isValidMoveQueen(board: board, move: move)
            case .bishop:
                result = Self.isValidMoveBishop(board: board, move: move)
            case .knight:
                result = Self.isValidMoveKnight(board: board, move: move)
            case .rook:
                result = Self.isValidMoveRook(board: board, move: move)
            case .pawn:
                result = Self.isValidMovePawn(board: board, move: move)
            }
            if case .success = result {
                return true
            }
            return false
        }
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
