-- =====================================================
-- DIAGNÓSTICO COMPLETO PARA PRC_CERTCOT_TRAB_PUB
-- Identifica la causa del error PLS-00905
-- =====================================================

SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;
SET ECHO OFF;

PROMPT =====================================================
PROMPT DIAGNÓSTICO COMPLETO - PRC_CERTCOT_TRAB_PUB
PROMPT =====================================================

-- 1. VERIFICAR ESTADO ACTUAL DEL PROCEDIMIENTO
PROMPT
PROMPT 1. ESTADO DEL PROCEDIMIENTO:
SELECT 
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS,
    TO_CHAR(CREATED, 'DD/MM/YYYY HH24:MI:SS') as CREATED,
    TO_CHAR(LAST_DDL_TIME, 'DD/MM/YYYY HH24:MI:SS') as LAST_DDL_TIME
FROM USER_OBJECTS 
WHERE OBJECT_NAME = 'PRC_CERTCOT_TRAB_PUB';

-- 2. VERIFICAR ERRORES DE COMPILACIÓN
PROMPT
PROMPT 2. ERRORES DE COMPILACIÓN:
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_ERRORS
    WHERE NAME = 'PRC_CERTCOT_TRAB_PUB';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Se encontraron ' || v_count || ' errores:');
        DBMS_OUTPUT.PUT_LINE('');
        
        FOR rec IN (
            SELECT LINE, POSITION, TEXT, ATTRIBUTE
            FROM USER_ERRORS
            WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
            ORDER BY SEQUENCE
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('Línea ' || rec.LINE || ', Pos ' || rec.POSITION || 
                               ' [' || rec.ATTRIBUTE || ']: ' || rec.TEXT);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No se encontraron errores de compilación.');
    END IF;
END;
/

-- 3. VERIFICAR DEPENDENCIAS
PROMPT
PROMPT 3. DEPENDENCIAS DEL PROCEDIMIENTO:
SELECT 
    REFERENCED_OWNER,
    REFERENCED_NAME,
    REFERENCED_TYPE,
    DEPENDENCY_TYPE
FROM USER_DEPENDENCIES 
WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
ORDER BY REFERENCED_TYPE, REFERENCED_NAME;

-- 4. VERIFICAR OBJETOS INVÁLIDOS
PROMPT
PROMPT 4. OBJETOS INVÁLIDOS EN EL ESQUEMA:
SELECT 
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS,
    TO_CHAR(LAST_DDL_TIME, 'DD/MM/YYYY HH24:MI:SS') as LAST_DDL_TIME
FROM USER_OBJECTS 
WHERE STATUS = 'INVALID'
ORDER BY OBJECT_TYPE, OBJECT_NAME;

-- 5. VERIFICAR TABLAS GTT ESPECÍFICAS
PROMPT
PROMPT 5. VERIFICACIÓN DETALLADA DE TABLAS GTT:

-- Verificar GTT_REC_VIR_TRA
DECLARE
    v_exists NUMBER;
    v_temporary VARCHAR2(1);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Verificando GTT_REC_VIR_TRA:');
    
    SELECT COUNT(*), MAX(TEMPORARY)
    INTO v_exists, v_temporary
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GTT_REC_VIR_TRA';
    
    IF v_exists > 0 THEN
        DBMS_OUTPUT.PUT_LINE('  ✓ Existe - Temporal: ' || NVL(v_temporary, 'N'));
        
        -- Verificar estructura básica
        SELECT COUNT(*)
        INTO v_exists
        FROM USER_TAB_COLUMNS
        WHERE TABLE_NAME = 'GTT_REC_VIR_TRA'
          AND COLUMN_NAME IN ('REC_PERIODO', 'CON_RUT', 'TRA_RUT', 'SUC_COD');
          
        DBMS_OUTPUT.PUT_LINE('  ✓ Columnas básicas: ' || v_exists || '/4');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ✗ NO EXISTE');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ ERROR: ' || SQLERRM);
END;
/

-- 6. VERIFICAR TABLAS PRINCIPALES
PROMPT
PROMPT 6. VERIFICACIÓN DE TABLAS PRINCIPALES:

DECLARE
    v_count NUMBER;
    v_table VARCHAR2(30);
    TYPE t_tables IS TABLE OF VARCHAR2(30);
    v_tables t_tables := t_tables(
        'REC_EMPRESA', 'REC_TRABAJADOR', 'REC_TRAAFP', 
        'REC_TRAINP', 'REC_TRAISA', 'REC_ENTPREV'
    );
