//
//  LoginViewModelTests.swift
//  NeuroNote
//
//  Created by Eclipse on 09/07/25.
//

import XCTest
@testable import NeuroNote_UIKit

final class LoginViewModelTests: XCTestCase {

    @MainActor func testForgotPasswordShowsExpectedAlert() {
        let viewModel = LoginViewModel()
        var receivedAlert: AlertContent?

        viewModel.onMessage = { receivedAlert = $0 }

        viewModel.forgotPasswordButtonTapped(email: "test@example.com")

        XCTAssertEqual(receivedAlert?.title, "Forgot Password?")
        XCTAssertEqual(receivedAlert?.message, "Don't worry, we've got you!")
        XCTAssertEqual(receivedAlert?.animationName, Constants.animations.unsureStar)
        XCTAssertFalse(receivedAlert?.shouldBeRed ?? true)
    }

    @MainActor func testSignInFailsIfFieldsAreEmpty() {
        let viewModel = LoginViewModel()
        var alert: AlertContent?

        viewModel.onMessage = { alert = $0 }

        viewModel.signInButtonTapped(
            email: Constants.empty,
            password: Constants.empty,
            confirmPassword: nil,
            mode: .login
        )

        XCTAssertEqual(alert?.title, AuthAlert.fieldsMissing.title)
    }

    @MainActor func testSignUpFailsIfPasswordsDontMatch() {
        let viewModel = LoginViewModel()
        var alert: AlertContent?

        viewModel.onMessage = { alert = $0 }

        viewModel.signInButtonTapped(
            email: Constants.Tests.validEmail,
            password: "123",
            confirmPassword: "456",
            mode: .signup
        )

        XCTAssertEqual(alert?.title, AuthAlert.passwordMismatch.title)
    }
    
    @MainActor
    func testServerErrorShowsCorrectAlert() {
        let mock = MockAuthManager()
        mock.shouldThrowServerError = true

        let viewModel = LoginViewModel(authManager: mock)
        let expectation = XCTestExpectation(description: "Server error alert received")

        var alert: AlertContent?

        viewModel.onMessage = {
            alert = $0
            expectation.fulfill()
        }

        viewModel.signInButtonTapped(
            email: "neuronotetests@gmail.com",
            password: "CoolPass1@",
            confirmPassword: "CoolPass1@",
            mode: .signup
        )

        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(alert?.title, AuthAlert.internalServerError.title)
    }
    
    @MainActor
    func testUnknownErrorShowsDefaultAlert() {
        let mock = MockAuthManager()
        mock.shouldThrowUnknownError = true

        let viewModel = LoginViewModel(authManager: mock)
        let expectation = XCTestExpectation(description: "Unknown error alert received")

        var alert: AlertContent?

        viewModel.onMessage = {
            alert = $0
            expectation.fulfill()
        }

        viewModel.signInButtonTapped(
            email: "neuronotetests@gmail.com",
            password: "CoolPass1@",
            confirmPassword: "CoolPass1@",
            mode: .signup
        )

        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(alert?.title, AuthAlert.unknown.title)
    }
    
    @MainActor func testSignUpFailsIfConfirmPasswordIsNil() {
        
        let viewModel = LoginViewModel()
        var alert: AlertContent?

        viewModel.onMessage = { alert = $0 }

        viewModel.signInButtonTapped(
            email: Constants.Tests.validEmail,
            password: "123",
            confirmPassword: nil,
            mode: .signup
        )

        XCTAssertEqual(alert?.title, AuthAlert.passwordMismatch.title)
    }
}
