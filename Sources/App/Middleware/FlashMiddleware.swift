//
//  FlashMiddleware.swift
//  EDLApplication
//
//  Created during feature implementation
//

import Vapor

/// Flash message types for user feedback
enum FlashType: String, Codable {
    case success
    case error
    case warning
    case info
}

/// Flash message structure
struct FlashMessage: Codable {
    let type: FlashType
    let message: String
}

/// Middleware for flash messages (temporary messages shown to users)
struct FlashMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        
        // Store flash messages in session if they exist
        if let flash = request.flash {
            request.session.data["flash_type"] = flash.type.rawValue
            request.session.data["flash_message"] = flash.message
        }
        
        return response
    }
}

extension Request {
    /// Sets a flash message for the next request
    func setFlash(_ type: FlashType, message: String) {
        session.data["flash_type"] = type.rawValue
        session.data["flash_message"] = message
    }
    
    /// Gets and clears flash message from session
    var flash: FlashMessage? {
        guard let typeString = session.data["flash_type"],
              let type = FlashType(rawValue: typeString),
              let message = session.data["flash_message"] else {
            return nil
        }
        
        // Clear flash after reading
        session.data["flash_type"] = nil
        session.data["flash_message"] = nil
        
        return FlashMessage(type: type, message: message)
    }
}

