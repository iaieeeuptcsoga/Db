CREATE OR REPLACE PROCEDURE PRC_CERTCOT_TRAB_PUB (
    p_fec_ini       IN DATE,
    p_fec_ter       IN DATE,
    p_emp_rut       IN NUMBER,
    p_convenio      IN NUMBER,
    p_rut_tra       IN NUMBER,
    p_tipoCon       IN NUMBER,
    p_Parametro     IN VARCHAR2 DEFAULT NULL,
    p_parametro2    IN VARCHAR2 DEFAULT NULL,
    p_parametro3    IN VARCHAR2 DEFAULT NULL,
    p_cursor        OUT SYS_REFCURSOR
)
AS
    -- Variables locales
    v_tipoImp       NUMBER(1);
    v_periodo       DATE;
    v_nomTra        VARCHAR2(100);  -- Aumentado de 40 a 100 para evitar ORA-06502
    v_apeTra        VARCHAR2(100);  -- Aumentado de 40 a 100 para evitar ORA-06502
    v_numComp       NUMBER(7);
    
BEGIN
    -- Limpiar tablas temporales globales
    DELETE FROM GTT_REC_VIR_TRA_PUB;
    DELETE FROM GTT_REC_VIR_TRA2_PUB;
    DELETE FROM GTT_REC_CERT_DETALLE_PUB;
    DELETE FROM GTT_REC_PLANILLA_PUB;
    DELETE FROM GTT_REC_SUCURSALES_PUB;
    
    -- Lógica para determinar sucursales según tipo de consulta
    IF p_tipoCon = 2 THEN
        -- Consulta por impresión por sucursal
        -- NOTA: La tabla DET_CTA_USU no existe en el modelo Oracle
        -- Se debe implementar la lógica correcta según el modelo de datos disponible
        -- Por ahora se usa una consulta alternativa basada en las tablas disponibles
        INSERT INTO GTT_REC_SUCURSALES_PUB (COD_SUC)
        SELECT DISTINCT SUC_CODIGO
        FROM REC_SUCURSAL
        WHERE CON_RUT = p_emp_rut 
          AND CON_CORREL = p_convenio
          AND USU_CODIGO = p_Parametro;
          
    ELSIF p_tipoCon = 3 THEN
        -- Consulta por impresión masiva por sucursal
        INSERT INTO GTT_REC_SUCURSALES_PUB (COD_SUC)
        VALUES (p_Parametro);
    END IF;
    
    -- Commit para hacer disponibles los datos en las tablas temporales
    COMMIT;
    
    -- Obtiene los datos del trabajador
    IF p_convenio >= 600 AND p_convenio <= 699 THEN
        IF p_tipoCon = 1 THEN
            -- Consulta individual - Proceso 1,3,4
            INSERT INTO GTT_REC_VIR_TRA2_PUB
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                sucursal.suc_ccaf_adh,                     -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                '0',                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_SUCURSAL sucursal, REC_PAGO pago, REC_TRABAJADOR trabajador
            WHERE empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso IN (1,3,4)
                AND pago.pag_digest IS NOT NULL
                AND pago.ret_estado = 5
                AND trabajador.tra_rut = p_rut_tra
                AND empresa.rec_periodo = sucursal.rec_periodo
                AND empresa.con_rut = sucursal.con_rut
                AND empresa.con_correl = sucursal.con_correl
                AND empresa.rpr_proceso = sucursal.rpr_proceso
                AND empresa.nro_comprobante = sucursal.nro_comprobante
                AND empresa.rec_periodo = pago.rec_periodo
                AND empresa.con_rut = pago.con_rut
                AND empresa.con_correl = pago.con_correl
                AND empresa.rpr_proceso = pago.rpr_proceso
                AND empresa.nro_comprobante = pago.nro_comprobante
                AND empresa.rec_periodo = trabajador.rec_periodo
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
                AND trabajador.suc_codigo = sucursal.suc_codigo
            UNION ALL
            -- Consulta individual - Proceso 2
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                sucursal.suc_ccaf_adh,                     -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                CASE
                    WHEN (EXTRACT(YEAR FROM empresa.rec_periodo) >= 2013)
                      OR (EXTRACT(YEAR FROM empresa.rec_periodo) = 2012 AND EXTRACT(MONTH FROM empresa.rec_periodo) >= 5)
                    THEN NVL(dato_usuario.usu_pago_retroactivo,'0')
                    ELSE '0'
                END,                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_SUCURSAL sucursal, REC_DATOUSU dato_usuario, REC_PAGO pago, REC_TRABAJADOR trabajador
            WHERE empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso = 2
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND trabajador.tra_rut = p_rut_tra
                AND empresa.rec_periodo = sucursal.rec_periodo 
                AND empresa.con_rut = sucursal.con_rut
                AND empresa.con_correl = sucursal.con_correl
                AND empresa.rpr_proceso = sucursal.rpr_proceso
                AND empresa.nro_comprobante = sucursal.nro_comprobante
                AND empresa.rec_periodo = dato_usuario.rec_periodo 
                AND empresa.con_rut = dato_usuario.con_rut
                AND empresa.con_correl = dato_usuario.con_correl
                AND empresa.rpr_proceso = dato_usuario.rpr_proceso
                AND empresa.nro_comprobante = dato_usuario.nro_comprobante
                AND empresa.rec_periodo = pago.rec_periodo
                AND empresa.con_rut = pago.con_rut
                AND empresa.con_correl = pago.con_correl         
                AND empresa.rpr_proceso = pago.rpr_proceso        
                AND empresa.nro_comprobante = pago.nro_comprobante    
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
                AND trabajador.suc_codigo = sucursal.suc_codigo
                AND trabajador.usu_codigo = dato_usuario.usu_codigo
            ORDER BY 1, 22, 23;  -- rec_periodo, suc_codigo, usu_codigo
            
        ELSE
            -- Consulta por sucursal - Proceso 1,3,4
            INSERT INTO GTT_REC_VIR_TRA2_PUB
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                sucursal.suc_ccaf_adh,                     -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                '0',                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_SUCURSAL sucursal, REC_PAGO pago, REC_TRABAJADOR trabajador
            WHERE empresa.rec_periodo = sucursal.rec_periodo 
                AND empresa.con_rut = sucursal.con_rut
                AND empresa.con_correl = sucursal.con_correl
                AND empresa.rpr_proceso = sucursal.rpr_proceso
                AND empresa.nro_comprobante = sucursal.nro_comprobante
                AND empresa.rec_periodo = pago.rec_periodo  
                AND empresa.con_rut = pago.con_rut
                AND empresa.con_correl = pago.con_correl  
                AND empresa.rpr_proceso = pago.rpr_proceso 
                AND empresa.nro_comprobante = pago.nro_comprobante 
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
                AND trabajador.suc_codigo = sucursal.suc_codigo
                AND empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso IN (1,3,4)
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND trabajador.tra_rut = p_rut_tra
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES_PUB)
            UNION ALL
            -- Consulta por sucursal - Proceso 2
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                sucursal.suc_ccaf_adh,                     -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                CASE
                    WHEN (EXTRACT(YEAR FROM empresa.rec_periodo) >= 2013)
                      OR (EXTRACT(YEAR FROM empresa.rec_periodo) = 2012 AND EXTRACT(MONTH FROM empresa.rec_periodo) >= 5)
                    THEN NVL(dato_usuario.usu_pago_retroactivo,'0')
                    ELSE '0'
                END,                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_SUCURSAL sucursal, REC_DATOUSU dato_usuario, REC_PAGO pago, REC_TRABAJADOR trabajador
            WHERE empresa.rec_periodo = sucursal.rec_periodo 
                AND empresa.con_rut = sucursal.con_rut
                AND empresa.con_correl = sucursal.con_correl
                AND empresa.rpr_proceso = sucursal.rpr_proceso
                AND empresa.nro_comprobante = sucursal.nro_comprobante
                AND empresa.rec_periodo = dato_usuario.rec_periodo 
                AND empresa.con_rut = dato_usuario.con_rut
                AND empresa.con_correl = dato_usuario.con_correl
                AND empresa.rpr_proceso = dato_usuario.rpr_proceso
                AND empresa.nro_comprobante = dato_usuario.nro_comprobante
                AND empresa.rec_periodo = pago.rec_periodo  
                AND empresa.con_rut = pago.con_rut
                AND empresa.con_correl = pago.con_correl  
                AND empresa.rpr_proceso = pago.rpr_proceso 
                AND empresa.nro_comprobante = pago.nro_comprobante 
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
                AND trabajador.suc_codigo = sucursal.suc_codigo
                AND empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso = 2
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND trabajador.tra_rut = p_rut_tra
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES_PUB)
                AND trabajador.usu_codigo = dato_usuario.usu_codigo
            ORDER BY 1, 22, 23;  -- rec_periodo, suc_codigo, usu_codigo
        END IF;
        
    ELSE  -- Convenio < 600 o > 699
        IF p_tipoCon = 1 THEN
            -- Consulta individual - Proceso 1,3,4
            INSERT INTO GTT_REC_VIR_TRA2_PUB
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                empresa.emp_ccaf_adh,                      -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                '0',                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_PAGO pago, REC_TRABAJADOR trabajador 
            WHERE empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso IN (1,3,4)
                AND trabajador.tra_rut = p_rut_tra
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND empresa.rec_periodo = pago.rec_periodo 
                AND empresa.con_rut = pago.con_rut 
                AND empresa.con_correl = pago.con_correl 
                AND empresa.rpr_proceso = pago.rpr_proceso
                AND empresa.nro_comprobante = pago.nro_comprobante
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
            UNION ALL
            -- Consulta individual - Proceso 2
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                empresa.emp_ccaf_adh,                      -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                CASE
                    WHEN (EXTRACT(YEAR FROM empresa.rec_periodo) >= 2013)
                      OR (EXTRACT(YEAR FROM empresa.rec_periodo) = 2012 AND EXTRACT(MONTH FROM empresa.rec_periodo) >= 5)
                    THEN NVL(dato_usuario.usu_pago_retroactivo,'0')
                    ELSE '0'
                END,                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_DATOUSU dato_usuario, REC_PAGO pago, REC_TRABAJADOR trabajador 
            WHERE empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso = 2
                AND trabajador.tra_rut = p_rut_tra
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND empresa.rec_periodo = dato_usuario.rec_periodo 
                AND empresa.con_rut = dato_usuario.con_rut
                AND empresa.con_correl = dato_usuario.con_correl
                AND empresa.rpr_proceso = dato_usuario.rpr_proceso
                AND empresa.nro_comprobante = dato_usuario.nro_comprobante 
                AND empresa.rec_periodo = pago.rec_periodo 
                AND empresa.con_rut = pago.con_rut 
                AND empresa.con_correl = pago.con_correl 
                AND empresa.rpr_proceso = pago.rpr_proceso
                AND empresa.nro_comprobante = pago.nro_comprobante
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
                AND trabajador.usu_codigo = dato_usuario.usu_codigo
            ORDER BY 1, 22, 23;  -- rec_periodo, suc_codigo, usu_codigo
            
        ELSE
            -- Consulta por sucursal - Proceso 1,3,4
            INSERT INTO GTT_REC_VIR_TRA2_PUB
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                empresa.emp_ccaf_adh,                      -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                '0',                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_PAGO pago, REC_TRABAJADOR trabajador 
            WHERE empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso IN (1,3,4)
                AND trabajador.tra_rut = p_rut_tra
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES_PUB)
                AND empresa.rec_periodo = pago.rec_periodo
                AND empresa.con_rut = pago.con_rut
                AND empresa.con_correl = pago.con_correl
                AND empresa.rpr_proceso = pago.rpr_proceso
                AND empresa.nro_comprobante = pago.nro_comprobante
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
            UNION ALL
            -- Consulta por sucursal - Proceso 2
            SELECT
                trabajador.rec_periodo,                    -- REC_PERIODO
                trabajador.con_rut,                        -- CON_RUT
                trabajador.con_correl,                     -- CON_CORREL
                trabajador.rpr_proceso,                    -- RPR_PROCESO
                trabajador.nro_comprobante,                -- NRO_COMPROBANTE
                trabajador.suc_codigo,                     -- SUC_COD
                trabajador.usu_codigo,                     -- USU_CODIGO
                trabajador.tra_rut,                        -- TRA_RUT
                trabajador.tra_digito,                     -- TRA_DIG
                trabajador.tra_nomtra,                     -- TRA_NOMBRE
                trabajador.tra_apetra,                     -- TRA_APE
                trabajador.tra_rem_imponible,              -- REM_IMPO
                trabajador.tra_rem_imp_afp,                -- REM_IMP_AFP
                trabajador.tra_remimp_inpccaf,             -- REM_IMPO_INP
                trabajador.tra_rem_imponible_fc,           -- REM_IMPO_FC
                trabajador.tra_rem_imp_depcon,             -- REM_IMPO_DEPCONV
                trabajador.tra_nro_dias_trab,              -- DIAS_TRAB
                trabajador.tra_reg_previs,                 -- PREVISION
                trabajador.tra_reg_salud,                  -- SALUD
                trabajador.tra_adm_fondo_ces,              -- ENT_AFC
                empresa.emp_orden_imp,                     -- TIPO_IMPRE
                pago.pag_fecpag,                          -- FEC_PAGO
                empresa.emp_ccaf_adh,                      -- CCAF_ADH
                empresa.emp_mutual_adh,                    -- MUT_ADH
                empresa.emp_tasa_cot_mut,                  -- TASA_COT_MUT
                empresa.emp_cotadic_mut,                   -- TASA_ADIC_MUT
                empresa.emp_razsoc,                        -- RAZ_SOC
                trabajador.tra_isades,                     -- TRA_ISA_DEST
                trabajador.tra_tipo_ins_apv,               -- TRA_TIPO_APV
                trabajador.tra_ins_apv,                    -- TRA_INS_APV
                CASE
                    WHEN (EXTRACT(YEAR FROM empresa.rec_periodo) >= 2013)
                      OR (EXTRACT(YEAR FROM empresa.rec_periodo) = 2012 AND EXTRACT(MONTH FROM empresa.rec_periodo) >= 5)
                    THEN NVL(dato_usuario.usu_pago_retroactivo,'0')
                    ELSE '0'
                END,                                       -- USU_PAGO_RETROACTIVO
                trabajador.tra_rem_ccaf,                   -- REM_IMPO_CCAF
                trabajador.tra_rem_isapre,                 -- REM_IMPO_ISA
                trabajador.tra_rem_mutual                  -- REM_IMPO_MUTUAL
            FROM REC_EMPRESA empresa, REC_DATOUSU dato_usuario, REC_PAGO pago, REC_TRABAJADOR trabajador 
            WHERE empresa.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
                AND empresa.con_rut = p_emp_rut
                AND empresa.con_correl = p_convenio
                AND empresa.rpr_proceso = 2
                AND trabajador.tra_rut = p_rut_tra
                AND pago.pag_digest IS NOT NULL 
                AND pago.ret_estado = 5
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES_PUB)
                AND trabajador.usu_codigo = dato_usuario.usu_codigo
                AND empresa.rec_periodo = dato_usuario.rec_periodo 
                AND empresa.con_rut = dato_usuario.con_rut
                AND empresa.con_correl = dato_usuario.con_correl
                AND empresa.rpr_proceso = dato_usuario.rpr_proceso
                AND empresa.nro_comprobante = dato_usuario.nro_comprobante
                AND empresa.rec_periodo = pago.rec_periodo
                AND empresa.con_rut = pago.con_rut
                AND empresa.con_correl = pago.con_correl
                AND empresa.rpr_proceso = pago.rpr_proceso
                AND empresa.nro_comprobante = pago.nro_comprobante 
                AND empresa.rec_periodo = trabajador.rec_periodo 
                AND empresa.con_rut = trabajador.con_rut
                AND empresa.con_correl = trabajador.con_correl
                AND empresa.rpr_proceso = trabajador.rpr_proceso
                AND empresa.nro_comprobante = trabajador.nro_comprobante
            ORDER BY 1, 22, 23;  -- rec_periodo, suc_codigo, usu_codigo
        END IF;
    END IF;
    
    -- Si el tipo de consulta es > a 1, traspasa los datos a la tabla GTT_REC_VIR_TRA_PUB
    IF p_parametro2 IS NOT NULL THEN
        -- Cuando es agrupado por dato usuario
        INSERT INTO GTT_REC_VIR_TRA_PUB
        SELECT * FROM GTT_REC_VIR_TRA2_PUB
        WHERE USU_CODIGO = p_parametro2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    ELSE
        -- Cuando es agrupado por sucursal
        INSERT INTO GTT_REC_VIR_TRA_PUB
        SELECT * FROM GTT_REC_VIR_TRA2_PUB
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    END IF;

    /* Obtiene el nombre del trabajador correspondiente al ultimo periodo
    registrado*/
    SELECT TRA_NOMBRE, TRA_APE
    INTO v_nomTra, v_apeTra
    FROM (
        SELECT TRA_NOMBRE, TRA_APE
        FROM GTT_REC_VIR_TRA_PUB
        ORDER BY REC_PERIODO DESC
    )
    WHERE ROWNUM = 1;

    -- Actualiza todos los registros con el nombre del trabajador del último período
    UPDATE GTT_REC_VIR_TRA_PUB
    SET TRA_NOMBRE = TRIM(v_nomTra),
        TRA_APE = TRIM(v_apeTra);

    -- Cotización AFP: Gratificaciones
    -- VOS, por incorporación de Rem_imp_AFP
    -- Se deja este solo para el proceso de Gratificaciones
    -- VOS2090928 agrego NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) as AFP_SEG_INV_SOBRE
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'A' AS TIPO_ENT,
        afps.ENT_RUT,
        afps.ENT_NOMBRE,
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
        trab_afp.AFP_COT_OBLIGATORIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) AS AFP_SEG_INV_SOBRE,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.PREVISION = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 2
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP: Remuneraciones antes de Julio 2009
    -- VOS, por incorporación de Rem_imp_AFP
    -- Se agrega para el proceso de remuneraciones que lea del campo Rem_impo
    -- para períodos menores a Julio del 2009
    -- VOS2090928 agrego NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) as AFP_SEG_INV_SOBRE
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'A' AS TIPO_ENT,
        afps.ENT_RUT,
        afps.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        trab_afp.AFP_COT_OBLIGATORIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) AS AFP_SEG_INV_SOBRE,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.PREVISION = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009
             OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP: Remuneraciones Después de Julio 2009
    -- VOS, por incorporación de Rem_imp_AFP
    -- Se agrega para el proceso de remuneraciones que lea del campo Rem_imp_afp
    -- para períodos Mayores o iguales a Julio del 2009
    -- VOS2090928 agrego NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) as AFP_SEG_INV_SOBRE
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'A' AS TIPO_ENT,
        afps.ENT_RUT,
        afps.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMP_AFP,
        trab_afp.AFP_COT_OBLIGATORIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) AS AFP_SEG_INV_SOBRE,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.PREVISION = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009
             OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización INP:
    -- VOS2090928 agrego 0
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'A' AS TIPO_ENT,
        inp.ENT_RUT,
        inp.ENT_NOMBRE,
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
        tra_inp.INP_COT_PREV,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAINP tra_inp ON
            vt.REC_PERIODO = tra_inp.REC_PERIODO
            AND vt.CON_RUT = tra_inp.CON_RUT
            AND vt.CON_CORREL = tra_inp.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_inp.SUC_CODIGO
            AND vt.USU_CODIGO = tra_inp.USU_CODIGO
            AND vt.TRA_RUT = tra_inp.TRA_RUT
        INNER JOIN REC_ENTPREV inp ON
            vt.PREVISION = inp.ENT_CODIFICACION
            AND tra_inp.ENT_RUT = inp.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización Fonasa
    -- VOS2090928 agrego 0
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'B' AS TIPO_ENT,
        tra_inp.ENT_RUT,
        isapres.ENT_NOMBRE,
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
        tra_inp.INP_COT_FONASA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAINP tra_inp ON
            vt.REC_PERIODO = tra_inp.REC_PERIODO
            AND vt.CON_RUT = tra_inp.CON_RUT
            AND vt.CON_CORREL = tra_inp.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_inp.SUC_CODIGO
            AND vt.USU_CODIGO = tra_inp.USU_CODIGO
            AND vt.TRA_RUT = tra_inp.TRA_RUT
        INNER JOIN REC_ENTPREV isapres ON
            vt.SALUD = isapres.ENT_CODIFICACION
            -- Comentado: AND tra_inp.ENT_RUT = isapres.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización en Isapre
    -- VOS2090928 agrego 0
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'B' AS TIPO_ENT,
        isapres.ENT_RUT,
        isapres.ENT_NOMBRE,
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
        tra_isapre.ISA_COT_APAGAR,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        vt.TRA_ISA_DEST AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAISA tra_isapre ON
            vt.REC_PERIODO = tra_isapre.REC_PERIODO
            AND vt.CON_RUT = tra_isapre.CON_RUT
            AND vt.CON_CORREL = tra_isapre.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_isapre.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_isapre.SUC_CODIGO
            AND vt.USU_CODIGO = tra_isapre.USU_CODIGO
            AND vt.TRA_RUT = tra_isapre.TRA_RUT
        INNER JOIN REC_ENTPREV isapres ON
            vt.SALUD = isapres.ENT_CODIFICACION
            AND tra_isapre.ENT_RUT = isapres.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.SALUD > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;


    -- Cotización en CCAF
    -- VOS2090928 agrego 0
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'C' AS TIPO_ENT,
        cajas.ENT_RUT,
        CASE
           WHEN cajas.ENT_CODIFICACION = 1
                THEN 'LOS ANDES 0.6%'
          WHEN cajas.ENT_CODIFICACION = 2
                THEN 'LOS HEROES 0.6%'
           WHEN cajas.ENT_CODIFICACION = 3
                THEN 'LA ARAUCANA 0.6%'
           WHEN cajas.ENT_CODIFICACION = 4
                THEN 'GABRIELA M.  0.6%'
           WHEN cajas.ENT_CODIFICACION = 5
                THEN 'JAVIERA C.  0.6%'
           WHEN cajas.ENT_CODIFICACION = 6
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
        tra_ccaf.CCAF_SALUD,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRACCAF tra_ccaf ON
            vt.REC_PERIODO = tra_ccaf.REC_PERIODO
            AND vt.CON_RUT = tra_ccaf.CON_RUT
            AND vt.CON_CORREL = tra_ccaf.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_ccaf.SUC_CODIGO
            AND vt.USU_CODIGO = tra_ccaf.USU_CODIGO
            AND vt.TRA_RUT = tra_ccaf.TRA_RUT
        INNER JOIN REC_ENTPREV cajas ON
            vt.CCAF_ADH = cajas.ENT_CODIFICACION
            AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Seguro de cesantía
    -- VOS2090928 agrego 0
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'D' AS TIPO_ENT,
        afps.ENT_RUT,
        'SEG. CES.' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_FC,
        trab_afp.AFP_FONDO_CESANTIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.REM_IMPO_FC >= 0
        AND vt.REM_IMPO_FC IS NOT NULL
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP - Trabajo pesado
    -- VOS2090928 agrego 0
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'E' AS TIPO_ENT,
        afps.ENT_RUT,
        'TRAB.PES. ' || SUBSTR(LTRIM(RTRIM(afps.ENT_NOMBRE)), 1, 20) AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        trab_afp.AFP_MTO_TRA_PESADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.PREVISION = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 4
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización Accidente del trabajo
    -- VOS2090928 agrego 0
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    -- VOS 20100204 por solicitud de FR se agregó lo siguiente
    -- AND (tm.TSUC_NUMTRAB > 0 OR tm.TSUC_REM_IMPONIBLE > 0 OR tm.TSUC_TOT_COTIZACION > 0)
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT DISTINCT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'F' AS TIPO_ENT,
        iat.ENT_RUT,
        CASE iat.ENT_CODIFICACION
            WHEN 4 THEN 'IST'
            WHEN 2 THEN 'MUTUAL DE SEGURIDAD'
            WHEN 3 THEN 'ACHS'
            ELSE iat.ENT_NOMBRE
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
           WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                THEN (vt.REM_IMPO_MUTUAL * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100
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
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TOTALSUC tm ON
            vt.REC_PERIODO = tm.REC_PERIODO
            AND vt.CON_RUT = tm.CON_RUT
            AND vt.CON_CORREL = tm.CON_CORREL
            AND vt.RPR_PROCESO = tm.RPR_PROCESO
            AND vt.NRO_COMPROBANTE = tm.NRO_COMPROBANTE
        INNER JOIN REC_ENTPREV iat ON
            vt.MUT_ADH = iat.ENT_CODIFICACION
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.MUT_ADH > 0
        AND (tm.TSUC_NUMTRAB > 0 OR
             tm.TSUC_REM_IMPONIBLE > 0 OR
             tm.TSUC_TOT_COTIZACION > 0)
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización APV - Entidades AFP
    -- VOS2090928 agrego 0
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'G' AS TIPO_ENT,
        afps.ENT_RUT,
        SUBSTR(LTRIM(RTRIM(afps.ENT_NOMBRE)), 1, 20) || ' (APV)' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_DEPCONV,
        trab_afp.AFP_COT_VOLUNTARIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.TRA_INS_APV = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 3
        AND vt.TRA_RUT = p_rut_tra
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización APV - Entidades <> a las AFP
    -- VOS2090928 agrego 0
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'G' AS TIPO_ENT,
        entidad_previsional.ENT_RUT,
        SUBSTR(LTRIM(RTRIM(entidad_previsional.ENT_NOMBRE)), 1, 19) || ' (APV)' AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_DEPCONV,
        tra_apv.AFP_COT_VOLUNTARIA,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP tra_apv ON
            vt.REC_PERIODO = tra_apv.REC_PERIODO
            AND vt.CON_RUT = tra_apv.CON_RUT
            AND vt.CON_CORREL = tra_apv.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_apv.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_apv.SUC_CODIGO
            AND vt.USU_CODIGO = tra_apv.USU_CODIGO
            AND vt.TRA_RUT = tra_apv.TRA_RUT
        INNER JOIN REC_ENTPREV entidad_previsional ON
            vt.TRA_INS_APV = entidad_previsional.ENT_CODIFICACION
            AND tra_apv.ENT_RUT = entidad_previsional.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 3
        AND vt.TRA_RUT = p_rut_tra
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Nuevos Conceptos CCAF (solo si se especifica el parámetro 3)
    IF p_parametro3 IS NOT NULL THEN
        IF p_parametro3 = '1' THEN

            -- Nuevo VOS20110630 Créditos CCAF
            INSERT INTO GTT_REC_CERT_DETALLE_PUB
            SELECT
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                vt.TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO AS USU_COD,
                'I' AS TIPO_ENT,
                cajas.ENT_RUT,
                CASE
                    WHEN cajas.ENT_CODIFICACION = 1
                        THEN 'LOS ANDES CREDITOS'
                    WHEN cajas.ENT_CODIFICACION = 2
                        THEN 'LOS HEROES CREDITOS'
                    WHEN cajas.ENT_CODIFICACION = 3
                        THEN 'LA ARAUCANA CREDITOS'
                    WHEN cajas.ENT_CODIFICACION = 4
                        THEN 'GABRIELA M. CREDITOS'
                    WHEN cajas.ENT_CODIFICACION = 5
                        THEN 'JAVIERA C. CREDITOS'
                    WHEN cajas.ENT_CODIFICACION = 6
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
                tra_ccaf.CCAF_MTO_CRED,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS,
                vt.USU_PAGO_RETROACTIVO
            FROM GTT_REC_VIR_TRA_PUB vt
                INNER JOIN REC_TRACCAF tra_ccaf ON
                    vt.REC_PERIODO = tra_ccaf.REC_PERIODO
                    AND vt.CON_RUT = tra_ccaf.CON_RUT
                    AND vt.CON_CORREL = tra_ccaf.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
                    AND vt.SUC_COD = tra_ccaf.SUC_CODIGO
                    AND vt.USU_CODIGO = tra_ccaf.USU_CODIGO
                    AND vt.TRA_RUT = tra_ccaf.TRA_RUT
                INNER JOIN REC_ENTPREV cajas ON
                    vt.CCAF_ADH = cajas.ENT_CODIFICACION
                    AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
                AND vt.CON_RUT = p_emp_rut
                AND vt.CON_CORREL = p_convenio
                AND vt.RPR_PROCESO = 1
                AND vt.TRA_RUT = p_rut_tra
                AND tra_ccaf.CCAF_MTO_CRED > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

            -- Nuevo VOS20110630 Ahorro CCAF
            INSERT INTO GTT_REC_CERT_DETALLE_PUB
            SELECT
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                vt.TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO AS USU_COD,
                'I' AS TIPO_ENT,
                cajas.ENT_RUT,
                CASE
                    WHEN cajas.ENT_CODIFICACION = 1
                        THEN 'LOS ANDES AHORRO'
                    WHEN cajas.ENT_CODIFICACION = 2
                        THEN 'LOS HEROES AHORRO'
                    WHEN cajas.ENT_CODIFICACION = 3
                        THEN 'LA ARAUCANA AHORRO'
                    WHEN cajas.ENT_CODIFICACION = 4
                        THEN 'GABRIELA M. AHORRO'
                    WHEN cajas.ENT_CODIFICACION = 5
                        THEN 'JAVIERA C. AHORRO'
                    WHEN cajas.ENT_CODIFICACION = 6
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
                tra_ccaf.CCAF_MTO_LEAS,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS,
                vt.USU_PAGO_RETROACTIVO
            FROM GTT_REC_VIR_TRA_PUB vt
                INNER JOIN REC_TRACCAF tra_ccaf ON
                    vt.REC_PERIODO = tra_ccaf.REC_PERIODO
                    AND vt.CON_RUT = tra_ccaf.CON_RUT
                    AND vt.CON_CORREL = tra_ccaf.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
                    AND vt.SUC_COD = tra_ccaf.SUC_CODIGO
                    AND vt.USU_CODIGO = tra_ccaf.USU_CODIGO
                    AND vt.TRA_RUT = tra_ccaf.TRA_RUT
                INNER JOIN REC_ENTPREV cajas ON
                    vt.CCAF_ADH = cajas.ENT_CODIFICACION
                    AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
                AND vt.CON_RUT = p_emp_rut
                AND vt.CON_CORREL = p_convenio
                AND vt.RPR_PROCESO = 1
                AND vt.TRA_RUT = p_rut_tra
                AND tra_ccaf.CCAF_MTO_LEAS > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

            -- Nuevo VOS20110630 Seguro de Vida CCAF
            INSERT INTO GTT_REC_CERT_DETALLE_PUB
            SELECT
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                vt.TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO AS USU_COD,
                'I' AS TIPO_ENT,
                cajas.ENT_RUT,
                CASE
                    WHEN cajas.ENT_CODIFICACION = 1
                        THEN 'LOS ANDES SEG. VIDA'
                    WHEN cajas.ENT_CODIFICACION = 2
                        THEN 'LOS HEROES SEG. VIDA'
                    WHEN cajas.ENT_CODIFICACION = 3
                        THEN 'LA ARAUCANA SEG. VIDA'
                    WHEN cajas.ENT_CODIFICACION = 4
                        THEN 'GABRIELA M. SEG. VIDA'
                    WHEN cajas.ENT_CODIFICACION = 5
                        THEN 'JAVIERA C. SEG. VIDA'
                    WHEN cajas.ENT_CODIFICACION = 6
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
                tra_ccaf.CCAF_MTO_SEGU,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS,
                vt.USU_PAGO_RETROACTIVO
            FROM GTT_REC_VIR_TRA_PUB vt
                INNER JOIN REC_TRACCAF tra_ccaf ON
                    vt.REC_PERIODO = tra_ccaf.REC_PERIODO
                    AND vt.CON_RUT = tra_ccaf.CON_RUT
                    AND vt.CON_CORREL = tra_ccaf.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
                    AND vt.SUC_COD = tra_ccaf.SUC_CODIGO
                    AND vt.USU_CODIGO = tra_ccaf.USU_CODIGO
                    AND vt.TRA_RUT = tra_ccaf.TRA_RUT
                INNER JOIN REC_ENTPREV cajas ON
                    vt.CCAF_ADH = cajas.ENT_CODIFICACION
                    AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
                AND vt.CON_RUT = p_emp_rut
                AND vt.CON_CORREL = p_convenio
                AND vt.RPR_PROCESO = 1
                AND vt.TRA_RUT = p_rut_tra
                AND tra_ccaf.CCAF_MTO_SEGU > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

            -- Nuevo VOS20110630 Servicios Leg.Prepagados CCAF
            INSERT INTO GTT_REC_CERT_DETALLE_PUB
            SELECT
                vt.REC_PERIODO,
                vt.NRO_COMPROBANTE,
                vt.TIPO_IMPRE,
                vt.SUC_COD,
                vt.USU_CODIGO AS USU_COD,
                'I' AS TIPO_ENT,
                cajas.ENT_RUT,
                CASE
                    WHEN cajas.ENT_CODIFICACION = 1
                        THEN 'LOS ANDES SERV.LEG.PREPAG.'
                    WHEN cajas.ENT_CODIFICACION = 2
                        THEN 'LOS HEROES SERV.LEG.PREPAG.'
                    WHEN cajas.ENT_CODIFICACION = 3
                        THEN 'LA ARAUCANA SERV.LEG.PREPAG.'
                    WHEN cajas.ENT_CODIFICACION = 4
                        THEN 'GABRIELA M. SERV.LEG.PREPAG.'
                    WHEN cajas.ENT_CODIFICACION = 5
                        THEN 'JAVIERA C. SERV.LEG.PREPAG.'
                    WHEN cajas.ENT_CODIFICACION = 6
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
                tra_ccaf.CCAF_MTO_OTRO,
                vt.FEC_PAGO,
                NULL AS FOLIO_PLANILLA,
                vt.RAZ_SOC,
                NULL AS SALUD,
                0 AS MONTO_SIS,
                vt.USU_PAGO_RETROACTIVO
            FROM GTT_REC_VIR_TRA_PUB vt
                INNER JOIN REC_TRACCAF tra_ccaf ON
                    vt.REC_PERIODO = tra_ccaf.REC_PERIODO
                    AND vt.CON_RUT = tra_ccaf.CON_RUT
                    AND vt.CON_CORREL = tra_ccaf.CON_CORREL
                    AND vt.NRO_COMPROBANTE = tra_ccaf.NRO_COMPROBANTE
                    AND vt.SUC_COD = tra_ccaf.SUC_CODIGO
                    AND vt.USU_CODIGO = tra_ccaf.USU_CODIGO
                    AND vt.TRA_RUT = tra_ccaf.TRA_RUT
                INNER JOIN REC_ENTPREV cajas ON
                    vt.CCAF_ADH = cajas.ENT_CODIFICACION
                    AND tra_ccaf.ENT_RUT = cajas.ENT_RUT
            WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
                AND vt.CON_RUT = p_emp_rut
                AND vt.CON_CORREL = p_convenio
                AND vt.RPR_PROCESO = 1
                AND vt.TRA_RUT = p_rut_tra
                AND tra_ccaf.CCAF_MTO_OTRO > 0
            ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

        END IF;
    END IF;

    -- Cta Ahorro Prev. AFP: Remuneraciones antes de Julio 2009
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'J' AS TIPO_ENT,
        afps.ENT_RUT,
        'CTA.AHO.PREV. ' || SUBSTR(LTRIM(RTRIM(afps.ENT_NOMBRE)), 1, 20) AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        trab_afp.AFP_CTAAHO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.PREVISION = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
        AND trab_afp.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cta Ahorro Prev. AFP: Remuneraciones Después de Julio 2009
    INSERT INTO GTT_REC_CERT_DETALLE_PUB
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO AS USU_COD,
        'J' AS TIPO_ENT,
        afps.ENT_RUT,
        'CTA.AHO.PREV. ' || SUBSTR(LTRIM(RTRIM(afps.ENT_NOMBRE)), 1, 20) AS ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMP_AFP,
        trab_afp.AFP_CTAAHO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA_PUB vt
        INNER JOIN REC_TRAAFP trab_afp ON
            vt.REC_PERIODO = trab_afp.REC_PERIODO
            AND vt.CON_RUT = trab_afp.CON_RUT
            AND vt.CON_CORREL = trab_afp.CON_CORREL
            AND vt.NRO_COMPROBANTE = trab_afp.NRO_COMPROBANTE
            AND vt.SUC_COD = trab_afp.SUC_CODIGO
            AND vt.USU_CODIGO = trab_afp.USU_CODIGO
            AND vt.TRA_RUT = trab_afp.TRA_RUT
        INNER JOIN REC_ENTPREV afps ON
            vt.PREVISION = afps.ENT_CODIFICACION
            AND trab_afp.ENT_RUT = afps.ENT_RUT
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009 OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
        AND trab_afp.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Procesamiento de planillas usando cursor
    DECLARE
        v_numComp       NUMBER(7);

        -- Cursor para obtener períodos, tipos de impresión y comprobantes únicos
        CURSOR tra_cursor IS
            SELECT DISTINCT REC_PERIODO, TIPO_IMPRE, NRO_COMPROBANTE
            FROM GTT_REC_CERT_DETALLE_PUB;

    BEGIN
        -- Procesar cada registro del cursor
        FOR rec IN tra_cursor LOOP
            v_numComp := rec.NRO_COMPROBANTE;

            -- Procesar según tipo de impresión
            IF (rec.TIPO_IMPRE = 0 OR rec.TIPO_IMPRE = 1 OR rec.TIPO_IMPRE = 2) THEN
                INSERT INTO GTT_REC_PLANILLA_PUB (
                    REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
                )
                SELECT
                    vt.REC_PERIODO,
                    vt.NRO_COMPROBANTE,
                    planilla.ENT_RUT,
                    planilla.PLA_NRO_SERIE,
                    vt.SUC_COD,
                    vt.USU_COD
                FROM REC_PLANILLA planilla
                    INNER JOIN GTT_REC_CERT_DETALLE_PUB vt ON
                        planilla.REC_PERIODO = vt.REC_PERIODO
                        AND planilla.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                        AND planilla.ENT_RUT = vt.ENT_RUT
                WHERE vt.REC_PERIODO = rec.REC_PERIODO
                  AND vt.TIPO_IMPRE = rec.TIPO_IMPRE
                  AND vt.NRO_COMPROBANTE = v_numComp
                ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;

            ELSIF (rec.TIPO_IMPRE = 3) THEN
                INSERT INTO GTT_REC_PLANILLA_PUB (
                    REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
                )
                SELECT
                    vt.REC_PERIODO,
                    vt.NRO_COMPROBANTE,
                    planilla.ENT_RUT,
                    planilla.PLA_NRO_SERIE,
                    vt.SUC_COD,
                    vt.USU_COD
                FROM REC_PLANILLA planilla
                    INNER JOIN GTT_REC_CERT_DETALLE_PUB vt ON
                        planilla.REC_PERIODO = vt.REC_PERIODO
                        AND planilla.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                        AND planilla.SUC_CODIGO = vt.SUC_COD
                        AND planilla.ENT_RUT = vt.ENT_RUT
                WHERE vt.REC_PERIODO = rec.REC_PERIODO
                  AND vt.TIPO_IMPRE = rec.TIPO_IMPRE
                  AND vt.NRO_COMPROBANTE = v_numComp
                ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;

            ELSIF (rec.TIPO_IMPRE = 4) THEN
                INSERT INTO GTT_REC_PLANILLA_PUB (
                    REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
                )
                SELECT
                    vt.REC_PERIODO,
                    vt.NRO_COMPROBANTE,
                    planilla.ENT_RUT,
                    planilla.PLA_NRO_SERIE,
                    vt.SUC_COD,
                    vt.USU_COD
                FROM REC_PLANILLA planilla
                    INNER JOIN GTT_REC_CERT_DETALLE_PUB vt ON
                        planilla.REC_PERIODO = vt.REC_PERIODO
                        AND planilla.NRO_COMPROBANTE = vt.NRO_COMPROBANTE
                        AND planilla.USU_CODIGO = vt.USU_COD
                        AND planilla.ENT_RUT = vt.ENT_RUT
                WHERE vt.REC_PERIODO = rec.REC_PERIODO
                  AND vt.TIPO_IMPRE = rec.TIPO_IMPRE
                  AND vt.NRO_COMPROBANTE = v_numComp
                ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_COD;
            END IF;

        END LOOP;
    END;

    -- Actualizar folio de planilla en los detalles de certificación
    UPDATE GTT_REC_CERT_DETALLE_PUB cd
    SET FOLIO_PLANILLA = (
        SELECT p.PLA_NRO_SERIE
        FROM GTT_REC_PLANILLA_PUB p
        WHERE cd.REC_PERIODO = p.REC_PERIODO
          AND cd.NRO_COMPROBANTE = p.NRO_COMPROBANTE
          AND cd.ENT_RUT = p.ENT_RUT
          AND cd.SUC_COD = p.SUC_COD
          AND cd.USU_COD = p.USU_COD
    )
    WHERE EXISTS (
        SELECT 1
        FROM GTT_REC_PLANILLA_PUB p
        WHERE cd.REC_PERIODO = p.REC_PERIODO
          AND cd.NRO_COMPROBANTE = p.NRO_COMPROBANTE
          AND cd.ENT_RUT = p.ENT_RUT
          AND cd.SUC_COD = p.SUC_COD
          AND cd.USU_COD = p.USU_COD
    );

    -- Abrir cursor con los resultados finales ordenados
    OPEN p_cursor FOR
        SELECT *
        FROM GTT_REC_CERT_DETALLE_PUB
        ORDER BY REC_PERIODO, SUC_COD, USU_COD, TIPO_ENT;

    -- Commit final para confirmar todos los cambios
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Manejo de errores
        ROLLBACK;

        -- Las tablas temporales se limpian automáticamente
        -- al hacer ROLLBACK debido a ON COMMIT DELETE ROWS

        -- Re-lanzar la excepción
        RAISE;

END PRC_CERTCOT_TRAB_PUB;
