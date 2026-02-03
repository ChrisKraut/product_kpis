"""Base exporter class for KPI results."""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import List

from src.models.result import KPIResult


class Exporter(ABC):
    """Abstract base class for result exporters."""

    @abstractmethod
    def export(self, result: KPIResult, output_path: Path) -> None:
        """
        Export a single KPI result to a file.

        Args:
            result: The KPI result to export
            output_path: Full path to the output file
        """
        pass

    @abstractmethod
    def export_report(self, results: List[KPIResult], output_path: Path) -> None:
        """
        Export multiple KPI results as a combined report.

        Args:
            results: List of KPI results to include
            output_path: Full path to the output file
        """
        pass

    @property
    @abstractmethod
    def file_extension(self) -> str:
        """Return the file extension for this export format."""
        pass
