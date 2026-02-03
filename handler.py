"""
Shared handler functions for report generation.

This module contains shared utility functions and report generators used across
multiple scripts. Some functions here are legacy and may be deprecated in favor
 of more specialized modules.

Note: The `generate_leitzonen_report_csv` function in this module is DEPRECATED.
      Use `leitzonen_report.report_generator.generate_leitzonen_report_csv` instead.
"""
from datetime import datetime
import csv
import random
import json
import os
from pathlib import Path
from collections import defaultdict
from sqlalchemy import text
import sys

# Import shared utilities for caching
sys.path.insert(0, str(Path(__file__).parent))
from utils import execute_cached_query


def _get_cache_file_path(shop_id, timeframe_months, script_name='leitzonen'):
    """
    DEPRECATED: Use utils.get_cache_file_path instead.
    
    Generate cache file path based on script name, shop_id, and timeframe.
    This function uses the old cache structure (not shop-specific).
    """
    cache_dir = Path('cache')
    cache_dir.mkdir(exist_ok=True)
    cache_filename = f"{script_name}_shop_{shop_id}_months_{timeframe_months}.json"
    return cache_dir / cache_filename


def _save_cache(cache_path, data, metadata):
    """Save data to cache file with metadata."""
    cache_data = {
        'metadata': metadata,
        'data': data
    }
    with open(cache_path, 'w', encoding='utf-8') as f:
        json.dump(cache_data, f, default=str, indent=2)
    print(f"Cache saved to: {cache_path}")


def _load_cache(cache_path):
    """Load data from cache file."""
    with open(cache_path, 'r', encoding='utf-8') as f:
        cache_data = json.load(f)
    print(f"Cache loaded from: {cache_path}")
    return cache_data['metadata'], cache_data['data']


def _should_use_cache(cache_path):
    """Ask user if they want to use the cache file."""
    if not cache_path.exists():
        return False
    
    print(f"\nCache file found: {cache_path}")
    response = input("Do you want to use the cache file? (y/n): ").strip().lower()
    return response in ('y', 'yes')


def _get_output_dir(script_name):
    """Create and return output directory for the script."""
    output_dir = Path('output') / script_name
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir


def _get_init_start_stock(engine, product_id, shop_id, warehouse_id, start_date):
    """
    Fetches the last known stock quantity for a product at a specific location
    before a given start date.
    """
    query = """
    SELECT 
        su.new_quantity
    FROM stock_update AS su
    JOIN stock AS s ON su.stock_id = s.id
    JOIN product AS p ON s.product_id = p.id
    WHERE 
        p.id = :product_id
        AND p.shop_id = :shop_id
        AND s.warehouse_id = :warehouse_id
        AND su.updated_date < :start_date
    ORDER BY su.updated_date DESC
    LIMIT 1;
    """
    
    with engine.connect() as conn:
        result = conn.execute(
            text(query),
            {
                "product_id": product_id,
                "shop_id": shop_id,
                "warehouse_id": warehouse_id,
                "start_date": start_date
            }
        )
        row = result.fetchone()
    
    return row[0] if row and row[0] is not None else 0

