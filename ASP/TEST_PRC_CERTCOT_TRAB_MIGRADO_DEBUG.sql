-- ============================================================================
-- SCRIPT DE DEBUG PARA PRC_CERTCOT_TRAB_MIGRADO
-- ============================================================================
-- Descripción: Script simplificado para identificar problemas de tipos de datos
-- Fecha: 2025-07-04
-- Autor: Debug Version - Identificar ORA-06502
-- ============================================================================

SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    -- PARÁMETROS DE ENTRADA PARA LA PRUEBA
    v_rut_tra           NUMBER := 13613755;
    v_emp_rut           NUMBER := 96758240;
    v_cnv_cta           NUMBER := 1;
    v_sel_op            NUMBER := 1;
    v_anio              NUMBER := 2003;
    v_mes               NUMBER := 08;
    v_anio_hasta        NUMBER := 2003;
    v_mes_hasta         NUMBER := 08;
    v_imp_ccaf          VARCHAR2(1) := 'N';
    v_tipo_con          NUMBER := 1;
    
    -- CURSORS DE SALIDA
    v_cursor_datos      SYS_REFCURSOR;
    v_cursor_encabezado SYS_REFCURSOR;
    v_cursor_metadatos  SYS_REFCURSOR;

    -- PARÁMETROS DE SALIDA ADICIONALES
    v_num_registros     NUMBER;
    v_num_paginas       NUMBER;
    v_es_empresa_pub    VARCHAR2(1);
    v_periodo_desde     DATE;
    v_periodo_hasta     DATE;
    v_mensaje_error     VARCHAR2(4000);
    v_codigo_retorno    NUMBER;

    -- VARIABLES PARA FETCH INDIVIDUAL (para identificar el campo problemático)
    v_campo1    DATE;           -- REC_PERIODO
    v_campo2    NUMBER;         -- TRA_RUT
    v_campo3    VARCHAR2(1);    -- TRA_DIG
    v_campo4    VARCHAR2(500);  -- TRABAJADOR_NOMBRE_COMPLETO (más grande por seguridad)
    v_campo5    NUMBER;         -- ENT_RUT
    v_campo6    VARCHAR2(500);  -- ENT_NOMBRE (más grande por seguridad)
    v_campo7    VARCHAR2(500);  -- EMPRESA_RAZON_SOCIAL (más grande por seguridad)
    v_campo8    NUMBER;         -- DIAS_TRAB
    v_campo9    NUMBER;         -- REM_IMPO
    v_campo10   NUMBER;         -- MONTO_COTIZADO
    v_campo11   NUMBER;         -- MONTO_SIS
    v_campo12   DATE;           -- FEC_PAGO
    v_campo13   NUMBER;         -- FOLIO_PLANILLA
    v_campo14   NUMBER;         -- SALUD
    v_campo15   VARCHAR2(50);   -- MES_ANIO_FORMATEADO
    v_campo16   VARCHAR2(500);  -- ENTIDAD_NOMBRE_FORMATEADO (más grande por seguridad)
    v_campo17   VARCHAR2(50);   -- REM_IMPO_FORMATEADO
    v_campo18   VARCHAR2(50);   -- MONTO_COTIZADO_FORMATEADO
    v_campo19   VARCHAR2(50);   -- MONTO_SIS_FORMATEADO
    v_campo20   VARCHAR2(50);   -- FECHA_PAGO_FORMATEADA
    v_campo21   VARCHAR2(1);    -- USU_PAGO_RETROACTIVO
    v_campo22   NUMBER;         -- TIPO_IMPRE
    v_campo23   VARCHAR2(10);   -- USU_COD
    v_campo24   VARCHAR2(50);   -- MES_RETROACTIVO_FORMATEADO
    v_campo25   NUMBER;         -- NUMERO_FILA
    v_campo26   VARCHAR2(1);    -- ES_CAMBIO_PERIODO
    v_campo27   NUMBER;         -- REGISTROS_POR_PAGINA
    v_campo28   NUMBER;         -- NUMERO_PAGINA

    v_count_datos       NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('DEBUG: IDENTIFICANDO PROBLEMA ORA-06502 EN PRC_CERTCOT_TRAB_MIGRADO');
    DBMS_OUTPUT.PUT_LINE('============================================================================');

    -- EJECUTAR EL STORED PROCEDURE
    BEGIN
        PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV(
            p_rut_tra           => v_rut_tra,
            p_emp_rut           => v_emp_rut,
            p_cnv_cta           => v_cnv_cta,
            p_sel_op            => v_sel_op,
            p_anio              => v_anio,
            p_mes               => v_mes,
            p_anio_hasta        => v_anio_hasta,
            p_mes_hasta         => v_mes_hasta,
            p_imp_ccaf          => v_imp_ccaf,
            p_tipo_con          => v_tipo_con,
            p_cursor_datos      => v_cursor_datos,
            p_cursor_encabezado => v_cursor_encabezado,
            p_cursor_metadatos  => v_cursor_metadatos,
            p_num_registros     => v_num_registros,
            p_num_paginas       => v_num_paginas,
            p_es_empresa_pub    => v_es_empresa_pub,
            p_periodo_desde     => v_periodo_desde,
            p_periodo_hasta     => v_periodo_hasta,
            p_mensaje_error     => v_mensaje_error,
            p_codigo_retorno    => v_codigo_retorno
        );

        DBMS_OUTPUT.PUT_LINE('✅ SP ejecutado exitosamente');
        DBMS_OUTPUT.PUT_LINE('- Código retorno: ' || NVL(v_codigo_retorno, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Número registros: ' || NVL(v_num_registros, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Es empresa pública: ' || NVL(v_es_empresa_pub, 'NULL'));
        
        IF v_mensaje_error IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Mensaje error: ' || v_mensaje_error);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ ERROR ejecutando SP: ' || SQLERRM);
            RETURN;
    END;

    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('DEBUG: PROBANDO FETCH CAMPO POR CAMPO');
    DBMS_OUTPUT.PUT_LINE('============================================================================');

    -- PROCESAR CURSOR CON FETCH INDIVIDUAL PARA IDENTIFICAR EL CAMPO PROBLEMÁTICO
    BEGIN
        LOOP
            BEGIN
                FETCH v_cursor_datos INTO 
                    v_campo1,  v_campo2,  v_campo3,  v_campo4,  v_campo5,  v_campo6,  v_campo7,
                    v_campo8,  v_campo9,  v_campo10, v_campo11, v_campo12, v_campo13, v_campo14,
                    v_campo15, v_campo16, v_campo17, v_campo18, v_campo19, v_campo20, v_campo21,
                    v_campo22, v_campo23, v_campo24, v_campo25, v_campo26, v_campo27, v_campo28;

                EXIT WHEN v_cursor_datos%NOTFOUND;

                v_count_datos := v_count_datos + 1;

                -- Mostrar solo el primer registro para debug
                IF v_count_datos = 1 THEN
                    DBMS_OUTPUT.PUT_LINE('✅ FETCH exitoso - Primer registro:');
                    DBMS_OUTPUT.PUT_LINE('  Campo 1 (REC_PERIODO): ' || TO_CHAR(v_campo1, 'YYYY-MM-DD'));
                    DBMS_OUTPUT.PUT_LINE('  Campo 2 (TRA_RUT): ' || v_campo2);
                    DBMS_OUTPUT.PUT_LINE('  Campo 3 (TRA_DIG): ' || v_campo3);
                    DBMS_OUTPUT.PUT_LINE('  Campo 4 (TRABAJADOR_NOMBRE): ' || SUBSTR(v_campo4, 1, 50));
                    DBMS_OUTPUT.PUT_LINE('  Campo 5 (ENT_RUT): ' || v_campo5);
                    DBMS_OUTPUT.PUT_LINE('  Campo 6 (ENT_NOMBRE): ' || SUBSTR(v_campo6, 1, 30));
                    DBMS_OUTPUT.PUT_LINE('  Campo 7 (EMPRESA_RAZON): ' || SUBSTR(v_campo7, 1, 30));
                    DBMS_OUTPUT.PUT_LINE('  Campo 8 (DIAS_TRAB): ' || NVL(v_campo8, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 9 (REM_IMPO): ' || NVL(v_campo9, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 10 (MONTO_COTIZADO): ' || NVL(v_campo10, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 11 (MONTO_SIS): ' || NVL(v_campo11, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 12 (FEC_PAGO): ' || TO_CHAR(v_campo12, 'YYYY-MM-DD'));
                    DBMS_OUTPUT.PUT_LINE('  Campo 13 (FOLIO_PLANILLA): ' || NVL(v_campo13, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 14 (SALUD): ' || NVL(v_campo14, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 15 (MES_ANIO_FORM): ' || v_campo15);
                    DBMS_OUTPUT.PUT_LINE('  Campo 16 (ENTIDAD_FORM): ' || v_campo16);
                    DBMS_OUTPUT.PUT_LINE('  Campo 17 (REM_IMPO_FORM): ' || v_campo17);
                    DBMS_OUTPUT.PUT_LINE('  Campo 18 (MONTO_COT_FORM): ' || v_campo18);
                    DBMS_OUTPUT.PUT_LINE('  Campo 19 (MONTO_SIS_FORM): ' || v_campo19);
                    DBMS_OUTPUT.PUT_LINE('  Campo 20 (FECHA_PAGO_FORM): ' || v_campo20);
                    DBMS_OUTPUT.PUT_LINE('  Campo 21 (USU_PAGO_RETRO): ' || v_campo21);
                    DBMS_OUTPUT.PUT_LINE('  Campo 22 (TIPO_IMPRE): ' || NVL(v_campo22, 0));
                    DBMS_OUTPUT.PUT_LINE('  Campo 23 (USU_COD): ' || v_campo23);
                    DBMS_OUTPUT.PUT_LINE('  Campo 24 (MES_RETRO_FORM): ' || NVL(v_campo24, 'NULL'));
                    DBMS_OUTPUT.PUT_LINE('  Campo 25 (NUMERO_FILA): ' || v_campo25);
                    DBMS_OUTPUT.PUT_LINE('  Campo 26 (ES_CAMBIO_PER): ' || v_campo26);
                    DBMS_OUTPUT.PUT_LINE('  Campo 27 (REG_POR_PAG): ' || v_campo27);
                    DBMS_OUTPUT.PUT_LINE('  Campo 28 (NUMERO_PAGINA): ' || v_campo28);
                END IF;

                -- Solo procesar los primeros 3 registros para debug
                IF v_count_datos >= 3 THEN
                    EXIT;
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('❌ ERROR en FETCH registro ' || (v_count_datos + 1));
                    DBMS_OUTPUT.PUT_LINE('   SQLCODE: ' || SQLCODE);
                    DBMS_OUTPUT.PUT_LINE('   SQLERRM: ' || SQLERRM);
                    DBMS_OUTPUT.PUT_LINE('   Esto indica que hay un problema de tipo de datos en algún campo');
                    
                    -- Intentar identificar qué campo causa el problema
                    DBMS_OUTPUT.PUT_LINE('   Verificar:');
                    DBMS_OUTPUT.PUT_LINE('   1. Que todos los campos NUMBER no contengan texto');
                    DBMS_OUTPUT.PUT_LINE('   2. Que todos los campos DATE sean fechas válidas');
                    DBMS_OUTPUT.PUT_LINE('   3. Que los campos VARCHAR2 no excedan el tamaño definido');
                    EXIT;
            END;
        END LOOP;
        
        CLOSE v_cursor_datos;
        
        DBMS_OUTPUT.PUT_LINE('============================================================================');
        DBMS_OUTPUT.PUT_LINE('RESULTADO DEL DEBUG');
        DBMS_OUTPUT.PUT_LINE('============================================================================');
        
        IF v_count_datos > 0 THEN
            DBMS_OUTPUT.PUT_LINE('🎉 ÉXITO: Se procesaron ' || v_count_datos || ' registros sin errores ORA-06502');
            DBMS_OUTPUT.PUT_LINE('✅ La estructura del cursor es correcta');
            DBMS_OUTPUT.PUT_LINE('✅ Los tipos de datos coinciden');
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('RECOMENDACIÓN: Usar el test corregido completo');
        ELSE
            DBMS_OUTPUT.PUT_LINE('⚠️  No se encontraron registros para procesar');
            DBMS_OUTPUT.PUT_LINE('   Verificar parámetros de entrada o datos en las tablas');
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error general procesando cursor: ' || SQLERRM);
            IF v_cursor_datos%ISOPEN THEN
                CLOSE v_cursor_datos;
            END IF;
    END;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERROR GENERAL EN DEBUG:');
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
        
        IF v_cursor_datos%ISOPEN THEN
            CLOSE v_cursor_datos;
        END IF;
END;
/

-- ============================================================================
-- VERIFICACIÓN ADICIONAL: ESTRUCTURA REAL DEL CURSOR
-- ============================================================================

PROMPT
PROMPT ============================================================================
PROMPT VERIFICANDO ESTRUCTURA REAL DEL CURSOR DEL SP
PROMPT ============================================================================

-- Script para mostrar la estructura real del cursor (solo si el SP funciona)
DECLARE
    v_cursor_datos SYS_REFCURSOR;
    v_cursor_desc  DBMS_SQL.DESC_TAB;
    v_cursor_id    INTEGER;
    v_col_count    INTEGER;
BEGIN
    -- Ejecutar SP solo para obtener estructura del cursor
    PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV(
        p_rut_tra           => 13613755,
        p_emp_rut           => 96758240,
        p_cnv_cta           => 1,
        p_sel_op            => 1,
        p_anio              => 2003,
        p_mes               => 08,
        p_anio_hasta        => 2003,
        p_mes_hasta         => 08,
        p_imp_ccaf          => 'N',
        p_tipo_con          => 1,
        p_cursor_datos      => v_cursor_datos,
        p_cursor_encabezado => v_cursor_datos, -- dummy
        p_cursor_metadatos  => v_cursor_datos, -- dummy
        p_num_registros     => v_col_count,    -- dummy
        p_num_paginas       => v_col_count,    -- dummy
        p_es_empresa_pub    => 'N',            -- dummy
        p_periodo_desde     => SYSDATE,        -- dummy
        p_periodo_hasta     => SYSDATE,        -- dummy
        p_mensaje_error     => 'dummy',        -- dummy
        p_codigo_retorno    => v_col_count     -- dummy
    );
    
    -- Convertir REF CURSOR a DBMS_SQL para obtener metadata
    v_cursor_id := DBMS_SQL.TO_CURSOR_NUMBER(v_cursor_datos);
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor_id, v_col_count, v_cursor_desc);
    
    DBMS_OUTPUT.PUT_LINE('Estructura real del cursor (total columnas: ' || v_col_count || '):');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    FOR i IN 1..v_col_count LOOP
        DBMS_OUTPUT.PUT_LINE('Campo ' || i || ': ' || v_cursor_desc(i).col_name || 
                           ' - Tipo: ' || v_cursor_desc(i).col_type || 
                           ' - Tamaño: ' || v_cursor_desc(i).col_max_len);
    END LOOP;
    
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('No se pudo obtener la estructura del cursor: ' || SQLERRM);
        IF DBMS_SQL.IS_OPEN(v_cursor_id) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        END IF;
END;
/
