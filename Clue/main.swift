//
//  main.swift
//  Clue
//
//  Created by Sylvan Martin on 1/2/23.
//

import Foundation

let players = [
    Human("Sylvan", asCharacter: .mustard),
    Human("Celeste", asCharacter: .plum),
    Human("Camille", asCharacter: .green),
]

let game = Game(players: players)

game.runGame()
