//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

/// A type that represents an identifiable, representable, and persistable structure in the app.
protocol Entity: Model, Content {
    var id: UUID? { get set }
}
