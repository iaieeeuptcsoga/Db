-- ===================================================================================
-- SCRIPT 3: TABLAS Y TRIGGERS
-- ===================================================================================
-- Migración de CertificadoCotPrev_SIL.asp - Estructura de datos
-- Autor: Migración desde ASP VBScript
-- Fecha: 2025-01-07
-- ===================================================================================

-- 1. TABLA DE LOG PARA AUDITORÍA
-- Equivalente a sp_actCertCot_generados del ASP original
CREATE TABLE LOG_CERTIFICADOS_GENERADOS (
    id NUMBER(10) NOT NULL,
    fecha_generacion VARCHAR2(8) NOT NULL,
    rut_trabajador NUMBER(12) NOT NULL,
    rut_empresa NUMBER(12) NOT NULL,
    convenio NUMBER(10) NOT NULL,
    rut_representante NUMBER(12) NOT NULL,
    tipo_operacion NUMBER(2) NOT NULL,
    periodo_desde VARCHAR2(20),
    periodo_hasta VARCHAR2(20),
    fecha_creacion DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT CON_SIL_PK_LOG_CERT PRIMARY KEY (id)
);

-- 2. COMENTARIOS EN LA TABLA
COMMENT ON TABLE LOG_CERTIFICADOS_GENERADOS IS 'Registro de auditoría para certificados de cotizaciones generados';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.id IS 'Identificador único del registro';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.fecha_generacion IS 'Fecha de generación en formato YYYYMMDD';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.rut_trabajador IS 'RUT del trabajador para quien se genera el certificado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.rut_empresa IS 'RUT de la empresa que solicita el certificado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.convenio IS 'Código de convenio utilizado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.rut_representante IS 'RUT del usuario que genera el certificado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.tipo_operacion IS 'Tipo de operación: 1=Año específico, 2=Últimos 12 meses, 4=Mes específico, 5=Rango personalizado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.periodo_desde IS 'Fecha inicial del período consultado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.periodo_hasta IS 'Fecha final del período consultado';
COMMENT ON COLUMN LOG_CERTIFICADOS_GENERADOS.fecha_creacion IS 'Timestamp de creación del registro';

-- 3. ÍNDICES PARA OPTIMIZACIÓN
CREATE INDEX IND_SIL_NX_LOG_CERT_FECHA ON LOG_CERTIFICADOS_GENERADOS (fecha_generacion);
CREATE INDEX IND_SIL_NX_LOG_CERT_TRABAJADOR ON LOG_CERTIFICADOS_GENERADOS (rut_trabajador);
CREATE INDEX IND_SIL_NX_LOG_CERT_EMPRESA ON LOG_CERTIFICADOS_GENERADOS (rut_empresa);
CREATE INDEX IND_SIL_NX_LOG_CERT_USUARIO ON LOG_CERTIFICADOS_GENERADOS (rut_representante);

-- 4. TRIGGER PARA AUTO-INCREMENTO DEL ID
-- Utilizando MAX+1 en lugar de secuencia como se solicita
CREATE OR REPLACE TRIGGER TRG_SIL_LOG_CERT_ID
    BEFORE INSERT ON LOG_CERTIFICADOS_GENERADOS
    FOR EACH ROW
DECLARE
    v_max_id NUMBER;
BEGIN
    IF :NEW.id IS NULL THEN
        SELECT NVL(MAX(id), 0) + 1
        INTO v_max_id
        FROM LOG_CERTIFICADOS_GENERADOS;
        
        :NEW.id := v_max_id;
    END IF;
END TRG_SIL_LOG_CERT_ID;
/