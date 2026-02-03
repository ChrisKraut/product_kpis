"""KPI execution with progress tracking."""

import json
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

from src.cache import load_from_cache, save_to_cache
from src.config import get_config
from src.credentials.keychain import get_db_url
from src.database.connection import init_db_engine
from src.export import get_exporter
from src.kpis import discover_kpis, BaseKPI
from src.models.result import KPIResult, KPIReport


class KPIExecutor:
    """Execute KPIs with progress display and error handling."""

    def __init__(self):
        self._engine = None

    def _get_engine(self):
        """Get or create the database engine."""
        if self._engine is None:
            db_url = get_db_url()
            self._engine = init_db_engine(db_url)
        return self._engine

    def _execute_with_cache(
        self, kpi: BaseKPI, engine: Any, params: Dict[str, Any]
    ) -> KPIResult:
        """
        Execute KPI with cache support for dev mode.

        In dev mode, checks cache first and saves results to cache.
        In production mode, always fetches live data.
        """
        config = get_config()

        # In dev mode, try to load from cache
        if config.dev_mode:
            # Create a simple query identifier for caching
            query_id = f"{kpi.name}:{json.dumps(params, sort_keys=True, default=str)}"
            cached = load_from_cache(kpi.name, query_id, params)

            if cached:
                columns, rows, metadata = cached
                print("[cached] ", end="")
                return KPIResult(
                    kpi_name=kpi.name,
                    columns=columns,
                    rows=rows,
                    parameters=params,
                    from_cache=True,
                    duration_seconds=0.0,
                )

        # Execute the KPI
        result = kpi.execute(engine, params)

        # In dev mode, save to cache on success
        if config.dev_mode and result.success:
            query_id = f"{kpi.name}:{json.dumps(params, sort_keys=True, default=str)}"
            save_to_cache(
                kpi.name,
                query_id,
                params,
                result.columns,
                result.rows,
                result.duration_seconds,
            )

        return result

    def execute_all(self) -> Optional[KPIReport]:
        """
        Execute all discovered KPIs and export results.

        Returns:
            KPIReport with all results, or None if no KPIs found.
        """
        config = get_config()
        kpis = discover_kpis()

        if not kpis:
            print()
            print("No KPIs available to run.")
            return None

        print()
        print("Running KPIs...")
        print("-" * 40)

        results: List[KPIResult] = []
        total_start = datetime.now()

        for i, kpi_class in enumerate(kpis, 1):
            kpi = kpi_class()
            print(f"  [{i}/{len(kpis)}] {kpi.name}...", end=" ", flush=True)

            try:
                engine = self._get_engine()
                # Use default parameters for Run All
                params = {p.name: p.default for p in kpi.get_parameters()}
                result = self._execute_with_cache(kpi, engine, params)
                results.append(result)

                if result.success:
                    print(f"✓ ({result.duration_seconds:.1f}s)")
                else:
                    print(f"✗ ({result.error})")

            except Exception as e:
                error_result = KPIResult(
                    kpi_name=kpi.name,
                    columns=[],
                    rows=[],
                    error=str(e),
                )
                results.append(error_result)
                print(f"✗ ({e})")

        total_duration = (datetime.now() - total_start).total_seconds()

        # Create report
        report = KPIReport(
            results=results,
            total_duration_seconds=total_duration,
            dev_mode=config.dev_mode,
        )

        # Print summary
        print("-" * 40)
        print(f"Complete: {report.success_count}/{len(results)} KPIs succeeded")
        print(f"Total time: {total_duration:.1f}s")

        # Export results
        self._export_report(results)

        return report

    def execute_single(
        self, kpi: BaseKPI, params: Dict[str, Any]
    ) -> Optional[KPIResult]:
        """
        Execute a single KPI with specified parameters.

        Args:
            kpi: The KPI instance to execute
            params: Parameters for the KPI

        Returns:
            KPIResult with the execution result.
        """
        print()
        print(f"Running {kpi.name}...")
        print("-" * 40)

        try:
            engine = self._get_engine()
            result = self._execute_with_cache(kpi, engine, params)

            if result.success:
                print(f"Status: Success")
                print(f"Duration: {result.duration_seconds:.2f}s")
                print(f"Rows returned: {result.row_count}")

                # Show detailed results
                if result.rows:
                    print()
                    print("Results:")
                    print("-" * 40)

                    # Print header
                    header = " | ".join(result.columns)
                    print(header)
                    print("-" * len(header))

                    # Print rows (limit to 20 for display)
                    for row in result.rows[:20]:
                        values = [str(row.get(col, "")) for col in result.columns]
                        print(" | ".join(values))

                    if result.row_count > 20:
                        print(f"... and {result.row_count - 20} more rows")

            else:
                print(f"Status: Failed")
                print(f"Error: {result.error}")

            # Export result
            self._export_single(result)

            return result

        except Exception as e:
            print(f"Error: {e}")
            return KPIResult(
                kpi_name=kpi.name,
                columns=[],
                rows=[],
                error=str(e),
            )

    def _export_report(self, results: List[KPIResult]) -> None:
        """Export all results to a report file."""
        config = get_config()
        exporter = get_exporter(config.export_format)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"kpi_report_{timestamp}.{exporter.file_extension}"
        output_path = config.output_directory / filename

        exporter.export_report(results, output_path)
        print()
        print(f"Output saved to: {output_path}")

    def _export_single(self, result: KPIResult) -> None:
        """Export a single KPI result to a file."""
        config = get_config()
        exporter = get_exporter(config.export_format)

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        safe_name = result.kpi_name.lower().replace(" ", "_")
        filename = f"{safe_name}_{timestamp}.{exporter.file_extension}"
        output_path = config.output_directory / filename

        exporter.export(result, output_path)
        print()
        print(f"Output saved to: {output_path}")
