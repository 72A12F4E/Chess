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
    
    @State
    var error: Error?
    
    @State
    var isShowingError: Bool = false
    
    // Promotion Interaction
    @State
    var isShowingPromotionPrompt: Bool = false
    
    @State
    var promotionMove: Move?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(1..<9) { file in
                VStack(spacing: 0) {
                    ForEach(1..<9) { rank in
                        square(file: file, rank: rank)
                    }
                }
            }
        }
        .border(SwiftUI.Color.black, width: 1)
        .aspectRatio(1.0, contentMode: .fit)
        .alert(isPresented: $isShowingError) {
            Alert(
                title: Text("Error"),
                message: Text(error?.localizedDescription ?? "")
            )
        }
        .actionSheet(isPresented: $isShowingPromotionPrompt) {
            ActionSheet(
                title: Text("Congratulations!"),
                message: Text("Pick your new piece"),
                buttons: [
                    .default(Text("Rook")) {
                        guard var move = promotionMove else { return }
                        move.promotionChoice = .rook
                        performMove(move)
                    },
                    .default(Text("Bishop")) {
                        guard var move = promotionMove else { return }
                        move.promotionChoice = .bishop
                        performMove(move)
                    },
                    .default(Text("Knight")) {
                        guard var move = promotionMove else { return }
                        move.promotionChoice = .knight
                        performMove(move)
                    },
                    .default(Text("Queen")) {
                        guard var move = promotionMove else { return }
                        move.promotionChoice = .queen
                        performMove(move)
                    },
                ]
            )
        }
    }
    
    
    @ViewBuilder
    func square(file: Int, rank: Int) -> some View {
        let location = BoardLocation(file: file, rank: rank)
        ZStack {
            Rectangle()
                .foregroundColor(color(rank: rank, file: file))
                .onTapGesture {
                    onSquareTapped(location)
                }
            Text(location.description)
                .font(.system(size: 10))
                
            if let piece = chess.piece(for: location) {
                piece.image
                    .resizable()
                    .onTapGesture {
                        onPieceTapped(piece, location: location)
                    }
            }
        }
    }
    
    private func onSquareTapped(_ location: BoardLocation) {
        if let selected = selectedSquare, let piece = chess.piece(for: selected) {
            let move = Move(piece: piece, destination: location)
            performMove(move)
        }
    }
    
    private func onPieceTapped(_ piece: Piece, location: BoardLocation) {
        guard selectedSquare != location else {
            selectedSquare = nil
            return
        }
        if let selected = selectedSquare, let piece = chess.piece(for: selected) {
            let move = Move(piece: piece, destination: location)
            performMove(move)
        } else if chess.turn == piece.color {
            self.selectedSquare = location
        }
    }
    
    private func performMove(_ move: Move) {
        if move.isPromotion && promotionMove == nil {
            promotionMove = move
            isShowingPromotionPrompt = true
        } else {
            promotionMove = nil
            selectedSquare = nil
            do {
                try chess.apply(move)
            } catch {
                self.error = error
                isShowingError = true
            }
        }
    }
    
    private func color(rank: Int, file: Int) -> SwiftUI.Color {
        let location = BoardLocation(file: file, rank: rank)
        if selectedSquare == location {
            return .yellow
        }
        let green = SwiftUI.Color(red: 0.462, green: 0.576, blue: 0.329, opacity: 1)
        let white = SwiftUI.Color(red: 0.917, green: 0.917, blue: 0.811, opacity: 1)
        return (file + (rank - 1 * 8)).isMultiple(of: 2) ? green : white
    }
}

