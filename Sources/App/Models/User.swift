//
//  File.swift
//  
//
//  Created by Wadÿe on 30/04/2023.
//

import Vapor
import Fluent

/// A structure that represents a user of the application.
final class User: Entity {
    static var schema: String = "User"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "type")
    var type: UserType
    
    init() { }
    
    init(id: UUID? = nil, firstName: String, lastName: String, email: String, passwordHash: String, type: UserType) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.passwordHash = passwordHash
        self.type = type
    }
    
    init(context: CSVCreateContext) throws {
        self.firstName = context.firstName
        self.lastName = context.lastName
        self.email = context.email
        self.passwordHash = try Bcrypt.hash(context.password)
        self.type = .candidate
    }
}

enum UserType: String, Codable {
    case admin = "Admin"
    case cfdPresident = "CFD President"
    case dean = "Dean"
    case teacher = "Teacher"
    case candidate = "Candidate"
}

extension User {
    /// Returns the full name of the user
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    struct CreateContext: Content {
        var firstName: String
        var lastName: String
        var type: UserType
        var email: String
        var password: String
    }
    
    struct AuthenticationContext: Content {
        let email: String
        let password: String
    }
    
    struct UpdateContext: Content {
        var firstName: String
        var lastName: String
        var email: String
        var type: UserType
    }
    
    struct CSVCreateContext: Content {
        var firstName: String
        var lastName: String
        var email: String
        var password: String
    }
}

extension User: SessionAuthenticatable {
    var sessionID: UUID {
        return self.id!
    }
}

extension User {
    static func deleteUser(_ id: UUID, in request: Request, completion: (Request) -> Response) async throws -> Response {
        let database = request.db
        guard let user = try await User.find(id, on: database) else {
            throw Abort(.notFound, reason: "Could not find the user by ID.")
        }
        
        let copies = try await Copy.query(on: database)
            .join(User.self, on: \User.$id == \Copy.$id)
            .group(.or) {
                $0
                    .filter(\.$candidate.$id == id)
                    .filter(\.$teacher1.$id == id)
                    .filter(\.$teacher2.$id == id)
                    .filter(\.$teacher3.$id == id)
            }
            .all()
        for copy in copies {
            try await copy.delete(on: database)
        }
        
        let posts = try await Post.query(on: database)
            .filter(\.$user.$id == id)
            .all()
        for post in posts {
            try await post.delete(on: database)
        }
        
        let secretCodes = try await SecretCode.query(on: database)
            .filter(\.$candidate.$id == id)
            .all()
        for code in secretCodes {
            try await code.delete(on: database)
        }
        
        let results = try await Result.query(on: database)
            .filter(\.$candidate.$id == id)
            .all()
        for result in results {
            try await result.delete(on: database)
        }
        
        try await user.delete(on: database)
        return completion(request)
    }
}
