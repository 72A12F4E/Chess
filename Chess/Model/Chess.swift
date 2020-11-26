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

    func isValidMove(_ move: Move) -> Result<Void, MoveError> {
        guard turn == move.piece.color else {
            return .failure(.wrongTurn)
        }
        
        guard move.piece.location != move.destination else {
            return .failure(.moveToSameLocation)
        }
        
        guard board.contains(move.piece) else {
            return .failure(.noPieceAtLocation)
        }
        
        guard !Set(board.filter {
                $0.color == move.piece.color
            }.map(\.location))
            .contains(move.destination) else {
            return .failure(.noCaptureOwnPiece)
        }
        
        switch move.piece.kind {
        case .king:
            return isValidMoveKing(move)
        case .queen:
            return isValidMoveQueen(move)
        case .bishop:
            return isValidMoveBishop(move)
        case .knight:
            return isValidMoveKnight(move)
        case .rook:
            return isValidMoveRook(move)
        case .pawn:
            return isValidMovePawn(move)
        }
    }
    
    private func isValidMoveKing(_ move: Move) -> Result<Void, MoveError> {
        if abs(move.destination.rank - move.piece.location.rank) <= 1 &&
            abs(move.destination.file - move.piece.location.file) <= 1 {
            return .success(())
        }
        return .failure(.invalidMove)
    }
    
    private func isValidMoveQueen(_ move: Move) -> Result<Void, MoveError> {
        // A queen is just a combination of a Rook & Bishop
        // so we can re-use their validation
        let result1 = isValidMoveRook(move)
        if case .success = result1 {
            return result1
        }
        let result2 = isValidMoveBishop(move)
        if case .success = result2 {
            return result2
        }
        
        return .failure(.invalidMove)
    }
    
    private func isValidMoveBishop(_ move: Move) -> Result<Void, MoveError> {
        .failure(.invalidMove)
    }
    
    private func isValidMoveKnight(_ move: Move) -> Result<Void, MoveError>  {
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
    
    private func isValidMoveRook(_ move: Move) -> Result<Void, MoveError> {
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
    
    private func isValidMovePawn(_ move: Move) -> Result<Void, MoveError> {
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
            // invalid move
            else {
                return .failure(.invalidMove)
            }
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
            // invalid move
            else {
                return .failure(.invalidMove)
            }
        }
    }
    
    @discardableResult
    func apply(_ move: Move) -> Result<Void, MoveError> {
        let result = isValidMove(move)
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
