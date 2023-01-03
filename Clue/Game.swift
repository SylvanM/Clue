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
 * A suspect or accusation
 */
typealias Statement = (person: Person, weapon: Weapon, room: Room)

/**
 * Represents the state of a game of clue, from a particular player's perspective
 */
class Game {
    
}
