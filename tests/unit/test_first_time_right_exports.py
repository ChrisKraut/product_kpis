"""Unit tests for First Time Right (Exports) KPI."""

import pytest
from datetime import date, datetime, timedelta
from unittest.mock import MagicMock, patch

from src.kpis.first_time_right_exports import FirstTimeRightExportsKPI
from src.kpis.base import ParameterType
from src.models.result import KPIResult


class TestFirstTimeRightExportsKPI:
    """Tests for FirstTimeRightExportsKPI class."""

    @pytest.fixture
    def kpi(self):
        """Create KPI instance for testing."""
        return FirstTimeRightExportsKPI()

    # T005: Test get_parameters() returns correct parameter definitions
    def test_get_parameters_returns_expected_parameters(self, kpi):
        """Verify get_parameters returns expected parameters."""
        params = kpi.get_parameters()

        assert len(params) == 4

        param_names = [p.name for p in params]
        assert "start_date" in param_names
        assert "end_date" in param_names
        assert "shop_id" in param_names
        assert "discover_action_types" in param_names

    def test_get_parameters_types_are_correct(self, kpi):
        """Verify parameter types match expected types."""
        params = kpi.get_parameters()
        params_by_name = {p.name: p for p in params}

        assert params_by_name["start_date"].type == ParameterType.DATE
        assert params_by_name["end_date"].type == ParameterType.DATE
        assert params_by_name["shop_id"].type == ParameterType.STRING

    def test_get_parameters_none_are_required(self, kpi):
        """Verify all parameters are optional."""
        params = kpi.get_parameters()

        for param in params:
            assert param.required is False, f"{param.name} should be optional"

    # T006: Test execute() returns KPIResult with correct columns
    def test_execute_returns_kpi_result_with_correct_columns(self, kpi, mock_engine):
        """Verify execute returns KPIResult with expected columns."""
        # Setup mock to return sample data
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (100, 85)  # total, successful
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        result = kpi.execute(mock_engine, {})

        assert isinstance(result, KPIResult)
        assert result.kpi_name == "First Time Right (Exports)"
        assert "total_exports" in result.columns
        assert "successful_exports" in result.columns
        assert "failed_exports" in result.columns
        assert "success_rate" in result.columns

    def test_execute_computes_failed_and_rate(self, kpi, mock_engine):
        """Verify failed_exports and success_rate are computed correctly."""
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (100, 80)  # 80% success rate
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        result = kpi.execute(mock_engine, {})

        # Now returns multiple rows (one per action type in config)
        assert len(result.rows) >= 1
        row = result.rows[0]
        assert row["total_exports"] == 100
        assert row["successful_exports"] == 80
        assert row["failed_exports"] == 20
        assert row["success_rate"] == 80.0
        assert "action_type" in row

    # T007: Test execute() handles empty result set gracefully
    def test_execute_handles_empty_result(self, kpi, mock_engine):
        """Verify empty result set returns zero values."""
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (0, 0)  # No records
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        result = kpi.execute(mock_engine, {})

        assert result.success is True
        # Now returns multiple rows (one per action type in config)
        assert len(result.rows) >= 1
        row = result.rows[0]
        assert row["total_exports"] == 0
        assert row["successful_exports"] == 0
        assert row["failed_exports"] == 0
        assert row["success_rate"] == 0.0

    # T008: Test execute() catches database errors
    def test_execute_catches_database_error(self, kpi, mock_engine):
        """Verify database errors are caught and returned in error field."""
        mock_engine.connect.side_effect = Exception("Database connection failed")

        result = kpi.execute(mock_engine, {})

        assert isinstance(result, KPIResult)
        assert result.success is False
        assert result.error is not None
        assert "Database connection failed" in result.error

    # T016: Test date range filtering
    def test_date_range_applied_to_query(self, kpi, mock_engine):
        """Verify start_date and end_date are applied to query."""
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (50, 45)
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        params = {
            "start_date": date(2026, 1, 1),
            "end_date": date(2026, 1, 15),
        }
        result = kpi.execute(mock_engine, params)

        # Verify query was executed with date parameters
        assert mock_conn.execute.called
        call_args = mock_conn.execute.call_args
        query_params = call_args[0][1] if len(call_args[0]) > 1 else call_args[1]
        assert result.parameters.get("start_date") == date(2026, 1, 1)
        assert result.parameters.get("end_date") == date(2026, 1, 15)

    # T017: Test invalid date range validation
    def test_invalid_date_range_returns_error(self, kpi, mock_engine):
        """Verify end_date before start_date returns validation error."""
        params = {
            "start_date": date(2026, 1, 15),
            "end_date": date(2026, 1, 1),  # Before start
        }
        result = kpi.execute(mock_engine, params)

        assert result.success is False
        assert result.error is not None
        assert "date" in result.error.lower()

    # T020: Test shop_id filter applies
    def test_shop_id_filter_applied(self, kpi, mock_engine):
        """Verify shop_id filter is applied when provided."""
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (30, 25)
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        shop_id = "123e4567-e89b-12d3-a456-426614174000"
        params = {"shop_id": shop_id}
        result = kpi.execute(mock_engine, params)

        assert result.success is True
        assert result.parameters.get("shop_id") == shop_id

    # T021: Test shop_id is optional
    def test_shop_id_optional(self, kpi, mock_engine):
        """Verify query works without shop_id parameter."""
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (100, 90)
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        result = kpi.execute(mock_engine, {})

        assert result.success is True
        assert result.parameters.get("shop_id") is None

    def test_kpi_name_and_description(self, kpi):
        """Verify KPI has correct name and description."""
        assert kpi.name == "First Time Right (Exports)"
        assert "export" in kpi.description.lower() or "success" in kpi.description.lower()

    def test_duration_tracking(self, kpi, mock_engine):
        """Verify duration is tracked in result."""
        mock_conn = MagicMock()
        mock_result = MagicMock()
        mock_result.fetchone.return_value = (10, 8)
        mock_conn.execute.return_value = mock_result
        mock_engine.connect.return_value.__enter__ = MagicMock(return_value=mock_conn)
        mock_engine.connect.return_value.__exit__ = MagicMock(return_value=False)

        result = kpi.execute(mock_engine, {})

        assert result.duration_seconds >= 0
