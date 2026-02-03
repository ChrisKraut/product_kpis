"""Runtime configuration for the Product KPIs tool."""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path


class ExportFormat(Enum):
    """Supported export formats for KPI reports."""

    CSV = "csv"
    JSON = "json"


@dataclass
class RuntimeConfig:
    """
    In-memory configuration (not persisted between sessions).

    dev_mode resets to False on each launch per specification.
    """

    dev_mode: bool = False
    export_format: ExportFormat = ExportFormat.CSV
    output_directory: Path = field(default_factory=lambda: Path("output"))

    def __post_init__(self):
        """Ensure output directory exists."""
        self.output_directory.mkdir(parents=True, exist_ok=True)


# Global config instance - recreated on each launch
_config: RuntimeConfig | None = None


def get_config() -> RuntimeConfig:
    """Get the global runtime configuration."""
    global _config
    if _config is None:
        _config = RuntimeConfig()
    return _config


def reset_config() -> RuntimeConfig:
    """Reset configuration to defaults (called on launch)."""
    global _config
    _config = RuntimeConfig()
    return _config
