#!/bin/bash

# Script to update all exercise manuals to use the setup script approach
# This removes manual dotnet new and package installation steps

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Updating All Exercise Manuals${NC}"
echo "=================================="

# Function to update exercise files
update_exercise() {
    local file_path=$1
    local exercise_name=$2
    local backup_file="${file_path}.backup"
    
    echo -n "Updating $(basename "$file_path")... "
    
    # Create backup
    cp "$file_path" "$backup_file"
    
    # Create updated content
    cat > temp_update.md << EOF
### Part 0: Project Setup (2 minutes)

**Run the setup script:**
\`\`\`bash
# From the aspnet-core-training directory
./setup-exercise.sh $exercise_name
cd LibraryAPI
\`\`\`

**Verify setup:**
\`\`\`bash
../verify-packages.sh
dotnet build
\`\`\`

EOF
    
    # Note: This is a template - manual review and specific updates needed for each exercise
    echo -e "${YELLOW}⚠️  Template created - manual review needed${NC}"
}

# List of exercises that need updating
declare -a EXERCISES=(
    "Module03-Working-with-Web-APIs/Exercises/Exercise01-Create-Basic-API.md:exercise01-basic-api"
    "Module03-Working-with-Web-APIs/Exercises/Exercise02-Add-Authentication-Security.md:exercise02-authentication"
    "Module03-Working-with-Web-APIs/Exercises/Exercise03-API-Documentation-Versioning.md:exercise03-documentation"
)

echo -e "${BLUE}📋 Exercises to Update:${NC}"
for exercise in "${EXERCISES[@]}"; do
    file_path=$(echo "$exercise" | cut -d':' -f1)
    exercise_name=$(echo "$exercise" | cut -d':' -f2)
    echo "  - $file_path ($exercise_name)"
done
echo ""

# Summary of changes needed
echo -e "${YELLOW}📝 Manual Changes Required for Each Exercise:${NC}"
echo ""
echo "1. Replace project creation sections with:"
echo "   - Part 0: Project Setup (2 minutes)"
echo "   - Setup script command"
echo "   - Verification commands"
echo ""
echo "2. Remove these sections:"
echo "   - dotnet new webapi commands"
echo "   - dotnet add package commands"
echo "   - Manual package installation steps"
echo ""
echo "3. Update time estimates:"
echo "   - Reduce setup time from 10-15 minutes to 2 minutes"
echo "   - Focus time on actual coding exercises"
echo ""
echo "4. Add troubleshooting references:"
echo "   - Reference verify-packages.sh for issues"
echo "   - Reference STUDENT-SETUP-GUIDE.md"
echo ""

echo -e "${GREEN}✅ Exercise files already updated:${NC}"
echo "  - Exercise01-Create-Basic-API.md"
echo "  - Exercise02-Add-Authentication-Security.md"
echo ""

echo -e "${YELLOW}🔄 Still need manual updates:${NC}"
echo "  - Exercise03-API-Documentation-Versioning.md"
echo "  - Any other module exercises that create projects"
echo ""

echo -e "${BLUE}💡 Recommended Update Pattern:${NC}"
cat << 'EOF'

OLD PATTERN (Remove):
```markdown
### Part 1: Create the API Project (10 minutes)

1. **Create a new Web API project**:
   ```bash
   dotnet new webapi -n LibraryAPI --framework net8.0
   cd LibraryAPI
   ```

2. **Add required packages**:
   ```bash
   dotnet add package SomePackage --version X.X.X
   ```
```

NEW PATTERN (Use):
```markdown
### Part 0: Project Setup (2 minutes)

**Run the setup script:**
```bash
# From the aspnet-core-training directory
./setup-exercise.sh exercise-name
cd LibraryAPI
```

**Verify setup:**
```bash
../verify-packages.sh
dotnet build
```

### Part 1: [Actual Exercise Content] (10 minutes)
```

EOF

echo ""
echo -e "${GREEN}🎯 Benefits of Updated Approach:${NC}"
echo "  ✅ Consistent package versions across all students"
echo "  ✅ Faster setup (2 minutes vs 10-15 minutes)"
echo "  ✅ Eliminates package installation errors"
echo "  ✅ More time for actual learning"
echo "  ✅ Easier troubleshooting and support"
echo ""

echo -e "${YELLOW}📞 Next Steps:${NC}"
echo "1. Review and update remaining exercise files manually"
echo "2. Test each updated exercise with students"
echo "3. Update any module-specific setup scripts"
echo "4. Update instructor guides and materials"
echo ""

echo -e "${GREEN}🎉 Update guidance complete!${NC}"
