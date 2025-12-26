//
//  File.swift
//  
//
//  Created by Wadÿe on 24/05/2023.
//

import Vapor
import Fluent

struct CFDPresidentController: TypedController {
    let type: UserType = .cfdPresident
    
    func boot(routes: RoutesBuilder) throws {
        let controller = routes.grouped("cfd-president")
        controller.get("copies", "marked", use: getMarkedCopies)
        controller.get("copies", "unmarked", use: getUnmarkedCopies)
        controller.get("copies", "third-teacher", use: getRequiringThirdTeacherCopies)
        controller.post("copies", "unmarked", use: assignTeachers)
        controller.post("copies", "third-teacher", use: assignThirdTeacher)
        controller.post("copies", "marked", "publish", use: publishResults)
    }
    
    func getMarkedCopies(request: Request) async throws -> View {
        let user = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allCopies = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .with(\.$candidate)
            .all()
        
        let markedCopies = allCopies.compactMap { copy -> Copy.View.Marked? in
            guard let mark1 = copy.mark1,
                  let mark2 = copy.mark2,
                  (abs(mark1 - mark2) < AppConstants.markDifferenceThreshold || copy.mark3 != nil) else {
                return nil
            }
            return Copy.View.Marked(from: copy)
        }
        
        let context = Copy.Context.Marked(user: user, copies: markedCopies)
        return try await request.view.render("mark", context)
    }
    
    func getUnmarkedCopies(request: Request) async throws -> View {
        let user = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allCopies = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .with(\.$candidate)
            .with(\.$teacher1)
            .with(\.$teacher2)
            .all()
        
        let unmarkedCopies = allCopies.compactMap { copy -> Copy.View.Unmarked? in
            guard copy.mark1 == nil,
                  copy.mark2 == nil,
                  copy.teacher1 == nil,
                  copy.teacher2 == nil else {
                return nil
            }
            return Copy.View.Unmarked(from: copy)
        }
        
        let teachers = try await User.query(on: request.db)
            .filter(\.$type == .teacher)
            .all()
        
        let context = Copy.Context.Unmarked(user: user, copies: unmarkedCopies, teachers: teachers)
        return try await request.view.render("affect_teacher", context)
    }
    
    func getRequiringThirdTeacherCopies(request: Request) async throws -> View {
        let user = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allCopies = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .with(\.$candidate)
            .with(\.$teacher3)
            .all()
        
        let copiesRequiringThirdTeacher = allCopies.compactMap { copy -> Copy.View.RequiringThirdTeacher? in
            guard let mark1 = copy.mark1,
                  let mark2 = copy.mark2,
                  copy.teacher3 == nil,
                  abs(mark1 - mark2) >= AppConstants.markDifferenceThreshold else {
                return nil
            }
            return Copy.View.RequiringThirdTeacher(from: copy)
        }
        
        let teachers = try await User.query(on: request.db)
            .filter(\.$type == .teacher)
            .all()
        
        let context = Copy.Context.RequiringThirdTeacher(user: user, copies: copiesRequiringThirdTeacher, teachers: teachers)
        return try await request.view.render("third_teacher", context)
    }
    
    func assignTeachers(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let assignmentData = try request.content.decode(Copy.JSON.AssignTeachers.self)
        
        guard let copy = try await Copy.find(assignmentData.copyID, on: request.db) else {
            request.setFlash(.error, message: "Copy not found.")
            return request.redirect(to: "/cfd-president/copies/unmarked")
        }
        
        copy.$teacher1.id = assignmentData.teacher1ID
        copy.$teacher2.id = assignmentData.teacher2ID
        
        try await copy.save(on: request.db)
        
        // Send notifications to teachers
        if let teacher1 = try await User.find(assignmentData.teacher1ID, on: request.db) {
            try? await NotificationService.notifyTeachersAssigned(
                teacherEmail: teacher1.email,
                teacherName: teacher1.fullName,
                numberOfCopies: 1,
                on: request
            )
        }
        
        if let teacher2 = try await User.find(assignmentData.teacher2ID, on: request.db) {
            try? await NotificationService.notifyTeachersAssigned(
                teacherEmail: teacher2.email,
                teacherName: teacher2.fullName,
                numberOfCopies: 1,
                on: request
            )
        }
        
        request.setFlash(.success, message: "Teachers assigned successfully.")
        return request.redirect(to: "/cfd-president/copies/unmarked")
    }
    
    func assignThirdTeacher(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let assignmentData = try request.content.decode(Copy.JSON.AssignThirdTeacher.self)
        
        guard let copy = try await Copy.find(assignmentData.copyID, on: request.db) else {
            throw Abort(.notFound, reason: "Could not find copy in database.")
        }
        
        copy.$teacher3.id = assignmentData.teacher3ID
        try await copy.update(on: request.db)
        
        return request.redirect(to: "/cfd-president/copies/third-teacher")
    }
    
    func publishResults(request: Request) async throws -> Response {
        _ = try await UserAuthenticator.verifyIdentity(for: type, in: request)
        
        let allCopies = try await Copy.query(on: request.db)
            .with(\.$module)
            .with(\.$secretCode)
            .with(\.$candidate)
            .all()
        
        let markedCopies = allCopies.compactMap { copy -> Copy.View.Marked? in
            guard let mark1 = copy.mark1,
                  let mark2 = copy.mark2,
                  (abs(mark1 - mark2) < AppConstants.markDifferenceThreshold || copy.mark3 != nil) else {
                return nil
            }
            return Copy.View.Marked(from: copy)
        }
        
        let candidateIDs = Set(markedCopies.map { $0.candidateID })
        var publishedCount = 0
        
        for candidateID in candidateIDs {
            let candidateCopies = try await Copy.query(on: request.db)
                .with(\.$candidate)
                .filter(\.$candidate.$id == candidateID)
                .all()
            
            guard candidateCopies.count == AppConstants.requiredModulesPerCandidate else {
                continue
            }
            
            let finalMarks = candidateCopies.map { copy -> Float in
                if let mark3 = copy.mark3 {
                    return mark3
                }
                guard let mark1 = copy.mark1, let mark2 = copy.mark2 else {
                    return 0.0
                }
                return max(mark1, mark2)
            }
            
            guard finalMarks.count == AppConstants.requiredModulesPerCandidate else {
                continue
            }
            
            let average = (finalMarks[0] + finalMarks[1]) * AppConstants.resultCalculationMultiplier
            
            let result = Result(candidateID: candidateID, value: average)
            try await result.save(on: request.db)
            
            // Send notification to candidate
            if let candidate = try await User.find(candidateID, on: request.db) {
                try? await NotificationService.notifyResultsPublished(
                    candidateEmail: candidate.email,
                    candidateName: candidate.fullName,
                    finalMark: average,
                    accepted: result.accepted,
                    on: request
                )
            }
            
            for copy in candidateCopies {
                try await copy.delete(on: request.db)
            }
            
            publishedCount += 1
        }
        
        request.setFlash(.success, message: "Results published successfully for \(publishedCount) candidate(s).")
        return request.redirect(to: "/cfd-president/copies/marked")
    }
}

