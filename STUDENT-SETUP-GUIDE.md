# 🎓 Student Setup Guide

## 📋 **Before Starting ANY Exercise**

### **Step 1: Navigate to Training Directory**
```bash
cd aspnet-core-training
```

### **Step 2: Run Setup Script for Each Exercise**
```bash
./setup-exercise.sh <exercise-name>
```

### **Step 3: Work in the Created Project**
```bash
cd LibraryAPI
# Follow the exercise instructions
```

## 🚀 **Exercise-Specific Commands**

### **Module 3 - Working with Web APIs**

**Exercise 1: Create Basic API**
```bash
cd aspnet-core-training
./setup-exercise.sh exercise01-basic-api
cd LibraryAPI
# Now follow Exercise 1 instructions
```

**Exercise 2: Add Authentication & Security**
```bash
cd aspnet-core-training
./setup-exercise.sh exercise02-authentication
cd LibraryAPI
# Now follow Exercise 2 instructions
```

**Exercise 3: API Documentation & Versioning**
```bash
cd aspnet-core-training
./setup-exercise.sh exercise03-documentation
cd LibraryAPI
# Now follow Exercise 3 instructions
```

## ✅ **Verification Commands**

### **Check Package Versions**
```bash
# Run this inside your project directory (LibraryAPI)
../verify-packages.sh
```

### **Check if Everything Works**
```bash
# Build the project
dotnet build

# Run the project
dotnet run
```

## 🔄 **Typical Workflow**

1. **Start Exercise:**
   ```bash
   cd aspnet-core-training
   ./setup-exercise.sh exercise01-basic-api
   cd LibraryAPI
   ```

2. **Verify Setup:**
   ```bash
   ../verify-packages.sh
   dotnet build
   ```

3. **Follow Exercise Instructions:**
   - Open the exercise markdown file
   - Follow the step-by-step instructions
   - Create models, controllers, etc.

4. **Test Your Work:**
   ```bash
   dotnet run
   # Test endpoints with Swagger or curl
   ```

5. **Move to Next Exercise:**
   ```bash
   cd ..  # Back to aspnet-core-training
   ./setup-exercise.sh exercise02-authentication
   cd LibraryAPI
   ```

## 🆘 **Troubleshooting**

### **Setup Script Not Found**
```bash
# Make sure you're in the right directory
pwd
# Should show: .../aspnet-core-training

# Make script executable
chmod +x setup-exercise.sh
```

### **Package Version Issues**
```bash
# Check what's wrong
../verify-packages.sh

# If packages are incorrect, the script will show fix commands
# Example output:
# dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 8.0.11
```

### **Build Errors**
```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

### **Port Already in Use**
```bash
# Kill processes on port 5000
lsof -ti:5000 | xargs kill -9

# Or use a different port
dotnet run --urls="http://localhost:5001"
```

## 📁 **Directory Structure After Setup**

```
aspnet-core-training/
├── setup-exercise.sh          ← Run this for each exercise
├── verify-packages.sh         ← Check package versions
├── LibraryAPI/               ← Your working project
│   ├── LibraryAPI.csproj     ← Correct package versions
│   ├── Program.cs
│   └── ...
└── Module03-Working-with-Web-APIs/
    └── Exercises/
        ├── Exercise01-Create-Basic-API.md
        ├── Exercise02-Add-Authentication-Security.md
        └── Exercise03-API-Documentation-Versioning.md
```

## 💡 **Pro Tips**

1. **Always run setup script first** - Don't create projects manually
2. **Verify packages** - Run `../verify-packages.sh` if you have issues
3. **One exercise at a time** - Complete each exercise before moving to the next
4. **Keep terminal open** - You'll need it for running commands
5. **Read error messages** - They usually tell you exactly what's wrong

## 🎯 **Success Indicators**

✅ Setup script runs without errors  
✅ `../verify-packages.sh` shows all green checkmarks  
✅ `dotnet build` succeeds  
✅ `dotnet run` starts the application  
✅ Swagger UI loads at http://localhost:5000/swagger  

## 📞 **Getting Help**

If you encounter issues:
1. Run `../verify-packages.sh` to check your setup
2. Try the troubleshooting steps above
3. Ask your instructor for help
4. Share the exact error message you're seeing

---

**Remember: The setup script ensures everyone has the same environment, making it easier to follow along and get help when needed!** 🎉
