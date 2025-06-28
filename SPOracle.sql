-- =====================================================================================
-- ARCHIVO: DDL_TABLAS_NORMATIVAS_COT.sql
-- DESCRIPCIÓN: Definición de tablas temporales refactorizadas según normativas Oracle
-- SISTEMA: COT (Cotizaciones)
-- FECHA CREACIÓN: 2025-06-27
-- AUTOR: Refactorización según normativas de nomenclatura Oracle
-- =====================================================================================

-- =====================================================================================
-- DOCUMENTACIÓN DE REFACTORIZACIÓN
-- =====================================================================================
-- OBJETIVO: Normalizar nombres de tablas temporales según normativas Oracle
-- ALCANCE: Tablas temporales del sistema de cotizaciones (COT)
--
-- NOMENCLATURA APLICADA:
-- - TBL: Prefijo para tablas
-- - COT: Prefijo del sistema (Cotizaciones)
-- - Nombres descriptivos según funcionalidad
--
-- MAPEO DE REFACTORIZACIÓN:
-- TBL_COT_TRABAJADOR_VIRTUAL_2        -> TBL_COT_TRABAJADOR_VIRTUAL_2
-- TBL_COT_TRABAJADOR_VIRTUAL         -> TBL_COT_TRABAJADOR_VIRTUAL
-- TBL_COT_CERTIFICADO_DETALLE    -> TBL_COT_CERTIFICADO_DETALLE
-- TBL_COT_PLANILLA_TEMPORAL        -> TBL_COT_PLANILLA_TEMPORAL
-- TBL_COT_SUCURSALES_TEMPORAL      -> TBL_COT_SUCURSALES_TEMPORAL
-- =====================================================================================

-- =====================================================================================
-- TABLA: TBL_COT_TRABAJADOR_VIRTUAL_2
-- DESCRIPCIÓN: Tabla temporal para almacenar datos virtuales de trabajadores (versión 2)
-- REEMPLAZA: TBL_COT_TRABAJADOR_VIRTUAL_2
-- PROPÓSITO: Almacena información detallada de trabajadores para procesamiento de cotizaciones
-- SIZING ESTIMADO:
--   - 1 mes: 50,000 registros
--   - 1 año: 600,000 registros
--   - 3 años: 1,800,000 registros
-- MANTENIMIENTO: Los datos se eliminan automáticamente al finalizar la transacción (ON COMMIT DELETE ROWS)
-- PROCESO DUEÑO: Sistema de Cotizaciones - Módulo de Certificados
-- =====================================================================================
CREATE GLOBAL TEMPORARY TABLE TBL_COT_TRABAJADOR_VIRTUAL_2 (
    -- Campos de identificación temporal y de proceso
    COT_REC_PERIODO         DATE,                  -- Período de recaudación
    COT_CON_RUT             NUMBER(9),             -- RUT del convenio
    COT_CON_CORREL          NUMBER(3),             -- Correlativo del convenio
    COT_RPR_PROCESO         NUMBER(1),             -- Proceso de recaudación
    COT_NRO_COMPROBANTE     NUMBER(7),             -- Número de comprobante
    COT_SUC_COD             VARCHAR2(6),           -- Código de sucursal
    COT_USU_CODIGO          VARCHAR2(6),           -- Código de usuario

    -- Datos del trabajador
    COT_TRA_RUT             NUMBER(9),             -- RUT del trabajador
    COT_TRA_DIG             VARCHAR2(1),           -- Dígito verificador del trabajador
    COT_TRA_NOMBRE          VARCHAR2(40),          -- Nombre del trabajador
    COT_TRA_APE             VARCHAR2(40),          -- Apellido del trabajador

    -- Remuneraciones e importes
    COT_REM_IMPO            NUMBER(8),             -- Remuneración imponible
    COT_REM_IMP_AFP         NUMBER(8),             -- Remuneración imponible AFP
    COT_REM_IMPO_INP        NUMBER(8),             -- Remuneración imponible INP
    COT_REM_IMPO_FC         NUMBER(8),             -- Remuneración imponible fondo cesantía
    COT_REM_IMPO_DEPCONV    NUMBER(8),             -- Remuneración imponible depósito convenido

    -- Información laboral
    COT_DIAS_TRAB           NUMBER(5),             -- Días trabajados
    COT_PREVISION           NUMBER(2),             -- Código de previsión
    COT_SALUD               NUMBER(2),             -- Código de salud
    COT_ENT_AFC             NUMBER(2),             -- Entidad administradora fondo cesantía
    COT_TIPO_IMPRE          NUMBER(1),             -- Tipo de impresión
    COT_FEC_PAGO            DATE,                  -- Fecha de pago

    -- Información de cajas y mutuales
    COT_CCAF_ADH            NUMBER(2),             -- CCAF adherida
    COT_MUT_ADH             NUMBER(2),             -- Mutual adherida
    COT_TASA_COT_MUT        NUMBER(6,3),           -- Tasa cotización mutual
    COT_TASA_ADIC_MUT       NUMBER(6,3),           -- Tasa adicional mutual
    COT_RAZ_SOC             VARCHAR2(40),          -- Razón social

    -- Información APV e ISAPRE
    COT_TRA_ISA_DEST        NUMBER(2),             -- Destino ISAPRE trabajador
    COT_TRA_TIPO_APV        NUMBER(2),             -- Tipo APV trabajador
    COT_TRA_INS_APV         NUMBER(2),             -- Institución APV trabajador

    -- Remuneraciones específicas
    COT_REM_IMPO_CCAF       NUMBER(8),             -- Remuneración imponible CCAF
    COT_REM_IMPO_ISA        NUMBER(8),             -- Remuneración imponible ISAPRE
    COT_REM_IMPO_MUTUAL     NUMBER(8),             -- Remuneración imponible mutual

    -- Indicadores multi-entidad
    COT_EMP_MULTI_CCAF      NUMBER(1),             -- Empresa multi CCAF
    COT_EMP_MULTI_MUTUAL    NUMBER(1)              -- Empresa multi mutual
) ON COMMIT DELETE ROWS;

