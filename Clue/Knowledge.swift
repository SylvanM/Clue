//
//  Knowledge.swift
//  Clue
//
//  Created by Sylvan Martin on 1/2/23.
//

import Foundation

/**
 * This is a way for an AI to keep track of everything going on in the game of clue. This is everything you would
 * observe in a game of clue, without providing any strategy about how to play. This also keeps track of what cards
 * this player is holding.
 *
 * It is the client's responsibility to update the notebook after initialization!
 */
class Knowledge {
    
    enum InformationStatus {
        case confirmed
        case ruledOut
        case unknown
    }
    
    typealias NoteBook = (people: [Person : InformationStatus], weapons: [Weapon : InformationStatus], rooms: [Room : InformationStatus])
    
    // MARK: Properties
    
    /**
     * The person this player is in the game!
     */
    let me: Person
    
    /**
     * The scratchpaper logbook typical in a game of clue
     */
    var notebook: NoteBook = (
        people:     [Person : InformationStatus](uniqueKeysWithValues: Person.allCases.map  { ($0, .unknown) }),
        weapons:    [Weapon : InformationStatus](uniqueKeysWithValues: Weapon.allCases.map  { ($0, .unknown) }),
        rooms:      [Room   : InformationStatus](uniqueKeysWithValues: Room.allCases.map    { ($0, .unknown) })
    )
    
    /**
     * Where everyone on the board currently is
     */
    var locations: [Person : PlayerLocation]
    
    /**
     * The cards everyone (including this player) in the game is holding, if they are known!
     */
    var cards: [Person : [Card]]
    
    /**
     * The publically available game state
     */
    let game: GameState
    
    // MARK: Initializers
    
    /**
     * Creates a game given a certain number of players, and the cards in this players hand.
     *
     * - Parameter game: The game!
     * - Parameter asPlayer: Me!
     * - Parameter players: A record of all players in the game, and how many cards they have.
     * - Parameter myCards: All cards dealt to this player in the game.
     */
    init(forGame game: GameState, asPlayer: Person, players: [Person : Int], myCards: [Card]) {
        self.game = game
        me = asPlayer
        cards = [:]
        locations = [:]
        
        for (player, cardCount) in players {
            cards[player] = [Card](repeating: .unknown, count: cardCount)
            locations[player] = .walking
        }
        
        cards[me] = myCards
        
        // update the notebook with the knowledge we now have!
        
        for card in myCards {
            switch card {
            case .roomCard(let room):
                notebook.rooms[room] = .ruledOut
            case .playerCard(let person):
                notebook.people[person] = .ruledOut
            case .weaponCard(let weapon):
                notebook.weapons[weapon] = .ruledOut
            case .unknown:
                fatalError("This should never be reached, we should know all our cards!")
            }
        }
    }
    
}
