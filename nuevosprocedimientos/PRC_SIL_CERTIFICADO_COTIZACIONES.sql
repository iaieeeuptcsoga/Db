-- ===================================================================================
-- SCRIPT 2: PROCEDIMIENTOS ALMACENADOS
-- ===================================================================================
-- Migración de CertificadoCotPrev_SIL.asp - Procedimientos principales
-- Autor: Migración desde ASP VBScript
-- Fecha: 2025-01-07
-- ===================================================================================

-- 1. PROCEDIMIENTO AUXILIAR PARA DETERMINAR ÚLTIMOS 12 MESES
-- Equivalente a sub ult12() del ASP
CREATE OR REPLACE PROCEDURE PRC_SIL_DETERMINA_PERIODO_12M(
    p_rut_trabajador IN NUMBER,
    p_fecha_desde OUT VARCHAR2,
    p_fecha_hasta OUT VARCHAR2
)
IS
    v_fecha_min DATE;
    v_fecha_max DATE;
BEGIN
    -- Buscar el rango de períodos de los últimos 12 meses para el trabajador
    -- Equivalente a sp_determinaPeriodo del SQL Server
    SELECT MIN(rec_periodo), MAX(rec_periodo)
    INTO v_fecha_min, v_fecha_max
    FROM (
        SELECT DISTINCT rec_periodo
        FROM REC_TRABAJADOR
        WHERE tra_rut = p_rut_trabajador
          AND rec_periodo >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -12)
        ORDER BY rec_periodo DESC
        FETCH FIRST 12 ROWS ONLY
    );
    
    IF v_fecha_min IS NOT NULL AND v_fecha_max IS NOT NULL THEN
        p_fecha_desde := TO_CHAR(v_fecha_min, 'YYYY-MM-DD');
        p_fecha_hasta := TO_CHAR(v_fecha_max, 'YYYY-MM-DD');
    ELSE
        p_fecha_desde := NULL;
        p_fecha_hasta := NULL;
    END IF;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_fecha_desde := NULL;
        p_fecha_hasta := NULL;
    WHEN OTHERS THEN
        p_fecha_desde := NULL;
        p_fecha_hasta := NULL;
END PRC_SIL_DETERMINA_PERIODO_12M;
/

-- 2. PROCEDIMIENTO PRINCIPAL - MIGRACIÓN DEL ASP
-- Equivalente a CertificadoCotPrev_SIL.asp
CREATE OR REPLACE PROCEDURE PRC_SIL_CERTIFICADO_COTIZACIONES(
    p_rut_trabajador IN NUMBER,
    p_cnv_cta IN NUMBER,
    p_sel_operacion IN NUMBER,
    p_anio IN NUMBER,
    p_mes IN NUMBER DEFAULT 0,
    p_anio_hasta IN NUMBER DEFAULT 0,
    p_mes_hasta IN NUMBER DEFAULT 0,
    p_imp_ccaf IN NUMBER DEFAULT 0,
    p_emp_rut IN NUMBER,
    p_rut_representante IN NUMBER,
    p_cod_perfil IN VARCHAR2,
    p_datos_trabajador OUT SYS_REFCURSOR,
    p_datos_cotizaciones OUT SYS_REFCURSOR,
    p_resultado OUT NUMBER,
    p_mensaje OUT VARCHAR2
)
IS
    v_per_desde VARCHAR2(20);
    v_per_hasta VARCHAR2(20);
    v_fecha_desde DATE;
    v_fecha_hasta DATE;
    v_acceso_valido NUMBER;
    v_count_datos NUMBER;
    v_fecha_actual VARCHAR2(8);
    
