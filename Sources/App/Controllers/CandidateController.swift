//
//  File.swift
//  
//
//  Created by Wadÿe on 06/05/2023.
//

import Vapor
import Fluent

struct CandidateController: TypedController {
    let type: UserType = .candidate
    
    func boot(routes: RoutesBuilder) throws {
        let controller = routes.grouped("candidate")
        controller.get(use: getData)
        // Operations...
    }
    
    func getData(request: Request) async throws -> View {
        let candidate = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allPosts = try await Post.query(on: request.db)
            .with(\.$user)
            .all()
            .reversed()
        
        let allResults = try await Result.query(on: request.db)
            .with(\.$candidate)
            .sort(\.$value, .descending)
            .all()
        
        let posts = allPosts.map { Post.Data(from: $0) }
        
        let results = allResults.enumerated().map { index, result in
            Result.Data(from: result, index: index)
        }
        
        let context = CandidateController.ViewContext(candidate: candidate, posts: posts, results: results)
        return try await request.view.render("Candidate", context)
    }
}

extension CandidateController {
    struct ViewContext: Encodable {
        let candidate: User
        let posts: [Post.Data]
        let results: [Result.Data]
    }
}
