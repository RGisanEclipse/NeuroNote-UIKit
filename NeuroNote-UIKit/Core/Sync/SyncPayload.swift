//
//  SyncPayload.swift
//  NeuroNote-UIKit
//

import Foundation

// MARK: - Request

struct SyncRequest: Encodable {
    let operations: [SyncOperation]
}

struct SyncOperation: Encodable {
    let type: String
    let payload: SyncMoodPayload
}

struct SyncMoodPayload: Encodable {
    let mood: String
    let reason: String?
    let timestamp: Int64
}

// MARK: - Response

struct SyncResponsePayload: Decodable {
    let results: [SyncResult]
    let processed: Int
    let failed: Int
}

struct SyncResult: Decodable {
    let index: Int
    let success: Bool
    let error: String?
}

typealias SyncAPIResponse = APIResponse<SyncResponsePayload>