BEGIN
    FOR i IN 1..v_tables.COUNT LOOP
        v_table := v_tables(i);
        
        BEGIN
            SELECT COUNT(*)
            INTO v_count
            FROM USER_TABLES
            WHERE TABLE_NAME = v_table;
            
            IF v_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE('✓ ' || RPAD(v_table, 20) || ' - EXISTE');
            ELSE
                DBMS_OUTPUT.PUT_LINE('✗ ' || RPAD(v_table, 20) || ' - NO EXISTE');
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ ' || RPAD(v_table, 20) || ' - ERROR: ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- 7. INTENTAR RECOMPILACIÓN FORZADA
PROMPT
PROMPT 7. RECOMPILACIÓN FORZADA:

BEGIN
    DBMS_OUTPUT.PUT_LINE('Intentando recompilar...');
    
    -- Recompilar con debug
    EXECUTE IMMEDIATE 'ALTER PROCEDURE PRC_CERTCOT_TRAB_PUB COMPILE DEBUG';
    
    DBMS_OUTPUT.PUT_LINE('✓ Recompilación exitosa');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error en recompilación: ' || SQLERRM);
        
        -- Intentar recompilación normal
        BEGIN
            EXECUTE IMMEDIATE 'ALTER PROCEDURE PRC_CERTCOT_TRAB_PUB COMPILE';
            DBMS_OUTPUT.PUT_LINE('✓ Recompilación normal exitosa');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ Error en recompilación normal: ' || SQLERRM);
        END;
END;
/

-- 8. VERIFICAR ESTADO DESPUÉS DE RECOMPILACIÓN
PROMPT
PROMPT 8. ESTADO DESPUÉS DE RECOMPILACIÓN:
SELECT 
    OBJECT_NAME,
    STATUS,
    TO_CHAR(LAST_DDL_TIME, 'DD/MM/YYYY HH24:MI:SS') as LAST_DDL_TIME
FROM USER_OBJECTS 
WHERE OBJECT_NAME = 'PRC_CERTCOT_TRAB_PUB';

-- 9. MOSTRAR NUEVOS ERRORES SI EXISTEN
PROMPT
PROMPT 9. ERRORES DESPUÉS DE RECOMPILACIÓN:
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_ERRORS
    WHERE NAME = 'PRC_CERTCOT_TRAB_PUB';
    
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Errores encontrados:');
        
        FOR rec IN (
            SELECT LINE, POSITION, TEXT, ATTRIBUTE
            FROM USER_ERRORS
            WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
            ORDER BY SEQUENCE
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('L' || rec.LINE || ':P' || rec.POSITION || 
                               ' [' || rec.ATTRIBUTE || '] ' || rec.TEXT);
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ No hay errores de compilación');
    END IF;
END;
/

-- 10. PRUEBA SIMPLE DE INVOCACIÓN
PROMPT
PROMPT 10. PRUEBA SIMPLE DE INVOCACIÓN:

DECLARE
    v_cursor SYS_REFCURSOR;
    v_error_code NUMBER;
    v_error_msg VARCHAR2(4000);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Intentando invocar el procedimiento...');
    
    -- Intentar llamada simple
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
    
    -- Si llegamos aquí, la invocación fue exitosa
    DBMS_OUTPUT.PUT_LINE('✓ Invocación exitosa');
    
    -- Cerrar cursor si está abierto
    IF v_cursor%ISOPEN THEN
        CLOSE v_cursor;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;
        
        DBMS_OUTPUT.PUT_LINE('✗ Error en invocación:');
        DBMS_OUTPUT.PUT_LINE('  SQLCODE: ' || v_error_code);
        DBMS_OUTPUT.PUT_LINE('  SQLERRM: ' || v_error_msg);
        
        -- Cerrar cursor si está abierto
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
END;
/

PROMPT
PROMPT =====================================================
PROMPT DIAGNÓSTICO COMPLETADO
PROMPT =====================================================
PROMPT
PROMPT INSTRUCCIONES:
PROMPT 1. Revise los errores de compilación mostrados arriba
PROMPT 2. Verifique que todas las tablas GTT existan
PROMPT 3. Asegúrese de que las tablas principales existan
PROMPT 4. Si hay objetos inválidos, recompílelos primero
PROMPT 5. Ejecute el script CREATE_GTT_TABLES_CERTCOT.sql si faltan tablas GTT
PROMPT
