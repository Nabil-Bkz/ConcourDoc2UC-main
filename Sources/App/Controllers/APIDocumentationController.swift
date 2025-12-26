//
//  APIDocumentationController.swift
//  EDLApplication
//
//  Created during feature implementation
//

import Vapor

/// Controller for API documentation
struct APIDocumentationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let apiDocs = routes.grouped("api", "docs")
        apiDocs.get(use: getDocumentation)
        apiDocs.get("json", use: getJSONDocumentation)
    }
    
    func getDocumentation(request: Request) async throws -> View {
        let documentation = generateDocumentation()
        return try await request.view.render("api_documentation", documentation)
    }
    
    func getJSONDocumentation(request: Request) async throws -> Response {
        let documentation = generateDocumentation()
        return try await documentation.encodeResponse(for: request)
    }
    
    private func generateDocumentation() -> APIDocumentation {
        return APIDocumentation(
            title: "EDL Application API Documentation",
            version: "1.0.0",
            description: "API documentation for the Doctorate Contest Management System",
            endpoints: [
                APIEndpoint(
                    method: "POST",
                    path: "/login",
                    description: "Authenticate user and create session",
                    parameters: [
                        APIParameter(name: "email", type: "String", required: true, description: "User email address"),
                        APIParameter(name: "password", type: "String", required: true, description: "User password")
                    ],
                    response: "Redirects to role-specific dashboard"
                ),
                APIEndpoint(
                    method: "GET",
                    path: "/admin",
                    description: "Get all users (Admin only)",
                    authentication: "Required - Admin role",
                    response: "View with all users grouped by type"
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/admin",
                    description: "Create new user (Admin only)",
                    authentication: "Required - Admin role",
                    parameters: [
                        APIParameter(name: "firstName", type: "String", required: true),
                        APIParameter(name: "lastName", type: "String", required: true),
                        APIParameter(name: "email", type: "String", required: true),
                        APIParameter(name: "password", type: "String", required: true),
                        APIParameter(name: "type", type: "UserType", required: true)
                    ]
                ),
                APIEndpoint(
                    method: "GET",
                    path: "/candidate",
                    description: "Get candidate dashboard with posts and results",
                    authentication: "Required - Candidate role",
                    response: "View with posts and results"
                ),
                APIEndpoint(
                    method: "GET",
                    path: "/dean",
                    description: "Get dean dashboard with posts",
                    authentication: "Required - Dean role",
                    response: "View with dean's posts"
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/dean/new-post",
                    description: "Create new announcement post",
                    authentication: "Required - Dean role",
                    parameters: [
                        APIParameter(name: "title", type: "String", required: true),
                        APIParameter(name: "content", type: "String", required: true),
                        APIParameter(name: "link", type: "String", required: false)
                    ]
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/dean/assign-code/:candidateID",
                    description: "Assign secret code to candidate",
                    authentication: "Required - Dean role",
                    parameters: [
                        APIParameter(name: "candidateID", type: "UUID", required: true, path: true)
                    ]
                ),
                APIEndpoint(
                    method: "GET",
                    path: "/teacher",
                    description: "Get assigned examination copies",
                    authentication: "Required - Teacher role",
                    response: "View with assigned copies"
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/teacher",
                    description: "Submit marks for assigned copies",
                    authentication: "Required - Teacher role",
                    parameters: [
                        APIParameter(name: "marks", type: "[Copy.JSON.TeacherPerspective]", required: true)
                    ]
                ),
                APIEndpoint(
                    method: "GET",
                    path: "/cfd-president/copies/marked",
                    description: "Get all marked copies with final results",
                    authentication: "Required - CFD President role",
                    response: "View with marked copies"
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/cfd-president/copies/unmarked",
                    description: "Assign teachers to unmarked copies",
                    authentication: "Required - CFD President role",
                    parameters: [
                        APIParameter(name: "copyID", type: "UUID", required: true),
                        APIParameter(name: "teacher1ID", type: "UUID", required: true),
                        APIParameter(name: "teacher2ID", type: "UUID", required: true)
                    ]
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/cfd-president/copies/third-teacher",
                    description: "Assign third teacher for disagreement resolution",
                    authentication: "Required - CFD President role",
                    parameters: [
                        APIParameter(name: "copyID", type: "UUID", required: true),
                        APIParameter(name: "teacher3ID", type: "UUID", required: true)
                    ]
                ),
                APIEndpoint(
                    method: "POST",
                    path: "/cfd-president/copies/marked/publish",
                    description: "Publish final results and calculate averages",
                    authentication: "Required - CFD President role",
                    response: "Publishes results and sends notifications"
                )
            ]
        )
    }
}

// MARK: - Documentation Models

struct APIDocumentation: Content {
    let title: String
    let version: String
    let description: String
    let endpoints: [APIEndpoint]
}

struct APIEndpoint: Content {
    let method: String
    let path: String
    let description: String
    let authentication: String?
    let parameters: [APIParameter]?
    let response: String?
    
    init(method: String, path: String, description: String, authentication: String? = nil, parameters: [APIParameter]? = nil, response: String? = nil) {
        self.method = method
        self.path = path
        self.description = description
        self.authentication = authentication
        self.parameters = parameters
        self.response = response
    }
}

struct APIParameter: Content {
    let name: String
    let type: String
    let required: Bool
    let description: String?
    let path: Bool?
    
    init(name: String, type: String, required: Bool, description: String? = nil, path: Bool? = nil) {
        self.name = name
        self.type = type
        self.required = required
        self.description = description
        self.path = path
    }
}

