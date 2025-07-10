//
//  PasswordManager.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation

struct PasswordManager {
    
    static func getCommonPasswords() -> Set<String> {
        return commonPasswords
    }
    
    private static let commonPasswords: Set<String> = [
        "1234567890A1@", "123456789A1@", "access123A1@", "adminadminA1@", "adventureA1@",
        "airplanes1A1@", "aquarius1A1@", "asdfghjkl1A1@", "backspaceA1@", "barracudaA1@",
        "baseball1A1@", "basketballA1@", "blackbearA1@", "blueberryA1@", "butterflyA1@",
        "calculatorA1@", "campfiresA1@", "capricornA1@", "caterpillA1@", "cheese123A1@",
        "chocolate1A1@", "computer1A1@", "donutsrockA1@", "dragon123A1@", "elephant1A1@",
        "firestormA1@", "fireworksA1@", "flower123A1@", "football1A1@", "freedom11A1@",
        "galaxy123A1@", "giraffes1A1@", "goldcoinsA1@", "greentea1A1@", "hamburgerA1@",
        "hello1234A1@", "highscoreA1@", "honeycombA1@", "hottie123A1@", "hoverboardA1@",
        "iloveyou1A1@", "internet1A1@", "joystick1A1@", "keyboard12A1@", "leftarrowA1@",
        "letmein123A1@", "lightningA1@", "magnetronA1@", "marshmallA1@", "matchstickA1@",
        "mechanismA1@", "microwaveA1@", "monkey123A1@", "moonlightA1@", "mountains1A1@",
        "nightmodeA1@", "ninja1234A1@", "octopusesA1@", "password123A1@", "penguins1A1@",
        "pepperoniA1@", "pineappleA1@", "planetx99A1@", "plankton9A1@", "qazwsxedc1A1@",
        "qwerty1234A1@", "rainstormA1@", "raspberryA1@", "robotwarsA1@", "sandstormA1@",
        "scooter11A1@", "shadow123A1@", "skateboardA1@", "snowboardA1@", "snowflakesA1@",
        "spaceshipA1@", "spacesuitA1@", "starlightA1@", "starwars1A1@", "stormwindA1@",
        "strawberrA1@", "sunflowerA1@", "sunglassesA1@", "sunshine1A1@", "superman1A1@",
        "supernovaA1@", "tangerineA1@", "televisionA1@", "thermostatA1@", "trampolineA1@",
        "trustno11A1@", "tumblebeeA1@", "turquoiseA1@", "volleyballA1@", "waterfallA1@",
        "welcome123A1@", "whatever1A1@", "whirlwindA1@", "woodpeckerA1@", "zxcvbnm12A1@"
    ]
}
