//
//  File.swift
//  
//
//  Created by Wadÿe on 05/05/2023.
//

import Vapor

/// A controller that holds in a user type with it.
protocol TypedController: RouteCollection {
    var type: UserType { get }
}
