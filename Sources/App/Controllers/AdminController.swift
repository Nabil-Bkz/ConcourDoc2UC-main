//
//  File.swift
//  
//
//  Created by Wadÿe on 30/04/2023.
//

import Vapor
import Fluent

/// A controller that holds most functionality for admins.
struct AdminController: TypedController {
    let type: UserType = .admin
    
    func boot(routes: RoutesBuilder) throws {
        let controller = routes.grouped("admin")
        controller.get(use: getAllUsers)
        controller.get(":userID", use: getUser)
        controller.post(use: createUser)
        controller.post(":userID", "delete", use: deleteUser)
        controller.put(":userID", "update", use: updateUser)
        controller.post("batchCreate", use: batchCreate)
    }
    
    func getAllUsers(request: Request) async throws -> View {
        let admin = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        let database = request.db
        
        let admins = try await User.query(on: database)
            .filter(\.$type == .admin)
            .all()

        let employees = try await User.query(on: database)
            .filter(\.$type != .admin)
            .filter(\.$type != .candidate)
            .all()

        let candidates = try await User.query(on: database)
            .filter(\.$type == .candidate)
            .all()

        let context = Self.ViewContext(
            connectedAdmin: admin,
            admins: admins,
            employees: employees,
            candidates: candidates
        )
        
        return try await request.view.render("Admin", context)
    }
    
    func getUser(request: Request) async throws -> User {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let userID: UUID = request.parameters.get("userID") else {
            throw Abort(.badRequest, reason: "Could not get parameter: userID from request.")
        }
        
        guard let user = try await User.find(userID, on: request.db) else {
            throw Abort(.notFound, reason: "Could not find the user in the database.")
        }
        
        return user
    }
    
    func createUser(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let userData = try request.content.decode(User.CreateContext.self)
        
        // Validate input
        let sanitizedEmail = ValidationHelper.sanitize(userData.email)
        let sanitizedFirstName = ValidationHelper.sanitize(userData.firstName)
        let sanitizedLastName = ValidationHelper.sanitize(userData.lastName)
        
        guard ValidationHelper.isValidEmail(sanitizedEmail) else {
            request.setFlash(.error, message: "Invalid email format.")
            return request.redirect(to: "/admin")
        }
        
        guard ValidationHelper.isValidName(sanitizedFirstName) && ValidationHelper.isValidName(sanitizedLastName) else {
            request.setFlash(.error, message: "First name and last name are required and must be less than 100 characters.")
            return request.redirect(to: "/admin")
        }
        
        guard ValidationHelper.isValidPassword(userData.password) else {
            request.setFlash(.error, message: "Password must be at least 6 characters long.")
            return request.redirect(to: "/admin")
        }
        
        // Check for duplicate email
        let existingUser = try await User.query(on: request.db)
            .filter(\.$email == sanitizedEmail)
            .first()
        
        if existingUser != nil {
            request.setFlash(.error, message: "A user with this email already exists.")
            return request.redirect(to: "/admin")
        }
        
        let passwordHash = try Bcrypt.hash(userData.password)
        let user = User(
            firstName: sanitizedFirstName,
            lastName: sanitizedLastName,
            email: sanitizedEmail.lowercased(),
            passwordHash: passwordHash,
            type: userData.type
        )
        
        try await user.save(on: request.db)
        
        request.setFlash(.success, message: "User \(sanitizedFirstName) \(sanitizedLastName) created successfully.")
        return request.redirect(to: "/admin")
    }
    
    func updateUser(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let userID: UUID = request.parameters.get("userID") else {
            throw Abort(.badRequest, reason: "Could not get parameter userID from request.")
        }
        
        guard let existingUser = try await User.find(userID, on: request.db) else {
            request.setFlash(.error, message: "User not found.")
            return request.redirect(to: "/admin")
        }
        
        let userData = try request.content.decode(User.UpdateContext.self)
        
        // Validate input
        let sanitizedEmail = ValidationHelper.sanitize(userData.email)
        let sanitizedFirstName = ValidationHelper.sanitize(userData.firstName)
        let sanitizedLastName = ValidationHelper.sanitize(userData.lastName)
        
        guard ValidationHelper.isValidEmail(sanitizedEmail) else {
            request.setFlash(.error, message: "Invalid email format.")
            return request.redirect(to: "/admin")
        }
        
        guard ValidationHelper.isValidName(sanitizedFirstName) && ValidationHelper.isValidName(sanitizedLastName) else {
            request.setFlash(.error, message: "First name and last name are required and must be less than 100 characters.")
            return request.redirect(to: "/admin")
        }
        
        // Check for duplicate email (excluding current user)
        if sanitizedEmail.lowercased() != existingUser.email.lowercased() {
            let duplicateUser = try await User.query(on: request.db)
                .filter(\.$email == sanitizedEmail.lowercased())
                .first()
            
            if duplicateUser != nil {
                request.setFlash(.error, message: "A user with this email already exists.")
                return request.redirect(to: "/admin")
            }
        }
        
        existingUser.firstName = sanitizedFirstName
        existingUser.lastName = sanitizedLastName
        existingUser.email = sanitizedEmail.lowercased()
        existingUser.type = userData.type
        
        try await existingUser.update(on: request.db)
        
        request.setFlash(.success, message: "User updated successfully.")
        return request.redirect(to: "/admin")
    }
    
    func deleteUser(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let userID: UUID = request.parameters.get("userID") else {
            throw Abort(.badRequest, reason: "Could not get userID parameter from request.")
        }
        
        guard let user = try await User.find(userID, on: request.db) else {
            request.setFlash(.error, message: "User not found.")
            return request.redirect(to: "/admin")
        }
        
        let userName = "\(user.firstName) \(user.lastName)"
        
        return try await User.deleteUser(userID, in: request) { request in
            request.setFlash(.success, message: "User \(userName) deleted successfully.")
            return request.redirect(to: "/admin")
        }
    }
    
    func batchCreate(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let usersData = try request.content.decode([User.CSVCreateContext].self)
        
        let users = try usersData.map { try User(context: $0) }
        
        for user in users {
            try await user.save(on: request.db)
        }
        
        return request.redirect(to: "/admin")
    }
}

extension AdminController {
    struct ViewContext: Encodable {
        let connectedAdmin: User
        let admins: [User]
        let employees: [User]
        let candidates: [User]
    }
}
