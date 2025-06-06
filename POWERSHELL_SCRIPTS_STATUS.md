# PowerShell Scripts Status

## Fixed and Ready to Use
- **Module01** - Introduction to ASP.NET Core: ✅ Fixed (no Unicode, proper here-strings)
- **Module02** - ASP.NET Core with React: ✅ Fixed (no Unicode, proper here-strings)
- **Module03** - Working with Web APIs: ✅ Already clean (no Unicode issues)
- **Module04** - Authentication and Authorization: ✅ Already clean (no Unicode issues)
- **Module05** - Entity Framework Core: ✅ Fixed (no Unicode)
- **Module06** - Debugging and Troubleshooting: ✅ Fixed (no Unicode)
- **Module07** - Testing Applications: ✅ Fixed (no Unicode)
- **Module08** - Performance Optimization: ❌ Needs fixing (still has Unicode)

## Common Issues Fixed
1. **Unicode/Emoji Characters**: Replaced with text equivalents
   - 📄 → [FILE]
   - ✅ → [OK]
   - 🚀 → [LAUNCH]
   - etc.

2. **Here-String Bullet Points**: Changed from `-` to `*`
   - PowerShell interprets `-` at the start of a line as an operator
   - Using `*` or other characters avoids this issue

## Usage Instructions
To use any PowerShell script:
```powershell
cd Module01-Introduction-to-ASP.NET-Core
.\launch-exercises.ps1 -List
.\launch-exercises.ps1 exercise01
```

## Module08 Still Needs Fixing
Module08 fix was interrupted. To complete:
1. Remove remaining Unicode characters
2. Check for here-string issues with hyphens
3. Test the script

## Testing Commands
To test a script:
```powershell
# List available exercises
.\launch-exercises.ps1 -List

# Run in preview mode (no files created)
.\launch-exercises.ps1 exercise01 -Preview

# Run in automatic mode (skip prompts)
.\launch-exercises.ps1 exercise01 -Auto
```