//
//  MoodManagerProtocol.swift
//  AVYO
//
//  Created by Eclipse on 04/01/26.
//


protocol MoodManagerProtocol{
    func logMood(with data: MoodLogData) async throws
}
