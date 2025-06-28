-- =====================================================
-- SCRIPT DE DATOS DE PRUEBA PARA CERTIFICADO COTIZACIONES
-- Sistema: REC - Recaudación Oracle
-- =====================================================

-- Limpiar datos existentes (opcional)
/*
DELETE FROM REC_TRACCAF;
DELETE FROM REC_TOTALAPV;
DELETE FROM REC_TOTALSUC;
DELETE FROM REC_TRAISA;
DELETE FROM REC_TRAINP;
DELETE FROM REC_TRAAFP;
DELETE FROM REC_PLANILLA;
DELETE FROM REC_DATOUSU;
DELETE FROM REC_TRABAJADOR;
DELETE FROM REC_SUCURSAL;
DELETE FROM REC_PAGO;
DELETE FROM REC_EMPRESA;
DELETE FROM REC_ENTPREV;
COMMIT;
*/

-- =====================================================
-- 1. ENTIDADES PREVISIONALES
-- =====================================================

-- AFP (Administradoras de Fondos de Pensiones)
INSERT INTO REC_ENTPREV VALUES (
    96572190, '9', 1, 'CAPITAL', 1, DATE '2020-01-01', 1, 1, 1, '12345678901',
    15, 0, NULL, 'ADMIN', DATE '2020-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    1, 100, 'CAPITAL', '001', 1, 1001, 'S', 1001, 'N', 'Gestión de fondos previsionales',
    2, '98765432109', 3, '11111111111', 4, '22222222222', 'Juan Pérez', 'Gerente',
    'S', 'S', 1
);

INSERT INTO REC_ENTPREV VALUES (
    96645850, '1', 1, 'PROVIDA', 1, DATE '2020-01-01', 2, 1, 1, '12345678902',
    15, 0, NULL, 'ADMIN', DATE '2020-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    1, 101, 'PROVIDA', '002', 1, 1002, 'S', 1002, 'N', 'Gestión de fondos previsionales',
    2, '98765432110', 3, '11111111112', 4, '22222222223', 'María García', 'Gerente',
    'S', 'S', 1
);

-- ISAPRES (Instituciones de Salud Previsional)
INSERT INTO REC_ENTPREV VALUES (
    96856780, '2', 2, 'BANMEDICA', 1, DATE '2020-01-01', 1, 1, 1, '12345678903',
    15, 0, NULL, 'ADMIN', DATE '2020-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    1, 201, 'BANMEDICA', '201', 1, 2001, 'S', 2001, 'N', 'Servicios de salud',
    2, '98765432111', 3, '11111111113', 4, '22222222224', 'Carlos López', 'Director',
    'S', 'S', 1
);

-- FONASA
INSERT INTO REC_ENTPREV VALUES (
    61603000, '0', 2, 'FONASA', 1, DATE '2020-01-01', 0, 1, 1, '12345678904',
    15, 0, NULL, 'ADMIN', DATE '2020-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    1, 200, 'FONASA', '200', 1, 2000, 'S', 2000, 'N', 'Fondo Nacional de Salud',
    2, '98765432112', 3, '11111111114', 4, '22222222225', 'Ana Martínez', 'Directora',
    'S', 'S', 1
);

-- CCAF (Cajas de Compensación)
INSERT INTO REC_ENTPREV VALUES (
    70016520, '9', 3, 'LOS ANDES', 1, DATE '2020-01-01', 1, 1, 1, '12345678905',
    15, 0, NULL, 'ADMIN', DATE '2020-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    1, 301, 'LOS ANDES', '301', 1, 3001, 'S', 3001, 'N', 'Compensación familiar',
    2, '98765432113', 3, '11111111115', 4, '22222222226', 'Pedro Rodríguez', 'Gerente',
    'S', 'S', 1
);

-- MUTUALIDADES
INSERT INTO REC_ENTPREV VALUES (
    70360100, '4', 4, 'MUTUAL DE SEGURIDAD', 1, DATE '2020-01-01', 2, 1, 1, '12345678906',
    15, 0, NULL, 'ADMIN', DATE '2020-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    1, 401, 'MUTUAL SEG', '401', 1, 4001, 'S', 4001, 'N', 'Seguridad laboral',
    2, '98765432114', 3, '11111111116', 4, '22222222227', 'Luis González', 'Director',
    'S', 'S', 1
);

-- =====================================================
-- 2. EMPRESA
-- =====================================================

