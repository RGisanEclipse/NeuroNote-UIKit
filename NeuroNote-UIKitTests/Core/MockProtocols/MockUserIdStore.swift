//
//  MockUserIdStore.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 20/07/25.
//

import Foundation
@testable import NeuroNote_UIKit

class MockUserIDStore: UserIDStore {
    var userIdToReturn: String?

    func getUserID() -> String? {
        return userIdToReturn ?? UUID().uuidString
    }
}