def generate_stock_movement_csv(engine, product_id, shop_id, start_date, end_date, output_file):
    """
    Generates a CSV report detailing all stock movements for a given product.
    
    This function tracks various types of stock movements including:
    - Transfers (Incoming)
    - Order Shipments (reduces stock)
    - Returns (Incoming)
    - Stock Updates (resets stock level)
    
    The report shows the correction value only on 'Stock Update' events and calculates
    expected stock levels based on all movements.
    
    Args:
        engine: SQLAlchemy database engine
        product_id: UUID of the product to analyze
        shop_id: UUID of the shop
        start_date: Start date for the analysis (YYYY-MM-DD format or datetime)
        end_date: End date for the analysis (YYYY-MM-DD format or datetime)
        output_file: Path to the output CSV file
    
    Returns:
        None (writes CSV file to disk)
    
    Example:
        >>> generate_stock_movement_csv(
        ...     engine=engine,
        ...     product_id="product-123",
        ...     shop_id="shop-456",
        ...     start_date="2024-01-01",
        ...     end_date="2024-12-31",
        ...     output_file="stock_report.csv"
        ... )
    """
    query_str = """
    WITH all_movements AS (
        -- TRANSFER (Incoming)
        SELECT
            t.updated_date AS movement_date,
            'Transfer (Incoming)' AS movement_type,
            p.sku AS product_sku,
            p.name AS product_name,
            ti.quantity_stocked AS quantity_moved,
            t.id AS identifier,
            w.name AS location,
            w.id AS warehouse_id,
            t.shop_id AS shop_id,
            ti.product_id as product_id
        FROM transfer AS t
        JOIN transfer_item AS ti ON t.id = ti.transfer_id
        JOIN product AS p ON ti.product_id = p.id
        JOIN warehouse AS w ON t.destination = w.id

        UNION ALL

        -- ORDER SHIPPED (reduces stock)
        SELECT
            oi.updated_date AS movement_date,
            'Order Shipped' AS movement_type,
            p.sku AS product_sku,
            p.name AS product_name,
            fi.quantity AS quantity_moved,
            o.id AS identifier,
            w.name AS location,
            w.id AS warehouse_id,
            o.shop_id AS shop_id,
            oi.product_id as product_id
        FROM "order" AS o
        JOIN order_item AS oi ON o.id = oi.order_id
        JOIN fulfillment AS f ON o.id = f.order_id
        JOIN fulfillment_item AS fi ON f.id = fi.fulfillment_id
             AND fi.order_item_id = oi.id
        JOIN product AS p ON p.id = oi.product_id
        JOIN warehouse AS w ON f.warehouse_id = w.id
        WHERE oi.state = 'shipped'

        UNION ALL

        -- RETURN (Incoming)
        SELECT
            r.updated_date AS movement_date,
            'Return (Incoming)' AS movement_type,
            p.sku AS product_sku,
            p.name AS product_name,
            ri.quantity AS quantity_moved,
            r.id AS identifier,
            w.name AS location,
            w.id AS warehouse_id,
            r.shop_id as shop_id,
            ri.product_id as product_id
        FROM return AS r
        JOIN return_item AS ri ON r.id = ri.return_id
        JOIN product AS p ON ri.product_id = p.id
        JOIN warehouse AS w ON r.warehouse_id = w.id

        UNION ALL

        -- STOCK UPDATE (resets stock level to new_quantity)
        SELECT
            su.updated_date AS movement_date,
            'Stock Update' AS movement_type,
            p.sku AS product_sku,
            p.name AS product_name,
            su.new_quantity AS quantity_moved,
            su.id AS identifier,
            w.name AS location,
            w.id AS warehouse_id,
            p.shop_id as shop_id,
            p.id as product_id
        FROM stock_update AS su
        JOIN stock AS s ON su.stock_id = s.id
        JOIN warehouse AS w ON s.warehouse_id = w.id
        JOIN product AS p ON s.product_id = p.id
    )
    SELECT
        movement_date    AS "date",
        movement_type    AS "movement_type",
        product_sku      AS "product_sku",
        product_name     AS "product_name",
        quantity_moved   AS "quantity_moved",
        identifier       AS "identifier",
        location         AS "location",
        warehouse_id     AS "warehouse_id"
    FROM all_movements
    WHERE
        product_id = :product_id
        AND shop_id = :shop_id
        AND movement_date >= :start_date
        AND movement_date < :end_date
    ORDER BY movement_date;
    """

    rows_data, metadata = execute_cached_query(
        engine=engine,
        query=query_str,
        params={
            "product_id": product_id,
            "shop_id": shop_id,
            "start_date": start_date,
            "end_date": end_date,
        },
        shop_id=shop_id,
        query_name="stock_movement",
        use_cache=True
    )
    
    movements = rows_data

    expected_stock_per_location = {}
    last_reported_stock_per_location = {}
    processed_rows = []

    unique_warehouse_ids = set(m["warehouse_id"] for m in movements)
    for wh_id in unique_warehouse_ids:
        initial_stock = _get_init_start_stock(engine, product_id, shop_id, wh_id, start_date)
        expected_stock_per_location[wh_id] = initial_stock
        last_reported_stock_per_location[wh_id] = initial_stock

    for m in movements:
        loc_wh_id = m["warehouse_id"]
        current_expected_stock = expected_stock_per_location.get(loc_wh_id, 0)
        
        if m["movement_type"] == "Order Shipped":
            quantity_change = -m["quantity_moved"]
        else:
            quantity_change = m["quantity_moved"]

        starting_stock = current_expected_stock
        correction_for_row = "" 

        if m["movement_type"] == "Stock Update":
            reported_new_quantity = quantity_change
            
            quantity_moved_for_report = reported_new_quantity - starting_stock
            m["quantity_moved"] = quantity_moved_for_report
            
            # CHANGED: New calculation for the correction amount
            correction_for_row = reported_new_quantity - starting_stock
            
            current_expected_stock = reported_new_quantity
            last_reported_stock_per_location[loc_wh_id] = reported_new_quantity
        else:
            current_expected_stock += quantity_change
        
        expected_stock_per_location[loc_wh_id] = current_expected_stock
        ending_stock = current_expected_stock
        
        processed_rows.append({
            "Date": m["date"].strftime("%Y-%m-%d %H:%M:%S") if isinstance(m["date"], datetime) else m["date"],
            "Movement Type": m["movement_type"],
            "Product SKU": m["product_sku"],
            "Product Name": m["product_name"],
            "Quantity Moved": m["quantity_moved"],
            "Identifier": m["identifier"],
            "Location": m["location"],
            "Expected Starting Stock": starting_stock,
            "Expected Ending Stock": ending_stock,
            "Reported Stock in System": last_reported_stock_per_location[loc_wh_id],
            "Correction by Stock Update": correction_for_row # CHANGED: Renamed column
        })

    # CHANGED: Updated fieldnames list for the new column name
    fieldnames = [
        "Date",
        "Movement Type",
        "Product SKU",
        "Product Name",
        "Quantity Moved",
        "Identifier",
        "Location",
        "Expected Starting Stock",
        "Expected Ending Stock",
        "Reported Stock in System",
        "Correction by Stock Update"
    ]
    
    with open(output_file, mode="w", newline="", encoding="utf-8") as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(processed_rows)
    
    print(f"CSV file generated: {output_file}")

