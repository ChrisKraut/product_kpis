#!/usr/bin/env python3
"""
Product KPIs - Main entry point.

Run with: python -m src.main
"""

from src.config import reset_config
from src.menu.console import Menu


def main() -> None:
    """Main entry point for Product KPIs tool."""
    # Reset config to defaults on each launch (dev_mode = False)
    reset_config()

    # Create menu
    menu = Menu()

    # Import and set up executor (done here to avoid circular imports)
    try:
        from src.runner.executor import KPIExecutor

        executor = KPIExecutor()
        menu.set_executor(executor)
    except ImportError:
        # Executor not yet implemented - menu will show error if KPIs are run
        pass

    # Run the menu
    menu.run_main_menu()


if __name__ == "__main__":
    main()
