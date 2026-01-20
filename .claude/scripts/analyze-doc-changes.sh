#!/bin/bash
# Analyze changes for a specific documentation file since last update
# Usage: ./analyze-doc-changes.sh <doc-file-name>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <doc-file-name>"
    echo "Example: $0 user-management-operations.md"
    exit 1
fi

DOC_FILE="$1"
DOC_PATH="docs/$DOC_FILE"

# Mapping of doc files to source directories
declare -A DOC_MAPPINGS=(
    ["user-management-operations.md"]="Users"
    ["client-management-operations.md"]="Clients"
    ["role-group-management-operations.md"]="Roles,Groups,RoleMapper,ScopeMappings"
    ["realm-administration-operations.md"]="RealmsAdmin,Root"
    ["authentication-core.md"]="KeycloakClient.cs,Common/Extensions"
)

if [ ! -f "$DOC_PATH" ]; then
    echo "Error: Documentation file not found: $DOC_PATH"
    exit 1
fi

if [ -z "${DOC_MAPPINGS[$DOC_FILE]}" ]; then
    echo "Error: No source mapping found for $DOC_FILE"
    echo "Available files:"
    for key in "${!DOC_MAPPINGS[@]}"; do
        echo "  - $key"
    done
    exit 1
fi

# Extract last hash
LAST_HASH=$(grep "Git Commit:" "$DOC_PATH" | grep -oP '\(\K[^)]+' | head -1)
CURRENT_HASH=$(git rev-parse HEAD)
CURRENT_HASH_SHORT=$(git rev-parse --short HEAD)

if [ -z "$LAST_HASH" ]; then
    echo "Error: No metadata found in $DOC_PATH"
    echo "Documentation should include a metadata header like:"
    echo ""
    echo "> **Document Metadata**"
    echo "> Last Updated: YYYY-MM-DD HH:MM:SS UTC"
    echo "> Git Commit: \`short-hash\` (full-hash)"
    echo "> Library Version: X.Y.Z"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║         Documentation Change Analysis                              ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Documentation: $DOC_FILE"
echo "Last Documented: $LAST_HASH"
echo "Current Commit:  $CURRENT_HASH ($CURRENT_HASH_SHORT)"
echo ""

if [ "$LAST_HASH" == "$CURRENT_HASH" ]; then
    echo "✅ Documentation is up to date!"
    exit 0
fi

# Get source paths
SOURCE_PATHS="${DOC_MAPPINGS[$DOC_FILE]}"
SRC_DIR="src/Keycloak.ApiClient.Net"

echo "Source directories: $SOURCE_PATHS"
echo ""

# Check each source path
IFS=',' read -ra PATHS <<< "$SOURCE_PATHS"
ANY_CHANGES=false

for path in "${PATHS[@]}"; do
    FULL_PATH="$SRC_DIR/$path"

    if ! git diff --quiet $LAST_HASH HEAD -- "$FULL_PATH" 2>/dev/null; then
        ANY_CHANGES=true

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📁 $path"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        echo "📊 File Statistics:"
        git diff --stat $LAST_HASH HEAD -- "$FULL_PATH" | sed 's/^/   /'
        echo ""

        echo "📝 Commits:"
        git log --oneline --decorate $LAST_HASH..HEAD -- "$FULL_PATH" | sed 's/^/   /'
        echo ""

        echo "🔍 Public Method Changes:"
        NEW_METHODS=$(git diff $LAST_HASH HEAD -- "$FULL_PATH" | grep -E '^\+.*public (async )?Task' | sed 's/^+//' | sed 's/^/   + /')
        REMOVED_METHODS=$(git diff $LAST_HASH HEAD -- "$FULL_PATH" | grep -E '^\-.*public (async )?Task' | sed 's/^-//' | sed 's/^/   - /')

        if [ ! -z "$NEW_METHODS" ]; then
            echo "   Added:"
            echo "$NEW_METHODS"
        fi

        if [ ! -z "$REMOVED_METHODS" ]; then
            echo "   Removed:"
            echo "$REMOVED_METHODS"
        fi

        if [ -z "$NEW_METHODS" ] && [ -z "$REMOVED_METHODS" ]; then
            echo "   No public method signature changes detected"
            echo "   (May be implementation changes, comments, or refactoring)"
        fi
        echo ""
    fi
done

# Check model changes
MODEL_PATH="src/Keycloak.ApiClient.Net/Models/${SOURCE_PATHS%%,*}/"
if [ -d "$MODEL_PATH" ]; then
    if ! git diff --quiet $LAST_HASH HEAD -- "$MODEL_PATH" 2>/dev/null; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Model Changes: ${SOURCE_PATHS%%,*}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        git diff --stat $LAST_HASH HEAD -- "$MODEL_PATH" | sed 's/^/   /'
        echo ""
    fi
fi

if [ "$ANY_CHANGES" = false ]; then
    echo "ℹ️  No source code changes detected."
    echo "   Only metadata update needed (timestamp and git hash)"
else
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════╗"
    echo "║  Recommended Actions                                               ║"
    echo "╚════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "1. Review the changes above"
    echo "2. Update $DOC_FILE following .claude/protocols/update-documentation.md"
    echo "3. Add/update documentation for new/changed methods"
    echo "4. Add PlantUML sequence diagrams for complex new operations"
    echo "5. Update code examples if behavior changed"
    echo "6. Update metadata header:"
    echo "   - Last Updated: $(date -u +'%Y-%m-%d %H:%M:%S') UTC"
    echo "   - Git Commit: \`$CURRENT_HASH_SHORT\` ($CURRENT_HASH)"
    echo ""
    echo "To see detailed diff:"
    echo "   git diff $LAST_HASH HEAD -- $SRC_DIR/${SOURCE_PATHS%%,*}/"
fi
