//
//  File.swift
//  
//
//  Created by Wadÿe on 06/05/2023.
//

import Vapor
import Fluent

/// Represents a module (a subject) that belongs to a certain affiliation, with a title and a factor.
final class Module: Entity {
    static var schema: String = "Module"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "affiliation_id")
    var affiliation: Affiliation
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "factor")
    var factor: Int
    
    init() { }
    
    init(id: UUID? = nil, affiliationID: Affiliation.IDValue, name: String, factor: Int) {
        self.id = id
        self.$affiliation.id = affiliationID
        self.name = name
        self.factor = factor
    }
}