BEGIN
    -- Inicializar variables
    p_resultado := 0;
    p_mensaje := '';
    
    -- Obtener fecha actual para auditoría (equivalente a VOS20110606)
    v_fecha_actual := TO_CHAR(SYSDATE, 'YYYYMMDD');
    
    -- Validar acceso por sucursal (equivalente a lógica CRIT_SUC)
    v_acceso_valido := FNC_SIL_VALIDA_ACCESO_SUCURSAL(
        p_emp_rut, 
        p_cnv_cta, 
        p_rut_representante, 
        p_cod_perfil
    );
    
    IF v_acceso_valido = 0 THEN
        p_resultado := -1;
        p_mensaje := 'El usuario no tiene acceso a esta empresa/convenio';
        RETURN;
    END IF;
    
    -- Determinar períodos según tipo de operación (equivalente a select case selOp)
    CASE p_sel_operacion
        WHEN 1 THEN -- Año específico
            v_per_desde := p_anio || '-01-01';  -- Corregido: enero inicia en 01, no 31
            v_per_hasta := p_anio || '-12-31';
            
        WHEN 2 THEN -- Últimos 12 meses
            PRC_SIL_DETERMINA_PERIODO_12M(p_rut_trabajador, v_per_desde, v_per_hasta);
            IF v_per_desde IS NULL OR v_per_hasta IS NULL THEN
                p_resultado := -4;
                p_mensaje := 'No se encontraron períodos para los últimos 12 meses';
                RETURN;
            END IF;
            
        WHEN 4 THEN -- Mes específico
            DECLARE
                v_ultimo_dia NUMBER;
            BEGIN
                -- Validar que el mes sea válido cuando se requiere
                IF p_mes = 0 OR p_mes IS NULL OR p_mes < 1 OR p_mes > 12 THEN
                    p_resultado := -5;
                    p_mensaje := 'Mes no válido para operación tipo 4';
                    RETURN;
                END IF;
                
                v_ultimo_dia := FNC_SIL_ULTIMO_DIA_MES(p_mes, p_anio);
                v_per_desde := p_anio || '-' || LPAD(p_mes, 2, '0') || '-01';  -- Desde el primer día del mes
                v_per_hasta := p_anio || '-' || LPAD(p_mes, 2, '0') || '-' || LPAD(v_ultimo_dia, 2, '0');
            END;
            
        WHEN 5 THEN -- Rango personalizado
            DECLARE
                v_ultimo_dia_desde NUMBER;
                v_ultimo_dia_hasta NUMBER;
            BEGIN
                -- Validar parámetros para rango
                IF p_mes = 0 OR p_mes IS NULL OR p_mes < 1 OR p_mes > 12 OR
                   p_mes_hasta = 0 OR p_mes_hasta IS NULL OR p_mes_hasta < 1 OR p_mes_hasta > 12 OR
                   p_anio_hasta = 0 OR p_anio_hasta IS NULL THEN
                    p_resultado := -6;
                    p_mensaje := 'Parámetros de rango no válidos para operación tipo 5';
                    RETURN;
                END IF;
                
                v_ultimo_dia_desde := FNC_SIL_ULTIMO_DIA_MES(p_mes, p_anio);
                v_ultimo_dia_hasta := FNC_SIL_ULTIMO_DIA_MES(p_mes_hasta, p_anio_hasta);
                v_per_desde := p_anio || '-' || LPAD(p_mes, 2, '0') || '-01';  -- Desde el primer día del mes inicial
                v_per_hasta := p_anio_hasta || '-' || LPAD(p_mes_hasta, 2, '0') || '-' || LPAD(v_ultimo_dia_hasta, 2, '0');
            END;
            
        ELSE
            p_resultado := -2;
            p_mensaje := 'Tipo de operación no válido';
            RETURN;
    END CASE;
    
    -- Convertir strings de fecha a DATE
    v_fecha_desde := TO_DATE(v_per_desde, 'YYYY-MM-DD');
    v_fecha_hasta := TO_DATE(v_per_hasta, 'YYYY-MM-DD');
    
    -- Validar que existan datos (equivalente a verificación EOF/BOF del ASP)
    SELECT COUNT(*)
    INTO v_count_datos
    FROM REC_TRABAJADOR RT
    JOIN REC_EMPRESA RE ON RT.rec_periodo = RE.rec_periodo
                       AND RT.con_rut = RE.con_rut
                       AND RT.con_correl = RE.con_correl
                       AND RT.rpr_proceso = RE.rpr_proceso
                       AND RT.nro_comprobante = RE.nro_comprobante
    WHERE RE.con_rut = p_emp_rut
      AND RE.con_correl = p_cnv_cta
      AND RT.tra_rut = p_rut_trabajador
      AND RT.rec_periodo BETWEEN v_fecha_desde AND v_fecha_hasta;
    
    IF v_count_datos = 0 THEN
        p_resultado := -3;
        p_mensaje := 'La persona no está asociada a la empresa o no tiene cotizaciones en el período';
        RETURN;
    END IF;
    
    -- Cursor con datos del trabajador (equivalente a encabezado)
    OPEN p_datos_trabajador FOR
        SELECT DISTINCT
            RT.tra_rut,
            RT.TRA_DIGITO,
            RT.TRA_APETRA || ' ' || RT.TRA_NOMTRA AS nombre_completo,
            RE.emp_rut,
            RE.EMP_DIGITO,
            RE.EMP_RAZSOC,
            RE.EMP_DIRECC || ' ' || RE.EMP_NUMERO || 
            CASE WHEN RE.EMP_LOCAL IS NOT NULL THEN ' ' || RE.EMP_LOCAL ELSE '' END AS direccion_completa,
            RE.EMP_TELEFONO,
            RE.EMP_RUT_REPR,
            RE.EMP_DIGITO_REPR,
            RE.EMP_APE_REPR,
            RE.EMP_NOM_REPR,
            TO_CHAR(v_fecha_desde, 'DD/MM/YYYY') AS periodo_desde,
            TO_CHAR(v_fecha_hasta, 'DD/MM/YYYY') AS periodo_hasta,
            v_fecha_actual AS fecha_generacion
        FROM REC_TRABAJADOR RT
        JOIN REC_EMPRESA RE ON RT.rec_periodo = RE.rec_periodo
                           AND RT.con_rut = RE.con_rut
                           AND RT.con_correl = RE.con_correl
                           AND RT.rpr_proceso = RE.rpr_proceso
                           AND RT.nro_comprobante = RE.nro_comprobante
        WHERE RE.con_rut = p_emp_rut
          AND RE.con_correl = p_cnv_cta
          AND RT.tra_rut = p_rut_trabajador
          AND RT.rec_periodo BETWEEN v_fecha_desde AND v_fecha_hasta
          AND ROWNUM = 1;
    
    -- Cursor con datos de cotizaciones (equivalente a la lógica del bucle principal del ASP)
    -- Corregido para usar las tablas específicas de cada entidad
    OPEN p_datos_cotizaciones FOR
        SELECT 
            RT.rec_periodo,
            FNC_SIL_NOMBRE_MES(TO_NUMBER(TO_CHAR(RT.rec_periodo, 'MM')), 
                              TO_NUMBER(TO_CHAR(RT.rec_periodo, 'YYYY'))) AS mes_anio_periodo,
            
            -- Información de entidad (con lógica especial para casos históricos)
            CASE 
                -- Lógica especial para noviembre 2003 (ISAPRES discontinuadas)
                WHEN TO_CHAR(RT.rec_periodo, 'YYYY-MM') = '2003-11' 
                     AND RT.TRA_REG_SALUD IN (5, 20) THEN
                    CASE RT.TRA_REG_SALUD
                        WHEN 5 THEN 'CIGNA SALUD'
                        WHEN 20 THEN 'VIDA PLENA'
                        ELSE COALESCE(VCAJAS.ENT_NOMBRE, VAFP.ENT_NOMBRE, VISA.ENT_NOMBRE, VINP.ENT_NOMBRE)
                    END
                -- Lógica especial para SANTA MARIA (períodos anteriores a abril 2008)
                WHEN COALESCE(VCAJAS.ENT_RUT, VAFP.ENT_RUT, VISA.ENT_RUT, VINP.ENT_RUT) = 98000000 
                     AND RT.rec_periodo < TO_DATE('2008-04-01', 'YYYY-MM-DD')
                     AND COALESCE(VCAJAS.ENT_NOMBRE, VAFP.ENT_NOMBRE, VISA.ENT_NOMBRE, VINP.ENT_NOMBRE) != 'SEG. CES.' THEN
                    'SANTA MARIA'
                ELSE 
                    SUBSTR(NVL(COALESCE(VCAJAS.ENT_NOMBRE, VAFP.ENT_NOMBRE, VISA.ENT_NOMBRE, VINP.ENT_NOMBRE), 'SIN ENTIDAD'), 1, 26)
            END AS institucion_prevision,
            
            -- Fechas de subsidio
            FNC_SIL_FORMAT_FECHA(RT.tra_fecinisub) AS fecha_inicio_subsidio,
            FNC_SIL_FORMAT_FECHA(RT.tra_fectersub) AS fecha_termino_subsidio,
            
            -- Información laboral y financiera
            NVL(RT.tra_nro_dias_trab, 0) AS dias_trabajados,
            NVL(RT.TRA_REM_IMPONIBLE, 0) AS remuneracion_imponible,
            
            -- Monto cotizado según tipo de entidad
            COALESCE(
                CCAF.CCAF_SALUD,           -- Monto CCAF
                AFP.AFP_COT_OBLIGATORIA,   -- Monto AFP
                ISA.ISA_COT_OBLIGATORIA,   -- Monto ISAPRE
                INP.INP_COT_PREV,          -- Monto INP
                0
            ) AS monto_cotizado,
            
            -- Información de pago
            FNC_SIL_FORMAT_FECHA(RP.PAG_FECPAG) AS fecha_pago,
            RPL.pla_nro_serie AS folio_planilla,
            SUBSTR(NVL(RE.EMP_RAZSOC, ''), 1, 24) AS entidad_pagadora,
            
            -- Información adicional para ordenamiento
            CASE 
                WHEN CCAF.tra_rut IS NOT NULL THEN 'C'  -- CCAF
                WHEN AFP.tra_rut IS NOT NULL THEN 'A'   -- AFP
                WHEN ISA.tra_rut IS NOT NULL THEN 'B'   -- ISAPRE
                WHEN INP.tra_rut IS NOT NULL THEN 'I'   -- INP
                ELSE 'Z'
            END AS tipo_entidad,
            NVL(COALESCE(VCAJAS.ENT_RUT, VAFP.ENT_RUT, VISA.ENT_RUT, VINP.ENT_RUT), 0) AS ent_rut
            
        FROM REC_TRABAJADOR RT
        JOIN REC_EMPRESA RE ON RT.rec_periodo = RE.rec_periodo
                           AND RT.con_rut = RE.con_rut
                           AND RT.con_correl = RE.con_correl
                           AND RT.rpr_proceso = RE.rpr_proceso
                           AND RT.nro_comprobante = RE.nro_comprobante
        LEFT JOIN REC_PAGO RP ON RE.rec_periodo = RP.rec_periodo
                        AND RE.nro_comprobante = RP.nro_comprobante
                        AND RE.con_rut = RP.con_rut
                        AND RE.con_correl = RP.con_correl
                        AND RE.rpr_proceso = RP.rpr_proceso
        LEFT JOIN REC_PLANILLA RPL ON RT.rec_periodo = RPL.rec_periodo
                                  AND RT.nro_comprobante = RPL.nro_comprobante
        
        -- JOINs con tablas específicas de cada entidad
        LEFT JOIN REC_TRACCAF CCAF ON RT.rec_periodo = CCAF.rec_periodo
                     AND RT.con_rut = CCAF.con_rut
                     AND RT.con_correl = CCAF.con_correl
                     AND RT.tra_rut = CCAF.tra_rut
                     AND RT.SUC_CODIGO = CCAF.SUC_CODIGO
                     AND RT.rpr_proceso = CCAF.rpr_proceso
                     AND RT.nro_comprobante = CCAF.nro_comprobante
                     AND RT.usu_codigo = CCAF.USU_CODIGO
        
        LEFT JOIN REC_TRAAFP AFP ON RT.rec_periodo = AFP.rec_periodo
                     AND RT.con_rut = AFP.con_rut
                     AND RT.con_correl = AFP.con_correl
                     AND RT.tra_rut = AFP.tra_rut
                     AND RT.SUC_CODIGO = AFP.SUC_CODIGO
                     AND RT.rpr_proceso = AFP.rpr_proceso
                     AND RT.nro_comprobante = AFP.nro_comprobante
                     AND RT.usu_codigo = AFP.USU_CODIGO
        
        LEFT JOIN REC_TRAISA ISA ON RT.rec_periodo = ISA.rec_periodo
                     AND RT.con_rut = ISA.con_rut
                     AND RT.con_correl = ISA.con_correl
                     AND RT.tra_rut = ISA.tra_rut
                     AND RT.SUC_CODIGO = ISA.SUC_CODIGO
                     AND RT.rpr_proceso = ISA.rpr_proceso
                     AND RT.nro_comprobante = ISA.nro_comprobante
                     AND RT.usu_codigo = ISA.USU_CODIGO
        
        LEFT JOIN REC_TRAINP INP ON RT.rec_periodo = INP.rec_periodo
                     AND RT.con_rut = INP.con_rut
                     AND RT.con_correl = INP.con_correl
                     AND RT.tra_rut = INP.tra_rut
                     AND RT.SUC_CODIGO = INP.SUC_CODIGO
                     AND RT.rpr_proceso = INP.rpr_proceso
                     AND RT.nro_comprobante = INP.nro_comprobante
                     AND RT.usu_codigo = INP.USU_CODIGO
        
        -- JOINs con vistas para obtener nombres de entidades
        LEFT JOIN VIS_REC_CAJAS VCAJAS ON RT.TRA_CODIGO_CCAF = VCAJAS.ent_codificacion
        LEFT JOIN VIS_REC_AFPS VAFP ON RT.TRA_REG_PREVIS = VAFP.ent_codificacion  
        LEFT JOIN VIS_REC_ISAPRES VISA ON RT.TRA_REG_SALUD = VISA.ent_codificacion
        LEFT JOIN VIS_REC_INP VINP ON RT.TRA_REG_IMPOS = VINP.ent_codificacion
        
        WHERE RE.con_rut = p_emp_rut
          AND RE.con_correl = p_cnv_cta
          AND RT.tra_rut = p_rut_trabajador
          AND RT.rec_periodo BETWEEN v_fecha_desde AND v_fecha_hasta
          AND RT.TRA_REG_SALUD = 0  -- Solo trabajadores sin registro de salud especial
          -- Aplicar filtro de CCAF si es necesario
          AND (p_imp_ccaf = 0 OR (p_imp_ccaf = 1 AND CCAF.tra_rut IS NOT NULL))
        ORDER BY RT.rec_periodo, 
                 CASE 
                    WHEN CCAF.tra_rut IS NOT NULL THEN 'C'
                    WHEN AFP.tra_rut IS NOT NULL THEN 'A'
                    WHEN ISA.tra_rut IS NOT NULL THEN 'B'
                    WHEN INP.tra_rut IS NOT NULL THEN 'I'
                    ELSE 'Z'
                 END,
                 NVL(COALESCE(VCAJAS.ENT_NOMBRE, VAFP.ENT_NOMBRE, VISA.ENT_NOMBRE, VINP.ENT_NOMBRE), 'ZZZ');
    
    -- Actualizar contador de certificados generados (equivalente a VOS20110606)
    BEGIN
        INSERT INTO LOG_CERTIFICADOS_GENERADOS (
            fecha_generacion,
            rut_trabajador,
            rut_empresa,
            convenio,
            rut_representante,
            tipo_operacion,
            periodo_desde,
            periodo_hasta,
            fecha_creacion
        ) VALUES (
            v_fecha_actual,
            p_rut_trabajador,
            p_emp_rut,
            p_cnv_cta,
            NVL(p_rut_representante, 0),  -- Usar 0 si es null
            p_sel_operacion,
            v_per_desde,
            v_per_hasta,
            SYSDATE
        );
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- No fallar el proceso si no se puede registrar el log
            NULL;
    END;
    
    p_resultado := 1;
    p_mensaje := 'Certificado generado exitosamente';
    
EXCEPTION
    WHEN OTHERS THEN
        p_resultado := -99;
        p_mensaje := 'Error interno: ' || SQLERRM;
        
        -- Cerrar cursores si están abiertos
        IF p_datos_trabajador%ISOPEN THEN
            CLOSE p_datos_trabajador;
        END IF;
        
        IF p_datos_cotizaciones%ISOPEN THEN
            CLOSE p_datos_cotizaciones;
        END IF;
        
END PRC_SIL_CERTIFICADO_COTIZACIONES;
