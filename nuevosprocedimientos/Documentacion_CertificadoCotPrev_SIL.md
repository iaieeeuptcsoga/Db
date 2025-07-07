# Documentación Técnica: CertificadoCotPrev_SIL.asp

## Resumen Ejecutivo

El archivo `CertificadoCotPrev_SIL.asp` es una aplicación web ASP (Active Server Pages) desarrollada para generar certificados de cotizaciones previsionales en formato PDF para el Sistema de Información Laboral (S.I.L.). Este sistema permite a las empresas emitir certificados oficiales que validan las cotizaciones realizadas por los trabajadores a diferentes entidades previsionales.

## ¿Qué hace?

### Funcionalidad Principal
- **Genera certificados de cotizaciones previsionales en formato PDF** para trabajadores específicos
- **Consolida información de múltiples entidades previsionales** (AFP, ISAPRE, CCAF, INP, Seguro de Cesantía)
- **Permite diferentes tipos de consultas temporales**:
  - Año específico
  - Últimos 12 meses
  - Mes y año específico
  - Rango de períodos personalizado
- **Produce documentos jurídicamente válidos** según normativa laboral chilena

### Tipos de Datos Procesados
- Información del trabajador (RUT, nombre, apellidos)
- Períodos de cotización
- Montos cotizados por entidad
- Fechas de inicio y término de subsidios
- Días trabajados
- Remuneraciones imponibles
- Fechas de pago
- Folios de planillas
- Entidades pagadoras de subsidios

## ¿Por qué lo hace?

### Cumplimiento Legal
- **Artículo 31 del D.F.L. N° 2 de 1967** - Ley Orgánica de la Dirección del Trabajo
- **Ordenanza N° 2460 del 27 de Junio de 2003** - Validez jurídica de certificados
- **Obligación empresarial** de proporcionar certificados de cotizaciones a trabajadores

### Necesidades del Negocio
- **Transparencia laboral**: Los trabajadores pueden verificar sus cotizaciones
- **Procesos administrativos**: Requerido para trámites previsionales
- **Auditorías**: Documentación oficial para fiscalizaciones
- **Gestión de subsidios**: Información necesaria para licencias médicas

### Beneficios Operacionales
- **Automatización**: Reduce trabajo manual de generación de certificados
- **Consistencia**: Formato estandarizado y datos confiables
- **Trazabilidad**: Registro de certificados emitidos
- **Eficiencia**: Generación rápida bajo demanda

## ¿Cómo lo hace?

### Arquitectura Técnica

#### 1. Tecnologías Utilizadas
- **ASP (VBScript)**: Lógica de aplicación web
- **SQL Server**: Base de datos principal
- **DPDF_Gen**: Componente para generación de PDF
- **ADODB**: Conectividad con base de datos

#### 2. Archivos de Dependencia
```
CertificadoCotPrev_SIL.asp
├── layaut/layautCert_SIL.asp      # Layout y formato del certificado
├── sql/sqlCert_SIL.asp            # Funciones SQL y consultas
├── data.inc                       # Configuración de datos
├── adovbs.inc                     # Constantes ADODB
├── funciones_fechas.asp           # Utilidades de fechas
└── SQLConnection.cls              # Clase de conexión SQL
```

#### 3. Stored Procedures Principales
- **`sp_certCot_SIL`**: Procedimiento principal que extrae datos de cotizaciones
- **`sp_determinaPeriodo`**: Determina períodos de los últimos 12 meses
- **`sp_actCertCot_generados`**: Contabiliza certificados emitidos

### Flujo de Procesamiento

#### Fase 1: Inicialización y Parámetros
```vbscript
' Configuración de timeout
Server.ScriptTimeout = 3600

' Parámetros de entrada
Per_Rut     = RUT del trabajador
EmpRut      = RUT de la empresa
cnvCta      = Código de convenio
selOp       = Tipo de operación (1-5)
anio        = Año de consulta
nMes        = Mes específico (opcional)
```

#### Fase 2: Determinación de Períodos
```vbscript
Select Case selOp
    Case 1: ' Año específico
        Per_Desde = anio & "-01-31"
        Per_Hasta = anio & "-12-31"
    
    Case 2: ' Últimos 12 meses
        Call ult12(ConnBd, Per_Rut, Per_Desde, Per_Hasta)
    
    Case 4: ' Mes específico
        Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
        Per_Hasta = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
    
    Case 5: ' Rango personalizado
        Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
        Per_Hasta = anioHasta & "-" & mesHasta & "-" & UltimoDiaDeMes(mesHasta,anioHasta)
End Select
```

