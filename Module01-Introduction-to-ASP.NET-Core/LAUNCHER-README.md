# Module 1 Exercise Launcher

This module has its own interactive exercise launcher specifically designed for ASP.NET Core introduction exercises.

## 🚀 Quick Start

```bash
# Make sure you're in the Module 1 directory
cd Module01-Introduction-to-ASP.NET-Core

# Run the interactive launcher
./launch-exercises.sh
```

## 📋 Available Options

### Interactive Mode (Default)
```bash
./launch-exercises.sh
```
- Provides a menu-driven interface
- Includes learning objectives and key concepts
- Offers step-by-step guidance for each exercise
- Checks prerequisites before starting

### List Exercises
```bash
./launch-exercises.sh --list
# or
./launch-exercises.sh -l
```
Shows all available exercises with their status (completed/not started).

### Auto Setup
```bash
./launch-exercises.sh --auto
# or
./launch-exercises.sh -a
```
Automatically sets up all exercises without interaction.

### Preview Exercise
```bash
./launch-exercises.sh --preview exercise01
# or
./launch-exercises.sh -p exercise01
```
Preview what you'll learn in a specific exercise.

### Help
```bash
./launch-exercises.sh --help
# or
./launch-exercises.sh -h
```

## 🎯 Module 1 Exercises

1. **Exercise 01: Create Your First App**
   - Create a new ASP.NET Core web application
   - Run and explore the default template
   - Make basic modifications

2. **Exercise 02: Explore Project Structure**
   - Understand the project organization
   - Learn about Program.cs and middleware pipeline
   - Explore configuration files

3. **Exercise 03: Configuration and Middleware**
   - Implement strongly-typed configuration
   - Create custom middleware components
   - Use feature flags

## 📚 Learning Features

The launcher includes:
- **Interactive Teaching**: Concepts are explained as you progress
- **Visual Diagrams**: Request pipeline and architecture diagrams
- **Progress Tracking**: Exercises are marked as complete
- **Prerequisite Checking**: Ensures you have .NET SDK installed
- **Progressive Learning**: Exercise 2 and 3 build on Exercise 1

## 🛠️ Prerequisites

Before running the exercises, ensure you have:
- .NET 8.0 SDK or later
- A code editor (VS Code recommended)
- Basic knowledge of C#

## 📁 Exercise Structure

Exercises are created in:
```
../exercise-work/module01/
├── exercise01/
│   └── MyFirstWebApp/
├── exercise02/
│   └── MyFirstWebApp/
└── exercise03/
    └── MyFirstWebApp/
```

## 🆘 Troubleshooting

If you encounter issues:
1. Run `./launch-exercises.sh --help` to see all options
2. Check prerequisites with option 2 in the menu
3. Ensure you have proper permissions to create directories
4. Make sure the script is executable: `chmod +x launch-exercises.sh`

## 📖 Additional Resources

- Full exercise instructions: `Exercises/` directory
- Example code: `SourceCode/` directory
- Reference materials: `Resources/` directory

Happy learning! 🚀