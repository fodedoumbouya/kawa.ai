# Project Runner Makefile
# Runs code-server, kawa, and kawa_web projects

.PHONY: all run-all stop-all clean help setup-env setup test setup-precommit check-precommit
.DEFAULT_GOAL := help

# Detect OS for commands and colors
UNAME_S := $(shell uname -s)

# Colors for output - Unix-like systems (Linux, macOS) support ANSI colors
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m

# Project directories
CODE_SERVER_DIR = vscode_preview
KAWA_DIR = kawa_server
KAWA_WEB_DIR = kawa_web
KAWA_WEB_PORT = 8000

# Dynamic port/host storage
SERVICE_INFO_FILE = .service_info
PIDS_FILE = .project_pids

# OS-specific commands
ifeq ($(UNAME_S),Linux)
    KILL_PORT_CMD = fuser -k
    FIND_PORT_CMD = netstat -tlnp | grep
    PYTHON_CMD = python3
endif
ifeq ($(UNAME_S),Darwin)
    KILL_PORT_CMD = lsof -ti:
    FIND_PORT_CMD = lsof -i:
    PYTHON_CMD = python3
endif

help: ## Show this help message
	@echo "$(BLUE)Project Runner - Available Commands:$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

check-core-dependencies: ## Check if core required tools are installed (Go, Python)
	@echo "$(YELLOW)Checking core dependencies...$(NC)"
	@MISSING_DEPS=""; \
	if ! command -v go >/dev/null 2>&1; then \
		echo "$(RED)✗ Go not found$(NC)"; \
		MISSING_DEPS="$$MISSING_DEPS Go"; \
	else \
		echo "$(GREEN)✓ Go found: $$(go version)$(NC)"; \
	fi; \
	if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then \
		echo "$(RED)✗ Python not found$(NC)"; \
		MISSING_DEPS="$$MISSING_DEPS Python"; \
	else \
		if command -v python3 >/dev/null 2>&1; then \
			echo "$(GREEN)✓ Python3 found: $$(python3 --version)$(NC)"; \
		else \
			echo "$(GREEN)✓ Python found: $$(python --version)$(NC)"; \
		fi; \
	fi; \
	if [ ! -z "$$MISSING_DEPS" ]; then \
		echo "$(RED)"; \
		echo "❌ CRITICAL ERROR: Missing required dependencies:$$MISSING_DEPS"; \
		echo ""; \
		echo "Please install the missing dependencies:"; \
		if echo "$$MISSING_DEPS" | grep -q "Go"; then \
			echo "  🔗 Go: https://golang.org/doc/install"; \
		fi; \
		if echo "$$MISSING_DEPS" | grep -q "Python"; then \
			echo "  🔗 Python: https://www.python.org/downloads/"; \
		fi; \
		echo "$(NC)"; \
		exit 1; \
	fi

check-optional-dependencies: ## Check optional dependencies (Flutter/Dart)
	@echo "$(YELLOW)Checking optional dependencies...$(NC)"
	@if command -v flutter >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Flutter found: $$(flutter --version | head -1)$(NC)"; \
		if command -v dart >/dev/null 2>&1; then \
			echo "$(GREEN)✓ Dart found: $$(dart --version 2>&1 | head -1)$(NC)"; \
		else \
			echo "$(YELLOW)⚠ Dart not found separately (included with Flutter)$(NC)"; \
		fi; \
	else \
		echo "$(YELLOW)⚠ Flutter not found$(NC)"; \
		echo "$(BLUE)  ℹ Flutter is optional - will serve pre-built web files if available$(NC)"; \
		echo "$(BLUE)  🔗 Install Flutter: https://flutter.dev/docs/get-started/install$(NC)"; \
	fi

