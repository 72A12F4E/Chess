//
//  BoardLocation.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation

struct BoardLocation: Equatable, Hashable {
    /// Files are columns that go up and down the chessboard.
    /// Files are indicated with the letters 'a' through 'h'
    ///
    /// https://www.dummies.com/games/chess/naming-ranks-and-files-in-chess/
    let file: Int
    
    /// Ranks are rows that go from side to side across
    /// the chessboard and are referred to by numbers. Each
    /// chessboard has eight ranks, which are numbered from
    /// the bottom of the board (where the white pieces start) on up.
    ///
    /// https://www.dummies.com/games/chess/naming-ranks-and-files-in-chess/
    let rank: Int
}

extension BoardLocation: CustomStringConvertible {
    var description: String {
        String(UnicodeScalar(96 + file)!) + "\(rank)"
    }
}

extension BoardLocation {
    static let a1 = BoardLocation(file: 1, rank: 1)
    static let a2 = BoardLocation(file: 1, rank: 2)
    static let a3 = BoardLocation(file: 1, rank: 3)
    static let a4 = BoardLocation(file: 1, rank: 4)
    static let a5 = BoardLocation(file: 1, rank: 5)
    static let a6 = BoardLocation(file: 1, rank: 6)
    static let a7 = BoardLocation(file: 1, rank: 7)
    static let a8 = BoardLocation(file: 1, rank: 8)

    static let b1 = BoardLocation(file: 2, rank: 1)
    static let b2 = BoardLocation(file: 2, rank: 2)
    static let b3 = BoardLocation(file: 2, rank: 3)
    static let b4 = BoardLocation(file: 2, rank: 4)
    static let b5 = BoardLocation(file: 2, rank: 5)
    static let b6 = BoardLocation(file: 2, rank: 6)
    static let b7 = BoardLocation(file: 2, rank: 7)
    static let b8 = BoardLocation(file: 2, rank: 8)
    
    static let c1 = BoardLocation(file: 3, rank: 1)
    static let c2 = BoardLocation(file: 3, rank: 2)
    static let c3 = BoardLocation(file: 3, rank: 3)
    static let c4 = BoardLocation(file: 3, rank: 4)
    static let c5 = BoardLocation(file: 3, rank: 5)
    static let c6 = BoardLocation(file: 3, rank: 6)
    static let c7 = BoardLocation(file: 3, rank: 7)
    static let c8 = BoardLocation(file: 3, rank: 8)

    static let d1 = BoardLocation(file: 4, rank: 1)
    static let d2 = BoardLocation(file: 4, rank: 2)
    static let d3 = BoardLocation(file: 4, rank: 3)
    static let d4 = BoardLocation(file: 4, rank: 4)
    static let d5 = BoardLocation(file: 4, rank: 5)
    static let d6 = BoardLocation(file: 4, rank: 6)
    static let d7 = BoardLocation(file: 4, rank: 7)
    static let d8 = BoardLocation(file: 4, rank: 8)

    static let e1 = BoardLocation(file: 5, rank: 1)
    static let e2 = BoardLocation(file: 5, rank: 2)
    static let e3 = BoardLocation(file: 5, rank: 3)
    static let e4 = BoardLocation(file: 5, rank: 4)
    static let e5 = BoardLocation(file: 5, rank: 5)
    static let e6 = BoardLocation(file: 5, rank: 6)
    static let e7 = BoardLocation(file: 5, rank: 7)
    static let e8 = BoardLocation(file: 5, rank: 8)

    static let f1 = BoardLocation(file: 6, rank: 1)
    static let f2 = BoardLocation(file: 6, rank: 2)
    static let f3 = BoardLocation(file: 6, rank: 3)
    static let f4 = BoardLocation(file: 6, rank: 4)
    static let f5 = BoardLocation(file: 6, rank: 5)
    static let f6 = BoardLocation(file: 6, rank: 6)
    static let f7 = BoardLocation(file: 6, rank: 7)
    static let f8 = BoardLocation(file: 6, rank: 8)
    
    static let g1 = BoardLocation(file: 7, rank: 1)
    static let g2 = BoardLocation(file: 7, rank: 2)
    static let g3 = BoardLocation(file: 7, rank: 3)
    static let g4 = BoardLocation(file: 7, rank: 4)
    static let g5 = BoardLocation(file: 7, rank: 5)
    static let g6 = BoardLocation(file: 7, rank: 6)
    static let g7 = BoardLocation(file: 7, rank: 7)
    static let g8 = BoardLocation(file: 7, rank: 8)

    static let h1 = BoardLocation(file: 8, rank: 1)
    static let h2 = BoardLocation(file: 8, rank: 2)
    static let h3 = BoardLocation(file: 8, rank: 3)
    static let h4 = BoardLocation(file: 8, rank: 4)
    static let h5 = BoardLocation(file: 8, rank: 5)
    static let h6 = BoardLocation(file: 8, rank: 6)
    static let h7 = BoardLocation(file: 8, rank: 7)
    static let h8 = BoardLocation(file: 8, rank: 8)
}
