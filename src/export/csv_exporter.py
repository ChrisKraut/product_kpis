"""CSV exporter for KPI results."""

import csv
from pathlib import Path
from typing import List

from src.export.base import Exporter
from src.models.result import KPIResult


class CSVExporter(Exporter):
    """Export KPI results to CSV format."""

    @property
    def file_extension(self) -> str:
        return "csv"

    def export(self, result: KPIResult, output_path: Path) -> None:
        """Export a single KPI result to CSV."""
        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, "w", newline="", encoding="utf-8") as f:
            if result.rows:
                writer = csv.DictWriter(f, fieldnames=result.columns)
                writer.writeheader()
                writer.writerows(result.rows)

    def export_report(self, results: List[KPIResult], output_path: Path) -> None:
        """Export multiple KPI results to a combined CSV report."""
        output_path.parent.mkdir(parents=True, exist_ok=True)

        with open(output_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)

            for i, result in enumerate(results):
                # Add separator between KPIs
                if i > 0:
                    writer.writerow([])

                # Write KPI header
                writer.writerow([f"=== {result.kpi_name} ==="])
                writer.writerow([f"Status: {'Success' if result.success else 'Failed'}"])
                writer.writerow([f"Duration: {result.duration_seconds:.2f}s"])
                writer.writerow([f"Rows: {result.row_count}"])

                if result.error:
                    writer.writerow([f"Error: {result.error}"])
                    continue

                if result.rows:
                    writer.writerow([])
                    # Write data
                    dict_writer = csv.DictWriter(f, fieldnames=result.columns)
                    dict_writer.writeheader()
                    dict_writer.writerows(result.rows)
