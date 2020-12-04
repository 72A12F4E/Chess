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
                if let winner = chess.winner {
                    Text("\(winner.description) wins!")
                    Button("Play Again") {
                        chess.reset()
                    }
                } else if let check = chess.inCheck {
                    Text("\(check.description) is in check")
                } else {
                    Text("\(chess.turn.description) to move")
                }
                MoveHistoryView()
            }.navigationTitle("Chess")
        }
    }
}
