//
//  Chess+MoveValidation.swift
//  Chess
//
//  Created by Blake McAnally on 11/27/20.
//

import Foundation

extension Chess {
    /// Determines if the given move is legal in a standard chess game
    /// - Parameters:
    ///   - board: the current board state
    ///   - move: the move to perform
    ///   - turn: the current player's turn
    /// - Throws: `MoveError`
    static func isValidMove(board: [Piece], move: Move, turn: Color) throws {
        // You can't move if its not your turn
        guard turn == move.piece.color else {
            throw MoveError.wrongTurn
        }
        
        // You can't move to the same spot.
        guard move.piece.location != move.destination else {
            throw MoveError.moveToSameLocation
        }
        
        // You can't move a piece that doesn't exist
        guard board.contains(move.piece) else {
            throw MoveError.noPieceAtLocation
        }
        
        // You can't capture your own piece
        guard !Set(board.filter {
                $0.color == move.piece.color
            }.map(\.location))
            .contains(move.destination) else {
            throw MoveError.noCaptureOwnPiece
        }
        
        switch move.piece.kind {
        case .king:
            try Self.isValidMoveKing(board: board, move: move)
        case .queen:
            try Self.isValidMoveQueen(board: board, move: move)
        case .bishop:
            try Self.isValidMoveBishop(board: board, move: move)
        case .knight:
            try Self.isValidMoveKnight(board: board, move: move)
        case .rook:
            try Self.isValidMoveRook(board: board, move: move)
        case .pawn:
            try Self.isValidMovePawn(board: board, move: move)
        }
        
        // If a move would place your own king in check its not a valid move
        // Try and apply the new move,
        let isOwnKingThreatened: Bool = {
            var newBoardState = board
            if let capturedIndex = board.firstIndex(where: { $0.location == move.destination }) {
                newBoardState.remove(at: capturedIndex)
            }
            if let index = newBoardState.firstIndex(of: move.piece) {
                newBoardState[index] = Piece(
                    kind: move.piece.kind,
                    color: move.piece.color,
                    location: move.destination
                )
            }
            // find the king's location on the new board
            guard let newKingLocation = newBoardState.first(where: { $0.kind == .king && $0.color == turn }) else {
                return false
            }
            return isThreatened(piece: newKingLocation, board: newBoardState)
        }()
        if isOwnKingThreatened {
            throw MoveError.placesKingInCheck
        }
        
        return
    }
    
    static func isValidMoveKing(board: [Piece], move: Move) throws {
        if abs(move.destination.rank - move.piece.location.rank) <= 1 &&
            abs(move.destination.file - move.piece.location.file) <= 1 {
            return
        }
        
        //TODO: handle castling
        
        throw MoveError.invalidMove
    }
    
    static func isValidMoveQueen(board: [Piece], move: Move) throws {
        // A queen is just a combination of a Rook & Bishop
        // so we can re-use their validation rules :-)
        try isValidMoveRook(board: board, move: move)
        try isValidMoveBishop(board: board, move: move)
    }
    
    static func isValidMoveBishop(board: [Piece], move: Move) throws {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        
        // Bishops can only move along a diagonal
        guard abs(sourceRank - destRank) == abs(sourceFile - destFile) else {
            throw MoveError.invalidMove
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
            throw MoveError.invalidMove
        }
        
        return
    }
    
    static func isValidMoveKnight(board: [Piece], move: Move) throws  {
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
            return
        }
        
        throw MoveError.invalidMove
    }
    
    static func isValidMoveRook(board: [Piece], move: Move) throws {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        // Rooks can only move along their current rank & file
        guard sourceRank == destRank || sourceFile == destFile else {
            throw MoveError.invalidMove
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
                return
            }
        } else {
            let minRank = min(sourceRank, destRank)
            let maxRank = max(sourceRank, destRank)
            let span = (minRank..<maxRank).map {
                BoardLocation(file: sourceFile, rank: $0)
            }
            if Set(board.map(\.location)).intersection(span).count == 1 {
                return
            }
        }
        
        throw MoveError.invalidMove
    }
    
    static func isValidMovePawn(board: [Piece], move: Move) throws {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        if move.piece.color == .white {
            // Standard pawn move
            if sourceFile == destFile &&
                sourceRank == destRank - 1 &&
                !board.map(\.location).contains(move.destination) {
                return
            }
            // Pawn opening double move
            else if sourceRank == 2 &&
                sourceFile == destFile &&
                sourceRank == destRank - 2 {
                return
            }
            // Pawn Capture
            else if (sourceFile == destFile - 1 || sourceFile == destFile + 1) &&
                sourceRank == destRank - 1 &&
                board.map(\.location).contains(move.destination) {
                return
            }
            //TODO: en passant
            // invalid move
            throw MoveError.invalidMove
        } else {
            // Standard pawn move
            if sourceFile == destFile &&
                sourceRank == destRank + 1 &&
                !board.map(\.location).contains(move.destination) {
                return
            }
            // Pawn opening double move
            else if sourceRank == 7  &&
                sourceFile == destFile &&
                sourceRank == destRank + 2 {
                return
            }
            // Pawn Capture
            else if (sourceFile == destFile - 1 || sourceFile == destFile + 1) &&
                sourceRank == destRank + 1 &&
                board.map(\.location).contains(move.destination) {
                return
            }
            //TODO: en passant
            // invalid move
            throw MoveError.invalidMove
        }
    }
}

extension Chess {
    
    /// Returns true if the given piece is attackable by an opponents piece.
    static func isThreatened(piece: Piece, board: [Piece]) -> Bool {
        // A piece is threatened if the opponent has a piece on the board
        // that can legally move to the pieces location.
        let opponentsPieces = board.filter {
            $0.color != piece.color
        }
        
        return opponentsPieces.contains {
            let move = Move(piece: $0, destination: piece.location)
            do {
                switch $0.kind {
                case .king:
                    try Self.isValidMoveKing(board: board, move: move)
                case .queen:
                    try Self.isValidMoveQueen(board: board, move: move)
                case .bishop:
                    try Self.isValidMoveBishop(board: board, move: move)
                case .knight:
                    try Self.isValidMoveKnight(board: board, move: move)
                case .rook:
                    try Self.isValidMoveRook(board: board, move: move)
                case .pawn:
                    try Self.isValidMovePawn(board: board, move: move)
                }
            } catch {
                return false
            }
            return true
        }
    }
}
