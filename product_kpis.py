"""
Product KPIs generated from the database.

This module provides KPI functions that query the database directly.
"""
from datetime import datetime, timedelta
from typing import Any, List, Dict, Optional

from sqlalchemy import text


def get_orders_created_by_date_last_14_days(
    engine: Any,
    shop_id: Optional[str] = None,
) -> List[Dict[str, Any]]:
    """
    KPI: Orders created by date for the last 14 days (including today).

    Queries the order table, groups by calendar date, and returns one row per day
    with the count of orders created on that day. Days with zero orders are
    included so the result always has exactly 14 entries.

    Args:
        engine: SQLAlchemy database engine (from database.init_db_engine).
        shop_id: Optional shop ID to filter orders. If None, all shops are included.

    Returns:
        List of dicts with keys "date" (YYYY-MM-DD) and "orders_count", ordered by date ascending.
        Example: [{"date": "2025-01-21", "orders_count": 12}, ...]

    Example:
        >>> engine = init_db_engine("postgresql://...")
        >>> rows = get_orders_created_by_date_last_14_days(engine, shop_id="shop-123")
    """
    end_date = datetime.utcnow().date()
    start_date = end_date - timedelta(days=13)
    date_range_days = 14

    query = """
    SELECT
        (creation_date AT TIME ZONE 'UTC')::date AS order_date,
        COUNT(*) AS orders_count
    FROM "order"
    WHERE
        creation_date >= :start_date
        AND creation_date < :end_date + INTERVAL '1 day'
    """
    params: Dict[str, Any] = {
        "start_date": start_date,
        "end_date": end_date,
    }
    if shop_id is not None:
        query += " AND shop_id = :shop_id"
        params["shop_id"] = shop_id
    query += """
    GROUP BY (creation_date AT TIME ZONE 'UTC')::date
    ORDER BY order_date;
    """

    with engine.connect() as conn:
        result = conn.execute(text(query), params)
        rows = result.fetchall()

    count_by_date = {row[0].isoformat() if hasattr(row[0], "isoformat") else str(row[0]): row[1] for row in rows}

    out: List[Dict[str, Any]] = []
    for i in range(date_range_days):
        d = start_date + timedelta(days=i)
        date_str = d.isoformat()
        out.append({
            "date": date_str,
            "orders_count": count_by_date.get(date_str, 0),
        })
    return out
