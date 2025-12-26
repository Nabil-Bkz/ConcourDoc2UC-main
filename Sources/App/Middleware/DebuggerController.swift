//
//  File.swift
//  
//
//  Created by Wadÿe on 25/05/2023.
//

import Vapor
import Fluent

struct DebuggerController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let debugger = routes.grouped("debug")
        debugger.post("populatedb", "users", use: populateDBWithUsers)
        debugger.post("populatedb", "posts", use: populateDBWithPosts)
        debugger.post("populatedb", "results", use: populateDBWithResults)
        debugger.post("populatedb", "secretCodes", use: populateDBWithSecretCodes)
        debugger.post("populatedb", "affiliations", use: populateDBWithAffiliations)
        debugger.post("populatedb", "modules", use: populateDBWithModules)
        debugger.post("populatedb", "copies", use: populateDBWithCopies)
        debugger.post("populatedb", use: populateDBWithEverything)
        debugger.post("test", use: test)
        debugger.post("startOver", use: startOver)
    }
    
    func populateDBWithEverything(request: Request) async throws -> Response {
        _ = try await populateDBWithAffiliations(request: request)
        _ = try await populateDBWithModules(request: request)
        _ = try await populateDBWithUsers(request: request)
        _ = try await populateDBWithPosts(request: request)
        _ = try await populateDBWithSecretCodes(request: request)
        _ = try await populateDBWithCopies(request: request)
        
        return Response(status: .ok)
    }
    
    /// Populates the database with some users.
    func populateDBWithUsers(request: Request) async throws -> Response {
        let wadye = try User(firstName: "Wadÿe", lastName: "Khebbeb", email: "wiwi@icloud.com", passwordHash: Bcrypt.hash("wiwi"), type: .admin)
        let nabil = try User(firstName: "Nabil", lastName: "Boukerzaza", email: "admin@example.com", passwordHash: Bcrypt.hash("napi"), type: .admin)
        let faiza = try User(firstName: "Faiza", lastName: "Belala", email: "faiza.belala@lab-lire.dz", passwordHash: Bcrypt.hash("svs"), type: .dean)
        let manel = try User(firstName: "Manel Amel", lastName: "Djenouhat", email: "manel.djenouhat@univ2.dz", passwordHash: Bcrypt.hash("tml"), type: .teacher)
        let souheila = try User(firstName: "Souheila", lastName: "Boudouda", email: "souheila.boudouda@univ2.dz", passwordHash: Bcrypt.hash("plf"), type: .teacher)
        let ramdane = try User(firstName: "Ramdane", lastName: "Maameri", email: "ramdane.maameri@univ2.dz", passwordHash: Bcrypt.hash("aql"), type: .teacher)
        let zakaria = try User(firstName: "Zakaria", lastName: "Benzadri", email: "zakaria.benzadri@fablab.dz", passwordHash: Bcrypt.hash("poc"), type: .teacher)
        let fateh = try User(firstName: "Fateh", lastName: "Latreche", email: "fateh.latreche@univ2.dz", passwordHash: Bcrypt.hash("sd"), type: .cfdPresident)
        let yousri = try User(firstName: "Yousri", lastName: "Boumaza", email: "pigeon@riot.com", passwordHash: Bcrypt.hash("kaisa"), type: .candidate)
        let toufik = try User(firstName: "Toufik", lastName: "Menaa", email: "toufik@gmail.com", passwordHash: Bcrypt.hash("tou"), type: .candidate)
        let lyna = try User(firstName: "Lyna", lastName: "Benabbas", email: "lyna@mooc.dz", passwordHash: Bcrypt.hash("love"), type: .candidate)
        let hadjer = try User(firstName: "Hadjer", lastName: "Bougzia", email: "hadjer@univ2.dz", passwordHash: Bcrypt.hash("estp"), type: .candidate)
        let aymen = try User(firstName: "Aymen", lastName: "Kerrouche", email: "aymen@laboom.dz", passwordHash: Bcrypt.hash("hallab"), type: .candidate)
        let edon = try User(firstName: "Oussama", lastName: "Foura", email: "edon@g.fx", passwordHash: Bcrypt.hash("akali"), type: .candidate)
        
        let users = [wadye, nabil, faiza, manel, fateh, yousri, toufik, souheila, ramdane, zakaria, lyna, aymen, hadjer, edon]
        
        for user in users {
            try await user.save(on: request.db)
        }
        
        return Response(status: .ok)
    }
    
    /// Populates the database with some posts.
    func populateDBWithPosts(request: Request) async throws -> Response {
        let database = request.db
        
        guard let faizaID = try? await User.query(on: database).filter(\.$firstName == "Faiza").first()?.id else {
            throw Abort(.notFound)
        }
        
        let post1 = Post(userID: faizaID, title: "Séance de TD annulée", content: "La séance de TD de demain a été annulée.")
        let post2 = Post(userID: faizaID, title: "Notes interrogation SVS", content: "Veuillez consulter vos notes d'interrogation du module SVS dans le mail.", link: "NotesInterroSVS.pdf")
        let post3 = Post(userID: faizaID, title: "Notes interrogation SVS", content: "Veuillez consulter vos notes de contrôle du module SVS dans le mail.", link: "NotesControleSVS.xlsx")
        
        let posts = [post1, post2, post3]
        
        for post in posts {
            try await post.save(on: database)
        }
        
        return Response(status: .ok)
    }
    
    /// Populates the database with some results.
    func populateDBWithResults(request: Request) async throws -> Response {
        let database = request.db
        
        guard let yousriID = try? await User.query(on: database).filter(\.$firstName == "Yousri").first()?.id,
              let toufikID = try? await User.query(on: database).filter(\.$firstName == "Toufik").first()?.id
        else {
            throw Abort(.notFound, reason: "Could not get IDs from the database.")
        }
        
        print("Done searching...".uppercased())
        
        let result1 = Result(candidateID: yousriID, value: 8.32)
        let result2 = Result(candidateID: toufikID, value: 13.73)
        
        let results = [result1, result2]
        
        for result in results {
            try await result.save(on: database)
        }
        
        return Response(status: .ok)
    }
    
    /// Populates the database with some affiliations.
    func populateDBWithAffiliations(request: Request) async throws -> Response {
        let affiliations = [
            Affiliation(name: "GL"),
            Affiliation(name: "STIC"),
            Affiliation(name: "SITW"),
            Affiliation(name: "RSD")
        ]
        
        for affiliation in affiliations {
            try await affiliation.save(on: request.db)
        }
        
        return Response(status: .ok)
    }
    
    func populateDBWithCopies(request: Request) async throws -> Response {
        let database = request.db
        
        let yousriID = try await User.findIDByFirstName("Yousri", in: request)
        let toufikID = try await User.findIDByFirstName("Toufik", in: request)
        let lynaID = try await User.findIDByFirstName("Lyna", in: request)
        let hadjerID = try await User.findIDByFirstName("Hadjer", in: request)
        let aymenID = try await User.findIDByFirstName("Aymen", in: request)
        let edonID = try await User.findIDByFirstName("Oussama", in: request)
        
        let yousriSecretCodeID = try await SecretCode.query(on: database)
            .join(User.self, on: \SecretCode.$candidate.$id == \User.$id)
            .filter(\.$candidate.$id == yousriID)
            .first()!
            .id!
        
        let toufikSecretCodeID = try await SecretCode.query(on: database)
            .join(User.self, on: \SecretCode.$candidate.$id == \User.$id)
            .filter(\.$candidate.$id == toufikID)
            .first()!
            .id!
        
        let lynaSCID = try await SecretCode.query(on: database)
            .join(User.self, on: \SecretCode.$candidate.$id == \User.$id)
            .filter(\.$candidate.$id == lynaID)
            .first()!
            .id!
        
        let hadjerSCID = try await SecretCode.query(on: database)
            .join(User.self, on: \SecretCode.$candidate.$id == \User.$id)
            .filter(\.$candidate.$id == hadjerID)
            .first()!
            .id!
        
        let aymenSCID = try await SecretCode.query(on: database)
            .join(User.self, on: \SecretCode.$candidate.$id == \User.$id)
            .filter(\.$candidate.$id == aymenID)
            .first()!
            .id!
        
        let edonSCID = try await SecretCode.query(on: database)
            .join(User.self, on: \SecretCode.$candidate.$id == \User.$id)
            .filter(\.$candidate.$id == edonID)
            .first()!
            .id!
        
        print(yousriID)
        
        let mathID = try await Module.query(on: database).filter(\.$name == "MATH").first()!.id!
        let infoID = try await Module.query(on: database).filter(\.$name == "INFO").first()!.id!
        
        let manelID = try await User.query(on: database).filter(\.$firstName == "Manel Amel").first()!.id!
        let souheilaID = try await User.query(on: database).filter(\.$firstName == "Souheila").first()!.id!
        let zakariaID = try await User.query(on: database).filter(\.$firstName == "Zakaria").first()!.id!
        let ramdaneID = try await User.query(on: database).filter(\.$firstName == "Ramdane").first()!.id!
        
        let copies = [
            Copy(moduleID: mathID, candidateID: yousriID, secretCodeID: yousriSecretCodeID),
            Copy(moduleID: infoID, candidateID: yousriID, secretCodeID: yousriSecretCodeID),
            
            Copy(moduleID: mathID, candidateID: toufikID, secretCodeID: toufikSecretCodeID),
            Copy(moduleID: infoID, candidateID: toufikID, secretCodeID: toufikSecretCodeID, teacher1ID: souheilaID, teacher2ID: ramdaneID, mark1: 14, mark2: 17),
            
            Copy(moduleID: mathID, candidateID: lynaID, secretCodeID: lynaSCID, teacher1ID: manelID, teacher2ID: souheilaID, mark1: 20, mark2: 18),
            Copy(moduleID: infoID, candidateID: lynaID, secretCodeID: lynaSCID, teacher1ID: zakariaID, teacher2ID: manelID, mark1: 18.5, mark2: 18.75),
            
            Copy(moduleID: mathID, candidateID: edonID, secretCodeID: edonSCID),
            Copy(moduleID: infoID, candidateID: edonID, secretCodeID: edonSCID, teacher1ID: ramdaneID, teacher2ID: zakariaID, mark1: 12, mark2: 9),
            
            Copy(moduleID: mathID, candidateID: aymenID, secretCodeID: aymenSCID),
            Copy(moduleID: infoID, candidateID: aymenID, secretCodeID: aymenSCID),
            
            Copy(moduleID: mathID, candidateID: hadjerID, secretCodeID: hadjerSCID, teacher1ID: ramdaneID, teacher2ID: souheilaID, mark1: 13, mark2: 18),
            Copy(moduleID: infoID, candidateID: hadjerID, secretCodeID: hadjerSCID, teacher1ID: zakariaID, teacher2ID: manelID)
        ]
        
        for copy in copies {
            try await copy.save(on: database)
        }

        return Response(status: .ok)
    }
    
    /// Populates the database with some modules.
    func populateDBWithModules(request: Request) async throws -> Response {
        let database = request.db
        
        guard
            let glID = try? await Affiliation.query(on: database).filter(\.$name == "GL").first()?.id else {
            throw Abort(.notFound, reason: "Could not retrieve affiliation IDs from the database.")
        }
        
        let modules = [
            Module(affiliationID: glID, name: "MATH", factor: 2),
            Module(affiliationID: glID, name: "INFO", factor: 1),
        ]
        
        for module in modules {
            try await module.save(on: database)
        }
        
        return Response(status: .ok)
    }
    
    /// Populates the database with some secret codes.
    func populateDBWithSecretCodes(request: Request) async throws -> Response {
        let database = request.db
        
        guard let yousriID = try? await User.query(on: database).filter(\.$firstName == "Yousri").first()?.id,
              let toufikID = try? await User.query(on: database).filter(\.$firstName == "Toufik").first()?.id,
                let lynaID = try? await User.findIDByFirstName("Lyna", in: request),
                let hadjerID = try? await User.findIDByFirstName("Hadjer", in: request),
                let aymenID = try? await User.findIDByFirstName("Aymen", in: request),
                let edonID = try? await User.findIDByFirstName("Oussama", in: request)
        else {
            throw Abort(.notFound, reason: "Could not get IDs from the database.")
        }
        
        let codes = [
            SecretCode(candidateID: yousriID),
            SecretCode(candidateID: toufikID),
            SecretCode(candidateID: lynaID),
            SecretCode(candidateID: aymenID),
            SecretCode(candidateID: hadjerID),
            SecretCode(candidateID: edonID)
        ]
        
        for code in codes {
            try await code.save(on: database)
        }
        
        return Response(status: .ok)
    }
    
    func startOver(request: Request) async throws -> Response {
        let database = request.db
        try await AffiliationMigration().revert(on: database)
        try await ModuleMigration().revert(on: database)
        try await SecretCodeMigration().revert(on: database)
        try await ResultMigration().revert(on: database)
        try await SecretCodeMigration().revert(on: database)
        try await PostMigration().revert(on: database)
        try await UserMigration().revert(on: database)
        try await CopyMigration().revert(on: database)
        
        _ = try await populateDBWithEverything(request: request)
        
        return Response(status: .ok)
    }
    
    /// Returns `ok` if the debugger is working.
    func test(request: Request) -> Response {
        return Response(status: .ok)
    }
}

extension User {
    static func findByFirstName(_ firstName: String, in request: Request) async throws -> User {
        guard let user = try? await User.query(on: request.db).filter(\.$firstName == firstName).first() else {
            throw Abort(.notFound, reason: "Could not find user by first name in database.")
        }
        return user
    }
    
    static func findIDByFirstName(_ firstName: String, in request: Request) async throws -> UUID {
        guard let id = try? await User.query(on: request.db).filter(\.$firstName == firstName).first()?.id else {
            throw Abort(.notFound, reason: "Could not find user by first name in database.")
        }
        return id
    }
}
