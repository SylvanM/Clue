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
    func makeTurn()
    
    /**
     * Called when they are showed a card to disprove their suggestion
     */
    func show(_: Card, from: Person)
    
    /**
     * Returns whether or not this player can disprove a suggestion
     */
    func canDisprove(_: Statement) -> Bool
    
    /**
     * Tells a player that a certain notable action happened
     */
    func receive(_: Event)
    
    /**
     * Called to get which card to show upon a suggestion being made
     */
    func disprove(_ suggestion: Statement) -> Card?
    
    /**
     * Reveals all cards, used when this player is out.
     */
    func revealCards() -> [Card]
    
    func setGame(to game: Game)
    
}
