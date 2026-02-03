"""
KPI Interface Contract

This file defines the contract that all KPIs must implement.
It serves as documentation and type reference for KPI developers.

NOTE: This is a contract specification file, not production code.
The actual implementation will be in src/kpis/base.py
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from typing import Any, Dict, List, Optional

from sqlalchemy.engine import Engine


class ParameterType(Enum):
    """Supported parameter types for KPI configuration."""
    STRING = "string"
    DATE = "date"
    INTEGER = "integer"
    BOOLEAN = "boolean"


@dataclass
class Parameter:
    """A configurable input parameter for a KPI."""
    name: str                    # Internal identifier (e.g., "shop_id")
    display_name: str            # Human-readable name (e.g., "Shop ID")
    type: ParameterType          # Data type
    required: bool               # Whether parameter is mandatory
    default: Optional[Any]       # Default value if not provided
    description: str             # Help text for the user


@dataclass
class KPIResult:
    """The output of executing a KPI."""
    kpi_name: str                          # Name of the KPI
    columns: List[str]                     # Column names in order
    rows: List[Dict[str, Any]]             # Result data
    executed_at: datetime = None           # When executed (auto-filled)
    duration_seconds: float = 0.0          # Execution time
    parameters: Dict[str, Any] = None      # Parameters used
    from_cache: bool = False               # Whether from cache
    error: Optional[str] = None            # Error message if failed

    @property
    def row_count(self) -> int:
        """Number of rows in the result."""
        return len(self.rows)

    @property
    def success(self) -> bool:
        """Whether execution succeeded."""
        return self.error is None


class BaseKPI(ABC):
    """
    Abstract base class for all KPIs.

    To create a new KPI:
    1. Create a new file in src/kpis/
    2. Define a class that extends BaseKPI
    3. Implement all abstract methods
    4. The KPI will be auto-discovered on next launch

    Example:
        class MyKPI(BaseKPI):
            name = "My KPI Name"
            description = "What this KPI measures"

            def get_parameters(self) -> List[Parameter]:
                return [...]

            def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
                # Query database and return result
                return KPIResult(...)
    """

    # Class attributes to be defined by subclasses
    name: str = ""              # Display name for menu
    description: str = ""       # What this KPI measures

    @abstractmethod
    def get_parameters(self) -> List[Parameter]:
        """
        Return the list of configurable parameters for this KPI.

        Returns:
            List of Parameter objects defining the inputs this KPI accepts.
            Return empty list if KPI has no configurable parameters.
        """
        pass

    @abstractmethod
    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        """
        Execute the KPI query and return results.

        Args:
            engine: SQLAlchemy database engine for executing queries
            params: Dictionary of parameter values provided by the user

        Returns:
            KPIResult containing the query results or error information.

        Notes:
            - Do NOT handle caching here - that's done by the runner
            - Always return a KPIResult, even on error (set error field)
            - Use params.get("key", default) for optional parameters
        """
        pass


# Export format contract
class Exporter(ABC):
    """Base class for result exporters."""

    @abstractmethod
    def export(self, result: KPIResult, output_path: str) -> None:
        """
        Export a single KPI result to a file.

        Args:
            result: The KPI result to export
            output_path: Full path to the output file
        """
        pass

    @abstractmethod
    def export_report(self, results: List[KPIResult], output_path: str) -> None:
        """
        Export multiple KPI results as a combined report.

        Args:
            results: List of KPI results to include
            output_path: Full path to the output file
        """
        pass