def generate_leitzonen_report_csv(engine, shop_id, timeframe_months, output_file, use_cache=True):
    """
    DEPRECATED: Use leitzonen_report.report_generator.generate_leitzonen_report_csv instead.
    
    This function is kept for backward compatibility but should not be used in new code.
    The new version supports output directory parameters and better path management.
    
    Generates a CSV report showing average delivery duration by leitzone (postal code prefix)
    for shipments within a specified timeframe.
    Uses E10 as preferred event, but falls back to G11 when E10 is missing.
    Also generates a comparison report showing the impact of using G11 as proxy.
    
    Minimizes database load by fetching raw data and doing all analysis in Python.
    Supports caching to avoid repeated database queries during iteration.
    """
    # Create output directory
    output_dir = _get_output_dir('leitzonen')
    output_file_path = output_dir / Path(output_file).name
    
    # Check for cache
    cache_path = _get_cache_file_path(shop_id, timeframe_months, 'leitzonen')
    raw_data = None
    query_execution_time = None
    query_duration = None
    
    if use_cache and _should_use_cache(cache_path):
        # Load from cache
        try:
            metadata, raw_data = _load_cache(cache_path)
            query_execution_time = datetime.fromisoformat(metadata['query_execution_time'])
            query_duration = metadata['query_duration']
            print(f"Using cached data from: {metadata['query_execution_time']}")
        except Exception as e:
            print(f"Error loading cache: {e}")
            print("Fetching from database...")
            raw_data = None
    
    if raw_data is None:
        # Need to fetch from database - engine must be provided
        if engine is None:
            raise ValueError("Database engine is required when not using cache")
        
        # Fetch from database
        query_str = f"""
        SELECT 
            s.id AS shipment_id,
            s.tracking_codes AS tracking_code,
            a.zip,
            a.country_code,
            pe.event_key,
            pe.phase_key,
            pe.event_time
        FROM shipment s
        JOIN fulfillment f ON s.fulfillment_id = f.id
        JOIN address a ON f.shipping_address_id = a.id
        LEFT JOIN parcel_event pe ON s.id = pe.shipment_id
            AND pe.event_time >= CURRENT_DATE - INTERVAL '{timeframe_months} months'
            AND (pe.event_key = 'E10' OR pe.event_key = 'E11' OR pe.event_key = 'G11' OR pe.event_key = 'F10'
                 OR pe.phase_key = 'H' OR pe.event_key IN ('G30', 'G31', 'G32', 'G33'))
        WHERE 
            s.shop_id = :shop_id
            AND s.creation_date >= CURRENT_DATE - INTERVAL '{timeframe_months} months'
            AND a.country_code = 'DE'
        ORDER BY s.id, pe.event_time;
        """
        
        # Capture query execution time
        query_execution_time = datetime.now()
        
        with engine.connect() as conn:
            result = conn.execute(
                text(query_str),
                {
                    "shop_id": shop_id,
                }
            )
            rows = result.fetchall()
        
        query_completion_time = datetime.now()
        query_duration = (query_completion_time - query_execution_time).total_seconds()
        
        print(f"Query executed at: {query_execution_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Query completed in: {query_duration:.2f} seconds")
        
        # Convert rows to dictionaries
        raw_data = [dict(row._mapping) for row in rows]
        
        # Save to cache
        metadata = {
            'shop_id': shop_id,
            'timeframe_months': timeframe_months,
            'query_execution_time': query_execution_time.isoformat(),
            'query_duration': query_duration,
            'row_count': len(raw_data)
        }
        _save_cache(cache_path, raw_data, metadata)
    
    print("Processing data in Python...")
    
    # Group events by shipment in Python
    shipments = defaultdict(lambda: {
        'zip': None,
        'country_code': None,
        'tracking_code': None,
        'e10_events': [],
        'e11_events': [],
        'g11_events': [],
        'f10_events': [],
        'h_events': [],  # List of (event_key, event_time) tuples
        'g30_33_events': []  # List of (event_key, event_time) tuples for G30-G33
    })
    
    for row in raw_data:
        shipment_id = row["shipment_id"]
        if shipment_id not in shipments:
            shipments[shipment_id]['zip'] = row["zip"]
            shipments[shipment_id]['country_code'] = row["country_code"]
            # Handle tracking_code - it might be a list/array from the database
            tracking_code_raw = row.get("tracking_code")
            tracking_code = None
            if tracking_code_raw:
                if isinstance(tracking_code_raw, list):
                    # If it's a list, take the first non-empty one
                    for tc in tracking_code_raw:
                        if tc and str(tc).strip():
                            tracking_code = str(tc).strip()
                            break
                elif isinstance(tracking_code_raw, str) and tracking_code_raw.strip():
                    tracking_code = tracking_code_raw.strip()
                else:
                    # Try to convert to string if it's not None
                    try:
                        tc_str = str(tracking_code_raw).strip()
                        if tc_str and tc_str.lower() != 'none':
                            tracking_code = tc_str
                    except:
                        pass
            shipments[shipment_id]['tracking_code'] = tracking_code
        
        event_key = row.get("event_key")
        phase_key = row.get("phase_key")
        event_time = row.get("event_time")
        
        if not event_time:
            continue
        
        if event_key == 'E10':
            shipments[shipment_id]['e10_events'].append(event_time)
        elif event_key == 'E11':
            shipments[shipment_id]['e11_events'].append(event_time)
        elif event_key == 'G11':
            shipments[shipment_id]['g11_events'].append(event_time)
        elif event_key == 'F10':
            shipments[shipment_id]['f10_events'].append(event_time)
        elif event_key in ('G30', 'G31', 'G32', 'G33'):
            # Store G30-G33 events for delivery proxy
            shipments[shipment_id]['g30_33_events'].append((event_key, event_time))
        elif phase_key == 'H':
            # Store both event_key and event_time for H events
            h_event_key = event_key if event_key else 'H_UNKNOWN'
            shipments[shipment_id]['h_events'].append((h_event_key, event_time))
    
    # Process shipments in Python - calculate durations for both approaches
    leitzone_data_with_proxy = defaultdict(list)  # Using E10 + G11 proxy
    leitzone_data_e10_only = defaultdict(list)    # Using only E10
    leitzone_event_types = defaultdict(lambda: {'E10': 0, 'E11': 0, 'G11': 0, 'F10': 0})  # Track event types used
    leitzone_h_events = defaultdict(lambda: defaultdict(int))  # Track H event types per leitzone
    leitzone_delivery_events = defaultdict(lambda: defaultdict(int))  # Track delivery events (H or G proxy) per leitzone
    leitzone_h_tracking_codes = defaultdict(lambda: defaultdict(list))  # Track tracking codes per delivery event per leitzone
    overall_h_events = defaultdict(int)  # Track H event types overall (original)
    overall_delivery_events = defaultdict(int)  # Track delivery events overall (H or G proxy)
    overall_h_tracking_codes = defaultdict(list)  # Track tracking codes per delivery event overall
    delivery_proxy_usage = {'h20_23_with_g_proxy': 0, 'h20_23_without_g_proxy': 0, 'other_h_events': 0}  # Track proxy usage
    
    # Track filtering reasons
    filter_stats = {
        'total_shipments': len(shipments),
        'filtered_no_country_or_zip': 0,
        'filtered_no_h_event': 0,
        'filtered_no_start_event': 0,
        'filtered_invalid_duration': 0,
        'eligible_shipments': 0
    }
    
    def parse_datetime(dt_value):
        """Helper to parse datetime from various formats"""
        if isinstance(dt_value, datetime):
            return dt_value
        if isinstance(dt_value, str):
            try:
                return datetime.fromisoformat(dt_value.replace('Z', '+00:00'))
            except:
                return datetime.fromisoformat(dt_value)
        return dt_value
    
    def calculate_duration_hours(start_time, end_time):
        """Calculate duration in hours between two datetimes"""
        if not start_time or not end_time:
            return None
        start_dt = parse_datetime(start_time)
        end_dt = parse_datetime(end_time)
        if isinstance(start_dt, datetime) and isinstance(end_dt, datetime):
            duration_seconds = (end_dt - start_dt).total_seconds()
            return duration_seconds / 3600
        return None
    
    for shipment_id, shipment_data in shipments.items():
        zip_code = shipment_data['zip'] or ""
        leitzone = zip_code[:2] if len(zip_code) >= 2 else ""
        country_code = shipment_data['country_code']
        
        if not country_code or not leitzone:
            filter_stats['filtered_no_country_or_zip'] += 1
            continue
        
        key = (country_code, leitzone)
        
        # Get all start events (E10, E11, G11, F10) - we'll find the earliest
        e10_times = sorted(shipment_data['e10_events'], reverse=True) if shipment_data['e10_events'] else []
        e11_times = sorted(shipment_data['e11_events'], reverse=True) if shipment_data['e11_events'] else []
        g11_times = sorted(shipment_data['g11_events'], reverse=True) if shipment_data['g11_events'] else []
        f10_times = sorted(shipment_data['f10_events'], reverse=True) if shipment_data['f10_events'] else []
        h_events_list = shipment_data['h_events'] if shipment_data['h_events'] else []
        
        # Need at least one H event for end time
        if not h_events_list:
            filter_stats['filtered_no_h_event'] += 1
            continue
        
        # Sort H events by time and get the earliest one (used for end time)
        h_events_sorted = sorted(h_events_list, key=lambda x: x[1])
        h_event_key_used, h_event_time = h_events_sorted[0]  # First H event (earliest)
        
        # Check if H event is H20-H23, and if so, look for G30-G33 proxy
        delivery_event_key = h_event_key_used
        end_time = h_event_time
        delivery_proxy_used = False
        
        if h_event_key_used in ('H20', 'H21', 'H22', 'H23'):
            # Look for G30-G33 events as proxy
            g30_33_events = shipment_data.get('g30_33_events', [])
            if g30_33_events:
                # Sort G30-G33 events by time and get the earliest one
                g_events_sorted = sorted(g30_33_events, key=lambda x: x[1])
                g_event_key, g_event_time = g_events_sorted[0]
                # Use G event as proxy if it's earlier or equal to H event time
                if g_event_time <= h_event_time:
                    delivery_event_key = g_event_key
                    end_time = g_event_time
                    delivery_proxy_used = True
                    delivery_proxy_usage['h20_23_with_g_proxy'] += 1
                else:
                    delivery_proxy_usage['h20_23_without_g_proxy'] += 1
            else:
                delivery_proxy_usage['h20_23_without_g_proxy'] += 1
        else:
            delivery_proxy_usage['other_h_events'] += 1
        
        # Process WITH proxy: Find earliest event among E10, E11, G11, F10
        # Use F10 only if it's the earliest; otherwise use the earliest of E10/E11/G11
        start_time_with_proxy = None
        start_event_type = None
        
        # Collect all start events with their types and times
        start_event_candidates = []
        
        # Get the earliest (first) event from each type
        if e10_times:
            earliest_e10 = sorted(e10_times)[0] if e10_times else None
            if earliest_e10:
                start_event_candidates.append(('E10', earliest_e10))
        
        if e11_times:
            earliest_e11 = sorted(e11_times)[0] if e11_times else None
            if earliest_e11:
                start_event_candidates.append(('E11', earliest_e11))
        
        if g11_times:
            earliest_g11 = sorted(g11_times)[0] if g11_times else None
            if earliest_g11:
                start_event_candidates.append(('G11', earliest_g11))
        
        if f10_times:
            earliest_f10 = sorted(f10_times)[0] if f10_times else None
            if earliest_f10:
                start_event_candidates.append(('F10', earliest_f10))
        
        if start_event_candidates:
            # Sort by time to find the earliest
            start_event_candidates_sorted = sorted(start_event_candidates, key=lambda x: x[1])
            earliest_event_type, earliest_event_time = start_event_candidates_sorted[0]
            
            # Use F10 only if it's the earliest; otherwise use the earliest of E10/E11/G11
            if earliest_event_type == 'F10':
                # F10 is earliest, use it
                start_time_with_proxy = earliest_event_time
                start_event_type = 'F10'
            else:
                # F10 is not earliest, find earliest among E10/E11/G11 (ignore F10)
                non_f10_candidates = [c for c in start_event_candidates_sorted if c[0] != 'F10']
                if non_f10_candidates:
                    start_event_type, start_time_with_proxy = non_f10_candidates[0]
                else:
                    # Only F10 exists, use it
                    start_time_with_proxy = earliest_event_time
                    start_event_type = 'F10'
        else:
            start_time_with_proxy = None
            start_event_type = None
        
        if not start_time_with_proxy:
            filter_stats['filtered_no_start_event'] += 1
            continue
        
        duration_hours = calculate_duration_hours(start_time_with_proxy, end_time)
        if duration_hours is None:
            filter_stats['filtered_invalid_duration'] += 1
            continue
        
        # Shipment is eligible - track delivery event type (H or G proxy)
        filter_stats['eligible_shipments'] += 1
        leitzone_data_with_proxy[key].append(duration_hours)
        leitzone_event_types[key][start_event_type] += 1
        
        # Track delivery event type used (original H or G proxy) and tracking code
        tracking_code = shipment_data.get('tracking_code')
        
        # Track original H event
        leitzone_h_events[key][h_event_key_used] += 1
        overall_h_events[h_event_key_used] += 1
        
        # Track actual delivery event used (H or G proxy)
        leitzone_delivery_events[key][delivery_event_key] += 1
        overall_delivery_events[delivery_event_key] += 1
        
        # Store tracking code if available (ensure it's a non-empty string)
        # Use delivery_event_key (the one actually used) for tracking codes
        if tracking_code and str(tracking_code).strip():
            tracking_code_str = str(tracking_code).strip()
            leitzone_h_tracking_codes[key][delivery_event_key].append(tracking_code_str)
            overall_h_tracking_codes[delivery_event_key].append(tracking_code_str)
        
        # Process E10 ONLY (for comparison)
        if e10_times:
            start_time_e10_only = e10_times[0]
            duration_hours_e10 = calculate_duration_hours(start_time_e10_only, end_time)
            if duration_hours_e10 is not None:
                leitzone_data_e10_only[key].append(duration_hours_e10)
    
    # Calculate averages and prepare report data (using proxy approach for CSV)
    report_data = []
    for (country_code, leitzone), durations in leitzone_data_with_proxy.items():
        total_shipments = len(durations)
        avg_duration_hours = sum(durations) / total_shipments if total_shipments > 0 else 0
        
        event_counts = leitzone_event_types.get((country_code, leitzone), {'E10': 0, 'E11': 0, 'G11': 0})
        
        report_data.append({
            "country_code": country_code,
            "leitzone": leitzone,
            "total_shipments": total_shipments,
            "avg_duration_hours": round(avg_duration_hours, 2),
            "e10_count": event_counts['E10'],
            "e11_count": event_counts.get('E11', 0),
            "g11_count": event_counts['G11']
        })
    
    # Sort by average duration (ascending - fastest first)
    report_data.sort(key=lambda x: x["avg_duration_hours"])
    
    # Define CSV fieldnames
    fieldnames = [
        "country_code",
        "leitzone",
        "total_shipments",
        "avg_duration_hours",
        "e10_count",
        "e11_count",
        "g11_count"
    ]
    
    # Write to CSV with query execution time as metadata
    with open(output_file_path, mode="w", newline="", encoding="utf-8") as csv_file:
        # Write metadata comment
        csv_file.write(f"# Query executed at: {query_execution_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        csv_file.write(f"# Query duration: {query_duration:.2f} seconds\n")
        csv_file.write(f"# Shop ID: {shop_id}\n")
        csv_file.write(f"# Timeframe: {timeframe_months} months\n")
        csv_file.write(f"# Total records: {len(report_data)}\n")
        csv_file.write(f"# Note: Uses E10 as preferred event, G11 as proxy when E10 is missing\n")
        
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(report_data)
    
    print(f"CSV file generated: {output_file_path}")
    print(f"Report contains {len(report_data)} leitzone entries")
    
    # Generate comparison report (TXT file)
    output_txt_file = output_file_path.with_suffix('').with_name(
        output_file_path.stem + '_g11_proxy_impact.txt'
    )
    _generate_g11_proxy_comparison_report(
        leitzone_data_with_proxy,
        leitzone_data_e10_only,
        leitzone_event_types,
        leitzone_h_events,
        leitzone_delivery_events,
        leitzone_h_tracking_codes,
        overall_h_events,
        overall_delivery_events,
        overall_h_tracking_codes,
        delivery_proxy_usage,
        filter_stats,
        output_txt_file,
        shop_id,
        timeframe_months,
        query_execution_time
    )
    
    print(f"Comparison report generated: {output_txt_file}")


def _generate_g11_proxy_comparison_report(
    leitzone_data_with_proxy,
    leitzone_data_e10_only,
    leitzone_event_types,
    leitzone_h_events,
    leitzone_delivery_events,
    leitzone_h_tracking_codes,
    overall_h_events,
    overall_delivery_events,
    overall_h_tracking_codes,
    delivery_proxy_usage,
    filter_stats,
    output_file,
    shop_id,
    timeframe_months,
    query_execution_time
):
    """
    Generates a text report comparing the impact of using G11 as proxy vs E10 only.
    """
    with open(output_file, mode="w", encoding="utf-8") as txt_file:
        txt_file.write("=" * 80 + "\n")
        txt_file.write("G11 PROXY IMPACT ANALYSIS REPORT\n")
        txt_file.write("=" * 80 + "\n\n")
        
        txt_file.write(f"Query executed at: {query_execution_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        txt_file.write(f"Shop ID: {shop_id}\n")
        txt_file.write(f"Timeframe: {timeframe_months} months\n")
        txt_file.write(f"\nNote: E10 is preferred, G11 is used as proxy when E10 is missing.\n")
        txt_file.write(f"      For delivery events: H20-H23 use G30-G33 as proxy when available.\n\n")
        
        # Filtering statistics section
        txt_file.write("=" * 80 + "\n")
        txt_file.write("SHIPMENT FILTERING STATISTICS\n")
        txt_file.write("=" * 80 + "\n\n")
        
        total_shipments = filter_stats['total_shipments']
        eligible = filter_stats['eligible_shipments']
        filtered_out = total_shipments - eligible
        
        txt_file.write(f"Total shipments processed: {total_shipments:,}\n")
        txt_file.write(f"Eligible shipments:         {eligible:,}\n")
        txt_file.write(f"Filtered out shipments:     {filtered_out:,}\n")
        
        if total_shipments > 0:
            eligible_pct = (eligible / total_shipments) * 100
            filtered_pct = (filtered_out / total_shipments) * 100
            txt_file.write(f"Eligible percentage:        {eligible_pct:.2f}%\n")
            txt_file.write(f"Filtered percentage:        {filtered_pct:.2f}%\n")
        
        txt_file.write("\nFiltering reasons:\n")
        txt_file.write("-" * 80 + "\n")
        
        reasons = [
            ('filtered_no_country_or_zip', 'Missing country code or invalid zip code'),
            ('filtered_no_h_event', 'No H phase event (delivery completion)'),
            ('filtered_no_start_event', 'No E10 or G11 start event'),
            ('filtered_invalid_duration', 'Invalid duration calculation')
        ]
        
        for reason_key, reason_desc in reasons:
            count = filter_stats.get(reason_key, 0)
            if total_shipments > 0:
                pct = (count / total_shipments) * 100
                txt_file.write(f"  {reason_desc:50s}: {count:8,} ({pct:6.2f}%)\n")
            else:
                txt_file.write(f"  {reason_desc:50s}: {count:8,}\n")
        
        txt_file.write("\n")
        
        # Delivery proxy statistics (H20-H23 with G30-G33 proxy)
        txt_file.write("=" * 80 + "\n")
        txt_file.write("DELIVERY PROXY STATISTICS (H20-H23 → G30-G33)\n")
        txt_file.write("=" * 80 + "\n\n")
        
        total_h20_23 = delivery_proxy_usage['h20_23_with_g_proxy'] + delivery_proxy_usage['h20_23_without_g_proxy']
        total_eligible = delivery_proxy_usage['h20_23_with_g_proxy'] + delivery_proxy_usage['h20_23_without_g_proxy'] + delivery_proxy_usage['other_h_events']
        
        txt_file.write(f"Total H20-H23 events: {total_h20_23:,}\n")
        txt_file.write(f"  - With G30-G33 proxy: {delivery_proxy_usage['h20_23_with_g_proxy']:,}\n")
        txt_file.write(f"  - Without G30-G33 proxy: {delivery_proxy_usage['h20_23_without_g_proxy']:,}\n")
        txt_file.write(f"Other H events (not H20-H23): {delivery_proxy_usage['other_h_events']:,}\n")
        
        if total_h20_23 > 0:
            proxy_pct = (delivery_proxy_usage['h20_23_with_g_proxy'] / total_h20_23) * 100
            txt_file.write(f"\nProxy usage rate for H20-H23: {proxy_pct:.2f}%\n")
        
        txt_file.write("\n")
        
        # Leitzones with >1% G11 proxy usage
        txt_file.write("=" * 80 + "\n")
        txt_file.write("LEITZONES WITH >1% G11 PROXY USAGE\n")
        txt_file.write("=" * 80 + "\n\n")
        
        high_g11_leitzones = []
        for (country_code, leitzone), event_counts in leitzone_event_types.items():
            total = event_counts['E10'] + event_counts['G11']
            if total > 0:
                g11_pct = (event_counts['G11'] / total) * 100
                if g11_pct > 1.0:
                    high_g11_leitzones.append({
                        'country_code': country_code,
                        'leitzone': leitzone,
                        'g11_count': event_counts['G11'],
                        'e10_count': event_counts['E10'],
                        'total': total,
                        'g11_percentage': g11_pct
                    })
        
        # Sort by G11 percentage (descending)
        high_g11_leitzones.sort(key=lambda x: x['g11_percentage'], reverse=True)
        
        if high_g11_leitzones:
            txt_file.write(f"{'Leitzone':<12} {'Country':<10} {'G11 Count':<12} {'E10 Count':<12} {'Total':<12} {'G11 %':<10}\n")
            txt_file.write("-" * 80 + "\n")
            for item in high_g11_leitzones:
                txt_file.write(
                    f"{item['leitzone']:<12} {item['country_code']:<10} "
                    f"{item['g11_count']:<12,} {item['e10_count']:<12,} "
                    f"{item['total']:<12,} {item['g11_percentage']:>9.2f}%\n"
                )
        else:
            txt_file.write("No leitzones found with >1% G11 proxy usage.\n")
        
        txt_file.write("\n")
        
        # Overall statistics
        all_leitzones = set(leitzone_data_with_proxy.keys()) | set(leitzone_data_e10_only.keys())
        
        total_shipments_with_proxy = sum(len(durations) for durations in leitzone_data_with_proxy.values())
        total_shipments_e10_only = sum(len(durations) for durations in leitzone_data_e10_only.values())
        
        txt_file.write("=" * 80 + "\n")
        txt_file.write("OVERALL STATISTICS\n")
        txt_file.write("=" * 80 + "\n\n")
        txt_file.write(f"Total eligible shipments WITH G11 proxy: {total_shipments_with_proxy:,}\n")
        txt_file.write(f"Total eligible shipments E10 ONLY:      {total_shipments_e10_only:,}\n")
        txt_file.write(f"Additional shipments (G11 proxy impact): {total_shipments_with_proxy - total_shipments_e10_only:,}\n")
        if total_shipments_e10_only > 0:
            increase_percentage = ((total_shipments_with_proxy - total_shipments_e10_only) / total_shipments_e10_only) * 100
            txt_file.write(f"Increase percentage: {increase_percentage:.2f}%\n")
        txt_file.write("\n")
        
        # Overall delivery event statistics (includes G30-G33 proxy)
        txt_file.write("=" * 80 + "\n")
        txt_file.write("OVERALL DELIVERY EVENT STATISTICS\n")
        txt_file.write("=" * 80 + "\n\n")
        txt_file.write("Note: Shows actual delivery events used (H events, or G30-G33 proxy for H20-H23)\n\n")
        
        if overall_delivery_events:
            total_delivery_events = sum(overall_delivery_events.values())
            txt_file.write(f"Total delivery events used: {total_delivery_events:,}\n\n")
            txt_file.write(f"{'Delivery Event':<20} {'Count':<15} {'Percentage':<15} {'Example Tracking Codes':<40}\n")
            txt_file.write("-" * 80 + "\n")
            
            # Sort by count (descending)
            sorted_delivery_events = sorted(overall_delivery_events.items(), key=lambda x: x[1], reverse=True)
            for delivery_event_key, count in sorted_delivery_events:
                percentage = (count / total_delivery_events) * 100 if total_delivery_events > 0 else 0
                
                # Get 3 random tracking code examples
                tracking_codes = overall_h_tracking_codes.get(delivery_event_key, [])
                # Filter out None, empty strings, and non-string values
                valid_tracking_codes = [tc for tc in tracking_codes if tc and str(tc).strip() and str(tc).strip().lower() != 'none']
                if valid_tracking_codes:
                    # Get up to 3 random examples
                    examples = random.sample(valid_tracking_codes, min(3, len(valid_tracking_codes)))
                    # Ensure all examples are strings
                    examples = [str(ex).strip() for ex in examples]
                    examples_str = ", ".join(examples)
                else:
                    examples_str = "N/A"
                
                # Mark G30-G33 events as proxy
                event_label = delivery_event_key
                if delivery_event_key in ('G30', 'G31', 'G32', 'G33'):
                    event_label = f"{delivery_event_key} (proxy)"
                
                txt_file.write(f"{event_label:<20} {count:<15,} {percentage:>14.2f}% {examples_str:<40}\n")
        else:
            txt_file.write("No delivery event data available.\n")
        
        txt_file.write("\n")
        
        # Original H event statistics (for reference)
        txt_file.write("=" * 80 + "\n")
        txt_file.write("ORIGINAL H EVENT STATISTICS (Before Proxy)\n")
        txt_file.write("=" * 80 + "\n\n")
        
        if overall_h_events:
            total_h_events = sum(overall_h_events.values())
            txt_file.write(f"Total original H events: {total_h_events:,}\n\n")
            txt_file.write(f"{'H Event Key':<20} {'Count':<15} {'Percentage':<15}\n")
            txt_file.write("-" * 80 + "\n")
            
            # Sort by count (descending)
            sorted_h_events = sorted(overall_h_events.items(), key=lambda x: x[1], reverse=True)
            for h_event_key, count in sorted_h_events:
                percentage = (count / total_h_events) * 100 if total_h_events > 0 else 0
                txt_file.write(f"{h_event_key:<20} {count:<15,} {percentage:>14.2f}%\n")
        else:
            txt_file.write("No H event data available.\n")
        
        txt_file.write("\n")
        
        # Per-leitzone analysis
        txt_file.write("=" * 80 + "\n")
        txt_file.write("PER-LEITZONE ANALYSIS\n")
        txt_file.write("=" * 80 + "\n\n")
        
        # Sort leitzones for consistent output
        sorted_leitzones = sorted(all_leitzones, key=lambda x: (x[0], x[1]))
        
        for country_code, leitzone in sorted_leitzones:
            durations_with_proxy = leitzone_data_with_proxy.get((country_code, leitzone), [])
            durations_e10_only = leitzone_data_e10_only.get((country_code, leitzone), [])
            event_counts = leitzone_event_types.get((country_code, leitzone), {'E10': 0, 'G11': 0})
            
            shipments_with_proxy = len(durations_with_proxy)
            shipments_e10_only = len(durations_e10_only)
            
            if shipments_with_proxy == 0 and shipments_e10_only == 0:
                continue
            
            txt_file.write(f"Leitzone: {leitzone} ({country_code})\n")
            txt_file.write("-" * 80 + "\n")
            
            # Shipment counts
            txt_file.write(f"  Shipments WITH G11 proxy: {shipments_with_proxy:,}\n")
            txt_file.write(f"  Shipments E10 ONLY:       {shipments_e10_only:,}\n")
            additional = shipments_with_proxy - shipments_e10_only
            txt_file.write(f"  Additional shipments:     {additional:,}\n")
            
            if shipments_e10_only > 0:
                increase_pct = (additional / shipments_e10_only) * 100
                txt_file.write(f"  Increase:                 {increase_pct:.2f}%\n")
            
            # Event type breakdown
            txt_file.write(f"\n  Event type breakdown:\n")
            txt_file.write(f"    E10 events used: {event_counts['E10']:,}\n")
            txt_file.write(f"    G11 events used: {event_counts['G11']:,}\n")
            
            # Delivery event breakdown for this leitzone (includes G30-G33 proxy)
            delivery_events_for_leitzone = leitzone_delivery_events.get((country_code, leitzone), {})
            if delivery_events_for_leitzone:
                total_delivery_for_leitzone = sum(delivery_events_for_leitzone.values())
                txt_file.write(f"\n  Delivery event breakdown (includes G30-G33 proxy for H20-H23):\n")
                # Sort by count (descending)
                sorted_delivery_events = sorted(delivery_events_for_leitzone.items(), key=lambda x: x[1], reverse=True)
                for delivery_event_key, count in sorted_delivery_events:
                    percentage = (count / total_delivery_for_leitzone) * 100 if total_delivery_for_leitzone > 0 else 0
                    
                    # Get 3 random tracking code examples for this leitzone and delivery event
                    tracking_codes = leitzone_h_tracking_codes.get((country_code, leitzone), {}).get(delivery_event_key, [])
                    # Filter out None, empty strings, and non-string values
                    valid_tracking_codes = [tc for tc in tracking_codes if tc and str(tc).strip() and str(tc).strip().lower() != 'none']
                    
                    # Mark G30-G33 events as proxy
                    event_label = delivery_event_key
                    if delivery_event_key in ('G30', 'G31', 'G32', 'G33'):
                        event_label = f"{delivery_event_key} (proxy)"
                    
                    if valid_tracking_codes:
                        examples = random.sample(valid_tracking_codes, min(3, len(valid_tracking_codes)))
                        # Ensure all examples are strings
                        examples = [str(ex).strip() for ex in examples]
                        examples_str = ", ".join(examples)
                        txt_file.write(f"    {event_label}: {count:,} ({percentage:.2f}%) - Examples: {examples_str}\n")
                    else:
                        txt_file.write(f"    {event_label}: {count:,} ({percentage:.2f}%)\n")
            
            # Average delivery times
            if shipments_with_proxy > 0:
                avg_with_proxy = sum(durations_with_proxy) / shipments_with_proxy
                txt_file.write(f"\n  Average delivery time WITH G11 proxy: {avg_with_proxy:.2f} hours ({avg_with_proxy/24:.2f} days)\n")
            
            if shipments_e10_only > 0:
                avg_e10_only = sum(durations_e10_only) / shipments_e10_only
                txt_file.write(f"  Average delivery time E10 ONLY:      {avg_e10_only:.2f} hours ({avg_e10_only/24:.2f} days)\n")
                
                if shipments_with_proxy > 0:
                    time_shift = avg_with_proxy - avg_e10_only
                    time_shift_pct = (time_shift / avg_e10_only) * 100 if avg_e10_only > 0 else 0
                    txt_file.write(f"  Time shift:                          {time_shift:+.2f} hours ({time_shift/24:+.2f} days)\n")
                    txt_file.write(f"  Time shift percentage:               {time_shift_pct:+.2f}%\n")
            
            txt_file.write("\n")
        
        # Special focus on leitzone 94
        leitzone_94_key = None
        for key in all_leitzones:
            if key[1] == '94':
                leitzone_94_key = key
                break
        
        if leitzone_94_key:
            country_code, leitzone = leitzone_94_key
            durations_with_proxy = leitzone_data_with_proxy.get(leitzone_94_key, [])
            durations_e10_only = leitzone_data_e10_only.get(leitzone_94_key, [])
            event_counts = leitzone_event_types.get(leitzone_94_key, {'E10': 0, 'G11': 0})
            
            txt_file.write("=" * 80 + "\n")
            txt_file.write("SPECIAL ANALYSIS: LEITZONE 94\n")
            txt_file.write("=" * 80 + "\n\n")
            
            shipments_with_proxy = len(durations_with_proxy)
            shipments_e10_only = len(durations_e10_only)
            
            txt_file.write(f"Shipments WITH G11 proxy: {shipments_with_proxy:,}\n")
            txt_file.write(f"Shipments E10 ONLY:       {shipments_e10_only:,}\n")
            additional = shipments_with_proxy - shipments_e10_only
            txt_file.write(f"Additional shipments:     {additional:,}\n")
            
            if shipments_e10_only > 0:
                increase_pct = (additional / shipments_e10_only) * 100
                txt_file.write(f"Increase:                 {increase_pct:.2f}%\n")
            
            txt_file.write(f"\nEvent type breakdown:\n")
            txt_file.write(f"  E10 events used: {event_counts['E10']:,}\n")
            txt_file.write(f"  G11 events used: {event_counts['G11']:,}\n")
            
            # Delivery event breakdown for leitzone 94 (includes G30-G33 proxy)
            delivery_events_for_leitzone_94 = leitzone_delivery_events.get(leitzone_94_key, {})
            if delivery_events_for_leitzone_94:
                total_delivery_for_leitzone_94 = sum(delivery_events_for_leitzone_94.values())
                txt_file.write(f"\nDelivery event breakdown (includes G30-G33 proxy for H20-H23):\n")
                # Sort by count (descending)
                sorted_delivery_events = sorted(delivery_events_for_leitzone_94.items(), key=lambda x: x[1], reverse=True)
                for delivery_event_key, count in sorted_delivery_events:
                    percentage = (count / total_delivery_for_leitzone_94) * 100 if total_delivery_for_leitzone_94 > 0 else 0
                    
                    # Get 3 random tracking code examples for leitzone 94 and delivery event
                    tracking_codes = leitzone_h_tracking_codes.get(leitzone_94_key, {}).get(delivery_event_key, [])
                    # Filter out None, empty strings, and non-string values
                    valid_tracking_codes = [tc for tc in tracking_codes if tc and str(tc).strip() and str(tc).strip().lower() != 'none']
                    
                    # Mark G30-G33 events as proxy
                    event_label = delivery_event_key
                    if delivery_event_key in ('G30', 'G31', 'G32', 'G33'):
                        event_label = f"{delivery_event_key} (proxy)"
                    
                    if valid_tracking_codes:
                        examples = random.sample(valid_tracking_codes, min(3, len(valid_tracking_codes)))
                        # Ensure all examples are strings
                        examples = [str(ex).strip() for ex in examples]
                        examples_str = ", ".join(examples)
                        txt_file.write(f"  {event_label}: {count:,} ({percentage:.2f}%) - Examples: {examples_str}\n")
                    else:
                        txt_file.write(f"  {event_label}: {count:,} ({percentage:.2f}%)\n")
            
            if shipments_with_proxy > 0:
                avg_with_proxy = sum(durations_with_proxy) / shipments_with_proxy
                txt_file.write(f"\nAverage delivery time WITH G11 proxy: {avg_with_proxy:.2f} hours ({avg_with_proxy/24:.2f} days)\n")
            
            if shipments_e10_only > 0:
                avg_e10_only = sum(durations_e10_only) / shipments_e10_only
                txt_file.write(f"Average delivery time E10 ONLY:      {avg_e10_only:.2f} hours ({avg_e10_only/24:.2f} days)\n")
                
                if shipments_with_proxy > 0:
                    time_shift = avg_with_proxy - avg_e10_only
                    time_shift_pct = (time_shift / avg_e10_only) * 100 if avg_e10_only > 0 else 0
                    txt_file.write(f"Time shift:                          {time_shift:+.2f} hours ({time_shift/24:+.2f} days)\n")
                    txt_file.write(f"Time shift percentage:               {time_shift_pct:+.2f}%\n")
            
            txt_file.write("\n")
        
        txt_file.write("=" * 80 + "\n")
        txt_file.write("END OF REPORT\n")
        txt_file.write("=" * 80 + "\n")

def generate_parcel_event_report_csv(engine, shop_id, timeframe_months, leitzone, output_file, output_dir=None):
    """
    Generates a CSV report showing all parcel_event entries for a specific leitzone.
    
    This function queries all parcel events for shipments to a specific leitzone
    (2-digit postal code prefix) within a specified timeframe. The report includes
    all parcel event columns plus joined zip code and country information.
    
    Args:
        engine: SQLAlchemy database engine
        shop_id: UUID of the shop
        timeframe_months: Number of months to look back from current date
        leitzone: 2-digit leitzone (postal code prefix, e.g., "10", "20", "94")
        output_file: Output file name or path (filename will be used if output_dir provided)
        output_dir: Optional output directory. If provided, output_file is placed here.
                    If None, uses output_file's parent directory.
    
    Returns:
        None (writes CSV file to disk)
    
    Example:
        >>> generate_parcel_event_report_csv(
        ...     engine=engine,
        ...     shop_id="shop-123",
        ...     timeframe_months=6,
        ...     leitzone="94",
        ...     output_file="parcel_events.csv",
        ...     output_dir=Path("output/shop-123/run-1")
        ... )
    """
    query_str = f"""
    SELECT 
        pe.*,
        a.zip AS zip_code,
        a.country_code,
        SUBSTRING(a.zip, 1, 2) AS leitzone
    FROM parcel_event pe
    JOIN shipment s ON pe.shipment_id = s.id
    JOIN fulfillment f ON s.fulfillment_id = f.id
    JOIN address a ON f.shipping_address_id = a.id
    WHERE 
        s.shop_id = :shop_id
        AND s.creation_date >= CURRENT_DATE - INTERVAL '{timeframe_months} months'
        AND a.country_code = 'DE'
        AND SUBSTRING(a.zip, 1, 2) = :leitzone
        AND pe.event_time >= CURRENT_DATE - INTERVAL '{timeframe_months} months'
    ORDER BY pe.event_time, pe.shipment_id, pe.id;
    """
    
    rows_data, metadata = execute_cached_query(
        engine=engine,
        query=query_str,
        params={
            "shop_id": shop_id,
            "leitzone": leitzone,
        },
        shop_id=shop_id,
        query_name=f"parcel_events_leitzone_{leitzone}",
        use_cache=True
    )
    
    query_execution_time = datetime.fromisoformat(metadata['query_execution_time'])
    query_duration = metadata['query_duration']
    
    # Convert rows to dictionaries, handling all columns dynamically
    report_data = []
    if rows_data:
        # Get column names from the first row
        first_row = rows_data[0]
        fieldnames = list(first_row.keys())
        
        for row_dict in rows_data:
            # Format datetime objects
            formatted_row = {}
            for key, value in row_dict.items():
                if isinstance(value, str):
                    # Try to parse datetime strings
                    try:
                        dt = datetime.fromisoformat(value.replace('Z', '+00:00'))
                        formatted_row[key] = dt.strftime("%Y-%m-%d %H:%M:%S")
                    except (ValueError, AttributeError):
                        formatted_row[key] = value
                elif isinstance(value, datetime):
                    formatted_row[key] = value.strftime("%Y-%m-%d %H:%M:%S")
                else:
                    formatted_row[key] = value
            report_data.append(formatted_row)
    else:
        # If no rows, use default fieldnames
        fieldnames = [
            "id",
            "shipment_id",
            "event_key",
            "phase_key",
            "event_time",
            "zip_code",
            "country_code",
            "leitzone"
        ]
    
    # Determine output directory and file path
    if output_dir is None:
        output_dir = Path(output_file).parent
    else:
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
    
    output_path = output_dir / Path(output_file).name
    
    # Write to CSV with query execution time as metadata
    with open(output_path, mode="w", newline="", encoding="utf-8") as csv_file:
        # Write metadata comment
        csv_file.write(f"# Query executed at: {query_execution_time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        csv_file.write(f"# Query duration: {query_duration:.2f} seconds\n")
        csv_file.write(f"# Shop ID: {shop_id}\n")
        csv_file.write(f"# Timeframe: {timeframe_months} months\n")
        csv_file.write(f"# Leitzone: {leitzone}\n")
        csv_file.write(f"# Total records: {len(report_data)}\n")
        
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(report_data)
    
    print(f"CSV file generated: {output_path}")
    print(f"Report contains {len(report_data)} parcel event entries for leitzone {leitzone}")