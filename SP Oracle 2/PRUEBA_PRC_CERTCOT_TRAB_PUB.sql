-- =====================================================
-- DIAGNÓSTICO Y PRUEBA PARA PRC_CERTCOT_TRAB_PUB
-- Sistema: REC - Recaudación Oracle
-- Procedimiento: PRC_CERTCOT_TRAB_PUB
-- =====================================================

-- Configuración inicial
SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;
SET ECHO OFF;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY';

-- =====================================================
-- DIAGNÓSTICO DE DEPENDENCIAS
-- =====================================================

PROMPT ===== DIAGNÓSTICO DE DEPENDENCIAS DEL PROCEDIMIENTO =====

-- 1. Verificar estado del procedimiento
SELECT
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS,
    CREATED,
    LAST_DDL_TIME
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'PRC_CERTCOT_TRAB_PUB';

-- 2. Verificar errores de compilación
SELECT
    LINE,
    POSITION,
    TEXT as ERROR_MESSAGE
FROM USER_ERRORS
WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
ORDER BY SEQUENCE;

-- 3. Verificar dependencias del procedimiento
SELECT
    REFERENCED_OWNER,
    REFERENCED_NAME,
    REFERENCED_TYPE,
    DEPENDENCY_TYPE
FROM USER_DEPENDENCIES
WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
ORDER BY REFERENCED_TYPE, REFERENCED_NAME;

-- 4. Verificar objetos inválidos que podrían afectar
SELECT
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS
FROM USER_OBJECTS
WHERE STATUS = 'INVALID'
ORDER BY OBJECT_TYPE, OBJECT_NAME;

-- 5. Verificar existencia de tablas GTT requeridas
PROMPT ===== VERIFICACIÓN DE TABLAS GTT =====

DECLARE
    v_count NUMBER;
    v_table_name VARCHAR2(30);
    TYPE t_tables IS TABLE OF VARCHAR2(30);
    v_gtt_tables t_tables := t_tables(
        'GTT_REC_VIR_TRA',
        'GTT_REC_VIR_TRA2',
        'GTT_REC_CERT_DETALLE',
        'GTT_REC_PLANILLA',
        'GTT_REC_SUCURSALES'
    );
BEGIN
    DBMS_OUTPUT.PUT_LINE('Verificando tablas GTT requeridas:');
    DBMS_OUTPUT.PUT_LINE('');

    FOR i IN 1..v_gtt_tables.COUNT LOOP
        v_table_name := v_gtt_tables(i);

        BEGIN
            SELECT COUNT(*)
            INTO v_count
            FROM USER_TABLES
            WHERE TABLE_NAME = v_table_name;

            IF v_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE('✓ ' || v_table_name || ' - EXISTE');
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ ' || v_table_name || ' - NO EXISTE');
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ ' || v_table_name || ' - ERROR: ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- 6. Verificar existencia de tablas principales
PROMPT ===== VERIFICACIÓN DE TABLAS PRINCIPALES =====

DECLARE
    v_count NUMBER;
    v_table_name VARCHAR2(30);
    TYPE t_tables IS TABLE OF VARCHAR2(30);
    v_main_tables t_tables := t_tables(
        'REC_EMPRESA',
        'REC_TRABAJADOR',
        'REC_TRAAFP',
        'REC_TRAINP',
        'REC_TRAISA',
        'REC_ENTPREV'
    );
BEGIN
    DBMS_OUTPUT.PUT_LINE('Verificando tablas principales:');
    DBMS_OUTPUT.PUT_LINE('');

    FOR i IN 1..v_main_tables.COUNT LOOP
        v_table_name := v_main_tables(i);

        BEGIN
            SELECT COUNT(*)
            INTO v_count
            FROM USER_TABLES
            WHERE TABLE_NAME = v_table_name;

            IF v_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE('✓ ' || v_table_name || ' - EXISTE');

                -- Verificar si tiene datos
                EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_table_name || ' WHERE ROWNUM <= 1'
                INTO v_count;

                IF v_count > 0 THEN
                    DBMS_OUTPUT.PUT_LINE('  └─ Contiene datos');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('  └─ Sin datos');
                END IF;
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ ' || v_table_name || ' - NO EXISTE');
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ ' || v_table_name || ' - ERROR: ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- 7. Intentar recompilar el procedimiento
PROMPT ===== RECOMPILACIÓN DEL PROCEDIMIENTO =====

