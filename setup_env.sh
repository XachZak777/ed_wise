#!/bin/bash

# EdWise Environment Setup Script
echo "🚀 Setting up EdWise environment variables..."

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists. Backing up to .env.backup"
    cp .env .env.backup
fi

# Copy .env.example to .env
if [ -f ".env.example" ]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
    echo ""
    echo "📝 Next steps:"
    echo "1. Open .env file and replace placeholder values with your actual Firebase credentials"
    echo "2. Get your Firebase credentials from: https://console.firebase.google.com/"
    echo "3. Run 'flutter pub get' to install dependencies"
    echo "4. Run 'flutter run' to start the app"
    echo ""
    echo "🔒 Remember: Never commit .env to version control!"
else
    echo "❌ .env.example file not found. Please create it first."
    exit 1
fi
