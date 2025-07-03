# Estructura de Respuesta - PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV

## Resumen
Este documento define la estructura de respuesta del stored procedure Oracle `PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV`, que es la migración del ASP `CertificadoCotPrev.asp` a Oracle PL/SQL siguiendo las normativas de nomenclatura Oracle del proyecto.

## Parámetros de Salida del Stored Procedure

### 1. **p_cursor (SYS_REFCURSOR)**
Cursor principal que contiene los datos del certificado de cotizaciones.

#### Estructura del Cursor:
```sql
SELECT 
    REC_PERIODO,           -- DATE: Período de la cotización
    NRO_COMPROBANTE,       -- NUMBER(7,0): Número de comprobante
    TIPO_IMPRE,            -- NUMBER(1,0): Tipo de impresión
    SUC_COD,               -- VARCHAR2(6): Código de sucursal
    USU_COD,               -- VARCHAR2(6): Código de usuario
    TIPO_ENT,              -- VARCHAR2(1): Tipo de entidad (A=AFP, B=ISAPRE, C=CCAF, etc.)
    ENT_RUT,               -- NUMBER(9,0): RUT de la entidad previsional
    ENT_NOMBRE,            -- VARCHAR2(255): Nombre de la entidad previsional
    TRA_RUT,               -- NUMBER(9,0): RUT del trabajador
    TRA_DIG,               -- VARCHAR2(1): Dígito verificador del trabajador
    TRA_NOMBRE,            -- VARCHAR2(40): Nombre del trabajador
    TRA_APE,               -- VARCHAR2(40): Apellido del trabajador
    DIAS_TRAB,             -- NUMBER(5,0): Días trabajados
    REM_IMPO,              -- NUMBER(8,0): Remuneración imponible
    MONTO_COTIZADO,        -- NUMBER(8,0): Monto cotizado
    FEC_PAGO,              -- DATE: Fecha de pago
    FOLIO_PLANILLA,        -- NUMBER(10,0): Número de folio de planilla
    RAZ_SOC,               -- VARCHAR2(40): Razón social de la empresa
    SALUD,                 -- NUMBER(2,0): Código de salud
    MONTO_SIS,             -- NUMBER(8,0): Monto del Seguro de Invalidez y Sobrevivencia
    USU_PAGO_RETROACTIVO   -- VARCHAR2(1): Indicador de pago retroactivo (solo empresas públicas)
FROM GTT_REC_CERT_DETALLE[_PUB]
ORDER BY REC_PERIODO, SUC_COD, USU_COD, TIPO_ENT;
```

### 2. **p_num_registros (NUMBER)**
- **Descripción**: Número total de registros encontrados en el certificado
- **Equivalente ASP**: Variable `nRegx`
- **Uso**: Para control de paginación y validación de datos

### 3. **p_num_paginas (NUMBER)**
- **Descripción**: Número estimado de páginas del certificado PDF
- **Equivalente ASP**: Variable `numPag`
- **Cálculo**: `CEIL(p_num_registros / 30)` (30 registros por página)
- **Uso**: Para generación de numeración de páginas en el PDF

### 4. **p_es_empresa_pub (VARCHAR2)**
- **Descripción**: Indicador si la empresa es pública
- **Valores**: 'S' = Empresa pública, 'N' = Empresa privada
- **Equivalente ASP**: Variable `bEsEmpresaPublica`
- **Uso**: Determina el formato del certificado y columnas adicionales

### 5. **p_periodo_desde (DATE)**
- **Descripción**: Fecha de inicio del período consultado
- **Equivalente ASP**: Variable `Per_Desde`
- **Formato**: DATE de Oracle
- **Uso**: Para mostrar el rango de fechas en el encabezado del certificado

### 6. **p_periodo_hasta (DATE)**
- **Descripción**: Fecha de término del período consultado
- **Equivalente ASP**: Variable `Per_Hasta`
- **Formato**: DATE de Oracle
- **Uso**: Para mostrar el rango de fechas en el encabezado del certificado

### 7. **p_mensaje_error (VARCHAR2)**
- **Descripción**: Mensaje de error descriptivo si ocurre algún problema
- **Valores**: 
  - `NULL` = Sin errores
  - Texto descriptivo del error
- **Ejemplos**:
  - "La persona no está asociada a la empresa en el período consultado"
  - "Tipo de operación no válido. Valores permitidos: 1, 2, 4, 5"
  - "No se pudieron determinar los períodos de consulta"

### 8. **p_codigo_retorno (NUMBER)**
- **Descripción**: Código de estado de la ejecución
- **Valores**:
  - `0` = Ejecución exitosa
  - `-1` = Error en la ejecución
- **Uso**: Para control de flujo en la aplicación cliente

## Estructura de Datos del Cursor Principal

### Campos Principales (Equivalentes al ASP original)

| Campo ASP Original | Campo Oracle | Tipo | Descripción |
|-------------------|--------------|------|-------------|
| `rec_periodo` | `REC_PERIODO` | DATE | Período de cotización |
| `ENT_NOMBRE` | `ENT_NOMBRE` | VARCHAR2(255) | Institución de previsión |
| `DIAS_TRAB` | `DIAS_TRAB` | NUMBER(5,0) | Días trabajados |
| `REM_IMPO` | `REM_IMPO` | NUMBER(8,0) | Remuneración imponible |
| `monto_COTizado` | `MONTO_COTIZADO` | NUMBER(8,0) | Monto cotizado |
| `monto_sis` | `MONTO_SIS` | NUMBER(8,0) | Monto S.I.S. |
| `FEC_PAGo` | `FEC_PAGO` | DATE | Fecha de pago |
| `folio_planilla` | `FOLIO_PLANILLA` | NUMBER(10,0) | N° folio planilla |
| `RAZ_SOC` | `RAZ_SOC` | VARCHAR2(40) | Empleador |
| `salud` | `SALUD` | NUMBER(2,0) | Código salud |

