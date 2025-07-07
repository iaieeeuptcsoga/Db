-- ===================================================================================
-- FUNCIONES PL/SQL CORREGIDAS
-- ===================================================================================

-- FUNCIÓN 1: ÚLTIMO DÍA DEL MES
CREATE OR REPLACE FUNCTION FNC_SIL_ULTIMO_DIA_MES(
    p_mes IN NUMBER,
    p_anio IN NUMBER
) 
RETURN NUMBER
IS
    v_fecha DATE;
    v_ultimo_dia NUMBER(2);
BEGIN
    -- Crear fecha del primer día del mes
    v_fecha := TO_DATE(p_anio || '-' || LPAD(p_mes, 2, '0') || '-01', 'YYYY-MM-DD');
    
    -- Obtener el último día del mes
    v_ultimo_dia := TO_NUMBER(TO_CHAR(LAST_DAY(v_fecha), 'DD'));
    
    RETURN v_ultimo_dia;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 31; -- Valor por defecto
END FNC_SIL_ULTIMO_DIA_MES;
/

-- FUNCIÓN 2: VALIDAR ACCESO SUCURSAL (CON MANEJO DE TABLA INEXISTENTE)
CREATE OR REPLACE FUNCTION FNC_SIL_VALIDA_ACCESO_SUCURSAL(
    p_emp_rut IN NUMBER,
    p_convenio IN NUMBER,
    p_rut_representante IN NUMBER,
    p_cod_perfil IN VARCHAR2
) 
RETURN NUMBER
IS
    v_count NUMBER(10);
BEGIN
    -- Si el usuario tiene perfil especial "SI", tiene acceso completo
    IF p_cod_perfil = 'SI' THEN
        RETURN 1;
    END IF;
    
    v_count := 0;
    
    BEGIN
        -- Verificar si el representante tiene acceso a esta empresa/convenio
        -- Usando la tabla REC_TRACCAF con las columnas correctas
        SELECT COUNT(*)
        INTO v_count
        FROM REC_TRACCAF
        WHERE CON_RUT = p_emp_rut
          AND CON_CORREL = p_convenio
          AND TRA_RUT = p_rut_representante;
          
    EXCEPTION
        WHEN OTHERS THEN
            v_count := 0;
    END;
    
    IF v_count > 0 THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END FNC_SIL_VALIDA_ACCESO_SUCURSAL;
/

-- FUNCIÓN 3: FORMATEAR FECHAS
CREATE OR REPLACE FUNCTION FNC_SIL_FORMAT_FECHA(
    p_fecha IN DATE
) 
RETURN VARCHAR2
IS
BEGIN
    IF p_fecha IS NULL THEN
        RETURN '';
    END IF;
    
    RETURN TO_CHAR(p_fecha, 'DD/MM/YYYY');
EXCEPTION
    WHEN OTHERS THEN
        RETURN '';
END FNC_SIL_FORMAT_FECHA;
/

-- FUNCIÓN 4: NOMBRE DEL MES
CREATE OR REPLACE FUNCTION FNC_SIL_NOMBRE_MES(
    p_mes IN NUMBER,
    p_anio IN NUMBER
) 
RETURN VARCHAR2
IS
    v_fecha DATE;
    v_nombre_mes VARCHAR2(50);
BEGIN
    -- Validar parámetros
    IF p_mes IS NULL OR p_anio IS NULL OR p_mes < 1 OR p_mes > 12 THEN
        RETURN 'Mes Inválido';
    END IF;
    
    v_fecha := TO_DATE(p_anio || '-' || LPAD(p_mes, 2, '0') || '-01', 'YYYY-MM-DD');
    
    -- Obtener nombre del mes en español
    SELECT CASE p_mes
               WHEN 1 THEN 'Enero'
               WHEN 2 THEN 'Febrero'
               WHEN 3 THEN 'Marzo'
               WHEN 4 THEN 'Abril'
               WHEN 5 THEN 'Mayo'
               WHEN 6 THEN 'Junio'
               WHEN 7 THEN 'Julio'
               WHEN 8 THEN 'Agosto'
               WHEN 9 THEN 'Septiembre'
               WHEN 10 THEN 'Octubre'
               WHEN 11 THEN 'Noviembre'
               WHEN 12 THEN 'Diciembre'
               ELSE 'Mes Inválido'
           END || ' ' || TO_CHAR(p_anio)
    INTO v_nombre_mes
    FROM DUAL;
    
    RETURN v_nombre_mes;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error en Fecha';
END FNC_SIL_NOMBRE_MES;
/