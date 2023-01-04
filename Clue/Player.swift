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
     * Called on the player's turn to get what they want to do with their turn
     */
    func makeTurn() -> Action
    
}
