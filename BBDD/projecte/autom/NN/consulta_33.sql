SELECT 
    -- Identificadors (per fer el split Train/Test sense data leakage)
    g.pk_id_gene,
    e.pk_id_exp,
    
    -- Features del Gen i Genoma
    COALESCE(g.description_gene, '') AS description_gene,
    GROUP_CONCAT(DISTINCT go.desc_GO SEPARATOR ' ') AS go_terms,
    AVG(ga.gene_length) AS avg_gene_length,
    
    -- Features de la Mostra i Espècie
    o.scientific_name AS species,
    t.name_tissue AS tissue,
    b.age,
    COALESCE(b.sex, 'unknown') AS sex,
    
    -- Features de l'Experiment (Resolució jerarquia ISA)
    p.name_platform AS platform,
    CASE 
        WHEN hm.pk_fk_id_exp IS NOT NULL THEN CONCAT('HM_', hc.name_hm)
        WHEN tf.pk_fk_id_exp IS NOT NULL THEN CONCAT('TF_', tfc.name_tf)
        WHEN da.pk_fk_id_exp IS NOT NULL THEN CONCAT('DA_', ac.name_da)
        WHEN tr.pk_fk_id_exp IS NOT NULL THEN CONCAT('TR_', tc.name_tr)
        ELSE 'OTHER'
    END AS exp_subtype,
    
    -- Variables Objectiu (Targets)
    ex.expression_value,
    TRIM(ex.gene_expressed) AS gene_expressed

FROM expression ex
JOIN genes g ON ex.pk_fk_id_gene = g.pk_id_gene
JOIN experiments e ON ex.pk_fk_id_exp = e.pk_id_exp
JOIN biosamples b ON e.fk_id_biosample = b.pk_id_biosample
JOIN tissues t ON b.fk_id_tissue = t.pk_id_tissue
JOIN organisms o ON b.fk_id_organism = o.pk_id_organism
JOIN platforms p ON e.fk_id_platform = p.pk_id_platform
LEFT JOIN gene_ass ga ON g.pk_id_gene = ga.pk_fk_id_gene
LEFT JOIN gene_ontologies go ON g.fk_id_GO = go.pk_id_GO -- Canviar a gene_go si és N:M

-- Joins per a les taules ISA
LEFT JOIN exp_hm hm ON e.pk_id_exp = hm.pk_fk_id_exp
LEFT JOIN histone_catalog hc ON hm.fk_id_hm = hc.pk_id_hm
LEFT JOIN exp_tf tf ON e.pk_id_exp = tf.pk_fk_id_exp
LEFT JOIN tf_catalog tfc ON tf.fk_id_tf = tfc.pk_id_tf
LEFT JOIN exp_da da ON e.pk_id_exp = da.pk_fk_id_exp
LEFT JOIN accessibility_catalog ac ON da.fk_id_da = ac.pk_id_da
LEFT JOIN exp_tr tr ON e.pk_id_exp = tr.pk_fk_id_exp
LEFT JOIN transcription_catalog tc ON tr.fk_id_tr = tc.pk_id_tr

GROUP BY ex.pk_fk_id_exp, ex.pk_fk_id_gene;