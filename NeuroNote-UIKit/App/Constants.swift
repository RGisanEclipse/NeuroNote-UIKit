//
//  Constants.swift
//  NeuroNote
//
//  Created by Eclipse on 29/06/25.
//

struct Constants{
    
    static let empty = ""
    
    struct moodImages{
        
        static let happy  = "happyFace"
        static let feared = "fearedFace"
        static let angry  = "angryFace"
        
    }
    
    struct LaunchScreenConstants{
        
        static let logoImageName = "NeuroNote"
        
    }
    struct LoginViewControllerConstants{
        
        static let loginBGImageName = "LoginBG"
        static let helloLabelSignInText = "Hello\nSign in!"
        static let helloLabelSignUpText = "Create Your\nAccount"
        static let toggleButtonToSignUpText = "Don't have an account? Sign up"
        static let toggleButtonToSignInText = "Already have an account? Sign in"
        
    }
    
    struct KeychainHelperKeys{
        static let authToken = "auth_token"
    }
}
