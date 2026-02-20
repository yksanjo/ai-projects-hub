#!/bin/bash
###############################################################################
# META-FACTORY: Generate 10 AI Infrastructure Projects
# Each project: 8 core + 8 features + 8 verticals × 5 = 56 packages
# Total: 10 × 56 = 560 packages
###############################################################################

set -e

HUB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 10 AI Infrastructure Projects
PROJECTS=(
    "ai-ml-ops:Machine Learning Operations Platform:ml,mlops,training,deployment"
    "ai-edge-compute:Edge AI and IoT Inference:edge,iot,mobile,embedded"
    "ai-cloud-native:Cloud-Native AI Services:cloud,kubernetes,serverless,scalable"
    "ai-data-platform:AI Data Platform and Lakehouse:data,lakehouse,etl,analytics"
    "ai-security-governance:AI Security and Governance:security,governance,compliance,privacy"
    "ai-observability:AI Observability and Monitoring:observability,monitoring,logging,tracing"
    "ai-workflow-orchestration:AI Workflow and Pipeline Orchestration:workflow,pipeline,automation,dag"
    "ai-model-marketplace:AI Model Marketplace and Registry:marketplace,registry,sharing,discovery"
    "ai-llm-platform:LLM and Foundation Model Platform:llm,foundation,prompt,fine-tuning"
    "ai-robotics-automation:AI Robotics and Process Automation:robotics,rpa,automation,agents"
)

# Packages per project
CORE_PKGS=(
    "api-gateway:API Gateway and Routing"
    "sdk-client:SDK and Client Libraries"
    "config-manager:Configuration Management"
    "auth-security:Authentication and Security"
    "logging-monitoring:Logging and Monitoring"
    "cache-storage:Caching and Storage"
    "queue-messaging:Queue and Messaging"
    "scheduler-jobs:Scheduling and Jobs"
)

FEATURE_PKGS=(
    "auto-scaling:Automatic Scaling"
    "load-balancing:Load Balancing"
    "rate-limiting:Rate Limiting"
    "circuit-breaker:Circuit Breaker"
    "retry-logic:Retry Logic"
    "health-checks:Health Checks"
    "metrics-collection:Metrics Collection"
    "alerting:Alerting System"
)

VERTICALS=(
    "vision:Computer Vision and Image Processing"
    "language:Natural Language Processing"
    "audio:Speech and Audio Processing"
    "tabular:Tabular Data and Analytics"
    "timeseries:Time Series Analysis"
    "graph:Graph Neural Networks"
    "reinforcement:Reinforcement Learning"
    "multimodal:Multimodal AI"
)

print_banner() {
    echo -e "\033[0;36m"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║           META-FACTORY - AI PROJECT GENERATOR             ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
}

print_project() {
    echo -e "\033[1;33m"
    echo "═══════════════════════════════════════════════════════════"
    echo "  PROJECT: $1"
    echo "═══════════════════════════════════════════════════════════"
    echo -e "\033[0m"
}

