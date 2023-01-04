//
//  main.swift
//  Clue
//
//  Created by Sylvan Martin on 1/2/23.
//

import Foundation

let manifesto: [Person : Int] = [
    .mustard : 6,
    .plum : 6,
    .green : 6,
    .white : 6
]

let aiCards: [Card] = [
    .roomCard(.lounge),
    .roomCard(.billiard),
    .weaponCard(.knife),
    .playerCard(.white),
    .roomCard(.ballroom),
    .weaponCard(.pipe)
]

let aiKnowledge = Knowledge(asPlayer: .white, players: manifesto, myCards: aiCards)

let players: [Player] = [
    Human("Sylvan", asCharacter: .mustard),
    Human("Celeste", asCharacter: .plum),
    Human("Camille", asCharacter: .green),
    RandomAI("Random AI", withStartingKnowledge: aiKnowledge)
]

let game = Game(players: players)

game.runGame()
