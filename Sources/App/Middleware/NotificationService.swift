//
//  NotificationService.swift
//  EDLApplication
//
//  Created during feature implementation
//

import Vapor
import Foundation

/// Service for sending email notifications
struct NotificationService {
    /// Sends an email notification (placeholder for SMTP integration)
    /// In production, integrate with SMTP service like SendGrid, Mailgun, or AWS SES
    static func sendEmail(
        to recipient: String,
        subject: String,
        body: String,
        on request: Request
    ) async throws {
        // TODO: Integrate with actual SMTP service
        // For now, log the email that would be sent
        request.logger.info("📧 Email Notification", metadata: [
            "to": .string(recipient),
            "subject": .string(subject),
            "body": .string(body)
        ])
        
        // In production, uncomment and configure:
        // let email = Email(
        //     from: Environment.get("SMTP_FROM") ?? "noreply@university.edu",
        //     to: recipient,
        //     subject: subject,
        //     body: body
        // )
        // try await request.email.send(email)
    }
    
    /// Sends notification when results are published
    static func notifyResultsPublished(
        candidateEmail: String,
        candidateName: String,
        finalMark: Float,
        accepted: Bool,
        on request: Request
    ) async throws {
        let subject = "Examination Results Published"
        let status = accepted ? "accepted" : "not accepted"
        let body = """
        Dear \(candidateName),
        
        Your examination results have been published.
        
        Final Mark: \(String(format: "%.2f", finalMark))/20
        Status: \(status.capitalized)
        
        You can view detailed results by logging into the system.
        
        Best regards,
        Examination Committee
        """
        
        try await sendEmail(to: candidateEmail, subject: subject, body: body, on: request)
    }
    
    /// Sends notification when secret code is assigned
    static func notifySecretCodeAssigned(
        candidateEmail: String,
        candidateName: String,
        secretCode: String,
        on request: Request
    ) async throws {
        let subject = "Secret Code Assigned - Examination System"
        let body = """
        Dear \(candidateName),
        
        Your secret code for anonymous examination has been assigned.
        
        Secret Code: \(secretCode)
        
        Please keep this code confidential. It will be used to identify your examination papers anonymously.
        
        Important: Do not share this code with anyone.
        
        Best regards,
        Examination Committee
        """
        
        try await sendEmail(to: candidateEmail, subject: subject, body: body, on: request)
    }
    
    /// Sends notification when teachers are assigned to grade
    static func notifyTeachersAssigned(
        teacherEmail: String,
        teacherName: String,
        numberOfCopies: Int,
        on request: Request
    ) async throws {
        let subject = "New Examination Papers Assigned"
        let body = """
        Dear \(teacherName),
        
        You have been assigned \(numberOfCopies) examination paper(s) to grade.
        
        Please log into the system to access and grade the assigned papers.
        
        Best regards,
        Examination Committee
        """
        
        try await sendEmail(to: teacherEmail, subject: subject, body: body, on: request)
    }
}

