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
        "\(piece.description)\(piece.location.description) \(destination.description)"
    }
}

enum MoveError: Error {
    case noPieceAtLocation
    case invalidMove
    case kingInCheck
    case wrongTurn
    case moveToSameLocation
}
