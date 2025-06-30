-- =====================================================
-- SCRIPT PARA CERTIFICADO COTIZACIONES
-- Sistema: REC - Recaudación Oracle
-- =====================================================

-- Configuración inicial
SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;
SET ECHO OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

-- =====================================================
-- BLOQUE PL/SQL PRINCIPAL
-- =====================================================

DECLARE
    -- Variables para el cursor de resultados
    v_cursor SYS_REFCURSOR;
    
    -- Variables para los parámetros de entrada
    v_fec_ini DATE;
    v_fec_ter DATE;
    v_emp_rut NUMBER;
    v_convenio NUMBER;
    v_rut_tra NUMBER;
    v_tipo_con NUMBER;
    
    -- Variables para leer el cursor de resultados - CORREGIDAS
    v_rec_periodo DATE;
    v_nro_comprobante NUMBER;
    v_tipo_impre NUMBER;
    v_suc_cod VARCHAR2(6);
    v_usu_cod VARCHAR2(6);
    v_tipo_ent VARCHAR2(1);
    v_ent_rut NUMBER;
    v_ent_nombre VARCHAR2(255);
    v_tra_rut NUMBER;
    v_tra_dig VARCHAR2(1);
    v_tra_nombre VARCHAR2(80);  -- CAMBIADO: de 40 a 80
    v_tra_ape VARCHAR2(80);     -- CAMBIADO: de 40 a 80
    v_dias_trab NUMBER;
    v_rem_impo NUMBER;
    v_monto_cotizado NUMBER;
    v_fec_pago DATE;
    v_folio_planilla NUMBER;
    v_raz_soc VARCHAR2(80);     -- CAMBIADO: de 40 a 80
    v_salud NUMBER;
    v_monto_sis NUMBER;
    
    -- Variables de control
    v_contador NUMBER := 0;
    v_total_cotizaciones NUMBER := 0;
    
