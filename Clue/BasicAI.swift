//
//  BasicAI.swift
//  Clue
//
//  Created by Sylvan Martin on 1/15/23.
//

import Foundation

/**
 * A computer player that plays the same as a beginner Clue player might play
 */
class BasicAI: ComputerPlayer {
    
    // MARK: Properties
    
    var knowledge: Knowledge
    
    var character: Person
    
    var name: String
    
    var game: Game!
    
    var cards: Set<Card> {
        knowledge.knownCards[character]!
    }
    
    var currentRoom: Room? {
        switch location {
        case .inRoom(let room):
            return room
        case .walking:
            return nil
        }
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
    
    func canDisprove(_: Statement) -> Bool {
        fatalError("This should never be called on a computer player")
    }
    
    func revealCards() -> Set<Card> {
        cards
    }
    
    func setGame(to game: Game) {
        self.game = game
        knowledge.game = game.gameState
    }
    
    func show(_ card: Card, from person: Person) {
        knowledge.knownCards[person]?.insert(card)
        
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
    
    func getCloseRooms() -> [Room] {
        var rooms: [Room] = []
        var input: String = ""
        print("Please enter all the possible rooms that \(name) can go to on this turn. Enter 'done' when done.")
        
        repeat {
            input = readLine()!
            if let room = Room(input) {
                rooms.append(room)
            } else {
                print("Unrecognized input. please try again.")
            }
        } while input != "done"
        
        return rooms
    }
    
    // MARK: Gameplay
    
    /**
     * All the possible rooms still not ruled out
     */
    var suspiciousRooms: Set<Room> {
        let array = knowledge.notebook.rooms.filter { (key: Room, value: Knowledge.InformationStatus) in
            value != .ruledOut
        }.map { (key: Room, _) in
            key
        }
        
        return Set(array)
    }
    
    /**
     * All the possible weapons still not ruled out
     */
    var suspiciousWeapons: Set<Weapon> {
        let array = knowledge.notebook.weapons.filter { (key: Weapon, value: Knowledge.InformationStatus) in
            value != .ruledOut
        }.map { (key: Weapon, _) in
            key
        }
        
        return Set(array)
    }
    
    /**
     * All the possible people still not ruled out
     */
    var suspiciousPeople: Set<Person> {
        let array = knowledge.notebook.people.filter { (key: Person, value: Knowledge.InformationStatus) in
            value != .ruledOut
        }.map { (key: Person, _) in
            key
        }
        
        return Set(array)
    }
    
    func isSuspicious(_ room: Room) -> Bool {
        print("Checking if \(room) is suspicious, since rooms are \(suspiciousRooms)")
        return suspiciousRooms.contains(room)
    }
    
    func isSuspicious(_ weapon: Weapon) -> Bool {
        suspiciousWeapons.contains(weapon)
    }
    
    func isSuspicious(_ person: Person) -> Bool {
        suspiciousPeople.contains(person)
    }
    
    func inSuspiciousRoom() -> Bool {
        switch location {
        case .inRoom(let room):
            return isSuspicious(room)
        case .walking:
            return false
        }
    }

    func overlap<T: Equatable>(_ a1: [T], _ a2: [T]) -> [T] {
        var overlap: [T] = []
        for elem in a1 {
            if a2.contains(where: { $0 == elem }) {
                overlap.append(elem)
            }
        }
        return overlap
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
        
        if optionsToShow.isEmpty {
            print("\(name) cannot disprove this.")
        }
        
        return optionsToShow.randomElement()
    }
    
    func receive(_ event: Event) {
        
        let (person, action) = event
        
        if person == knowledge.me {
            // we already handle when it's us, skip over this!
            return
        }
        
        switch action {
            
        case .suggestionDisproved(let statement, let disprover):
            
            knowledge.oneOfThese[disprover]?.insert(.roomCard(statement.room))
            knowledge.oneOfThese[disprover]?.insert(.playerCard(statement.person))
            knowledge.oneOfThese[disprover]?.insert(.weaponCard(statement.weapon))
            
        case .couldntRefute(let statement, let person):
            
            knowledge.antiCards[person]?.insert(.roomCard(statement.room))
            knowledge.antiCards[person]?.insert(.playerCard(statement.person))
            knowledge.antiCards[person]?.insert(.weaponCard(statement.weapon))
            
        case .suggestionUnrefuted(_):
            // alright at this point, whoever made the suggestion should really just accuse, so there's no use in
            // coding this right now.
            break
            
        case .accuse(_, _):
            // this is already handled
            break
        case .travel(_):
            // We don't care about traveling
            break
        }
    }
    
    func makeTurn() {
        
        // first, if there is only one possible thing, MAKE that accusation!
        
        
        // look at all possibilities for the rooms that are left to guess, and go to that room, if possible.
        if !inSuspiciousRoom() {
            // if there are any overlaps, go to those rooms! If not, indicate that we WANT to go towards one of the suspicious rooms.
            let closeRooms = getCloseRooms()
            
            if let nextRoom = suspiciousRooms.intersection(closeRooms).first {
                game.handleTravel(to: nextRoom, arrived: true)
            } else {
                // we want to travel toward one of the suspicious rooms!
                print("\(name) wants to travel to one of these rooms: \(suspiciousRooms)")
                game.handleTravel()
                return // end of the turn!
            }
        }
        
        if inSuspiciousRoom() {
            // we are right where we need to be! Make a suspicion.
            
            let personToGuess = suspiciousPeople.first!
            let weaponToGuess = suspiciousWeapons.first!
            
            // BasicAI is not smart enough to not giveaway too much information in its suggestions.
            
            game.handleSuspect((person: personToGuess, weapon: weaponToGuess, room: currentRoom!)) { [self] notableEvent in
                switch notableEvent {
                    
                case .couldntRefute(_, person: let person):
                    
                    knowledge.antiCards[person]?.insert(.roomCard(currentRoom!))
                    knowledge.antiCards[person]?.insert(.playerCard(personToGuess))
                    knowledge.antiCards[person]?.insert(.weaponCard(weaponToGuess))
                    
                    break
                    
                case .suggestionUnrefuted((let person, let weapon, let room)):
                    
                    game.handleAccuse((person: person, weapon: weapon, room: room))
                    
                    break
                    
                case .suggestionDisproved(_, disprover: _):
                    // this is handled with "show"
                    break
                default:
                    fatalError("This should never happen")
                }
            }
        }
        
        
    }
    
    
}
