#!/bin/bash
set -e

# Vibe post_tool hook — ported from the Claude Code post-tool-use tracker.
# Runs after edit/write_file tools; tracks edited files and their repos.
# Payload protocol: https://docs.mistral.ai — JSON on stdin, exit 0 + empty
# stdout passes through.

tool_info=$(cat)

tool_name=$(echo "$tool_info" | jq -r '.tool_name // empty')
file_path=$(echo "$tool_info" | jq -r '.tool_input.file_path // .tool_input.path // empty')
session_id=$(echo "$tool_info" | jq -r '.session_id // empty')
project_dir=$(echo "$tool_info" | jq -r '.cwd // empty')

# Skip if no file path or no project dir
if [[ -z "$file_path" ]] || [[ -z "$project_dir" ]]; then
    exit 0
fi

# Skip non-edit tools (Vibe qualified names: file_system.edit / file_system.write_file)
if [[ ! "$tool_name" =~ ^(file_system\.)?(edit|write_file)$ ]]; then
    exit 0
fi

# Skip markdown files
if [[ "$file_path" =~ \.(md|markdown)$ ]]; then
    exit 0
fi

# Create cache directory in project
cache_dir="$project_dir/.vibe/tsc-cache/${session_id:-default}"
mkdir -p "$cache_dir"

# Function to detect repo from file path
detect_repo() {
    local file="$1"
    local project_root="$project_dir"

    # Remove project root from path
    local relative_path="${file#$project_root/}"

    # Extract first directory component
    local repo=$(echo "$relative_path" | cut -d'/' -f1)

    case "$repo" in
        frontend|client|web|app|ui)
            echo "$repo"
            ;;
        backend|server|api|src|services)
            echo "$repo"
            ;;
        database|prisma|migrations)
            echo "$repo"
            ;;
        packages)
            local package=$(echo "$relative_path" | cut -d'/' -f2)
            if [[ -n "$package" ]]; then
                echo "packages/$package"
            else
                echo "$repo"
            fi
            ;;
        examples)
            local example=$(echo "$relative_path" | cut -d'/' -f2)
            if [[ -n "$example" ]]; then
                echo "examples/$example"
            else
                echo "$repo"
            fi
            ;;
        *)
            if [[ ! "$relative_path" =~ / ]]; then
                echo "root"
            else
                echo "unknown"
            fi
            ;;
    esac
}

# Function to get build command for repo
get_build_command() {
    local repo="$1"
    local repo_path="$project_dir/$repo"

    if [[ -f "$repo_path/package.json" ]]; then
        if grep -q '"build"' "$repo_path/package.json" 2>/dev/null; then
            if [[ -f "$repo_path/pnpm-lock.yaml" ]]; then
                echo "cd $repo_path && pnpm build"
            elif [[ -f "$repo_path/package-lock.json" ]]; then
                echo "cd $repo_path && npm run build"
            elif [[ -f "$repo_path/yarn.lock" ]]; then
                echo "cd $repo_path && yarn build"
            else
                echo "cd $repo_path && npm run build"
            fi
            return
        fi
    fi

    if [[ "$repo" == "database" ]] || [[ "$repo" =~ prisma ]]; then
        if [[ -f "$repo_path/schema.prisma" ]] || [[ -f "$repo_path/prisma/schema.prisma" ]]; then
            echo "cd $repo_path && npx prisma generate"
            return
        fi
    fi

    echo ""
}

# Function to get TSC command for repo
get_tsc_command() {
    local repo="$1"
    local repo_path="$project_dir/$repo"

    if [[ -f "$repo_path/tsconfig.json" ]]; then
        if [[ -f "$repo_path/tsconfig.app.json" ]]; then
            echo "cd $repo_path && npx tsc --project tsconfig.app.json --noEmit"
        else
            echo "cd $repo_path && npx tsc --noEmit"
        fi
        return
    fi

    echo ""
}

# Detect repo
repo=$(detect_repo "$file_path")

if [[ "$repo" == "unknown" ]] || [[ -z "$repo" ]]; then
    exit 0
fi

# Log edited file
echo "$(date +%s):$file_path:$repo" >> "$cache_dir/edited-files.log"

# Update affected repos list
if ! grep -q "^$repo$" "$cache_dir/affected-repos.txt" 2>/dev/null; then
    echo "$repo" >> "$cache_dir/affected-repos.txt"
fi

# Store build commands
build_cmd=$(get_build_command "$repo")
tsc_cmd=$(get_tsc_command "$repo")

if [[ -n "$build_cmd" ]]; then
    echo "$repo:build:$build_cmd" >> "$cache_dir/commands.txt.tmp"
fi

if [[ -n "$tsc_cmd" ]]; then
    echo "$repo:tsc:$tsc_cmd" >> "$cache_dir/commands.txt.tmp"
fi

if [[ -f "$cache_dir/commands.txt.tmp" ]]; then
    sort -u "$cache_dir/commands.txt.tmp" > "$cache_dir/commands.txt"
    rm -f "$cache_dir/commands.txt.tmp"
fi

exit 0
