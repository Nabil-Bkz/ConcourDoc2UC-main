//
//  Copy.swift
//  
//
//  Created by Wadÿe on 23/05/2023.
//

import Vapor
import Fluent

/// A candidate's copy, that is ready for verification, or is already verified.
final class Copy: Entity {
    static var schema: String = "Copy"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "module_id")
    var module: Module
    
    @Parent(key: "candidate_id")
    var candidate: User
    
    @Parent(key: "secret_code_id")
    var secretCode: SecretCode
    
    @OptionalParent(key: "teacher1_id")
    var teacher1: User?
    
    @OptionalParent(key: "teacher2_id")
    var teacher2: User?
    
    @OptionalParent(key: "teacher3_id")
    var teacher3: User?
    
    @OptionalField(key: "mark1")
    var mark1: Float?
    
    @OptionalField(key: "mark2")
    var mark2: Float?
    
    @OptionalField(key: "mark3")
    var mark3: Float?
    
    init() { }
    
    init(
        id: UUID? = nil,
        moduleID: Module.IDValue,
        candidateID: User.IDValue,
        secretCodeID: SecretCode.IDValue,
        teacher1ID: User.IDValue? = nil,
        teacher2ID: User.IDValue? = nil,
        teacher3ID: User.IDValue? = nil,
        mark1: Float? = nil,
        mark2: Float? = nil
    ) {
        self.id = id
        self.$module.id = moduleID
        self.$candidate.id = candidateID
        self.$secretCode.id = secretCodeID
        self.$teacher1.id = teacher1ID
        self.$teacher2.id = teacher2ID
        self.$teacher3.id = teacher3ID
        self.mark1 = mark1
        self.mark2 = mark2
    }
}

extension Copy {
    enum View {
        struct Marked: Content {
            let id: UUID
            let secretCode: String
            let candidateID: UUID
            let fullName: String
            let module: String
            let mark1: Float
            let mark2: Float
            let mark3: Float?
            let finalMark: Float
            
            init(from copy: Copy) {
                guard let copyID = copy.id,
                      let candidateID = copy.candidate.id,
                      let mark1 = copy.mark1,
                      let mark2 = copy.mark2 else {
                    fatalError("Copy.Marked view requires copy with ID, candidate ID, and both marks")
                }
                
                self.id = copyID
                self.secretCode = copy.secretCode.content
                self.candidateID = candidateID
                self.fullName = "\(copy.candidate.firstName) \(copy.candidate.lastName)"
                self.module = copy.module.name
                self.mark1 = mark1
                self.mark2 = mark2
                self.mark3 = copy.mark3
                
                if let mark3 = copy.mark3 {
                    self.finalMark = mark3
                } else {
                    self.finalMark = max(mark1, mark2)
                }
            }
        }
        
        struct Unmarked: Content {
            let id: UUID
            let secretCode: String
            let fullName: String
            let module: String
            
            init(from copy: Copy) {
                self.id = copy.id!
                self.secretCode = copy.secretCode.content
                self.fullName = "\(copy.candidate.firstName) \(copy.candidate.lastName)"
                self.module = copy.module.name
            }
        }
        
        struct RequiringThirdTeacher: Content {
            let id: UUID
            let secretCode: String
            let fullName: String
            let module: String
            let mark1: Float
            let mark2: Float
            
            init(from copy: Copy) {
                self.id = copy.id!
                self.secretCode = copy.secretCode.content
                self.fullName = "\(copy.candidate.firstName) \(copy.candidate.lastName)"
                self.module = copy.module.name
                self.mark1 = copy.mark1!
                self.mark2 = copy.mark2!
            }
        }
        
        struct TeacherPerspective: Content {
            let id: UUID
            let secretCode: String
            let module: String
            
            init(from copy: Copy) {
                self.id = copy.id!
                self.secretCode = copy.secretCode.content
                self.module = copy.module.name
            }
        }
    }
    
    enum Context {
        struct Marked: Encodable {
            let user: User
            let copies: [Copy.View.Marked]
        }
        
        struct Unmarked: Encodable {
            let user: User
            let copies: [Copy.View.Unmarked]
            let teachers: [User]
        }
        
        struct RequiringThirdTeacher: Encodable {
            let user: User
            let copies: [Copy.View.RequiringThirdTeacher]
            let teachers: [User]
        }
        
        struct TeacherPerspective: Encodable {
            let teacher: User
            let copies: [Copy.View.TeacherPerspective]
        }
    }
    
    enum JSON {
        struct AssignThirdTeacher: Content {
            let copyID: UUID
            let teacher3ID: UUID
        }
        
        struct AssignTeachers: Content {
            let copyID: UUID
            let teacher1ID: UUID
            let teacher2ID: UUID
        }
        
        struct TeacherPerspective: Content {
            let copyID: UUID
            let mark: Float
        }
        
        struct Publish: Content {
            let candidateID: UUID
            let infoFinalMark: Float
            let mathFinalMark: Float
        }
    }
}
