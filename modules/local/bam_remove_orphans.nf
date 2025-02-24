process BAM_REMOVE_ORPHANS {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::pysam=0.22.0 bioconda::samtools=1.19.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-295c3b1e30b1b8b8cae86c1033ba99e7b63674d6:2f4c558dbcac0618112a14d10e44a4d5a69ba3d8-0' :
        'biocontainers/mulled-v2-295c3b1e30b1b8b8cae86c1033ba99e7b63674d6:2f4c558dbcac0618112a14d10e44a4d5a69ba3d8-0' }"

    input:
    tuple val(meta), path(bam) //, path(bai)

    output:
    tuple val(meta), path("*.bam"), emit: bam
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/atacseq/bin/
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    if (!meta.single_end) {
        """
        bampe_rm_orphan.py \\
            $bam \\
            ${prefix}.bam \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        END_VERSIONS
        """
    } else {
        """
        ln -s $bam ${prefix}.bam

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            samtools: \$(echo \$(samtools --version 2>&1) | sed 's/^.*samtools //; s/Using.*\$//')
        END_VERSIONS
        """
    }
}
