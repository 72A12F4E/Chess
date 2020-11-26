//
//  ChessBoardView.swift
//  Chess
//
//  Created by Blake McAnally on 11/25/20.
//

import SwiftUI

struct ChessBoardView: View {
    @EnvironmentObject
    var chess: Chess

    @State
    var selectedSquare: BoardLocation?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1..<9) { file in
                VStack(spacing: 0) {
                    ForEach(1..<9) { rank in
                        ZStack {
                            Rectangle()
                                .foregroundColor(color(rank: rank, file: file))
                                .border(SwiftUI.Color.black, width: 1)
                                .onTapGesture {
                                    if let selected = selectedSquare,
                                       let piece = chess.piece(rank: selected.rank, file: selected.file) {
                                        print(chess.apply(
                                            Move(piece: piece, destination: BoardLocation(file: file, rank: rank))
                                        ))
                                        selectedSquare = nil
                                    }
                                }
                            if let piece = chess.piece(rank: rank, file: file) {
                                piece.image.resizable()
                                    .onTapGesture {
                                        if let selected = selectedSquare, let piece = chess.piece(for: selected) {
                                            let target = BoardLocation(file: file, rank: rank)
                                            print(chess.apply(
                                                Move(piece: piece, destination: target)
                                            ))
                                            selectedSquare = nil
                                        } else if chess.turn == piece.color {
                                            self.selectedSquare = BoardLocation(file: file, rank: rank)
                                        }
                                    }
                            }
                        }
                    }
                }
            }
        }
        .border(SwiftUI.Color.black, width: 2)
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    private func color(rank: Int, file: Int) -> SwiftUI.Color {
        let location = BoardLocation(file: file, rank: rank)
        if selectedSquare == location {
            return .yellow
        }
        return (file + (rank - 1 * 8)).isMultiple(of: 2) ? .gray : .white
    }
}

