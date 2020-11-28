//
//  Piece.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation

struct Piece: Identifiable, Equatable {
    enum Kind: String {
        case king
        case queen
        case bishop
        case knight
        case rook
        case pawn
    }
    let id: UUID
    private(set) var kind: Kind
    let color: Color
    private(set) var location: BoardLocation
    
    init(kind: Kind, color: Color, location: BoardLocation) {
        self.id = UUID()
        self.kind = kind
        self.color = color
        self.location = location
    }
}

extension Piece {
    mutating func move(to location: BoardLocation) {
        self.location = location
    }
    
    mutating func promote(to kind: Kind) {
        guard kind != .king || kind == .pawn else { return }
        self.kind = kind
    }
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

#if canImport(SwiftUI)
import SwiftUI
extension Piece {
    var image: Image {
        switch (kind, color) {
        case (.king, .white):
            return Image("whiteking")
        case (.queen, .white):
            return Image("whitequeen")
        case (.bishop, .white):
            return Image("whitebishop")
        case (.knight, .white):
            return Image("whiteknight")
        case (.rook, .white):
            return Image("whiterook")
        case (.pawn, .white):
            return Image("whitepawn")
        case (.king, .black):
            return Image("blackking")
        case (.queen, .black):
            return Image("blackqueen")
        case (.bishop, .black):
            return Image("blackbishop")
        case (.knight, .black):
            return Image("blackknight")
        case (.rook, .black):
            return Image("blackrook")
        case (.pawn, .black):
            return Image("blackpawn")
        }
    }
}
#endif
