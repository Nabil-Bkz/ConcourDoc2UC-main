//
//  File.swift
//  
//
//  Created by Wadÿe on 30/04/2023.
//

import Vapor
import Fluent

struct UserMigration: AsyncMigration {
    let schema = User.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("first_name", .string, .required)
            .field("last_name", .string, .required)
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("type", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
