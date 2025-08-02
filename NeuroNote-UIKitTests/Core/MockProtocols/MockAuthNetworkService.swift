//
//  MockAuthNetworkService.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 02/08/25.
//
import Foundation
@testable import NeuroNote_UIKit

class MockAuthNetworkService: AuthNetworkService {
    init(session: NetworkSession) {
        super.init(session: session)
    }
}