check-dependencies: check-core-dependencies check-optional-dependencies ## Check if required tools are installed
	@echo "$(YELLOW)Checking additional tools...$(NC)"
	@if command -v code-server >/dev/null 2>&1; then \
		echo "$(GREEN)✓ code-server found$(NC)"; \
	else \
		echo "$(YELLOW)⚠ code-server not found - installing...$(NC)"; \
		curl -fsSL https://code-server.dev/install.sh | sh || { echo "$(RED)✗ Failed to install code-server$(NC)"; exit 1; }; \
		echo "$(GREEN)✓ code-server installed successfully$(NC)"; \
	fi
	@if command -v pre-commit >/dev/null 2>&1; then \
		echo "$(GREEN)✓ pre-commit found$(NC)"; \
	else \
		echo "$(YELLOW)⚠ pre-commit not found - installing...$(NC)"; \
		if command -v pip3 >/dev/null 2>&1; then \
			pip3 install pre-commit || { echo "$(RED)✗ Failed to install pre-commit with pip3$(NC)"; exit 1; }; \
		elif command -v pip >/dev/null 2>&1; then \
			pip install pre-commit || { echo "$(RED)✗ Failed to install pre-commit with pip$(NC)"; exit 1; }; \
		elif command -v brew >/dev/null 2>&1; then \
			brew install pre-commit || { echo "$(RED)✗ Failed to install pre-commit with brew$(NC)"; exit 1; }; \
		else \
			echo "$(RED)✗ Could not install pre-commit automatically$(NC)"; \
			echo "$(BLUE)Please install pre-commit manually:$(NC)"; \
			echo "$(BLUE)  🔗 Visit: https://pre-commit.com/#install$(NC)"; \
			exit 1; \
		fi; \
		echo "$(GREEN)✓ pre-commit installed successfully$(NC)"; \
	fi
	@echo "$(GREEN)✓ Dependency check complete$(NC)"

setup: check-dependencies ## Setup all projects (go mod tidy + flutter pub get if available)
	@echo "$(BLUE)🔧 Setting up all projects...$(NC)"
	@echo ""
	@echo "$(YELLOW)Setting up pre-commit hooks...$(NC)"
	@pre-commit install
	@pre-commit install --hook-type commit-msg
	@echo "$(GREEN)✓ Pre-commit hooks installed$(NC)"
	@echo ""
	@echo "$(YELLOW)Setting up Kawa (Go) project...$(NC)"
	@if [ ! -d "$(KAWA_DIR)" ]; then \
		echo "$(RED)✗ kawa directory not found$(NC)"; \
		exit 1; \
	fi
	@cd $(KAWA_DIR) && go mod tidy
	@echo "$(GREEN)✓ Kawa setup complete$(NC)"
	@echo ""
	@echo "$(YELLOW)Setting up Kawa Web project...$(NC)"
	@if [ ! -d "$(KAWA_WEB_DIR)" ]; then \
		echo "$(RED)✗ kawa_web directory not found$(NC)"; \
		exit 1; \
	fi
	@if command -v flutter >/dev/null 2>&1; then \
		echo "$(BLUE)Flutter found - running flutter pub get$(NC)"; \
		cd $(KAWA_WEB_DIR) && flutter pub get; \
		echo "$(GREEN)✓ Kawa Web Flutter setup complete$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Flutter not found - skipping flutter pub get$(NC)"; \
		echo "$(BLUE)  ℹ Will serve pre-built files from build/web if available$(NC)"; \
		if [ ! -d "$(KAWA_WEB_DIR)/build/web" ]; then \
			echo "$(YELLOW)⚠ No pre-built web files found in $(KAWA_WEB_DIR)/build/web$(NC)"; \
			echo "$(BLUE)  Consider installing Flutter to build the web project$(NC)"; \
		else \
			echo "$(GREEN)✓ Pre-built web files found$(NC)"; \
		fi; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 All projects setup successfully!$(NC)"