INSERT INTO REC_EMPRESA VALUES (
    DATE '2024-01-01', 76123456, 1, 1, 76123456, '7', 0, 'EMPRESA DE PRUEBA S.A.', 0,
    620200, 0, 'AV. PROVIDENCIA 1234', '1234', 'OF 501', 0, 'PROVIDENCIA', 'SANTIAGO',
    'RM', 0, '223334455', 0, '223334456', 0, '7501234', 'CASILLA 123', 'contacto@empresa.cl',
    'administracion@empresa.cl', 12345678, '9', 'REPRESENTANTE', 'LEGAL', 0, 2, 1234567,
    0.68, 0.95, 1, 0.004, DATE '2024-01-01', DATE '2024-12-31', 1001, DATE '2024-01-01',
    'ADMIN', DATE '2024-01-01', 'ADMIN', 50, 0, 1, 'repleg@empresa.cl', 0, '223334457', 0,
    '223334458', 0, 0, 0, 'CONVENIO EMPRESA', 0, DATE '2024-01-01', DATE '2024-12-31',
    0, 1, 'CLAVE123', 'E1', 'ORGANISMO PÚBLICO', 'SUC001', 'SUCURSAL PRINCIPAL', 1,
    0, 0, 0, 1, 1, 1, 0, 0
);

-- =====================================================
-- 3. SUCURSAL
-- =====================================================

INSERT INTO REC_SUCURSAL VALUES (
    DATE '2024-01-01', 76123456, 1, 1, 'SUC001', 'SUCURSAL PRINCIPAL',
    'AV. PROVIDENCIA 1234', 'PROVIDENCIA', 'SANTIAGO', 'RM', 0, 25, 50000000,
    1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 'USU001',
    1, 2, 1234567, 0.68, 0.95
);

-- =====================================================
-- 4. PAGO
-- =====================================================

INSERT INTO REC_PAGO VALUES (
    DATE '2024-01-01', 1001, '7', 76123456, 1, 1, 25, 1500000, 3000000, 500000,
    800000, 200000, 6000000, 1, 5, DATE '2024-01-15', DATE '2024-01-20', 'CAJ001',
    001, 1234567890, 'RM', 'S001', DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN',
    '1', 12345, 800000, 200000, 100, 'EMPRESA DE PRUEBA S.A.', 'AV. PROVIDENCIA 1234',
    '1234', 'OF 501', 'PROVIDENCIA', 'SANTIAGO', 'RM', '223334455', 12345678, '9',
    'REPRESENTANTE', 'LEGAL', 'DIGEST123', 1, 'N', DATE '2024-01-20', 'N', NULL, 100000,
    'N', NULL, 'N', NULL, 0, 'N', NULL, 1001, 'EXT001', 'N', 0, 'N', NULL, 0, 1, 100,
    '01', 'N', NULL, 'N', NULL, 1, 'V1.0'
);

-- =====================================================
-- 5. DATO USUARIO
-- =====================================================

INSERT INTO REC_DATOUSU VALUES (
    DATE '2024-01-01', 76123456, 1, 1, 'USU001', 'USUARIO PRINCIPAL', 1001,
    DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 'N',
    DATE '2024-01-01', DATE '2024-01-31'
);

-- =====================================================
-- 6. TRABAJADORES
-- =====================================================

-- Trabajador 1 - AFP CAPITAL
INSERT INTO REC_TRABAJADOR VALUES (
    DATE '2024-01-01', 76123456, 1, 1, 'SUC001', 11111111, '1', 'EMP001',
    'GONZÁLEZ PÉREZ', 'JUAN CARLOS', 1, 1, 0, 0, 0, 0, 0, 1, 150000, 1, 1500000,
    30, 1200000, 50000, 250000, DATE '2024-01-01', DATE '2024-01-31', 10.0, 1001,
    DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 0, 0, 'GONZÁLEZ', 'PÉREZ',
    'USU001', 'EMPRESA DE PRUEBA S.A.', 1, 50000, DATE '2024-01-01', DATE '2024-01-31',
    76123456, '7', 1500000, 50000, 200000, 1400000, 1, 0, 150000, 150000, 150000,
    1, 0, 0, 1, 1, 1, 1, 2, 0, 'CL', 'CHILENA', 0, 0, 'P', 0, '0', 'APELLIDO EMP',
    'NOMBRE EMP', 'CONTRATO001', '01', 'APE PAT EMP', 'APE MAT EMP', '01', 1400000,
    1, DATE '1985-01-15', 0, 1, 1, 0, 1, 'R', 12, 1400000, 100000, 0
);

