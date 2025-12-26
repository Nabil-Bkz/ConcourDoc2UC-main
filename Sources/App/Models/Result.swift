//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

/// A type that encapsulates the final results of a candidate. Determines whether the candidate is accepted or adjourned.
final class Result: Entity {
    static var schema: String = "Result"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "candidate_id")
    var candidate: User
    
    @Field(key: "value")
    var value: Float
    
    @Field(key: "accepted")
    var accepted: Bool
    
    init() { }
    
    init(id: UUID? = nil, candidateID: User.IDValue, value: Float) {
        self.id = id
        self.$candidate.id = candidateID
        self.value = value
        self.accepted = value >= AppConstants.minimumPassingMark
    }
}

extension Result {
    struct Data: Content {
        let id: UUID?
        let ranking: Int
        let firstName: String
        let lastName: String
        let accepted: Bool
        
        init(from result: Result, index: Int) {
            self.id = result.id
            self.ranking = index + 1
            self.firstName = result.candidate.firstName
            self.lastName = result.candidate.lastName
            self.accepted = result.accepted
        }
    }
}
