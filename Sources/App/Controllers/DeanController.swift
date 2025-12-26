//
//  File.swift
//  
//
//  Created by Wadÿe on 08/05/2023.
//

import Vapor
import Fluent

struct DeanController: TypedController {
    let type: UserType = .dean
    
    func boot(routes: RoutesBuilder) throws {
        let controller = routes.grouped("dean")
        controller.get(use: getPosts)
        controller.get("secret-codes", use: getSecretCodes)
        controller.get("assign-code", use: getAssignCodesView)
        controller.get("new-post", use: renderNewPostView)
        controller.post("new-post", use: createPost)
        controller.post("assign-code", ":candidateID", use: assignSecretCode)
        controller.post(":postID", "delete", use: deletePost)
    }
    
    func getPosts(request: Request) async throws -> View {
        let dean = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let deanID = dean.id else {
            throw Abort(.internalServerError, reason: "Dean ID is missing.")
        }
        
        let allPosts = try await Post.query(on: request.db)
            .with(\.$user)
            .filter(\.$user.$id == deanID)
            .sort(\.$postedAt)
            .all()
            .reversed()
        
        let posts = allPosts.map { Post.Data(from: $0) }
        
        let context = DeanController.ViewContext.Posts(dean: dean, posts: posts)
        
        return try await request.view.render("my_post", context)
    }
    
    func renderNewPostView(request: Request) async throws -> View {
        let dean = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        return try await request.view.render("new_post", DeanController.ViewContext.NewPost(dean: dean))
    }
    
    func createPost(request: Request) async throws -> Response {
        let dean = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let deanID = dean.id else {
            throw Abort(.internalServerError, reason: "Dean ID is missing.")
        }
        
        let postData = try request.content.decode(Post.CreateContext.self)
        
        // Validate input
        let sanitizedTitle = ValidationHelper.sanitize(postData.title)
        let sanitizedContent = ValidationHelper.sanitize(postData.content)
        
        guard !sanitizedTitle.isEmpty && sanitizedTitle.count <= 200 else {
            request.setFlash(.error, message: "Title is required and must be less than 200 characters.")
            return request.redirect(to: "/dean/new-post")
        }
        
        guard !sanitizedContent.isEmpty else {
            request.setFlash(.error, message: "Content is required.")
            return request.redirect(to: "/dean/new-post")
        }
        
        let sanitizedLink = postData.link.map { ValidationHelper.sanitize($0) }
        let post = Post(userID: deanID, title: sanitizedTitle, content: sanitizedContent, link: sanitizedLink)
        try await post.save(on: request.db)
        
        request.setFlash(.success, message: "Post created successfully.")
        return request.redirect(to: "/dean")
    }
    
    func getSecretCodes(request: Request) async throws -> View {
        let dean = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allSecretCodes = try await SecretCode.query(on: request.db)
            .with(\.$candidate)
            .all()
        
        let secretCodes = allSecretCodes.map { SecretCode.Data(from: $0) }
        
        let context = DeanController.ViewContext.SecretCodes(dean: dean, secretCodes: secretCodes)
        
        return try await request.view.render("secret_code", context)
    }
    
    func getAssignCodesView(request: Request) async throws -> View {
        let dean = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allCandidates = try await User.query(on: request.db)
            .filter(\.$type == .candidate)
            .all()
        
        let candidatesWithCodes = try await User.query(on: request.db)
            .join(SecretCode.self, on: \User.$id == \SecretCode.$candidate.$id)
            .all()
            .compactMap { $0.id }
        
        let candidatesWithoutCodes = allCandidates.filter { candidate in
            guard let candidateID = candidate.id else { return false }
            return !candidatesWithCodes.contains(candidateID)
        }
        
        let context = DeanController.ViewContext.AssignSecretCodes(dean: dean, candidates: candidatesWithoutCodes)
        
        return try await request.view.render("generate_code", context)
    }
    
    func assignSecretCode(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let candidateID: UUID = request.parameters.get("candidateID") else {
            throw Abort(.badRequest, reason: "Could not get parameter candidateID from request.")
        }
        
        guard let candidate = try await User.find(candidateID, on: request.db) else {
            request.setFlash(.error, message: "Candidate not found.")
            return request.redirect(to: "/dean/assign-code")
        }
        
        let existingCodesArray = try await SecretCode.query(on: request.db)
            .all()
            .map { $0.content }
        var existingCodes = Set(existingCodesArray)
        
        let codeGenerator = SWCodeGenerator(length: AppConstants.secretCodeLength)
        let content = try codeGenerator.generate(considering: &existingCodes)
        
        let secretCode = SecretCode(candidateID: candidateID, content: content)
        try await secretCode.save(on: request.db)
        
        // Send notification email
        try? await NotificationService.notifySecretCodeAssigned(
            candidateEmail: candidate.email,
            candidateName: candidate.fullName,
            secretCode: content,
            on: request
        )
        
        request.setFlash(.success, message: "Secret code assigned successfully to \(candidate.firstName) \(candidate.lastName).")
        return request.redirect(to: "/dean/assign-code")
    }
    
    func deletePost(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let postID: UUID = request.parameters.get("postID") else {
            throw Abort(.badRequest, reason: "Could not get parameter postID from request.")
        }
        
        guard let post = try await Post.find(postID, on: request.db) else {
            request.setFlash(.error, message: "Post not found.")
            return request.redirect(to: "/dean")
        }
        
        try await post.delete(on: request.db)
        
        request.setFlash(.success, message: "Post deleted successfully.")
        return request.redirect(to: "/dean")
    }
}

extension DeanController {
    enum ViewContext {
        struct Posts: Encodable {
            let dean: User
            let posts: [Post.Data]
        }
        
        struct SecretCodes: Encodable {
            let dean: User
            let secretCodes: [SecretCode.Data]
        }
        
        struct NewPost: Encodable {
            let dean: User
        }
        
        struct AssignSecretCodes: Encodable {
            let dean: User
            let candidates: [User]
        }
    }
}
