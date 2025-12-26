//
//  ValidationHelper.swift
//  EDLApplication
//
//  Created during code improvements
//

import Foundation

/// Helper utilities for input validation
struct ValidationHelper {
    /// Validates email format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// Validates password strength (minimum 6 characters)
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    /// Validates name (non-empty, reasonable length)
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed.count <= 100
    }
    
    /// Sanitizes string input (trims whitespace)
    static func sanitize(_ input: String) -> String {
        return input.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

