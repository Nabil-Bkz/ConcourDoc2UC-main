//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

struct ResultMigration: AsyncMigration {
    let schema = Result.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("candidate_id", .uuid, .required, .references(User.schema, "id"))
            .field("value", .float, .required)
            .field("accepted", .bool, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
