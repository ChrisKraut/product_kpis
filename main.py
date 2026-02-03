#!/usr/bin/env python3
"""
Product KPIs – main console runner.

Run with no arguments for an interactive menu, or use subcommands for scripts/automation.
"""
import argparse
import sys
from typing import Optional

from database import init_db_engine
from login import get_db_url, set_db_url, clear_db_url, has_db_url
from product_kpis import get_orders_created_by_date_last_14_days


def _run_orders_by_date(shop_id: Optional[str] = None) -> None:
    """Load DB URL, create engine, run orders-by-date KPI and print results."""
    try:
        db_url = get_db_url()
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)
    engine = init_db_engine(db_url)
    rows = get_orders_created_by_date_last_14_days(engine, shop_id=shop_id)
    print("\nOrders created by date (last 14 days)")
    print("-" * 40)
    for r in rows:
        print(f"  {r['date']}: {r['orders_count']}")
    print("-" * 40)
    print(f"Total: {sum(r['orders_count'] for r in rows)} orders\n")


def _cmd_kpi_orders_by_date(shop_id: Optional[str]) -> None:
    _run_orders_by_date(shop_id=shop_id)


def _cmd_db_set(url: Optional[str]) -> None:
    if url:
        set_db_url(url)
        print("Database URL stored in keychain.")
    else:
        u = input("Enter database URL: ").strip()
        if not u:
            print("No URL entered.")
            sys.exit(1)
        set_db_url(u)
        print("Database URL stored in keychain.")


def _cmd_db_clear() -> None:
    clear_db_url()
    print("Database URL removed from keychain.")


def _cmd_db_show() -> None:
    if not has_db_url():
        print("No database URL stored in keychain.")
        return
    url = get_db_url()
    # Mask password for display
    if "@" in url and "://" in url:
        prefix, rest = url.split("://", 1)
        if "@" in rest:
            user_part, host_part = rest.rsplit("@", 1)
            if ":" in user_part:
                user, _ = user_part.split(":", 1)
                user_part = f"{user}:****"
            masked = f"{prefix}://{user_part}@{host_part}"
        else:
            masked = url
    else:
        masked = url
    print(f"Stored database URL: {masked}")


def _interactive_menu() -> None:
    """Run the interactive console menu."""
    while True:
        print()
        print("Product KPIs")
        print("============")
        print("  1. Set database URL (keychain)")
        print("  2. Show stored database URL")
        print("  3. KPI: Orders created by date (last 14 days)")
        print("  4. Clear stored database URL")
        print("  5. Exit")
        print()
        choice = input("Choice [1-5]: ").strip() or "5"

        if choice == "1":
            _cmd_db_set(None)
        elif choice == "2":
            _cmd_db_show()
        elif choice == "3":
            shop_id = input("Shop ID (leave empty for all shops): ").strip() or None
            try:
                _run_orders_by_date(shop_id=shop_id)
            except Exception as e:
                print(f"Error: {e}")
        elif choice == "4":
            _cmd_db_clear()
        elif choice == "5":
            print("Bye.")
            break
        else:
            print("Invalid choice.")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Product KPIs – run from console or use subcommands.",
        prog="python main.py",
    )
    sub = parser.add_subparsers(dest="command", help="Command (omit for interactive menu)")

    # db *
    db = sub.add_parser("db", help="Database URL in keychain")
    db_sub = db.add_subparsers(dest="db_action", required=True)
    db_set = db_sub.add_parser("set", help="Store database URL")
    db_set.add_argument("url", nargs="?", help="Database URL (prompt if omitted)")
    db_sub.add_parser("clear", help="Remove stored database URL")
    db_sub.add_parser("show", help="Show stored database URL (password masked)")

    # kpi *
    kpi = sub.add_parser("kpi", help="Run a KPI")
    kpi_sub = kpi.add_subparsers(dest="kpi_action", required=True)
    orders = kpi_sub.add_parser("orders-by-date", help="Orders created by date, last 14 days")
    orders.add_argument("--shop-id", default=None, help="Filter by shop ID (optional)")

    return parser.parse_args()


def main() -> None:
    args = _parse_args()

    if args.command is None:
        _interactive_menu()
        return

    if args.command == "db":
        if args.db_action == "set":
            _cmd_db_set(getattr(args, "url", None))
        elif args.db_action == "clear":
            _cmd_db_clear()
        elif args.db_action == "show":
            _cmd_db_show()
        return

    if args.command == "kpi":
        if args.kpi_action == "orders-by-date":
            _cmd_kpi_orders_by_date(shop_id=args.shop_id)
        return


if __name__ == "__main__":
    main()
