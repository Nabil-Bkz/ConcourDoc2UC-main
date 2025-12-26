//
//  File.swift
//  
//
//  Created by Wadÿe on 05/05/2023.
//

import Vapor
import Fluent

/// A structure that represents a candidate's secret code (used for anonymity).
final class SecretCode: Entity {
    static var schema: String = "SecretCode"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "candidate_id")
    var candidate: User
    
    @Field(key: "content")
    var content: String
    
    init() { }
    
    /// Creates a new secret code for a candidate.
    init(id: UUID? = nil, candidateID: User.IDValue, content: String) {
        self.id = id
        self.$candidate.id = candidateID
        self.content = content
    }
    
    /// Creates a new secret code for a candidate with an automatically generated content (for testing only).
    init(id: UUID? = nil, candidateID: User.IDValue) {
        self.id = id
        self.$candidate.id = candidateID
        self.content = try! SWCodeGenerator(length: 4).generate()
    }
}

extension SecretCode {
    struct Data: Content {
        let firstName: String
        let lastName: String
        let content: String
        
        init(from secretCode: SecretCode) {
            self.firstName = secretCode.candidate.firstName
            self.lastName = secretCode.candidate.lastName
            self.content = secretCode.content
        }
    }
}
