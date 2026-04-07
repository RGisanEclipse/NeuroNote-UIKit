//
//  Constants.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

import UIKit

struct Constants{
    
    static let empty = ""
    
    struct HTTPFields {
        static let requestId    = "X-Request-Id"
        static let refreshToken = "refreshToken"
        static let userId       = "userId"
    }
    
    struct moodImages {
        
        static let happy  = "happyFace"
        static let feared = "fearedFace"
        static let angry  = "angryFace"
        
    }
    struct animations {
        
        static let angryStar       = "angry-star"
        static let unsureStar      = "unsure-star"
        static let thumbsUp        = "birdie-success"
        static let clouds          = "clouds"
        static let happySun        = "happy-sun"
        static let noWifi          = "no-wifi"
        static let loadingDots     = "loading-dots"
        static let nightSky        = "night-sky"
        static let rotatingMoon    = "rotating-moon"
        static let jetPack         = "jetpack"
        static let plane           = "plane"
        static let otpChair        = "otp-chair"
        static let phonePassword   = "phone-password"
        static let maleAvatar      = "male-avatar"
        static let femaleAvatar    = "female-avatar"
        static let joyfulSky       = "joyful-sky"
        static let happyAlien      = "happy-alien"
        static let alienInRocket   = "alien-in-rocket"
        static let angryAlien      = "angry-alien"
        static let confusedAlien   = "confused-alien"
        static let sadAlien        = "sad-alien"
        static let confetti        = "confetti"
        static let lockSuccess     = "lock-success"
        static let stars           = "stars"
        static let meditatingBrain = "meditating-brain"
        static let emptyBox        = "empty-box"
        static let noInternet      = "no-internet"
    }
    struct LaunchScreenConstants {
        
        static let logoImageName = "NeuroNote"
        
    }
    struct LoginViewControllerConstants {
        
        static let loginBGImageName         = "LoginBG"
        static let helloLabelSignInText     = "Welcome Back!"
        static let helloLabelSignUpText     = "Create Your\nAccount"
        static let toggleButtonToSignUpText = "Don't have an account? Sign up"
        static let toggleButtonToSignInText = "Already have an account? Sign in"
        
    }
    
    struct OTPViewControllerConstants {
        static let titleLabel          = "Prove you're the real one"
        static let messageLabel        = "We've sent an OTP on your email. Look, it’s not that we don’t trust you. Wait, actually, it is. So, OTP please?"
        static let serverError         = "Our server's on a snack break 🍕\n Try again in a bit!"
        static let backgroundImageName = "otpBG"
    }
    
    struct KeychainHelperKeys {
        static let authToken    = "auth_token"
        static let refreshToken = "refresh_token"
        static let userId       = "user_id"
        static let deviceId     = "device_id"
    }
    
    struct Tests {
        static let validEmail    = "a@b.com"
        static let validPassword = "CoolPass1@"
        static let userId        = "12345"
        static let otp           = "1234"
        static let token         = "demoToken"
    }
    
    struct CreatePasswordViewControllerConstants {
        static let titleLabel = "Fresh start, Fresh password ✨"
    }
    
    struct HomeViewControllerConstants {
        static let plusIconImageName      = "plus"
        static let greetingLabelText      = "How was your day?"
        static let prefixLabelText        = "Lately, I feel"
        static let breatheCardTitle       = "Breathe"
        static let breatheCardBottomText  = "Try out a 30 minute guided breathing exercise"
        static let moodLoggingSuccessText = "Mood logged!\nThank you for checking in.🌱"
        static let tileDarkModeColor      = UIColor(red: 0.14, green: 0.13, blue: 0.20, alpha: 1.0)
        static let dominantMoodUnavailablePrefix = "Server has been invaded,\nHang on until we fix it!"
        static let dominantMoodEmptyPrefix       = "Track your moods,\nwe’ll reflect them back to you"
        static let dominantMoodPlaceholder      = "—"
    }
    
    struct Colors {
        static let dashboardLightPurple = UIColor(red: 0.922, green: 0.910, blue: 0.988, alpha: 1.0)
        static let dashboardDarkPurple  = UIColor(red: 0.18, green: 0.15, blue: 0.25, alpha: 1.0)
    }
}
