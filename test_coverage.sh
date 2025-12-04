#!/bin/bash

# Test Coverage Script for EdWise
# This script runs all tests and generates coverage reports

echo "🧪 Running Flutter tests with coverage..."

# Run tests with coverage
flutter test --coverage

# Check if lcov is installed
if ! command -v lcov &> /dev/null; then
    echo ""
    echo "lcov is not installed. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install lcov
    else
        echo "Homebrew not found. Please install lcov manually:"
        echo "   macOS: brew install lcov"
        echo "   Linux: sudo apt-get install lcov"
        echo ""
        echo "Coverage data has been generated at: coverage/lcov.info"
        echo "You can view it using any LCOV viewer after installing lcov."
        exit 1
    fi
fi

if ! command -v genhtml &> /dev/null; then
    echo "genhtml (part of lcov) is not found. Please ensure lcov is properly installed."
    exit 1
fi

echo "Generating coverage report..."

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html

echo "Coverage report generated at: coverage/html/index.html"
echo "Opening coverage report..."

# Open coverage report in default browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    open coverage/html/index.html 2>/dev/null
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open coverage/html/index.html 2>/dev/null
else
    echo "Please open coverage/html/index.html manually"
fi

echo ""
echo "Coverage Summary:"
lcov --summary coverage/lcov.info