-- =====================================================================================
-- TABLA: TBL_COT_TRABAJADOR_VIRTUAL
-- DESCRIPCIÓN: Tabla temporal principal para datos virtuales de trabajadores
-- REEMPLAZA: TBL_COT_TRABAJADOR_VIRTUAL
-- PROPÓSITO: Almacena información consolidada de trabajadores para procesamiento final
-- SIZING ESTIMADO:
--   - 1 mes: 45,000 registros
--   - 1 año: 540,000 registros
--   - 3 años: 1,620,000 registros
-- MANTENIMIENTO: Los datos se eliminan automáticamente al finalizar la transacción
-- PROCESO DUEÑO: Sistema de Cotizaciones - Módulo de Certificados
-- =====================================================================================
CREATE GLOBAL TEMPORARY TABLE TBL_COT_TRABAJADOR_VIRTUAL (
    -- Campos de identificación temporal y de proceso
    COT_REC_PERIODO         DATE,                  -- Período de recaudación
    COT_CON_RUT             NUMBER(9),             -- RUT del convenio
    COT_CON_CORREL          NUMBER(3),             -- Correlativo del convenio
    COT_RPR_PROCESO         NUMBER(1),             -- Proceso de recaudación
    COT_NRO_COMPROBANTE     NUMBER(7),             -- Número de comprobante
    COT_SUC_COD             VARCHAR2(6),           -- Código de sucursal
    COT_USU_CODIGO          VARCHAR2(6),           -- Código de usuario

    -- Datos del trabajador
    COT_TRA_RUT             NUMBER(9),             -- RUT del trabajador
    COT_TRA_DIG             VARCHAR2(1),           -- Dígito verificador del trabajador
    COT_TRA_NOMBRE          VARCHAR2(40),          -- Nombre del trabajador
    COT_TRA_APE             VARCHAR2(40),          -- Apellido del trabajador

    -- Remuneraciones e importes
    COT_REM_IMPO            NUMBER(8),             -- Remuneración imponible
    COT_REM_IMP_AFP         NUMBER(8),             -- Remuneración imponible AFP
    COT_REM_IMPO_INP        NUMBER(8),             -- Remuneración imponible INP
    COT_REM_IMPO_FC         NUMBER(8),             -- Remuneración imponible fondo cesantía
    COT_REM_IMPO_DEPCONV    NUMBER(8),             -- Remuneración imponible depósito convenido

    -- Información laboral
    COT_DIAS_TRAB           NUMBER(5),             -- Días trabajados
    COT_PREVISION           NUMBER(2),             -- Código de previsión
    COT_SALUD               NUMBER(2),             -- Código de salud
    COT_ENT_AFC             NUMBER(2),             -- Entidad administradora fondo cesantía
    COT_TIPO_IMPRE          NUMBER(1),             -- Tipo de impresión
    COT_FEC_PAGO            DATE,                  -- Fecha de pago

    -- Información de cajas y mutuales
    COT_CCAF_ADH            NUMBER(2),             -- CCAF adherida
    COT_MUT_ADH             NUMBER(2),             -- Mutual adherida
    COT_TASA_COT_MUT        NUMBER(6,3),           -- Tasa cotización mutual
    COT_TASA_ADIC_MUT       NUMBER(6,3),           -- Tasa adicional mutual
    COT_RAZ_SOC             VARCHAR2(40),          -- Razón social

    -- Información APV e ISAPRE
    COT_TRA_ISA_DEST        NUMBER(2),             -- Destino ISAPRE trabajador
    COT_TRA_TIPO_APV        NUMBER(2),             -- Tipo APV trabajador
    COT_TRA_INS_APV         NUMBER(2),             -- Institución APV trabajador

    -- Remuneraciones específicas
    COT_REM_IMPO_CCAF       NUMBER(8),             -- Remuneración imponible CCAF
    COT_REM_IMPO_ISA        NUMBER(8),             -- Remuneración imponible ISAPRE
    COT_REM_IMPO_MUTUAL     NUMBER(8),             -- Remuneración imponible mutual

    -- Indicadores multi-entidad
    COT_EMP_MULTI_CCAF      NUMBER(1),             -- Empresa multi CCAF
    COT_EMP_MULTI_MUTUAL    NUMBER(1)              -- Empresa multi mutual
) ON COMMIT DELETE ROWS;

-- =====================================================================================
-- TABLA: TBL_COT_CERTIFICADO_DETALLE
-- DESCRIPCIÓN: Tabla temporal para almacenar detalles de certificados de cotizaciones
-- REEMPLAZA: TBL_COT_CERTIFICADO_DETALLE
-- PROPÓSITO: Contiene el detalle de certificados generados para trabajadores
-- SIZING ESTIMADO:
--   - 1 mes: 100,000 registros
--   - 1 año: 1,200,000 registros
--   - 3 años: 3,600,000 registros
-- MANTENIMIENTO: Los datos se eliminan automáticamente al finalizar la transacción
-- PROCESO DUEÑO: Sistema de Cotizaciones - Módulo de Certificados
-- =====================================================================================
CREATE GLOBAL TEMPORARY TABLE TBL_COT_CERTIFICADO_DETALLE (
    -- Campos de identificación temporal
    COT_REC_PERIODO         DATE,                  -- Período de recaudación
    COT_NRO_COMPROBANTE     NUMBER(7),             -- Número de comprobante
    COT_TIPO_IMPRE          NUMBER(1),             -- Tipo de impresión
    COT_SUC_COD             VARCHAR2(6),           -- Código de sucursal
    COT_USU_COD             VARCHAR2(6),           -- Código de usuario

    -- Información de la entidad
    COT_TIPO_ENT            VARCHAR2(1),           -- Tipo de entidad (A=AFP, B=FONASA/ISAPRE, C=CCAF, etc.)
    COT_ENT_RUT             NUMBER(9),             -- RUT de la entidad
    COT_ENT_NOMBRE          VARCHAR2(255),         -- Nombre de la entidad

    -- Datos del trabajador
    COT_TRA_RUT             NUMBER(9),             -- RUT del trabajador
    COT_TRA_DIG             VARCHAR2(1),           -- Dígito verificador del trabajador
    COT_TRA_NOMBRE          VARCHAR2(40),          -- Nombre del trabajador
    COT_TRA_APE             VARCHAR2(40),          -- Apellido del trabajador

    -- Información laboral y de cotización
    COT_DIAS_TRAB           NUMBER(5),             -- Días trabajados
    COT_REM_IMPO            NUMBER(8),             -- Remuneración imponible
    COT_MONTO_COTIZADO      NUMBER(8),             -- Monto cotizado
    COT_FEC_PAGO            DATE,                  -- Fecha de pago
    COT_FOLIO_PLANILLA      NUMBER(10),            -- Folio de planilla
    COT_RAZ_SOC             VARCHAR2(40),          -- Razón social
    COT_SALUD               NUMBER(2),             -- Código de salud
    COT_MONTO_SIS           NUMBER(8)              -- Monto SIS
) ON COMMIT DELETE ROWS;

-- =====================================================================================
-- TABLA: TBL_COT_PLANILLA_TEMPORAL
-- DESCRIPCIÓN: Tabla temporal para almacenar información de planillas
-- REEMPLAZA: TBL_COT_PLANILLA_TEMPORAL
-- PROPÓSITO: Almacena información temporal de planillas para asociar con certificados
-- SIZING ESTIMADO:
--   - 1 mes: 20,000 registros
--   - 1 año: 240,000 registros
--   - 3 años: 720,000 registros
-- MANTENIMIENTO: Los datos se eliminan automáticamente al finalizar la transacción
-- PROCESO DUEÑO: Sistema de Cotizaciones - Módulo de Planillas
-- =====================================================================================
CREATE GLOBAL TEMPORARY TABLE TBL_COT_PLANILLA_TEMPORAL (
    -- Campos de identificación temporal
    COT_REC_PERIODO         DATE,                  -- Período de recaudación
    COT_NRO_COMPROBANTE     NUMBER(7),             -- Número de comprobante
    COT_ENT_RUT             NUMBER(9),             -- RUT de la entidad
    COT_PLA_NRO_SERIE       NUMBER(10),            -- Número de serie de planilla
    COT_SUC_COD             VARCHAR2(6),           -- Código de sucursal
    COT_USU_COD             VARCHAR2(6)            -- Código de usuario
) ON COMMIT DELETE ROWS;

-- =====================================================================================
-- TABLA: TBL_COT_SUCURSALES_TEMPORAL
-- DESCRIPCIÓN: Tabla temporal para almacenar códigos de sucursales
-- REEMPLAZA: TBL_COT_SUCURSALES_TEMPORAL
-- PROPÓSITO: Almacena temporalmente códigos de sucursales para filtros de consulta
-- SIZING ESTIMADO:
--   - 1 mes: 500 registros
--   - 1 año: 6,000 registros
--   - 3 años: 18,000 registros
-- MANTENIMIENTO: Los datos se eliminan automáticamente al finalizar la transacción
-- PROCESO DUEÑO: Sistema de Cotizaciones - Módulo de Sucursales
-- =====================================================================================
CREATE GLOBAL TEMPORARY TABLE TBL_COT_SUCURSALES_TEMPORAL (
    COT_CODSUC              VARCHAR2(7)            -- Código de sucursal
) ON COMMIT DELETE ROWS;

