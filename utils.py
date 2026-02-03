"""
Utility functions for path management and output organization.

This module provides utilities for managing output directories and cache file paths
in a structured way that supports multiple shops and runs.
"""
from pathlib import Path
from datetime import datetime
from typing import Optional, Any, Dict, Tuple, List, TYPE_CHECKING
import json
import hashlib
from sqlalchemy import text

if TYPE_CHECKING:
    from sqlalchemy.engine import Engine


def get_output_dir_for_run(shop_id: str, run_id: Optional[str] = None) -> Path:
    """
    Get the output directory for a specific shop and run.
    
    Creates a structured output directory path: output/{shop_id}/{run_id}/
    If no run_id is provided, a timestamp-based run_id is automatically generated.
    The directory is created if it doesn't exist.
    
    Args:
        shop_id: The shop ID (UUID string)
        run_id: Optional run ID for organizing outputs. If None, generates
                a timestamp-based ID in format YYYYMMDD_HHMMSS.
    
    Returns:
        Path object pointing to the output directory (created if needed).
    
    Example:
        >>> output_dir = get_output_dir_for_run("shop-123", "run-1")
        >>> # Returns: Path('output/shop-123/run-1')
        >>> 
        >>> output_dir = get_output_dir_for_run("shop-123")
        >>> # Returns: Path('output/shop-123/20241223_143022')  # timestamp-based
    """
    if run_id is None:
        run_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    output_dir = Path('output') / shop_id / run_id
    output_dir.mkdir(parents=True, exist_ok=True)
    return output_dir


def get_cache_file_path(shop_id: str, timeframe_months: int, script_name: str = 'leitzonen') -> Path:
    """
    Generate cache file path based on script name, shop_id, and timeframe.
    
    Creates a structured cache file path: cache/{shop_id}/{script_name}_shop_{shop_id}_months_{timeframe}.json
    The cache directory is created if it doesn't exist.
    
    Args:
        shop_id: The shop ID (UUID string)
        timeframe_months: Number of months for the timeframe (used in filename)
        script_name: Name of the script generating the cache (default: 'leitzonen')
                    Used to differentiate cache files from different scripts.
    
    Returns:
        Path object pointing to the cache file (directory created if needed).
    
    Example:
        >>> cache_path = get_cache_file_path("shop-123", 6, "leitzonen")
        >>> # Returns: Path('cache/shop-123/leitzonen_shop_shop-123_months_6.json')
    """
    cache_dir = Path('cache') / shop_id
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_filename = f"{script_name}_shop_{shop_id}_months_{timeframe_months}.json"
    return cache_dir / cache_filename


def _generate_query_cache_key(query: str, params: Dict[str, Any]) -> str:
    """
    Generate a unique cache key for a database query.
    
    Args:
        query: SQL query string
        params: Query parameters dictionary
    
    Returns:
        SHA256 hash of the query and parameters as a hex string
    """
    # Normalize query by removing extra whitespace
    normalized_query = ' '.join(query.split())
    # Create a deterministic string representation of params
    params_str = json.dumps(params, sort_keys=True, default=str)
    # Generate hash
    cache_key = hashlib.sha256(f"{normalized_query}|{params_str}".encode()).hexdigest()
    return cache_key


def get_query_cache_path(shop_id: str, cache_key: str, query_name: str = 'query') -> Path:
    """
    Generate cache file path for a database query.
    
    Args:
        shop_id: The shop ID (UUID string)
        cache_key: Unique cache key for the query (hash)
        query_name: Descriptive name for the query (used in filename)
    
    Returns:
        Path object pointing to the cache file (directory created if needed).
    """
    cache_dir = Path('cache') / shop_id / 'queries'
    cache_dir.mkdir(parents=True, exist_ok=True)
    cache_filename = f"{query_name}_{cache_key[:16]}.json"
    return cache_dir / cache_filename


def check_cache_exists(shop_id: str) -> bool:
    """
    Check if any cache files exist for a given shop.
    
    Args:
        shop_id: The shop ID (UUID string)
    
    Returns:
        True if any cache files exist, False otherwise
    """
    cache_dir = Path('cache') / shop_id
    if not cache_dir.exists():
        return False
    
    # Check for query caches
    queries_dir = cache_dir / 'queries'
    if queries_dir.exists():
        cache_files = list(queries_dir.glob('*.json'))
        if cache_files:
            return True
    
    # Check for legacy cache files (in shop_id root)
    legacy_cache_files = list(cache_dir.glob('*.json'))
    if legacy_cache_files:
        return True
    
    return False


