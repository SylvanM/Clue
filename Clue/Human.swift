//
//  Human.swift
//  Clue
//
//  Created by Sylvan Martin on 1/3/23.
//

import Foundation

class Human: Player {
    
    var character: Person
    
    var name: String
    
    func canDisprove(_ suggestion: Statement) -> Bool {
        print("Can \(name) disprove this? Enter Y/N: ")
        return readLine()!.lowercased() == "y"
    }
    
    func makeTurn() -> Action {
        print("What is \(name) doing on this turn? (TRAVEL/suggest/accuse)")
        let response = readLine()
        switch response {
        case "suggest":
            print("Please enter the suspicion in the format 'person room weapon'")
            
            guard let suggestion = readStatement(readLine()!) else {
                print("Unable to read input. Starting turn over.")
                return makeTurn()
            }
            
            return .suggest(suggestion)
        case "accuse":
            print("Please enter the accusation in the format 'person room weapon'")
            
            guard let accusation = readStatement(readLine()!) else {
                print("Unable to read input. Starting turn over.")
                return makeTurn()
            }
            
            return .accuse(accusation)
        default:
            return .travel
        }
    }
    
    func show(_ card: Card, from person: Person) {
        print("\(person) shows \(name) the card: \(card)")
    }
    
    required init(_ name: String, asCharacter character: Person) {
        self.name = name
        self.character = character
    }
    
}
