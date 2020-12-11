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
    static func isValidMove(board: [Piece], move: Move, turn: Color, history: [Move]) throws {
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
            try Self.isValidMoveKing(board: board, move: move, history: history)
        case .queen:
            try Self.isValidMoveQueen(board: board, move: move)
        case .bishop:
            try Self.isValidMoveBishop(board: board, move: move)
        case .knight:
            try Self.isValidMoveKnight(board: board, move: move)
        case .rook:
            try Self.isValidMoveRook(board: board, move: move)
        case .pawn:
            try Self.isValidMovePawn(board: board, move: move, history: history)
        }
        
        // If a move would place your own king in check its not a valid move
        // Try and apply the new move and see if the king becomes threatened
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
    
    static func isValidMoveKing(board: [Piece], move: Move, history: [Move]) throws {
        if abs(move.destination.rank - move.piece.location.rank) <= 1 &&
            abs(move.destination.file - move.piece.location.file) <= 1 {
            return
        }
    
        guard move.isCastle else {
            throw MoveError.invalidMove
        }
        
        // https://en.wikipedia.org/wiki/Castling
        //
        // Castling may only be done if
        //  * the king has never moved,
        //  * the rook involved has never moved
        //  * the squares between the king and the rook involved are unoccupied
        //  * the king is not in check,
        //  * the king does not cross over or end on a square attacked by an enemy piece.
        let color = move.piece.color
        let isKingSide = move.destination.file == 7
        
        let isKingMoved = history.contains {
            $0.piece.kind == .king && $0.piece.color == color
        }
        
        let isRookMoved = history.contains {
            $0.piece.color == .white ?
                $0.piece.kind == .rook &&
                (isKingSide ? $0.piece.location == .h1 : $0.piece.location == .a1) :
                $0.piece.kind == .rook &&
                (isKingSide ? $0.piece.location == .h8 : $0.piece.location == .a8)
        }
        
        let openLocations: [BoardLocation] = {
            if isKingSide && color == .white {
                return [.f1, .g1]
            } else if color == .white {
                return [.b1, .c1, .d1]
            } else if isKingSide {
                return [.f8, .g8]
            } else {
                return [.b8, .c8, .d8]
            }
        }()
        let isOpen = Set(board.map(\.location)).intersection(openLocations).isEmpty
        
        let threatenedLocations: [BoardLocation] = {
            if isKingSide && color == .white {
                return [.f1, .g1, move.piece.location]
            } else if color == .white {
                return [.c1, .d1, move.piece.location]
            } else if isKingSide {
                return [.f8, .g8, move.piece.location]
            } else {
                return [.c8, .d8, move.piece.location]
            }
        }()

        let isUnderThreat = threatenedLocations.allSatisfy {
            isThreatened(location: $0, by: color == .white ? .black : .white, board: board)
        }
        
        guard !isKingMoved && !isRookMoved && isOpen && !isUnderThreat else {
            throw MoveError.invalidMove
        }
    }
    
    static func isValidMoveQueen(board: [Piece], move: Move) throws {
        // A queen is just a combination of a Rook & Bishop
        // so we can re-use their validation rules :-)
        do {
            try isValidMoveRook(board: board, move: move)
        } catch {
            try isValidMoveBishop(board: board, move: move)
        }
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
        
        guard isValid else {
            throw MoveError.invalidMove
        }
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
            if Set(board.map(\.location)).intersection(span).count <= 1 {
                return
            }
        } else {
            let minRank = min(sourceRank, destRank)
            let maxRank = max(sourceRank, destRank)
            let span = (minRank..<maxRank).map {
                BoardLocation(file: sourceFile, rank: $0)
            }
            if Set(board.map(\.location)).intersection(span).count <= 1 {
                return
            }
        }
        
        throw MoveError.invalidMove
    }
    
    static func isValidMovePawn(board: [Piece], move: Move, history: [Move]) throws {
        let sourceRank = move.piece.location.rank
        let sourceFile = move.piece.location.file
        let destRank = move.destination.rank
        let destFile = move.destination.file
        if move.piece.color == .white {
            // Standard pawn move
            let isStandardMove = sourceFile == destFile &&
                sourceRank == destRank - 1 &&
                !board.map(\.location).contains(move.destination)
            
            // Pawn opening double move
            let isOpeningMove = sourceRank == 2 &&
                sourceFile == destFile &&
                sourceRank == destRank - 2 &&
                !board.map(\.location).contains(move.destination) &&
                !board.map(\.location).contains(BoardLocation(file: destFile, rank: destRank - 1))
            
            // Pawn Capture
            let isCapture = (sourceFile == destFile - 1 || sourceFile == destFile + 1) &&
                sourceRank == destRank - 1 &&
                board.map(\.location).contains(move.destination)
            
            // En passant: https://en.wikipedia.org/wiki/En_passant
            let isEnPassant = history.last.flatMap { previousMove in
                previousMove.piece.kind == .pawn &&
                    previousMove.piece.location.rank == 7 &&
                    previousMove.destination.rank == 5 &&
                    move.destination.rank == 6 &&
                    move.destination.file == previousMove.piece.location.file
            } ?? false
            
            guard isStandardMove || isOpeningMove || isCapture || isEnPassant else {
                throw MoveError.invalidMove
            }
        } else {
            // Standard pawn move
            let isStandardMove = sourceFile == destFile &&
                sourceRank == destRank + 1 &&
                !board.map(\.location).contains(move.destination)
            
            // Pawn opening double move
            let isOpeningMove = sourceRank == 7 &&
                sourceFile == destFile &&
                sourceRank == destRank + 2 &&
                !board.map(\.location).contains(move.destination) &&
                !board.map(\.location).contains(BoardLocation(file: destFile, rank: destRank + 1))
                
            // Pawn Capture
            let isCapture = (sourceFile == destFile - 1 || sourceFile == destFile + 1) &&
                sourceRank == destRank + 1 &&
                board.map(\.location).contains(move.destination)
            
            // En passant: https://en.wikipedia.org/wiki/En_passant
            let isEnPassant = history.last.flatMap { previousMove in
                previousMove.piece.kind == .pawn &&
                    previousMove.piece.location.rank == 2 &&
                    previousMove.destination.rank == 4 &&
                    move.destination.rank == 3 &&
                    move.destination.file == previousMove.piece.location.file
            } ?? false
            
            guard isStandardMove || isOpeningMove || isCapture || isEnPassant else {
                throw MoveError.invalidMove
            }
        }
    }
}

