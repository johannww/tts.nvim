# Formatting commands
format: format-python format-lua

format-python:
	@echo "Formatting Python files..."
	black .
	isort .

format-lua:
	@echo "Formatting Lua files..."
	stylua .

# Linting commands
lint: lint-python lint-lua

lint-python:
	@echo "Linting Python files..."
	black --check .
	isort --check-only .
	flake8 .
	mypy .

lint-lua:
	@echo "Linting Lua files..."
	stylua --check .

# Check formatting without applying changes
check-format: check-format-python check-format-lua

check-format-python:
	@echo "Checking Python formatting..."
	black --check --diff .
	isort --check-only --diff .

check-format-lua:
	@echo "Checking Lua formatting..."
	stylua --check .

# Install formatting tools
install-formatters:
	@echo "Installing Python formatters..."
	pip install black isort flake8 mypy
	@echo "Please install stylua manually:"
	@echo "  - Via cargo: cargo install stylua"
	@echo "  - Via npm: npm install -g @johnnymorganz/stylua-bin"
	@echo "  - Or download from: https://github.com/JohnnyMorganz/StyLua/releases"

.PHONY: format format-python format-lua lint lint-python lint-lua check-format check-format-python check-format-lua install-formatters
