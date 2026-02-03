"""Base KPI class and related types for KPI implementation."""

from abc import ABC, abstractmethod
from dataclasses import dataclass
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

    name: str
    display_name: str
    type: ParameterType
    required: bool
    default: Optional[Any]
    description: str


class BaseKPI(ABC):
    """
    Abstract base class for all KPIs.

    To create a new KPI:
    1. Create a new file in src/kpis/
    2. Define a class that extends BaseKPI
    3. Implement all abstract methods
    4. The KPI will be auto-discovered on next launch
    """

    name: str = ""
    description: str = ""

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
    def execute(
        self, engine: Engine, params: Dict[str, Any]
    ) -> "KPIResult":  # Forward reference
        """
        Execute the KPI query and return results.

        Args:
            engine: SQLAlchemy database engine for executing queries
            params: Dictionary of parameter values provided by the user

        Returns:
            KPIResult containing the query results or error information.
        """
        pass


# Import KPIResult here to avoid circular imports
from src.models.result import KPIResult  # noqa: E402, F401