test: check-core-dependencies ## Run tests for all projects
	@echo "$(BLUE)🧪 Running tests for all projects...$(NC)"
	@echo ""
	@echo "$(YELLOW)Testing Kawa (Go) project...$(NC)"
	@if [ ! -d "$(KAWA_DIR)" ]; then \
		echo "$(RED)✗ kawa directory not found$(NC)"; \
		exit 1; \
	fi
	@cd $(KAWA_DIR) && go test ./... -v || { echo "$(RED)✗ Kawa tests failed$(NC)"; exit 1; }
	@echo "$(GREEN)✓ Kawa tests passed$(NC)"
	@echo ""
	@if command -v flutter >/dev/null 2>&1; then \
		echo "$(YELLOW)Testing Kawa Web (Flutter) project...$(NC)"; \
		if [ ! -d "$(KAWA_WEB_DIR)" ]; then \
			echo "$(RED)✗ kawa_web directory not found$(NC)"; \
			exit 1; \
		fi; \
		cd $(KAWA_WEB_DIR) && flutter test || { echo "$(RED)✗ Kawa Web tests failed$(NC)"; exit 1; }; \
		echo "$(GREEN)✓ Kawa Web tests passed$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Flutter not available - skipping Flutter tests$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)🎉 All available tests passed successfully!$(NC)"

setup-precommit: ## Install and setup pre-commit hooks
	@echo "$(BLUE)🔧 Setting up pre-commit hooks...$(NC)"
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "$(YELLOW)Installing pre-commit...$(NC)"; \
		if [ ! -d "venv" ]; then \
			echo "$(YELLOW)Creating Python virtual environment...$(NC)"; \
			$(PYTHON_CMD) -m venv venv; \
		fi; \
		echo "$(YELLOW)Activating virtual environment...$(NC)"; \
		. venv/bin/activate && pip install pre-commit && echo "$(GREEN)✓ pre-commit installed in virtual environment$(NC)" || { \
			echo "$(RED)✗ Failed to install pre-commit in virtual environment$(NC)"; \
			exit 1; \
		}; \
	else \
		echo "$(GREEN)✓ pre-commit already installed$(NC)"; \
	fi
	@if [ -d "venv" ]; then \
		. venv/bin/activate && pre-commit install && pre-commit install --hook-type commit-msg; \
	else \
		pre-commit install && pre-commit install --hook-type commit-msg; \
	fi
	@echo "$(GREEN)✓ Pre-commit hooks installed successfully$(NC)"
	@echo "$(BLUE)💡 Pre-commit will now run automatically on each commit$(NC)"
	@echo "$(YELLOW)💡 TIP: When needed, activate the virtual environment with: . venv/bin/activate$(NC)"

check-precommit: ## Run pre-commit hooks on all files
	@echo "$(BLUE)🔍 Running pre-commit hooks on all files...$(NC)"
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "$(RED)✗ pre-commit not installed. Run 'make setup-precommit' first$(NC)"; \
		exit 1; \
	fi
	@pre-commit run --all-files

update-precommit: ## Update pre-commit hooks to latest versions
	@echo "$(BLUE)🔄 Updating pre-commit hooks...$(NC)"
	@if ! command -v pre-commit >/dev/null 2>&1; then \
		echo "$(RED)✗ pre-commit not installed. Run 'make setup-precommit' first$(NC)"; \
		exit 1; \
	fi
	@pre-commit autoupdate
	@echo "$(GREEN)✓ Pre-commit hooks updated$(NC)"

extract-port-from-log: ## Helper to extract port from log file
	@grep -o "http://[^[:space:]]*" $(1) 2>/dev/null | head -1 || \
	 grep -o "localhost:[0-9]*" $(1) 2>/dev/null | head -1 || \
	 grep -o ":[0-9]*" $(1) 2>/dev/null | head -1 | sed 's/://'

kill-port: ## Kill process on specified port (usage: make kill-port PORT=8080)
	@echo "$(YELLOW)Killing processes on port $(PORT)...$(NC)"
ifeq ($(UNAME_S),Linux)
	@fuser -k $(PORT)/tcp 2>/dev/null || echo "$(YELLOW)No process found on port $(PORT)$(NC)"
