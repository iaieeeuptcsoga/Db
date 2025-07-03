-- ============================================================================
-- SCRIPT DE PRUEBA PARA PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV
-- VERSIÓN 2: Con correcciones para ORA-06502 (buffer de cadenas demasiado pequeño)
-- ============================================================================
-- Descripción: Script para probar el stored procedure migrado desde CertificadoCotPrev.asp
-- Fecha: 2025-07-03
-- Autor: Migración Oracle
-- ============================================================================

SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    -- PARÁMETROS DE ENTRADA PARA LA PRUEBA (DATOS REALES)
    v_rut_tra           NUMBER := 13613755;     -- RUT del trabajador (datos reales)
    v_emp_rut           NUMBER := 96758240;     -- RUT de la empresa (datos reales)
    v_cnv_cta           NUMBER := 1;            -- Número de convenio
    v_sel_op            NUMBER := 1;            -- Opción de selección
    v_anio              NUMBER := 2003;         -- Año de consulta (datos reales)
    v_mes               NUMBER := 08;         -- Mes específico (NULL para todo el año)
    v_anio_hasta        NUMBER := 2003;         -- Año hasta (NULL para un solo año)
    v_mes_hasta         NUMBER := 08;         -- Mes hasta (NULL)
    v_imp_ccaf          VARCHAR2(1) := 'N';     -- Imprimir CCAF
    v_tipo_con          NUMBER := 1;            -- Tipo de consulta
    
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

    -- VARIABLES PARA PROCESAR LOS CURSORS
    v_count_datos       NUMBER := 0;
    v_count_encabezado  NUMBER := 0;
    v_count_metadatos   NUMBER := 0;

    -- VARIABLES PARA LEER DATOS DEL CURSOR PRINCIPAL
    TYPE t_cursor_datos IS RECORD (
        rec_periodo     DATE,
        nro_comprobante NUMBER,
        tipo_impre      NUMBER,
        suc_cod         VARCHAR2(6),
        usu_cod         VARCHAR2(6),    -- Corregido: era VARCHAR2(10), debe ser VARCHAR2(6)
        tipo_ent        VARCHAR2(1),
        ent_rut         NUMBER,
        ent_nombre      VARCHAR2(255),
        tra_rut         NUMBER,
        tra_dig         VARCHAR2(1),
        tra_nombre      VARCHAR2(100),  -- Corregido: era 40
        tra_ape         VARCHAR2(100),  -- Corregido: era 40
        dias_trab       NUMBER,
        rem_impo        NUMBER,
        monto_cotizado  NUMBER,
        fec_pago        DATE,
        folio_planilla  NUMBER(10),     -- Corregido: era VARCHAR2(20), debe ser NUMBER
        raz_soc         VARCHAR2(100),  -- Corregido: era VARCHAR2(255), debe ser VARCHAR2(100)
        salud           NUMBER,
        monto_sis       NUMBER
    );
    
    v_datos_rec t_cursor_datos;

BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('INICIANDO PRUEBA DE PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Parámetros de prueba:');
    DBMS_OUTPUT.PUT_LINE('- RUT Trabajador: ' || v_rut_tra);
    DBMS_OUTPUT.PUT_LINE('- RUT Empresa: ' || v_emp_rut);
    DBMS_OUTPUT.PUT_LINE('- Convenio: ' || v_cnv_cta);
    DBMS_OUTPUT.PUT_LINE('- Año: ' || v_anio);
    DBMS_OUTPUT.PUT_LINE('- Tipo Consulta: ' || v_tipo_con);
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

        DBMS_OUTPUT.PUT_LINE('✅ STORED PROCEDURE EJECUTADO EXITOSAMENTE');
        DBMS_OUTPUT.PUT_LINE('============================================================================');
        DBMS_OUTPUT.PUT_LINE('PARÁMETROS DE SALIDA:');
        DBMS_OUTPUT.PUT_LINE('- Código de retorno: ' || NVL(v_codigo_retorno, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Número de registros: ' || NVL(v_num_registros, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Número de páginas: ' || NVL(v_num_paginas, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Es empresa pública: ' || NVL(v_es_empresa_pub, 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Período desde: ' || NVL(TO_CHAR(v_periodo_desde, 'YYYY-MM-DD'), 'NULL'));
        DBMS_OUTPUT.PUT_LINE('- Período hasta: ' || NVL(TO_CHAR(v_periodo_hasta, 'YYYY-MM-DD'), 'NULL'));

        IF v_mensaje_error IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('⚠️  Mensaje de error: ' || v_mensaje_error);
        ELSE
            DBMS_OUTPUT.PUT_LINE('✅ Sin mensajes de error');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ ERROR AL EJECUTAR EL STORED PROCEDURE:');
            DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
            RETURN;
    END;

    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('PROCESANDO CURSORS DE SALIDA');
    DBMS_OUTPUT.PUT_LINE('============================================================================');

    -- PROCESAR CURSOR DE DATOS PRINCIPALES
    BEGIN
        DBMS_OUTPUT.PUT_LINE('📊 Procesando cursor de datos principales...');
        
        LOOP
            BEGIN
                FETCH v_cursor_datos INTO v_datos_rec;
                EXIT WHEN v_cursor_datos%NOTFOUND;

                v_count_datos := v_count_datos + 1;

                -- Mostrar solo los primeros 5 registros para no saturar la salida
                IF v_count_datos <= 5 THEN
                    DBMS_OUTPUT.PUT_LINE('  Registro ' || v_count_datos || ':');
                    DBMS_OUTPUT.PUT_LINE('    - Período: ' || TO_CHAR(v_datos_rec.rec_periodo, 'YYYY-MM-DD'));
                    DBMS_OUTPUT.PUT_LINE('    - Trabajador: ' || v_datos_rec.tra_nombre || ' ' || v_datos_rec.tra_ape);
                    DBMS_OUTPUT.PUT_LINE('    - Entidad: ' || SUBSTR(v_datos_rec.ent_nombre, 1, 50));
                    DBMS_OUTPUT.PUT_LINE('    - SUC_COD: [' || v_datos_rec.suc_cod || ']');
                    DBMS_OUTPUT.PUT_LINE('    - USU_COD: [' || v_datos_rec.usu_cod || ']');
                    DBMS_OUTPUT.PUT_LINE('    - Monto Cotizado: ' || NVL(v_datos_rec.monto_cotizado, 0));
                    DBMS_OUTPUT.PUT_LINE('    - Días Trabajados: ' || NVL(v_datos_rec.dias_trab, 0));
                    DBMS_OUTPUT.PUT_LINE('    - Folio Planilla: ' || NVL(v_datos_rec.folio_planilla, 0));
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('❌ ERROR en FETCH registro ' || (v_count_datos + 1) || ': ' || SQLERRM);
                    DBMS_OUTPUT.PUT_LINE('   Error Code: ' || SQLCODE);
                    EXIT; -- Salir del loop si hay error en FETCH
            END;
        END LOOP;
        
        CLOSE v_cursor_datos;
        DBMS_OUTPUT.PUT_LINE('✅ Total registros en cursor datos: ' || v_count_datos);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error procesando cursor de datos: ' || SQLERRM);
            IF v_cursor_datos%ISOPEN THEN
                CLOSE v_cursor_datos;
            END IF;
    END;

    -- PROCESAR CURSOR DE ENCABEZADO
    BEGIN
        DBMS_OUTPUT.PUT_LINE('📋 Procesando cursor de encabezado...');
        
        LOOP
            FETCH v_cursor_encabezado INTO v_datos_rec;
            EXIT WHEN v_cursor_encabezado%NOTFOUND;
            v_count_encabezado := v_count_encabezado + 1;
        END LOOP;
        
        CLOSE v_cursor_encabezado;
        DBMS_OUTPUT.PUT_LINE('✅ Total registros en cursor encabezado: ' || v_count_encabezado);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error procesando cursor de encabezado: ' || SQLERRM);
            IF v_cursor_encabezado%ISOPEN THEN
                CLOSE v_cursor_encabezado;
            END IF;
    END;

    -- PROCESAR CURSOR DE METADATOS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('📈 Procesando cursor de metadatos...');
        
        LOOP
            FETCH v_cursor_metadatos INTO v_datos_rec;
            EXIT WHEN v_cursor_metadatos%NOTFOUND;
            v_count_metadatos := v_count_metadatos + 1;
        END LOOP;
        
        CLOSE v_cursor_metadatos;
        DBMS_OUTPUT.PUT_LINE('✅ Total registros en cursor metadatos: ' || v_count_metadatos);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error procesando cursor de metadatos: ' || SQLERRM);
            IF v_cursor_metadatos%ISOPEN THEN
                CLOSE v_cursor_metadatos;
            END IF;
    END;

    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE LA PRUEBA');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('✅ Stored Procedure: EJECUTADO CORRECTAMENTE');
    DBMS_OUTPUT.PUT_LINE('📊 Registros de datos: ' || v_count_datos);
    DBMS_OUTPUT.PUT_LINE('📋 Registros de encabezado: ' || v_count_encabezado);
    DBMS_OUTPUT.PUT_LINE('📈 Registros de metadatos: ' || v_count_metadatos);
    DBMS_OUTPUT.PUT_LINE('📄 Total registros (SP): ' || NVL(v_num_registros, 0));
    DBMS_OUTPUT.PUT_LINE('📑 Total páginas (SP): ' || NVL(v_num_paginas, 0));
    DBMS_OUTPUT.PUT_LINE('🏢 Tipo empresa: ' || CASE WHEN v_es_empresa_pub = 'S' THEN 'PÚBLICA' WHEN v_es_empresa_pub = 'N' THEN 'PRIVADA' ELSE 'DESCONOCIDO' END);

    IF v_count_datos > 0 THEN
        DBMS_OUTPUT.PUT_LINE('🎉 PRUEBA EXITOSA: El SP retornó datos');
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠️  ADVERTENCIA: El SP no retornó datos (verificar parámetros)');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERROR GENERAL EN LA PRUEBA:');
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
        
        -- Cerrar cursors si están abiertos
        IF v_cursor_datos%ISOPEN THEN
            CLOSE v_cursor_datos;
        END IF;
        IF v_cursor_encabezado%ISOPEN THEN
            CLOSE v_cursor_encabezado;
        END IF;
        IF v_cursor_metadatos%ISOPEN THEN
            CLOSE v_cursor_metadatos;
        END IF;
END;
/

-- ============================================================================
-- SCRIPT ADICIONAL: VERIFICAR DEPENDENCIAS
-- ============================================================================

PROMPT
PROMPT ============================================================================
PROMPT VERIFICANDO DEPENDENCIAS DEL STORED PROCEDURE
PROMPT ============================================================================

-- Verificar que los SPs dependientes existen
SELECT 'PRC_REC_CERTCOT_TRAB' AS procedimiento,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado
FROM user_procedures 
WHERE object_name = 'PRC_REC_CERTCOT_TRAB'
UNION ALL
SELECT 'PRC_CERTCOT_TRAB_PUB' AS procedimiento,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado
FROM user_procedures 
WHERE object_name = 'PRC_CERTCOT_TRAB_PUB'
UNION ALL
SELECT 'PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV' AS procedimiento,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado
FROM user_procedures 
WHERE object_name = 'PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV';

PROMPT
PROMPT ============================================================================
PROMPT INSTRUCCIONES PARA EJECUTAR LA PRUEBA:
PROMPT ============================================================================
PROMPT 1. Ajustar los parámetros v_rut_tra y v_emp_rut con datos reales
PROMPT 2. Verificar que existan datos para el año especificado (v_anio)
PROMPT 3. Ejecutar este script en SQL*Plus o SQL Developer
PROMPT 4. Revisar la salida para verificar el funcionamiento correcto
PROMPT ============================================================================
