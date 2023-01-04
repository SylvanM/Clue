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
enum Card: CustomStringConvertible {
    case roomCard(Room)
    case playerCard(Person)
    case weaponCard(Weapon)
    case unknown
    
    var description: String {
        switch self {
        case .roomCard(let room):
            return room.description
        case .playerCard(let person):
            return person.description
        case .weaponCard(let weapon):
            return weapon.description
        case .unknown:
            return "unknown"
        }
    }
    
    init?(_ string: String) {
        if let room = Room(string) {
            self = .roomCard(room)
        } else if let person = Person(string) {
            self = .playerCard(person)
        } else if let weapon = Weapon(string) {
            self = .weaponCard(weapon)
        } else {
            return nil
        }
    }
}

/**
 * A location in the game of clue
 */
enum Room: CaseIterable, CustomStringConvertible {
    case ballroom
    case dining
    case study
    case kitchen
    case conservatory
    case billiard
    case hall
    case lounge
    
    var description: String {
        "\(self)"
    }
    
    init?(_ string: String) {
        switch string {
        case "ballroom":
            self = .ballroom
        case "dining":
            self = .dining
        case "study":
            self = .study
        case "kitchen":
            self = .kitchen
        case "conservatory":
            self = .conservatory
        case "billiard":
            self = .billiard
        case "hall":
            self = .hall
        case "lounge":
            self = .lounge
        default:
            return nil
        }
    }
}

/**
 * A player in the game of clue
 */
enum Person: CaseIterable, CustomStringConvertible {
    case scarlet
    case white
    case peacock
    case plum
    case green
    case mustard
    
    var description: String {
        "\(self)"
    }
    
    init?(_ string: String) {
        switch string {
        case "scarlet":
            self = .scarlet
        case "white":
            self = .white
        case "peacock":
            self = .peacock
        case "plum":
            self = .plum
        case "green":
            self = .green
        case "mustard":
            self = .mustard
        default:
            return nil
        }
    }
}

/**
 * A weapon in the game of clue
 */
enum Weapon: CaseIterable, CustomStringConvertible {
    case candlestick
    case knife
    case pipe
    case revolver
    case rope
    case wrench
    
    var description: String {
        "\(self)"
    }
    
    init?(_ string: String) {
        switch string {
        case "candlestick":
            self = .candlestick
        case "knife":
            self = .knife
        case "pipe":
            self = .pipe
        case "revolver":
            self = .revolver
        case "rope":
            self = .rope
        case "wrench":
            self = .wrench
        default:
            return nil
        }
    }
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
typealias Statement = (person: Person, weapon: Weapon, room: Room)

/**
 * Expects three words separated by spaces, in the order `person weapon room`
 */
func readStatement(_ string: String) -> Statement? {
    let items = string.components(separatedBy: " ")
    
    guard let person = Person(items[0]) else { return nil }
    guard let room   = Room(items[1])   else { return nil }
    guard let weapon = Weapon(items[2]) else { return nil }
    
    
    return (person: person, weapon: weapon, room: room)
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
 * An entry in the log, saying what happened in one turn
 */
enum TurnSummary {
    case travel
    case suggestionDisproved(Statement, disprover: Person)
    case suggestionUnrefuted(Statement)
    case accuse(Statement, wasCorrect: Bool)
}

/**
 * Represents the public state of the game. That is, where everyone is, and a log of what has transpired so far.
 */
class GameState {
    
    // MARK: Properties
    
    // A list, in order, of the actions of each turn in the game and who did them
    var actionLog: [(Person, TurnSummary)] = []
    
    var people: [Person]
    
    var locations: [Person : PlayerLocation]
    
    // MARK: Initializers
    
    init(people: [Person]) {
        self.people = people
        
        self.locations = [:]
        
        for player in self.people {
            self.locations[player] = .walking
        }
    }
    
    // MARK: Methods
    
    func log(person: Person, turnSummary: TurnSummary) {
        actionLog.append((person, turnSummary))
    }
    
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
    
    /**
     * The updated game state, can be shared by many other classes
     */
    let gameState: GameState
    
    // MARK: Initializers
    
    init(players: [Player]) {
        self.players = players
        
        self.gameState = GameState(people: players.map { $0.character })
        
        for player in players {
            if player is ComputerPlayer {
                (player as! any ComputerPlayer).subscribe(to: gameState)
            }
        }
    }
    
    // MARK: Methods
    
    func runGame() {
        
        print("Starting the game!")
        
        var gameInProgress = true
        var turnIndex = 0
        
        while gameInProgress {
            print("\n")
            
            let action = players[turnIndex].makeTurn()
            
            switch action {
            case .suggest(let statement):
                
                var i = turnIndex + 1
            
                while i != turnIndex {
                    
                    if let disprovement = players[i].disprove(statement) {
                        // show that the player disproved the statement,
                        
                        gameState.log(
                            person: players[turnIndex].character,
                            turnSummary: .suggestionDisproved(statement, disprover: players[i].character)
                        )
                        
                        break
                    }
                
                    i += 1
                    i %= players.count
                }
                
                if i == turnIndex {
                    gameState.log(person: players[turnIndex].character, turnSummary: .suggestionUnrefuted(statement))
                }
                
            case .accuse(_):
                
                
                
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
