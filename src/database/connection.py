"""Database connection utilities using SQLAlchemy."""

from typing import Any

from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError


class DatabaseConnectionError(Exception):
    """Raised when database connection fails."""

    pass


def init_db_engine(db_url: str) -> Any:
    """
    Initialize and return a SQLAlchemy database engine.

    This function creates a database engine using the provided connection URL.
    The engine can be used to execute queries and manage database connections.

    Args:
        db_url: Database connection URL in SQLAlchemy format.
                Example: 'postgresql://user:password@localhost:5432/database'

    Returns:
        SQLAlchemy Engine object that can be used for database operations.

    Example:
        >>> engine = init_db_engine('postgresql://user:pass@localhost:5432/mydb')
        >>> with engine.connect() as conn:
        ...     result = conn.execute(text("SELECT 1"))
    """
    try:
        engine = create_engine(db_url)
        return engine
    except SQLAlchemyError as e:
        raise DatabaseConnectionError(
            f"Cannot connect to database. Check VPN connection and credentials.\n"
            f"Details: {e}"
        ) from e
