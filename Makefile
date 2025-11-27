.PHONY: help init clean get build-runner slang slang-clean analyze format test run-dev run-prod build-apk build-ios hooks add

# Default target
help:
	@echo "Available commands:"
	@echo "  make init         - Initialize project (run init.sh)"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make get          - Get Flutter dependencies"
	@echo "  make build-runner - Run build_runner for code generation"
	@echo "  make slang        - Run Slang for translations"
	@echo "  make slang-clean  - Remove slang generated files"
	@echo "  make analyze      - Analyze code for issues"
	@echo "  make format       - Format code"
	@echo "  make test         - Run tests"
	@echo "  make run-dev      - Run app in debug mode"
	@echo "  make run-prod     - Run app in release mode"
	@echo "  make build-apk    - Build Android APK"
	@echo "  make build-ios    - Build iOS app"
	@echo "  make hooks        - Setup pre-commit hooks"

# Initialize project
init:
	@chmod +x init.sh
	@./init.sh

# Clean build artifacts
clean:
	@flutter clean
	@rm -rf build/
	@rm -rf .dart_tool/

# Get dependencies
get:
	@flutter pub get

# Run build_runner
build-runner:
	@dart run build_runner build --delete-conflicting-outputs

# Run Slang for translations
slang:
	@dart run slang

# Clean slang generated files
slang-clean:
	@rm -f lib/i18n/*.g.dart

# Analyze code
analyze:
	@flutter analyze

# Format code
format:
	@dart format .

# Run tests
test:
	@flutter test

# Run app in debug mode
run-dev:
	@flutter run

# Run app in release mode
run-prod:
	@flutter run --release

# Build Android APK
build-apk:
	@flutter build apk --release

# Build iOS app
build-ios:
	@flutter build ios --release

# Setup pre-commit hooks
hooks:
	@dart pub global activate flutter_pre_commit
	@flutter_pre_commit install


add:
ifdef pub
	@flutter pub add $(pub)
else
	@echo "Usage: make add pub=<package>"
endif
