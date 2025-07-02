-- =====================================================
-- SCRIPT DE SOLUCIÓN PARA PRC_CERTCOT_TRAB_PUB
-- Resuelve el error PLS-00905
-- =====================================================

SET SERVEROUTPUT ON SIZE 1000000;
SET VERIFY OFF;
SET ECHO OFF;

PROMPT =====================================================
PROMPT SCRIPT DE SOLUCIÓN - PRC_CERTCOT_TRAB_PUB
PROMPT =====================================================

-- PASO 1: CREAR TABLAS GTT SI NO EXISTEN
PROMPT
PROMPT PASO 1: Creando tablas GTT requeridas...

-- GTT_REC_VIR_TRA
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GTT_REC_VIR_TRA';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
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
        ) ON COMMIT DELETE ROWS';
        
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_VIR_TRA creada');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_VIR_TRA ya existe');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error creando GTT_REC_VIR_TRA: ' || SQLERRM);
END;
/

-- GTT_REC_VIR_TRA2
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GTT_REC_VIR_TRA2';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
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
        ) ON COMMIT DELETE ROWS';
        
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_VIR_TRA2 creada');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_VIR_TRA2 ya existe');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error creando GTT_REC_VIR_TRA2: ' || SQLERRM);
END;
/

-- GTT_REC_CERT_DETALLE
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GTT_REC_CERT_DETALLE';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
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
        ) ON COMMIT DELETE ROWS';
        
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_CERT_DETALLE creada');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_CERT_DETALLE ya existe');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error creando GTT_REC_CERT_DETALLE: ' || SQLERRM);
END;
/

-- GTT_REC_PLANILLA
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GTT_REC_PLANILLA';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
        CREATE GLOBAL TEMPORARY TABLE GTT_REC_PLANILLA (
            REC_PERIODO             DATE NOT NULL,
            NRO_COMPROBANTE         NUMBER(7,0) NOT NULL,
            ENT_RUT                 NUMBER(9,0) NOT NULL,
            PLA_NRO_SERIE           NUMBER(10,0),
            SUC_COD                 VARCHAR2(6) NOT NULL,
            USU_COD                 VARCHAR2(6) NOT NULL
        ) ON COMMIT DELETE ROWS';
        
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_PLANILLA creada');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_PLANILLA ya existe');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error creando GTT_REC_PLANILLA: ' || SQLERRM);
END;
/

-- GTT_REC_SUCURSALES
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM USER_TABLES
    WHERE TABLE_NAME = 'GTT_REC_SUCURSALES';
    
    IF v_count = 0 THEN
        EXECUTE IMMEDIATE '
        CREATE GLOBAL TEMPORARY TABLE GTT_REC_SUCURSALES (
            COD_SUC                 VARCHAR2(7)
        ) ON COMMIT DELETE ROWS';
        
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_SUCURSALES creada');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ GTT_REC_SUCURSALES ya existe');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error creando GTT_REC_SUCURSALES: ' || SQLERRM);
END;
/

-- PASO 2: RECOMPILAR OBJETOS INVÁLIDOS
PROMPT
PROMPT PASO 2: Recompilando objetos inválidos...

DECLARE
    v_sql VARCHAR2(1000);
BEGIN
    FOR rec IN (
        SELECT OBJECT_NAME, OBJECT_TYPE
        FROM USER_OBJECTS
        WHERE STATUS = 'INVALID'
          AND OBJECT_TYPE IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
        ORDER BY OBJECT_TYPE, OBJECT_NAME
    ) LOOP
        BEGIN
            v_sql := 'ALTER ' || rec.OBJECT_TYPE || ' ' || rec.OBJECT_NAME || ' COMPILE';
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('✓ Recompilado: ' || rec.OBJECT_TYPE || ' ' || rec.OBJECT_NAME);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ Error recompilando ' || rec.OBJECT_NAME || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- PASO 3: RECOMPILAR EL PROCEDIMIENTO ESPECÍFICO
PROMPT
PROMPT PASO 3: Recompilando PRC_CERTCOT_TRAB_PUB...

BEGIN
    EXECUTE IMMEDIATE 'ALTER PROCEDURE PRC_CERTCOT_TRAB_PUB COMPILE';
    DBMS_OUTPUT.PUT_LINE('✓ PRC_CERTCOT_TRAB_PUB recompilado exitosamente');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error recompilando PRC_CERTCOT_TRAB_PUB: ' || SQLERRM);
END;
/

-- PASO 4: VERIFICAR ESTADO FINAL
PROMPT
PROMPT PASO 4: Verificando estado final...

SELECT 
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS,
    TO_CHAR(LAST_DDL_TIME, 'DD/MM/YYYY HH24:MI:SS') as LAST_DDL_TIME
FROM USER_OBJECTS 
WHERE OBJECT_NAME = 'PRC_CERTCOT_TRAB_PUB';

-- PASO 5: MOSTRAR ERRORES SI EXISTEN
PROMPT
PROMPT PASO 5: Verificando errores de compilación...

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
        DBMS_OUTPUT.PUT_LINE('✓ No hay errores de compilación');
    END IF;
END;
/

-- PASO 6: PRUEBA FINAL
PROMPT
PROMPT PASO 6: Prueba final del procedimiento...

DECLARE
    v_cursor SYS_REFCURSOR;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Ejecutando prueba simple...');
    
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
    
    DBMS_OUTPUT.PUT_LINE('✓ Procedimiento ejecutado exitosamente');
    
    IF v_cursor%ISOPEN THEN
        CLOSE v_cursor;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('✗ Error en ejecución: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
END;
/

PROMPT
PROMPT =====================================================
PROMPT SOLUCIÓN COMPLETADA
PROMPT =====================================================
PROMPT
PROMPT Si aún hay errores, ejecute:
PROMPT 1. DIAGNOSTICO_PRC_CERTCOT_TRAB_PUB.sql para más detalles
PROMPT 2. Verifique que las tablas principales (REC_*) existan
PROMPT 3. Contacte al administrador de BD si persisten los problemas
PROMPT