endif
ifeq ($(UNAME_S),Darwin)
	@PIDS=$$(lsof -ti:$(PORT) 2>/dev/null); \
	if [ ! -z "$$PIDS" ]; then \
		echo "$(YELLOW)Killing PIDs: $$PIDS$(NC)"; \
		kill $$PIDS 2>/dev/null || kill -9 $$PIDS 2>/dev/null; \
	else \
		echo "$(YELLOW)No process found on port $(PORT)$(NC)"; \
	fi
endif

extract-and-kill-ports: ## Extract ports from service_info and kill processes
	@echo "$(YELLOW)Extracting ports from service info and killing processes...$(NC)"
	@if [ -f "$(SERVICE_INFO_FILE)" ]; then \
		while IFS='|' read -r service url; do \
			if [ ! -z "$$url" ]; then \
				PORT=$$(echo "$$url" | grep -oE '[0-9]+$$' | head -1); \
				if [ ! -z "$$PORT" ]; then \
					echo "$(BLUE)Killing $$service on port $$PORT$(NC)"; \
					$(MAKE) kill-port PORT=$$PORT; \
				else \
					echo "$(YELLOW)Could not extract port from $$url$(NC)"; \
				fi; \
			fi; \
		done < "$(SERVICE_INFO_FILE)"; \
	else \
		echo "$(YELLOW)No service info file found$(NC)"; \
	fi

run-code-server: ## Start code-server
	@echo "$(YELLOW)Starting code-server...$(NC)"
	@if [ ! -d "$(CODE_SERVER_DIR)" ]; then \
		echo "$(RED)✗ code-server directory not found$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi
	@cd $(CODE_SERVER_DIR) && code-server --auth none > ../code-server.log 2>&1 &
	@CODE_SERVER_PID=$$!; \
	echo $$CODE_SERVER_PID >> $(PIDS_FILE); \
	echo "$(BLUE)Waiting for code-server to start...$(NC)"; \
	CODE_SERVER_URL=""; \
	for i in $$(seq 1 30); do \
		if [ -f code-server.log ]; then \
			CODE_SERVER_URL=$$(grep -oE 'http://127\.0\.0\.1:[0-9]+' code-server.log 2>/dev/null | head -1); \
			if [ ! -z "$$CODE_SERVER_URL" ]; then \
				if curl -s $$CODE_SERVER_URL >/dev/null 2>&1; then \
					echo "$(GREEN)✓ code-server is ready at $$CODE_SERVER_URL$(NC)"; \
					echo "vscode_preview|$$CODE_SERVER_URL" >> $(SERVICE_INFO_FILE); \
					break; \
				fi; \
			fi; \
		fi; \
		if [ $$i -eq 30 ]; then \
			echo "$(RED)✗ code-server failed to start$(NC)"; \
			echo "$(YELLOW)Code-server log:$(NC)"; \
			tail -10 code-server.log 2>/dev/null || echo "No log available"; \
			$(MAKE) stop-all; \
			exit 1; \
		fi; \
		sleep 1; \
	done

setup-kawa-env: ## Setup environment file for kawa with code-server URL
	@echo "$(YELLOW)Setting up kawa environment with code-server URL...$(NC)"
	@if [ -f "$(SERVICE_INFO_FILE)" ]; then \
		CODE_SERVER_URL=$$(grep "^vscode_preview|" $(SERVICE_INFO_FILE) | cut -d'|' -f2); \
		if [ ! -z "$$CODE_SERVER_URL" ]; then \
			VSCODE_PREVIEW_HOST=$$(echo $$CODE_SERVER_URL | sed 's|http://||' | sed 's|https://||'); \
			echo "VSCODE_PREVIEW_HOST=$$VSCODE_PREVIEW_HOST" > $(KAWA_DIR)/.env; \
			echo "$(GREEN)✓ Created .env file in kawa with VSCODE_PREVIEW_HOST=$$VSCODE_PREVIEW_HOST$(NC)"; \
		else \
			echo "$(RED)✗ Could not find code-server URL$(NC)"; \
			$(MAKE) stop-all; \
			exit 1; \
		fi; \
	else \
		echo "$(RED)✗ Code-server must be started first$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi

