"""Orders by Date KPI - Shows order counts for the last 14 days."""

from datetime import datetime, timedelta
from typing import Any, Dict, List

from sqlalchemy import text
from sqlalchemy.engine import Engine

from src.kpis.base import BaseKPI, Parameter, ParameterType
from src.models.result import KPIResult


class OrdersByDateKPI(BaseKPI):
    """
    KPI: Orders created by date for the last 14 days.

    Queries the order table, groups by calendar date, and returns one row per day
    with the count of orders created on that day. Days with zero orders are
    included so the result always has exactly 14 entries.
    """

    name = "Orders by Date"
    description = "Order counts for the last 14 days, optionally filtered by shop"

    def get_parameters(self) -> List[Parameter]:
        """Return configurable parameters for this KPI."""
        return [
            Parameter(
                name="shop_id",
                display_name="Shop ID",
                type=ParameterType.STRING,
                required=False,
                default=None,
                description="Filter by shop ID (leave empty for all shops)",
            )
        ]

    def execute(self, engine: Engine, params: Dict[str, Any]) -> KPIResult:
        """Execute the orders-by-date query."""
        start_time = datetime.now()

        try:
            end_date = datetime.utcnow().date()
            start_date = end_date - timedelta(days=13)
            date_range_days = 14

            shop_id = params.get("shop_id")

            query = """
            SELECT
                (creation_date AT TIME ZONE 'UTC')::date AS order_date,
                COUNT(*) AS orders_count
            FROM "order"
            WHERE
                creation_date >= :start_date
                AND creation_date < :end_date + INTERVAL '1 day'
            """

            query_params: Dict[str, Any] = {
                "start_date": start_date,
                "end_date": end_date,
            }

            if shop_id:
                query += " AND shop_id = :shop_id"
                query_params["shop_id"] = shop_id

            query += """
            GROUP BY (creation_date AT TIME ZONE 'UTC')::date
            ORDER BY order_date;
            """

            with engine.connect() as conn:
                result = conn.execute(text(query), query_params)
                rows = result.fetchall()

            # Convert to dict mapping date -> count
            count_by_date = {
                row[0].isoformat() if hasattr(row[0], "isoformat") else str(row[0]): row[1]
                for row in rows
            }

            # Build output with all 14 days (including zeros)
            output_rows: List[Dict[str, Any]] = []
            for i in range(date_range_days):
                d = start_date + timedelta(days=i)
                date_str = d.isoformat()
                output_rows.append({
                    "date": date_str,
                    "orders_count": count_by_date.get(date_str, 0),
                })

            duration = (datetime.now() - start_time).total_seconds()

            return KPIResult(
                kpi_name=self.name,
                columns=["date", "orders_count"],
                rows=output_rows,
                duration_seconds=duration,
                parameters=params,
            )

        except Exception as e:
            duration = (datetime.now() - start_time).total_seconds()
            return KPIResult(
                kpi_name=self.name,
                columns=["date", "orders_count"],
                rows=[],
                duration_seconds=duration,
                parameters=params,
                error=str(e),
            )
