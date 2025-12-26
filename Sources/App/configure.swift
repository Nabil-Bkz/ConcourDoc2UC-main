import Fluent
import Leaf
import Vapor
import FluentSQLiteDriver

// configures your application
public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(FlashMiddleware())

    app.databases.use(.sqlite(.file("EDLApp.sqlite")), as: .sqlite)

    app.migrations.add(UserMigration())
    app.migrations.add(PostMigration())
    app.migrations.add(SecretCodeMigration())
    app.migrations.add(AffiliationMigration())
    app.migrations.add(ModuleMigration())
    app.migrations.add(CopyMigration())
    app.migrations.add(ResultMigration())
    try await app.autoMigrate()

    app.views.use(.leaf)
    
    // register routes
    try routes(app)
}
