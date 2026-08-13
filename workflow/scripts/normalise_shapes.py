"""Input shape normalisation."""

import sys
from typing import TYPE_CHECKING, Any

import geopandas as gpd
from _schemas import ShapesSchema

if TYPE_CHECKING:
    snakemake: Any


def main() -> None:
    """Standardise the provided shapes to an internally standardised CRS."""
    shapes = gpd.read_parquet(snakemake.input.shapes)
    shapes = ShapesSchema.validate(shapes)

    target_crs = snakemake.params.crs
    if not shapes.crs.equals(target_crs):
        shapes = shapes.to_crs(target_crs)

    shapes = ShapesSchema.validate(shapes)
    shapes.to_parquet(snakemake.output.shapes)


if __name__ == "__main__":
    sys.stderr = open(snakemake.log[0], "w", buffering=1)
    main()
