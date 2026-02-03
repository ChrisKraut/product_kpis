"""
Store and retrieve the database URL in the system keychain (macOS Keychain).

Use this so you don't have to enter the DB URL every time you run scripts
that need a database connection.
"""

from typing import Optional

import keyring

SERVICE_NAME = "product_kpis"
DB_URL_KEY = "db_url"


class KeychainAccessError(Exception):
    """Raised when keychain access fails."""

    pass

# In-memory cache to avoid repeated keychain access in the same process
_db_url_cache: Optional[str] = None


def get_db_url() -> str:
    """
    Get the database URL from the keychain.

    Returns:
        The database URL (e.g. postgresql://user:password@host:5432/dbname).

    Raises:
        ValueError: If no URL is stored or keychain access fails.
    """
    global _db_url_cache

    if _db_url_cache is not None:
        return _db_url_cache

    try:
        url = keyring.get_password(SERVICE_NAME, DB_URL_KEY)
    except keyring.errors.KeyringError as e:
        raise KeychainAccessError(
            "Cannot access keychain. Grant permission in System Preferences → "
            "Security & Privacy → Privacy → Full Disk Access.\n"
            f"Details: {e}"
        ) from e

    if not url or not url.strip():
        raise ValueError(
            "No database URL stored. Use Settings → Set database URL to configure."
        )

    _db_url_cache = url.strip()
    return _db_url_cache


def set_db_url(url: str) -> None:
    """
    Store the database URL in the keychain.

    Args:
        url: Full database URL (e.g. postgresql://user:password@host:5432/dbname).

    Raises:
        ValueError: If URL is empty.
    """
    global _db_url_cache

    if not url or not url.strip():
        raise ValueError("Database URL cannot be empty.")

    keyring.set_password(SERVICE_NAME, DB_URL_KEY, url.strip())
    _db_url_cache = url.strip()


def clear_db_url() -> None:
    """Remove the stored database URL from the keychain."""
    global _db_url_cache

    try:
        keyring.delete_password(SERVICE_NAME, DB_URL_KEY)
    except keyring.errors.PasswordDeleteError:
        pass
    _db_url_cache = None


def has_db_url() -> bool:
    """Return True if a database URL is stored in the keychain."""
    url = keyring.get_password(SERVICE_NAME, DB_URL_KEY)
    return bool(url and url.strip())


def get_masked_url() -> str:
    """
    Get a masked version of the stored URL for display.

    Returns:
        URL with password masked, or message if no URL stored.
    """
    if not has_db_url():
        return "No database URL stored."

    url = get_db_url()

    # Mask password for display
    if "@" in url and "://" in url:
        prefix, rest = url.split("://", 1)
        if "@" in rest:
            user_part, host_part = rest.rsplit("@", 1)
            if ":" in user_part:
                user, _ = user_part.split(":", 1)
                user_part = f"{user}:****"
            return f"{prefix}://{user_part}@{host_part}"

    return url
