//
//  Chess.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation

class Chess {
    var turn: Color = .white
    var board: [Piece] = initialBoardState
    var history: [Move] = []

    func isValidMove(_ move: Move) -> Result<Void, MoveError> {
        guard turn == move.piece.color else {
            return .failure(.wrongTurn)
        }
        guard board.contains(move.piece) else {
            return .failure(.noPieceAtLocation)
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
        } else {
            return .failure(.invalidMove)
        }
    }
    
    private func isValidMoveQueen(_ move: Move) -> Result<Void, MoveError> {
        .failure(.invalidMove)
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
        ].filter { (1...8).contains($0.0) && (1...8).contains($0.1) }.map {
            BoardLocation(file: $0.0, rank: $0.1)
        }.contains(move.destination)
        
        if isValid {
            return .success(())
        } else {
            return .failure(.invalidMove)
        }
    }
    
    private func isValidMoveRook(_ move: Move) -> Result<Void, MoveError> {
        .failure(.invalidMove)
    }
    
    private func isValidMovePawn(_ move: Move) -> Result<Void, MoveError> {
        if move.piece.color == .white {
            // Standard pawn move
            if move.piece.location.file == move.destination.file &&
                move.piece.location.rank == move.destination.rank - 1 &&
                !board.map(\.location).contains(move.destination) {
                return .success(())
            }
            // Pawn opening double move
            else if move.piece.location.rank == 2  &&
                move.piece.location.file == move.destination.file &&
                move.piece.location.rank == move.destination.rank - 2 {
                return .success(())
            }
            // Capture :TODO:
            
            // invalid move
            else {
                return .failure(.invalidMove)
            }
        } else {
            // Standard pawn move
            if move.piece.location.file == move.destination.file &&
                move.piece.location.rank == move.destination.rank + 1 &&
                !board.map(\.location).contains(move.destination) {
                return .success(())
            }
            // Pawn opening double move
            else if move.piece.location.rank == 7  &&
                move.piece.location.file == move.destination.file &&
                move.piece.location.rank == move.destination.rank + 2 {
                return .success(())
            }
            
            // Capture :TODO:
            
            // invalid move
            else {
                return .failure(.invalidMove)
            }
        }
    }
    
    func apply(_ move: Move) -> Result<Void, MoveError> {
        guard let index = board.firstIndex(of: move.piece) else {
            return .failure(.noPieceAtLocation)
        }
        
        let result = isValidMove(move)
        if case .success = result {
            turn = turn == .white ? .black : .white
            history.append(move)
            board[index] = Piece(
                kind: move.piece.kind,
                color: move.piece.color,
                location: move.destination
            )
        }
        return result
    }
}

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
        return string
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
