CREATE OR REPLACE PROCEDURE PRC_REC_CERTCOT_TRAB (
    p_fec_ini       IN  DATE,
    p_fec_ter       IN  DATE,
    p_emp_rut       IN  NUMBER,
    p_convenio      IN  NUMBER,
    p_rut_tra       IN  NUMBER,
    p_tipoCon       IN  NUMBER,
    p_parametro     IN  VARCHAR2 DEFAULT NULL,
    p_parametro2    IN  VARCHAR2 DEFAULT NULL,
    p_parametro3    IN  VARCHAR2 DEFAULT NULL,
    p_cursor        OUT SYS_REFCURSOR
) IS

    -- Declaración de variables
    v_tipoImp       NUMBER(1);
    v_periodo       DATE;
    v_nomTra        VARCHAR2(40);
    v_apeTra        VARCHAR2(40);

BEGIN

    -- Limpiar tablas temporales al inicio
    DELETE FROM GTT_REC_VIR_TRA;
    DELETE FROM GTT_REC_VIR_TRA2;
    DELETE FROM GTT_REC_CERT_DETALLE;
    DELETE FROM GTT_REC_PLANILLA;
    DELETE FROM GTT_REC_SUCURSALES;

    -- Determinación de sucursales según tipo de consulta
    IF p_tipoCon = 2 THEN
        -- Consulta por impresión por sucursal
        -- Reemplazamos DET_CTA_USU por REC_TRACCAF
        INSERT INTO GTT_REC_SUCURSALES (COD_SUC)
        SELECT DISTINCT RTC.SUC_CODIGO 
        FROM REC_TRACCAF RTC
        WHERE RTC.CON_RUT = p_emp_rut 
          AND RTC.CON_CORREL = p_convenio 
          AND RTC.USU_CODIGO = p_parametro;
          
    ELSIF p_tipoCon = 3 THEN
        -- Consulta por impresión masiva por sucursal
        INSERT INTO GTT_REC_SUCURSALES (COD_SUC)
        VALUES (p_parametro);
    END IF;

    -- Obtiene los datos del trabajador
    IF p_convenio >= 600 AND p_convenio <= 699 THEN
        
        IF p_tipoCon = 1 THEN
            -- Consulta individual para convenios 600-699
            INSERT INTO GTT_REC_VIR_TRA2 (
                REC_PERIODO, CON_RUT, CON_CORREL, RPR_PROCESO, NRO_COMPROBANTE,
                SUC_COD, USU_CODIGO, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                REM_IMPO, REM_IMP_AFP, REM_IMPO_INP, REM_IMPO_FC, REM_IMPO_DEPCONV,
                DIAS_TRAB, PREVISION, SALUD, ENT_AFC, TIPO_IMPRE, FEC_PAGO,
                CCAF_ADH, MUT_ADH, TASA_COT_MUT, TASA_ADIC_MUT, RAZ_SOC,
                TRA_ISA_DEST, TRA_TIPO_APV, TRA_INS_APV, REM_IMPO_CCAF,
                REM_IMPO_ISA, REM_IMPO_MUTUAL, EMP_MULTI_CCAF, EMP_MULTI_MUTUAL
            )
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
                t.TRA_APETRA || ' ' || t.TRA_NOMTRA,
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
                p.PAG_FECPAG,
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
            FROM REC_EMPRESA e,
                 REC_SUCURSAL s,
                 REC_PAGO p,
                 REC_TRABAJADOR t
            WHERE e.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND e.CON_RUT = p_emp_rut
              AND e.CON_CORREL = p_convenio
              AND e.RPR_PROCESO IN (1,2,3,4)
              AND p.RET_ESTADO = 5 
              AND t.TRA_RUT = p_rut_tra
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
            -- Consulta por sucursal para convenios 600-699
            INSERT INTO GTT_REC_VIR_TRA2 (
                REC_PERIODO, CON_RUT, CON_CORREL, RPR_PROCESO, NRO_COMPROBANTE,
                SUC_COD, USU_CODIGO, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                REM_IMPO, REM_IMP_AFP, REM_IMPO_INP, REM_IMPO_FC, REM_IMPO_DEPCONV,
                DIAS_TRAB, PREVISION, SALUD, ENT_AFC, TIPO_IMPRE, FEC_PAGO,
                CCAF_ADH, MUT_ADH, TASA_COT_MUT, TASA_ADIC_MUT, RAZ_SOC,
                TRA_ISA_DEST, TRA_TIPO_APV, TRA_INS_APV, REM_IMPO_CCAF,
                REM_IMPO_ISA, REM_IMPO_MUTUAL, EMP_MULTI_CCAF, EMP_MULTI_MUTUAL
            )
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
                t.TRA_APETRA || ' ' || t.TRA_NOMTRA,
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
                p.PAG_FECPAG,
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
            FROM REC_EMPRESA e,
                 REC_SUCURSAL s,
                 REC_PAGO p,
                 REC_TRABAJADOR t
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
              AND e.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND e.CON_RUT = p_emp_rut
              AND e.CON_CORREL = p_convenio
              AND e.RPR_PROCESO IN (1,2,3,4)
              AND p.RET_ESTADO = 5
              AND t.TRA_RUT = p_rut_tra
              AND t.SUC_CODIGO IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES)
            ORDER BY t.REC_PERIODO, t.SUC_CODIGO, t.USU_CODIGO;

        END IF;

    ELSE
        -- Para otros convenios (no 600-699)
        IF p_tipoCon = 1 THEN
            -- Consulta individual para otros convenios
            INSERT INTO GTT_REC_VIR_TRA2 (
                REC_PERIODO, CON_RUT, CON_CORREL, RPR_PROCESO, NRO_COMPROBANTE,
                SUC_COD, USU_CODIGO, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                REM_IMPO, REM_IMP_AFP, REM_IMPO_INP, REM_IMPO_FC, REM_IMPO_DEPCONV,
                DIAS_TRAB, PREVISION, SALUD, ENT_AFC, TIPO_IMPRE, FEC_PAGO,
                CCAF_ADH, MUT_ADH, TASA_COT_MUT, TASA_ADIC_MUT, RAZ_SOC,
                TRA_ISA_DEST, TRA_TIPO_APV, TRA_INS_APV, REM_IMPO_CCAF,
                REM_IMPO_ISA, REM_IMPO_MUTUAL, EMP_MULTI_CCAF, EMP_MULTI_MUTUAL
            )
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
                t.TRA_APETRA || ' ' || t.TRA_NOMTRA,
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
                p.PAG_FECPAG,
                CASE 
                   WHEN (e.EMP_MULTICCAF IS NULL) OR (e.EMP_MULTICCAF = 0)
                        THEN e.EMP_CCAF_ADH  
                   WHEN (e.EMP_MULTICCAF = 1) 
                        THEN t.TRA_CCAF_ADH   
                   ELSE 0
                END AS emp_ccaf_adh,
                CASE 
                   WHEN (e.EMP_MULTIMUT IS NULL) OR (e.EMP_MULTIMUT = 0)
                        THEN e.EMP_MUTUAL_ADH  
                   WHEN (e.EMP_MULTIMUT = 1) 
                        THEN t.TRA_MUTUAL_ADH   
                   ELSE 0
                END AS emp_mut_adh,
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
            FROM REC_EMPRESA e,
                 REC_PAGO p,
                 REC_TRABAJADOR t
            WHERE e.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND e.CON_RUT = p_emp_rut
              AND e.CON_CORREL = p_convenio
              AND e.RPR_PROCESO IN (1,2,3,4)
              AND t.TRA_RUT = p_rut_tra
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
            -- Consulta por sucursal para otros convenios
            INSERT INTO GTT_REC_VIR_TRA2 (
                REC_PERIODO, CON_RUT, CON_CORREL, RPR_PROCESO, NRO_COMPROBANTE,
                SUC_COD, USU_CODIGO, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                REM_IMPO, REM_IMP_AFP, REM_IMPO_INP, REM_IMPO_FC, REM_IMPO_DEPCONV,
                DIAS_TRAB, PREVISION, SALUD, ENT_AFC, TIPO_IMPRE, FEC_PAGO,
                CCAF_ADH, MUT_ADH, TASA_COT_MUT, TASA_ADIC_MUT, RAZ_SOC,
                TRA_ISA_DEST, TRA_TIPO_APV, TRA_INS_APV, REM_IMPO_CCAF,
                REM_IMPO_ISA, REM_IMPO_MUTUAL, EMP_MULTI_CCAF, EMP_MULTI_MUTUAL
            )
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
                t.TRA_APETRA || ' ' || t.TRA_NOMTRA,
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
                p.PAG_FECPAG,
                CASE 
                   WHEN (e.EMP_MULTICCAF IS NULL) OR (e.EMP_MULTICCAF = 0)
                        THEN e.EMP_CCAF_ADH  
                   WHEN (e.EMP_MULTICCAF = 1) 
                        THEN t.TRA_CCAF_ADH   
                   ELSE 0
                END AS emp_ccaf_adh,
                CASE 
                   WHEN (e.EMP_MULTIMUT IS NULL) OR (e.EMP_MULTIMUT = 0)
                        THEN e.EMP_MUTUAL_ADH  
                   WHEN (e.EMP_MULTIMUT = 1) 
                        THEN t.TRA_MUTUAL_ADH   
                   ELSE 0
                END AS emp_mut_adh,
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
            FROM REC_EMPRESA e,
                 REC_PAGO p,
                 REC_TRABAJADOR t
            WHERE e.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND e.CON_RUT = p_emp_rut
              AND e.CON_CORREL = p_convenio
              AND e.RPR_PROCESO IN (1,2,3,4)
              AND t.TRA_RUT = p_rut_tra
              AND p.RET_ESTADO = 5
              AND t.SUC_CODIGO IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES)
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

    -- Si el tipo de consulta es > a 1, traspasa los datos a la tabla @vir_tra
    IF p_parametro2 IS NOT NULL THEN
        -- Cuando es agrupado por dato usuario
        INSERT INTO GTT_REC_VIR_TRA (
            REC_PERIODO, CON_RUT, CON_CORREL, RPR_PROCESO, NRO_COMPROBANTE,
            SUC_COD, USU_CODIGO, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
            REM_IMPO, REM_IMP_AFP, REM_IMPO_INP, REM_IMPO_FC, REM_IMPO_DEPCONV,
            DIAS_TRAB, PREVISION, SALUD, ENT_AFC, TIPO_IMPRE, FEC_PAGO,
            CCAF_ADH, MUT_ADH, TASA_COT_MUT, TASA_ADIC_MUT, RAZ_SOC,
            TRA_ISA_DEST, TRA_TIPO_APV, TRA_INS_APV, REM_IMPO_CCAF,
            REM_IMPO_ISA, REM_IMPO_MUTUAL, EMP_MULTI_CCAF, EMP_MULTI_MUTUAL
        )
        SELECT * 
        FROM GTT_REC_VIR_TRA2
        WHERE USU_CODIGO = p_parametro2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    ELSE
        -- Cuando es agrupado por sucursal
        INSERT INTO GTT_REC_VIR_TRA (
            REC_PERIODO, CON_RUT, CON_CORREL, RPR_PROCESO, NRO_COMPROBANTE,
            SUC_COD, USU_CODIGO, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
            REM_IMPO, REM_IMP_AFP, REM_IMPO_INP, REM_IMPO_FC, REM_IMPO_DEPCONV,
            DIAS_TRAB, PREVISION, SALUD, ENT_AFC, TIPO_IMPRE, FEC_PAGO,
            CCAF_ADH, MUT_ADH, TASA_COT_MUT, TASA_ADIC_MUT, RAZ_SOC,
            TRA_ISA_DEST, TRA_TIPO_APV, TRA_INS_APV, REM_IMPO_CCAF,
            REM_IMPO_ISA, REM_IMPO_MUTUAL, EMP_MULTI_CCAF, EMP_MULTI_MUTUAL
        )
        SELECT * 
        FROM GTT_REC_VIR_TRA2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    END IF;

    -- Obtiene el nombre del trabajador correspondiente al último periodo registrado
    BEGIN
        SELECT TRA_NOMBRE, TRA_APE
        INTO v_nomTra, v_apeTra
        FROM (
            SELECT LTRIM(RTRIM(TRA_NOMBRE)) AS TRA_NOMBRE, 
                   LTRIM(RTRIM(TRA_APE)) AS TRA_APE
            FROM GTT_REC_VIR_TRA
            ORDER BY REC_PERIODO DESC
        )
        WHERE ROWNUM = 1;
        
        -- Actualiza todos los registros con el nombre más reciente
        UPDATE GTT_REC_VIR_TRA
        SET TRA_NOMBRE = v_nomTra,
            TRA_APE = v_apeTra;
            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL; -- Si no hay datos, continúa sin error
    END;

    -- Cotización AFP: Gratificaciones
    -- Proceso específico para gratificaciones (RPR_PROCESO = 2)
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'A' AS TIPO_ENT,
        ep.ENT_RUT,
        ep.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
           WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                THEN vt.REM_IMP_AFP    
           ELSE vt.REM_IMPO
        END AS REM_IMPO,
        ta.AFP_COT_OBLIGATORIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(ta.AFP_SEG_INV_SOBRE, 0) AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 2
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP: Remuneraciones antes de Julio 2009
    -- Proceso para remuneraciones que lee del campo REM_IMPO para períodos menores a Julio 2009
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'A' AS TIPO_ENT,
        ep.ENT_RUT,
        ep.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        ta.AFP_COT_OBLIGATORIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(ta.AFP_SEG_INV_SOBRE, 0) AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009 
           OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP: Remuneraciones después de Julio 2009
    -- Proceso para remuneraciones que lee del campo REM_IMP_AFP para períodos mayores o iguales a Julio 2009
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'A' AS TIPO_ENT,
        ep.ENT_RUT,
        ep.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMP_AFP,
        ta.AFP_COT_OBLIGATORIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(ta.AFP_SEG_INV_SOBRE, 0) AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009 
           OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización INP
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'A' AS TIPO_ENT,
        ep.ENT_RUT,
        ep.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                 THEN vt.REM_IMPO_INP  
            WHEN vt.RPR_PROCESO = 1 
                 AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMPO_INP   
            ELSE vt.REM_IMPO
        END AS REM_IMPO,
        ti.INP_COT_PREV,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAINP ti ON 
            vt.REC_PERIODO = ti.REC_PERIODO
            AND vt.CON_RUT = ti.CON_RUT
            AND vt.CON_CORREL = ti.CON_CORREL
            AND vt.NRO_COMPROBANTE = ti.NRO_COMPROBANTE
            AND vt.SUC_COD = ti.SUC_CODIGO
            AND vt.USU_CODIGO = ti.USU_CODIGO
            AND vt.TRA_RUT = ti.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ti.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización FONASA
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'B' AS TIPO_ENT,
        ti.ENT_RUT,
        ep.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                 THEN vt.REM_IMPO_INP  
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION = 0  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMPO_INP   
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION <> 90
                 AND vt.PREVISION <> 0 
                 AND vt.PREVISION IS NOT NULL  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END AS REM_IMPO,
        ti.INP_COT_FONASA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAINP ti ON 
            vt.REC_PERIODO = ti.REC_PERIODO
            AND vt.CON_RUT = ti.CON_RUT
            AND vt.CON_CORREL = ti.CON_CORREL
            AND vt.NRO_COMPROBANTE = ti.NRO_COMPROBANTE
            AND vt.SUC_COD = ti.SUC_CODIGO
            AND vt.USU_CODIGO = ti.USU_CODIGO
            AND vt.TRA_RUT = ti.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.SALUD = ep.ENT_CODIFICACION
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización ISL (Instituto de Seguridad Laboral)
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'B' AS TIPO_ENT,
        ti.ENT_RUT,
        'I.S.L.' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                 THEN vt.REM_IMPO_INP  
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION = 0  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMPO_INP   
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION <> 90
                 AND vt.PREVISION <> 0 
                 AND vt.PREVISION IS NOT NULL  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END AS REM_IMPO,
        ti.INP_COT_ACC_TRAB,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAINP ti ON 
            vt.REC_PERIODO = ti.REC_PERIODO
            AND vt.CON_RUT = ti.CON_RUT
            AND vt.CON_CORREL = ti.CON_CORREL
            AND vt.NRO_COMPROBANTE = ti.NRO_COMPROBANTE
            AND vt.SUC_COD = ti.SUC_CODIGO
            AND vt.USU_CODIGO = ti.USU_CODIGO
            AND vt.TRA_RUT = ti.TRA_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND ti.INP_COT_ACC_TRAB > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización en ISAPRE
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'B' AS TIPO_ENT,
        ep.ENT_RUT,
        CASE 
            WHEN (ep.ENT_RUT = 96504160) AND ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2014 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7) 
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2014)) 
                 THEN 'FERROSALUD S.A.'
            ELSE ep.ENT_NOMBRE 
        END AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                 THEN vt.REM_IMPO_ISA  
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION = 0  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMPO_INP   
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION <> 90
                 AND vt.PREVISION <> 0 
                 AND vt.PREVISION IS NOT NULL  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END AS REM_IMPO,
        ti.ISA_COT_APAGAR,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        vt.TRA_ISA_DEST AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAISA ti ON 
            vt.REC_PERIODO = ti.REC_PERIODO
            AND vt.CON_RUT = ti.CON_RUT
            AND vt.CON_CORREL = ti.CON_CORREL
            AND vt.NRO_COMPROBANTE = ti.NRO_COMPROBANTE
            AND vt.SUC_COD = ti.SUC_CODIGO
            AND vt.USU_CODIGO = ti.USU_CODIGO
            AND vt.TRA_RUT = ti.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.SALUD = ep.ENT_CODIFICACION
            AND ti.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND vt.SALUD > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización en CCAF (Cajas de Compensación de Asignación Familiar)
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'C' AS TIPO_ENT,
        ep.ENT_RUT,
        CASE 
            WHEN ep.ENT_CODIFICACION = 1 
                THEN 'LOS ANDES 0.6%'   
            WHEN ep.ENT_CODIFICACION = 2 
                THEN 'LOS HEROES 0.6%'   
            WHEN ep.ENT_CODIFICACION = 3 
                THEN 'LA ARAUCANA 0.6%'   
            WHEN ep.ENT_CODIFICACION = 4 
                THEN 'GABRIELA M.  0.6%'   
            WHEN ep.ENT_CODIFICACION = 5 
                THEN 'JAVIERA C.  0.6%'   
            WHEN ep.ENT_CODIFICACION = 6 
                THEN '18 SEP.  0.6%'   
            ELSE ''
        END AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                 THEN vt.REM_IMPO_CCAF  
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION = 0  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMPO_INP   
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION <> 90
                 AND vt.PREVISION <> 0 
                 AND vt.PREVISION IS NOT NULL  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END AS REM_IMPO,
        tc.CCAF_SALUD,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRACCAF tc ON 
            vt.REC_PERIODO = tc.REC_PERIODO
            AND vt.CON_RUT = tc.CON_RUT
            AND vt.CON_CORREL = tc.CON_CORREL
            AND vt.NRO_COMPROBANTE = tc.NRO_COMPROBANTE
            AND vt.SUC_COD = tc.SUC_CODIGO
            AND vt.USU_CODIGO = tc.USU_CODIGO
            AND vt.TRA_RUT = tc.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.CCAF_ADH = ep.ENT_CODIFICACION
            AND tc.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Seguro de Cesantía
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'D' AS TIPO_ENT,
        ep.ENT_RUT,
        'SEG. CES.' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_FC,
        ta.AFP_FONDO_CESANTIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND vt.REM_IMPO_FC >= 0 
      AND vt.REM_IMPO_FC IS NOT NULL
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP - Trabajo Pesado
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'E' AS TIPO_ENT,
        ep.ENT_RUT,
        'TRAB.PES. ' || SUBSTR(LTRIM(RTRIM(ep.ENT_NOMBRE)), 1, 20) AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        ta.AFP_MTO_TRA_PESADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 4
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización Accidente del Trabajo
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT DISTINCT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'F' AS TIPO_ENT,
        ep.ENT_RUT,
        CASE ep.ENT_CODIFICACION
            WHEN 4 THEN 'IST' 
            WHEN 2 THEN 'MUTUAL DE SEGURIDAD'
            WHEN 3 THEN 'ACHS'
            ELSE ep.ENT_NOMBRE
        END AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                 THEN vt.REM_IMPO_MUTUAL  
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION = 0  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMPO_INP   
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION <> 90
                 AND vt.PREVISION <> 0 
                 AND vt.PREVISION IS NOT NULL  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN vt.REM_IMP_AFP   
            ELSE vt.REM_IMPO
        END AS REM_IMPO,
        CASE 
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11 AND vt.EMP_MULTI_MUTUAL = 0)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014 AND vt.EMP_MULTI_MUTUAL = 0))
                 THEN (vt.REM_IMPO_MUTUAL * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100   
            WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11 AND vt.EMP_MULTI_MUTUAL = 1)
                 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014 AND vt.EMP_MULTI_MUTUAL = 1))
                 THEN (vt.REM_IMPO_MUTUAL * (tm.TSUC_TASA_COT_MUT + tm.TSUC_COTADIC_MUT)) / 100   
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION = 0  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN (vt.REM_IMPO_INP * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100  
            WHEN (vt.RPR_PROCESO = 1 
                 AND vt.PREVISION <> 90
                 AND vt.PREVISION <> 0 
                 AND vt.PREVISION IS NOT NULL  
                 AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                 THEN (vt.REM_IMP_AFP * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100 
            ELSE (vt.REM_IMPO * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100
        END AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TOTALSUC tm ON 
            vt.REC_PERIODO = tm.REC_PERIODO 
            AND vt.CON_RUT = tm.CON_RUT 
            AND vt.CON_CORREL = tm.CON_CORREL 
            AND vt.RPR_PROCESO = tm.RPR_PROCESO 
            AND vt.NRO_COMPROBANTE = tm.NRO_COMPROBANTE 
        INNER JOIN REC_ENTPREV ep ON 
            vt.MUT_ADH = ep.ENT_CODIFICACION
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO IN (1,2)
      AND vt.TRA_RUT = p_rut_tra
      AND vt.MUT_ADH > 0 
      AND (tm.TSUC_NUMTRAB > 0 OR tm.TSUC_REM_IMPONIBLE > 0 OR tm.TSUC_TOT_COTIZACION > 0)
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización APV - Entidades AFP
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'G' AS TIPO_ENT,
        ep.ENT_RUT,
        SUBSTR(LTRIM(RTRIM(ep.ENT_NOMBRE)), 1, 20) || ' (APV)' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_DEPCONV,
        ta.AFP_COT_VOLUNTARIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.TRA_INS_APV = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 3
      AND vt.TRA_RUT = p_rut_tra
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización APV - Entidades diferentes a las AFP
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'G' AS TIPO_ENT,
        ep.ENT_RUT,
        SUBSTR(LTRIM(RTRIM(ep.ENT_NOMBRE)), 1, 19) || ' (APV)' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_DEPCONV,
        ta.TAPV_COT_VOLUNTARIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TOTALAPV ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
        INNER JOIN REC_ENTPREV ep ON 
            vt.TRA_INS_APV = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 3
      AND vt.TRA_RUT = p_rut_tra
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Nuevos Conceptos CCAF (solo si se especifica el parámetro 3)
    IF p_parametro3 IS NOT NULL THEN
        IF p_parametro3 = '1' THEN

            -- Créditos CCAF
            INSERT INTO GTT_REC_CERT_DETALLE (
                REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
                TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
                RAZ_SOC, SALUD, MONTO_SIS
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO,
                'I' AS TIPO_ENT,
                ep.ENT_RUT,
                CASE 
                    WHEN ep.ENT_CODIFICACION = 1 
                        THEN 'LOS ANDES CREDITOS'   
                    WHEN ep.ENT_CODIFICACION = 2 
                        THEN 'LOS HEROES CREDITOS'   
                    WHEN ep.ENT_CODIFICACION = 3 
                        THEN 'LA ARAUCANA CREDITOS'   
                    WHEN ep.ENT_CODIFICACION = 4 
                        THEN 'GABRIELA M. CREDITOS'   
                    WHEN ep.ENT_CODIFICACION = 5 
                        THEN 'JAVIERA C. CREDITOS'   
                    WHEN ep.ENT_CODIFICACION = 6 
                        THEN '18 SEP. CREDITOS'   
                    ELSE ''
                END AS ENT_NOMBRE,
                vt.TRA_RUT,
                vt.TRA_DIG,
                vt.TRA_NOMBRE,
                vt.TRA_APE,
                vt.DIAS_TRAB,
                CASE 
                    WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                         OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                         THEN vt.REM_IMPO_CCAF  
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION = 0  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMPO_INP   
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION <> 90
                         AND vt.PREVISION <> 0 
                         AND vt.PREVISION IS NOT NULL  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMP_AFP   
                    ELSE vt.REM_IMPO
                END AS REM_IMPO,
                tc.CCAF_MTO_CRED,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS
            FROM GTT_REC_VIR_TRA vt
                INNER JOIN REC_TRACCAF tc ON 
                    vt.REC_PERIODO = tc.REC_PERIODO
                    AND vt.CON_RUT = tc.CON_RUT
                    AND vt.CON_CORREL = tc.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tc.NRO_COMPROBANTE
                    AND vt.SUC_COD = tc.SUC_CODIGO
                    AND vt.USU_CODIGO = tc.USU_CODIGO
                    AND vt.TRA_RUT = tc.TRA_RUT
                INNER JOIN REC_ENTPREV ep ON 
                    vt.CCAF_ADH = ep.ENT_CODIFICACION
                    AND tc.ENT_RUT = ep.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND vt.CON_RUT = p_emp_rut
              AND vt.CON_CORREL = p_convenio
              AND vt.RPR_PROCESO = 1
              AND vt.TRA_RUT = p_rut_tra
              AND tc.CCAF_MTO_CRED > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

            -- Ahorro CCAF
            INSERT INTO GTT_REC_CERT_DETALLE (
                REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
                TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
                RAZ_SOC, SALUD, MONTO_SIS
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO,
                'I' AS TIPO_ENT,
                ep.ENT_RUT,
                CASE 
                    WHEN ep.ENT_CODIFICACION = 1 
                        THEN 'LOS ANDES AHORRO'   
                    WHEN ep.ENT_CODIFICACION = 2 
                        THEN 'LOS HEROES AHORRO'   
                    WHEN ep.ENT_CODIFICACION = 3 
                        THEN 'LA ARAUCANA AHORRO'   
                    WHEN ep.ENT_CODIFICACION = 4 
                        THEN 'GABRIELA M. AHORRO'   
                    WHEN ep.ENT_CODIFICACION = 5 
                        THEN 'JAVIERA C. AHORRO'   
                    WHEN ep.ENT_CODIFICACION = 6 
                        THEN '18 SEP. AHORRO'   
                    ELSE ''
                END AS ENT_NOMBRE,
                vt.TRA_RUT,
                vt.TRA_DIG,
                vt.TRA_NOMBRE,
                vt.TRA_APE,
                vt.DIAS_TRAB,
                CASE 
                    WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                         OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                         THEN vt.REM_IMPO_CCAF 
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION = 0  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMPO_INP   
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION <> 90
                         AND vt.PREVISION <> 0 
                         AND vt.PREVISION IS NOT NULL  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMP_AFP   
                    ELSE vt.REM_IMPO
                END AS REM_IMPO,
                tc.CCAF_MTO_LEAS,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS
            FROM GTT_REC_VIR_TRA vt
                INNER JOIN REC_TRACCAF tc ON 
                    vt.REC_PERIODO = tc.REC_PERIODO
                    AND vt.CON_RUT = tc.CON_RUT
                    AND vt.CON_CORREL = tc.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tc.NRO_COMPROBANTE
                    AND vt.SUC_COD = tc.SUC_CODIGO
                    AND vt.USU_CODIGO = tc.USU_CODIGO
                    AND vt.TRA_RUT = tc.TRA_RUT
                INNER JOIN REC_ENTPREV ep ON 
                    vt.CCAF_ADH = ep.ENT_CODIFICACION
                    AND tc.ENT_RUT = ep.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND vt.CON_RUT = p_emp_rut
              AND vt.CON_CORREL = p_convenio
              AND vt.RPR_PROCESO = 1
              AND vt.TRA_RUT = p_rut_tra
              AND tc.CCAF_MTO_LEAS > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

            -- Seguro de Vida CCAF
            INSERT INTO GTT_REC_CERT_DETALLE (
                REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
                TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
                RAZ_SOC, SALUD, MONTO_SIS
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO,
                'I' AS TIPO_ENT,
                ep.ENT_RUT,
                CASE 
                    WHEN ep.ENT_CODIFICACION = 1 
                        THEN 'LOS ANDES SEG. VIDA'   
                    WHEN ep.ENT_CODIFICACION = 2 
                        THEN 'LOS HEROES SEG. VIDA'   
                    WHEN ep.ENT_CODIFICACION = 3 
                        THEN 'LA ARAUCANA SEG. VIDA'   
                    WHEN ep.ENT_CODIFICACION = 4 
                        THEN 'GABRIELA M. SEG. VIDA'   
                    WHEN ep.ENT_CODIFICACION = 5 
                        THEN 'JAVIERA C. SEG. VIDA'   
                    WHEN ep.ENT_CODIFICACION = 6 
                        THEN '18 SEP. SEG. VIDA'   
                    ELSE ''
                END AS ENT_NOMBRE,
                vt.TRA_RUT,
                vt.TRA_DIG,
                vt.TRA_NOMBRE,
                vt.TRA_APE,
                vt.DIAS_TRAB,
                CASE 
                    WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                         OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                         THEN vt.REM_IMPO_CCAF 
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION = 0  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMPO_INP   
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION <> 90
                         AND vt.PREVISION <> 0 
                         AND vt.PREVISION IS NOT NULL  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMP_AFP   
                    ELSE vt.REM_IMPO
                END AS REM_IMPO,
                tc.CCAF_MTO_SEGU,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS
            FROM GTT_REC_VIR_TRA vt
                INNER JOIN REC_TRACCAF tc ON 
                    vt.REC_PERIODO = tc.REC_PERIODO
                    AND vt.CON_RUT = tc.CON_RUT
                    AND vt.CON_CORREL = tc.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tc.NRO_COMPROBANTE
                    AND vt.SUC_COD = tc.SUC_CODIGO
                    AND vt.USU_CODIGO = tc.USU_CODIGO
                    AND vt.TRA_RUT = tc.TRA_RUT
                INNER JOIN REC_ENTPREV ep ON 
                    vt.CCAF_ADH = ep.ENT_CODIFICACION
                    AND tc.ENT_RUT = ep.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND vt.CON_RUT = p_emp_rut
              AND vt.CON_CORREL = p_convenio
              AND vt.RPR_PROCESO = 1
              AND vt.TRA_RUT = p_rut_tra
              AND tc.CCAF_MTO_SEGU > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

            -- Servicios Legales Prepagados CCAF
            INSERT INTO GTT_REC_CERT_DETALLE (
                REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
                TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
                RAZ_SOC, SALUD, MONTO_SIS
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO,
                'I' AS TIPO_ENT,
                ep.ENT_RUT,
                CASE 
                    WHEN ep.ENT_CODIFICACION = 1 
                        THEN 'LOS ANDES SERV.LEG.PREPAG.'   
                    WHEN ep.ENT_CODIFICACION = 2 
                        THEN 'LOS HEROES SERV.LEG.PREPAG.'   
                    WHEN ep.ENT_CODIFICACION = 3 
                        THEN 'LA ARAUCANA SERV.LEG.PREPAG.'   
                    WHEN ep.ENT_CODIFICACION = 4 
                        THEN 'GABRIELA M. SERV.LEG.PREPAG.'   
                    WHEN ep.ENT_CODIFICACION = 5 
                        THEN 'JAVIERA C. SERV.LEG.PREPAG.'   
                    WHEN ep.ENT_CODIFICACION = 6 
                        THEN '18 SEP. SERV.LEG.PREPAG.'   
                    ELSE ''
                END AS ENT_NOMBRE,
                vt.TRA_RUT,
                vt.TRA_DIG,
                vt.TRA_NOMBRE,
                vt.TRA_APE,
                vt.DIAS_TRAB,
                CASE 
                    WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                         OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                         THEN vt.REM_IMPO_CCAF 
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION = 0  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMPO_INP   
                    WHEN (vt.RPR_PROCESO = 1 
                         AND vt.PREVISION <> 90
                         AND vt.PREVISION <> 0 
                         AND vt.PREVISION IS NOT NULL  
                         AND EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                         THEN vt.REM_IMP_AFP   
                    ELSE vt.REM_IMPO
                END AS REM_IMPO,
                tc.CCAF_MTO_OTRO,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS
            FROM GTT_REC_VIR_TRA vt
                INNER JOIN REC_TRACCAF tc ON 
                    vt.REC_PERIODO = tc.REC_PERIODO
                    AND vt.CON_RUT = tc.CON_RUT
                    AND vt.CON_CORREL = tc.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tc.NRO_COMPROBANTE
                    AND vt.SUC_COD = tc.SUC_CODIGO
                    AND vt.USU_CODIGO = tc.USU_CODIGO
                    AND vt.TRA_RUT = tc.TRA_RUT
                INNER JOIN REC_ENTPREV ep ON 
                    vt.CCAF_ADH = ep.ENT_CODIFICACION
                    AND tc.ENT_RUT = ep.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
              AND vt.CON_RUT = p_emp_rut
              AND vt.CON_CORREL = p_convenio
              AND vt.RPR_PROCESO = 1
              AND vt.TRA_RUT = p_rut_tra
              AND tc.CCAF_MTO_OTRO > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

        END IF;
    END IF;

    -- Cuenta Ahorro Previsional AFP: Remuneraciones antes de Julio 2009
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'J' AS TIPO_ENT,
        ep.ENT_RUT,
        'CTA.AHO.PREV. ' || SUBSTR(LTRIM(RTRIM(ep.ENT_NOMBRE)), 1, 20) AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        ta.AFP_CTAAHO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009 
           OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION > 0
      AND ta.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cuenta Ahorro Previsional AFP: Remuneraciones después de Julio 2009
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS
    )
    SELECT 
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        NVL(vt.TIPO_IMPRE, 1) AS TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'J' AS TIPO_ENT,
        ep.ENT_RUT,
        'CTA.AHO.PREV. ' || SUBSTR(LTRIM(RTRIM(ep.ENT_NOMBRE)), 1, 20) AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMP_AFP,
        ta.AFP_CTAAHO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAAFP ta ON 
            vt.REC_PERIODO = ta.REC_PERIODO
            AND vt.CON_RUT = ta.CON_RUT
            AND vt.CON_CORREL = ta.CON_CORREL
            AND vt.NRO_COMPROBANTE = ta.NRO_COMPROBANTE
            AND vt.SUC_COD = ta.SUC_CODIGO
            AND vt.USU_CODIGO = ta.USU_CODIGO
            AND vt.TRA_RUT = ta.TRA_RUT
        INNER JOIN REC_ENTPREV ep ON 
            vt.PREVISION = ep.ENT_CODIFICACION
            AND ta.ENT_RUT = ep.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
      AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009 
           OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
      AND vt.CON_RUT = p_emp_rut
      AND vt.CON_CORREL = p_convenio
      AND vt.RPR_PROCESO = 1
      AND vt.TRA_RUT = p_rut_tra
      AND vt.PREVISION > 0
      AND ta.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Procesamiento de planillas para asociar folios
    -- Cursor para procesar distintos períodos y tipos de impresión
    FOR rec IN (
        SELECT DISTINCT REC_PERIODO, TIPO_IMPRE, NRO_COMPROBANTE 
        FROM GTT_REC_CERT_DETALLE
    ) LOOP
        
        IF (rec.TIPO_IMPRE = 0 OR rec.TIPO_IMPRE = 1 OR rec.TIPO_IMPRE = 2) THEN
            INSERT INTO GTT_REC_PLANILLA (
                REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                p.ENT_RUT,
                p.PLA_NRO_SERIE,
                vt.SUC_COD,
                vt.USU_COD
            FROM REC_PLANILLA p
                INNER JOIN GTT_REC_CERT_DETALLE vt ON
                    p.REC_PERIODO = vt.REC_PERIODO
                    AND p.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                    AND p.ENT_RUT = vt.ENT_RUT
            WHERE vt.REC_PERIODO = rec.REC_PERIODO
              AND vt.TIPO_IMPRE = rec.TIPO_IMPRE
              AND vt.NRO_COMPROBANTE = rec.NRO_COMPROBANTE
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
              
        ELSIF (rec.TIPO_IMPRE = 3) THEN
            INSERT INTO GTT_REC_PLANILLA (
                REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                p.ENT_RUT,
                p.PLA_NRO_SERIE,
                vt.SUC_COD,
                vt.USU_COD
            FROM REC_PLANILLA p
                INNER JOIN GTT_REC_CERT_DETALLE vt ON
                    p.REC_PERIODO = vt.REC_PERIODO
                    AND p.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                    AND p.SUC_CODIGO = vt.SUC_COD
                    AND p.ENT_RUT = vt.ENT_RUT
            WHERE vt.REC_PERIODO = rec.REC_PERIODO
              AND vt.TIPO_IMPRE = rec.TIPO_IMPRE
              AND vt.NRO_COMPROBANTE = rec.NRO_COMPROBANTE
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
              
        ELSIF (rec.TIPO_IMPRE = 4) THEN
            INSERT INTO GTT_REC_PLANILLA (
                REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
            )
            SELECT 
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                p.ENT_RUT,
                p.PLA_NRO_SERIE,
                vt.SUC_COD,
                vt.USU_COD
            FROM REC_PLANILLA p
                INNER JOIN GTT_REC_CERT_DETALLE vt ON
                    p.REC_PERIODO = vt.REC_PERIODO
                    AND p.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                    AND p.USU_CODIGO = vt.USU_COD
                    AND p.ENT_RUT = vt.ENT_RUT
            WHERE vt.REC_PERIODO = rec.REC_PERIODO
              AND vt.TIPO_IMPRE = rec.TIPO_IMPRE
              AND vt.NRO_COMPROBANTE = rec.NRO_COMPROBANTE
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
        END IF;
        
    END LOOP;

    -- Actualizar el folio de planilla en el detalle de certificaciones
    UPDATE GTT_REC_CERT_DETALLE cd
    SET FOLIO_PLANILLA = (
        SELECT MAX(p.PLA_NRO_SERIE)
        FROM GTT_REC_PLANILLA p
        WHERE cd.REC_PERIODO = p.REC_PERIODO
          AND cd.NRO_COMPROBANTE = p.NRO_COMPROBANTE
          AND cd.ENT_RUT = p.ENT_RUT
          AND cd.SUC_COD = p.SUC_COD
          AND cd.USU_COD = p.USU_COD
    );

    -- Retornar cursor con el resultado final de certificaciones
    OPEN p_cursor FOR
        SELECT 
            REC_PERIODO,
            NRO_COMPROBANTE,
            TIPO_IMPRE,
            SUC_COD,
            USU_COD,
            TIPO_ENT,
            ENT_RUT,
            ENT_NOMBRE,
            TRA_RUT,
            TRA_DIG,
            TRA_NOMBRE,
            TRA_APE,
            DIAS_TRAB,
            REM_IMPO,
            MONTO_COTIZADO,
            FEC_PAGO,
            FOLIO_PLANILLA,
            RAZ_SOC,
            SALUD,
            MONTO_SIS
        FROM GTT_REC_CERT_DETALLE
        ORDER BY REC_PERIODO, SUC_COD, USU_COD, TIPO_ENT;

EXCEPTION
    WHEN OTHERS THEN
        -- Manejo de errores
        RAISE_APPLICATION_ERROR(-20001, 'Error en PRC_REC_CERTCOT_TRAB: ' || SQLERRM);
        
END PRC_REC_CERTCOT_TRAB;