extension Chess {
    
    /// Returns true if the given piece is attackable by an opponent's piece.
    static func isThreatened(piece: Piece, board: [Piece]) -> Bool {
        let opponent: Color = piece.color == .white ? .black : .white
        return isThreatened(location: piece.location, by: opponent, board: board)
    }
    
    /// Returns true if the given location is attackable by an opponent's piece
    static func isThreatened(location: BoardLocation, by opponent: Color, board: [Piece]) -> Bool {
        let opponentsPieces = board.filter {
            $0.color == opponent
        }
        return opponentsPieces.contains {
            let move = Move(piece: $0, destination: location)
            do {
                switch $0.kind {
                case .king:
                    try Self.isValidMoveKing(board: board, move: move, history: [])
                case .queen:
                    try Self.isValidMoveQueen(board: board, move: move)
                case .bishop:
                    try Self.isValidMoveBishop(board: board, move: move)
                case .knight:
                    try Self.isValidMoveKnight(board: board, move: move)
                case .rook:
                    try Self.isValidMoveRook(board: board, move: move)
                case .pawn:
                    try Self.isValidMovePawn(board: board, move: move, history: [])
                }
            } catch {
                return false
            }
            return true
        }
    }
    
    
    /// A player is in checkmate if their king is threatened and there are no possible moves
    /// that would remove their king from check.
    /// - Parameters:
    ///   - color: the color to check for checkmate
    ///   - board: the current state of the board
    ///   - history: the move history
    /// - Returns: `true` if `color`s king is in checkmate
    static func isCheckmate(color: Color, board: [Piece], history: [Move]) -> Bool {
        guard let king = board.first(where: { $0.kind == .king && $0.color == color }) else {
             return true
        }
        return isThreatened(piece: king, board: board) && !board
            .filter { color == $0.color }
            .flatMap { piece in
                BoardLocation.allCases.compactMap { location in
                    Move(piece: piece, destination: location)
                }
            }.contains(where: {
                do {
                    try Chess.isValidMove(board: board, move: $0, turn: color, history: history)
                    return true
                } catch {
                    return false
                }
            })
    }
}
