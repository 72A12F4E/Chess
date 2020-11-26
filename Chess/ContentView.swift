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
        VStack {
            Text("\(chess.turn == .white ? "White" : "Black")'s move")
                .font(.largeTitle)
            ChessBoardView()
                .padding()
            MoveHistoryView()
                .padding()
            
        }
    }
}
