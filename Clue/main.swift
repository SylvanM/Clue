//
//  main.swift
//  Clue
//
//  Created by Sylvan Martin on 1/2/23.
//

import Foundation

let manifesto: [Person : Int] = [
    .scarlet : 6,
    .green : 6,
    .mustard : 6,
]

let aiCards: [Card] = [
    .weaponCard(.knife),
    .roomCard(.ballroom),
    .weaponCard(.pipe),
    .playerCard(.mustard),
    .roomCard(.billiard),
    .weaponCard(.revolver)
]

let aiKnowledge = Knowledge(asPlayer: .green, players: manifesto, myCards: aiCards)

let players: [Player] = [
    Human("Dummy Human", asCharacter: .mustard),
    Human("Celeste (AI)", asCharacter: .scarlet),
    BasicAI("Sylvan (AI)", withStartingKnowledge: aiKnowledge)
]

let game = Game(players: players)

game.runGame()
