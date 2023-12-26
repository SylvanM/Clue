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
    
    typealias NoteBook = (
        people:     [Person : InformationStatus],
        weapons:    [Weapon : InformationStatus],
        rooms:      [Room   : InformationStatus]
    )
    
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
    var locations: [Person : PlayerLocation] {
        game.locations
    }
    
    /**
     * The cards everyone (including this player) in the game is holding, if they are known!
     */
    var knownCards: [Person : Set<Card>]
    
    /**
     * Keep track of what players certainly DON'T have certain cards
     *
     * This dictionary does NOT include `self.character` as a key.
     */
    var antiCards: [Person : Set<Card>]
    
    /**
     * Sometimes a player disproves a suggestion and you know they must have ONE of those cards!
     */
    var oneOfThese: [Person : Set<Card>]
    
    /**
     * The publically available game state, set by subscribing to an ongoing game.
     */
    var game: GameState!
    
    // MARK: Initializers
    
    /**
     * Creates a game given a certain number of players, and the cards in this players hand.
     *
     * - Parameter asPlayer: Me!
     * - Parameter players: A record of all players in the game, and how many cards they have.
     * - Parameter myCards: All cards dealt to this player in the game.
     */
    init(asPlayer: Person, players: [Person : Int], myCards: [Card]) {
        self.me = asPlayer
        self.knownCards = [:]
        self.antiCards = [:]
        self.oneOfThese = [:]
        
        for (player, _) in players {
            knownCards[player] = Set<Card>()
            if player != me {
                antiCards[player] = []
            }
        }
        
        
        knownCards[me] = Set(myCards)
        
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
