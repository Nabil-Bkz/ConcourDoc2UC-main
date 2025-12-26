//
//  File.swift
//  
//
//  Created by Wadÿe on 04/05/2023.
//

import Vapor
import Fluent

struct PostMigration: AsyncMigration {
    let schema = Post.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("dean_id", .uuid, .required, .references(User.schema, "id"))
            .field("title", .string, .required)
            .field("content", .string, .required)
            .field("link", .string)
            .field("posted_at", .date, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
