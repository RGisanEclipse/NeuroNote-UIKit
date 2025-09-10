//
//  Constants.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

struct Constants{
    
    static let empty = ""
    
    struct HTTPFields{
        static let requestId = "X-Request-Id"
        static let refreshToken = "refreshToken"
    }
    
    struct moodImages{
        
        static let happy  = "happyFace"
        static let feared = "fearedFace"
        static let angry  = "angryFace"
        
    }
    struct animations{
        
        static let angryStar = "angry-star"
        static let unsureStar = "unsure-star"
        static let thumbsUp = "birdie-success"
        static let clouds = "clouds"
        static let happySun = "happy-sun"
        static let noWifi = "no-wifi"
        static let loadingDots = "loading-dots"
        static let nightSky = "night-sky"
        static let rotatingMoon = "rotating-moon"
        static let jetPack = "jetpack"
        static let plane = "plane"
        static let otpChair = "otp-chair"
    }
    struct LaunchScreenConstants{
        
        static let logoImageName = "NeuroNote"
        
    }
    struct LoginViewControllerConstants{
        
        static let loginBGImageName = "LoginBG"
        static let helloLabelSignInText = "Welcome Back!"
        static let helloLabelSignUpText = "Create Your\nAccount"
        static let toggleButtonToSignUpText = "Don't have an account? Sign up"
        static let toggleButtonToSignInText = "Already have an account? Sign in"
        
    }
    
    struct OTPViewControllerConstants{
        static let titleLabel = "We Just Met"
        static let messageLabel = "We've sent an OTP on your email. Look, it’s not that we don’t trust you. Wait, actually, it is. So, OTP please?"
        static let serverError = "Our server's on a snack break 🍕\n Try again in a bit!"
        static let backgroundImageName = "otpBG"
    }
    
    struct KeychainHelperKeys{
        static let authToken = "auth_token"
        static let refreshToken = "refresh_token"
        static let userId    = "user_id"
    }
    
    struct Tests{
        static let validEmail = "a@b.com"
        static let validPassword = "CoolPass1@"
        static let userId = "12345"
        static let otp = "1234"
        static let token = "demoToken"
    }
}
