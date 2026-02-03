"""
Store and retrieve the database URL in the system keychain (macOS Keychain).

Use this so you don't have to enter the DB URL every time you run scripts
that need a database connection.
"""
import keyring
from typing import Optional

SERVICE_NAME = "product_kpis"
DB_URL_KEY = "db_url"

# In-memory cache to avoid repeated keychain access in the same process
_db_url_cache: Optional[str] = None


def get_db_url() -> str:
    """
    Get the database URL from the keychain.

    If no URL is stored, prompts the user to enter it and then stores it
    in the keychain for future use.

    Returns:
        The database URL (e.g. postgresql://user:password@host:5432/dbname).

    Raises:
        ValueError: If keychain access fails or stored value is invalid.
    """
    global _db_url_cache

    if _db_url_cache is not None:
        return _db_url_cache

    url = keyring.get_password(SERVICE_NAME, DB_URL_KEY)

    if not url or not url.strip():
        url = _prompt_and_store_db_url()

    if not url or not url.strip():
        raise ValueError("Database URL is required. Run this script and enter a URL to store it in the keychain.")

    _db_url_cache = url.strip()
    return _db_url_cache


def set_db_url(url: str) -> None:
    """
    Store the database URL in the keychain.

    Args:
        url: Full database URL (e.g. postgresql://user:password@host:5432/dbname).
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


def _prompt_and_store_db_url() -> Optional[str]:
    """Prompt the user for the DB URL and offer to store it. Returns the URL or None."""
    print("No database URL found in keychain.")
    url = input("Enter database URL (e.g. postgresql://user:password@host:5432/dbname): ").strip()
    if not url:
        return None
    store = input("Store in keychain for future use? [Y/n]: ").strip().lower()
    if store in ("", "y", "yes"):
        set_db_url(url)
        print("Database URL stored in keychain.")
    return url


if __name__ == "__main__":
    if has_db_url():
        print("A database URL is already stored in the keychain.")
        change = input("Overwrite? [y/N]: ").strip().lower()
        if change not in ("y", "yes"):
            print("Done.")
            exit(0)
    url = input("Enter database URL: ").strip()
    if not url:
        print("No URL entered.")
        exit(1)
    set_db_url(url)
    print("Database URL stored in keychain.")
