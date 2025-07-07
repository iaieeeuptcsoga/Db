-- ===================================================================================
-- SCRIPT DE PRUEBA PARA PRC_SIL_CERTIFICADO_COTIZACIONES
-- ===================================================================================
-- Autor: Testing migración desde ASP VBScript
-- Fecha: 2025-01-07
-- Descripción: Script completo para probar el procedimiento de certificados
-- ===================================================================================

DECLARE
    -- Variables para cursores de salida
    v_datos_trabajador SYS_REFCURSOR;
    v_datos_cotizaciones SYS_REFCURSOR;
    
    -- Variables para resultados
    v_resultado NUMBER;
    v_mensaje VARCHAR2(500);
    
    -- Variables para datos del trabajador
    v_tra_rut NUMBER;
    v_tra_digito VARCHAR2(1);
    v_nombre_completo VARCHAR2(100);
    v_emp_rut NUMBER;
    v_emp_digito VARCHAR2(1);
    v_emp_razsoc VARCHAR2(40);
    v_direccion_completa VARCHAR2(200);
    v_emp_telefono VARCHAR2(12);
    v_emp_rut_repr NUMBER;
    v_emp_digito_repr VARCHAR2(1);
    v_emp_ape_repr VARCHAR2(20);
    v_emp_nom_repr VARCHAR2(20);
    v_periodo_desde VARCHAR2(12);
    v_periodo_hasta VARCHAR2(12);
    v_fecha_generacion VARCHAR2(8);
    
    -- Variables para datos de cotizaciones
    v_rec_periodo DATE;
    v_mes_anio_periodo VARCHAR2(20);
    v_institucion_prevision VARCHAR2(26);
    v_fecha_inicio_subsidio VARCHAR2(12);
    v_fecha_termino_subsidio VARCHAR2(12);
    v_dias_trabajados NUMBER;
    v_remuneracion_imponible NUMBER;
    v_monto_cotizado NUMBER;
    v_fecha_pago VARCHAR2(12);
    v_folio_planilla NUMBER;
    v_entidad_pagadora VARCHAR2(24);
    v_tipo_entidad VARCHAR2(1);
    v_ent_rut NUMBER;
    
    -- Contadores
    v_count_trabajador NUMBER := 0;
    v_count_cotizaciones NUMBER := 0;

