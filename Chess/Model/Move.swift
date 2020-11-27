//
//  Move.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation

struct Move {
    let piece: Piece
    let destination: BoardLocation
}

extension Move: CustomStringConvertible {
    var description: String {
        "\(piece.description) \(piece.location.description) \(destination.description)"
    }
}

enum MoveError: LocalizedError {
    case noPieceAtLocation
    case invalidMove
    case placesKingInCheck
    case wrongTurn
    case moveToSameLocation
    case noCaptureOwnPiece
}

extension MoveError {
    var errorDescription: String? {
        switch self {
        case .noPieceAtLocation:
            return "Attempted to move a piece that does not exist!"
        case .invalidMove:
            return "This is an invalid move"
        case .placesKingInCheck:
            return "This move places your king in check"
        case .wrongTurn:
            return "It isn't your turn to move"
        case .moveToSameLocation:
            return "You cannot move to the same location"
        case .noCaptureOwnPiece:
            return "You cannot capture your own piece"
        }
    }
}
