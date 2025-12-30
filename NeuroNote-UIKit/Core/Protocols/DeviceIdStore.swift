//
//  DeviceIdStore.swift
//  NeuroNote-UIKit
//
//  Created by Eclipse on 30/12/25.
//

protocol DeviceIdStore {
    func getOrCreateDeviceId() -> String
}