# Create a single package
create_package() {
    local pkg_dir=$1
    local pkg_name=$2
    local pkg_desc=$3
    local project_name=$4
    
    mkdir -p "$pkg_dir"/{src,tests,examples}
    
    cat > "$pkg_dir/package.json" << EOF
{
  "name": "@$project_name/$pkg_name",
  "version": "1.0.0",
  "description": "$pkg_desc",
  "main": "src/index.js",
  "type": "module",
  "scripts": {
    "test": "jest",
    "start": "node src/index.js",
    "dev": "node --watch src/index.js"
  },
  "keywords": ["ai", "$project_name", "$pkg_name"],
  "author": "Yoshi Kondo <yoshi@musicailab.com>",
  "license": "MIT"
}
EOF

    local class_name=$(echo "$pkg_name" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | sed 's/ //g')
    
    cat > "$pkg_dir/src/index.js" << EOF
/**
 * $pkg_name
 * $pkg_desc
 * Project: $project_name
 */

export class $class_name {
  constructor(options = {}) {
    this.name = '$pkg_name';
    this.project = '$project_name';
    this.options = options;
    this.initialized = false;
  }

  async init() {
    this.initialized = true;
    return { status: 'initialized', service: this.name, project: this.project };
  }

  async execute(data) {
    if (!this.initialized) await this.init();
    return { success: true, service: this.name, project: this.project, data, timestamp: Date.now() };
  }

  async health() {
    return { service: this.name, status: this.initialized ? 'healthy' : 'uninitialized' };
  }
}

export default $class_name;
EOF

    cat > "$pkg_dir/README.md" << EOF
# $pkg_name

> $pkg_desc

## Installation

\`\`\`bash
npm install @$project_name/$pkg_name
\`\`\`

## Usage

\`\`\`javascript
import { $class_name } from '@$project_name/$pkg_name';

const service = new $class_name();
await service.init();
\`\`\`

## License

MIT
EOF
}

# Generate one complete project
generate_project() {
    local project_key=$1
    local project_name=$2
    local tags=$3
    
    local project_dir="$HUB_ROOT/$project_key"
    print_project "$project_name ($project_key)"
    
    mkdir -p "$project_dir"/{packages,features,verticals}
    
    # Core packages
    echo "  Creating core packages..."
    for pkg_info in "${CORE_PKGS[@]}"; do
        IFS=':' read -r pkg_name pkg_desc <<< "$pkg_info"
        create_package "$project_dir/packages/$pkg_name" "$pkg_name" "$pkg_desc" "$project_key"
        echo -n "."
    done
    echo " ✓"
    
    # Advanced features
    echo "  Creating advanced features..."
    for feat_info in "${FEATURE_PKGS[@]}"; do
        IFS=':' read -r feat_name feat_desc <<< "$feat_info"
        create_package "$project_dir/features/$feat_name" "$feat_name" "$feat_desc" "$project_key"
        echo -n "."
    done
    echo " ✓"
    
    # Verticals (5 packages each)
    echo "  Creating verticals..."
    for vert_info in "${VERTICALS[@]}"; do
        IFS=':' read -r vert_name vert_desc <<< "$vert_info"
        for pkg_type in api sdk models pipelines connectors; do
            local pkg_name="$vert_name-$pkg_type"
            create_package "$project_dir/verticals/$pkg_name" "$pkg_name" "$pkg_type for $vert_desc" "$project_key"
        done
        echo -n "."
    done
    echo " ✓"
    
    # Root package.json
    cat > "$project_dir/package.json" << EOF
{
  "name": "$project_key",
  "version": "1.0.0",
  "description": "$project_name",
  "private": true,
  "workspaces": ["packages/*", "features/*", "verticals/*"],
  "scripts": {
    "test": "npm run test --workspaces --if-present",
    "dev": "npm run dev --workspaces --if-present"
  },
  "keywords": ["ai", "$tags"],
  "author": "Yoshi Kondo <yoshi@musicailab.com>",
  "license": "MIT"
}
EOF

    # Root README
    cat > "$project_dir/README.md" << EOF
# $project_name

> $project_name - AI Infrastructure

## Packages

- **Core:** $(ls -1 packages/ | wc -l) packages
- **Features:** $(ls -1 features/ | wc -l) packages  
- **Verticals:** $(ls -1 verticals/ | wc -l) packages

## Quick Start

\`\`\`bash
npm install
npm run dev
\`\`\`

## License

MIT
EOF

    # .gitignore
    echo "node_modules/" > "$project_dir/.gitignore"
    
    echo ""
    echo "  ✓ Project $project_key complete!"
    echo ""
}

# Main execution
main() {
    print_banner
    
    echo "Generating 10 AI Infrastructure Projects..."
    echo "Each project: 8 core + 8 features + 40 verticals = 56 packages"
    echo "Total: 10 × 56 = 560 packages"
    echo ""
    
    local count=0
    for proj_info in "${PROJECTS[@]}"; do
        IFS=':' read -r proj_key proj_name proj_tags <<< "$proj_info"
        generate_project "$proj_key" "$proj_name" "$proj_tags"
        count=$((count + 1))
        echo "Progress: $count/10 projects"
        echo ""
    done
    
    print_banner
    echo "✓ META-FACTORY COMPLETE!"
    echo ""
    echo "📊 SUMMARY:"
    echo "   Projects: 10"
    echo "   Packages per project: 56"
    echo "   TOTAL PACKAGES: 560"
    echo ""
    echo "📁 Location: $HUB_ROOT"
    echo ""
}

main "$@"
