# Documentación - CertificadoCotPrev.asp

## Información General

**Archivo:** `ASP/CertificadoCotPrev.asp`  
**Versión:** 2.0  
**Fecha de Creación:** 10-11-2005  
**Desarrollador:** IPA  
**Última Modificación:** 24-11-2011  

## Propósito

Este archivo ASP es responsable de generar **Certificados de Cotizaciones Previsionales** en formato PDF. El sistema permite crear documentos oficiales que certifican las cotizaciones realizadas por trabajadores a instituciones previsionales (AFP, INP, ISAPRES, etc.) durante períodos específicos.

## Funcionalidad Principal

### ¿Qué hace?

1. **Genera certificados PDF** con información detallada de cotizaciones previsionales
2. **Valida la relación** trabajador-empresa antes de generar el certificado
3. **Maneja diferentes tipos de empresas** (públicas y privadas) con formatos específicos
4. **Soporta múltiples períodos** de consulta (año específico, últimos 12 meses, mes específico, rango de períodos)
5. **Incluye información completa** de cotizaciones: institución, período, días trabajados, remuneración, montos cotizados, etc.

### ¿Cómo lo hace?

#### 1. **Recepción de Parámetros**
- **RUT del trabajador** (`rutTra`)
- **RUT de la empresa** (`EmpRut`)
- **Código de convenio** (`cnvCta`)
- **Tipo de consulta** (`selOp`): 1=Año específico, 2=Últimos 12 meses, 4=Mes específico, 5=Rango de períodos
- **Año y mes** de consulta
- **Parámetros adicionales** como impresión de CCAF

#### 2. **Validación y Conexión**
- Establece conexión con base de datos SQL Server
- Valida que el trabajador esté asociado a la empresa
- Determina si es empresa pública o privada

#### 3. **Consulta de Datos**
- Ejecuta procedimientos almacenados para obtener información de cotizaciones:
  - `sp_CertCot_trab` para empresas privadas
  - `SQL_TRA_DET_PUB` para empresas públicas
- Recupera datos de períodos, instituciones, montos, fechas de pago, etc.

#### 4. **Generación del PDF**
- Utiliza el objeto `DPDF_Gen.Document` para crear el documento PDF
- Genera encabezados con información del trabajador y empresa
- Crea tablas con datos de cotizaciones organizados por período
- Aplica formato específico según tipo de empresa

#### 5. **Características Especiales**

##### **Empresas Públicas**
- Formato diferente con columna adicional "Mes Retro"
- Manejo especial de pagos retroactivos
- Validación específica basada en `EMP_TIPO_GRATIF = 2` y `EMP_ORDEN_INP = 4`

##### **Manejo de Instituciones Especiales**
- **Santa María**: Cambio de nombre para períodos anteriores a abril 2008
- **Vida Corp**: Cambio de nombre para períodos anteriores a fecha específica (Confuturo)
- **Isapres extintas**: Manejo especial para Vida Plena y Cigna Salud (período 11-2003)

##### **Paginación Inteligente**
- Control automático de salto de página
- Numeración de páginas
- Encabezados repetidos en cada página

## Estructura del Documento PDF

### **Encabezado**
- Información del trabajador (nombre, RUT)
- Información de la empresa (razón social, RUT)
- Período consultado
- Fecha de emisión

### **Tabla de Cotizaciones**
| Columna | Descripción |
|---------|-------------|
| Institución de Previsión | AFP, INP, ISAPRE, etc. |
| Mes y Año | Período de la cotización |
| Días Trabajados | Días laborados en el período |
| Remuneración Imponible | Monto base para cotización |
| Monto Cotizado | Valor cotizado |
| Monto S.I.S. | Seguro de Invalidez y Sobrevivencia |
| Fecha de Pago | Fecha de pago de la cotización |
| N° Folio Planilla | Número de planilla |
| Empleador | Razón social del empleador |
| Mes Retro* | Solo para empresas públicas |

*Solo visible en empresas públicas con pagos retroactivos

### **Pie de Página**
- Validez jurídica del certificado
- Referencia legal (Art. 31 del D.F.L. N° 2, de 1967)
- Numeración de páginas

## Parámetros de Entrada

| Parámetro | Tipo | Descripción | Valores |
|-----------|------|-------------|---------|
| `rutTra` | String | RUT del trabajador | Formato: 12345678-9 |
| `EmpRut` | String | RUT de la empresa | Formato: 12345678-9 |
| `cnvCta` | String | Código de convenio | Numérico |
| `selOp` | Integer | Tipo de consulta | 1,2,4,5 |
| `anio` | String | Año de consulta | YYYY |
| `mes` | String | Mes de consulta | MM |
| `anioHasta` | String | Año hasta (rango) | YYYY |
| `mesHasta` | String | Mes hasta (rango) | MM |
| `impCCAF` | String | Imprimir conceptos CCAF | S/N |

## Funciones Auxiliares

### **UltimoDiaDeMes(iMonth, iYear)**
- Calcula el último día de un mes específico
- Maneja años bisiestos correctamente

### **ult12(conBd, rutPer, perDesde, perHasta)**
- Determina fechas de inicio y término para los últimos 12 meses
- Ejecuta `sp_determinaPeriodo` para obtener períodos disponibles

### **EsEmpresaPublica(conBd, rutEmp, con_correl, perDesde, perHasta)**
- Determina si una empresa es pública basándose en criterios específicos
- Valida `rpr_proceso = 2`, `EMP_TIPO_GRATIF = 2`, `EMP_ORDEN_INP = 4`

## Validaciones y Controles

1. **Validación de Objetos**: Verifica creación exitosa de objetos COM
2. **Validación de Datos**: Confirma que el trabajador esté asociado a la empresa
3. **Control de Errores**: Manejo de errores con redirección a página de error
4. **Timeout**: Configuración de 3600 segundos para consultas largas
5. **Contabilización**: Registra certificados generados para estadísticas

## Dependencias

### **Archivos Include**
- `layaout_Certificado.asp`: Layout y formato del certificado
- `sql_certificado.asp`: Consultas SQL específicas
- `data.inc`: Configuración de datos
- `adovbs.inc`: Constantes ADO
- `funciones_fechas.asp`: Funciones de manejo de fechas
- `SQLConnection.cls`: Clase de conexión a base de datos
- `utilitarios.asp`: Funciones utilitarias
- `funciones.asp`: Funciones PDF

### **Objetos COM**
- `DPDF_Gen.Document`: Generación de documentos PDF
- `ADODB.Connection`: Conexión a base de datos
- `ADODB.Recordset`: Manejo de resultados

## Casos de Uso

1. **Certificado Anual**: Trabajador solicita certificado de todo un año
2. **Certificado Últimos 12 Meses**: Para trámites que requieren período reciente
3. **Certificado Mensual**: Para verificación de cotización específica
4. **Certificado por Rango**: Para períodos personalizados
5. **Empresa Pública**: Certificados con información de pagos retroactivos

## Consideraciones Técnicas

- **Performance**: Optimizado con procedimientos almacenados
- **Escalabilidad**: Manejo de grandes volúmenes de datos con paginación
- **Compatibilidad**: Soporte para diferentes tipos de instituciones previsionales
- **Seguridad**: Validación de relación trabajador-empresa
- **Auditoría**: Registro de certificados generados

## Validez Legal

El certificado generado es **jurídicamente válido** para cumplir con la exigencia contenida en el Artículo 31 del D.F.L. N° 2, de 1967, Ley Orgánica de la Dirección del Trabajo (ORD. N° 2460 del 27 Junio de 2003).