-- =====================================================================================
-- ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- =====================================================================================

-- Índices para TBL_COT_TRABAJADOR_VIRTUAL_2
CREATE INDEX IND_COT_NX_TRAV2_PERIODO ON TBL_COT_TRABAJADOR_VIRTUAL_2 (COT_REC_PERIODO);
CREATE INDEX IND_COT_NX_TRAV2_TRABAJ ON TBL_COT_TRABAJADOR_VIRTUAL_2 (COT_TRA_RUT);
CREATE INDEX IND_COT_NX_TRAV2_COMPRO ON TBL_COT_TRABAJADOR_VIRTUAL_2 (COT_NRO_COMPROBANTE);

-- Índices para TBL_COT_TRABAJADOR_VIRTUAL
CREATE INDEX IND_COT_NX_TRAV_PERIODO ON TBL_COT_TRABAJADOR_VIRTUAL (COT_REC_PERIODO);
CREATE INDEX IND_COT_NX_TRAV_TRABAJ ON TBL_COT_TRABAJADOR_VIRTUAL (COT_TRA_RUT);
CREATE INDEX IND_COT_NX_TRAV_COMPRO ON TBL_COT_TRABAJADOR_VIRTUAL (COT_NRO_COMPROBANTE);

-- Índices para TBL_COT_CERTIFICADO_DETALLE
CREATE INDEX IND_COT_NX_CERTDET_PER ON TBL_COT_CERTIFICADO_DETALLE (COT_REC_PERIODO);
CREATE INDEX IND_COT_NX_CERTDET_TRA ON TBL_COT_CERTIFICADO_DETALLE (COT_TRA_RUT);
CREATE INDEX IND_COT_NX_CERTDET_ENT ON TBL_COT_CERTIFICADO_DETALLE (COT_ENT_RUT);

-- Índices para TBL_COT_PLANILLA_TEMPORAL
CREATE INDEX IND_COT_NX_PLANT_PERIO ON TBL_COT_PLANILLA_TEMPORAL (COT_REC_PERIODO);
CREATE INDEX IND_COT_NX_PLANT_COMPR ON TBL_COT_PLANILLA_TEMPORAL (COT_NRO_COMPROBANTE);

-- =====================================================================================
-- COMENTARIOS ADICIONALES SOBRE TABLAS
-- =====================================================================================

-- Comentarios en tablas principales
COMMENT ON TABLE TBL_COT_TRABAJADOR_VIRTUAL_2 IS 'Tabla temporal para datos virtuales de trabajadores versión 2 - Sistema COT';
COMMENT ON TABLE TBL_COT_TRABAJADOR_VIRTUAL IS 'Tabla temporal principal para datos virtuales de trabajadores - Sistema COT';
COMMENT ON TABLE TBL_COT_CERTIFICADO_DETALLE IS 'Tabla temporal para detalles de certificados de cotizaciones - Sistema COT';
COMMENT ON TABLE TBL_COT_PLANILLA_TEMPORAL IS 'Tabla temporal para información de planillas - Sistema COT';
COMMENT ON TABLE TBL_COT_SUCURSALES_TEMPORAL IS 'Tabla temporal para códigos de sucursales - Sistema COT';
CREATE OR REPLACE PROCEDURE SP_CERTCOT_TRAB20 (
    P_FEC_INI      IN DATE,
    P_FEC_TER      IN DATE,
    P_EMP_RUT      IN NUMBER,
    P_CONVENIO     IN NUMBER,
    P_RUT_TRA      IN NUMBER,
    P_TIPOCON      IN NUMBER,
    P_PARAMETRO    IN VARCHAR2 DEFAULT NULL,
    P_PARAMETRO2   IN VARCHAR2 DEFAULT NULL,
    P_PARAMETRO3   IN VARCHAR2 DEFAULT NULL
) AS
    V_TIPOIMP   NUMBER(1);
    V_PERIODO   DATE;
    V_NOMTRA    VARCHAR2(40);
    V_APETRA    VARCHAR2(40);
    V_NUMCOMP   NUMBER(7);

    -- Cursor para los insert de planilla
    CURSOR TRA_CURSOR IS
        SELECT DISTINCT REC_PERIODO, TIPO_IMPRE, NRO_COMPROBANTE
        FROM TMP_CERT_DETALLE;
