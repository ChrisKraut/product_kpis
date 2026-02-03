"""Export functionality for KPI reports (CSV, JSON)."""

from src.config import ExportFormat
from src.export.base import Exporter
from src.export.csv_exporter import CSVExporter
from src.export.json_exporter import JSONExporter


def get_exporter(format: ExportFormat) -> Exporter:
    """
    Factory function to get the appropriate exporter.

    Args:
        format: The export format to use

    Returns:
        An Exporter instance for the specified format
    """
    if format == ExportFormat.CSV:
        return CSVExporter()
    elif format == ExportFormat.JSON:
        return JSONExporter()
    else:
        raise ValueError(f"Unsupported export format: {format}")
