//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

struct TeacherController: TypedController {
    let type: UserType = .teacher
    
    func boot(routes: RoutesBuilder) throws {
        let controller = routes.grouped("teacher")
        controller.get(use: getAssignedCopies)
        controller.post(use: sendMarks)
    }
    
    func getAssignedCopies(request: Request) async throws -> View {
        let teacher = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        guard let teacherID = teacher.id else {
            throw Abort(.internalServerError, reason: "Teacher ID is missing.")
        }
        
        let copiesAsTeacher1 = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .join(User.self, on: \Copy.$teacher1.$id == \User.$id)
            .filter(\.$teacher1.$id == teacherID)
            .all()
        
        let copiesAsTeacher2 = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .join(User.self, on: \Copy.$teacher2.$id == \User.$id)
            .filter(\.$teacher2.$id == teacherID)
            .all()
        
        let copiesAsTeacher3 = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .join(User.self, on: \Copy.$teacher3.$id == \User.$id)
            .filter(\.$teacher3.$id == teacherID)
            .all()
        
        let allAssignedCopies = copiesAsTeacher1 + copiesAsTeacher2 + copiesAsTeacher3
        
        let assignedCopies = allAssignedCopies.map { Copy.View.TeacherPerspective(from: $0) }
        
        let context = Copy.Context.TeacherPerspective(teacher: teacher, copies: assignedCopies)
        
        return try await request.view.render("Teacher", context)
    }
    
    func sendMarks(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let marksData = try request.content.decode([Copy.JSON.TeacherPerspective].self)
        var updatedCount = 0
        
        for markData in marksData {
            guard let copy = try await Copy.find(markData.copyID, on: request.db) else {
                continue
            }
            
            if copy.mark1 == nil {
                copy.mark1 = markData.mark
            } else if copy.mark2 == nil {
                copy.mark2 = markData.mark
            } else if copy.mark3 == nil {
                copy.mark3 = markData.mark
            } else {
                continue
            }
            
            try await copy.update(on: request.db)
            updatedCount += 1
        }
        
        if updatedCount > 0 {
            request.setFlash(.success, message: "Marks submitted successfully for \(updatedCount) paper(s).")
        } else {
            request.setFlash(.warning, message: "No marks were updated.")
        }
        
        return request.redirect(to: "/teacher")
    }
}
