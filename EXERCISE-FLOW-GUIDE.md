# 📚 Exercise Flow Guide for Instructors

## 🎯 Module 3: Working with Web APIs - Exercise Flow

### **Exercise 1: Create Basic API**
**Fresh Start Required**
```bash
./setup-exercise.sh exercise01-basic-api
cd LibraryAPI
# Follow Exercise 1 instructions
```

**What students build:**
- Basic Web API project
- Book models and controllers
- In-memory database
- Basic Swagger documentation

---

### **Exercise 2: Add Authentication & Security**
**Builds on Exercise 1**

**Option A: Continue from Exercise 1 (Recommended)**
```bash
# Students continue with their existing LibraryAPI project
cd LibraryAPI
# Follow Exercise 2 instructions (no setup script needed)
```

**Option B: Fresh Start**
```bash
./setup-exercise.sh exercise02-authentication
cd LibraryAPI
# Follow Exercise 2 instructions
```

**What students add:**
- JWT authentication
- User registration/login
- Identity framework
- Authorization policies
- Security headers

---

### **Exercise 3: API Documentation & Versioning**
**Builds on Exercises 1 & 2**

**Option A: Continue from Exercise 2 (Recommended)**
```bash
# Students continue with their existing LibraryAPI project
cd LibraryAPI

# Add only the new packages needed for Exercise 3
dotnet add package Swashbuckle.AspNetCore.Annotations --version 6.8.1
dotnet add package Microsoft.AspNetCore.Mvc.Versioning --version 5.1.0
dotnet add package Microsoft.AspNetCore.Mvc.Versioning.ApiExplorer --version 5.1.0
dotnet add package AspNetCore.HealthChecks.UI --version 8.0.2
dotnet add package AspNetCore.HealthChecks.UI.Client --version 8.0.2
dotnet add package AspNetCore.HealthChecks.UI.InMemory.Storage --version 8.0.2

# Follow Exercise 3 instructions
```

**Option B: Fresh Start**
```bash
./setup-exercise.sh exercise03-documentation
cd LibraryAPI
# Follow Exercise 3 instructions
```

**What students add:**
- Enhanced Swagger documentation
- API versioning (v1, v2)
- Health checks and monitoring
- API analytics and metrics

## 🎓 Teaching Recommendations

### **For Sequential Learning (Recommended)**
Students should complete exercises in order:
1. **Exercise 1** → Use setup script
2. **Exercise 2** → Continue with existing project
3. **Exercise 3** → Continue with existing project + add packages

### **For Individual Exercises**
If students want to jump to a specific exercise:
- Use the setup script for that exercise
- Each setup script creates a complete project with all dependencies

### **For Troubleshooting**
If students have issues with their existing project:
- Use the setup script to start fresh
- Compare with their existing code to identify issues

## 🔧 Package Management Strategy

### **Exercise 1 Packages:**
- Basic Web API packages
- Entity Framework In-Memory
- Swagger/OpenAPI

### **Exercise 2 Adds:**
- JWT Authentication packages
- Identity Framework
- Security packages

### **Exercise 3 Adds:**
- Advanced Swagger features
- API Versioning
- Health Checks
- Analytics packages

## 📋 Verification Commands

Students can verify their setup at any point:
```bash
../verify-packages.sh  # Check package versions
dotnet build           # Verify compilation
dotnet run            # Test application
```

## 🎯 Learning Progression

**Exercise 1:** Basic API concepts
- REST principles
- HTTP methods
- Data models
- Basic documentation

**Exercise 2:** Security fundamentals
- Authentication vs Authorization
- JWT tokens
- Identity management
- Security best practices

**Exercise 3:** Advanced API features
- Comprehensive documentation
- API evolution (versioning)
- Monitoring and observability
- Production readiness

## 💡 Instructor Tips

1. **Emphasize the build-up approach** - Each exercise adds to the previous
2. **Use setup scripts for fresh starts** - When students need to catch up
3. **Verify package versions** - Use the verification script to catch issues early
4. **Focus on concepts** - Less time on setup, more time on learning
5. **Encourage continuation** - Students learn more by building incrementally

## 🆘 Common Issues & Solutions

**Issue**: Student missed Exercise 1 but wants to do Exercise 2
**Solution**: Use `./setup-exercise.sh exercise02-authentication`

**Issue**: Student's project is broken and won't build
**Solution**: Use setup script to start fresh, then compare code

**Issue**: Package version conflicts
**Solution**: Run `../verify-packages.sh` and follow the fix commands

**Issue**: Student wants to skip to Exercise 3
**Solution**: Use `./setup-exercise.sh exercise03-documentation`

---

**The key insight: Setup scripts provide flexibility while the sequential approach provides the best learning experience!** 🎉
