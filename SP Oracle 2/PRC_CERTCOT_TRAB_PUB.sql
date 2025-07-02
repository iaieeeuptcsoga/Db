-- Eliminar procedimiento si existe
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE PRC_CERTCOT_TRAB_PUB';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN -- ORA-04043: object does not exist
            RAISE;
        END IF;
END;
/

-- Eliminar cualquier versión con sufijo numérico
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE PRC_CERTCOT_TRAB_PUB1';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN -- ORA-04043: object does not exist
            RAISE;
        END IF;
END;
/

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
    v_nomTra        VARCHAR2(40);
    v_apeTra        VARCHAR2(40);
    v_numComp       NUMBER(7);
    
BEGIN
    -- Limpiar tablas temporales globales
    DELETE FROM GTT_REC_VIR_TRA;
    DELETE FROM GTT_REC_VIR_TRA2;
    DELETE FROM GTT_REC_CERT_DETALLE;
    DELETE FROM GTT_REC_PLANILLA;
    DELETE FROM GTT_REC_SUCURSALES;
    
    -- Lógica para determinar sucursales según tipo de consulta
    IF p_tipoCon = 2 THEN
        -- Consulta por impresión por sucursal
        -- NOTA: La tabla DET_CTA_USU no existe en el modelo Oracle
        -- Se debe implementar la lógica correcta según el modelo de datos disponible
        -- Por ahora se usa una consulta alternativa basada en las tablas disponibles
        INSERT INTO GTT_REC_SUCURSALES (COD_SUC)
        SELECT DISTINCT SUC_CODIGO
        FROM REC_SUCURSAL
        WHERE CON_RUT = p_emp_rut 
          AND CON_CORREL = p_convenio
          AND USU_CODIGO = p_Parametro;
          
    ELSIF p_tipoCon = 3 THEN
        -- Consulta por impresión masiva por sucursal
        INSERT INTO GTT_REC_SUCURSALES (COD_SUC)
        VALUES (p_Parametro);
    END IF;
    
    -- Commit para hacer disponibles los datos en las tablas temporales
    COMMIT;
    
    -- Obtiene los datos del trabajador
    IF p_convenio >= 600 AND p_convenio <= 699 THEN
        IF p_tipoCon = 1 THEN
            -- Consulta individual - Proceso 1,3,4
            INSERT INTO GTT_REC_VIR_TRA2
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
            INSERT INTO GTT_REC_VIR_TRA2
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
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES)
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
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES)
                AND trabajador.usu_codigo = dato_usuario.usu_codigo
            ORDER BY 1, 22, 23;  -- rec_periodo, suc_codigo, usu_codigo
        END IF;
        
    ELSE  -- Convenio < 600 o > 699
        IF p_tipoCon = 1 THEN
            -- Consulta individual - Proceso 1,3,4
            INSERT INTO GTT_REC_VIR_TRA2
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
            INSERT INTO GTT_REC_VIR_TRA2
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
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES)
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
                AND trabajador.suc_codigo IN (SELECT COD_SUC FROM GTT_REC_SUCURSALES)
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
    
    -- Si el tipo de consulta es > a 1, traspasa los datos a la tabla GTT_REC_VIR_TRA
    IF p_parametro2 IS NOT NULL THEN
        -- Cuando es agrupado por dato usuario
        INSERT INTO GTT_REC_VIR_TRA
        SELECT * FROM GTT_REC_VIR_TRA2
        WHERE USU_CODIGO = p_parametro2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    ELSE
        -- Cuando es agrupado por sucursal
        INSERT INTO GTT_REC_VIR_TRA
        SELECT * FROM GTT_REC_VIR_TRA2
        ORDER BY REC_PERIODO, SUC_COD, USU_CODIGO;
    END IF;

    -- Obtiene el nombre del trabajador correspondiente al ultimo periodo registrado
    SELECT TRA_NOMBRE, TRA_APE
    INTO v_nomTra, v_apeTra
    FROM (
        SELECT TRA_NOMBRE, TRA_APE
        FROM GTT_REC_VIR_TRA
        ORDER BY REC_PERIODO DESC
    )
    WHERE ROWNUM = 1;

    -- Actualiza todos los registros con el nombre del trabajador del último período
    UPDATE GTT_REC_VIR_TRA
    SET TRA_NOMBRE = TRIM(v_nomTra),
        TRA_APE = TRIM(v_apeTra);

    -- Cotización AFP: Gratificaciones
    -- VOS, por incorporación de Rem_imp_AFP
    -- Se deja este solo para el proceso de Gratificaciones
    -- VOS2090928 agrego NVL(REC_TRAAFP.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre
    INSERT INTO GTT_REC_CERT_DETALLE (
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
        MONTO_SIS,
        USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
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
        trab_afp.AFP_COT_OBLIGATORIA AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND vt.RPR_PROCESO = 2
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP: Remuneraciones antes de Julio 2009
    -- VOS, por incorporación de Rem_imp_AFP
    -- Se agrega para el proceso de remuneraciones que lea del campo Rem_impo
    -- para períodos menores a Julio del 2009
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'A' AS TIPO_ENT,
        afps.ENT_RUT,
        afps.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        trab_afp.AFP_COT_OBLIGATORIA AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) < 2009
             OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) < 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP: Remuneraciones después de Julio 2009
    -- VOS, por incorporación de Rem_imp_AFP
    -- Se agrega para el proceso de remuneraciones que lea del campo rem_imp_afp
    -- para períodos mayores o iguales a Julio del 2009
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'A' AS TIPO_ENT,
        afps.ENT_RUT,
        afps.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMP_AFP,
        trab_afp.AFP_COT_OBLIGATORIA AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        NVL(trab_afp.AFP_SEG_INV_SOBRE, 0) AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009
             OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización INP: Previsión
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
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
        tra_inp.INP_COT_PREV AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAINP tra_inp ON
            vt.REC_PERIODO = tra_inp.REC_PERIODO
            AND vt.CON_RUT = tra_inp.CON_RUT
            AND vt.CON_CORREL = tra_inp.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_inp.SUC_CODIGO
            AND vt.USU_CODIGO = tra_inp.USU_CODIGO
            AND vt.TRA_RUT = tra_inp.TRA_RUT
        INNER JOIN REC_ENTPREV inp ON
            tra_inp.ENT_RUT = inp.ENT_RUT

    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización INP: Fondo
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
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
                THEN vt.REM_IMPO_INP
           WHEN vt.RPR_PROCESO = 1
                AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                THEN vt.REM_IMPO_INP
           ELSE vt.REM_IMPO
        END AS REM_IMPO,
        tra_inp.INP_COT_FONASA AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAINP tra_inp ON
            vt.REC_PERIODO = tra_inp.REC_PERIODO
            AND vt.CON_RUT = tra_inp.CON_RUT
            AND vt.CON_CORREL = tra_inp.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_inp.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_inp.SUC_CODIGO
            AND vt.USU_CODIGO = tra_inp.USU_CODIGO
            AND vt.TRA_RUT = tra_inp.TRA_RUT
        INNER JOIN REC_ENTPREV isapres ON
            tra_inp.ENT_RUT = isapres.ENT_RUT

    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.SALUD = 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización ISAPRE
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'C' AS TIPO_ENT,
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
           WHEN vt.RPR_PROCESO = 1
                AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                THEN vt.REM_IMPO_ISA
           ELSE vt.REM_IMPO
        END AS REM_IMPO,
        tra_isapre.ISA_COT_APAGAR AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        vt.TRA_ISA_DEST AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
        INNER JOIN REC_TRAISA tra_isapre ON
            vt.REC_PERIODO = tra_isapre.REC_PERIODO
            AND vt.CON_RUT = tra_isapre.CON_RUT
            AND vt.CON_CORREL = tra_isapre.CON_CORREL
            AND vt.NRO_COMPROBANTE = tra_isapre.NRO_COMPROBANTE
            AND vt.SUC_COD = tra_isapre.SUC_CODIGO
            AND vt.USU_CODIGO = tra_isapre.USU_CODIGO
            AND vt.TRA_RUT = tra_isapre.TRA_RUT
        INNER JOIN REC_ENTPREV isapres ON
            tra_isapre.ENT_RUT = isapres.ENT_RUT

    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.SALUD > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización CCAF (Cajas de Compensación de Asignación Familiar)
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'D' AS TIPO_ENT,
        ccaf.ENT_RUT,
        ccaf.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        CASE
           WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                THEN vt.REM_IMPO_CCAF
           WHEN vt.RPR_PROCESO = 1
                AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                THEN vt.REM_IMPO_CCAF
           ELSE vt.REM_IMPO
        END AS REM_IMPO,
        (CASE
           WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                THEN (vt.REM_IMPO_CCAF * 0.6) / 100
           WHEN vt.RPR_PROCESO = 1
                AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                THEN (vt.REM_IMPO_CCAF * 0.6) / 100
           ELSE (vt.REM_IMPO * 0.6) / 100
        END) AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
        CROSS JOIN REC_ENTPREV ccaf
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.CCAF_ADH > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización Fondo de Cesantía
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'H' AS TIPO_ENT,
        afc.ENT_RUT,
        afc.ENT_NOMBRE,
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_FC,
        (vt.REM_IMPO_FC * 0.6) / 100 AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
        CROSS JOIN REC_ENTPREV afc
    WHERE vt.REC_PERIODO BETWEEN p_fec_ini AND p_fec_ter
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO IN (1,2)
        AND vt.TRA_RUT = p_rut_tra
        AND vt.REM_IMPO_FC >= 0
        AND vt.REM_IMPO_FC IS NOT NULL
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización AFP - Trabajo pesado
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'E' AS TIPO_ENT,
        afps.ENT_RUT,
        'TRAB.PES. ' || SUBSTR(TRIM(afps.ENT_NOMBRE), 1, 20),
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO,
        trab_afp.AFP_MTO_TRA_PESADO AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND vt.PREVISION > 0
        AND trab_afp.AFP_MTO_TRA_PESADO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización Accidente del trabajo (Mutual)
    -- VOS 20100125 por UF 64,7 se incorporó AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
    -- VOS 20100204 por solicitud de FR se agregó validación de TOTAL_MUTUAL
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT DISTINCT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'F' AS TIPO_ENT,
        iat.ENT_RUT,
        CASE iat.ENT_CODIFICACION
            WHEN 4 THEN 'IST'
            WHEN 2 THEN 'MUTUAL DE SEGURIDAD'
            WHEN 3 THEN 'ACHS'
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
           WHEN vt.RPR_PROCESO = 1
                AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                THEN vt.REM_IMPO_MUTUAL
           ELSE vt.REM_IMPO
        END AS REM_IMPO,
        CASE
           WHEN ((EXTRACT(YEAR FROM vt.REC_PERIODO) = 2013 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 11)
                OR (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2014))
                THEN (vt.REM_IMPO_MUTUAL * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100
           WHEN vt.RPR_PROCESO = 1
                AND (EXTRACT(YEAR FROM vt.REC_PERIODO) >= 2010)
                THEN (vt.REM_IMPO_MUTUAL * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100
           ELSE (vt.REM_IMPO * (vt.TASA_COT_MUT + vt.TASA_ADIC_MUT)) / 100
        END AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND (tm.TSUC_NUMTRAB > 0 OR tm.TSUC_REM_IMPONIBLE > 0 OR tm.TSUC_TOT_COTIZACION > 0)
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización APV (Ahorro Previsional Voluntario)
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'G' AS TIPO_ENT,
        afps.ENT_RUT,
        SUBSTR(TRIM(afps.ENT_NOMBRE), 1, 20) || ' (APV)',
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMPO_DEPCONV,
        trab_afp.AFP_COT_VOLUNTARIA AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND vt.TRA_INS_APV > 0
        AND trab_afp.AFP_COT_VOLUNTARIA > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Cotización Cuenta de Ahorro AFP
    INSERT INTO GTT_REC_CERT_DETALLE (
        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
        RAZ_SOC, SALUD, MONTO_SIS, USU_PAGO_RETROACTIVO
    )
    SELECT
        vt.REC_PERIODO,
        vt.NRO_COMPROBANTE,
        vt.TIPO_IMPRE,
        vt.SUC_COD,
        vt.USU_CODIGO,
        'I' AS TIPO_ENT,
        afps.ENT_RUT,
        'CTA.AHORRO ' || SUBSTR(TRIM(afps.ENT_NOMBRE), 1, 20),
        vt.TRA_RUT,
        vt.TRA_DIG,
        vt.TRA_NOMBRE,
        vt.TRA_APE,
        vt.DIAS_TRAB,
        vt.REM_IMP_AFP,
        trab_afp.AFP_CTAAHO AS MONTO_COTIZADO,
        vt.FEC_PAGO,
        NULL AS FOLIO_PLANILLA,
        vt.RAZ_SOC,
        NULL AS SALUD,
        0 AS MONTO_SIS,
        vt.USU_PAGO_RETROACTIVO
    FROM GTT_REC_VIR_TRA vt
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
        AND (EXTRACT(YEAR FROM vt.REC_PERIODO) > 2009
             OR (EXTRACT(YEAR FROM vt.REC_PERIODO) = 2009 AND EXTRACT(MONTH FROM vt.REC_PERIODO) >= 7))
        AND vt.CON_RUT = p_emp_rut
        AND vt.CON_CORREL = p_convenio
        AND vt.RPR_PROCESO = 1
        AND vt.TRA_RUT = p_rut_tra
        AND vt.PREVISION > 0
        AND trab_afp.AFP_CTAAHO > 0
    ORDER BY vt.REC_PERIODO, vt.SUC_COD, vt.USU_CODIGO;

    -- Variables para el cursor de planillas
    DECLARE
        v_periodo DATE;
        v_tipoImp NUMBER(1);
        v_numComp NUMBER(7);

        -- Cursor para procesar planillas
        CURSOR tra_cursor IS
            SELECT DISTINCT REC_PERIODO, TIPO_IMPRE, NRO_COMPROBANTE
            FROM GTT_REC_CERT_DETALLE;
    BEGIN
        -- Procesar planillas usando cursor
        FOR rec IN tra_cursor LOOP
            v_periodo := rec.REC_PERIODO;
            v_tipoImp := rec.TIPO_IMPRE;
            v_numComp := rec.NRO_COMPROBANTE;

            -- Insertar planillas AFP
            INSERT INTO GTT_REC_PLANILLA (
                REC_PERIODO, NRO_COMPROBANTE, ENT_RUT, PLA_NRO_SERIE, SUC_COD, USU_COD
            )
            SELECT DISTINCT
                v_periodo,
                v_numComp,
                cd.ENT_RUT,
                pl.PLA_NRO_SERIE,
                cd.SUC_COD,
                cd.USU_COD
            FROM GTT_REC_CERT_DETALLE cd
                INNER JOIN REC_PLANILLA pl ON
                    cd.REC_PERIODO = pl.REC_PERIODO
                    AND cd.NRO_COMPROBANTE = pl.NRO_COMPROBANTE
                    AND cd.ENT_RUT = pl.ENT_RUT
                    AND cd.SUC_COD = pl.SUC_CODIGO
                    AND cd.USU_COD = pl.USU_CODIGO
            WHERE cd.REC_PERIODO = v_periodo
                AND cd.TIPO_IMPRE = v_tipoImp
                AND cd.NRO_COMPROBANTE = v_numComp
                AND cd.TIPO_ENT = 'A'
                AND NOT EXISTS (
                    SELECT 1 FROM GTT_REC_PLANILLA gp
                    WHERE gp.REC_PERIODO = v_periodo
                        AND gp.NRO_COMPROBANTE = v_numComp
                        AND gp.ENT_RUT = cd.ENT_RUT
                        AND gp.SUC_COD = cd.SUC_COD
                        AND gp.USU_COD = cd.USU_COD
                );
        END LOOP;
    END;

    -- Actualizar folio de planilla en cert_detalle
    UPDATE GTT_REC_CERT_DETALLE cd
    SET FOLIO_PLANILLA = (
        SELECT p.PLA_NRO_SERIE
        FROM GTT_REC_PLANILLA p
        WHERE cd.REC_PERIODO = p.REC_PERIODO
            AND cd.NRO_COMPROBANTE = p.NRO_COMPROBANTE
            AND cd.ENT_RUT = p.ENT_RUT
            AND cd.SUC_COD = p.SUC_COD
            AND cd.USU_COD = p.USU_COD
    )
    WHERE EXISTS (
        SELECT 1 FROM GTT_REC_PLANILLA p
        WHERE cd.REC_PERIODO = p.REC_PERIODO
            AND cd.NRO_COMPROBANTE = p.NRO_COMPROBANTE
            AND cd.ENT_RUT = p.ENT_RUT
            AND cd.SUC_COD = p.SUC_COD
            AND cd.USU_COD = p.USU_COD
    );

    -- Resultado final: Seleccionar todos los registros del certificado
    OPEN p_cursor FOR
        SELECT * FROM GTT_REC_CERT_DETALLE
        ORDER BY REC_PERIODO, SUC_COD, USU_COD, TIPO_ENT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END PRC_CERTCOT_TRAB_PUB;
/
