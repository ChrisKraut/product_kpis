"""Data models for KPI results and reports."""

from dataclasses import dataclass, field
from datetime import datetime
from typing import Any, Dict, List, Optional


@dataclass
class KPIResult:
    """The output of executing a KPI."""

    kpi_name: str
    columns: List[str]
    rows: List[Dict[str, Any]]
    executed_at: datetime = field(default_factory=datetime.now)
    duration_seconds: float = 0.0
    parameters: Dict[str, Any] = field(default_factory=dict)
    from_cache: bool = False
    error: Optional[str] = None

    @property
    def row_count(self) -> int:
        """Number of rows in the result."""
        return len(self.rows)

    @property
    def success(self) -> bool:
        """Whether execution succeeded."""
        return self.error is None


@dataclass
class KPIReport:
    """A collection of KPI results from a 'Run All' execution."""

    generated_at: datetime = field(default_factory=datetime.now)
    results: List[KPIResult] = field(default_factory=list)
    total_duration_seconds: float = 0.0
    dev_mode: bool = False

    @property
    def success_count(self) -> int:
        """Number of successful KPIs."""
        return sum(1 for r in self.results if r.success)

    @property
    def failure_count(self) -> int:
        """Number of failed KPIs."""
        return sum(1 for r in self.results if not r.success)
