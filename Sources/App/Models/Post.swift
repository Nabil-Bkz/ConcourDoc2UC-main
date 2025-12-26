//
//  File.swift
//  
//
//  Created by Wadÿe on 04/05/2023.
//

import Vapor
import Fluent

/// A structure that represents a post that can be made by a dean.
final class Post: Entity {
    static var schema: String = "Post"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "dean_id")
    var user: User
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String
    
    @OptionalField(key: "link")
    var link: String?
    
    @Timestamp(key: "posted_at", on: .create)
    var postedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, userID: User.IDValue, title: String, content: String, link: String? = nil, postedAt: Date? = nil) {
        self.id = id
        self.$user.id = userID
        self.title = title
        self.content = content
        self.link = link
        self.postedAt = postedAt
    }
}

extension Post {
    struct Data: Content {
        let id: UUID?
        let title: String
        let content: String
        let link: String?
        let userFullName: String
        let date: String
        
        init(from post: Post) {
            self.id = post.id
            self.title = post.title
            self.content = post.content
            self.link = post.link
            self.userFullName = "\(post.user.firstName) \(post.user.lastName)"
            self.date = post.postedAt?.formatted() ?? "N/A"
        }
    }
    
    struct CreateContext: Content {
        let title: String
        let content: String
        let link: String?
    }
}