#### Fase 3: Extracción de Datos
```vbscript
' Llamada al procedimiento principal
SQL_TRA_DET ConnBd, rsx, per_desde, per_hasta, EmpRut, cnvCta, Per_Rut

' Validación de datos
If rsx.EOF or rsx.BOF Then
    ' Mostrar mensaje: "La persona no está asociada a la empresa"
    Response.End
End If
```

#### Fase 4: Generación del PDF

##### Estructura del Documento
1. **Encabezado**: Información de la empresa y trabajador
2. **Tabla de datos**: Cotizaciones por período y entidad
3. **Pie de página**: Validación jurídica y numeración

##### Campos del Certificado
- **Institución de Previsión**: Nombre de la entidad (AFP, ISAPRE, etc.)
- **Mes y Año Período**: Período de cotización
- **Fecha Ini. Sub.**: Fecha inicio subsidio
- **Fecha Ter. Sub.**: Fecha término subsidio
- **Días de licencia**: Días trabajados/subsidiados
- **Remuneración Imponible**: Monto base de cotización
- **Monto Cotizado**: Valor efectivamente cotizado
- **Fecha de pago**: Cuándo se realizó el pago
- **N° folio planilla**: Identificador de planilla
- **Entidad pagadora de Subsidio**: Quién paga el subsidio

#### Fase 5: Procesamiento Especial

##### Manejo de Entidades Discontinuadas
```vbscript
' Casos especiales para ISAPRES que dejaron de operar
If YEAR(rsx("rec_periodo")) = "2003" and MONTH(rsx("rec_periodo")) = "11" Then
    If cLng(rsx("TRA_REG_SAL")) = 20 OR cLng(rsx("TRA_REG_SAL")) = 5 Then
        ' Vida Plena o Cigna Salud - usar función nombreEntidad()
        flag = true
    End If
End If
```

##### Manejo de SANTA MARIA
```vbscript
' Lógica especial para períodos anteriores a abril 2008
If (Trim(rsx("ENT_RUT")) = "98000000" _
    and (YEAR(rsx("rec_periodo")) < 2008 or 
         (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) Then
    If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
        objPage.addtextarea "SANTA MARIA", -17, n, 504, 12, 1, 7, 8, "000000"
    End If
End If
```

#### Fase 6: Finalización
```vbscript
' Generación final del PDF
objDoc.DrawToASP

' Contabilización de certificados emitidos
sqlStrCant = "EXEC sp_actCertCot_generados '" & sFechaCreaPdf & "'"
ConnBd.Execute sqlStrCant

' Limpieza de recursos
objDoc = Nothing
ConnBd.Close
```

### Características Técnicas

#### Manejo de Errores
- Validación de conexión a base de datos
- Verificación de existencia de datos
- Manejo de timeouts (1 hora)
- Redirección a página de error en caso de fallas

#### Optimizaciones
- Uso de cursores para grandes volúmenes de datos
- Paginación automática del PDF
- Reutilización de conexiones
- Formato eficiente de números y fechas

#### Seguridad
- Validación de parámetros de entrada
- Uso de stored procedures (prevención SQL injection)
- Manejo seguro de sesiones
- Limpieza de objetos y conexiones

### Integración con el Sistema

#### Dependencias Externas
- **Base de datos SQL Server** con tablas de trabajadores, empresas y cotizaciones
- **Componente DPDF_Gen** para generación de PDF
- **Sistema de autenticación** para validar empresa (Session("RutEmp"))

#### Salidas del Sistema
- **Documento PDF** enviado directamente al navegador
- **Registro de auditoría** en tabla de certificados generados
- **Mensajes de error** en caso de problemas

## Historial de Modificaciones

- **13-04-2006**: Versión inicial (Autor: IPA)
- **06-06-2011**: Agregada contabilización de certificados emitidos (VOS)
- **11/04/2008**: Soporte para consulta por mes específico (VOS)
- **20091007**: Soporte para rangos de períodos personalizados (VOS)

## Consideraciones de Mantenimiento

### Puntos de Atención
1. **Cambios en entidades previsionales**: Requiere actualización de lógica especial
2. **Modificaciones legales**: Puede requerir cambios en formato o validaciones
3. **Actualizaciones de base de datos**: Verificar compatibilidad con stored procedures
4. **Rendimiento**: Monitorear tiempos de generación con grandes volúmenes

### Recomendaciones
- Mantener actualizada la lógica de entidades discontinuadas
- Revisar periódicamente la validez jurídica del formato
- Implementar logs detallados para debugging
- Considerar migración a tecnologías más modernas (.NET, etc.)