BEGIN
    -- =====================================================
    -- PARÁMETROS DE CONSULTA
    -- =====================================================
    v_fec_ini := DATE '2000-07-31';        
    v_fec_ter := DATE '2003-07-31';        
    v_emp_rut := 83146800;                 
    v_convenio := 1;                       
    v_rut_tra := 3221253;                  
    v_tipo_con := 1;                       
    -- =====================================================
    
    -- Mostrar información inicial
    DBMS_OUTPUT.PUT_LINE('=== CERTIFICADO DE COTIZACIONES PREVISIONALES ===');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('PARÁMETROS DE CONSULTA:');
    DBMS_OUTPUT.PUT_LINE('- Período: ' || TO_CHAR(v_fec_ini, 'DD/MM/YYYY') || ' al ' || TO_CHAR(v_fec_ter, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('- RUT Empresa: ' || TO_CHAR(v_emp_rut, 'FM99,999,999'));
    DBMS_OUTPUT.PUT_LINE('- Convenio: ' || v_convenio);
    DBMS_OUTPUT.PUT_LINE('- RUT Trabajador: ' || TO_CHAR(v_rut_tra, 'FM99,999,999'));
    DBMS_OUTPUT.PUT_LINE('- Tipo Consulta: ' || 
        CASE v_tipo_con 
            WHEN 0 THEN 'Todas las entidades'
            WHEN 1 THEN 'Solo AFP'
            WHEN 2 THEN 'Solo Salud'
            ELSE 'Tipo no definido'
        END);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Validar fechas
    IF v_fec_ini > v_fec_ter THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: La fecha de inicio no puede ser mayor a la fecha de término.');
        RETURN;
    END IF;
    
    -- Verificar existencia de empresa
    DECLARE
        v_count_emp NUMBER;
        v_nombre_emp VARCHAR2(255);
    BEGIN
        SELECT COUNT(*)
        INTO v_count_emp
        FROM REC_EMPRESA
        WHERE CON_RUT = v_emp_rut;
          
        IF v_count_emp = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ADVERTENCIA: No se encontró la empresa con RUT ' || v_emp_rut);
            DBMS_OUTPUT.PUT_LINE('');
        ELSE
            DBMS_OUTPUT.PUT_LINE('EMPRESA ENCONTRADA con RUT: ' || v_emp_rut);
            DBMS_OUTPUT.PUT_LINE('');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al verificar empresa: ' || SQLERRM);
    END;
    
    -- Verificar existencia de trabajador
    DECLARE
        v_count_tra NUMBER;
        v_nombre_tra VARCHAR2(255);
    BEGIN
        SELECT COUNT(*), MAX(SUBSTR(TRA_NOMTRA || ' ' || TRA_APETRA, 1, 80))
        INTO v_count_tra, v_nombre_tra
        FROM REC_TRABAJADOR
        WHERE TRA_RUT = v_rut_tra;
          
        IF v_count_tra = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ADVERTENCIA: No se encontró el trabajador con RUT ' || v_rut_tra);
            DBMS_OUTPUT.PUT_LINE('');
        ELSE
            DBMS_OUTPUT.PUT_LINE('TRABAJADOR: ' || v_nombre_tra);
            DBMS_OUTPUT.PUT_LINE('');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al verificar trabajador: ' || SQLERRM);
    END;
    
    -- Llamar al procedimiento
    DBMS_OUTPUT.PUT_LINE('Ejecutando consulta...');
    DBMS_OUTPUT.PUT_LINE('');
    
    BEGIN
        PRC_REC_CERTCOT_TRAB(
            p_fec_ini => v_fec_ini,
            p_fec_ter => v_fec_ter,
            p_emp_rut => v_emp_rut,
            p_convenio => v_convenio,
            p_rut_tra => v_rut_tra,
            p_tipoCon => v_tipo_con,
            p_parametro => NULL,
            p_parametro2 => NULL,
            p_parametro3 => NULL,
            p_cursor => v_cursor
        );
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR al ejecutar el procedimiento: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
            RETURN;
    END;
    
    -- Mostrar encabezado de resultados
    DBMS_OUTPUT.PUT_LINE('=== RESULTADOS ===');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(RPAD('PERÍODO', 8) || ' | ' ||
                         RPAD('TIPO', 4) || ' | ' ||
                         RPAD('ENTIDAD', 25) || ' | ' ||
                         RPAD('TRABAJADOR', 12) || ' | ' ||
                         LPAD('DÍAS', 4) || ' | ' ||
                         LPAD('REM.IMPONIBLE', 15) || ' | ' ||
                         LPAD('COTIZACIÓN', 12) || ' | ' ||
                         RPAD('FOLIO', 8));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 8, '-') || '-+-' ||
                         RPAD('-', 4, '-') || '-+-' ||
                         RPAD('-', 25, '-') || '-+-' ||
                         RPAD('-', 12, '-') || '-+-' ||
                         LPAD('-', 4, '-') || '-+-' ||
                         LPAD('-', 15, '-') || '-+-' ||
                         LPAD('-', 12, '-') || '-+-' ||
                         RPAD('-', 8, '-'));
    
    -- Leer y mostrar los resultados del cursor
    LOOP
        BEGIN
            FETCH v_cursor INTO 
                v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
                v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig, 
                v_tra_nombre, v_tra_ape, v_dias_trab, v_rem_impo, v_monto_cotizado,
                v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis;
                
            EXIT WHEN v_cursor%NOTFOUND;
            
            -- Incrementar contador y sumar totales
            v_contador := v_contador + 1;
            v_total_cotizaciones := v_total_cotizaciones + NVL(v_monto_cotizado, 0);
            
            -- Mostrar fila de resultados
            DBMS_OUTPUT.PUT_LINE(
                RPAD(TO_CHAR(v_rec_periodo, 'MM/YYYY'), 8) || ' | ' ||
                RPAD(NVL(v_tipo_ent, 'N/A'), 4) || ' | ' ||
                RPAD(SUBSTR(NVL(v_ent_nombre, 'N/A'), 1, 25), 25) || ' | ' ||
                RPAD(TO_CHAR(v_tra_rut), 12) || ' | ' ||
                LPAD(NVL(TO_CHAR(v_dias_trab), '0'), 4) || ' | ' ||
                LPAD(TO_CHAR(NVL(v_rem_impo, 0), 'FM999,999,999'), 15) || ' | ' ||
                LPAD(TO_CHAR(NVL(v_monto_cotizado, 0), 'FM999,999,999'), 12) || ' | ' ||
                RPAD(NVL(TO_CHAR(v_folio_planilla), 'N/A'), 8)
            );
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR al procesar fila: ' || SQLERRM);
                EXIT;
        END;
    END LOOP;
    
    -- Cerrar cursor
    IF v_cursor%ISOPEN THEN
        CLOSE v_cursor;
    END IF;
    
    -- Mostrar resumen
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== RESUMEN ===');
    DBMS_OUTPUT.PUT_LINE('Total de registros encontrados: ' || v_contador);
    DBMS_OUTPUT.PUT_LINE('Total cotizaciones: $' || TO_CHAR(v_total_cotizaciones, 'FM999,999,999,999'));
    
    IF v_contador = 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('No se encontraron registros con los parámetros especificados.');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('SUGERENCIAS:');
        DBMS_OUTPUT.PUT_LINE('- Verifique que el RUT de la empresa sea correcto');
        DBMS_OUTPUT.PUT_LINE('- Verifique que el RUT del trabajador sea correcto');
        DBMS_OUTPUT.PUT_LINE('- Verifique que el período seleccionado tenga datos');
        DBMS_OUTPUT.PUT_LINE('- Verifique que el número de convenio sea correcto');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== CONSULTA COMPLETADA ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('ERROR GENERAL: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        
        RAISE;
END;
/

-- =====================================================
-- CONSULTAS DE AYUDA PARA ENCONTRAR DATOS
-- =====================================================

-- Mostrar empresas disponibles
SELECT 'EMPRESAS DISPONIBLES (muestra):' AS INFO FROM DUAL;

SELECT DISTINCT CON_RUT AS RUT_EMPRESA
FROM REC_EMPRESA 
WHERE ROWNUM <= 100
ORDER BY CON_RUT;

-- Mostrar trabajadores de ejemplo
SELECT 'TRABAJADORES DE EJEMPLO:' AS INFO FROM DUAL;

SELECT DISTINCT TRA_RUT, TRA_NOMTRA || ' ' || TRA_APETRA AS NOMBRE
FROM REC_TRABAJADOR 
WHERE ROWNUM <= 100
ORDER BY TRA_RUT;

-- Mostrar períodos disponibles
SELECT 'PERÍODOS DISPONIBLES:' AS INFO FROM DUAL;

SELECT DISTINCT TO_CHAR(REC_PERIODO, 'MM/YYYY') AS PERIODO
FROM REC_TRABAJADOR
WHERE ROWNUM <= 12
ORDER BY REC_PERIODO;

-- =====================================================
-- SCRIPT RÁPIDO DE PRUEBA
-- =====================================================

PROMPT 
PROMPT =====================================================
PROMPT SCRIPT DE PRUEBA RÁPIDA
PROMPT =====================================================
PROMPT 
PROMPT Para una prueba rápida sin modificar el código principal,
PROMPT ejecute este bloque con parámetros específicos:
PROMPT 

/*
-- EJEMPLO DE USO RÁPIDO:
DECLARE
    v_cursor SYS_REFCURSOR;
    v_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA RÁPIDA ===');
    
    -- Usar estos parámetros para prueba rápida
    PRC_REC_CERTCOT_TRAB(
        p_fec_ini => DATE '2009-01-01',
        p_fec_ter => DATE '2009-12-31',
        p_emp_rut => 84694600,
        p_convenio => 1,
        p_rut_tra => 11828995,
        p_tipoCon => 0,
        p_parametro => NULL,
        p_parametro2 => NULL,
        p_parametro3 => NULL,
        p_cursor => v_cursor
    );
    
    -- Contar resultados
    LOOP
        FETCH v_cursor INTO 
            v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
            v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig, 
            v_tra_nombre, v_tra_ape, v_dias_trab, v_rem_impo, v_monto_cotizado,
            v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis;
            
        EXIT WHEN v_cursor%NOTFOUND;
        v_count := v_count + 1;
    END LOOP;
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Registros encontrados: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Procedimiento ejecutado correctamente');
END;
/
*/

-- =====================================================
-- INSTRUCCIONES DE USO
-- =====================================================

SELECT '======================================================' AS INSTRUCCIONES FROM DUAL
UNION ALL SELECT 'INSTRUCCIONES DE USO' FROM DUAL
UNION ALL SELECT '======================================================' FROM DUAL
UNION ALL SELECT '' FROM DUAL
UNION ALL SELECT '1. Localice la sección "MODIFIQUE ESTOS VALORES"' FROM DUAL
UNION ALL SELECT '2. Cambie los valores según sus necesidades:' FROM DUAL
UNION ALL SELECT '   - v_fec_ini: Fecha de inicio' FROM DUAL
UNION ALL SELECT '   - v_fec_ter: Fecha de término' FROM DUAL
UNION ALL SELECT '   - v_emp_rut: RUT de empresa (sin DV)' FROM DUAL
UNION ALL SELECT '   - v_convenio: Número de convenio (usar 1)' FROM DUAL
UNION ALL SELECT '   - v_rut_tra: RUT de trabajador (sin DV)' FROM DUAL
UNION ALL SELECT '   - v_tipo_con: 0=Todos, 1=AFP, 2=Salud' FROM DUAL
UNION ALL SELECT '3. Ejecute todo el script' FROM DUAL
UNION ALL SELECT '4. Revise los resultados en la consola' FROM DUAL;


-- =====================================================
-- Consultas varias 
-- ===================================================== 


SELECT 
    TRA_APETRA || ' ' || TRA_NOMTRA as NOMBRE_COMPLETO,
    LENGTH(TRA_APETRA || ' ' || TRA_NOMTRA) as LONGITUD
FROM REC_TRABAJADOR
WHERE TRA_RUT = 3221253;
-- 1. ¿Qué empresas tienes?
SELECT DISTINCT CON_RUT, EMP_RAZSOC 
FROM REC_EMPRESA 
WHERE ROWNUM <= 10;

-- 2. ¿Qué trabajadores tienes?
SELECT DISTINCT TRA_RUT, TRA_NOMTRA, TRA_APETRA 
FROM REC_TRABAJADOR 
WHERE ROWNUM <= 10;

-- 3. ¿Qué rangos de fechas tienes?
SELECT MIN(REC_PERIODO), MAX(REC_PERIODO) 
FROM REC_EMPRESA;

-- 4. ¿Qué convenios tienes?
SELECT DISTINCT CON_CORREL 
FROM REC_EMPRESA;

-- =====================================================
-- PASO 1: VERIFICAR RANGOS DE FECHAS DISPONIBLES
-- =====================================================
SELECT 
    'REC_EMPRESA' as TABLA,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX,
    COUNT(DISTINCT REC_PERIODO) as PERIODOS_DISTINTOS,
    COUNT(*) as TOTAL_REGISTROS
FROM REC_EMPRESA

UNION ALL

SELECT 
    'REC_TRABAJADOR' as TABLA,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX,
    COUNT(DISTINCT REC_PERIODO) as PERIODOS_DISTINTOS,
    COUNT(*) as TOTAL_REGISTROS
FROM REC_TRABAJADOR;

-- =====================================================
-- PASO 2: BUSCAR COMBINACIONES BÁSICAS (SIN FILTRO DE FECHA)
-- =====================================================
SELECT 
    e.CON_RUT,
    e.CON_CORREL,
    COUNT(DISTINCT t.TRA_RUT) as TRABAJADORES_DISTINTOS,
    COUNT(DISTINCT e.REC_PERIODO) as PERIODOS_DISTINTOS,
    MIN(e.REC_PERIODO) as FECHA_MIN,
    MAX(e.REC_PERIODO) as FECHA_MAX,
    COUNT(*) as TOTAL_REGISTROS
FROM REC_EMPRESA e
INNER JOIN REC_TRABAJADOR t ON 
    e.REC_PERIODO = t.REC_PERIODO
    AND e.CON_RUT = t.CON_RUT
    AND e.CON_CORREL = t.CON_CORREL
    AND e.RPR_PROCESO = t.RPR_PROCESO
    AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
WHERE e.RPR_PROCESO IN (1,2,3,4)
GROUP BY e.CON_RUT, e.CON_CORREL
ORDER BY COUNT(*) DESC
FETCH FIRST 5 ROWS ONLY;

-- =====================================================
-- PASO 3: OBTENER UN CASO ESPECÍFICO PARA PRUEBA
-- =====================================================
SELECT 
    e.CON_RUT as EMPRESA_RUT,
    e.CON_CORREL as CONVENIO,
    t.TRA_RUT as TRABAJADOR_RUT,
    e.REC_PERIODO as PERIODO,
    e.RPR_PROCESO,
    '-- PARÁMETROS PARA EL SP:' as COMENTARIO,
    'v_emp_rut := ' || e.CON_RUT || ';' as PARAM_1,
    'v_convenio := ' || e.CON_CORREL || ';' as PARAM_2,
    'v_rut_tra := ' || t.TRA_RUT || ';' as PARAM_3,
    'v_fec_ini := DATE ''' || TO_CHAR(e.REC_PERIODO, 'YYYY-MM-DD') || ''';' as PARAM_4,
    'v_fec_ter := DATE ''' || TO_CHAR(e.REC_PERIODO, 'YYYY-MM-DD') || ''';' as PARAM_5,
    'v_tipo_con := 1;' as PARAM_6
FROM REC_EMPRESA e
INNER JOIN REC_TRABAJADOR t ON 
    e.REC_PERIODO = t.REC_PERIODO
    AND e.CON_RUT = t.CON_RUT
    AND e.CON_CORREL = t.CON_CORREL
    AND e.RPR_PROCESO = t.RPR_PROCESO
    AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
WHERE e.RPR_PROCESO = 1  -- Solo remuneraciones normales
AND ROWNUM = 1;

-- =====================================================
-- PASO 4: VERIFICAR SI EXISTEN TABLAS RELACIONADAS
-- =====================================================
SELECT 
    'REC_TRAAFP' as TABLA,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRAAFP
WHERE ROWNUM <= 1000

UNION ALL

SELECT 
    'REC_PAGO' as TABLA,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_PAGO
WHERE ROWNUM <= 1000

UNION ALL

SELECT 
    'REC_TRAISA' as TABLA,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRAISA
WHERE ROWNUM <= 1000;

-- =====================================================
-- PASO 5: CONSULTA SIMPLIFICADA PARA OBTENER PARÁMETROS
-- =====================================================
WITH datos_base AS (
    SELECT DISTINCT
        e.CON_RUT,
        e.CON_CORREL, 
        t.TRA_RUT,
        e.REC_PERIODO
    FROM REC_EMPRESA e, REC_TRABAJADOR t
    WHERE e.REC_PERIODO = t.REC_PERIODO
      AND e.CON_RUT = t.CON_RUT
      AND e.CON_CORREL = t.CON_CORREL
      AND e.RPR_PROCESO = t.RPR_PROCESO
      AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
      AND e.RPR_PROCESO = 1
      AND ROWNUM <= 100
)
SELECT 
    CON_RUT,
    CON_CORREL,
    TRA_RUT,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX,
    COUNT(*) as REGISTROS,
    '=== COPIAR ESTOS PARÁMETROS ===' as SEPARADOR,
    'v_emp_rut := ' || CON_RUT || ';' as EMPRESA,
    'v_convenio := ' || CON_CORREL || ';' as CONVENIO,
    'v_rut_tra := ' || TRA_RUT || ';' as TRABAJADOR,
    'v_fec_ini := DATE ''' || TO_CHAR(MIN(REC_PERIODO), 'YYYY-MM-DD') || ''';' as FECHA_INICIO,
    'v_fec_ter := DATE ''' || TO_CHAR(MAX(REC_PERIODO), 'YYYY-MM-DD') || ''';' as FECHA_FIN,
    'v_tipo_con := 1;' as TIPO_CONSULTA
FROM datos_base
GROUP BY CON_RUT, CON_CORREL, TRA_RUT
HAVING COUNT(*) >= 1
ORDER BY COUNT(*) DESC
FETCH FIRST 3 ROWS ONLY;

96758240	1	13613755	2003-08-31 00:00:00.000	2003-08-31 00:00:00.000	1	=== COPIAR ESTOS PARÁMETROS ===	v_emp_rut := 96758240;	v_convenio := 1;	v_rut_tra := 13613755;	v_fec_ini := DATE '2003-08-31';	v_fec_ter := DATE '2003-08-31';	v_tipo_con := 1;
71369900	1	14739784	2003-07-31 00:00:00.000	2003-07-31 00:00:00.000	1	=== COPIAR ESTOS PARÁMETROS ===	v_emp_rut := 71369900;	v_convenio := 1;	v_rut_tra := 14739784;	v_fec_ini := DATE '2003-07-31';	v_fec_ter := DATE '2003-07-31';	v_tipo_con := 1;
79602640	4	10334310	2003-07-31 00:00:00.000	2003-07-31 00:00:00.000	1	=== COPIAR ESTOS PARÁMETROS ===	v_emp_rut := 79602640;	v_convenio := 4;	v_rut_tra := 10334310;	v_fec_ini := DATE '2003-07-31';	v_fec_ter := DATE '2003-07-31';	v_tipo_con := 1;

