
-- Tabla temporal para datos virtuales del trabajador
CREATE GLOBAL TEMPORARY TABLE GTT_REC_TRA (
    rec_periodo     DATE,
    con_rut         NUMBER(9),
    con_correl      NUMBER(3),
    rpr_proceso     NUMBER(1),
    nro_comprobante NUMBER(7),
    suc_cod         VARCHAR2(6),
    usu_codigo      VARCHAR2(6),
    tra_rut         NUMBER(9),
    tra_dig         VARCHAR2(1),
    tra_nombre      VARCHAR2(40),
    tra_ape         VARCHAR2(40),
    rem_impo        NUMBER(8),
    rem_impo_fc     NUMBER(8),
    dias_trab       NUMBER(5),
    fec_iniSub      DATE,
    fec_terSub      DATE,
    prevision       NUMBER(2),
    salud           NUMBER(2),
    tipo_impre      NUMBER(1),
    fec_pago        DATE,
    ccaf_adh        NUMBER(2),
    raz_soc         VARCHAR2(40),
    tra_isa_dest    NUMBER(2)
) ON COMMIT PRESERVE ROWS;


-- Tabla temporal cert_detalle
CREATE GLOBAL TEMPORARY TABLE GTT_REC_CERT_DET (
    rec_periodo     DATE,
    nro_comprobante NUMBER(7),
    tipo_impre      NUMBER(1),
    suc_cod         VARCHAR2(6),
    usu_cod         VARCHAR2(6),
    tipo_ent        VARCHAR2(1),
    ent_rut         NUMBER(9),
    ent_nombre      VARCHAR2(255),
    tra_rut         NUMBER(9),
    tra_dig         VARCHAR2(1),
    tra_nombre      VARCHAR2(40),
    tra_ape         VARCHAR2(40),
    dias_trab       NUMBER(5),
    fec_inisub      DATE,
    fec_tersub      DATE,
    rem_impo        NUMBER(8),
    monto_cotizado  NUMBER(8),
    fec_pago        DATE,
    folio_planilla  NUMBER(10),
    raz_soc         VARCHAR2(40),
    tra_isa_dest    NUMBER(2),
    salud           NUMBER
) ON COMMIT PRESERVE ROWS;


-- Comentarios de documentación
COMMENT ON TABLE GTT_REC_TRA IS 'Tabla temporal para datos virtuales del trabajador - Certificado Cotizaciones';
COMMENT ON TABLE GTT_REC_CERT_DET IS 'Tabla temporal para detalle de certificaciones por entidad previsional';

-- Índices para optimizar consultas en tablas temporales
CREATE INDEX IDX_GTT_VIR_TRA_PERIODO ON GTT_REC_TRA(REC_PERIODO, TRA_RUT);
CREATE INDEX IDX_GTT_CERT_DET_PERIODO ON GTT_REC_CERT_DET(REC_PERIODO, TRA_RUT, TIPO_ENT);
