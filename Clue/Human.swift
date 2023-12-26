//
//  Human.swift
//  Clue
//
//  Created by Sylvan Martin on 1/3/23.
//

import Foundation

class Human: Player {
    
    // MARK: Properties
    
    var game: Game!
    
    var character: Person
    
    var name: String
    
    // MARK: Initializers
    
    required init(_ name: String, asCharacter character: Person) {
        self.name = name
        self.character = character
    }
    
    // MARK: Housekeeping
    
    func setGame(to game: Game) {
        self.game = game
    }
    
    func receive(_: Event) {
        // do nothing
    }
    
    func show(_ card: Card, from person: Person) {
        print("\(person) shows \(name) the card: \(card)")
    }
    
    func revealCards() -> Set<Card> {
        var cards: Set<Card> = []
        var input: String
        
        print("Please enter all of \(name)'s cards separated by lines. enter 'done' when done.")
        
        repeat {
            input = readLine()!.lowercased()
            if let card = Card(input) {
                cards.insert(card)
            } else {
                print("Please enter that card again.")
                continue
            }
        } while input != "done"
        
        return cards
    }
    
    // MARK: Gameplay
    
    func disprove(_ suggestion: Statement) -> Card? {
        print("What card does \(name) show to disprove this? (enter card, or enter 'none')")
        return Card(readLine()!)
    }
    
    func canDisprove(_ suggestion: Statement) -> Bool {
        print("Can \(name) disprove this? Enter Y/N: ")
        return readLine()!.lowercased() == "y"
    }
    
    func makeTurn() {
        var input: String
        
        print("It is now \(character)'s (\(name)'s) turn. ", terminator: "")
        
        repeat {
            print("Enter \(name)'s next action. (suggest/accuse/travel/done)")
            
            input = readLine()!
            
            switch input {
            case "suggest":
                
                print("Please enter \(name)'s suggestion in the format 'person room weapon'")
                
                var suggestionInput: String
                var statement: Statement? = nil
                
                repeat {
                    suggestionInput = readLine()!
                    statement = readStatement(suggestionInput)
                    if statement == nil {
                        print("Please enter that statement again.")
                    }
                } while statement == nil
                
                game.handleSuspect(statement!, completion: nil)
                
            case "accuse":
                
                print("Please enter \(name)'s accusation in the format 'person room weapon'")
                
                var suggestionInput: String
                var statement: Statement? = nil
                
                repeat {
                    suggestionInput = readLine()!
                    statement = readStatement(suggestionInput)
                    if statement == nil {
                        print("Unrecognized input. Please enter the accusation again.")
                    }
                } while statement == nil
                
                game.handleAccuse(statement!)
                
            case "travel":
                
                print("enter the final destination of \(character). Either '<room>', or anything else will be interpreted as just walking around.")
                
                if let room = Room(readLine()!) {
                    game.handleTravel(to: room, arrived: true)
                } else {
                    game.handleTravel()
                }
                
            case "done":
                return
            default:
                print("Unrecognized input '\(input)', try again.")
            }
            
        } while input != "done"
    }
    
}
