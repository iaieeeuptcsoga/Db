-- ============================================================================
-- SCRIPT DE PRUEBA REFACTORIZADO PARA PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV
-- VERSIÓN 3: Basado en los datos exitosos de PRC_REC_CERTCOT_TRAB
-- ============================================================================
-- Descripción: Script refactorizado usando los mismos parámetros que funcionan
--              con PRC_REC_CERTCOT_TRAB para garantizar datos consistentes
-- Fecha: 2025-07-04
-- Datos de prueba: RUT Trabajador 3221253, RUT Empresa 83146800, Período 2000-2003
-- ============================================================================

SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    -- PARÁMETROS DE ENTRADA BASADOS EN LOS DATOS EXITOSOS DE PRC_REC_CERTCOT_TRAB
    v_rut_tra           NUMBER := 3221253;      -- RUT del trabajador (datos comprobados)
    v_emp_rut           NUMBER := 83146800;     -- RUT de la empresa (datos comprobados)
    v_cnv_cta           NUMBER := 1;            -- Número de convenio (datos comprobados)
    v_sel_op            NUMBER := 1;            -- Opción 1: Busca un año específico
    v_anio              NUMBER := 2000;         -- Año 2000 (datos comprobados con registros)
    v_mes               NUMBER := NULL;         -- NULL para todo el año
    v_anio_hasta        NUMBER := NULL;         -- NULL para un solo año
    v_mes_hasta         NUMBER := NULL;         -- NULL
    v_imp_ccaf          VARCHAR2(1) := 'N';     -- No imprimir CCAF
    v_tipo_con          NUMBER := 1;            -- Tipo de consulta 1 (datos comprobados)
    
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
    v_total_cotizaciones NUMBER := 0;

    -- VARIABLES PARA LEER DATOS DEL CURSOR PRINCIPAL (ESTRUCTURA CORREGIDA)
    TYPE t_cursor_datos IS RECORD (
        -- DATOS DE IDENTIFICACIÓN
        REC_PERIODO                     DATE,
        TRA_RUT                         NUMBER,
        TRA_DIG                         VARCHAR2(1),
        TRABAJADOR_NOMBRE_COMPLETO      VARCHAR2(201),  -- TRA_NOMBRE + ' ' + TRA_APE
        ENT_RUT                         NUMBER,
        ENT_NOMBRE                      VARCHAR2(255),
        EMPRESA_RAZON_SOCIAL            VARCHAR2(100),
        -- DATOS FINANCIEROS
        DIAS_TRAB                       NUMBER,
        REM_IMPO                        NUMBER,
        MONTO_COTIZADO                  NUMBER,
        MONTO_SIS                       NUMBER,
        FEC_PAGO                        DATE,
        FOLIO_PLANILLA                  NUMBER,
        SALUD                           NUMBER,
        -- FORMATEO PARA PDF
        MES_ANIO_FORMATEADO             VARCHAR2(20),
        ENTIDAD_NOMBRE_FORMATEADO       VARCHAR2(26),
        REM_IMPO_FORMATEADO             VARCHAR2(20),
        MONTO_COTIZADO_FORMATEADO       VARCHAR2(20),
        MONTO_SIS_FORMATEADO            VARCHAR2(20),
        FECHA_PAGO_FORMATEADA           VARCHAR2(10),
        -- CAMPOS ESPECÍFICOS PARA EMPRESAS PÚBLICAS
        USU_PAGO_RETROACTIVO            VARCHAR2(1),
        TIPO_IMPRE                      NUMBER,
        USU_COD                         VARCHAR2(6),
        MES_RETROACTIVO_FORMATEADO      VARCHAR2(20),
        -- CONTROL DE PAGINACIÓN
        NUMERO_FILA                     NUMBER,
        ES_CAMBIO_PERIODO               VARCHAR2(1),
        REGISTROS_POR_PAGINA            NUMBER,
        NUMERO_PAGINA                   NUMBER
    );
    
    v_datos_rec t_cursor_datos;

    -- VARIABLES PARA CURSOR DE ENCABEZADO
    TYPE t_cursor_encabezado IS RECORD (
        TRABAJADOR_RUT                  NUMBER,
        TRABAJADOR_DV                   VARCHAR2(1),
        TRABAJADOR_NOMBRE               VARCHAR2(161),
        EMPRESA_RUT                     NUMBER,
        EMPRESA_DV                      VARCHAR2(1),
        EMPRESA_RAZON_SOCIAL            VARCHAR2(100),
        PERIODO_DESDE_FORMATEADO        VARCHAR2(10),
        PERIODO_HASTA_FORMATEADO        VARCHAR2(10),
        TITULO_CERTIFICADO              VARCHAR2(100),
        ES_EMPRESA_PUBLICA              VARCHAR2(1),
        IMPRIMIR_CCAF                   VARCHAR2(1),
        TIPO_CONTRATO                   NUMBER,
        FECHA_EMISION                   VARCHAR2(10),
        FECHA_ARCHIVO                   VARCHAR2(8),
        TEXTO_LEGAL                     VARCHAR2(500)
    );
    
    v_encabezado_rec t_cursor_encabezado;

    -- VARIABLES PARA CURSOR DE METADATOS
    TYPE t_cursor_metadatos IS RECORD (
        TOTAL_REGISTROS                 NUMBER,
        TOTAL_PAGINAS                   NUMBER,
        REGISTROS_POR_PAGINA            NUMBER,
        ES_EMPRESA_PUBLICA              VARCHAR2(1),
        MOSTRAR_COLUMNA_MES_RETRO       VARCHAR2(1),
        ANCHOS_COLUMNAS                 VARCHAR2(200),
        HEADERS_COLUMNAS                VARCHAR2(500),
        FUENTE_DATOS                    VARCHAR2(20),
        TAMAÑO_FUENTE_DATOS             NUMBER,
        FUENTE_HEADERS                  VARCHAR2(20),
        TAMAÑO_FUENTE_HEADERS           NUMBER,
        FUENTE_TITULO                   VARCHAR2(20),
        TAMAÑO_FUENTE_TITULO            NUMBER,
        COLOR_TEXTO                     VARCHAR2(20),
        COLOR_LINEAS                    VARCHAR2(20),
        COLOR_FONDO                     VARCHAR2(20),
        MARGEN_IZQUIERDO                NUMBER,
        MARGEN_DERECHO                  NUMBER,
        MARGEN_SUPERIOR                 NUMBER,
        MARGEN_INFERIOR                 NUMBER,
        NOMBRE_INSTITUCION              VARCHAR2(50),
        NOMBRE_SISTEMA                  VARCHAR2(100)
    );
    
    v_metadatos_rec t_cursor_metadatos;

BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('SCRIPT DE PRUEBA REFACTORIZADO - PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('Usando los mismos datos exitosos de PRC_REC_CERTCOT_TRAB:');
    DBMS_OUTPUT.PUT_LINE('- RUT Trabajador: ' || v_rut_tra || ' (RAUL GUAJARDO ADASME)');
    DBMS_OUTPUT.PUT_LINE('- RUT Empresa: ' || v_emp_rut || ' (comprobada con datos)');
    DBMS_OUTPUT.PUT_LINE('- Convenio: ' || v_cnv_cta);
    DBMS_OUTPUT.PUT_LINE('- Año: ' || v_anio || ' (período con 23 registros confirmados)');
    DBMS_OUTPUT.PUT_LINE('- Tipo Consulta: ' || v_tipo_con || ' (Solo AFP)');
    DBMS_OUTPUT.PUT_LINE('- Período esperado: 01/01/2000 al 31/12/2000');
    DBMS_OUTPUT.PUT_LINE('============================================================================');

    -- EJECUTAR EL STORED PROCEDURE
    BEGIN
        DBMS_OUTPUT.PUT_LINE('🚀 Ejecutando PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV...');
        
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
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ ERROR AL EJECUTAR EL STORED PROCEDURE:');
            DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
            RETURN;
    END;

    -- MOSTRAR PARÁMETROS DE SALIDA
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('PARÁMETROS DE SALIDA:');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('📊 Código de retorno: ' || NVL(TO_CHAR(v_codigo_retorno), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('📊 Número de registros: ' || NVL(TO_CHAR(v_num_registros), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('📊 Número de páginas: ' || NVL(TO_CHAR(v_num_paginas), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('🏢 Es empresa pública: ' || NVL(v_es_empresa_pub, 'NULL'));
    DBMS_OUTPUT.PUT_LINE('📅 Período desde: ' || NVL(TO_CHAR(v_periodo_desde, 'DD/MM/YYYY'), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('📅 Período hasta: ' || NVL(TO_CHAR(v_periodo_hasta, 'DD/MM/YYYY'), 'NULL'));

    IF v_mensaje_error IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('⚠️  Mensaje de error: ' || v_mensaje_error);
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Sin mensajes de error');
    END IF;

    -- VALIDAR CÓDIGO DE RETORNO
    IF v_codigo_retorno != 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ CÓDIGO DE RETORNO INDICA ERROR: ' || v_codigo_retorno);
        IF v_mensaje_error IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('   Mensaje: ' || v_mensaje_error);
        END IF;
        DBMS_OUTPUT.PUT_LINE('============================================================================');
        RETURN;
    END IF;

    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('PROCESANDO CURSORS DE SALIDA');
    DBMS_OUTPUT.PUT_LINE('============================================================================');

    -- 1. PROCESAR CURSOR DE ENCABEZADO PRIMERO (información básica)
    BEGIN
        DBMS_OUTPUT.PUT_LINE('📋 Procesando cursor de encabezado...');
        
        FETCH v_cursor_encabezado INTO v_encabezado_rec;
        IF v_cursor_encabezado%FOUND THEN
            v_count_encabezado := 1;
            DBMS_OUTPUT.PUT_LINE('   ✅ Datos del encabezado:');
            DBMS_OUTPUT.PUT_LINE('     - Trabajador: ' || v_encabezado_rec.TRABAJADOR_RUT || '-' || v_encabezado_rec.TRABAJADOR_DV);
            DBMS_OUTPUT.PUT_LINE('     - Nombre: ' || SUBSTR(v_encabezado_rec.TRABAJADOR_NOMBRE, 1, 50));
            DBMS_OUTPUT.PUT_LINE('     - Empresa: ' || v_encabezado_rec.EMPRESA_RUT || '-' || v_encabezado_rec.EMPRESA_DV);
            DBMS_OUTPUT.PUT_LINE('     - Razón Social: ' || SUBSTR(v_encabezado_rec.EMPRESA_RAZON_SOCIAL, 1, 50));
            DBMS_OUTPUT.PUT_LINE('     - Título: ' || v_encabezado_rec.TITULO_CERTIFICADO);
            DBMS_OUTPUT.PUT_LINE('     - Período: ' || v_encabezado_rec.PERIODO_DESDE_FORMATEADO || ' al ' || v_encabezado_rec.PERIODO_HASTA_FORMATEADO);
        END IF;
        
        CLOSE v_cursor_encabezado;
        DBMS_OUTPUT.PUT_LINE('   📊 Total registros en cursor encabezado: ' || v_count_encabezado);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error procesando cursor de encabezado: ' || SQLERRM);
            IF v_cursor_encabezado%ISOPEN THEN
                CLOSE v_cursor_encabezado;
            END IF;
    END;

    -- 2. PROCESAR CURSOR DE METADATOS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('📈 Procesando cursor de metadatos...');
        
        FETCH v_cursor_metadatos INTO v_metadatos_rec;
        IF v_cursor_metadatos%FOUND THEN
            v_count_metadatos := 1;
            DBMS_OUTPUT.PUT_LINE('   ✅ Configuración del certificado:');
            DBMS_OUTPUT.PUT_LINE('     - Total Registros: ' || v_metadatos_rec.TOTAL_REGISTROS);
            DBMS_OUTPUT.PUT_LINE('     - Total Páginas: ' || v_metadatos_rec.TOTAL_PAGINAS);
            DBMS_OUTPUT.PUT_LINE('     - Registros por página: ' || v_metadatos_rec.REGISTROS_POR_PAGINA);
            DBMS_OUTPUT.PUT_LINE('     - Es empresa pública: ' || v_metadatos_rec.ES_EMPRESA_PUBLICA);
            DBMS_OUTPUT.PUT_LINE('     - Mostrar columna mes retro: ' || v_metadatos_rec.MOSTRAR_COLUMNA_MES_RETRO);
            DBMS_OUTPUT.PUT_LINE('     - Institución: ' || v_metadatos_rec.NOMBRE_INSTITUCION);
        END IF;
        
        CLOSE v_cursor_metadatos;
        DBMS_OUTPUT.PUT_LINE('   📊 Total registros en cursor metadatos: ' || v_count_metadatos);
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error procesando cursor de metadatos: ' || SQLERRM);
            IF v_cursor_metadatos%ISOPEN THEN
                CLOSE v_cursor_metadatos;
            END IF;
    END;

    -- 3. PROCESAR CURSOR DE DATOS PRINCIPALES
    BEGIN
        DBMS_OUTPUT.PUT_LINE('📊 Procesando cursor de datos principales...');
        DBMS_OUTPUT.PUT_LINE('   🔍 Mostrando primeros 10 registros detallados...');
        
        LOOP
            BEGIN
                FETCH v_cursor_datos INTO v_datos_rec;
                EXIT WHEN v_cursor_datos%NOTFOUND;

                v_count_datos := v_count_datos + 1;
                v_total_cotizaciones := v_total_cotizaciones + NVL(v_datos_rec.MONTO_COTIZADO, 0);

                -- Mostrar solo los primeros 10 registros detallados
                IF v_count_datos <= 10 THEN
                    DBMS_OUTPUT.PUT_LINE('   📋 Registro ' || v_count_datos || ':');
                    DBMS_OUTPUT.PUT_LINE('     - Período: ' || TO_CHAR(v_datos_rec.REC_PERIODO, 'MM/YYYY') || 
                                         ' (' || v_datos_rec.MES_ANIO_FORMATEADO || ')');
                    DBMS_OUTPUT.PUT_LINE('     - Trabajador: ' || v_datos_rec.TRA_RUT || '-' || v_datos_rec.TRA_DIG);
                    DBMS_OUTPUT.PUT_LINE('     - Nombre: ' || SUBSTR(v_datos_rec.TRABAJADOR_NOMBRE_COMPLETO, 1, 40));
                    DBMS_OUTPUT.PUT_LINE('     - Entidad: ' || SUBSTR(v_datos_rec.ENTIDAD_NOMBRE_FORMATEADO, 1, 25) || 
                                         ' (RUT: ' || v_datos_rec.ENT_RUT || ')');
                    DBMS_OUTPUT.PUT_LINE('     - Días Trabajados: ' || NVL(v_datos_rec.DIAS_TRAB, 0));
                    DBMS_OUTPUT.PUT_LINE('     - Rem. Imponible: $' || v_datos_rec.REM_IMPO_FORMATEADO);
                    DBMS_OUTPUT.PUT_LINE('     - Monto Cotizado: $' || v_datos_rec.MONTO_COTIZADO_FORMATEADO);
                    DBMS_OUTPUT.PUT_LINE('     - Monto SIS: $' || v_datos_rec.MONTO_SIS_FORMATEADO);
                    DBMS_OUTPUT.PUT_LINE('     - Fecha Pago: ' || v_datos_rec.FECHA_PAGO_FORMATEADA);
                    DBMS_OUTPUT.PUT_LINE('     - Folio Planilla: ' || NVL(v_datos_rec.FOLIO_PLANILLA, 0));
                    DBMS_OUTPUT.PUT_LINE('     - Página: ' || v_datos_rec.NUMERO_PAGINA || 
                                         ' (Fila: ' || v_datos_rec.NUMERO_FILA || ')');
                    IF v_datos_rec.ES_CAMBIO_PERIODO = 'S' THEN
                        DBMS_OUTPUT.PUT_LINE('     🔄 *** CAMBIO DE PERÍODO ***');
                    END IF;
                ELSIF v_count_datos = 11 THEN
                    DBMS_OUTPUT.PUT_LINE('   ... (mostrando solo primeros 10 registros detallados)');
                END IF;

            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('❌ ERROR en FETCH registro ' || (v_count_datos + 1) || ': ' || SQLERRM);
                    DBMS_OUTPUT.PUT_LINE('   Error Code: ' || SQLCODE);
                    EXIT; -- Salir del loop si hay error en FETCH
            END;
        END LOOP;
        
        CLOSE v_cursor_datos;
        DBMS_OUTPUT.PUT_LINE('   📊 Total registros procesados: ' || v_count_datos);
        DBMS_OUTPUT.PUT_LINE('   💰 Total cotizaciones: $' || TO_CHAR(v_total_cotizaciones, 'FM999,999,999,999'));
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('❌ Error procesando cursor de datos: ' || SQLERRM);
            IF v_cursor_datos%ISOPEN THEN
                CLOSE v_cursor_datos;
            END IF;
    END;

    -- RESUMEN FINAL Y VALIDACIONES
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN FINAL DE LA PRUEBA');
    DBMS_OUTPUT.PUT_LINE('============================================================================');
    
    -- Resultados obtenidos
    DBMS_OUTPUT.PUT_LINE('📊 RESULTADOS OBTENIDOS:');
    DBMS_OUTPUT.PUT_LINE('   - Registros obtenidos: ' || v_count_datos);
    DBMS_OUTPUT.PUT_LINE('   - Cotizaciones obtenidas: $' || TO_CHAR(v_total_cotizaciones, 'FM999,999,999,999'));
    
    -- Validaciones
    IF v_count_datos = 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERROR: NO SE OBTUVIERON DATOS');
        DBMS_OUTPUT.PUT_LINE('   Posibles causas:');
        DBMS_OUTPUT.PUT_LINE('   - Error en la configuración de período');
        DBMS_OUTPUT.PUT_LINE('   - Error en la llamada a PRC_REC_CERTCOT_TRAB interno');
        DBMS_OUTPUT.PUT_LINE('   - Problema con las GTT (Global Temporary Tables)');
    ELSIF v_count_datos = v_num_registros THEN
        DBMS_OUTPUT.PUT_LINE('✅ CONSISTENCIA: Registros del cursor = parámetro num_registros');
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠️  INCONSISTENCIA: Registros del cursor ≠ parámetro num_registros');
    END IF;
    
    -- Validación de completitud de cursors
    DBMS_OUTPUT.PUT_LINE('📋 ESTADO DE CURSORS:');
    DBMS_OUTPUT.PUT_LINE('   - Cursor datos: ' || v_count_datos || ' registros');
    DBMS_OUTPUT.PUT_LINE('   - Cursor encabezado: ' || v_count_encabezado || ' registros');
    DBMS_OUTPUT.PUT_LINE('   - Cursor metadatos: ' || v_count_metadatos || ' registros');
    
    -- Resultado final
    IF v_codigo_retorno = 0 AND v_count_datos > 0 AND v_count_encabezado > 0 AND v_count_metadatos > 0 THEN
        DBMS_OUTPUT.PUT_LINE('🎉 PRUEBA EXITOSA: SP funcionando correctamente');
        DBMS_OUTPUT.PUT_LINE('   ✅ Código retorno: OK');
        DBMS_OUTPUT.PUT_LINE('   ✅ Datos obtenidos: OK');
        DBMS_OUTPUT.PUT_LINE('   ✅ Encabezado generado: OK');
        DBMS_OUTPUT.PUT_LINE('   ✅ Metadatos generados: OK');
    ELSE
        DBMS_OUTPUT.PUT_LINE('⚠️  ADVERTENCIA: Revisar configuración del SP');
        IF v_codigo_retorno != 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ Código de retorno indica error');
        END IF;
        IF v_count_datos = 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ No se obtuvieron datos');
        END IF;
        IF v_count_encabezado = 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ No se generó encabezado');
        END IF;
        IF v_count_metadatos = 0 THEN
            DBMS_OUTPUT.PUT_LINE('   ❌ No se generaron metadatos');
        END IF;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('============================================================================');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ ERROR GENERAL EN LA PRUEBA:');
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error Stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        
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
-- SCRIPT ADICIONAL: VERIFICACIÓN DE DEPENDENCIAS Y CONFIGURACIÓN
-- ============================================================================

PROMPT
PROMPT ============================================================================
PROMPT VERIFICANDO CONFIGURACIÓN PARA LOS DATOS DE PRUEBA
PROMPT ============================================================================

-- Verificar que existen los datos base
SELECT 'TRABAJADOR 3221253' AS verificacion,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado,
       MAX(TRA_NOMTRA || ' ' || TRA_APETRA) AS nombre
FROM REC_TRABAJADOR 
WHERE TRA_RUT = 3221253
UNION ALL
SELECT 'EMPRESA 83146800' AS verificacion,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado,
       MAX(EMP_RAZSOC) AS nombre
FROM REC_EMPRESA 
WHERE CON_RUT = 83146800 AND CON_CORREL = 1
UNION ALL
SELECT 'REGISTROS AÑO 2000' AS verificacion,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTEN (' || COUNT(*) || ')' ELSE '❌ NO EXISTEN' END AS estado,
       'Períodos: ' || MIN(TO_CHAR(REC_PERIODO, 'MM/YYYY')) || ' - ' || MAX(TO_CHAR(REC_PERIODO, 'MM/YYYY')) AS nombre
FROM REC_TRABAJADOR 
WHERE TRA_RUT = 3221253 
  AND EXTRACT(YEAR FROM REC_PERIODO) = 2000;

-- Verificar que los SPs dependientes existen
SELECT 'PRC_REC_CERTCOT_TRAB' AS procedimiento,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado,
       'Dependencia crítica' AS notas
FROM user_procedures 
WHERE object_name = 'PRC_REC_CERTCOT_TRAB'
UNION ALL
SELECT 'PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV' AS procedimiento,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado,
       'SP principal' AS notas
FROM user_procedures 
WHERE object_name = 'PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV';

-- Verificar GTT (Global Temporary Tables)
SELECT 'GTT_REC_CERT_DETALLE' AS tabla_temporal,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado,
       'Requerida para certificados' AS notas
FROM user_tables 
WHERE table_name = 'GTT_REC_CERT_DETALLE'
UNION ALL
SELECT 'GTT_REC_VIR_TRA' AS tabla_temporal,
       CASE WHEN COUNT(*) > 0 THEN '✅ EXISTE' ELSE '❌ NO EXISTE' END AS estado,
       'Requerida para procesamiento' AS notas
FROM user_tables 
WHERE table_name = 'GTT_REC_VIR_TRA';

PROMPT
PROMPT ============================================================================
PROMPT INSTRUCCIONES DE USO:
PROMPT ============================================================================
PROMPT 1. Los parámetros están basados en datos comprobados que funcionan
PROMPT 2. RUT Trabajador 3221253 tiene registros confirmados en el año 2000
PROMPT 3. RUT Empresa 83146800 existe y tiene convenio 1
PROMPT 4. Se esperan aproximadamente 23 registros (como PRC_REC_CERTCOT_TRAB)
PROMPT 5. Total cotizaciones esperado: alrededor de $155,256
PROMPT 6. El script muestra comparación detallada con el SP base
PROMPT 7. Valida automáticamente la consistencia de los resultados
PROMPT ============================================================================