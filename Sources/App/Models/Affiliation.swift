//
//  File.swift
//  
//
//  Created by Wadÿe on 06/05/2023.
//

import Vapor
import Fluent

final class Affiliation: Entity {
    static var schema: String = "Affiliation"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    init() { }
    
    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
