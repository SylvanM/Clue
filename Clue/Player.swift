//
//  Player.swift
//  Clue
//
//  Created by Sylvan Martin on 1/2/23.
//

import Foundation

/**
 * A player in the game of clue
 */
protocol Player {
    
    /**
     * The character this player is playing as
     */
    var character: Person { get }
    
    /**
     * The display name of this player
     */
    var name: String { get }
    
    /**
     * Called to get the card to disprove a suggestion, or nil if unable
     *
     * - Parameter suggestion: The `Statement` to disprove
     */
    func disprove(_ suggestion: Statement) -> Card?
    
    /**
     * Called on the player's turn to get what they want to do with their turn
     */
    func makeTurn() -> Action
    
}
