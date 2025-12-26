//
//  Constants.swift
//  EDLApplication
//
//  Created during refactoring
//

import Foundation

/// Application-wide constants
enum AppConstants {
    /// Minimum mark difference threshold for requiring a third teacher
    static let markDifferenceThreshold: Float = 3.0
    
    /// Minimum passing mark for candidate acceptance
    static let minimumPassingMark: Float = 10.0
    
    /// Secret code length for candidate anonymity
    static let secretCodeLength: Int8 = 4
    
    /// Number of modules required per candidate
    static let requiredModulesPerCandidate: Int = 2
    
    /// Result calculation multiplier
    static let resultCalculationMultiplier: Float = 2.0 / 3.0
}

/// Session keys for user authentication
enum SessionKeys {
    static let userId = "user_id"
    static let firstName = "first_name"
    static let lastName = "last_name"
    static let userType = "type"
}