BEGIN
    -- ===================================================================================
    -- CONFIGURACIÓN DE SALIDA PARA DEBUGGING
    -- ===================================================================================
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    DBMS_OUTPUT.PUT_LINE('INICIANDO PRUEBAS DEL PROCEDIMIENTO PRC_SIL_CERTIFICADO_COTIZACIONES');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    DBMS_OUTPUT.PUT_LINE('Fecha/Hora: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- ===================================================================================
    -- PRUEBA 1: CERTIFICADO POR AÑO ESPECÍFICO (Operación tipo 1)
    -- ===================================================================================
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1: Certificado por año específico (2025)');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    
    BEGIN
        -- Ejecutar el procedimiento principal
        PRC_SIL_CERTIFICADO_COTIZACIONES(
            p_rut_trabajador => 9430482,      -- RUT del trabajador (del ejemplo ASP)
            p_cnv_cta => 500,                 -- Código de convenio (del ejemplo ASP)
            p_sel_operacion => 1,             -- Año específico
            p_anio => 2025,                   -- Año 2025
            p_mes => 0,                       -- No se usa para tipo 1
            p_anio_hasta => 0,                -- No se usa para tipo 1
            p_mes_hasta => 0,                 -- No se usa para tipo 1
            p_imp_ccaf => 0,                  -- Sin filtro CCAF
            p_emp_rut => 81826800,            -- RUT empresa (del ejemplo ASP)
            p_rut_representante => 12345678,  -- RUT representante de prueba
            p_cod_perfil => 'SI',             -- Perfil con acceso completo
            p_datos_trabajador => v_datos_trabajador,
            p_datos_cotizaciones => v_datos_cotizaciones,
            p_resultado => v_resultado,
            p_mensaje => v_mensaje
        );
        
        DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado);
        DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje);
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Procesar datos del trabajador si fue exitoso
        IF v_resultado = 1 THEN
            DBMS_OUTPUT.PUT_LINE('DATOS DEL TRABAJADOR:');
            DBMS_OUTPUT.PUT_LINE('---------------------');
            
            LOOP
                FETCH v_datos_trabajador INTO 
                    v_tra_rut, v_tra_digito, v_nombre_completo, v_emp_rut, v_emp_digito,
                    v_emp_razsoc, v_direccion_completa, v_emp_telefono, v_emp_rut_repr,
                    v_emp_digito_repr, v_emp_ape_repr, v_emp_nom_repr, v_periodo_desde,
                    v_periodo_hasta, v_fecha_generacion;
                
                EXIT WHEN v_datos_trabajador%NOTFOUND;
                
                v_count_trabajador := v_count_trabajador + 1;
                
                DBMS_OUTPUT.PUT_LINE('RUT Trabajador: ' || v_tra_rut || '-' || v_tra_digito);
                DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_completo);
                DBMS_OUTPUT.PUT_LINE('RUT Empresa: ' || v_emp_rut || '-' || v_emp_digito);
                DBMS_OUTPUT.PUT_LINE('Razón Social: ' || v_emp_razsoc);
                DBMS_OUTPUT.PUT_LINE('Dirección: ' || v_direccion_completa);
                DBMS_OUTPUT.PUT_LINE('Período: ' || v_periodo_desde || ' al ' || v_periodo_hasta);
                DBMS_OUTPUT.PUT_LINE('Fecha Generación: ' || v_fecha_generacion);
                
            END LOOP;
            CLOSE v_datos_trabajador;
            
            DBMS_OUTPUT.PUT_LINE('');
            DBMS_OUTPUT.PUT_LINE('DATOS DE COTIZACIONES:');
            DBMS_OUTPUT.PUT_LINE('----------------------');
            
            LOOP
                FETCH v_datos_cotizaciones INTO 
                    v_rec_periodo, v_mes_anio_periodo, v_institucion_prevision,
                    v_fecha_inicio_subsidio, v_fecha_termino_subsidio, v_dias_trabajados,
                    v_remuneracion_imponible, v_monto_cotizado, v_fecha_pago,
                    v_folio_planilla, v_entidad_pagadora, v_tipo_entidad, v_ent_rut;
                
                EXIT WHEN v_datos_cotizaciones%NOTFOUND;
                
                v_count_cotizaciones := v_count_cotizaciones + 1;
                
                DBMS_OUTPUT.PUT_LINE('Registro ' || v_count_cotizaciones || ':');
                DBMS_OUTPUT.PUT_LINE('  Período: ' || TO_CHAR(v_rec_periodo, 'DD/MM/YYYY') || ' (' || v_mes_anio_periodo || ')');
                DBMS_OUTPUT.PUT_LINE('  Institución: ' || v_institucion_prevision);
                DBMS_OUTPUT.PUT_LINE('  Días trabajados: ' || v_dias_trabajados);
                DBMS_OUTPUT.PUT_LINE('  Remuneración: $' || TO_CHAR(v_remuneracion_imponible, '999,999,999'));
                DBMS_OUTPUT.PUT_LINE('  Monto cotizado: $' || TO_CHAR(v_monto_cotizado, '999,999,999'));
                DBMS_OUTPUT.PUT_LINE('  Fecha pago: ' || v_fecha_pago);
                DBMS_OUTPUT.PUT_LINE('  Folio planilla: ' || NVL(TO_CHAR(v_folio_planilla), 'N/A'));
                DBMS_OUTPUT.PUT_LINE('  Tipo entidad: ' || v_tipo_entidad);
                DBMS_OUTPUT.PUT_LINE('  ---');
                
            END LOOP;
            CLOSE v_datos_cotizaciones;
            
            DBMS_OUTPUT.PUT_LINE('Total registros de cotizaciones: ' || v_count_cotizaciones);
            
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR en Prueba 1: ' || SQLERRM);
            IF v_datos_trabajador%ISOPEN THEN
                CLOSE v_datos_trabajador;
            END IF;
            IF v_datos_cotizaciones%ISOPEN THEN
                CLOSE v_datos_cotizaciones;
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    
    -- ===================================================================================
    -- PRUEBA 2: CERTIFICADO POR MES ESPECÍFICO (Operación tipo 4)
    -- ===================================================================================
    DBMS_OUTPUT.PUT_LINE('PRUEBA 2: Certificado por mes específico (Enero 2025)');
    DBMS_OUTPUT.PUT_LINE('-----------------------------------------------------');
    
    -- Reiniciar contadores
    v_count_trabajador := 0;
    v_count_cotizaciones := 0;
    
    BEGIN
        PRC_SIL_CERTIFICADO_COTIZACIONES(
            p_rut_trabajador => 9430482,      -- RUT del trabajador
            p_cnv_cta => 500,                 -- Código de convenio
            p_sel_operacion => 4,             -- Mes específico
            p_anio => 2025,                   -- Año 2025
            p_mes => 1,                       -- Enero
            p_anio_hasta => 0,                -- No se usa para tipo 4
            p_mes_hasta => 0,                 -- No se usa para tipo 4
            p_imp_ccaf => 0,                  -- Sin filtro CCAF
            p_emp_rut => 81826800,            -- RUT empresa
            p_rut_representante => 12345678,  -- RUT representante
            p_cod_perfil => 'SI',             -- Perfil con acceso completo
            p_datos_trabajador => v_datos_trabajador,
            p_datos_cotizaciones => v_datos_cotizaciones,
            p_resultado => v_resultado,
            p_mensaje => v_mensaje
        );
        
        DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado);
        DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje);
        
        -- Cerrar cursores si están abiertos
        IF v_datos_trabajador%ISOPEN THEN
            CLOSE v_datos_trabajador;
        END IF;
        IF v_datos_cotizaciones%ISOPEN THEN
            CLOSE v_datos_cotizaciones;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR en Prueba 2: ' || SQLERRM);
            IF v_datos_trabajador%ISOPEN THEN
                CLOSE v_datos_trabajador;
            END IF;
            IF v_datos_cotizaciones%ISOPEN THEN
                CLOSE v_datos_cotizaciones;
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    
    -- ===================================================================================
    -- PRUEBA 3: CERTIFICADO CON USUARIO SIN ACCESO (Debería fallar)
    -- ===================================================================================
    DBMS_OUTPUT.PUT_LINE('PRUEBA 3: Usuario sin acceso (debería fallar)');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------');
    
    BEGIN
        PRC_SIL_CERTIFICADO_COTIZACIONES(
            p_rut_trabajador => 9430482,      -- RUT del trabajador
            p_cnv_cta => 500,                 -- Código de convenio
            p_sel_operacion => 1,             -- Año específico
            p_anio => 2025,                   -- Año 2025
            p_mes => 0,                       -- No se usa
            p_anio_hasta => 0,                -- No se usa
            p_mes_hasta => 0,                 -- No se usa
            p_imp_ccaf => 0,                  -- Sin filtro CCAF
            p_emp_rut => 81826800,            -- RUT empresa
            p_rut_representante => 99999999,  -- RUT representante SIN ACCESO
            p_cod_perfil => 'NO',             -- Perfil SIN acceso completo
            p_datos_trabajador => v_datos_trabajador,
            p_datos_cotizaciones => v_datos_cotizaciones,
            p_resultado => v_resultado,
            p_mensaje => v_mensaje
        );
        
        DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado);
        DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje);
        
        IF v_resultado = -1 THEN
            DBMS_OUTPUT.PUT_LINE('✓ Prueba exitosa: El acceso fue correctamente denegado');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ Error: Debería haber denegado el acceso');
        END IF;
        
        -- Cerrar cursores si están abiertos
        IF v_datos_trabajador%ISOPEN THEN
            CLOSE v_datos_trabajador;
        END IF;
        IF v_datos_cotizaciones%ISOPEN THEN
            CLOSE v_datos_cotizaciones;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR en Prueba 3: ' || SQLERRM);
            IF v_datos_trabajador%ISOPEN THEN
                CLOSE v_datos_trabajador;
            END IF;
            IF v_datos_cotizaciones%ISOPEN THEN
                CLOSE v_datos_cotizaciones;
            END IF;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    
    -- ===================================================================================
    -- PRUEBA 4: VALIDACIÓN DE PARÁMETROS INVÁLIDOS
    -- ===================================================================================
    DBMS_OUTPUT.PUT_LINE('PRUEBA 4: Validación de parámetros inválidos');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    
    BEGIN
        PRC_SIL_CERTIFICADO_COTIZACIONES(
            p_rut_trabajador => 9430482,      -- RUT del trabajador
            p_cnv_cta => 500,                 -- Código de convenio
            p_sel_operacion => 4,             -- Mes específico
            p_anio => 2025,                   -- Año 2025
            p_mes => 13,                      -- MES INVÁLIDO (13)
            p_anio_hasta => 0,                -- No se usa
            p_mes_hasta => 0,                 -- No se usa
            p_imp_ccaf => 0,                  -- Sin filtro CCAF
            p_emp_rut => 81826800,            -- RUT empresa
            p_rut_representante => 12345678,  -- RUT representante
            p_cod_perfil => 'SI',             -- Perfil con acceso completo
            p_datos_trabajador => v_datos_trabajador,
            p_datos_cotizaciones => v_datos_cotizaciones,
            p_resultado => v_resultado,
            p_mensaje => v_mensaje
        );
        
        DBMS_OUTPUT.PUT_LINE('Resultado: ' || v_resultado);
        DBMS_OUTPUT.PUT_LINE('Mensaje: ' || v_mensaje);
        
        IF v_resultado = -5 THEN
            DBMS_OUTPUT.PUT_LINE('✓ Prueba exitosa: Mes inválido detectado correctamente');
        ELSE
            DBMS_OUTPUT.PUT_LINE('✗ Error: Debería haber detectado mes inválido');
        END IF;
        
        -- Cerrar cursores si están abiertos
        IF v_datos_trabajador%ISOPEN THEN
            CLOSE v_datos_trabajador;
        END IF;
        IF v_datos_cotizaciones%ISOPEN THEN
            CLOSE v_datos_cotizaciones;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR en Prueba 4: ' || SQLERRM);
            IF v_datos_trabajador%ISOPEN THEN
                CLOSE v_datos_trabajador;
            END IF;
            IF v_datos_cotizaciones%ISOPEN THEN
                CLOSE v_datos_cotizaciones;
            END IF;
    END;
    
    -- ===================================================================================
    -- VERIFICAR LOG DE AUDITORÍA
    -- ===================================================================================
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    DBMS_OUTPUT.PUT_LINE('VERIFICANDO LOG DE AUDITORÍA');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    
    DECLARE
        v_count_log NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count_log
        FROM LOG_CERTIFICADOS_GENERADOS
        WHERE fecha_generacion = TO_CHAR(SYSDATE, 'YYYYMMDD');
        
        DBMS_OUTPUT.PUT_LINE('Registros de auditoría creados hoy: ' || v_count_log);
        
        -- Mostrar últimos 3 registros
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('ÚLTIMOS REGISTROS DE AUDITORÍA:');
        DBMS_OUTPUT.PUT_LINE('--------------------------------');
        
        FOR rec IN (
            SELECT id, rut_trabajador, rut_empresa, convenio, tipo_operacion, 
                   periodo_desde, periodo_hasta, fecha_creacion
            FROM LOG_CERTIFICADOS_GENERADOS
            WHERE fecha_generacion = TO_CHAR(SYSDATE, 'YYYYMMDD')
            ORDER BY id DESC
            FETCH FIRST 3 ROWS ONLY
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('ID: ' || rec.id || 
                               ' | Trabajador: ' || rec.rut_trabajador ||
                               ' | Empresa: ' || rec.rut_empresa ||
                               ' | Tipo Op: ' || rec.tipo_operacion ||
                               ' | Período: ' || rec.periodo_desde || ' - ' || rec.periodo_hasta);
        END LOOP;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error consultando log de auditoría: ' || SQLERRM);
    END;
    
    -- ===================================================================================
    -- RESUMEN FINAL
    -- ===================================================================================
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE PRUEBAS COMPLETADO');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');
    DBMS_OUTPUT.PUT_LINE('Fecha/Hora fin: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('NOTA: Si no hay errores arriba, el procedimiento está funcionando correctamente.');
    DBMS_OUTPUT.PUT_LINE('Si hay datos en los cursores, significa que la migración fue exitosa.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Para usar en tu aplicación, llama al procedimiento con los parámetros reales');
    DBMS_OUTPUT.PUT_LINE('y procesa los cursores p_datos_trabajador y p_datos_cotizaciones.');
    DBMS_OUTPUT.PUT_LINE('===================================================================================');

END;
/