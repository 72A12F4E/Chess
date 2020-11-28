//
//  ContentView.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject
    var chess: Chess
    
    var body: some View {
        NavigationView {
            VStack {
                ChessBoardView()
                Text("\(chess.turn.description) to move")
                if let check = chess.inCheck {
                    Text("\(check.description) is in check")
                }
                MoveHistoryView()
            }.navigationTitle("Chess")
        }
    }
}
