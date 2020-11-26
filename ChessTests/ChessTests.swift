//
//  ChessTests.swift
//  ChessTests
//
//  Created by Blake McAnally on 11/25/20.
//

import XCTest
@testable import Chess

class ChessTests: XCTestCase {
    
    func testInitialBoardView() throws {
        let chess = Chess()
        XCTAssertEqual(chess.boardView, """
        ♖♘♗♕♔♗♘♖
        ♙♙♙♙♙♙♙♙
                
                
                
                
        ♟♟♟♟♟♟♟♟
        ♜♞♝♛♚♝♞♜
        """)
    }
    
    func testBoardViewIsDebugDescription() throws {
        let chess = Chess()
        XCTAssertEqual(chess.boardView, chess.debugDescription)
    }
}
