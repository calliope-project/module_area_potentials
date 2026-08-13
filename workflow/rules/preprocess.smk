"""Rules related to data harmonisation."""

rule normalise_shapes:
    input:
        shapes="<shapes>",
    output:
        shapes="<resources>/automatic/normalized_shapes/{shape}.parquet",
    log:
        "<logs>/{shape}/normalise_shapes.log",
    conda:
        "../envs/module.yaml"
    params:
        crs=internal["target_crs"]
    message:
        "Validate and normalize {wildcards.shape} to {params.crs}."
    script:
        "../scripts/normalise_shapes.py"


checkpoint breakup_shape:
    input:
        script=workflow.source_path("../scripts/breakup_shape.py"),
        shapes=rules.normalise_shapes.output.shapes,
    output:
        directory("<resources>/automatic/shapes/{shape}"),
    log:
        "<logs>/{shape}/breakup_shape.log",
    conda:
        "../envs/module.yaml"
    params:
        split_by=config["split_by"],
    message:
        "Break up {wildcards.shape} into the configured subunits."
    shell:
        """
        python {input.script:q} {input.shapes:q} {params.split_by:q} {output:q} >{log:q} 2>&1
        """
