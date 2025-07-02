# Documentación Técnica: sp_certCot_trab_pub

## Resumen Ejecutivo
El stored procedure `sp_certCot_trab_pub` es una versión extendida del procedimiento `sp_certCot_trab`, diseñado específicamente para generar certificados de cotizaciones previsionales de trabajadores con funcionalidades adicionales para el sector público. Su función principal es extraer, procesar y consolidar información de cotizaciones de diferentes entidades previsionales (AFP, ISAPRE, CCAF, INP, etc.) para un trabajador específico en un período determinado, incluyendo el manejo de pagos retroactivos y conceptos adicionales de CCAF.

## Parámetros de Entrada

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| @fec_ini | datetime | Fecha de inicio del período de consulta |
| @fec_ter | datetime | Fecha de término del período de consulta |
| @emp_rut | numeric(9) | RUT de la empresa |
| @convenio | numeric(3) | Código del convenio |
| @rut_tra | numeric(9) | RUT del trabajador |
| @tipoCon | numeric | Tipo de consulta (1=Individual, 2=Por sucursal/usuario, 3=Masiva por sucursal) |
| @Parametro | varchar(10) | Parámetro adicional (opcional) - Usuario o sucursal según @tipoCon |
| @parametro2 | varchar(10) | Filtro por código de usuario (opcional) |
| @parametro3 | varchar(1) | Incluir conceptos adicionales CCAF (opcional) - '1' para incluir |

## Diferencias Principales con sp_certCot_trab

### 1. Campo Adicional: usu_pago_retroactivo
- **Propósito**: Controla el manejo de pagos retroactivos
- **Lógica**: Se aplica para períodos >= Mayo 2012
- **Valor**: '0' por defecto, valor de `dato_usuario.usu_pago_retroactivo` cuando aplica

### 2. Conceptos Adicionales CCAF (Parámetro @parametro3 = '1')
Cuando se activa este parámetro, se incluyen los siguientes conceptos adicionales:

#### I.1 Créditos CCAF
- **Tipo de Entidad**: 'I'
- **Campo**: `traccaf_mto_cred`
- **Sufijo nombre**: 'CREDITOS'

#### I.2 Ahorro CCAF  
- **Tipo de Entidad**: 'I'
- **Campo**: `traccaf_mto_leas`
- **Sufijo nombre**: 'AHORRO'

#### I.3 Seguro de Vida CCAF
- **Tipo de Entidad**: 'I'
- **Campo**: `traccaf_mto_seg`
- **Sufijo nombre**: 'SEG. VIDA'

#### I.4 Servicios Legales Prepagados CCAF
- **Tipo de Entidad**: 'I'
- **Campo**: `traccaf_mto_otro`
- **Sufijo nombre**: 'SERV.LEG.PREPAG.'

### 3. Cuenta de Ahorro Previsional AFP (Tipo 'J')
Incluye manejo de cuentas de ahorro previsional con lógica temporal:

#### J.1 Antes de Julio 2009
- **Monto base**: `rem_impo`
- **Campo cotización**: `traafp_cta_aho`

#### J.2 Después de Julio 2009
- **Monto base**: `rem_imp_afp`
- **Campo cotización**: `traafp_cta_aho`

## Estructura de Datos Principales

### Tablas Virtuales Creadas

1. **@vir_tra** y **@vir_tra2**: Almacenan datos consolidados del trabajador
   - **Diferencia**: Incluye campo `usu_pago_retroactivo`
   
2. **@cert_detalle**: Tabla principal que contiene el detalle de certificaciones
   - **Diferencia**: Incluye campo `usu_pago_retroactivo`
   
3. **@planilla**: Información de planillas asociadas
4. **@sucursales**: Lista de sucursales según tipo de consulta

## Flujo Principal del Procedimiento

### 1. Inicialización y Configuración de Sucursales
```sql
-- Determina las sucursales a procesar según @tipoCon
if @tipoCon = 2: Consulta por sucursal/usuario específico
if @tipoCon = 3: Consulta masiva por sucursal
```

### 2. Extracción de Datos Base del Trabajador

#### 2.1 Para Convenios 600-699 (Sector Público)
- **Consulta Individual**: Incluye tabla sucursal y manejo de pagos retroactivos
- **Consulta por Sucursal**: Incluye filtros de sucursal y usuario

#### 2.2 Para Otros Convenios
- **Consulta Individual**: Sin tabla sucursal, lógica simplificada
- **Consulta por Sucursal**: Incluye filtros de sucursal

### 3. Procesamiento de Datos del Trabajador
```sql
-- Actualiza nombre del trabajador con el más reciente
-- Transfiere datos de @vir_tra2 a @vir_tra según filtros
-- Incluye manejo de usu_pago_retroactivo
```

