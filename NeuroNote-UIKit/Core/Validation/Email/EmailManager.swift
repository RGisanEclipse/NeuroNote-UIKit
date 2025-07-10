//
//  EmailManager.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import Foundation

struct EmailManager {
    
    static func isCommonEmail(_ email: String) -> Bool {
        return commonEmails.contains(email)
    }
    
    private static let commonEmails: Set<String> = [
        "123456789@gmail.com", "qwerty123@gmail.com", "letmein123@gmail.com", "iloveyou1@gmail.com",
        "adminadmin@gmail.com", "password123@gmail.com", "football1@gmail.com", "baseball1@gmail.com",
        "monkey123@gmail.com", "welcome123@gmail.com", "sunshine1@gmail.com", "princess1@gmail.com",
        "dragon123@gmail.com", "freedom11@gmail.com", "starwars1@gmail.com", "superman1@gmail.com",
        "trustno11@gmail.com", "computer1@gmail.com", "internet1@gmail.com", "keyboard12@gmail.com",
        "zxcvbnm12@gmail.com", "asdfghjkl1@gmail.com", "joystick1@gmail.com", "galaxy123@gmail.com",
        "penguins1@gmail.com", "giraffes1@gmail.com", "donutsrock@gmail.com", "robotwars@gmail.com",
        "fireworks1@gmail.com", "moonlight1@gmail.com", "hamburger1@gmail.com", "shadow123@gmail.com",
        "ninja1234@gmail.com", "skateboard1@gmail.com", "snowboard1@gmail.com", "spaceship1@gmail.com",
        "rainstorm1@gmail.com", "greentea1@gmail.com", "goldcoins1@gmail.com", "letmeinagain@gmail.com",
        "notarealemail123@gmail.com", "fakename2023@gmail.com", "junkaccount01@gmail.com", "throwawayacc@gmail.com",
        "thisisfake99@gmail.com", "testuserdemo@gmail.com", "idontcare123@gmail.com", "dontreplymepls@gmail.com",
        "noinboxforme@gmail.com", "youllneverguess@gmail.com", "whyareyoureadingthis@gmail.com", "iamnotabotlol@gmail.com",
        "temporaryhuman@gmail.com", "iamfakeaccount@gmail.com", "stopreadingme@gmail.com", "guessmeifucan@gmail.com",
        "unknownperson99@gmail.com", "nothingtoseehere@gmail.com", "fakemailhere@gmail.com", "burnermail321@gmail.com",
        "useanothertest@gmail.com", "fakebot999@gmail.com", "disposable123@gmail.com", "accountforspam@gmail.com",
        "nomailneeded@gmail.com", "notmyrealname@gmail.com", "yougotbamboozled@gmail.com", "nooneusesme@gmail.com",
        "forgetmequick@gmail.com", "ignorethispls@gmail.com", "usedonceonly@gmail.com", "notseriousacc@gmail.com",
        "totallylegituser@gmail.com", "donotsendmeanything@gmail.com", "definitelynotreal@gmail.com",
        "thisemailisfake@gmail.com", "whoevenami@gmail.com", "john.doe.fake123@gmail.com", "emailnotfound@gmail.com",
        "autobot999@gmail.com", "throwawaymail987@gmail.com", "rejectedemail01@gmail.com", "iamghost@gmail.com",
        "expiredlogin99@gmail.com", "fakenameforreal@gmail.com", "anonymoustroll01@gmail.com", "cheateralert99@gmail.com",
        "spamoverflow01@gmail.com", "donttextmepls@gmail.com", "botaccount111@gmail.com", "sneakyemail321@gmail.com"
    ]
}
