"""Interactive console menu for Product KPIs."""

import sys
from typing import Callable, Dict, List, Optional, Any

from src.config import get_config, ExportFormat
from src.credentials.keychain import (
    get_db_url,
    set_db_url,
    clear_db_url,
    has_db_url,
    get_masked_url,
)
from src.database.connection import init_db_engine
from src.kpis import discover_kpis, BaseKPI, Parameter


class Menu:
    """Interactive console menu for navigating Product KPIs tool."""

    def __init__(self):
        self.running = True
        self._kpi_executor = None  # Set later to avoid circular imports

    def set_executor(self, executor: Any) -> None:
        """Set the KPI executor for running KPIs."""
        self._kpi_executor = executor

    def display_header(self) -> None:
        """Display the main menu header with current mode."""
        config = get_config()
        mode = "[DEV - cached data]" if config.dev_mode else "[PRODUCTION]"

        print()
        print("Product KPIs")
        print("=" * 40)
        print(f"Mode: {mode}")
        print()

    def display_main_menu(self) -> None:
        """Display the main menu options."""
        print("  1. Run All KPIs")
        print("  2. Run Individual KPI")
        print("  3. Settings")
        print("  4. Exit")
        print()

    def get_choice(self, prompt: str = "Choice: ", valid: Optional[List[str]] = None) -> str:
        """Get user input with optional validation."""
        while True:
            try:
                choice = input(prompt).strip()
                if valid is None or choice in valid:
                    return choice
                print(f"  Invalid choice. Please enter one of: {', '.join(valid)}")
            except EOFError:
                return "4"  # Exit on EOF

    def run_main_menu(self) -> None:
        """Run the main menu loop."""
        while self.running:
            self.display_header()
            self.display_main_menu()

            choice = self.get_choice("Choice [1-4]: ", ["1", "2", "3", "4"])

            if choice == "1":
                self.run_all_kpis()
            elif choice == "2":
                self.run_individual_kpi()
            elif choice == "3":
                self.run_settings_menu()
            elif choice == "4":
                self.exit_menu()

    def run_settings_menu(self) -> None:
        """Display and handle the Settings submenu."""
        while True:
            config = get_config()

            print()
            print("Settings")
            print("-" * 40)
            print("  a. Set database URL")
            print("  b. Show database URL")
            print("  c. Clear database URL")
            print("  d. Toggle dev mode" + (" [ON]" if config.dev_mode else " [OFF]"))
            print("  e. Clear cache")
            print("  f. Back to main menu")
            print()

            choice = self.get_choice("Choice [a-f]: ", ["a", "b", "c", "d", "e", "f"])

            if choice == "a":
                self.set_database_url()
            elif choice == "b":
                self.show_database_url()
            elif choice == "c":
                self.clear_database_url()
            elif choice == "d":
                self.toggle_dev_mode()
            elif choice == "e":
                self.clear_cache()
            elif choice == "f":
                break

    def set_database_url(self) -> None:
        """Prompt user to set the database URL."""
        print()
        print("Enter database URL (e.g., postgresql://user:password@host:5432/dbname)")
        url = input("URL: ").strip()

        if not url:
            print("  No URL entered.")
            return

        try:
            # Validate by attempting connection
            print("  Testing connection...")
            engine = init_db_engine(url)
            with engine.connect() as conn:
                conn.execute("SELECT 1")
            print("  Connection successful!")

            set_db_url(url)
            print("  Database URL stored in keychain.")
        except Exception as e:
            print(f"  Connection failed: {e}")
            save_anyway = input("  Store URL anyway? [y/N]: ").strip().lower()
            if save_anyway == "y":
                set_db_url(url)
                print("  Database URL stored in keychain.")

    def show_database_url(self) -> None:
        """Show the masked database URL."""
        print()
        print(f"  {get_masked_url()}")

    def clear_database_url(self) -> None:
        """Clear the stored database URL."""
        if not has_db_url():
            print()
            print("  No database URL stored.")
            return

        confirm = input("  Clear stored database URL? [y/N]: ").strip().lower()
        if confirm == "y":
            clear_db_url()
            print("  Database URL cleared.")

    def toggle_dev_mode(self) -> None:
        """Toggle development mode on/off."""
        config = get_config()
        config.dev_mode = not config.dev_mode
        status = "ON" if config.dev_mode else "OFF"
        print(f"  Dev mode is now {status}")

    def clear_cache(self) -> None:
        """Clear the query cache."""
        from pathlib import Path
        import shutil

        cache_dir = Path("cache")
        if cache_dir.exists():
            confirm = input("  Clear all cached data? [y/N]: ").strip().lower()
            if confirm == "y":
                shutil.rmtree(cache_dir)
                print("  Cache cleared.")
        else:
            print("  No cache to clear.")

    def run_all_kpis(self) -> None:
        """Run all KPIs and export results."""
        if not has_db_url():
            print()
            print("  No database URL configured.")
            print("  Go to Settings → Set database URL first.")
            return

        if self._kpi_executor is None:
            print()
            print("  KPI executor not initialized.")
            return

        # Get export format
        print()
        print("Export format:")
        print("  1. CSV")
        print("  2. JSON")
        choice = self.get_choice("Choice [1-2]: ", ["1", "2"])

        config = get_config()
        config.export_format = ExportFormat.CSV if choice == "1" else ExportFormat.JSON

        # Run all KPIs
        self._kpi_executor.execute_all()

    def run_individual_kpi(self) -> None:
        """Run a single KPI with parameter configuration."""
        if not has_db_url():
            print()
            print("  No database URL configured.")
            print("  Go to Settings → Set database URL first.")
            return

        if self._kpi_executor is None:
            print()
            print("  KPI executor not initialized.")
            return

        # Discover KPIs
        kpis = discover_kpis()
        if not kpis:
            print()
            print("  No KPIs available.")
            return

        # Display KPI list
        print()
        print("Available KPIs:")
        print("-" * 40)
        for i, kpi_class in enumerate(kpis, 1):
            print(f"  {i}. {kpi_class.name}")
            print(f"     {kpi_class.description}")
        print(f"  {len(kpis) + 1}. Back to main menu")
        print()

        valid_choices = [str(i) for i in range(1, len(kpis) + 2)]
        choice = self.get_choice(f"Choice [1-{len(kpis) + 1}]: ", valid_choices)

        choice_num = int(choice)
        if choice_num == len(kpis) + 1:
            return  # Back to main menu

        selected_kpi = kpis[choice_num - 1]

        # Get parameters
        kpi_instance = selected_kpi()
        params = self._get_kpi_parameters(kpi_instance)

        # Get export format
        print()
        print("Export format:")
        print("  1. CSV")
        print("  2. JSON")
        format_choice = self.get_choice("Choice [1-2]: ", ["1", "2"])

        config = get_config()
        config.export_format = ExportFormat.CSV if format_choice == "1" else ExportFormat.JSON

        # Run the KPI
        self._kpi_executor.execute_single(kpi_instance, params)

    def _get_kpi_parameters(self, kpi: BaseKPI) -> Dict[str, Any]:
        """Prompt user for KPI parameters."""
        parameters = kpi.get_parameters()
        if not parameters:
            return {}

        print()
        print("Configure parameters:")
        print("-" * 40)

        values: Dict[str, Any] = {}
        for param in parameters:
            default_str = f" [{param.default}]" if param.default is not None else ""
            required_str = " (required)" if param.required else ""

            print(f"  {param.display_name}{required_str}")
            print(f"    {param.description}")

            value = input(f"    Value{default_str}: ").strip()

            if not value and param.default is not None:
                value = param.default
            elif not value and param.required:
                print("    Required parameter - using empty string")
                value = ""

            # Type conversion
            if value:
                if param.type.value == "integer":
                    try:
                        value = int(value)
                    except ValueError:
                        print(f"    Warning: Could not convert to integer, using string")
                elif param.type.value == "boolean":
                    value = value.lower() in ("true", "yes", "1", "y")

            values[param.name] = value if value else None

        return values

    def exit_menu(self) -> None:
        """Exit the application."""
        print()
        print("Goodbye!")
        self.running = False
