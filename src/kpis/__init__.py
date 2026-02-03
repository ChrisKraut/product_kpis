"""KPI module with auto-discovery."""

import importlib
import inspect
import pkgutil
from typing import List, Type

from src.kpis.base import BaseKPI


def discover_kpis() -> List[Type[BaseKPI]]:
    """
    Scan the kpis/ directory for BaseKPI subclasses.

    Any Python file in this directory containing a class that extends BaseKPI
    will be automatically discovered and returned.

    Returns:
        List of KPI classes (not instances) found in this package.
    """
    kpis: List[Type[BaseKPI]] = []

    # Get the path to this package
    package_path = __path__

    # Walk through all modules in this package
    for importer, modname, ispkg in pkgutil.walk_packages(
        path=package_path, prefix=f"{__name__}."
    ):
        # Skip the base module
        if modname.endswith(".base"):
            continue

        try:
            module = importlib.import_module(modname)

            # Find all classes in the module
            for name, obj in inspect.getmembers(module, inspect.isclass):
                # Check if it's a subclass of BaseKPI (but not BaseKPI itself)
                if issubclass(obj, BaseKPI) and obj is not BaseKPI:
                    # Validate required attributes
                    if hasattr(obj, "name") and hasattr(obj, "description"):
                        if obj.name and obj.description:
                            kpis.append(obj)
        except Exception as e:
            # Log but don't fail on import errors
            print(f"Warning: Could not load KPI from {modname}: {e}")

    return kpis


# Re-export base classes for convenience
from src.kpis.base import BaseKPI, Parameter, ParameterType  # noqa: E402, F401
