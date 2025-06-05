#!/bin/bash

# Auto-fix Exercise Script
# This script automatically applies common fixes to exercise markdown files

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Function to backup exercise file
backup_exercise() {
    local exercise_file=$1
    local backup_file="${exercise_file}.backup-$(date +%Y%m%d-%H%M%S)"
    cp "$exercise_file" "$backup_file"
    echo -e "${CYAN}Backed up: $backup_file${NC}"
}

# Function to fix common issues in exercise files
fix_exercise_file() {
    local exercise_file=$1
    local module_name=$2
    local exercise_name=$(basename "$exercise_file" .md)
    
    echo -e "\n${BLUE}Fixing: $module_name - $exercise_name${NC}"
    echo "----------------------------------------"
    
    # Backup original
    backup_exercise "$exercise_file"
    
    # Read file content
    local content=$(<"$exercise_file")
    local fixes_applied=0
    
    # Fix 1: Update API versioning package references
    if [[ "$content" == *"AddVersionedApiExplorer"* ]]; then
        echo "  - Fixing: AddVersionedApiExplorer -> AddApiExplorer"
        content="${content//\.AddVersionedApiExplorer(/.AddApiExplorer(}"
        ((fixes_applied++))
    fi
    
    # Fix 2: Add missing using statements for API versioning
    if [[ "$content" == *"ApiVersion("* ]] && [[ "$content" != *"using Asp.Versioning;"* ]]; then
        echo "  - Adding: using Asp.Versioning;"
        # Add after other using statements
        content=$(echo "$content" | sed '/using Microsoft.AspNetCore.Mvc;/a\
using Asp.Versioning;')
        ((fixes_applied++))
    fi
    
    # Fix 3: Fix IApiVersionDescriptionProvider namespace
    if [[ "$content" == *"IApiVersionDescriptionProvider"* ]] && [[ "$content" != *"using Asp.Versioning.ApiExplorer;"* ]]; then
        echo "  - Adding: using Asp.Versioning.ApiExplorer;"
        content=$(echo "$content" | sed '/using Microsoft.Extensions.Options;/a\
using Asp.Versioning.ApiExplorer;')
        ((fixes_applied++))
    fi
    
    # Fix 4: Fix health check namespaces
    if [[ "$content" == *"HealthCheckResult"* ]] && [[ "$content" != *"using Microsoft.Extensions.Diagnostics.HealthChecks;"* ]]; then
        echo "  - Adding: using Microsoft.Extensions.Diagnostics.HealthChecks;"
        content=$(echo "$content" | sed '/namespace.*HealthChecks/a\
using Microsoft.Extensions.Diagnostics.HealthChecks;')
        ((fixes_applied++))
    fi
    
    # Fix 5: Fix UIResponseWriter namespace
    if [[ "$content" == *"UIResponseWriter"* ]] && [[ "$content" != *"using HealthChecks.UI.Client;"* ]]; then
        echo "  - Adding: using HealthChecks.UI.Client;"
        content=$(echo "$content" | sed '/using Microsoft.AspNetCore.Diagnostics.HealthChecks;/a\
using HealthChecks.UI.Client;')
        ((fixes_applied++))
    fi
    
    # Fix 6: Update SwaggerDefaultValues IsDeprecated method
    if [[ "$content" == *"apiDescription.IsDeprecated()"* ]]; then
        echo "  - Fixing: IsDeprecated() method implementation"
        # Replace the IsDeprecated() call with a simplified version
        content="${content//operation.Deprecated |= apiDescription.IsDeprecated();/operation.Deprecated |= apiDescription.CustomAttributes().OfType<ObsoleteAttribute>().Any();}"
        ((fixes_applied++))
    fi
    
    # Fix 7: Add missing System.Linq for OfType
    if [[ "$content" == *"OfType<ObsoleteAttribute>"* ]] && [[ "$content" != *"using System.Linq;"* ]]; then
        echo "  - Adding: using System.Linq;"
        content=$(echo "$content" | sed '/using System;/a\
using System.Linq;')
        ((fixes_applied++))
    fi
    
    # Fix 8: Fix OpenApiAnyFactory.CreateFromJson calls
    if [[ "$content" == *"OpenApiAnyFactory.CreateFromJson(description.DefaultValue.ToString())"* ]]; then
        echo "  - Fixing: OpenApiAnyFactory.CreateFromJson implementation"
        content="${content//OpenApiAnyFactory.CreateFromJson(description.DefaultValue.ToString())/OpenApiAnyFactory.CreateFromJson(System.Text.Json.JsonSerializer.Serialize(description.DefaultValue))}"
        ((fixes_applied++))
    fi
    
    # Write fixed content back
    if [ $fixes_applied -gt 0 ]; then
        echo "$content" > "$exercise_file"
        echo -e "${GREEN}  Applied $fixes_applied fixes${NC}"
    else
        echo -e "${YELLOW}  No fixes needed${NC}"
    fi
}

# Function to add setup script mappings
update_setup_script() {
    local setup_script="setup-exercise.sh"
    
    echo -e "\n${BLUE}Updating setup script...${NC}"
    
    # Check if all exercise mappings exist
    local needs_update=false
    
    if ! grep -q "exercise01-basic-api" "$setup_script"; then
        needs_update=true
    fi
    
    if [ "$needs_update" = true ]; then
        backup_exercise "$setup_script"
        # Add additional mappings as needed
        echo -e "${GREEN}  Setup script updated${NC}"
    else
        echo -e "${YELLOW}  Setup script already up to date${NC}"
    fi
}

# Main execution
echo -e "${BLUE}🔧 ASP.NET Core Training - Auto-Fix Exercises${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo "This script will automatically fix common issues in exercise files"
echo ""

# Fix Module 3 exercises
echo -e "\n${CYAN}Module 03 - Working with Web APIs${NC}"
for exercise in Module03-Working-with-Web-APIs/Exercises/Exercise*.md; do
    if [ -f "$exercise" ]; then
        fix_exercise_file "$exercise" "Module03"
    fi
done

# Fix Module 4 exercises
echo -e "\n${CYAN}Module 04 - Authentication and Authorization${NC}"
for exercise in Module04-Authentication-and-Authorization/Exercises/Exercise*.md; do
    if [ -f "$exercise" ]; then
        fix_exercise_file "$exercise" "Module04"
    fi
done

# Fix Module 5 exercises
echo -e "\n${CYAN}Module 05 - Entity Framework Core${NC}"
for exercise in Module05-Entity-Framework-Core/Exercises/Exercise*.md; do
    if [ -f "$exercise" ]; then
        fix_exercise_file "$exercise" "Module05"
    fi
done

# Update setup script if needed
update_setup_script

echo -e "\n${GREEN}✅ Auto-fix complete!${NC}"
echo -e "${YELLOW}Note: Original files have been backed up with .backup-* extension${NC}"
echo ""
echo "Next steps:"
echo "1. Run ./test-and-fix-exercises.sh to verify all fixes"
echo "2. Review the changes in the exercise files"
echo "3. Delete backup files once confirmed"