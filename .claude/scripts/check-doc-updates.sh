#!/bin/bash
# Check which documentation files need updates based on git changes

DOCS_DIR="docs"
SRC_DIR="src/Keycloak.ApiClient.Net"

# Mapping of doc folders/files to source directories
declare -A DOC_MAPPINGS=(
    ["user-management"]="Users"
    ["client-management"]="Clients"
    ["role-group-management"]="Roles,Groups,RoleMapper,ScopeMappings"
    ["realm-administration"]="RealmsAdmin,Root"
    ["authentication"]="KeycloakClient.cs,Common/Extensions"
)

echo "=== Documentation Update Check ==="
echo ""

for doc_area in "${!DOC_MAPPINGS[@]}"; do
    DOC_PATH="$DOCS_DIR/$doc_area/README.md"

    if [ ! -f "$DOC_PATH" ]; then
        echo "⚠️  $doc_area - File not found: $DOC_PATH"
        continue
    fi

    # Extract last hash
    LAST_HASH=$(grep "Git Commit:" "$DOC_PATH" | grep -oP '\(\K[^)]+' | head -1)
    CURRENT_HASH=$(git rev-parse HEAD)

    if [ -z "$LAST_HASH" ]; then
        echo "⚠️  $doc_area - No metadata found"
        continue
    fi

    if [ "$LAST_HASH" == "$CURRENT_HASH" ]; then
        echo "✅ $doc_area - Up to date"
        continue
    fi

    # Check if source files changed
    SOURCE_PATHS="${DOC_MAPPINGS[$doc_area]}"
    CHANGED=false

    IFS=',' read -ra PATHS <<< "$SOURCE_PATHS"
    for path in "${PATHS[@]}"; do
        if git diff --quiet $LAST_HASH HEAD -- "$SRC_DIR/$path" 2>/dev/null; then
            continue
        else
            CHANGED=true
            break
        fi
    done

    if [ "$CHANGED" = true ]; then
        echo "🔄 $doc_area - Needs update"
        echo "   Last: $LAST_HASH"
        echo "   Current: $CURRENT_HASH"
        echo "   Changed files:"
        for path in "${PATHS[@]}"; do
            git diff --stat $LAST_HASH HEAD -- "$SRC_DIR/$path" 2>/dev/null | sed 's/^/   /'
        done
        echo ""
    else
        echo "ℹ️  $doc_area - Code unchanged (metadata update only needed)"
    fi
done

echo ""
echo "=== Summary ==="
echo "Documentation is now organized into folders:"
echo "  docs/authentication/"
echo "  docs/user-management/"
echo "  docs/client-management/"
echo "  docs/realm-administration/"
echo "  docs/role-group-management/"
echo ""
echo "Run this script from the repository root to check documentation status."
echo "To see detailed changes for a specific area:"
echo "  bash .claude/scripts/analyze-doc-changes.sh <folder-name>"
