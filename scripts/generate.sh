#!/bin/bash
# Script to regenerate all code-generated files

echo "🔄 Regenerating code files..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get

# Generate all code
echo "⚡ Running code generation..."
dart run build_runner build --delete-conflicting-outputs

# Check for any issues
echo "🔍 Running analysis..."
flutter analyze

echo "✅ Code generation complete!"
echo ""
echo "Generated files are hidden by .gitignore and VS Code settings."
echo "Run this script anytime you modify models or providers."