run-kawa: setup-kawa-env ## Start kawa server with code-server environment
	@echo "$(YELLOW)Starting kawa server...$(NC)"
	@if [ ! -d "$(KAWA_DIR)" ]; then \
		echo "$(RED)✗ kawa directory not found$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi
	@if [ ! -d "$(KAWA_DIR)/cmd" ]; then \
		echo "$(RED)✗ kawa/cmd directory not found$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi
	@cd $(KAWA_DIR)/cmd && go run . serve > ../../kawa.log 2>&1 &
	@KAWA_PID=$$!; \
	echo $$KAWA_PID >> $(PIDS_FILE); \
	echo "$(BLUE)Waiting for kawa server to start...$(NC)"; \
	KAWA_URL=""; \
	for i in $$(seq 1 30); do \
		if [ -f kawa.log ]; then \
			KAWA_URL=$$(grep -oE "http?://[^[:space:]]*|localhost:[0-9]+" kawa.log 2>/dev/null | head -1); \
			if [ -z "$$KAWA_URL" ]; then \
				KAWA_PORT=$$(grep -oE ":[0-9]+" kawa.log 2>/dev/null | head -1 | sed 's/://'); \
				if [ ! -z "$$KAWA_PORT" ]; then \
					KAWA_URL="http://localhost:$$KAWA_PORT"; \
				fi; \
			fi; \
			if [ ! -z "$$KAWA_URL" ]; then \
				if curl -s $$KAWA_URL >/dev/null 2>&1 || \
				   netstat -ln 2>/dev/null | grep :$$(echo $$KAWA_URL | grep -o "[0-9]*$$") >/dev/null || \
				   lsof -i :$$(echo $$KAWA_URL | grep -o "[0-9]*$$") >/dev/null 2>&1; then \
					echo "$(GREEN)✓ kawa server is ready at $$KAWA_URL$(NC)"; \
					echo "kawa|$$KAWA_URL" >> $(SERVICE_INFO_FILE); \
					break; \
				fi; \
			fi; \
		fi; \
		if [ $$i -eq 30 ]; then \
			echo "$(RED)✗ kawa server failed to start$(NC)"; \
			echo "$(YELLOW)Kawa log:$(NC)"; \
			tail -10 kawa.log 2>/dev/null || echo "No log available"; \
			$(MAKE) stop-all; \
			exit 1; \
		fi; \
		sleep 1; \
	done

setup-kawa-web-env: ## Setup environment file for kawa_web with dynamic kawa URL
	@echo "$(YELLOW)Setting up kawa_web environment with kawa server URL...$(NC)"
	@if [ -f "$(SERVICE_INFO_FILE)" ]; then \
		KAWA_URL=$$(grep "^kawa|" $(SERVICE_INFO_FILE) | cut -d'|' -f2); \
		if [ ! -z "$$KAWA_URL" ]; then \
			KAWA_HOST=$$(echo $$KAWA_URL | sed 's|http://||' | sed 's|https://||'); \
			echo "SERVER_HOST=$$KAWA_HOST" > $(KAWA_WEB_DIR)/.env; \
			echo "$(GREEN)✓ Created .env file with SERVER_HOST=$$KAWA_HOST$(NC)"; \
		else \
			echo "$(RED)✗ Could not find kawa server URL$(NC)"; \
			$(MAKE) stop-all; \
			exit 1; \
		fi; \
	else \
		echo "$(RED)✗ Kawa server must be started first$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi

build-kawa-web: setup-kawa-web-env ## Build kawa_web project (Flutter if available, otherwise use pre-built)
	@echo "$(YELLOW)Setting up kawa_web...$(NC)"
	@if [ ! -d "$(KAWA_WEB_DIR)" ]; then \
		echo "$(RED)✗ kawa_web directory not found$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi
	@if command -v flutter >/dev/null 2>&1; then \
		echo "$(BLUE)Flutter found - building web project$(NC)"; \
		echo "$(BLUE)Resolving dependencies...$(NC)"; \
		cd $(KAWA_WEB_DIR) && flutter pub get && \
		echo "$(BLUE)Building web project...$(NC)" && \
		flutter build web; \
		echo "$(GREEN)✓ kawa_web built successfully$(NC)"; \
	else \
		echo "$(YELLOW)⚠ Flutter not found - checking for pre-built files$(NC)"; \
		if [ ! -d "$(KAWA_WEB_DIR)/build/web" ]; then \
			echo "$(RED)✗ No pre-built files found in $(KAWA_WEB_DIR)/build/web$(NC)"; \
			echo "$(RED)✗ Either install Flutter or provide pre-built web files$(NC)"; \
			echo "$(BLUE)🔗 Install Flutter: https://flutter.dev/docs/get-started/install$(NC)"; \
			$(MAKE) stop-all; \
			exit 1; \
		fi; \
		echo "$(GREEN)✓ Using pre-built web files$(NC)"; \
	fi

run-kawa-web: build-kawa-web ## Start kawa_web using Python HTTP server
	@echo "$(YELLOW)Starting kawa_web server...$(NC)"
	@if [ ! -d "$(KAWA_WEB_DIR)/build/web" ]; then \
		echo "$(RED)✗ build/web directory not found$(NC)"; \
		$(MAKE) stop-all; \
		exit 1; \
	fi
	@echo "$(BLUE)Starting Python HTTP server on port $(KAWA_WEB_PORT)$(NC)"
	@cd $(KAWA_WEB_DIR)/build/web && $(PYTHON_CMD) -m http.server $(KAWA_WEB_PORT) > ../../../kawa_web.log 2>&1 &
	@KAWA_WEB_PID=$$!; \
	echo $$KAWA_WEB_PID >> $(PIDS_FILE); \
	echo "$(BLUE)Waiting for kawa_web HTTP server to start...$(NC)"; \
	KAWA_WEB_URL="http://127.0.0.1:$(KAWA_WEB_PORT)"; \
	for i in $$(seq 1 30); do \
		if curl -s $$KAWA_WEB_URL >/dev/null 2>&1; then \
			echo "$(GREEN)✓ kawa_web is ready at $$KAWA_WEB_URL$(NC)"; \
			echo "kawa_web|$$KAWA_WEB_URL" >> $(SERVICE_INFO_FILE); \
			break; \
		fi; \
		if [ $$i -eq 30 ]; then \
			echo "$(RED)✗ kawa_web HTTP server failed to start$(NC)"; \
			echo "$(YELLOW)Kawa_web log:$(NC)"; \
			tail -10 kawa_web.log 2>/dev/null || echo "No log available"; \
			$(MAKE) stop-all; \
			exit 1; \
		fi; \
		sleep 1; \
	done

show-status: ## Show running services status table
	@echo ""
	@echo "$(GREEN)🚀 All Services Running Successfully!$(NC)"
	@echo ""
	@printf "$(BLUE)%-15s %-35s %-10s$(NC)\n" "PROJECT" "URL" "STATUS"
	@printf "$(BLUE)%-15s %-35s %-10s$(NC)\n" "-------" "---" "------"
	@if [ -f "$(SERVICE_INFO_FILE)" ]; then \
		while IFS='|' read -r service url; do \
			if curl -s $$url >/dev/null 2>&1; then \
				printf "$(GREEN)%-15s %-35s %-10s$(NC)\n" "$$service" "$$url" "✓ Running"; \
			else \
				printf "$(RED)%-15s %-35s %-10s$(NC)\n" "$$service" "$$url" "✗ Stopped"; \
			fi; \
		done < $(SERVICE_INFO_FILE); \
	else \
		echo "$(YELLOW)No services running$(NC)"; \
	fi
	@echo ""
	@if [ -f "$(KAWA_DIR)/.env" ]; then \
		echo "$(BLUE)Environment Files:$(NC)"; \
		echo "$(YELLOW)Kawa .env:$(NC) $$(cat $(KAWA_DIR)/.env 2>/dev/null || echo 'Not found')"; \
		echo "$(YELLOW)Kawa_web .env:$(NC) $$(cat $(KAWA_WEB_DIR)/.env 2>/dev/null || echo 'Not found')"; \
		echo ""; \
	fi
	@echo "$(YELLOW)💡 Use 'make stop-all' to stop all services$(NC)"
	@echo "$(YELLOW)💡 Use 'make logs' to view service logs$(NC)"
	@echo ""