-- Trabajador 2 - AFP PROVIDA
INSERT INTO REC_TRABAJADOR VALUES (
    DATE '2024-01-01', 76123456, 1, 1, 'SUC001', 22222222, '2', 'EMP002',
    'MARTÍNEZ LÓPEZ', 'MARÍA ELENA', 0, 2, 0, 0, 2, 0, 2, 2, 200000, 2, 2000000,
    30, 1600000, 80000, 320000, DATE '2024-01-01', DATE '2024-01-31', 10.0, 1001,
    DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 0, 0, 'MARTÍNEZ', 'LÓPEZ',
    'USU001', 'EMPRESA DE PRUEBA S.A.', 1, 66667, DATE '2024-01-01', DATE '2024-01-31',
    76123456, '7', 2000000, 66667, 250000, 1900000, 1, 0, 200000, 200000, 200000,
    2, 0, 0, 2, 2, 2, 1, 2, 0, 'CL', 'CHILENA', 0, 0, 'P', 0, '0', 'APELLIDO EMP2',
    'NOMBRE EMP2', 'CONTRATO002', '01', 'APE PAT EMP2', 'APE MAT EMP2', '01', 1900000,
    1, DATE '1990-03-20', 0, 2, 2, 0, 2, 'R', 12, 1900000, 100000, 0
);

-- =====================================================
-- 7. TRABAJADOR AFP
-- =====================================================

-- Datos AFP para Trabajador 1
INSERT INTO REC_TRAAFP VALUES (
    DATE '2024-01-01', 96572190, 76123456, 1, 'SUC001', 11111111, 1, 140000, 50000,
    25000, 200000, 1, 3.5, 0, 0, NULL, NULL, 1001, DATE '2024-01-01', 'ADMIN',
    DATE '2024-01-01', 'ADMIN', 140000, 'USU001', 0.0, 0, 'TRABAJO NORMAL', 0, 0,
    30000, 140000, 0.0, 0, 0.0, 0, 0, 0, '01', 0, 2000, 14000
);

-- Datos AFP para Trabajador 2
INSERT INTO REC_TRAAFP VALUES (
    DATE '2024-01-01', 96645850, 76123456, 1, 'SUC001', 22222222, 1, 190000, 75000,
    35000, 250000, 2, 3.5, 0, 0, NULL, NULL, 1001, DATE '2024-01-01', 'ADMIN',
    DATE '2024-01-01', 'ADMIN', 190000, 'USU001', 0.0, 0, 'TRABAJO NORMAL', 0, 0,
    40000, 190000, 0.0, 0, 0.0, 0, 0, 0, '01', 0, 3000, 19000
);

-- =====================================================
-- 8. TRABAJADOR INP
-- =====================================================

INSERT INTO REC_TRAINP VALUES (
    DATE '2024-01-01', 61603000, 76123456, 1, 'SUC001', 11111111, 1, 50000, 0, 0,
    1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 105000, 140000,
    15000, 0, 0, 0, 50000, 0, 190000, 245000, 0, 'USU001', 0, 0, 0, 0, 10.0
);

INSERT INTO REC_TRAINP VALUES (
    DATE '2024-01-01', 61603000, 76123456, 1, 'SUC001', 22222222, 1, 70000, 0, 0,
    1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 140000, 190000,
    20000, 0, 0, 0, 70000, 0, 260000, 330000, 0, 'USU001', 0, 0, 0, 0, 10.0
);

-- =====================================================
-- 9. TRABAJADOR ISAPRE
-- =====================================================

INSERT INTO REC_TRAISA VALUES (
    DATE '2024-01-01', 96856780, 76123456, 1, 'SUC001', 11111111, 1, 105000,
    7.0, 0, 0, 0, 105000, 1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01',
    'ADMIN', 0.0, 'USU001'
);

INSERT INTO REC_TRAISA VALUES (
    DATE '2024-01-01', 96856780, 76123456, 1, 'SUC001', 22222222, 1, 140000,
    7.0, 0, 0, 0, 140000, 1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01',
    'ADMIN', 0.0, 'USU001'
);

-- =====================================================
-- 10. TRABAJADOR CCAF
-- =====================================================

INSERT INTO REC_TRACCAF VALUES (
    DATE '2024-01-01', 70016520, 76123456, 1, 'SUC001', 11111111, 1, 25000, 0,
    15000, 5000, 10000, 0, 0, 1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01',
    'ADMIN', 8400, 0, 'USU001', 0, 0, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, NULL,
    NULL, 0, 0, 0.0, 0, 0, 0, 0, 0
);

