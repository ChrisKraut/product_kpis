"""First Time Right (Exports) KPI - Measures success rate for exports by action type."""

import json
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Dict, List

from sqlalchemy import text
from sqlalchemy.engine import Engine

from src.kpis.base import BaseKPI, Parameter, ParameterType
from src.models.result import KPIResult

# Load action types from config file (in same directory)
CONFIG_PATH = Path(__file__).parent / "config.json"


def load_action_types() -> List[str]:
    """Load action types from config file."""
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH) as f:
            config = json.load(f)
            return config.get("action_types", [])
    return ["export_fulfillment_create"]  # Default fallback


class FirstTimeRightExportsKPI(BaseKPI):
    """
    KPI: First Time Right for exports by action type.

    Calculates the percentage of exports that succeed on the first attempt
    (no associated error logs). Uses the everstox_qm__export_http table filtered
    by tags -> 'action_type' and checks for absence of error_log records.

    Action types are configured in config.json
    """

    name = "First Time Right (Exports)"
    description = "Success rate for exports by action type (no error logs)"

    def get_parameters(self) -> List[Parameter]:
        """Return configurable parameters for this KPI."""
        return [
            Parameter(
                name="start_date",
                display_name="Start Date",
                type=ParameterType.DATE,
                required=False,
                default=None,
                description="Start of date range, format: YYYY-MM-DD (defaults to 14 days ago)",
            ),
            Parameter(
                name="end_date",
                display_name="End Date",
                type=ParameterType.DATE,
                required=False,
                default=None,
                description="End of date range, format: YYYY-MM-DD (defaults to today)",
            ),
            Parameter(
                name="shop_id",
                display_name="Shop ID",
                type=ParameterType.STRING,
                required=False,
                default=None,
                description="Filter by shop ID (leave empty for all shops)",
            ),
            Parameter(
                name="discover_action_types",
                display_name="Discover Action Types",
                type=ParameterType.BOOLEAN,
                required=False,
                default=False,
                description="Set to 'true' to list all available action_types (ignores config)",
            ),
        ]

    def _discover_action_types(
        self, engine: Engine, start_date: Any, end_date: Any, start_time: datetime, params: Dict[str, Any]
    ) -> KPIResult:
        """Discover all available action_types from the database."""
        try:
            query = """
            SELECT
                tags -> 'action_type' as action_type,
                COUNT(*) as total_count
            FROM everstox_qm__export_http
            WHERE creation_date >= :start_date
              AND creation_date < :end_date + INTERVAL '1 day'
              AND tags -> 'action_type' IS NOT NULL
            GROUP BY tags -> 'action_type'
            ORDER BY total_count DESC
            LIMIT 50
            """

            rows: List[Dict[str, Any]] = []

            with engine.connect() as conn:
                result = conn.execute(text(query), {
                    "start_date": start_date,
                    "end_date": end_date,
                })

                print(f"\n      Available action_types in date range:")
                print("-" * 60)
                for row in result:
                    action_type = row[0]
                    count = row[1]
                    print(f"        {action_type}: {count} records")
                    rows.append({
                        "action_type": action_type,
                        "total_exports": count,
                        "successful_exports": None,
                        "failed_exports": None,
                        "success_rate": None,
                    })
                print("-" * 60)

            duration = (datetime.now() - start_time).total_seconds()
            print(f"\n      Discovery completed in {duration:.2f}s")
            print(f"      Found {len(rows)} action_types")
            print("=" * 60 + "\n")

            return KPIResult(
                kpi_name=self.name + " (Discovery)",
                columns=["action_type", "total_exports", "successful_exports", "failed_exports", "success_rate"],
                rows=rows,
                duration_seconds=duration,
                parameters={
                    "start_date": start_date,
                    "end_date": end_date,
                    "discover_action_types": True,
                },
            )

        except Exception as e:
            duration = (datetime.now() - start_time).total_seconds()
            print(f"\n[ERROR] Discovery failed: {e}")
            print("=" * 60 + "\n")
            return KPIResult(
                kpi_name=self.name + " (Discovery)",
                columns=["action_type", "total_exports", "successful_exports", "failed_exports", "success_rate"],
                rows=[],
                duration_seconds=duration,
                parameters=params,
                error=str(e),
            )

    def _parse_date(self, value: Any) -> Any:
        """Parse date from various input formats."""
        if value is None:
            return None
        if isinstance(value, datetime):
            return value.date()
        if hasattr(value, 'date'):  # date object
            return value
        if isinstance(value, str) and value.strip():
            # Try parsing YYYY-MM-DD format
            try:
                return datetime.strptime(value.strip(), "%Y-%m-%d").date()
            except ValueError:
                pass
        return value

    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        """Execute the First Time Right query for all configured action types."""
        start_time = datetime.now()

        print("\n" + "=" * 60)
        print("First Time Right KPI - Execution Log")
        print("=" * 60)

        try:
            # Parse date parameters
            raw_end = params.get("end_date")
            raw_start = params.get("start_date")
            print(f"\n[1/4] Parsing parameters...")
            print(f"      Raw start_date: {raw_start!r}")
            print(f"      Raw end_date: {raw_end!r}")

            end_date = self._parse_date(raw_end)
            start_date = self._parse_date(raw_start)

            if end_date is None:
                end_date = datetime.now(timezone.utc).date()
                print(f"      end_date defaulted to: {end_date}")

            if start_date is None:
                start_date = end_date - timedelta(days=13)
                print(f"      start_date defaulted to: {start_date}")

            print(f"      Parsed start_date: {start_date}")
            print(f"      Parsed end_date: {end_date}")

            # Date range validation
            print(f"\n[2/4] Validating date range...")
            if start_date > end_date:
                print(f"      ERROR: start_date ({start_date}) > end_date ({end_date})")
                duration = (datetime.now() - start_time).total_seconds()
                return KPIResult(
                    kpi_name=self.name,
                    columns=["action_type", "total_exports", "successful_exports", "failed_exports", "success_rate"],
                    rows=[],
                    duration_seconds=duration,
                    parameters=params,
                    error="Invalid date range: start_date must be before or equal to end_date",
                )

            shop_id = params.get("shop_id")
            discover_mode = str(params.get("discover_action_types", "")).lower() in ("true", "1", "yes")
            print(f"      Date range valid: {start_date} to {end_date}")
            print(f"      Shop filter: {shop_id or '(all shops)'}")
            print(f"      Discover mode: {discover_mode}")

            # Discovery mode: list all available action_types from DB
            if discover_mode:
                print(f"\n[3/3] Discovering action_types from database...")
                return self._discover_action_types(engine, start_date, end_date, start_time, params)

            # Load action types from config
            action_types = load_action_types()
            print(f"\n[3/4] Loading action types from config...")
            print(f"      Config file: {CONFIG_PATH}")
            print(f"      Action types: {action_types}")

            # Query for each action type
            print(f"\n[4/4] Executing queries for each action type...")
            print("-" * 60)

            rows: List[Dict[str, Any]] = []

            query = """
            WITH matching_exports AS (
                SELECT id
                FROM everstox_qm__export_http
                WHERE tags -> 'action_type' = :action_type
                  AND creation_date >= :start_date
                  AND creation_date < :end_date + INTERVAL '1 day'
            ),
            exports_with_errors AS (
                SELECT DISTINCT export_id
                FROM error_log
                WHERE export_id IN (SELECT id FROM matching_exports)
            )
            SELECT
                (SELECT COUNT(*) FROM matching_exports) as total_exports,
                (SELECT COUNT(*) FROM matching_exports
                 WHERE id NOT IN (SELECT export_id FROM exports_with_errors)) as successful_exports
            """

            with engine.connect() as conn:
                for action_type in action_types:
                    print(f"\n      [{action_type}]")

                    query_params: Dict[str, Any] = {
                        "action_type": action_type,
                        "start_date": start_date,
                        "end_date": end_date,
                    }

                    result = conn.execute(text(query), query_params)
                    row = result.fetchone()

                    total_exports = row[0] if row else 0
                    successful_exports = row[1] if row else 0
                    failed_exports = total_exports - successful_exports

                    if total_exports > 0:
                        success_rate = round((successful_exports / total_exports) * 100, 2)
                    else:
                        success_rate = 0.0

                    print(f"        Total: {total_exports} | Success: {successful_exports} | Failed: {failed_exports} | Rate: {success_rate}%")

                    rows.append({
                        "action_type": action_type,
                        "total_exports": total_exports,
                        "successful_exports": successful_exports,
                        "failed_exports": failed_exports,
                        "success_rate": success_rate,
                    })

            duration = (datetime.now() - start_time).total_seconds()

            print("-" * 60)
            print(f"\n      Total query duration: {duration:.2f}s")
            print("=" * 60 + "\n")

            return KPIResult(
                kpi_name=self.name,
                columns=["action_type", "total_exports", "successful_exports", "failed_exports", "success_rate"],
                rows=rows,
                duration_seconds=duration,
                parameters={
                    "start_date": start_date,
                    "end_date": end_date,
                    "shop_id": shop_id,
                },
            )

        except Exception as e:
            duration = (datetime.now() - start_time).total_seconds()
            print(f"\n[ERROR] Query failed: {e}")
            print("=" * 60 + "\n")
            return KPIResult(
                kpi_name=self.name,
                columns=["action_type", "total_exports", "successful_exports", "failed_exports", "success_rate"],
                rows=[],
                duration_seconds=duration,
                parameters=params,
                error=str(e),
            )