BEGIN
    DBMS_OUTPUT.PUT_LINE('Intentando recompilar PRC_CERTCOT_TRAB_PUB...');

    EXECUTE IMMEDIATE 'ALTER PROCEDURE PRC_CERTCOT_TRAB_PUB COMPILE';

    DBMS_OUTPUT.PUT_LINE('✓ Recompilación exitosa');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error en recompilación: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
END;
/

-- 8. Verificar estado después de recompilación
SELECT
    OBJECT_NAME,
    STATUS,
    LAST_DDL_TIME
FROM USER_OBJECTS
WHERE OBJECT_NAME = 'PRC_CERTCOT_TRAB_PUB';

-- 9. Mostrar errores de compilación si existen
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_ERRORS
    WHERE NAME = 'PRC_CERTCOT_TRAB_PUB';

    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('===== ERRORES DE COMPILACIÓN =====');

        FOR rec IN (
            SELECT LINE, POSITION, TEXT
            FROM USER_ERRORS
            WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
            ORDER BY SEQUENCE
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Línea ' || rec.LINE || ', Posición ' || rec.POSITION || ': ' || rec.TEXT);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('✓ No hay errores de compilación');
    END IF;
END;
/

-- =====================================================
-- PRUEBA SIMPLE DEL PROCEDIMIENTO
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
    v_parametro VARCHAR2(10);
    v_parametro2 VARCHAR2(10);
    v_parametro3 VARCHAR2(1);
    
    -- Variables para leer el cursor de resultados 
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
    v_tra_nombre VARCHAR2(80);  
    v_tra_ape VARCHAR2(80);     
    v_dias_trab NUMBER;
    v_rem_impo NUMBER;
    v_monto_cotizado NUMBER;
    v_fec_pago DATE;
    v_folio_planilla NUMBER;
    v_raz_soc VARCHAR2(80);     
    v_salud NUMBER;
    v_monto_sis NUMBER;
    v_usu_pago_retroactivo VARCHAR2(1);
    
    -- Variables de control
    v_contador NUMBER := 0;
    v_total_cotizaciones NUMBER := 0;
    
BEGIN
    -- =====================================================
    -- PARÁMETROS DE CONSULTA - MODIFIQUE ESTOS VALORES
    -- =====================================================
    v_fec_ini := DATE '2003-07-31';        -- Fecha inicio
    v_fec_ter := DATE '2003-08-31';        -- Fecha término
    v_emp_rut := 96758240;                 -- RUT empresa (sin DV)
    v_convenio := 1;                       -- Número convenio
    v_rut_tra := 13613755;                 -- RUT trabajador (sin DV)
    v_tipo_con := 1;                       -- Tipo consulta: 0=Todos, 1=AFP, 2=Salud
    v_parametro := NULL;                   -- Parámetro adicional 1
    v_parametro2 := NULL;                  -- Parámetro adicional 2 (para agrupación)
    v_parametro3 := NULL;                  -- Parámetro adicional 3
    -- =====================================================
    
    -- Mostrar información inicial
    DBMS_OUTPUT.PUT_LINE('=== CERTIFICADO DE COTIZACIONES PREVISIONALES - TRABAJADOR PÚBLICO ===');
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
    DBMS_OUTPUT.PUT_LINE('- Parámetro 2 (Agrupación): ' || NVL(v_parametro2, 'NULL (agrupado por sucursal)'));
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
        SELECT COUNT(*), MAX(EMP_RAZSOC)
        INTO v_count_emp, v_nombre_emp
        FROM REC_EMPRESA
        WHERE CON_RUT = v_emp_rut
          AND CON_CORREL = v_convenio;
          
        IF v_count_emp = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ADVERTENCIA: No se encontró la empresa con RUT ' || v_emp_rut || ' y convenio ' || v_convenio);
            DBMS_OUTPUT.PUT_LINE('');
        ELSE
            DBMS_OUTPUT.PUT_LINE('EMPRESA ENCONTRADA: ' || NVL(v_nombre_emp, 'Sin nombre'));
            DBMS_OUTPUT.PUT_LINE('RUT: ' || v_emp_rut || ' - Convenio: ' || v_convenio);
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
        SELECT COUNT(*), MAX(TRA_NOMTRA || ' ' || TRA_APETRA)
        INTO v_count_tra, v_nombre_tra
        FROM REC_TRABAJADOR
        WHERE TRA_RUT = v_rut_tra
          AND CON_RUT = v_emp_rut
          AND CON_CORREL = v_convenio
          AND REC_PERIODO BETWEEN v_fec_ini AND v_fec_ter;
          
        IF v_count_tra = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ADVERTENCIA: No se encontró el trabajador con RUT ' || v_rut_tra);
            DBMS_OUTPUT.PUT_LINE('en la empresa ' || v_emp_rut || ' para el período especificado');
            DBMS_OUTPUT.PUT_LINE('');
        ELSE
            DBMS_OUTPUT.PUT_LINE('TRABAJADOR: ' || NVL(v_nombre_tra, 'Sin nombre'));
            DBMS_OUTPUT.PUT_LINE('RUT: ' || v_rut_tra);
            DBMS_OUTPUT.PUT_LINE('');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al verificar trabajador: ' || SQLERRM);
    END;
    
    -- Llamar al procedimiento
    DBMS_OUTPUT.PUT_LINE('Ejecutando PRC_CERTCOT_TRAB_PUB...');
    DBMS_OUTPUT.PUT_LINE('');
    
    BEGIN
        PRC_CERTCOT_TRAB_PUB(
            p_fec_ini => v_fec_ini,
            p_fec_ter => v_fec_ter,
            p_emp_rut => v_emp_rut,
            p_convenio => v_convenio,
            p_rut_tra => v_rut_tra,
            p_tipoCon => v_tipo_con,
            p_Parametro => v_parametro,
            p_parametro2 => v_parametro2,
            p_parametro3 => v_parametro3,
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
                         RPAD('FOLIO', 8) || ' | ' ||
                         RPAD('RETRO', 5));
    DBMS_OUTPUT.PUT_LINE(RPAD('-', 8, '-') || '-+-' ||
                         RPAD('-', 4, '-') || '-+-' ||
                         RPAD('-', 25, '-') || '-+-' ||
                         RPAD('-', 12, '-') || '-+-' ||
                         LPAD('-', 4, '-') || '-+-' ||
                         LPAD('-', 15, '-') || '-+-' ||
                         LPAD('-', 12, '-') || '-+-' ||
                         RPAD('-', 8, '-') || '-+-' ||
                         RPAD('-', 5, '-'));
    
    -- Leer y mostrar los resultados del cursor
    LOOP
        BEGIN
            FETCH v_cursor INTO 
                v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
                v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig, 
                v_tra_nombre, v_tra_ape, v_dias_trab, v_rem_impo, v_monto_cotizado,
                v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis, v_usu_pago_retroactivo;
                
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
                RPAD(NVL(TO_CHAR(v_folio_planilla), 'N/A'), 8) || ' | ' ||
                RPAD(NVL(v_usu_pago_retroactivo, 'N'), 5)
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
        DBMS_OUTPUT.PUT_LINE('- Revise las tablas GTT y sus datos');
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

-- Verificar tablas GTT (Global Temporary Tables)
SELECT 'VERIFICACIÓN DE TABLAS GTT:' AS INFO FROM DUAL;

SELECT
    'GTT_REC_VIR_TRA' as TABLA,
    COUNT(*) as REGISTROS
FROM GTT_REC_VIR_TRA
UNION ALL
SELECT
    'GTT_REC_VIR_TRA2' as TABLA,
    COUNT(*) as REGISTROS
FROM GTT_REC_VIR_TRA2
UNION ALL
SELECT
    'GTT_REC_CERT_DETALLE' as TABLA,
    COUNT(*) as REGISTROS
FROM GTT_REC_CERT_DETALLE
UNION ALL
SELECT
    'GTT_REC_PLANILLA' as TABLA,
    COUNT(*) as REGISTROS
FROM GTT_REC_PLANILLA
UNION ALL
SELECT
    'GTT_REC_SUCURSALES' as TABLA,
    COUNT(*) as REGISTROS
FROM GTT_REC_SUCURSALES;

-- Mostrar empresas disponibles
SELECT 'EMPRESAS DISPONIBLES (muestra):' AS INFO FROM DUAL;

SELECT DISTINCT CON_RUT AS RUT_EMPRESA, EMP_RAZSOC, CON_CORREL AS CONVENIO
FROM REC_EMPRESA
WHERE ROWNUM <= 20
ORDER BY CON_RUT;

-- Mostrar trabajadores de ejemplo
SELECT 'TRABAJADORES DE EJEMPLO:' AS INFO FROM DUAL;

SELECT DISTINCT TRA_RUT, TRA_NOMTRA || ' ' || TRA_APETRA AS NOMBRE, CON_RUT AS EMPRESA
FROM REC_TRABAJADOR
WHERE ROWNUM <= 20
ORDER BY TRA_RUT;

-- Mostrar períodos disponibles
SELECT 'PERÍODOS DISPONIBLES:' AS INFO FROM DUAL;

SELECT DISTINCT TO_CHAR(REC_PERIODO, 'MM/YYYY') AS PERIODO
FROM REC_TRABAJADOR
WHERE ROWNUM <= 24
ORDER BY REC_PERIODO;

-- =====================================================
-- VERIFICAR TABLAS RELACIONADAS PARA COTIZACIONES
-- =====================================================

SELECT 'VERIFICACIÓN DE TABLAS DE COTIZACIONES:' AS INFO FROM DUAL;

-- Verificar tabla REC_TRABAFP (cotizaciones AFP)
SELECT
    'REC_TRABAFP' as TABLA,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRABAFP
WHERE ROWNUM <= 1000

UNION ALL

-- Verificar tabla REC_TRA_INP (cotizaciones INP)
SELECT
    'REC_TRA_INP' as TABLA,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRA_INP
WHERE ROWNUM <= 1000

UNION ALL

-- Verificar tabla REC_TRA_ISAPRE (cotizaciones ISAPRE)
SELECT
    'REC_TRA_ISAPRE' as TABLA,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRA_ISAPRE
WHERE ROWNUM <= 1000

UNION ALL

-- Verificar tabla REC_AFPS (entidades AFP)
SELECT
    'REC_AFPS' as TABLA,
    COUNT(*) as REGISTROS,
    NULL as FECHA_MIN,
    NULL as FECHA_MAX
FROM REC_AFPS
WHERE ROWNUM <= 1000

UNION ALL

-- Verificar tabla REC_ISAPRES (entidades ISAPRE)
SELECT
    'REC_ISAPRES' as TABLA,
    COUNT(*) as REGISTROS,
    NULL as FECHA_MIN,
    NULL as FECHA_MAX
FROM REC_ISAPRES
WHERE ROWNUM <= 1000;

-- =====================================================
-- SCRIPT RÁPIDO DE PRUEBA
-- =====================================================

PROMPT
PROMPT =====================================================
PROMPT SCRIPT DE PRUEBA RÁPIDA - PRC_CERTCOT_TRAB_PUB
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
    -- Variables para FETCH
    v_rec_periodo DATE; v_nro_comprobante NUMBER; v_tipo_impre NUMBER;
    v_suc_cod VARCHAR2(6); v_usu_cod VARCHAR2(6); v_tipo_ent VARCHAR2(1);
    v_ent_rut NUMBER; v_ent_nombre VARCHAR2(255); v_tra_rut NUMBER;
    v_tra_dig VARCHAR2(1); v_tra_nombre VARCHAR2(80); v_tra_ape VARCHAR2(80);
    v_dias_trab NUMBER; v_rem_impo NUMBER; v_monto_cotizado NUMBER;
    v_fec_pago DATE; v_folio_planilla NUMBER; v_raz_soc VARCHAR2(80);
    v_salud NUMBER; v_monto_sis NUMBER; v_usu_pago_retroactivo VARCHAR2(1);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA RÁPIDA PRC_CERTCOT_TRAB_PUB ===');

    -- Usar estos parámetros para prueba rápida
    PRC_CERTCOT_TRAB_PUB(
        p_fec_ini => DATE '2003-07-31',
        p_fec_ter => DATE '2003-08-31',
        p_emp_rut => 96758240,
        p_convenio => 1,
        p_rut_tra => 13613755,
        p_tipoCon => 0,
        p_Parametro => NULL,
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
            v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis, v_usu_pago_retroactivo;

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
UNION ALL SELECT 'INSTRUCCIONES DE USO - PRC_CERTCOT_TRAB_PUB' FROM DUAL
UNION ALL SELECT '======================================================' FROM DUAL
UNION ALL SELECT '' FROM DUAL
UNION ALL SELECT '1. Localice la sección "MODIFIQUE ESTOS VALORES"' FROM DUAL
UNION ALL SELECT '2. Cambie los valores según sus necesidades:' FROM DUAL
UNION ALL SELECT '   - v_fec_ini: Fecha de inicio' FROM DUAL
UNION ALL SELECT '   - v_fec_ter: Fecha de término' FROM DUAL
UNION ALL SELECT '   - v_emp_rut: RUT de empresa (sin DV)' FROM DUAL
UNION ALL SELECT '   - v_convenio: Número de convenio' FROM DUAL
UNION ALL SELECT '   - v_rut_tra: RUT de trabajador (sin DV)' FROM DUAL
UNION ALL SELECT '   - v_tipo_con: 0=Todos, 1=AFP, 2=Salud' FROM DUAL
UNION ALL SELECT '   - v_parametro2: NULL=Por sucursal, valor=Por usuario' FROM DUAL
UNION ALL SELECT '3. Ejecute todo el script' FROM DUAL
UNION ALL SELECT '4. Revise los resultados en la consola' FROM DUAL
UNION ALL SELECT '5. Verifique las tablas GTT si no hay resultados' FROM DUAL;

-- =====================================================
-- CONSULTAS PARA OBTENER PARÁMETROS DE PRUEBA
-- =====================================================

-- PASO 1: VERIFICAR RANGOS DE FECHAS DISPONIBLES
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

-- PASO 2: BUSCAR COMBINACIONES VÁLIDAS EMPRESA-TRABAJADOR
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
WHERE e.RPR_PROCESO IN (1,2)
GROUP BY e.CON_RUT, e.CON_CORREL
ORDER BY COUNT(*) DESC
FETCH FIRST 10 ROWS ONLY;

-- PASO 3: OBTENER PARÁMETROS ESPECÍFICOS PARA PRUEBA
WITH datos_base AS (
    SELECT DISTINCT
        e.CON_RUT,
        e.CON_CORREL,
        t.TRA_RUT,
        e.REC_PERIODO,
        t.TRA_NOMTRA,
        t.TRA_APETRA,
        e.EMP_RAZSOC
    FROM REC_EMPRESA e, REC_TRABAJADOR t
    WHERE e.REC_PERIODO = t.REC_PERIODO
      AND e.CON_RUT = t.CON_RUT
      AND e.CON_CORREL = t.CON_CORREL
      AND e.RPR_PROCESO = t.RPR_PROCESO
      AND e.NRO_COMPROBANTE = t.NRO_COMPROBANTE
      AND e.RPR_PROCESO = 1
      AND ROWNUM <= 200
)
SELECT
    CON_RUT,
    CON_CORREL,
    TRA_RUT,
    MAX(TRA_NOMTRA || ' ' || TRA_APETRA) as NOMBRE_TRABAJADOR,
    MAX(EMP_RAZSOC) as NOMBRE_EMPRESA,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX,
    COUNT(*) as REGISTROS,
    '=== COPIAR ESTOS PARÁMETROS ===' as SEPARADOR,
    'v_emp_rut := ' || CON_RUT || ';' as EMPRESA,
    'v_convenio := ' || CON_CORREL || ';' as CONVENIO,
    'v_rut_tra := ' || TRA_RUT || ';' as TRABAJADOR,
    'v_fec_ini := DATE ''' || TO_CHAR(MIN(REC_PERIODO), 'YYYY-MM-DD') || ''';' as FECHA_INICIO,
    'v_fec_ter := DATE ''' || TO_CHAR(MAX(REC_PERIODO), 'YYYY-MM-DD') || ''';' as FECHA_FIN,
    'v_tipo_con := 0; -- 0=Todos, 1=AFP, 2=Salud' as TIPO_CONSULTA
FROM datos_base
GROUP BY CON_RUT, CON_CORREL, TRA_RUT
HAVING COUNT(*) >= 1
ORDER BY COUNT(*) DESC
FETCH FIRST 5 ROWS ONLY;

-- PASO 4: VERIFICAR DATOS DE COTIZACIONES ESPECÍFICAS
SELECT 'VERIFICACIÓN DE DATOS DE COTIZACIONES:' AS INFO FROM DUAL;

-- Verificar si hay datos AFP para los parámetros de ejemplo
SELECT
    'DATOS AFP DISPONIBLES' as TIPO,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRABAFP ta
INNER JOIN REC_TRABAJADOR t ON
    ta.REC_PERIODO = t.REC_PERIODO
    AND ta.CON_RUT = t.CON_RUT
    AND ta.CON_CORREL = t.CON_CORREL
    AND ta.TRA_RUT = t.TRA_RUT
WHERE ta.CON_RUT = 96758240
  AND ta.CON_CORREL = 1
  AND ta.TRA_RUT = 13613755
  AND ta.REC_PERIODO BETWEEN DATE '2003-07-31' AND DATE '2003-08-31'

UNION ALL

-- Verificar si hay datos ISAPRE para los parámetros de ejemplo
SELECT
    'DATOS ISAPRE DISPONIBLES' as TIPO,
    COUNT(*) as REGISTROS,
    MIN(REC_PERIODO) as FECHA_MIN,
    MAX(REC_PERIODO) as FECHA_MAX
FROM REC_TRA_ISAPRE ti
INNER JOIN REC_TRABAJADOR t ON
    ti.REC_PERIODO = t.REC_PERIODO
    AND ti.CON_RUT = t.CON_RUT
    AND ti.CON_CORREL = t.CON_CORREL
    AND ti.TRA_RUT = t.TRA_RUT
WHERE ti.CON_RUT = 96758240
  AND ti.CON_CORREL = 1
  AND ti.TRA_RUT = 13613755
  AND ti.REC_PERIODO BETWEEN DATE '2003-07-31' AND DATE '2003-08-31';

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

SELECT '======================================================' AS NOTAS FROM DUAL
UNION ALL SELECT 'NOTAS IMPORTANTES PARA PRC_CERTCOT_TRAB_PUB' FROM DUAL
UNION ALL SELECT '======================================================' FROM DUAL
UNION ALL SELECT '' FROM DUAL
UNION ALL SELECT 'Este SP migrado incluye las siguientes cotizaciones:' FROM DUAL
UNION ALL SELECT '- AFP: Gratificaciones y Remuneraciones (pre/post 2009)' FROM DUAL
UNION ALL SELECT '- INP: Previsión y Fondo' FROM DUAL
UNION ALL SELECT '- ISAPRE: Cotizaciones de salud' FROM DUAL
UNION ALL SELECT '- CCAF: Cajas de Compensación' FROM DUAL
UNION ALL SELECT '- Fondo de Cesantía (AFC)' FROM DUAL
UNION ALL SELECT '- AFP Trabajo Pesado' FROM DUAL
UNION ALL SELECT '- Accidente del Trabajo (Mutual)' FROM DUAL
UNION ALL SELECT '- APV: Ahorro Previsional Voluntario' FROM DUAL
UNION ALL SELECT '- Cuenta de Ahorro AFP' FROM DUAL
UNION ALL SELECT '' FROM DUAL
UNION ALL SELECT 'Parámetros especiales:' FROM DUAL
UNION ALL SELECT '- p_parametro2: NULL = agrupado por sucursal' FROM DUAL
UNION ALL SELECT '- p_parametro2: valor = agrupado por usuario' FROM DUAL
UNION ALL SELECT '- p_tipoCon: 0=Todas, 1=AFP, 2=Salud' FROM DUAL;
