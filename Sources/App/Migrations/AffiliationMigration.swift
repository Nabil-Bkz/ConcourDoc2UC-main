//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

struct AffiliationMigration: AsyncMigration {
    let schema = Affiliation.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
