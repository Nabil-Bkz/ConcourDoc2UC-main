//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

struct ModuleMigration: AsyncMigration {
    let schema = Module.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("affiliation_id", .uuid, .required, .references(Affiliation.schema, "id"))
            .field("name", .string, .required)
            .field("factor", .int, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
