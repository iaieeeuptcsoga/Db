-- =====================================================
-- MODIFICACIÓN DE TABLAS TEMPORALES EXISTENTES
-- Sistema: REC - Recaudación
-- Autor: Migración SQL Server a Oracle
-- Fecha: $(date)
-- =====================================================

-- Modificar tabla GTT_REC_VIR_TRA
-- Aumentar tamaño de campos de texto para evitar errores ORA-12899

PROMPT 'Modificando tabla GTT_REC_VIR_TRA...'

ALTER TABLE GTT_REC_VIR_TRA MODIFY (
    TRA_NOMBRE VARCHAR2(100),
    TRA_APE VARCHAR2(100),
    RAZ_SOC VARCHAR2(100)
);

PROMPT 'Tabla GTT_REC_VIR_TRA modificada exitosamente.'

-- Modificar tabla GTT_REC_VIR_TRA2
-- Aumentar tamaño de campos de texto para evitar errores ORA-12899

PROMPT 'Modificando tabla GTT_REC_VIR_TRA2...'

ALTER TABLE GTT_REC_VIR_TRA2 MODIFY (
    TRA_NOMBRE VARCHAR2(100),
    TRA_APE VARCHAR2(100),
    RAZ_SOC VARCHAR2(100)
);

PROMPT 'Tabla GTT_REC_VIR_TRA2 modificada exitosamente.'

-- Modificar tabla GTT_REC_CERT_DETALLE
-- Aumentar tamaño de campos de texto para evitar errores ORA-12899

PROMPT 'Modificando tabla GTT_REC_CERT_DETALLE...'

ALTER TABLE GTT_REC_CERT_DETALLE MODIFY (
    TRA_NOMBRE VARCHAR2(100),
    TRA_APE VARCHAR2(100),
    RAZ_SOC VARCHAR2(100)
);

PROMPT 'Tabla GTT_REC_CERT_DETALLE modificada exitosamente.'

PROMPT 'Todas las modificaciones completadas exitosamente.'
PROMPT 'Los campos TRA_NOMBRE, TRA_APE y RAZ_SOC ahora soportan hasta 100 caracteres.'

-- Verificar las modificaciones
PROMPT 'Verificando las modificaciones...'

SELECT 
    table_name,
    column_name,
    data_type,
    data_length
FROM user_tab_columns 
WHERE table_name IN ('GTT_REC_VIR_TRA', 'GTT_REC_VIR_TRA2', 'GTT_REC_CERT_DETALLE')
  AND column_name IN ('TRA_NOMBRE', 'TRA_APE', 'RAZ_SOC')
ORDER BY table_name, column_name;

PROMPT 'Script de modificación completado.'