## Entidades Previsionales Procesadas

### A. AFP (Administradoras de Fondos de Pensiones)
**Tipo de Entidad: 'A'**

#### A.1 Gratificaciones (Proceso 2)
- **Tablas consultadas**: `trab_afp`, `afps`
- **Lógica de monto**: Usa `rem_imp_afp` para períodos >= Nov 2013, sino `rem_impo`
- **Campo cotización**: `traafp_cot_obl`
- **Campo adicional**: `afp_seg_inv_sobre` (seguro de invalidez y sobrevivencia)

#### A.2 Remuneraciones Antes de Julio 2009 (Proceso 1)
- **Monto base**: `rem_impo`
- **Campo cotización**: `traafp_cot_obl`

#### A.3 Remuneraciones Después de Julio 2009 (Proceso 1)
- **Monto base**: `rem_imp_afp`
- **Campo cotización**: `traafp_cot_obl`

### B. FONASA e ISAPRE (Instituciones de Salud)
**Tipo de Entidad: 'B'**

#### B.1 FONASA (salud = 0)
- **Tablas consultadas**: `tra_inp`, `isapres`
- **Lógica de monto**: Compleja según período y proceso
- **Campo cotización**: `trainp_cot_Fon`

#### B.2 ISAPRE (salud > 0)
- **Tablas consultadas**: `tra_isapre`, `isapres`
- **Lógica de monto**: Usa `rem_impo_isa` para períodos >= Nov 2013
- **Campo cotización**: `traisa_cot_apagar`

### C. CCAF (Cajas de Compensación)
**Tipo de Entidad: 'C'**

#### C.1 Cotización Regular CCAF
- **Tablas consultadas**: `tra_ccaf`, `cajas`
- **Lógica de monto**: Usa `rem_impo_ccaf` para períodos >= Nov 2013
- **Campo cotización**: `traccaf_salud`
- **Nombres específicos**: Incluye porcentaje 0.6% en el nombre

### D. Seguro de Cesantía
**Tipo de Entidad: 'D'**
- **Tablas consultadas**: `trab_afp`, `afps`
- **Monto base**: `rem_impo_fc`
- **Campo cotización**: `TRAAFP_FONDO_CESANTIA`

### E. Trabajo Pesado AFP
**Tipo de Entidad: 'E'**
- **Proceso específico**: rpr_proceso = 4
- **Campo cotización**: `traafp_mto_tra_pes`
- **Prefijo nombre**: 'TRAB.PES.'

### F. Accidentes del Trabajo (Mutuales)
**Tipo de Entidad: 'F'**
- **Tablas consultadas**: `TOTAL_MUTUAL`, `INST_ACC_TRAB`
- **Cálculo dinámico**: `(monto_base * (tasa_cot_mut + tasa_adic_mut)) / 100`
- **Validación**: Requiere que existan registros en TOTAL_MUTUAL

### G. APV (Ahorro Previsional Voluntario)
**Tipo de Entidad: 'G'**

#### G.1 APV en AFP (Proceso 3)
- **Tablas consultadas**: `trab_afp`, `afps`
- **Campo cotización**: `traafp_cot_vol`

#### G.2 APV en Otras Entidades (Proceso 3)
- **Tablas consultadas**: `tra_apv`, `entidad_previsional`
- **Campo cotización**: `apv_cot_vol`

### I. Conceptos Adicionales CCAF (Solo si @parametro3 = '1')
**Tipo de Entidad: 'I'**

#### I.1 Créditos CCAF
- **Campo**: `traccaf_mto_cred`
- **Sufijo nombre**: 'CREDITOS'

#### I.2 Ahorro CCAF
- **Campo**: `traccaf_mto_leas`
- **Sufijo nombre**: 'AHORRO'

#### I.3 Seguro de Vida CCAF
- **Campo**: `traccaf_mto_seg`
- **Sufijo nombre**: 'SEG. VIDA'

#### I.4 Servicios Legales Prepagados CCAF
- **Campo**: `traccaf_mto_otro`
- **Sufijo nombre**: 'SERV.LEG.PREPAG.'

### J. Cuenta de Ahorro Previsional AFP
**Tipo de Entidad: 'J'**

#### J.1 Antes de Julio 2009
- **Monto base**: `rem_impo`
- **Campo cotización**: `traafp_cta_aho`

#### J.2 Después de Julio 2009
- **Monto base**: `rem_imp_afp`
- **Campo cotización**: `traafp_cta_aho`

## Procesamiento de Planillas

### Cursor de Procesamiento
```sql
-- Recorre cada período/comprobante único en @cert_detalle
-- Asocia números de planilla según tipo de impresión
```