def prompt_cache_regeneration(shop_id: str) -> bool:
    """
    Prompt user whether to regenerate cache.
    
    Args:
        shop_id: The shop ID to check cache for
    
    Returns:
        True if user wants to use cache (don't regenerate), False if they want to regenerate
    """
    if not check_cache_exists(shop_id):
        return True  # No cache exists, so we'll create it
    
    print("\n" + "=" * 80)
    print("CACHE DETECTED")
    print("=" * 80)
    print(f"Cache files found for shop: {shop_id}")
    print("\nOptions:")
    print("  [y] Use existing cache (faster, uses cached data)")
    print("  [n] Regenerate cache (slower, fetches fresh data from database)")
    
    while True:
        response = input("\nUse existing cache? (y/n, default: y): ").strip().lower()
        
        if not response:
            return True  # Default to using cache
        
        if response in ('y', 'yes'):
            return True
        elif response in ('n', 'no'):
            return False
        else:
            print("  Error: Please enter 'y' or 'n'")


def save_query_cache(cache_path: Path, data: List[Dict[str, Any]], metadata: Dict[str, Any]) -> None:
    """
    Save query results to cache file.
    
    Args:
        cache_path: Path to the cache file
        data: Query results as list of dictionaries
        metadata: Metadata about the query (execution time, duration, etc.)
    """
    cache_data = {
        'metadata': metadata,
        'data': data
    }
    with open(cache_path, 'w', encoding='utf-8') as f:
        json.dump(cache_data, f, default=str, indent=2)
    print(f"Cache saved to: {cache_path}")


def load_query_cache(cache_path: Path) -> Tuple[Dict[str, Any], List[Dict[str, Any]]]:
    """
    Load query results from cache file.
    
    Args:
        cache_path: Path to the cache file
    
    Returns:
        Tuple of (metadata, data)
    """
    with open(cache_path, 'r', encoding='utf-8') as f:
        cache_data = json.load(f)
    print(f"Cache loaded from: {cache_path}")
    return cache_data['metadata'], cache_data['data']


def execute_cached_query(
    engine: Any,  # SQLAlchemy Engine
    query: str,
    params: Dict[str, Any],
    shop_id: str,
    query_name: str = 'query',
    use_cache: bool = True
) -> Tuple[List[Dict[str, Any]], Dict[str, Any]]:
    """
    Execute a database query with automatic caching.
    
    This function:
    1. Generates a unique cache key based on the query and parameters
    2. Checks for existing cache if use_cache=True
    3. Executes the query if no cache is found
    4. Always saves the results to cache after execution
    5. Returns the results and metadata
    
    Args:
        engine: SQLAlchemy database engine
        query: SQL query string
        params: Query parameters dictionary
        shop_id: Shop ID for cache organization
        query_name: Descriptive name for the query (used in cache filename)
        use_cache: Whether to use cache if available (default: True)
    
    Returns:
        Tuple of (results, metadata) where:
        - results: List of dictionaries representing query rows
        - metadata: Dictionary with query_execution_time, query_duration, row_count, etc.
    
    Example:
        >>> results, metadata = execute_cached_query(
        ...     engine=engine,
        ...     query="SELECT * FROM shipment WHERE shop_id = :shop_id",
        ...     params={"shop_id": "shop-123"},
        ...     shop_id="shop-123",
        ...     query_name="shipments"
        ... )
    """
    # Generate cache key and path
    cache_key = _generate_query_cache_key(query, params)
    cache_path = get_query_cache_path(shop_id, cache_key, query_name)
    
    # Try to load from cache
    if use_cache and cache_path.exists():
        try:
            metadata, results = load_query_cache(cache_path)
            print(f"Using cached query results from: {metadata.get('query_execution_time', 'unknown')}")
            return results, metadata
        except Exception as e:
            print(f"Error loading cache: {e}")
            print("Fetching from database...")
    
    # Execute query
    query_execution_time = datetime.now()
    
    with engine.connect() as conn:
        result = conn.execute(text(query), params)
        rows = result.fetchall()
    
    query_completion_time = datetime.now()
    query_duration = (query_completion_time - query_execution_time).total_seconds()
    
    print(f"Query executed at: {query_execution_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Query completed in: {query_duration:.2f} seconds")
    
    # Convert rows to dictionaries
    results = [dict(row._mapping) for row in rows]
    
    # Create metadata
    metadata = {
        'query_execution_time': query_execution_time.isoformat(),
        'query_duration': query_duration,
        'row_count': len(results),
        'query_name': query_name,
        'shop_id': shop_id
    }
    
    # Always save to cache
    save_query_cache(cache_path, results, metadata)
    
    return results, metadata

