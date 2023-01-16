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
    
    var cards: [Card] {
        knowledge.cards[character]!
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
    
    func canDisprove(_: Statement) -> Bool {
        fatalError("This should never be called on a computer player")
    }
    
    func revealCards() -> [Card] {
        cards
    }
    
    func setGame(to game: Game) {
        self.game = game
        knowledge.game = game.gameState
    }
    
    func show(_ card: Card, from person: Person) {
        var i = 0
        
        while knowledge.cards[person]![i] != .unknown { i += 1 }
        
        if knowledge.cards[person]!.indices.contains(i) {
            knowledge.cards[person]![i] = card
        }
        
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
        print("Please enter all the possible rooms that \(name) can go to on this turn. Enter 'none' when done.")
        
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
    var suspiciousRooms: [Room] {
        knowledge.notebook.rooms.filter { (key: Room, value: Knowledge.InformationStatus) in
            value != .ruledOut
        }.map { (key: Room, _) in
            key
        }
    }
    
    /**
     * All the possible weapons still not ruled out
     */
    var suspiciousWeapons: [Weapon] {
        knowledge.notebook.weapons.filter { (key: Weapon, value: Knowledge.InformationStatus) in
            value != .ruledOut
        }.map { (key: Weapon, _) in
            key
        }
    }
    
    /**
     * All the possible people still not ruled out
     */
    var suspiciousPeople: [Person] {
        knowledge.notebook.people.filter { (key: Person, value: Knowledge.InformationStatus) in
            value != .ruledOut
        }.map { (key: Person, _) in
            key
        }
    }
    
    func isSuspicious(_ room: Room) -> Bool {
        suspiciousRooms.contains { $0 == room }
    }
    
    func isSuspicious(_ weapon: Weapon) -> Bool {
        suspiciousWeapons.contains { $0 == weapon }
    }
    
    func isSuspicious(_ person: Person) -> Bool {
        suspiciousPeople.contains { $0 == person }
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
        
        return optionsToShow.randomElement()
    }
    
    func makeTurn() {
        
        // first, if there is only one possible thing, MAKE that accusation!
        
        
        // look at all possibilities for the rooms that are left to guess, and go to that room, if possible.
        if !inSuspiciousRoom() {
            // if there are any overlaps, go to those rooms! If not, indicate that we WANT to go towards one of the suspicious rooms.
            let closeRooms = getCloseRooms()
            
            if let nextRoom = overlap(suspiciousRooms, closeRooms).first {
                game.handleTravel(to: nextRoom, arrived: true)
            } else {
                // we want to travel toward one of the suspicious rooms!
                print("\(name) wants to travel to one of these rooms: \(suspiciousRooms)")
                game.handleTravel()
                return // end of the turn!
            }
        }
        
        // if we are IN one of those rooms, we are right where we need to be!
        switch location {
        case .inRoom(let room):
            
            if isSuspicious(room) {
                // we are right where we need to be! Make a suspicion.
                
                let personToGuess = suspiciousPeople.first!
                let weaponToGuess = suspiciousWeapons.first!
                
                // BasicAI is not smart enough to not giveaway too much information in its suggestions.
                
                game.handleSuspect((person: personToGuess, weapon: weaponToGuess, room: room)) { notableEvent in
                    switch notableEvent {
                        
                    case .couldntRefute(_, person: let person):
                        
                        // handle this
                        
                        break
                        
                    case .suggestionUnrefuted((let person, let weapon, let room)):
                        
                        // handle this
                        
                        break
                        
                    case .suggestionDisproved(_, disprover: let disprover):
                        // this is handled with "show"
                        break
                    default:
                        fatalError("This should never happen")
                    }
                }
                
            } else {
                // we've already dealt with this scenerio.
                break
            }
            
        case .walking:
            break
        }
        
        
    }
    
    
}
