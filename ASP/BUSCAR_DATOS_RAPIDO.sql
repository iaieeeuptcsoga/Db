-- ============================================================================
-- SCRIPT RÁPIDO PARA BUSCAR DATOS VÁLIDOS
-- ============================================================================
-- Descripción: Búsqueda optimizada de datos para prueba del SP
-- Fecha: 2025-07-04
-- ============================================================================

SET SERVEROUTPUT ON SIZE 1000000;

PROMPT ============================================================================
PROMPT BÚSQUEDA RÁPIDA DE DATOS VÁLIDOS
PROMPT ============================================================================

-- 1. Verificar si existen las tablas principales
PROMPT
PROMPT === 1. VERIFICANDO EXISTENCIA DE TABLAS ===
SELECT 'REC_EMPRESA' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_EMPRESA WHERE ROWNUM <= 10;
SELECT 'REC_TRABAJADOR' as TABLA, COUNT(*) as TOTAL_REGISTROS FROM REC_TRABAJADOR WHERE ROWNUM <= 10;

-- 2. Buscar algunos registros de trabajadores (limitado)
PROMPT
PROMPT === 2. MUESTRA DE TRABAJADORES (PRIMEROS 10) ===
SELECT 
    TRA_RUT,
    CON_RUT as EMP_RUT,
    TRA_NOMTRA,
    TRA_APETRA,
    REC_PERIODO
FROM REC_TRABAJADOR 
WHERE ROWNUM <= 10
ORDER BY REC_PERIODO DESC;

-- 3. Buscar empresas específicas (limitado)
PROMPT
PROMPT === 3. MUESTRA DE EMPRESAS (PRIMERAS 5) ===
SELECT 
    EMP_RUT,
    EMP_RAZSOC,
    EMP_ORDEN_IMP
FROM REC_EMPRESA 
WHERE ROWNUM <= 5;

-- 4. Verificar trabajador específico 13613755
PROMPT
PROMPT === 4. VERIFICANDO TRABAJADOR 13613755 ===
SELECT 
    TRA_RUT,
    CON_RUT as EMP_RUT,
    TRA_NOMTRA,
    TRA_APETRA,
    REC_PERIODO
FROM REC_TRABAJADOR 
WHERE TRA_RUT = 13613755
AND ROWNUM <= 5;

-- 5. Buscar cualquier trabajador con datos en 2003 (limitado)
PROMPT
PROMPT === 5. TRABAJADORES CON DATOS EN 2003 (PRIMEROS 5) ===
SELECT 
    TRA_RUT,
    CON_RUT as EMP_RUT,
    TRA_NOMTRA,
    TRA_APETRA,
    REC_PERIODO
FROM REC_TRABAJADOR 
WHERE REC_PERIODO >= TO_DATE('2003-01-01', 'YYYY-MM-DD')
  AND REC_PERIODO <= TO_DATE('2003-12-31', 'YYYY-MM-DD')
  AND ROWNUM <= 5;

-- 6. Buscar datos en otros años (limitado)
PROMPT
PROMPT === 6. DATOS EN OTROS AÑOS (MUESTRA) ===
SELECT 
    EXTRACT(YEAR FROM REC_PERIODO) as ANIO,
    COUNT(*) as REGISTROS_MUESTRA
FROM (
    SELECT REC_PERIODO 
    FROM REC_TRABAJADOR 
    WHERE ROWNUM <= 1000
) 
GROUP BY EXTRACT(YEAR FROM REC_PERIODO)
ORDER BY ANIO DESC;

-- 7. Verificar empresa específica 96758240
PROMPT
PROMPT === 7. VERIFICANDO EMPRESA 96758240 ===
SELECT 
    EMP_RUT,
    EMP_RAZSOC,
    EMP_ORDEN_IMP
FROM REC_EMPRESA 
WHERE EMP_RUT = 96758240;

-- 8. Buscar trabajadores para empresa 96758240 (si existe)
PROMPT
PROMPT === 8. TRABAJADORES PARA EMPRESA 96758240 ===
SELECT 
    TRA_RUT,
    CON_RUT as EMP_RUT,
    TRA_NOMTRA,
    TRA_APETRA,
    REC_PERIODO
FROM REC_TRABAJADOR 
WHERE CON_RUT = 96758240
  AND ROWNUM <= 5;

-- 9. Buscar cualquier combinación válida (muy limitado)
PROMPT
PROMPT === 9. COMBINACIONES VÁLIDAS (MUESTRA PEQUEÑA) ===
SELECT 
    t.TRA_RUT,
    t.CON_RUT as EMP_RUT,
    e.EMP_RAZSOC,
    t.TRA_NOMTRA || ' ' || t.TRA_APETRA as TRABAJADOR,
    t.REC_PERIODO,
    CASE WHEN e.EMP_ORDEN_IMP = 1 THEN 'PÚBLICA' ELSE 'PRIVADA' END as TIPO_EMPRESA
FROM REC_TRABAJADOR t
INNER JOIN REC_EMPRESA e ON t.CON_RUT = e.EMP_RUT
WHERE t.REC_PERIODO >= TO_DATE('2000-01-01', 'YYYY-MM-DD')
  AND ROWNUM <= 10;

PROMPT
PROMPT ============================================================================
PROMPT RECOMENDACIONES BASADAS EN LOS RESULTADOS
PROMPT ============================================================================
PROMPT 
PROMPT 1. Si encuentras datos en las secciones anteriores, usa esos valores
PROMPT 2. Si no hay datos en 2003, prueba con otros años mostrados en sección 6
PROMPT 3. Si la empresa 96758240 no existe, usa una de las empresas de sección 9
PROMPT 4. Si el trabajador 13613755 no existe, usa uno de los trabajadores de sección 9
PROMPT 
PROMPT PASOS SIGUIENTES:
PROMPT - Ejecutar este script primero para ver qué datos están disponibles
PROMPT - Usar los valores encontrados para actualizar el test del SP
PROMPT - Probar con datos reales que existan en la base de datos
PROMPT 
PROMPT ============================================================================
