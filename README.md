# DOCTORATE CONTEST MANAGEMENT SYSTEM 

[![Project Report](https://img.shields.io/badge/Project%20Report-View%20Report-blue)](#)
[![Swift](https://img.shields.io/badge/Swift-5.8-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4.76-blue.svg)](https://vapor.codes)

The Academic Examination Management System is an innovative web application designed to streamline and enhance the process of conducting doctoral-level examinations within the university. This robust system caters to the needs of candidates, administrative staff, and educators, ensuring a seamless and secure examination experience.

##  Features

-  **Role-Based Access Control** - Secure authentication with 5 distinct user roles
-  **Anonymous Grading System** - Secret code generation ensures fair evaluation
-  **Multi-Teacher Grading** - Supports up to 3 teachers with automatic conflict resolution
-  **Flash Messages** - User-friendly feedback system for all operations
-  **Email Notifications** - Automated notifications for key events
-  **API Documentation** - Comprehensive API documentation endpoint
-  **Result Publishing** - Automated result calculation and publishing
-  **Post Management** - Announcement system for deans

## 🛠 Technologies Used

- **Front-End:** HTML, CSS, JavaScript
- **Back-End:** Vapor Swift framework (4.76+)
- **Database:** SQLite (development), MySQL (production via Docker)
- **ORM:** Fluent
- **Templating:** Leaf
- **Authentication:** Session-based with Bcrypt password hashing

## Functional Requirements

### 1. **Candidate Access**
   - Registered candidates can log in to access essential examination information
   - View examination schedules and announcements
   - Access personal results with rankings
   - Receive email notifications when results are published

### 2. **Vice-Dean's Role**
   - Create and manage announcement posts
   - Generate confidential secret codes for candidate anonymity
   - View all assigned secret codes
   - Receive flash message feedback for all operations

### 3. **Anonymity Preservation**
   - Robust secret code generation system (4-character unique codes)
   - Codes prevent identification during grading process
   - Automatic code uniqueness validation

### 4. **Efficient Teacher Assignment**
   - CFD President assigns two teachers per examination copy
   - Automatic third teacher assignment when marks differ significantly (≥3 points)
   - Email notifications sent to teachers when assigned

### 5. **Confidential Anonymous Scoring**
   - System computes final averages using weighted algorithm
   - Final mark = (Module1 + Module2) × 2/3
   - Uses third teacher's mark if assigned, otherwise max of two marks

### 6. **Transparent Candidate Evaluation**
   - CFD President views comprehensive list of candidates with final averages
   - Results sorted by ranking
   - Automatic acceptance determination (≥10/20)

### 7. **Teacher Assessment Interface**
   - Teachers view assigned copies identified only by secret codes
   - Submit marks through user-friendly interface
   - Flash messages confirm successful submissions

## Non-Functional Requirements

1. **Security Assurance:**
   - Bcrypt password hashing for secure authentication
   - Session-based authentication with secure session management
   - Role-based access control on all protected routes
   - Input validation and sanitization

2. **Reliability:**
   - Comprehensive error handling throughout the application
   - Database transactions ensure data integrity
   - Cascading deletions maintain referential integrity
   - Flash messages provide user feedback for all operations

3. **Performance:**
   - Efficient database queries with proper indexing
   - Optimized code structure following Swift best practices
   - Async/await for non-blocking operations

4. **User Experience:**
   - Flash message system for immediate feedback
   - Email notifications for important events
   - Intuitive role-specific interfaces
   - Clear error messages and validation feedback

5. **Maintainability:**
   - Modular architecture with separation of concerns
   - Centralized constants for easy configuration
   - Comprehensive API documentation
   - Clean, well-documented code following Swift conventions

## Key Actors

1. **Candidate:**
   - Embarks on the doctoral examination journey, accessing results through the application.

2. **CFD President:**
   - Oversees the examination process, reviewing candidate lists and final averages.
   - Assigns educators for examination paper corrections.

3. **Vice-Dean:**
   - Imparts crucial examination information and contributes to candidate anonymity through code generation.

4. **Educator:**
   - Evaluates and grades examination papers, ensuring fair assessment.

##  Getting Started

### Prerequisites
- macOS 12+ or Linux
- Swift 5.8+
- Docker (for production deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-new-repository-url>
   cd <repository-name>
   ```

2. **Build the project**
   ```bash
   swift build
   ```

3. **Run migrations**
   ```bash
   swift run App migrate
   ```

4. **Start the server**
   ```bash
   swift run App serve
   ```

5. **Access the application**
   - Open browser to `http://localhost:8080`
   - Default redirects to `/login`

### Docker Deployment

```bash
# Build and start services
docker-compose up --build

# Run migrations
docker-compose run migrate

# Stop services
docker-compose down
```

### Configuration

The application uses environment variables for configuration:
- `LOG_LEVEL` - Logging level (default: `debug`)
- `DATABASE_HOST` - Database host (Docker: `db`)
- `DATABASE_NAME` - Database name
- `DATABASE_USERNAME` - Database username
- `DATABASE_PASSWORD` - Database password

### Email Notifications

Email notifications are currently logged to the console. To enable actual email sending:

1. Configure SMTP settings in `NotificationService.swift`
2. Uncomment the email sending code
3. Set environment variables for SMTP configuration

##  API Documentation

Access the API documentation at:
- **HTML View:** `http://localhost:8080/api/docs`
- **JSON Format:** `http://localhost:8080/api/docs/json`



##  User Roles

1. **Admin** - Full system administration
2. **CFD President** - Result management and teacher assignment
3. **Dean** - Post management and secret code generation
4. **Teacher** - Grade submission for assigned papers
5. **Candidate** - View results and announcements


