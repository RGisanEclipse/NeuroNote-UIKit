//
//  MockAuthNetworkService.swift
//  AVYO
//
//  Created by Eclipse on 02/08/25.
//
import Foundation
@testable import NeuroNote_UIKit

class MockAuthNetworkService: NetworkService {
    init(session: NetworkSession) {
        super.init(session: session)
    }
}
