-- =====================================================================================
-- QUERIES PARA PROBAR EL STORED PROCEDURE PRC_CERTCOT_TRAB_PUB2
-- =====================================================================================
-- Estas queries usan SOLO las tablas reales de Oracle definidas en tablasSp2.txt
-- Los parámetros del SP son: p_emp_rut, p_convenio, p_fec_ini, p_fec_ter, p_rut_tra, p_parametro2, p_parametro3
-- =====================================================================================

-- =====================================================================================
-- QUERY 1: DATOS BÁSICOS DE REC_TRAAFP (SIN FILTROS)
-- =====================================================================================
-- Esta query muestra los primeros registros de REC_TRAAFP tal como están

SELECT
    afp.CON_RUT as EMPRESA_RUT,
    afp.CON_CORREL as CONVENIO,
    afp.TRA_RUT as TRABAJADOR_RUT,
    afp.REC_PERIODO as PERIODO,
    afp.SUC_CODIGO as SUCURSAL,
    afp.USU_CODIGO as USUARIO,
    afp.RPR_PROCESO,
    afp.AFP_COT_OBLIGATORIA,
    afp.AFP_COT_VOLUNTARIA
FROM REC_TRAAFP afp
WHERE ROWNUM <= 10 -- Solo 10 registros para ver qué hay
ORDER BY afp.REC_PERIODO DESC;

-- =====================================================================================
-- QUERY 2: DATOS BÁSICOS DE REC_EMPRESA (SIN FILTROS)
-- =====================================================================================
-- Esta query muestra los primeros registros de REC_EMPRESA tal como están

SELECT
    emp.EMP_RUT,
    emp.CON_RUT,
    emp.CON_CORREL,
    emp.REC_PERIODO,
    emp.EMP_RAZSOC,
    emp.RPR_PROCESO
FROM REC_EMPRESA emp
WHERE ROWNUM <= 10 -- Solo 10 registros para ver qué hay
ORDER BY emp.REC_PERIODO DESC;

-- =====================================================================================
-- QUERY 3: GENERAR COMANDO DE TESTING CON DATOS REALES
-- =====================================================================================
-- Esta query genera comandos usando los primeros datos reales que encuentra

SELECT
    'COMANDO LISTO PARA EJECUTAR:' as TIPO,
    'EXEC PRC_CERTCOT_TRAB_PUB2(' ||
    '  p_emp_rut => ' || afp.CON_RUT || ',' ||
    '  p_convenio => ' || afp.CON_CORREL || ',' ||
    '  p_fec_ini => DATE''' || TO_CHAR(afp.REC_PERIODO, 'YYYY-MM-DD') || ''',' ||
    '  p_fec_ter => DATE''' || TO_CHAR(afp.REC_PERIODO, 'YYYY-MM-DD') || ''',' ||
    '  p_rut_tra => ' || afp.TRA_RUT || ',' ||
    '  p_parametro2 => ''' || afp.USU_CODIGO || ''',' ||
    '  p_parametro3 => 1' ||
    ');' as COMANDO_SP,
    'Empresa: ' || afp.CON_RUT || ' | Trabajador: ' || afp.TRA_RUT || ' | Período: ' || TO_CHAR(afp.REC_PERIODO, 'YYYY-MM-DD') as DESCRIPCION
FROM REC_TRAAFP afp
WHERE ROWNUM <= 3 -- Solo 3 ejemplos
ORDER BY afp.REC_PERIODO DESC;

-- =====================================================================================
-- QUERY 4: VERIFICAR QUE HAY DATOS EN LAS TABLAS (UNA POR UNA)
-- =====================================================================================
-- Para verificar que existen datos en las tablas principales

-- Verificar REC_TRAAFP
SELECT 'REC_TRAAFP' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_TRAAFP;

-- Verificar REC_EMPRESA
SELECT 'REC_EMPRESA' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_EMPRESA;

-- Verificar REC_TRAINP
SELECT 'REC_TRAINP' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_TRAINP;

-- Verificar REC_TRAISA
SELECT 'REC_TRAISA' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_TRAISA;

-- Verificar REC_TRACCAF
SELECT 'REC_TRACCAF' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_TRACCAF;

-- =====================================================================================
-- QUERY 5: VERIFICAR ENTIDADES PREVISIONALES (SIMPLE)
-- =====================================================================================
-- Para verificar que existen entidades previsionales

SELECT COUNT(*) as TOTAL_ENTIDADES FROM REC_ENTPREV;

-- Mostrar algunas entidades
SELECT
    ent.ENT_RUT,
    ent.ENT_NOMBRE,
    ent.ENT_TIPO
FROM REC_ENTPREV ent
WHERE ROWNUM <= 5;



-- =====================================================================================
-- INSTRUCCIONES DE USO:
-- =====================================================================================
-- 1. Ejecuta QUERY 4 primero para verificar que hay datos en las tablas
-- 2. Ejecuta QUERY 1 para ver datos de REC_TRAAFP
-- 3. Ejecuta QUERY 2 para ver datos de REC_EMPRESA
-- 4. Ejecuta QUERY 3 para generar comandos del SP con datos reales
-- 5. Ejecuta QUERY 5 para verificar entidades previsionales
--
-- Si alguna query devuelve 0 registros, significa que esa tabla está vacía
-- o que los nombres de las tablas son diferentes en tu entorno.
-- =====================================================================================