### Campos Adicionales para Empresas Públicas

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `USU_PAGO_RETROACTIVO` | VARCHAR2(1) | Indicador pago retroactivo |
| `USU_COD` | VARCHAR2(6) | Código para mes retroactivo |

## Tipos de Entidades (TIPO_ENT)

| Código | Descripción | Equivalente ASP |
|--------|-------------|-----------------|
| A | AFP | Administradora de Fondos de Pensiones |
| B | ISAPRE | Institución de Salud Previsional |
| C | CCAF | Caja de Compensación de Asignación Familiar |
| D | INP | Instituto de Normalización Previsional |
| E | APV | Ahorro Previsional Voluntario |
| F | MUTUAL | Mutual de Seguridad |

## Manejo de Casos Especiales

### 1. **Instituciones con Cambio de Nombre**
- **Santa María**: Para períodos anteriores a abril 2008
- **Vida Corp**: Para períodos anteriores a fecha Confuturo
- **Isapres extintas**: Vida Plena y Cigna Salud (período 11-2003)

### 2. **Empresas Públicas**
- Incluye columna adicional "Mes Retro"
- Manejo especial de pagos retroactivos
- Formato diferente en el certificado

### 3. **Validaciones**
- Relación trabajador-empresa
- Períodos válidos
- Existencia de datos

## Ejemplo de Uso desde Aplicación Cliente

```sql
DECLARE
    v_cursor        SYS_REFCURSOR;
    v_num_reg       NUMBER;
    v_num_pag       NUMBER;
    v_es_pub        VARCHAR2(1);
    v_desde         DATE;
    v_hasta         DATE;
    v_error         VARCHAR2(4000);
    v_codigo        NUMBER;
BEGIN
    PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV(
        p_rut_tra => 12345678,
        p_emp_rut => 87654321,
        p_cnv_cta => 1,
        p_sel_op => 1,
        p_anio => 2024,
        p_cursor => v_cursor,
        p_num_registros => v_num_reg,
        p_num_paginas => v_num_pag,
        p_es_empresa_pub => v_es_pub,
        p_periodo_desde => v_desde,
        p_periodo_hasta => v_hasta,
        p_mensaje_error => v_error,
        p_codigo_retorno => v_codigo
    );

    IF v_codigo = 0 THEN
        -- Procesar cursor con datos del certificado
        -- Generar PDF con v_num_pag páginas
        -- Usar formato según v_es_pub
    ELSE
        -- Manejar error: v_error
    END IF;
END;
```

## Estado Actual de la Migración

### **Migración Parcial Implementada**
Esta versión del stored procedure incluye **únicamente la migración de la sección de inicialización** del ASP original:

- ✅ **Encabezado y comentarios** con historial de modificaciones
- ✅ **Declaración de variables** equivalentes al ASP
- ✅ **Funciones auxiliares**: `ultimo_dia_mes`, `es_empresa_publica`, `determinar_ultimos_12_meses`
- ✅ **Lógica de determinación de períodos** según tipo de operación
- ✅ **Validaciones básicas** de empresa pública y relación trabajador-empresa
- ✅ **Estructura de respuesta completa** con todos los parámetros

### **Pendiente de Migración**
- ⏳ **Llamadas a procedimientos** de datos (SQL_TRA_DET, SQL_TRA_DET_PUB)
- ⏳ **Lógica de generación PDF** (objDoc, objPage)
- ⏳ **Procesamiento de datos** y paginación
- ⏳ **Contabilización** de certificados generados

### **Respuesta Actual**
Por ahora, el procedimiento retorna:
- **Cursor vacío** con estructura correcta de columnas
- **Parámetros de salida** con valores por defecto
- **Código de retorno 0** (éxito) para validaciones básicas
- **Mensajes de error** descriptivos cuando aplica

## Diferencias con el ASP Original

### **Ventajas de la Migración Oracle**
1. **Mejor Performance**: Uso de procedimientos almacenados optimizados
2. **Transaccionalidad**: Control de transacciones nativo
3. **Escalabilidad**: Mejor manejo de grandes volúmenes
4. **Mantenibilidad**: Lógica centralizada en base de datos
5. **Seguridad**: Validaciones a nivel de base de datos

### **Funcionalidades Mantenidas**
1. **Todos los tipos de consulta** (año, últimos 12 meses, mes, rango)
2. **Diferenciación empresa pública/privada**
3. **Manejo de instituciones especiales**
4. **Contabilización de certificados generados**
5. **Validaciones de seguridad**

### **Nuevas Capacidades**
1. **Mejor manejo de errores** con códigos y mensajes descriptivos
2. **Información estadística** (número de registros y páginas)
3. **Flexibilidad de parámetros** con valores por defecto
4. **Optimización de consultas** con tablas temporales GTT

## Consideraciones de Implementación

1. **Tablas GTT**: Deben estar creadas antes de ejecutar el procedimiento
2. **Permisos**: El usuario debe tener permisos sobre las tablas base
3. **Memoria**: Las tablas GTT se limpian automáticamente al finalizar la sesión
4. **Concurrencia**: Cada sesión tiene su propia instancia de tablas GTT
5. **Monitoreo**: Implementar logs para seguimiento de ejecución