BEGIN
    -- Limpieza de tablas temporales
    DELETE FROM TMP_VIR_TRA2;
    DELETE FROM TMP_VIR_TRA;
    DELETE FROM TMP_CERT_DETALLE;
    DELETE FROM TMP_PLANILLA;
    DELETE FROM TMP_SUCURSALES;

    -- Bloque de sucursales
    IF P_TIPOCON = 2 THEN
        INSERT INTO TMP_SUCURSALES (CODSUC)
        SELECT COD_SUC
        FROM DET_CTA_USU
        WHERE CON_RUT = P_EMP_RUT
            AND CON_CORREL = P_CONVENIO
            AND USR_RUT = TO_NUMBER(P_PARAMETRO);
    ELSIF P_TIPOCON = 3 THEN
        INSERT INTO TMP_SUCURSALES (CODSUC) VALUES (P_PARAMETRO);
    END IF;

    --------------------------------------------------------------------------
    -- Obtiene los datos del trabajador
    --------------------------------------------------------------------------
    IF P_CONVENIO BETWEEN 600 AND 699 THEN
        IF P_TIPOCON = 1 THEN
            INSERT INTO TMP_VIR_TRA2
            SELECT 
                t.REC_PERIODO,
                t.CON_RUT,
                t.CON_CORREL,
                t.RPR_PROCESO,
                t.NRO_COMPROBANTE,
                t.SUC_CODIGO,
                t.USU_CODIGO,
                t.TRA_RUT,
                t.TRA_DIGITO,
                t.TRA_NOMTRA,
                t.TRA_APETRA,
                t.TRA_REM_IMPONIBLE,
                t.TRA_REM_IMP_AFP,
                t.TRA_REMIMP_INPCCAF,
                t.TRA_REM_IMPONIBLE_FC,
                t.TRA_REM_IMP_DEPCON,
                t.TRA_NRO_DIAS_TRAB,
                t.TRA_REG_PREVIS,
                t.TRA_REG_SALUD,
                t.TRA_ADM_FONDO_CES,
                e.EMP_ORDEN_IMP,
                p.PAG_FECTIMBRE,
                s.SUC_CCAF_ADH,
                e.EMP_MUTUAL_ADH,
                e.EMP_TASA_COT_MUT,
                e.EMP_COTADIC_MUT,
                e.EMP_RAZSOC,
                t.TRA_ISADES,
                t.TRA_TIPO_INS_APV,
                t.TRA_INS_APV,
                t.TRA_REM_CCAF,
                t.TRA_REM_ISAPRE,
                t.TRA_REM_MUTUAL,
                NVL(e.EMP_MULTICCAF, 0),
                NVL(e.EMP_MULTIMUT, 0)
            FROM REC_EMPRESA e, REC_SUCURSAL s, REC_PAGO p, REC_TRABAJADOR t
            WHERE e.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
                AND e.CON_RUT = P_EMP_RUT
                AND e.CON_CORREL = P_CONVENIO
                AND e.RPR_PROCESO IN (1,2,3,4)
                AND p.PAG_TRASPASO = 1 
                AND p.RET_ESTADO = 5
                AND t.TRA_RUT = P_RUT_TRA
                AND e.REC_PERIODO = s.REC_PERIODO 
                AND e.CON_RUT = s.CON_RUT
                AND e.CON_CORREL = s.CON_CORREL
                AND e.RPR_PROCESO = s.RPR_PROCESO
                AND e.NRO_COMPROBANTE = s.NRO_COMPROBANTE
                AND e.REC_PERIODO = p.REC_PERIODO
                AND e.CON_RUT = p.CON_RUT
                AND e.CON_CORREL = p.CON_CORREL         
                AND e.RPR_PROCESO = p.RPR_PROCESO        
                AND e.NRO_COMPROBANTE = p.NRO_COMPROBANTE    
                AND e.REC_PERIODO = t.REC_PERIODO 
                AND e.CON_RUT = t.CON_RUT
                AND e.CON_CORREL = t.CON_CORREL
                AND e.RPR_PROCESO = t.RPR_PROCESO
                AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
                AND t.SUC_CODIGO = s.SUC_CODIGO
            ORDER BY t.REC_PERIODO, t.SUC_CODIGO, t.USU_CODIGO;
        ELSE
            INSERT INTO TMP_VIR_TRA2
            SELECT 
                t.REC_PERIODO,
                t.CON_RUT,
                t.CON_CORREL,
                t.RPR_PROCESO,
                t.NRO_COMPROBANTE,
                t.SUC_CODIGO,
                t.USU_CODIGO,
                t.TRA_RUT,
                t.TRA_DIGITO,
                t.TRA_NOMTRA,
                t.TRA_APETRA,
                t.TRA_REM_IMPONIBLE,
                t.TRA_REM_IMP_AFP,
                t.TRA_REMIMP_INPCCAF,
                t.TRA_REM_IMPONIBLE_FC,
                t.TRA_REM_IMP_DEPCON,
                t.TRA_NRO_DIAS_TRAB,
                t.TRA_REG_PREVIS,
                t.TRA_REG_SALUD,
                t.TRA_ADM_FONDO_CES,
                e.EMP_ORDEN_IMP,
                p.PAG_FECTIMBRE,
                s.SUC_CCAF_ADH,
                e.EMP_MUTUAL_ADH,
                e.EMP_TASA_COT_MUT,
                e.EMP_COTADIC_MUT,
                e.EMP_RAZSOC,
                t.TRA_ISADES,
                t.TRA_TIPO_INS_APV,
                t.TRA_INS_APV,
                t.TRA_REM_CCAF,
                t.TRA_REM_ISAPRE,
                t.TRA_REM_MUTUAL,
                NVL(e.EMP_MULTICCAF, 0),
                NVL(e.EMP_MULTIMUT, 0)
            FROM REC_EMPRESA e, REC_SUCURSAL s, REC_PAGO p, REC_TRABAJADOR t
            WHERE e.REC_PERIODO = s.REC_PERIODO 
                AND e.CON_RUT = s.CON_RUT
                AND e.CON_CORREL = s.CON_CORREL
                AND e.RPR_PROCESO = s.RPR_PROCESO
                AND e.NRO_COMPROBANTE = s.NRO_COMPROBANTE
                AND e.REC_PERIODO = p.REC_PERIODO  
                AND e.CON_RUT = p.CON_RUT
                AND e.CON_CORREL = p.CON_CORREL  
                AND e.RPR_PROCESO = p.RPR_PROCESO 
                AND e.NRO_COMPROBANTE = p.NRO_COMPROBANTE 
                AND e.REC_PERIODO = t.REC_PERIODO 
                AND e.CON_RUT = t.CON_RUT
                AND e.CON_CORREL = t.CON_CORREL
                AND e.RPR_PROCESO = t.RPR_PROCESO
                AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
                AND t.SUC_CODIGO = s.SUC_CODIGO
                AND e.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
                AND e.CON_RUT = P_EMP_RUT
                AND e.CON_CORREL = P_CONVENIO
                AND e.RPR_PROCESO IN (1,2,3,4)
                AND p.PAG_TRASPASO = 1 
                AND p.RET_ESTADO = 5
                AND t.TRA_RUT = P_RUT_TRA
                AND t.SUC_CODIGO IN (SELECT CODSUC FROM TMP_SUCURSALES)
            ORDER BY t.REC_PERIODO, t.SUC_CODIGO, t.USU_CODIGO;
        END IF;
    ELSE
        IF P_TIPOCON = 1 THEN
            INSERT INTO TMP_VIR_TRA2
            SELECT 
                t.REC_PERIODO,
                t.CON_RUT,
                t.CON_CORREL,
                t.RPR_PROCESO,
                t.NRO_COMPROBANTE,
                t.SUC_CODIGO,
                t.USU_CODIGO,
                t.TRA_RUT,
                t.TRA_DIGITO,
                t.TRA_NOMTRA,
                t.TRA_APETRA,
                t.TRA_REM_IMPONIBLE,
                t.TRA_REM_IMP_AFP,
                t.TRA_REMIMP_INPCCAF,
                t.TRA_REM_IMPONIBLE_FC,
                t.TRA_REM_IMP_DEPCON,
                t.TRA_NRO_DIAS_TRAB,
                t.TRA_REG_PREVIS,
                t.TRA_REG_SALUD,
                t.TRA_ADM_FONDO_CES,
                e.EMP_ORDEN_IMP,
                p.PAG_FECTIMBRE,
                CASE 
                    WHEN (e.EMP_MULTICCAF IS NULL) OR (e.EMP_MULTICCAF = 0)
                    THEN e.EMP_CCAF_ADH  
                    WHEN (e.EMP_MULTICCAF = 1) 
                    THEN t.TRA_CCAF_ADH   
                    ELSE 0
                END,
                CASE 
                    WHEN (e.EMP_MULTIMUT IS NULL) OR (e.EMP_MULTIMUT = 0)
                    THEN e.EMP_MUTUAL_ADH  
                    WHEN (e.EMP_MULTIMUT = 1) 
                    THEN t.TRA_MUTUAL_ADH   
                    ELSE 0
                END,
                e.EMP_TASA_COT_MUT,
                e.EMP_COTADIC_MUT,
                e.EMP_RAZSOC,
                t.TRA_ISADES,
                t.TRA_TIPO_INS_APV,
                t.TRA_INS_APV,
                t.TRA_REM_CCAF,
                t.TRA_REM_ISAPRE,
                t.TRA_REM_MUTUAL,
                NVL(e.EMP_MULTICCAF, 0),
                NVL(e.EMP_MULTIMUT, 0)
            FROM REC_EMPRESA e, REC_PAGO p, REC_TRABAJADOR t
            WHERE e.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
                AND e.CON_RUT = P_EMP_RUT
                AND e.CON_CORREL = P_CONVENIO
                AND e.RPR_PROCESO IN (1,2,3,4)
                AND t.TRA_RUT = P_RUT_TRA
                AND p.PAG_TRASPASO = 1 
                AND p.RET_ESTADO = 5
                AND e.REC_PERIODO = p.REC_PERIODO 
                AND e.CON_RUT = p.CON_RUT 
                AND e.CON_CORREL = p.CON_CORREL 
                AND e.RPR_PROCESO = p.RPR_PROCESO
                AND e.NRO_COMPROBANTE = p.NRO_COMPROBANTE
                AND e.REC_PERIODO = t.REC_PERIODO 
                AND e.CON_RUT = t.CON_RUT
                AND e.CON_CORREL = t.CON_CORREL
                AND e.RPR_PROCESO = t.RPR_PROCESO
                AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
            ORDER BY t.REC_PERIODO, t.SUC_CODIGO, t.USU_CODIGO;
        ELSE
            INSERT INTO TMP_VIR_TRA2
            SELECT 
                t.REC_PERIODO,
                t.CON_RUT,
                t.CON_CORREL,
                t.RPR_PROCESO,
                t.NRO_COMPROBANTE,
                t.SUC_CODIGO,
                t.USU_CODIGO,
                t.TRA_RUT,
                t.TRA_DIGITO,
                t.TRA_NOMTRA,
                t.TRA_APETRA,
                t.TRA_REM_IMPONIBLE,
                t.TRA_REM_IMP_AFP,
                t.TRA_REMIMP_INPCCAF,
                t.TRA_REM_IMPONIBLE_FC,
                t.TRA_REM_IMP_DEPCON,
                t.TRA_NRO_DIAS_TRAB,
                t.TRA_REG_PREVIS,
                t.TRA_REG_SALUD,
                t.TRA_ADM_FONDO_CES,
                e.EMP_ORDEN_IMP,
                p.PAG_FECTIMBRE,
                CASE 
                    WHEN (e.EMP_MULTICCAF IS NULL) OR (e.EMP_MULTICCAF = 0)
                    THEN e.EMP_CCAF_ADH  
                    WHEN (e.EMP_MULTICCAF = 1) 
                    THEN t.TRA_CCAF_ADH   
                    ELSE 0
                END,
                CASE 
                    WHEN (e.EMP_MULTIMUT IS NULL) OR (e.EMP_MULTIMUT = 0)
                    THEN e.EMP_MUTUAL_ADH  
                    WHEN (e.EMP_MULTIMUT = 1) 
                    THEN t.TRA_MUTUAL_ADH   
                    ELSE 0
                END,
                e.EMP_TASA_COT_MUT,
                e.EMP_COTADIC_MUT,
                e.EMP_RAZSOC,
                t.TRA_ISADES,
                t.TRA_TIPO_INS_APV,
                t.TRA_INS_APV,
                t.TRA_REM_CCAF,
                t.TRA_REM_ISAPRE,
                t.TRA_REM_MUTUAL,
                NVL(e.EMP_MULTICCAF, 0),
                NVL(e.EMP_MULTIMUT, 0)
            FROM REC_EMPRESA e, REC_PAGO p, REC_TRABAJADOR t
            WHERE e.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
                AND e.CON_RUT = P_EMP_RUT
                AND e.CON_CORREL = P_CONVENIO
                AND e.RPR_PROCESO IN (1,2,3,4)
                AND t.TRA_RUT = P_RUT_TRA
                AND p.PAG_TRASPASO = 1 
                AND p.RET_ESTADO = 5
                AND t.SUC_CODIGO IN (SELECT CODSUC FROM TMP_SUCURSALES)
                AND e.REC_PERIODO = t.REC_PERIODO 
                AND e.CON_RUT = t.CON_RUT
                AND e.CON_CORREL = t.CON_CORREL
                AND e.RPR_PROCESO = t.RPR_PROCESO
                AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
                AND e.REC_PERIODO = p.REC_PERIODO
                AND e.CON_RUT = p.CON_RUT
                AND e.CON_CORREL = p.CON_CORREL
                AND e.RPR_PROCESO = p.RPR_PROCESO
                AND e.NRO_COMPROBANTE = p.NRO_COMPROBANTE 
            ORDER BY t.REC_PERIODO, t.SUC_CODIGO, t.USU_CODIGO;
        END IF;
    END IF;

    --------------------------------------------------------------------------
    -- Agrupa datos de trabajador
    --------------------------------------------------------------------------
    IF P_PARAMETRO2 IS NOT NULL THEN
        INSERT INTO TMP_VIR_TRA
        SELECT * FROM TMP_VIR_TRA2 WHERE USU_CODIGO = P_PARAMETRO2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    ELSE
        INSERT INTO TMP_VIR_TRA
        SELECT * FROM TMP_VIR_TRA2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    END IF;

    --------------------------------------------------------------------------
    -- Obtiene el nombre/apellido del último periodo
    --------------------------------------------------------------------------
    BEGIN
        SELECT TRA_NOMBRE, TRA_APE
        INTO V_NOMTRA, V_APETRA
        FROM (
            SELECT TRA_NOMBRE, TRA_APE
            FROM TMP_VIR_TRA
            ORDER BY REC_PERIODO DESC
        ) WHERE ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            V_NOMTRA := NULL;
            V_APETRA := NULL;
    END;

    UPDATE TMP_VIR_TRA SET TRA_NOMBRE = V_NOMTRA, TRA_APE = V_APETRA;

    --------------------------------------------------------------------------
    -- Cotización AFP: Gratificaciones
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'A', afps.ENT_RUT, afps.ENT_NOM, vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMP_AFP
            ELSE vt.REM_IMPO
        END,
        trab_afp.AFP_COT_OBLIGATORIA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0)
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.PREVISION = AFPS.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = AFPS.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 2
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización AFP: Remuneraciones antes de Julio 2009
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'A', afps.ENT_RUT, afps.ENT_NOM, vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB, vt.REM_IMPO, trab_afp.AFP_COT_OBLIGATORIA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0)
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.PREVISION = AFPS.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = AFPS.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización AFP: Remuneraciones Después de Julio 2009
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'A', afps.ENT_RUT, afps.ENT_NOM, vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB, vt.REM_IMP_AFP, trab_afp.AFP_COT_OBLIGATORIA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0)
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.PREVISION = AFPS.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = AFPS.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización INP
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'A', inp.ENT_RUT, inp.ENT_NOM, vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMPO_INP  
            WHEN vt.RPR_PROCESO = 1 AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
            THEN vt.REM_IMPO_INP   
            ELSE vt.REM_IMPO
        END,
        tra_inp.INP_COT_PREV, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAINP tra_inp ON (
        vt.REC_PERIODO = tra_inp.REC_PERIODO
        AND vt.CON_RUT = tra_inp.CON_RUT
        AND vt.CON_CORREL = tra_inp.CON_CORREL
        AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
        AND vt.SUC_COD = tra_inp.SUC_CODIGO
        AND vt.USU_CODIGO = tra_inp.USU_CODIGO
        AND vt.TRA_RUT = tra_inp.TRA_RUT
    )
    INNER JOIN INP ON (
        vt.PREVISION = inp.ENT_CODIFICACION
        AND tra_inp.ENT_RUT = inp.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización Fonasa
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'B', tra_inp.ENT_RUT, isapres.ENT_NOM, vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMPO_INP  
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMPO_INP   
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END,
        tra_inp.INP_COT_FONASA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAINP tra_inp ON (
        vt.REC_PERIODO = tra_inp.REC_PERIODO
        AND vt.CON_RUT = tra_inp.CON_RUT
        AND vt.CON_CORREL = tra_inp.CON_CORREL
        AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
        AND vt.SUC_COD = tra_inp.SUC_CODIGO
        AND vt.USU_CODIGO = tra_inp.USU_CODIGO
        AND vt.TRA_RUT = tra_inp.TRA_RUT
    )
    INNER JOIN ISAPRES ON (
        vt.SALUD = isapres.ENT_CODIFICACION
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización ISL
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'B', tra_inp.ENT_RUT, 'I.S.L.', vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMPO_INP  
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMPO_INP   
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END,
        tra_inp.INP_COT_ACC_TRAB, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAINP tra_inp ON (
        vt.REC_PERIODO = tra_inp.REC_PERIODO
        AND vt.CON_RUT = tra_inp.CON_RUT
        AND vt.CON_CORREL = tra_inp.CON_CORREL
        AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
        AND vt.SUC_COD = tra_inp.SUC_CODIGO
        AND vt.USU_CODIGO = tra_inp.USU_CODIGO
        AND vt.TRA_RUT = tra_inp.TRA_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND tra_inp.INP_COT_ACC_TRAB > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización en Isapre
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'B', isapres.ENT_RUT,
        CASE 
            WHEN (isapres.ENT_RUT = 96504160) AND ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2014 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7) 
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2014)) 
            THEN 'FERROSALUD S.A.'
            ELSE isapres.ENT_NOM 
        END,
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMPO_ISA  
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMPO_INP   
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END,
        tra_isapre.ISA_COT_APAGAR, vt.FEC_PAGO, NULL, vt.RAZ_SOC, vt.TRA_ISA_DEST, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAISA tra_isapre ON (
        vt.REC_PERIODO = tra_isapre.REC_PERIODO
        AND vt.CON_RUT = tra_isapre.CON_RUT
        AND vt.CON_CORREL = tra_isapre.CON_CORREL
        AND vt.NRO_COMPROBANTE = tra_isapre.NRO_COMPROBANTE
        AND vt.SUC_COD = tra_isapre.SUC_CODIGO
        AND vt.USU_CODIGO = tra_isapre.USU_CODIGO
        AND vt.TRA_RUT = tra_isapre.TRA_RUT
    )
    INNER JOIN ISAPRES ON (
        vt.SALUD = isapres.ENT_CODIFICACION
        AND tra_isapre.ENT_RUT = isapres.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.SALUD > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización en CCAF
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'C', cajas.ENT_RUT,
        CASE 
            WHEN cajas.ENT_CODIFICACION = 1 THEN 'LOS ANDES 0.6%'   
            WHEN cajas.ENT_CODIFICACION = 2 THEN 'LOS HEROES 0.6%'   
            WHEN cajas.ENT_CODIFICACION = 3 THEN 'LA ARAUCANA 0.6%'   
            WHEN cajas.ENT_CODIFICACION = 4 THEN 'GABRIELA M.  0.6%'   
            WHEN cajas.ENT_CODIFICACION = 5 THEN 'JAVIERA C.  0.6%'   
            WHEN cajas.ENT_CODIFICACION = 6 THEN '18 SEP.  0.6%'   
            ELSE ''
        END,
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMPO_CCAF  
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMPO_INP   
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END,
        tra_ccaf.TRACCAF_SALUD, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN TRA_CCAF tra_ccaf ON (
        vt.REC_PERIODO = tra_ccaf.REC_PERIODO
        AND vt.CON_RUT = tra_ccaf.CON_RUT
        AND vt.CON_CORREL = tra_ccaf.CON_CORREL
        AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
        AND vt.SUC_COD = tra_ccaf.SUC_COD
        AND vt.USU_CODIGO = tra_ccaf.USR_COD
        AND vt.TRA_RUT = tra_ccaf.TRA_RUT
    )
    INNER JOIN CAJAS ON (
        vt.CCAF_ADH = cajas.ENT_CODIFICACION
        AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Seguro de cesantía
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'D', afps.ENT_RUT, 'SEG. CES.', vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE,
        vt.DIAS_TRAB, vt.REM_IMPO_FC, trab_afp.AFP_FONDO_CESANTIA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        trab_afp.ENT_RUT = afps.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.REM_IMPO_FC >= 0 
      AND vt.REM_IMPO_FC IS NOT NULL
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización AFP - Trabajo pesado
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'E', afps.ENT_RUT, 'TRAB.PES. ' || SUBSTR(TRIM(afps.ENT_NOM), 1, 20),
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB, vt.REM_IMPO,
        trab_afp.AFP_MTO_TRA_PESADO, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.PREVISION = afps.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = afps.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 4
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización Accidente del trabajo
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT DISTINCT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'F', iat.ENT_RUT,
        CASE iat.ENT_CODIFICACION
            WHEN 4 THEN 'IST' 
            WHEN 2 THEN 'MUTUAL DE SEGURIDAD'
            WHEN 3 THEN 'ACHS'
        END,
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
            THEN vt.REM_IMPO_MUTUAL  
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMPO_INP   
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END,
        CASE 
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11 AND vt.EMP_MULTI_MUTUAL = 0)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014 AND vt.EMP_MULTI_MUTUAL = 0)
            THEN (vt.REM_IMPO_MUTUAL * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100   
            WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11 AND vt.EMP_MULTI_MUTUAL = 1)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014 AND vt.EMP_MULTI_MUTUAL = 1)
            THEN (vt.REM_IMPO_MUTUAL * (TOTAL_MUTUAL.TSUC_TASA_COT_MUT + TOTAL_MUTUAL.TSUC_COTADIC_MUT)) / 100   
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN (vt.REM_IMPO_INP * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100  
            WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
            THEN (vt.REM_IMP_AFP * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100 
            ELSE (vt.REM_IMPO * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100
        END,
        vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TOTALSUC TOTAL_MUTUAL ON (
        vt.REC_PERIODO = TOTAL_MUTUAL.REC_PERIODO 
        AND vt.CON_RUT = TOTAL_MUTUAL.CON_RUT 
        AND vt.CON_CORREL = TOTAL_MUTUAL.CON_CORREL 
        AND vt.RPR_PROCESO = TOTAL_MUTUAL.RPR_PROCESO 
        AND vt.NRO_COMPROBANTE = TOTAL_MUTUAL.NRO_COMPROBANTE 
    )
    INNER JOIN INST_ACC_TRAB iat ON (
        vt.MUT_ADH = iat.ENT_CODIFICACION
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.MUT_ADH > 0 
      AND (TOTAL_MUTUAL.TSUC_NUMTRAB > 0 OR TOTAL_MUTUAL.TSUC_REM_IMPONIBLE > 0 OR TOTAL_MUTUAL.TSUC_TOT_COTIZACION > 0)
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización APV - Entidades AFP
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'G', afps.ENT_RUT, SUBSTR(TRIM(afps.ENT_NOM), 1, 20) || ' (APV)',
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB, vt.REM_IMPO_DEPCONV,
        trab_afp.AFP_COT_VOLUNTARIA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.TRA_INS_APV = afps.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = afps.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 3
      AND vt.TRA_RUT = P_RUT_TRA
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cotización APV - Entidades <> a las AFP
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'G', entidad_previsional.ENT_RUT, SUBSTR(TRIM(entidad_previsional.ENT_NOM), 1, 19) || ' (APV)',
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB, vt.REM_IMPO_DEPCONV,
        tra_apv.TAPV_COT_VOLUNTARIA, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TOTALAPV tra_apv ON (
        vt.REC_PERIODO = tra_apv.REC_PERIODO
        AND vt.CON_RUT = tra_apv.CON_RUT
        AND vt.CON_CORREL = tra_apv.CON_CORREL
        AND vt.NRO_COMPROBANTE = tra_apv.NRO_COMPROBANTE
        AND vt.SUC_COD = tra_apv.SUC_CODIGO
        AND vt.USU_CODIGO = tra_apv.USU_CODIGO
        AND vt.TRA_RUT = tra_apv.TRA_RUT
    )
    INNER JOIN ENTIDAD_PREVISIONAL ON (
        vt.TRA_INS_APV = entidad_previsional.ENT_CODIFICACION
        AND tra_apv.ENT_RUT = entidad_previsional.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 3
      AND vt.TRA_RUT = P_RUT_TRA
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Conceptos CCAF adicionales si P_PARAMETRO3 = '1'
    --------------------------------------------------------------------------
    IF P_PARAMETRO3 IS NOT NULL AND P_PARAMETRO3 = '1' THEN
        -- Créditos CCAF
        INSERT INTO TMP_CERT_DETALLE (
            REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
            TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
            DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
        )
        SELECT
            vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
            'I', cajas.ENT_RUT,
            CASE 
                WHEN cajas.ENT_CODIFICACION = 1 THEN 'LOS ANDES CREDITOS'   
                WHEN cajas.ENT_CODIFICACION = 2 THEN 'LOS HEROES CREDITOS'   
                WHEN cajas.ENT_CODIFICACION = 3 THEN 'LA ARAUCANA CREDITOS'   
                WHEN cajas.ENT_CODIFICACION = 4 THEN 'GABRIELA M. CREDITOS'   
                WHEN cajas.ENT_CODIFICACION = 5 THEN 'JAVIERA C. CREDITOS'   
                WHEN cajas.ENT_CODIFICACION = 6 THEN '18 SEP. CREDITOS'   
                ELSE ''
            END,
            vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
            CASE 
                WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                     OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
                THEN vt.REM_IMPO_CCAF  
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMPO_INP   
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMP_AFP   
                ELSE vt.REM_IMPO
            END,
            tra_ccaf.TRACCAF_MTO_CRED, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
        FROM TMP_VIR_TRA vt
        INNER JOIN TRA_CCAF tra_ccaf ON (
            vt.REC_PERIODO = tra_ccaf.REC_PERIODO
            AND vt.CON_RUT = tra_ccaf.CON_RUT
            AND vt.CON_CORREL = tra_ccaf.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_ccaf.SUC_COD
            AND vt.USU_CODIGO = tra_ccaf.USR_COD
            AND vt.TRA_RUT = tra_ccaf.TRA_RUT
        )
        INNER JOIN CAJAS ON (
            vt.CCAF_ADH = cajas.ENT_CODIFICACION
            AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
        )
        WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
          AND vt.CON_RUT = P_EMP_RUT
          AND vt.CON_CORREL = P_CONVENIO
          AND vt.RPR_PROCESO = 1
          AND vt.TRA_RUT = P_RUT_TRA
          AND tra_ccaf.TRACCAF_MTO_CRED > 0
        ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

        -- Ahorro CCAF
        INSERT INTO TMP_CERT_DETALLE (
            REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
            TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
            DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
        )
        SELECT
            vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
            'I', cajas.ENT_RUT,
            CASE 
                WHEN cajas.ENT_CODIFICACION = 1 THEN 'LOS ANDES AHORRO'   
                WHEN cajas.ENT_CODIFICACION = 2 THEN 'LOS HEROES AHORRO'   
                WHEN cajas.ENT_CODIFICACION = 3 THEN 'LA ARAUCANA AHORRO'   
                WHEN cajas.ENT_CODIFICACION = 4 THEN 'GABRIELA M. AHORRO'   
                WHEN cajas.ENT_CODIFICACION = 5 THEN 'JAVIERA C. AHORRO'   
                WHEN cajas.ENT_CODIFICACION = 6 THEN '18 SEP. AHORRO'   
                ELSE ''
            END,
            vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
            CASE 
                WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                     OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
                THEN vt.REM_IMPO_CCAF 
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMPO_INP   
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMP_AFP   
                ELSE vt.REM_IMPO
            END,
            tra_ccaf.TRACCAF_MTO_LEAS, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
        FROM TMP_VIR_TRA vt
        INNER JOIN TRA_CCAF tra_ccaf ON (
            vt.REC_PERIODO = tra_ccaf.REC_PERIODO
            AND vt.CON_RUT = tra_ccaf.CON_RUT
            AND vt.CON_CORREL = tra_ccaf.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_ccaf.SUC_COD
            AND vt.USU_CODIGO = tra_ccaf.USR_COD
            AND vt.TRA_RUT = tra_ccaf.TRA_RUT
        )
        INNER JOIN CAJAS ON (
            vt.CCAF_ADH = cajas.ENT_CODIFICACION
            AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
        )
        WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
          AND vt.CON_RUT = P_EMP_RUT
          AND vt.CON_CORREL = P_CONVENIO
          AND vt.RPR_PROCESO = 1
          AND vt.TRA_RUT = P_RUT_TRA
          AND tra_ccaf.TRACCAF_MTO_LEAS > 0
        ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

        -- Seguro de Vida CCAF
        INSERT INTO TMP_CERT_DETALLE (
            REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
            TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
            DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
        )
        SELECT
            vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
            'I', cajas.ENT_RUT,
            CASE 
                WHEN cajas.ENT_CODIFICACION = 1 THEN 'LOS ANDES SEG. VIDA'   
                WHEN cajas.ENT_CODIFICACION = 2 THEN 'LOS HEROES SEG. VIDA'   
                WHEN cajas.ENT_CODIFICACION = 3 THEN 'LA ARAUCANA SEG. VIDA'   
                WHEN cajas.ENT_CODIFICACION = 4 THEN 'GABRIELA M. SEG. VIDA'   
                WHEN cajas.ENT_CODIFICACION = 5 THEN 'JAVIERA C. SEG. VIDA'   
                WHEN cajas.ENT_CODIFICACION = 6 THEN '18 SEP. SEG. VIDA'   
                ELSE ''
            END,
            vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
            CASE 
                WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                     OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
                THEN vt.REM_IMPO_CCAF 
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMPO_INP   
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMP_AFP   
                ELSE vt.REM_IMPO
            END,
            tra_ccaf.TRACCAF_MTO_SEG, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
        FROM TMP_VIR_TRA vt
        INNER JOIN TRA_CCAF tra_ccaf ON (
            vt.REC_PERIODO = tra_ccaf.REC_PERIODO
            AND vt.CON_RUT = tra_ccaf.CON_RUT
            AND vt.CON_CORREL = tra_ccaf.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_ccaf.SUC_COD
            AND vt.USU_CODIGO = tra_ccaf.USR_COD
            AND vt.TRA_RUT = tra_ccaf.TRA_RUT
        )
        INNER JOIN CAJAS ON (
            vt.CCAF_ADH = cajas.ENT_CODIFICACION
            AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
        )
        WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
          AND vt.CON_RUT = P_EMP_RUT
          AND vt.CON_CORREL = P_CONVENIO
          AND vt.RPR_PROCESO = 1
          AND vt.TRA_RUT = P_RUT_TRA
          AND tra_ccaf.TRACCAF_MTO_SEG > 0
        ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

        -- Completar la sección de Servicios Legales Prepagados CCAF
        INSERT INTO TMP_CERT_DETALLE (
            REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
            TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
            DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
        )
        SELECT
            vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
            'I', cajas.ENT_RUT,
            CASE 
                WHEN cajas.ENT_CODIFICACION = 1 THEN 'LOS ANDES SERV.LEG.PREPAG.'   
                WHEN cajas.ENT_CODIFICACION = 2 THEN 'LOS HEROES SERV.LEG.PREPAG.'   
                WHEN cajas.ENT_CODIFICACION = 3 THEN 'LA ARAUCANA SERV.LEG.PREPAG.'   
                WHEN cajas.ENT_CODIFICACION = 4 THEN 'GABRIELA M. SERV.LEG.PREPAG.'   
                WHEN cajas.ENT_CODIFICACION = 5 THEN 'JAVIERA C. SERV.LEG.PREPAG.'   
                WHEN cajas.ENT_CODIFICACION = 6 THEN '18 SEP. SERV.LEG.PREPAG.'   
                ELSE ''
            END,
            vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB,
            CASE 
                WHEN (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                     OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014)
                THEN vt.REM_IMPO_CCAF 
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION = 0 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMPO_INP   
                WHEN vt.RPR_PROCESO = 1 AND vt.PREVISION <> 90 AND vt.PREVISION <> 0 AND vt.PREVISION IS NOT NULL AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010
                THEN vt.REM_IMP_AFP   
                ELSE vt.REM_IMPO
            END,
            tra_ccaf.TRACCAF_MTO_OTRO, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
        FROM TMP_VIR_TRA vt
        INNER JOIN TRA_CCAF tra_ccaf ON (
            vt.REC_PERIODO = tra_ccaf.REC_PERIODO
            AND vt.CON_RUT = tra_ccaf.CON_RUT
            AND vt.CON_CORREL = tra_ccaf.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_ccaf.SUC_COD
            AND vt.USU_CODIGO = tra_ccaf.USR_COD
            AND vt.TRA_RUT = tra_ccaf.TRA_RUT
        )
        INNER JOIN CAJAS ON (
            vt.CCAF_ADH = cajas.ENT_CODIFICACION
            AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
        )
        WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
          AND vt.CON_RUT = P_EMP_RUT
          AND vt.CON_CORREL = P_CONVENIO
          AND vt.RPR_PROCESO = 1
          AND vt.TRA_RUT = P_RUT_TRA
          AND tra_ccaf.TRACCAF_MTO_OTRO > 0
        ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;
    END IF;

    --------------------------------------------------------------------------
    -- Cuenta Ahorro Previsional AFP: Remuneraciones antes de Julio 2009
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'J', afps.ENT_RUT, 'CTA.AHO.PREV. ' || SUBSTR(TRIM(afps.ENT_NOM), 1, 20),
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB, vt.REM_IMPO,
        trab_afp.AFP_CTAAHO, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.PREVISION = afps.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = afps.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION > 0 
      AND trab_afp.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cuenta Ahorro Previsional AFP: Remuneraciones Después de Julio 2009
    --------------------------------------------------------------------------
    INSERT INTO TMP_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA, RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT
        vt.REC_PERIODO, vt.NRO_COMPROBANTE, vt.TIPO_IMPRE, vt.SUC_COD, vt.USU_CODIGO,
        'J', afps.ENT_RUT, 'CTA.AHO.PREV. ' || SUBSTR(TRIM(afps.ENT_NOM), 1, 20),
        vt.TRA_RUT, vt.TRA_DIG, vt.TRA_NOMBRE, vt.TRA_APE, vt.DIAS_TRAB, vt.REM_IMP_AFP,
        trab_afp.AFP_CTAAHO, vt.FEC_PAGO, NULL, vt.RAZ_SOC, NULL, 0
    FROM TMP_VIR_TRA vt
    INNER JOIN REC_TRAAFP trab_afp ON (
        vt.REC_PERIODO = trab_afp.REC_PERIODO
        AND vt.CON_RUT = trab_afp.CON_RUT
        AND vt.CON_CORREL = trab_afp.CON_CORREL
        AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
        AND vt.SUC_COD = trab_afp.SUC_CODIGO
        AND vt.USU_CODIGO = trab_afp.USU_CODIGO
        AND vt.TRA_RUT = trab_afp.TRA_RUT
    )
    INNER JOIN AFPS ON (
        vt.PREVISION = afps.ENT_CODIFICACION
        AND trab_afp.ENT_RUT = afps.ENT_RUT
    )
    WHERE vt.REC_PERIODO BETWEEN P_FEC_INI AND P_FEC_TER
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
      AND vt.CON_RUT = P_EMP_RUT
      AND vt.CON_CORREL = P_CONVENIO
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = P_RUT_TRA
      AND vt.PREVISION > 0 
      AND trab_afp.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    --------------------------------------------------------------------------
    -- Cursor para insertar en TMP_PLANILLA
    --------------------------------------------------------------------------
    FOR TRA_ROW IN TRA_CURSOR LOOP
        IF TRA_ROW.TIPO_IMPRE IN (0,1,2) THEN
            INSERT INTO TMP_PLANILLA
            SELECT vt.REC_PERIODO, vt.NRO_COMPROBANTE, p.ENT_RUT, p.PLA_NRO_SERIE, vt.SUC_COD, vt.USU_COD
            FROM REC_PLANILLA p
            INNER JOIN TMP_CERT_DETALLE vt ON
                p.REC_PERIODO = vt.REC_PERIODO
                AND p.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                AND p.ENT_RUT = vt.ENT_RUT
                AND p.SUC_CODIGO = vt.SUC_COD
                AND p.USU_CODIGO = vt.USU_COD
            WHERE vt.REC_PERIODO = TRA_ROW.REC_PERIODO
              AND vt.TIPO_IMPRE = TRA_ROW.TIPO_IMPRE
              AND vt.NRO_COMPROBANTE = TRA_ROW.NRO_COMPROBANTE
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
        ELSIF TRA_ROW.TIPO_IMPRE = 3 THEN
            INSERT INTO TMP_PLANILLA
            SELECT vt.REC_PERIODO, vt.NRO_COMPROBANTE, p.ENT_RUT, p.PLA_NRO_SERIE, vt.SUC_COD, vt.USU_COD
            FROM REC_PLANILLA p
            INNER JOIN TMP_CERT_DETALLE vt ON
                p.REC_PERIODO = vt.REC_PERIODO
                AND p.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                AND p.SUC_CODIGO = vt.SUC_COD
                AND p.ENT_RUT = vt.ENT_RUT
                AND p.USU_CODIGO = vt.USU_COD
            WHERE vt.REC_PERIODO = TRA_ROW.REC_PERIODO
              AND vt.TIPO_IMPRE = TRA_ROW.TIPO_IMPRE
              AND vt.NRO_COMPROBANTE = TRA_ROW.NRO_COMPROBANTE
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
        ELSIF TRA_ROW.TIPO_IMPRE = 4 THEN
            INSERT INTO TMP_PLANILLA
            SELECT vt.REC_PERIODO, vt.NRO_COMPROBANTE, p.ENT_RUT, p.PLA_NRO_SERIE, vt.SUC_COD, vt.USU_COD
            FROM REC_PLANILLA p
            INNER JOIN TMP_CERT_DETALLE vt ON
                p.REC_PERIODO = vt.REC_PERIODO
                AND p.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                AND p.USU_CODIGO = vt.USU_COD
                AND p.ENT_RUT = vt.ENT_RUT
                AND p.SUC_CODIGO = vt.SUC_COD
            WHERE vt.REC_PERIODO = TRA_ROW.REC_PERIODO
              AND vt.TIPO_IMPRE = TRA_ROW.TIPO_IMPRE
              AND vt.NRO_COMPROBANTE = TRA_ROW.NRO_COMPROBANTE
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
        END IF;
    END LOOP;

    --------------------------------------------------------------------------
    -- Actualiza folio_planilla en TMP_CERT_DETALLE
    --------------------------------------------------------------------------
    UPDATE TMP_CERT_DETALLE cd
    SET FOLIO_PLANILLA = (
        SELECT PLA_NRO_SERIE
        FROM TMP_PLANILLA p
        WHERE p.REC_PERIODO = cd.REC_PERIODO
          AND p.NRO_COMPROBANTE = cd.NRO_COMPROBANTE
          AND p.ENT_RUT = cd.ENT_RUT
          AND p.SUC_COD = cd.SUC_COD
          AND p.USU_COD = cd.USU_COD
    )
    WHERE EXISTS (
        SELECT 1
        FROM TMP_PLANILLA p
        WHERE p.REC_PERIODO = cd.REC_PERIODO
          AND p.NRO_COMPROBANTE = cd.NRO_COMPROBANTE
          AND p.ENT_RUT = cd.ENT_RUT
          AND p.SUC_COD = cd.SUC_COD
          AND p.USU_COD = cd.USU_COD
    );

    --------------------------------------------------------------------------
    -- Retorna resultados
    --------------------------------------------------------------------------
    OPEN cursor_result FOR
    SELECT * FROM TMP_CERT_DETALLE 
    ORDER BY REC_PERIODO, SUC_COD, USU_COD, TIPO_ENT;

    COMMIT;
END SP_CERTCOT_TRAB20;