### Lógica por Tipo de Impresión
- **Tipos 0, 1, 2**: Join por período, comprobante y entidad
- **Tipo 3**: Join adicional por sucursal
- **Tipo 4**: Join adicional por usuario

## Tablas Principales Consultadas

### Tablas Base
1. **empresa**: Información de la empresa
2. **sucursal**: Información de sucursales (solo convenios 600-699)
3. **pago**: Control de pagos habilitados
4. **trabajador**: Datos del trabajador
5. **dato_usuario**: Información adicional de usuario (para pagos retroactivos)

### Tablas de Entidades
1. **afps**: Administradoras de Fondos de Pensiones
2. **inp**: Instituto de Normalización Previsional
3. **isapres**: Instituciones de Salud Previsional
4. **cajas**: Cajas de Compensación de Asignación Familiar
5. **entidad_previsional**: Entidades previsionales generales
6. **INST_ACC_TRAB**: Instituciones de accidentes del trabajo

### Tablas de Cotizaciones
1. **trab_afp**: Cotizaciones AFP del trabajador
2. **tra_inp**: Cotizaciones INP del trabajador
3. **tra_isapre**: Cotizaciones ISAPRE del trabajador
4. **tra_ccaf**: Cotizaciones CCAF del trabajador
5. **tra_apv**: Cotizaciones APV del trabajador
6. **TOTAL_MUTUAL**: Totales de cotizaciones mutuales

### Tabla de Control
1. **planilla**: Números de planillas por entidad
2. **DET_CTA_USU**: Detalle de cuentas de usuario (para filtros)

## Resultado Final

El procedimiento retorna un dataset con la siguiente estructura:
- **rec_periodo**: Período de la cotización
- **nro_comprobante**: Número de comprobante
- **tipo_Impre**: Tipo de impresión
- **suc_cod**: Código de sucursal
- **usu_cod**: Código de usuario
- **tipo_ent**: Tipo de entidad (A,B,C,D,E,F,G,I,J)
- **ent_rut**: RUT de la entidad
- **ent_nombre**: Nombre de la entidad
- **tra_rut**: RUT del trabajador
- **tra_dig**: Dígito verificador del trabajador
- **tra_nombre**: Nombre del trabajador
- **tra_ape**: Apellido del trabajador
- **dias_trab**: Días trabajados
- **rem_impo**: Remuneración imponible
- **monto_cotizado**: Monto de la cotización
- **fec_pago**: Fecha de pago
- **folio_planilla**: Folio de la planilla
- **raz_soc**: Razón social de la empresa
- **salud**: Código de salud
- **monto_sis**: Monto del sistema
- **usu_pago_retroactivo**: Indicador de pago retroactivo (NUEVO)

## Conclusión

El stored procedure `sp_certCot_trab_pub` es una herramienta integral y extendida para la generación de certificados de cotizaciones previsionales que:

### Funcionalidad Principal
1. **Consolida información previsional** de múltiples entidades con funcionalidades adicionales
2. **Genera certificados detallados** con manejo de pagos retroactivos
3. **Maneja conceptos adicionales CCAF** cuando se requiere
4. **Incluye cuentas de ahorro previsional** con lógica temporal específica
5. **Soporta sector público** con manejo especializado de convenios 600-699

### Características Técnicas Adicionales
1. **Manejo de pagos retroactivos**: Control específico para períodos >= Mayo 2012
2. **Conceptos CCAF extendidos**: Créditos, ahorro, seguros y servicios legales
3. **Cuentas de ahorro previsional**: Manejo temporal antes/después de Julio 2009
4. **Flexibilidad sectorial**: Adaptado para sector público y privado

### Casos de Uso Específicos
1. **Certificación sector público**: Generación de certificados con conceptos adicionales
2. **Auditorías previsionales extendidas**: Verificación completa incluyendo APV y CCAF
3. **Reportes gerenciales completos**: Análisis integral de todas las cotizaciones
4. **Cumplimiento legal sectorial**: Documentación específica para organismos públicos

### Complejidad y Mantenimiento
- **Muy alta complejidad**: Maneja múltiples entidades y reglas de negocio extendidas
- **Dependencias extensas**: Requiere múltiples tablas del sistema y validaciones adicionales
- **Lógica temporal compleja**: Considera múltiples cambios normativos históricos
- **Mantenimiento crítico**: Cambios requieren análisis exhaustivo de impacto en múltiples conceptos

Este procedimiento es fundamental para el sistema de gestión previsional del sector público, proporcionando una vista consolidada y certificada completa de todas las cotizaciones de los trabajadores a través de diferentes entidades, períodos y conceptos adicionales.
