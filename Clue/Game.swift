//
//  Game.swift
//  Clue
//
//  Created by Sylvan Martin on 1/2/23.
//

import Foundation

/**
 * A room, weapon, or character in the game of Clue
 */
enum Card {
    case roomCard(Room)
    case playerCard(Person)
    case weaponCard(Weapon)
    case unknown
}

/**
 * A location in the game of clue
 */
enum Room: CaseIterable {
    case ballroom
    case dining
    case study
    case kitchen
    case conservatory
    case billiard
    case hall
    case lounge
}

/**
 * A player in the game of clue
 */
enum Person: CaseIterable {
    case scarlet
    case white
    case peacock
    case plum
    case green
    case mustard
}

/**
 * A weapon in the game of clue
 */
enum Weapon: CaseIterable {
    case candlestick
    case knife
    case pipe
    case revolver
    case rope
    case wrench
}

/**
 * The location of a player on the board
 */
enum PlayerLocation {
    case inRoom(Room)
    case walking
    // TODO: In future versions, maybe indicate what room they are near or heading toward?
}

/**
 * An accusation or suggestion
 */
typealias Statement = (player: Person, weapon: Weapon, room: Room)

/**
 * Represents the public state of the game. That is, where everyone is, and a log of what has transpired so far.
 */
class GameState {
    
    // MARK: Properties
    
    // A list of players, in order of the turns, with players[0] being the starting player.
    var people: [Person]
    
    var locations: [Person : PlayerLocation]
    
    // MARK: Initializers
    
    init(people: [Person]) {
        self.people = people
        self.locations = [:]
        for player in people {
            self.locations[player] = .walking
        }
    }
    
}

/**
 * An action you can take in a game of Clue
 */
enum Action {
    case suggest(Statement)
    case accuse(Statement)
    case travel
}

/**
 * The class that actually runs the game
 */
class Game {
    
    // MARK: Properties
    
    /**
     * The list of players and their characters
     */
    let players: [Player]
    
    // MARK: Initializers
    
    init(players: [Player]) {
        self.players = players
    }
    
    // MARK: Methods
    
    func runGame() {
        
        var gameInProgress = true
        var turnIndex = 0
        
        while gameInProgress {
            let action = players[turnIndex].makeTurn()
            
            switch action {
            case .suggest(let statement):
                
                var i = turnIndex + 1
            
                while i != turnIndex {
                    
                    if let disprovement = players[i].disprove(statement) {
                        // show that the player disproved the statement,
                        // TODO: Update the log!
                        print(disprovement)
                        break
                    }
                
                    i += 1
                    i %= players.count
                }
                
            case .accuse(_):
                
                // TODO: Ask for input about whether it was right or not
                
                gameInProgress = false
                
                // Either win the game for a player, get this player out (in which case it ends)
                // or another player's cards all get revealed!
                
            case .travel:
                // Do nothing I guess, just move on to the next player!
                break
            }
            
            turnIndex += 1
            turnIndex %= players.count
        }
        
    }
    
}
