//
//  Color.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import Foundation

enum Color {
    case white
    case black
}

extension Color: CustomStringConvertible {
    var description: String {
        self == .white ? "White" : "Black"
    }
}
