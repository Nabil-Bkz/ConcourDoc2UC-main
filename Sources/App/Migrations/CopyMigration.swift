//
//  File.swift
//  
//
//  Created by Wadÿe on 23/05/2023.
//

import Vapor
import Fluent

struct CopyMigration: AsyncMigration {
    let schema = Copy.schema
    let usersSchema = User.schema
    let modulesSchema = Module.schema
    let secretCodesSchema = SecretCode.schema
    
    func prepare(on database: Database) async throws {
        try await database.schema(schema)
            .id()
            .field("candidate_id", .uuid, .required, .references(usersSchema, "id"))
            .field("secret_code_id", .uuid, .required, .references(secretCodesSchema, "id"))
            .field("module_id", .uuid, .required, .references(modulesSchema, "id"))
            .field("teacher1_id", .uuid, .references(usersSchema, "id"))
            .field("teacher2_id", .uuid, .references(usersSchema, "id"))
            .field("teacher3_id", .uuid, .references(usersSchema, "id"))
            .field("mark1", .float)
            .field("mark2", .float)
            .field("mark3", .float)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(schema).delete()
    }
}
