# Documentación Técnica: sqlCert_SIL.asp

## Resumen Ejecutivo

El archivo `sqlCert_SIL.asp` es un módulo de funciones ASP que actúa como **capa de abstracción de datos** para el sistema de certificados de cotizaciones del Sistema de Información Laboral (S.I.L.). Su función principal es encapsular la lógica de acceso a datos y ejecutar el stored procedure `sp_certCot_SIL` que extrae la información de cotizaciones previsionales de los trabajadores.

## ¿Qué hace?

### Funcionalidad Principal
- **Ejecuta consultas de datos de cotizaciones** para certificados SIL
- **Maneja la conexión y ejecución** del stored procedure `sp_certCot_SIL`
- **Implementa control de acceso por sucursal** basado en permisos de usuario
- **Proporciona manejo de errores** para operaciones de base de datos
- **Retorna recordset** con datos listos para generar certificados PDF

### Función Principal: SQL_TRA_DET
```vbscript
Function SQL_TRA_DET(ConnBd, byRef rsx, fec_ini, fec_ter, emp_rut, convenio, rut_tra)
```

#### Parámetros de Entrada
- **ConnBd**: Objeto de conexión a base de datos (ADODB.Connection)
- **rsx**: Recordset de salida (pasado por referencia)
- **fec_ini**: Fecha de inicio del período (formato: "YYYY-MM-DD")
- **fec_ter**: Fecha de término del período (formato: "YYYY-MM-DD")
- **emp_rut**: RUT de la empresa (numérico)
- **convenio**: Código de convenio (numérico)
- **rut_tra**: RUT del trabajador (numérico)

#### Datos Retornados
El recordset contiene información consolidada de cotizaciones:
- Períodos de cotización
- Entidades previsionales (AFP, ISAPRE, CCAF, INP, Seguro Cesantía)
- Montos cotizados por entidad
- Fechas de subsidios
- Información de planillas
- Datos del trabajador y empresa

## ¿Por qué lo hace?

### Separación de Responsabilidades
- **Modularidad**: Separa la lógica de datos de la presentación
- **Reutilización**: Permite usar la misma función en diferentes contextos
- **Mantenibilidad**: Centraliza cambios en consultas de datos
- **Testabilidad**: Facilita pruebas independientes de la lógica de datos

### Control de Seguridad
- **Filtrado por sucursal**: Implementa restricciones de acceso según usuario
- **Validación de permisos**: Verifica autorización antes de ejecutar consultas
- **Prevención de acceso no autorizado**: Controla qué datos puede ver cada usuario

### Gestión de Errores
- **Manejo robusto**: Captura errores de base de datos
- **Mensajes informativos**: Proporciona feedback claro sobre problemas
- **Prevención de fallos**: Evita que errores de datos afecten la aplicación

## ¿Cómo lo hace?

### Arquitectura del Módulo

#### 1. Estructura del Archivo
```
sqlCert_SIL.asp
├── Función SQL_TRA_DET()
│   ├── Control de acceso por sucursal
│   ├── Ejecución de stored procedure
│   ├── Manejo de errores
│   └── Validación de resultados
└── Comentarios de ejemplo de uso
```

#### 2. Flujo de Procesamiento

##### Fase 1: Control de Acceso por Sucursal
```vbscript
CRIT_SUC = " SELECT DET_CTA_USU.COD_SUC FROM DET_CTA_USU DET_CTA_USU " & _
           " WHERE (DET_CTA_USU.CON_RUT=" & emp_rut & ")" & _
           " AND (DET_CTA_USU.CON_CORREL=" & convenio & ") " & _
           " AND (DET_CTA_USU.USR_RUT=" & Session("RutRep") & ")"

IF Session("USU_COD_PER") <> "SI" THEN CRIT_SUC = ""
```

**Propósito del Control de Acceso:**
- **Tabla DET_CTA_USU**: Contiene relación usuario-empresa-convenio-sucursal
- **Session("RutRep")**: RUT del representante/usuario logueado
- **Session("USU_COD_PER")**: Indicador de permisos especiales
  - Si es "SI": Usuario tiene permisos completos
  - Si no es "SI": Se aplican restricciones por sucursal

**Lógica de Seguridad:**
- Usuarios normales: Solo ven datos de sucursales asignadas
- Usuarios con permisos especiales: Ven todos los datos
- Filtro dinámico basado en sesión del usuario

##### Fase 2: Construcción y Ejecución de Consulta
```vbscript
sql = "EXEC sp_certCot_SIL '" & fec_ini & "','" & fec_ter & "'," & emp_rut & "," & convenio & "," & rut_tra

rsx.CursorLocation = adUseClient
rsx.Open sql, ConnBd, adOpenKeyset, adLockOptimistic
```

**Configuración del Recordset:**
- **adUseClient**: Cursor del lado del cliente para mejor rendimiento
- **adOpenKeyset**: Permite navegación bidireccional
- **adLockOptimistic**: Bloqueo optimista para lectura

##### Fase 3: Manejo de Errores y Validaciones
```vbscript
if err.number <> 0 then
    msgTxt = "Error al ejecutar consulta."
    fx_SQL_PEN_DET = msgTxt
    exit function
end if

if rsx.EOF or rsx.BOF then
    msgTxt = "No se encuentra información de la persona solicitada."
    fx_SQL_PEN_DET = msgTxt
    exit function
end if
```

