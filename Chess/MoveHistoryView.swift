//
//  MoveHistoryView.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import SwiftUI

struct MoveHistoryView: View {
    @EnvironmentObject
    var chess: Chess
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(chess.history, id: \.description) { move in
                    Text(move.description)
                        .lineLimit(1)
                        
                }
            }
        }.padding()    }
}
