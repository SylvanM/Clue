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
enum Card: CustomStringConvertible, Equatable, Hashable {
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
    
    init(_ person: Person) {
        self = .playerCard(person)
    }
    
    init(_ weapon: Weapon) {
        self = .weaponCard(weapon)
    }
    
    init(_ room: Room) {
        self = .roomCard(room)
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
    case library
    case lounge
    
    var description: String {
        switch self {
        case .ballroom:
            return "ballroom"
        case .dining:
            return "dining"
        case .study:
            return "study"
        case .kitchen:
            return "kitchen"
        case .conservatory:
            return "conservatory"
        case .billiard:
            return "billiard"
        case .hall:
            return "hall"
        case .lounge:
            return "lounge"
        case .library:
            return "library"
        }
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
        case "library":
            self = .library
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
        switch self {
        case .scarlet:
            return "scarlet"
        case .white:
            return "white"
        case .peacock:
            return "peacock"
        case .plum:
            return "plum"
        case .green:
            return "green"
        case .mustard:
            return "mustard"
        }
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
        switch self {
        case .candlestick:
            return "candlestick"
        case .knife:
            return "knife"
        case .pipe:
            return "pipe"
        case .revolver:
            return "revolver"
        case .rope:
            return "rope"
        case .wrench:
            return "wrench"
        }
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
}

/**
 * An accusation or suggestion
 */
typealias Statement = (person: Person, weapon: Weapon, room: Room)

/**
 * Expects three words separated by spaces, in the order `person room weapon`
 */
func readStatement(_ string: String) -> Statement? {
    let items = string.components(separatedBy: " ")
    
    if items.count != 3 { return nil }
    
    guard let person = Person(items[0]) else { return nil }
    guard let room   = Room(items[1])   else { return nil }
    guard let weapon = Weapon(items[2]) else { return nil }
    
    
    return (person: person, weapon: weapon, room: room)
}

/**
 * An action you can take in a game of Clue
 */
indirect enum Action {
    
    /**
     * Suspect a person, weapon, and room
     */
    case suggest(Statement)
    
    /**
     * Ultimately ACCUSE someone!
     */
    case accuse(Statement)
    
    /**
     * Indicate traveling with a room in mind
     */
    case travel(to: Room)
    
    /**
     * End the turn.
     */
    case end
    
}

/**
 * An entry in the log, saying what a player did that was notable. Multiple of these can be entered for one turn.
 *
 * As of this version of the program, this is NOT omnicient. This only records what I believe to be the most notable actions performec
 * in a turn.
 */
indirect enum NotableAction {
    
    /**
     * The player traveled.
     */
    case travel(to: Room)
    
    /**
     * The player made a suggestion that was disproved by `disprover`
     */
    case suggestionDisproved(Statement, disprover: Person)
    
    /**
     * A certain player was unable to refute a statement given by the active character
     */
    case couldntRefute(Statement, person: Person)
    
    /**
     * The player made an unrefuted suggestion
     */
    case suggestionUnrefuted(Statement)
    
    /**
     * The player made an accusation
     */
    case accuse(Statement, wasCorrect: Bool)
}

typealias Event = (Person, NotableAction)

/**
 * Represents the public state of the game. That is, where everyone is, and a log of what has transpired so far.
 */
class GameState {
    
    // MARK: Properties
    
    /// A list, in order, of the actions of each turn in the game and who did them
    var actionLog: [Event] = []
    
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
    
    func log(person: Person, action: NotableAction) {
        actionLog.append((person, action))
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
    var players: [Player]
    
    /**
     * The updated game state, can be shared by many other classes
     */
    let gameState: GameState
    
    /**
     * Who's turn it is, as an index in `players`
     */
    var turnIndex: Int = 0
    
    var gameRunning = true
    
    /**
     * The player who's turn it is
     */
    var currentPlayer: Player {
        players[turnIndex]
    }
    
    // MARK: Initializers
    
    init(players: [Player]) {
        self.players = players
        
        self.gameState = GameState(people: players.map { $0.character })
        
        for player in players {
            player.setGame(to: self)
        }
    }
    
    // MARK: Player-Game Interation
    
    /**
     * Tells every player of a specific action to occur
     */
    func broadcast(action: Event) {
        for player in players {
            player.receive(action)
        }
    }
    
    /**
     * Called by a player to suspect people in the game. It is assumed that `players[turnIndex]` is the player making
     * this suggestion.
     *
     * It is up to the players to handle showing the cards to each other. Calls with every notable action that happens.
     */
    func handleSuspect(_ suggestion: Statement, completion: ((NotableAction) -> ())?) {
        
        // we circle around the group, going left, (the "positive" direction)
        
        print("\(currentPlayer.character) is suggesting \(suggestion.person) in the \(suggestion.room) with the \(suggestion.weapon). How will everyone respond?")
        
        // first, we re-locate the suggested person to the room!
        if players.contains(where: { $0.character == suggestion.person }) {
            gameState.locations[suggestion.person] = .inRoom(suggestion.room)
        }
        
        var disproverIndex = (turnIndex + 1) % players.count
        
        var disprovingPlayer: Player {
            players[disproverIndex]
        }
        
        while disproverIndex != turnIndex {
            
            var disproven = false
            
            if currentPlayer is ComputerPlayer || players[disproverIndex] is ComputerPlayer {
                
                if let card = disprovingPlayer.disprove(suggestion) {
                    currentPlayer.show(card, from: disprovingPlayer.character)
                    disproven = true
                }
                
            } else {
                // human to human interactions are less interesting
                
                if disprovingPlayer.canDisprove(suggestion) {
                    disproven = true
                }
            }
            
            if disproven {
                
                let action = NotableAction.suggestionDisproved(suggestion, disprover: disprovingPlayer.character)
                
                gameState.log(
                    person: currentPlayer.character,
                    action: action
                )
                
                completion?(action)
                return
            } else {
                let action = NotableAction.couldntRefute(suggestion, person: disprovingPlayer.character)
                gameState.log(
                    person: currentPlayer.character,
                    action: action
                )
                completion?(action)
            }
            
            disproverIndex += 1
            disproverIndex %= players.count
            
        }
        
        let action = NotableAction.suggestionUnrefuted(suggestion)
        gameState.log(person: currentPlayer.character, action: action)
        completion?(action)
        
    }
    
    /**
     * Handles when a player makes an accusation
     */
    func handleAccuse(_ statement: Statement) {
        
        print("\(currentPlayer.character) ACCUSES \(statement.person) in the \(statement.room) with the \(statement.weapon)!")
        
        print("Is this accusation correct? (Enter Y/N)")
        let correct = readLine()!.lowercased() == "y"
        
        if correct {
            print("Congrats to \(currentPlayer.name) for winning the game!")
            gameRunning = false
        } else {
            
            // show the cards
            
            for card in currentPlayer.revealCards() {
                for player in players {
                    player.show(card, from: currentPlayer.character)
                }
            }
            
            // kick them out!
            
            players.remove(at: turnIndex)
            turnIndex %= players.count
        }
        
    }
    
    /**
     * Handles a player traveling
     */
    func handleTravel(to target: Room? = nil, arrived: Bool = false) {
        print("\(currentPlayer.name) travels", terminator: "")
        if arrived {
            let room = target!
            gameState.locations[currentPlayer.character] = .inRoom(room)
            print(" into the \(room).")
        } else {
            gameState.locations[currentPlayer.character] = .walking
            if let room = target {
                print(" towards the \(room).")
            } else {
                print(".")
            }
        }
    }
    
    // MARK: Running the Game
    
    func runGame() {
        
        while gameRunning {
            
            print("START of a new turn.")
            print(gameState.locations)
            
            currentPlayer.makeTurn()
            
            print("\n\n")
            
            turnIndex += 1
            turnIndex %= players.count
        }
    }
    
}
