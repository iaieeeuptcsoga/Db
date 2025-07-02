-- =====================================================
-- TABLAS TEMPORALES GLOBALES PARA CERTIFICADO COTIZACIONES
-- Sistema: REC - Recaudación
-- Procedimiento: PRC_CERTCOT_TRAB_PUB
-- =====================================================

-- Tabla temporal para datos virtuales del trabajador (versión 1)
CREATE GLOBAL TEMPORARY TABLE GTT_REC_VIR_TRA (
    REC_PERIODO             DATE NOT NULL,
    CON_RUT                 NUMBER(9,0) NOT NULL,
    CON_CORREL              NUMBER(3,0) NOT NULL,
    RPR_PROCESO             NUMBER(1,0) NOT NULL,
    NRO_COMPROBANTE         NUMBER(7,0) NOT NULL,
    SUC_COD                 VARCHAR2(6) NOT NULL,
    USU_CODIGO              VARCHAR2(6) NOT NULL,
    TRA_RUT                 NUMBER(9,0) NOT NULL,
    TRA_DIG                 VARCHAR2(1),
    TRA_NOMBRE              VARCHAR2(40),
    TRA_APE                 VARCHAR2(40),
    REM_IMPO                NUMBER(8,0),
    REM_IMP_AFP             NUMBER(8,0),
    REM_IMPO_INP            NUMBER(8,0),
    REM_IMPO_FC             NUMBER(8,0),
    REM_IMPO_DEPCONV        NUMBER(8,0),
    DIAS_TRAB               NUMBER(5,0),
    PREVISION               NUMBER(2,0),
    SALUD                   NUMBER(2,0),
    ENT_AFC                 NUMBER(2,0),
    TIPO_IMPRE              NUMBER(1,0),
    FEC_PAGO                DATE,
    CCAF_ADH                NUMBER(2,0),
    MUT_ADH                 NUMBER(2,0),
    TASA_COT_MUT            NUMBER(6,3),
    TASA_ADIC_MUT           NUMBER(6,3),
    RAZ_SOC                 VARCHAR2(40),
    TRA_ISA_DEST            NUMBER(2,0),
    TRA_TIPO_APV            NUMBER(2,0),
    TRA_INS_APV             NUMBER(2,0),
    USU_PAGO_RETROACTIVO    VARCHAR2(1),
    REM_IMPO_CCAF           NUMBER(8,0),
    REM_IMPO_ISA            NUMBER(8,0),
    REM_IMPO_MUTUAL         NUMBER(8,0)
) ON COMMIT DELETE ROWS;

-- Tabla temporal para datos virtuales del trabajador (versión 2)
CREATE GLOBAL TEMPORARY TABLE GTT_REC_VIR_TRA2 (
    REC_PERIODO             DATE NOT NULL,
    CON_RUT                 NUMBER(9,0) NOT NULL,
    CON_CORREL              NUMBER(3,0) NOT NULL,
    RPR_PROCESO             NUMBER(1,0) NOT NULL,
    NRO_COMPROBANTE         NUMBER(7,0) NOT NULL,
    SUC_COD                 VARCHAR2(6) NOT NULL,
    USU_CODIGO              VARCHAR2(6) NOT NULL,
    TRA_RUT                 NUMBER(9,0) NOT NULL,
    TRA_DIG                 VARCHAR2(1),
    TRA_NOMBRE              VARCHAR2(40),
    TRA_APE                 VARCHAR2(40),
    REM_IMPO                NUMBER(8,0),
    REM_IMP_AFP             NUMBER(8,0),
    REM_IMPO_INP            NUMBER(8,0),
    REM_IMPO_FC             NUMBER(8,0),
    REM_IMPO_DEPCONV        NUMBER(8,0),
    DIAS_TRAB               NUMBER(5,0),
    PREVISION               NUMBER(2,0),
    SALUD                   NUMBER(2,0),
    ENT_AFC                 NUMBER(2,0),
    TIPO_IMPRE              NUMBER(1,0),
    FEC_PAGO                DATE,
    CCAF_ADH                NUMBER(2,0),
    MUT_ADH                 NUMBER(2,0),
    TASA_COT_MUT            NUMBER(6,3),
    TASA_ADIC_MUT           NUMBER(6,3),
    RAZ_SOC                 VARCHAR2(40),
    TRA_ISA_DEST            NUMBER(2,0),
    TRA_TIPO_APV            NUMBER(2,0),
    TRA_INS_APV             NUMBER(2,0),
    USU_PAGO_RETROACTIVO    VARCHAR2(1),
    REM_IMPO_CCAF           NUMBER(8,0),
    REM_IMPO_ISA            NUMBER(8,0),
    REM_IMPO_MUTUAL         NUMBER(8,0)
) ON COMMIT DELETE ROWS;

-- Tabla temporal para detalle de certificaciones
CREATE GLOBAL TEMPORARY TABLE GTT_REC_CERT_DETALLE (
    REC_PERIODO             DATE NOT NULL,
    NRO_COMPROBANTE         NUMBER(7,0) NOT NULL,
    TIPO_IMPRE              NUMBER(1,0) NOT NULL,
    SUC_COD                 VARCHAR2(6) NOT NULL,
    USU_COD                 VARCHAR2(6) NOT NULL,
    TIPO_ENT                VARCHAR2(1) NOT NULL,
    ENT_RUT                 NUMBER(9,0) NOT NULL,
    ENT_NOMBRE              VARCHAR2(255),
    TRA_RUT                 NUMBER(9,0) NOT NULL,
    TRA_DIG                 VARCHAR2(1),
    TRA_NOMBRE              VARCHAR2(40),
    TRA_APE                 VARCHAR2(40),
    DIAS_TRAB               NUMBER(5,0),
    REM_IMPO                NUMBER(8,0),
    MONTO_COTIZADO          NUMBER(8,0),
    FEC_PAGO                DATE,
    FOLIO_PLANILLA          NUMBER(10,0),
    RAZ_SOC                 VARCHAR2(40),
    SALUD                   NUMBER(2,0),
    MONTO_SIS               NUMBER(8,0),
    USU_PAGO_RETROACTIVO    VARCHAR2(1)
) ON COMMIT DELETE ROWS;

-- Tabla temporal para información de planillas
CREATE GLOBAL TEMPORARY TABLE GTT_REC_PLANILLA (
    REC_PERIODO             DATE NOT NULL,
    NRO_COMPROBANTE         NUMBER(7,0) NOT NULL,
    ENT_RUT                 NUMBER(9,0) NOT NULL,
    PLA_NRO_SERIE           NUMBER(10,0),
    SUC_COD                 VARCHAR2(6) NOT NULL,
    USU_COD                 VARCHAR2(6) NOT NULL
) ON COMMIT DELETE ROWS;

-- Tabla temporal para códigos de sucursales
CREATE GLOBAL TEMPORARY TABLE GTT_REC_SUCURSALES (
    COD_SUC                 VARCHAR2(7)
) ON COMMIT DELETE ROWS;
