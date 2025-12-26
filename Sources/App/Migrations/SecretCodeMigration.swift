//
//  File.swift
//  
//
//  Created by Wadÿe on 05/05/2023.
//

import Vapor
import Fluent

struct SecretCodeMigration: AsyncMigration {
    let schema = SecretCode.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("candidate_id", .uuid, .required, .references(User.schema, "id"))
            .field("content", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