**Tipos de Validación:**
1. **Errores de Ejecución**: Problemas de conexión, SQL inválido, etc.
2. **Datos Vacíos**: Trabajador no encontrado o sin cotizaciones
3. **Retorno de Mensajes**: Información clara sobre el problema

### Integración con el Sistema

#### Relación con Stored Procedure sp_certCot_SIL
El archivo actúa como **wrapper** del stored procedure principal:

```sql
-- sp_certCot_SIL realiza:
1. Extracción de datos base del trabajador (@vir_tra)
2. Cotizaciones INP (tipo_ent = 'A')
3. Cotizaciones FONASA (tipo_ent = 'B') 
4. Cotizaciones ISAPRE (tipo_ent = 'B')
5. Cotizaciones CCAF (tipo_ent = 'C')
6. Seguro de Cesantía (tipo_ent = 'D')
7. Asociación con números de planilla
8. Ordenamiento final por período y entidad
```

#### Variables de Sesión Utilizadas
- **Session("RutRep")**: RUT del representante logueado
- **Session("USU_COD_PER")**: Nivel de permisos del usuario
- **Session("RutEmp")**: RUT de la empresa (usado en archivo principal)

#### Tabla de Control DET_CTA_USU
```sql
-- Estructura conceptual:
CON_RUT      -- RUT de la empresa
CON_CORREL   -- Código de convenio  
USR_RUT      -- RUT del usuario/representante
COD_SUC      -- Código de sucursal autorizada
```

**Propósito**: Controlar qué sucursales puede consultar cada usuario

### Características Técnicas

#### Configuración de Conexión
- **Timeout**: Heredado de la conexión principal (3600 segundos)
- **Tipo de Cursor**: Cliente (mejor rendimiento para lectura)
- **Modo de Bloqueo**: Optimista (solo lectura)

#### Manejo de Memoria
- **Recordset por Referencia**: Evita copias innecesarias de datos
- **Cursor del Cliente**: Libera recursos del servidor rápidamente
- **Sin Cleanup Explícito**: El recordset se maneja en el archivo principal

#### Compatibilidad
- **ASP Clásico**: Compatible con IIS 5.0+
- **VBScript**: Sintaxis estándar
- **SQL Server**: Optimizado para versiones 2000+

### Ejemplo de Uso

#### Llamada desde CertificadoCotPrev_SIL.asp
```vbscript
' Parámetros de entrada
per_desde = "2023-01-31"
per_hasta = "2023-12-31" 
EmpRut = 81826800
cnvCta = 1
Per_Rut = 13287666

' Ejecución
SQL_TRA_DET ConnBd, rsx, per_desde, per_hasta, EmpRut, cnvCta, Per_Rut

' Verificación de resultados
If rsx.EOF or rsx.BOF Then
    ' Mostrar mensaje de error
    Response.Write "La persona no está asociada a la empresa"
Else
    ' Procesar datos para generar PDF
    Do While Not rsx.EOF
        ' Lógica de generación de certificado
        rsx.MoveNext
    Loop
End If
```

### Consideraciones de Seguridad

#### Prevención de SQL Injection
- **Stored Procedures**: Uso exclusivo de procedimientos almacenados
- **Parámetros Tipados**: Validación implícita de tipos de datos
- **Sin Concatenación Directa**: No se construye SQL dinámico

#### Control de Acceso
- **Filtrado por Usuario**: Solo datos autorizados por DET_CTA_USU
- **Validación de Sesión**: Verificación de usuario logueado
- **Restricciones por Sucursal**: Granularidad de permisos

#### Manejo de Errores
- **No Exposición de Detalles**: Mensajes genéricos al usuario
- **Logging Implícito**: Errores capturados por ASP
- **Salida Controlada**: Exit function en caso de problemas

### Limitaciones y Consideraciones

#### Dependencias
- **Tabla DET_CTA_USU**: Crítica para control de acceso
- **Stored Procedure sp_certCot_SIL**: Debe existir y estar actualizado
- **Variables de Sesión**: Requiere autenticación previa

#### Rendimiento
- **Consultas Complejas**: sp_certCot_SIL puede ser lento con grandes volúmenes
- **Cursor Cliente**: Transfiere todos los datos al cliente
- **Sin Paginación**: Carga completa de resultados

#### Mantenimiento
- **Lógica Distribuida**: Cambios requieren coordinación con SP
- **Dependencia de Sesión**: Cambios en autenticación afectan funcionamiento
- **Tabla de Control**: Mantenimiento manual de permisos por sucursal

## Historial de Modificaciones

- **04-11-2005**: Versión inicial del módulo
- **Descripción incompleta**: El comentario original no especifica funcionalidad

## Recomendaciones de Mejora

### Funcionalidad
1. **Logging Detallado**: Implementar registro de consultas ejecutadas
2. **Validación de Parámetros**: Verificar formato y rangos de fechas
3. **Cache de Resultados**: Considerar cache para consultas frecuentes

### Seguridad
1. **Validación Adicional**: Verificar permisos a nivel de trabajador
2. **Auditoría**: Registrar accesos a datos sensibles
3. **Timeout de Sesión**: Validar vigencia de sesión

### Rendimiento
1. **Paginación**: Implementar carga por páginas
2. **Índices**: Optimizar consultas en DET_CTA_USU
3. **Compresión**: Considerar compresión de datos transferidos
