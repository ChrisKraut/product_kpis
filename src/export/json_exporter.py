"""JSON exporter for KPI results."""

import json
from pathlib import Path
from typing import Any, List

from src.export.base import Exporter
from src.models.result import KPIResult


class JSONExporter(Exporter):
    """Export KPI results to JSON format."""

    @property
    def file_extension(self) -> str:
        return "json"

    def _serialize_result(self, result: KPIResult) -> dict[str, Any]:
        """Convert KPIResult to JSON-serializable dict."""
        return {
            "kpi_name": result.kpi_name,
            "executed_at": result.executed_at.isoformat(),
            "duration_seconds": result.duration_seconds,
            "parameters": result.parameters,
            "success": result.success,
            "error": result.error,
            "row_count": result.row_count,
            "columns": result.columns,
            "data": result.rows,
        }

    def export(self, result: KPIResult, output_path: Path) -> None:
        """Export a single KPI result to JSON."""
        output_path.parent.mkdir(parents=True, exist_ok=True)

        data = self._serialize_result(result)

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, default=str)

    def export_report(self, results: List[KPIResult], output_path: Path) -> None:
        """Export multiple KPI results to a combined JSON report."""
        output_path.parent.mkdir(parents=True, exist_ok=True)

        report = {
            "generated_at": results[0].executed_at.isoformat() if results else None,
            "kpi_count": len(results),
            "success_count": sum(1 for r in results if r.success),
            "failure_count": sum(1 for r in results if not r.success),
            "total_duration_seconds": sum(r.duration_seconds for r in results),
            "results": [self._serialize_result(r) for r in results],
        }

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, default=str)
