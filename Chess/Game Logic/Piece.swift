//
//  Piece.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation

struct Piece: Equatable {
    enum Kind: String {
        case king
        case queen
        case bishop
        case knight
        case rook
        case pawn
    }
    let kind: Kind
    let color: Color
    let location: BoardLocation
}

extension Piece: CustomStringConvertible {
    var description: String {
        switch (kind, color) {
        case (.king, .white):
            return "♔"
        case (.queen, .white):
            return "♕"
        case (.bishop, .white):
            return "♗"
        case (.knight, .white):
            return "♘"
        case (.rook, .white):
            return "♖"
        case (.pawn, .white):
            return "♙"
        case (.king, .black):
            return "♚"
        case (.queen, .black):
            return "♛"
        case (.bishop, .black):
            return "♝"
        case (.knight, .black):
            return "♞"
        case (.rook, .black):
            return "♜"
        case (.pawn, .black):
            return "♟"
        }
    }
}
