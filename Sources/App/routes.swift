import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { request async throws in request.redirect(to: "/login") }
    app.get("login", use: UserAuthenticator.renderLoginPage)
    app.post("login", use: UserAuthenticator.login)
    app.get("logout", use: UserAuthenticator.logout)
    
    try app.register(collection: AdminController())
    try app.register(collection: CandidateController())
    try app.register(collection: DeanController())
    try app.register(collection: CFDPresidentController())
    try app.register(collection: TeacherController())
    try app.register(collection: APIDocumentationController())
    try app.register(collection: DebuggerController())
    
    app.get("unauthorised", use: UserAuthenticator.renderUnauthorisedPage)
}
