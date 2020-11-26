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
        HStack(spacing: 0) {
            ForEach(1..<9) { file in
                VStack(spacing: 0) {
                    ForEach(1..<9) { rank in
                        ZStack {
                            Rectangle()
                                .foregroundColor(color(rank: rank, file: file))
                                .border(SwiftUI.Color.black, width: 1)
                            if let piece = piece(rank: rank, file: file) {
                                piece.image.resizable()
                            }
                        }
                    }
                }
            }
        }
        .border(SwiftUI.Color.black, width: 2)
        .aspectRatio(1.0, contentMode: .fit)
        .padding()
    }
    
    private func piece(rank: Int, file: Int) -> Piece? {
        let location = BoardLocation(file: file, rank: rank)
        return chess.board.first(where: {
            $0.location == location
        })
    }
    
    private func color(rank: Int, file: Int) -> SwiftUI.Color {
        (file + (rank - 1 * 8)).isMultiple(of: 2) ? .gray : .white
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
