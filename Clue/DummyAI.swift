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
class DummyAI: ComputerPlayer {
    
    
    
    func makeTurn() {
        //
    }
    
    func canDisprove(_: Statement) -> Bool {
        true
    }
    
    
    
    
    // MARK: Properties
    
    var knowledge: Knowledge
    
    var character: Person
    
    var name: String
    
    var game: Game!
    
    var cards: Set<Card> {
        knowledge.knownCards[character]!
    }
    
    var location: PlayerLocation {
        knowledge.locations[character]!
    }
    
    // MARK: Initializers
    
    /**
     * Creates a random AI with knowledge of their cards and other potentially necessary information
     */
    init(_ name: String, withStartingKnowledge knowledge: Knowledge) {
        self.name = name
        self.character = knowledge.me
        self.knowledge = knowledge
    }
    
    // MARK: Housekeeping
    
    func receive(_: Event) {
        
    }
    
    func revealCards() -> Set<Card> {
        cards
    }
    
    func setGame(to game: Game) {
        self.game = game
        knowledge.game = game.gameState
    }
    
    func show(_ card: Card, from person: Person) {
        knowledge.knownCards[person]!.insert(card)
        
        // Cross that card off the notebook
        
        switch card {
        case .roomCard(let room):
            knowledge.notebook.rooms[room] = .ruledOut
        case .playerCard(let person):
            knowledge.notebook.people[person] = .ruledOut
        case .weaponCard(let weapon):
            knowledge.notebook.weapons[weapon] = .ruledOut
        case .unknown:
            fatalError("This should never happen.")
        }
    }
    
    // MARK: Gameplay
    
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
    
}