run-all: check-dependencies ## Start all projects (code-server, kawa, kawa_web)
	@echo "$(BLUE)🚀 Starting all projects...$(NC)"
	@echo ""
	@rm -f $(PIDS_FILE) $(SERVICE_INFO_FILE)
	@touch $(PIDS_FILE) $(SERVICE_INFO_FILE)
	@$(MAKE) run-code-server
	@$(MAKE) run-kawa
	@$(MAKE) run-kawa-web
	@$(MAKE) show-status

stop-all: ## Stop all running projects by killing processes on ports from service_info
	@echo "$(YELLOW)Stopping all projects...$(NC)"
	@$(MAKE) extract-and-kill-ports
	@echo "$(YELLOW)Cleaning up additional processes...$(NC)"
	@if [ -f $(PIDS_FILE) ]; then \
		while read pid; do \
			if kill -0 $$pid 2>/dev/null; then \
				echo "$(YELLOW)Stopping process $$pid$(NC)"; \
				kill $$pid 2>/dev/null || kill -9 $$pid 2>/dev/null; \
			fi; \
		done < $(PIDS_FILE); \
		rm -f $(PIDS_FILE); \
	fi
	@pkill -f "code-server --auth none" 2>/dev/null || true
	@pkill -f "go run . serve" 2>/dev/null || true
	@pkill -f "python.*http.server $(KAWA_WEB_PORT)" 2>/dev/null || true
	@pkill -f "python3.*http.server $(KAWA_WEB_PORT)" 2>/dev/null || true
	@rm -f $(SERVICE_INFO_FILE)
	@echo "$(GREEN)✓ All projects stopped$(NC)"

logs: ## Show logs for all services
	@echo "$(BLUE)=== Code Server Logs ===$(NC)"
	@tail -20 code-server.log 2>/dev/null || echo "No code-server logs found"
	@echo ""
	@echo "$(BLUE)=== Kawa Server Logs ===$(NC)"
	@tail -20 kawa.log 2>/dev/null || echo "No kawa logs found"
	@echo ""
	@echo "$(BLUE)=== Kawa Web Logs ===$(NC)"
	@tail -20 kawa_web.log 2>/dev/null || echo "No kawa_web logs found"

clean: stop-all ## Stop all projects and clean up log files
	@echo "$(YELLOW)Cleaning up...$(NC)"
	@rm -f *.log
	@rm -f $(PIDS_FILE) $(SERVICE_INFO_FILE)
	@rm -f $(KAWA_DIR)/.env $(KAWA_WEB_DIR)/.env
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

restart: stop-all run-all ## Restart all projects

status: show-status ## Show current status of all services

run-precommit: ## Run pre-commit commands in the virtual environment
	@echo "$(BLUE)🔍 Running pre-commit in virtual environment...$(NC)"
	@if [ ! -d "venv" ]; then \
		echo "$(RED)✗ Virtual environment not found. Run 'make setup-precommit' first$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Command format: make run-precommit CMD=\"pre-commit run --all-files\"$(NC)"
	@if [ -z "$(CMD)" ]; then \
		echo "$(RED)✗ No command specified. Use CMD=\"your-command\"$(NC)"; \
		echo "$(YELLOW)Example: make run-precommit CMD=\"pre-commit run --all-files\"$(NC)"; \
		exit 1; \
	fi
	@. venv/bin/activate && $(CMD)
	@echo "$(GREEN)✓ Pre-commit command completed$(NC)"