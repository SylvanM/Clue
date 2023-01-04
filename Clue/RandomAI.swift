//
//  RandomAI.swift
//  Clue
//
//  Created by Sylvan Martin on 1/4/23.
//

import Foundation

/**
 * A Clue AI that makes random moves
 */
class RandomAI: ComputerPlayer {
    
    // MARK: Properties
    
    var knowledge: Knowledge
    
    var character: Person
    
    var name: String
    
    var cards: [Card] {
        knowledge.cards[character]!
    }
    
    var location: PlayerLocation {
        knowledge.locations[character]!
    }
    
    /**
     * Creates a random AI with knowledge of their cards and other potentially necessary information
     */
    init(_ name: String, withStartingKnowledge knowledge: Knowledge) {
        self.name = name
        self.character = knowledge.me
        self.knowledge = knowledge
    }
    
    func subscribe(to gameState: GameState) {
        knowledge.game = gameState
    }
    
    func disprove(_ suggestion: Statement) -> Card? {
        var optionsToShow: [Card] = []
        
        if cards.contains(where: { $0 == Card(suggestion.person) }) {
            optionsToShow.append(Card(suggestion.person))
        }
        
        if cards.contains(where: { $0 == Card(suggestion.weapon) }) {
            optionsToShow.append(Card(suggestion.weapon))
        }
        
        if cards.contains(where: { $0 == Card(suggestion.room) }) {
            optionsToShow.append(Card(suggestion.room))
        }
        
        return optionsToShow.randomElement()
    }
    
    func makeTurn() -> Action {
        // literally just travel
        
        return .travel
    }
    
    func show(_ card: Card, from person: Person) {
        var i = 0
        
        while knowledge.cards[person]![i] != .unknown { i += 1 }
        
        if knowledge.cards[person]!.indices.contains(i) {
            knowledge.cards[person]![i] = card
        }
    }
    
    
    
    
}
