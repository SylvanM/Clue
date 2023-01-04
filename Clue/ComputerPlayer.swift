//
//  ComputerPlayer.swift
//  Clue
//
//  Created by Sylvan Martin on 1/3/23.
//

import Foundation

protocol ComputerPlayer: Player {
    
    func subscribe(to gameState: GameState)
    
    /**
     * Called to get which card to show upon a suggestion being made
     */
    func disprove(_ suggestion: Statement) -> Card?
    
    /**
     * Called when
     */
    
}