INSERT INTO REC_TRACCAF VALUES (
    DATE '2024-01-01', 70016520, 76123456, 1, 'SUC001', 22222222, 1, 35000, 0,
    20000, 8000, 15000, 0, 0, 1001, DATE '2024-01-01', 'ADMIN', DATE '2024-01-01',
    'ADMIN', 11200, 0, 'USU001', 0, 0, 0, 0, NULL, NULL, 0, 0, 0, 0, 0, 0, NULL,
    NULL, 0, 0, 0.0, 0, 0, 0, 0, 0
);

-- =====================================================
-- 11. TOTAL SUCURSAL
-- =====================================================

INSERT INTO REC_TOTALSUC VALUES (
    DATE '2024-01-01', 76123456, 1, 1, 25, 50000000, 6000000, 1001,
    DATE '2024-01-01', 'ADMIN', DATE '2024-01-01', 'ADMIN', 'SUC001', 'USU001',
    70360100, 1234567, 0.68, 0.95
);

-- =====================================================
-- 12. TOTAL APV
-- =====================================================

INSERT INTO REC_TOTALAPV VALUES (
    DATE '2024-01-01', 76123456, 1, 3, 96572190, 'SUC001', 'USU001', 1001,
    3500000, 125000, 200000, 50000, 1, 1, 2, DATE '2024-01-01', 'ADMIN',
    DATE '2024-01-01', 'ADMIN', 0, 0, 0
);

-- =====================================================
-- 13. PLANILLAS
-- =====================================================

-- Planilla AFP CAPITAL
INSERT INTO REC_PLANILLA VALUES (
    DATE '2024-01-01', 1001, 96572190, 2024010001, DATE '2024-01-01', 'ADMIN',
    DATE '2024-01-01', 'ADMIN', 'SUC001', 'USU001', 25, 3000000, 0, 0, 25, 1, 0,
    1, 1, 25, 0, 0, 0, 3000000, DATE '2024-01-20', 1, 'S001', 100, 'PAGAD', 0,
    'PAGAD', 0, 0, 'S'
);

-- Planilla FONASA
INSERT INTO REC_PLANILLA VALUES (
    DATE '2024-01-01', 1001, 61603000, 2024010002, DATE '2024-01-01', 'ADMIN',
    DATE '2024-01-01', 'ADMIN', 'SUC001', 'USU001', 25, 800000, 1, 0, 25, 1, 0,
    2, 2, 25, 0, 0, 0, 800000, DATE '2024-01-20', 2, 'S001', 101, 'PAGAD', 0,
    'PAGAD', 0, 0, 'S'
);

-- Planilla ISAPRE
INSERT INTO REC_PLANILLA VALUES (
    DATE '2024-01-01', 1001, 96856780, 2024010003, DATE '2024-01-01', 'ADMIN',
    DATE '2024-01-01', 'ADMIN', 'SUC001', 'USU001', 2, 245000, 0, 0, 2, 1, 0,
    1, 1, 2, 0, 0, 0, 245000, DATE '2024-01-20', 3, 'S001', 102, 'PAGAD', 0,
    'PAGAD', 0, 0, 'S'
);

-- =====================================================
-- COMMIT DE TODAS LAS TRANSACCIONES
-- =====================================================

COMMIT;

-- =====================================================
-- VERIFICACIÓN DE DATOS INSERTADOS
-- =====================================================

SELECT 'ENTIDADES PREVISIONALES' AS TABLA, COUNT(*) AS REGISTROS FROM REC_ENTPREV
UNION ALL
SELECT 'EMPRESAS', COUNT(*) FROM REC_EMPRESA
UNION ALL
SELECT 'SUCURSALES', COUNT(*) FROM REC_SUCURSAL
UNION ALL
SELECT 'PAGOS', COUNT(*) FROM REC_PAGO
UNION ALL
SELECT 'TRABAJADORES', COUNT(*) FROM REC_TRABAJADOR
UNION ALL
SELECT 'TRABAJADOR AFP', COUNT(*) FROM REC_TRAAFP
UNION ALL
SELECT 'TRABAJADOR INP', COUNT(*) FROM REC_TRAINP
UNION ALL
SELECT 'TRABAJADOR ISAPRE', COUNT(*) FROM REC_TRAISA
UNION ALL
SELECT 'TRABAJADOR CCAF', COUNT(*) FROM REC_TRACCAF
UNION ALL
SELECT 'PLANILLAS', COUNT(*) FROM REC_PLANILLA;