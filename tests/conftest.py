"""Shared pytest fixtures for Product KPIs tests."""

import pytest
from unittest.mock import MagicMock


@pytest.fixture
def mock_engine():
    """Mock SQLAlchemy engine for testing without database."""
    engine = MagicMock()
    return engine


@pytest.fixture
def sample_kpi_result():
    """Sample KPI result data for testing."""
    return {
        "columns": ["date", "orders_count"],
        "rows": [
            {"date": "2026-01-20", "orders_count": 42},
            {"date": "2026-01-21", "orders_count": 38},
        ],
    }
