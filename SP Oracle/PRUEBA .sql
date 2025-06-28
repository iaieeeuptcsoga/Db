-- =====================================================
-- PRUEBA DEL PROCEDIMIENTO MIGRADO
-- =====================================================

-- Declarar variable para el cursor
DECLARE
    v_cursor SYS_REFCURSOR;
    
    -- Variables para leer el cursor
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
    v_tra_nombre VARCHAR2(100);
    v_tra_ape VARCHAR2(100);
    v_dias_trab NUMBER;
    v_rem_impo NUMBER;
    v_monto_cotizado NUMBER;
    v_fec_pago DATE;
    v_folio_planilla NUMBER;
    v_raz_soc VARCHAR2(100);
    v_salud NUMBER;
    v_monto_sis NUMBER;
    
BEGIN
    -- Llamar al procedimiento migrado con los valores de prueba reales
    DBMS_OUTPUT.PUT_LINE('=== EJECUTANDO PROCEDIMIENTO PRC_REC_CERTCOT_TRAB ===');
    DBMS_OUTPUT.PUT_LINE('Parámetros de prueba reales:');
    DBMS_OUTPUT.PUT_LINE('- Fecha inicio: 31-ENE-2009');
    DBMS_OUTPUT.PUT_LINE('- Fecha término: 31-DIC-2009');
    DBMS_OUTPUT.PUT_LINE('- RUT empresa: 84694600');
    DBMS_OUTPUT.PUT_LINE('- Convenio: 1');
    DBMS_OUTPUT.PUT_LINE('- RUT trabajador: 11828995');
    DBMS_OUTPUT.PUT_LINE('- Tipo consulta: 1');
    DBMS_OUTPUT.PUT_LINE('- Parámetro adicional: 0');
    DBMS_OUTPUT.PUT_LINE('');

    PRC_REC_CERTCOT_TRAB(
        p_fec_ini => DATE '2009-01-31',
        p_fec_ter => DATE '2009-12-31',
        p_emp_rut => 84694600,
        p_convenio => 1,
        p_rut_tra => 11828995,
        p_tipoCon => 1,
        p_parametro => NULL,
        p_parametro2 => NULL,
        p_parametro3 => '0',
        p_cursor => v_cursor
    );
    
    DBMS_OUTPUT.PUT_LINE('=== RESULTADOS DEL CERTIFICADO DE COTIZACIONES ===');
    DBMS_OUTPUT.PUT_LINE('PERÍODO | TIPO_ENT | ENTIDAD | TRABAJADOR | DÍAS | REM_IMPONIBLE | COTIZACIÓN | FOLIO');
    DBMS_OUTPUT.PUT_LINE('--------+---------+---------+------------+------+---------------+------------+------');
    
    -- Leer los resultados del cursor
    LOOP
        FETCH v_cursor INTO 
            v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
            v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig, 
            v_tra_nombre, v_tra_ape, v_dias_trab, v_rem_impo, v_monto_cotizado,
            v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis;
            
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            TO_CHAR(v_rec_periodo, 'MM/YYYY') || ' | ' ||
            v_tipo_ent || ' | ' ||
            SUBSTR(v_ent_nombre, 1, 15) || ' | ' ||
            v_tra_rut || ' | ' ||
            LPAD(v_dias_trab, 4) || ' | ' ||
            LPAD(TO_CHAR(v_rem_impo, 'FM999,999,999'), 13) || ' | ' ||
            LPAD(TO_CHAR(v_monto_cotizado, 'FM999,999,999'), 10) || ' | ' ||
            NVL(TO_CHAR(v_folio_planilla), 'N/A')
        );
    END LOOP;
    
    CLOSE v_cursor;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== PRUEBA COMPLETADA EXITOSAMENTE ===');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR EN LA EJECUCIÓN: ' || SQLERRM);
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        RAISE;
END;
/

-- =====================================================
-- CONSULTA ALTERNATIVA SIMPLE (SIN PL/SQL)
-- =====================================================

-- Si el bloque PL/SQL anterior no funciona en tu entorno, 
-- puedes usar esta consulta simple para verificar:

/*
-- Solo llama al procedimiento (sin mostrar resultados)
DECLARE
    v_cursor SYS_REFCURSOR;
BEGIN
    PRC_REC_CERTCOT_TRAB(
        p_fec_ini => DATE '2024-01-01',
        p_fec_ter => DATE '2024-01-31', 
        p_emp_rut => 76123456,
        p_convenio => 1,
        p_rut_tra => 11111111,
        p_tipoCon => 1,
        p_parametro => NULL,
        p_parametro2 => NULL,
        p_parametro3 => NULL,
        p_cursor => v_cursor
    );
    
    CLOSE v_cursor;
    DBMS_OUTPUT.PUT_LINE('Procedimiento ejecutado correctamente');
END;
/
*/

-- =====================================================
-- CONSULTAS DE VERIFICACIÓN ADICIONALES
-- =====================================================

-- Verificar que las tablas temporales se crearon correctamente
SELECT 'Verificando tablas temporales...' AS STATUS FROM DUAL;

-- Verificar trabajadores y sus datos asociados
SELECT 
    t.TRA_RUT,
    t.TRA_APETRA || ' ' || t.TRA_NOMTRA AS NOMBRE_COMPLETO,
    t.TRA_REG_PREVIS AS AFP_COD,
    ep_afp.ENT_NOMBRE AS AFP_NOMBRE,
    t.TRA_REG_SALUD AS SALUD_COD,
    ep_sal.ENT_NOMBRE AS SALUD_NOMBRE
FROM REC_TRABAJADOR t
    LEFT JOIN REC_ENTPREV ep_afp ON t.TRA_REG_PREVIS = ep_afp.ENT_CODIFICACION AND ep_afp.ENT_TIPO = 1
    LEFT JOIN REC_ENTPREV ep_sal ON t.TRA_REG_SALUD = ep_sal.ENT_CODIFICACION AND ep_sal.ENT_TIPO = 2
ORDER BY t.TRA_RUT;

PROMPT 
PROMPT =====================================================
PROMPT SCRIPT DE PRUEBA COMPLETADO
PROMPT =====================================================
PROMPT 
PROMPT Para ejecutar el procedimiento manualmente, usa:
PROMPT 
PROMPT DECLARE
PROMPT     v_cursor SYS_REFCURSOR;
PROMPT BEGIN
PROMP