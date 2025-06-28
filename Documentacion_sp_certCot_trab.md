# Documentación Técnica: sp_certCot_trab

## Resumen Ejecutivo
El stored procedure `sp_certCot_trab` es un procedimiento complejo diseñado para generar certificados de cotizaciones previsionales de trabajadores. Su función principal es extraer, procesar y consolidar información de cotizaciones de diferentes entidades previsionales (AFP, ISAPRE, CCAF, INP, etc.) para un trabajador específico en un período determinado.

## Parámetros de Entrada

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| @fec_ini | datetime | Fecha de inicio del período de consulta |
| @fec_ter | datetime | Fecha de término del período de consulta |
| @emp_rut | numeric(9) | RUT de la empresa |
| @convenio | numeric(3) | Código del convenio |
| @rut_tra | numeric(9) | RUT del trabajador |
| @tipoCon | numeric | Tipo de consulta (1=Individual, 2=Por sucursal/usuario, 3=Masiva por sucursal) |
| @Parametro | varchar(10) | Parámetro adicional (opcional) |
| @parametro2 | varchar(10) | Filtro por usuario (opcional) |
| @parametro3 | varchar(1) | Incluir conceptos adicionales CCAF (opcional) |

## Estructura de Datos Principales

### Tablas Virtuales Creadas

1. **@vir_tra** y **@vir_tra2**: Almacenan datos consolidados del trabajador
2. **@cert_detalle**: Tabla principal que contiene el detalle de certificaciones
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

#### 2.1 Para Convenios 600-699 (Convenios Especiales)
- **Consulta Individual (@tipoCon = 1)**:
  - Extrae datos de tablas: `empresa`, `sucursal`, `pago`, `trabajador`
  - Aplica lógica especial para multi-CCAF y multi-mutual
  - Filtros: períodos habilitados, procesos válidos (1,2,3,4)

- **Consulta por Sucursal (@tipoCon > 1)**:
  - Similar a individual pero filtra por sucursales específicas
  - Incluye validaciones adicionales de sucursal

#### 2.2 Para Otros Convenios
- **Consulta Individual**: Sin tabla sucursal, lógica simplificada
- **Consulta por Sucursal**: Incluye filtros de sucursal

### 3. Procesamiento de Datos del Trabajador
```sql
-- Actualiza nombre del trabajador con el más reciente
-- Transfiere datos de @vir_tra2 a @vir_tra según filtros
```

## Entidades Previsionales Procesadas

### A. AFP (Administradoras de Fondos de Pensiones)
**Tipo de Entidad: 'A'**

#### A.1 Gratificaciones (Proceso 2)
- **Tablas consultadas**: `trab_afp`, `afps`
- **Lógica de monto**: Usa `rem_imp_afp` para períodos >= Nov 2013, sino `rem_impo`
- **Campo cotización**: `traafp_cot_obl`

#### A.2 Remuneraciones Antes de Julio 2009 (Proceso 1)
- **Monto base**: `rem_impo`
- **Filtro temporal**: Períodos < Julio 2009

#### A.3 Remuneraciones Después de Julio 2009 (Proceso 1)
- **Monto base**: `rem_imp_afp`
- **Filtro temporal**: Períodos >= Julio 2009

### B. ISAPRE y FONASA
**Tipo de Entidad: 'B'**

#### B.1 INP (Instituto de Normalización Previsional)
- **Tablas consultadas**: `tra_inp`, `inp`
- **Condición**: `prevision = 0`
- **Campo cotización**: `trainp_cot_prev`

#### B.2 FONASA
- **Tablas consultadas**: `tra_inp`, `isapres`
- **Condición**: `salud = 0`
- **Campo cotización**: `trainp_cot_Fon`

#### B.3 ISL (Instituto de Seguridad Laboral)
- **Condición**: `trainp_cot_acc_trab > 0`
- **Nombre fijo**: 'I.S.L.'

#### B.4 ISAPRE
- **Tablas consultadas**: `tra_isapre`, `isapres`
- **Condición**: `salud > 0`
- **Lógica especial**: Manejo de FERROSALUD para períodos específicos

### C. CCAF (Cajas de Compensación)
**Tipo de Entidad: 'C'**

- **Tablas consultadas**: `tra_ccaf`, `cajas`
- **Condición**: `salud = 0`
- **Nombres específicos**: Los Andes, Los Héroes, La Araucana, etc.
- **Campo cotización**: `traccaf_salud`

### D. Seguro de Cesantía
**Tipo de Entidad: 'D'**

- **Tablas consultadas**: `trab_afp`, `afps`
- **Monto base**: `rem_impo_fc`
- **Campo cotización**: `TRAAFP_FONDO_CESANTIA`

### E. Trabajo Pesado
**Tipo de Entidad: 'E'**

- **Proceso específico**: 4 (Trabajo pesado)
- **Campo cotización**: `traafp_mto_tra_pes`

### F. Accidentes del Trabajo (Mutuales)
**Tipo de Entidad: 'F'**

- **Tablas consultadas**: `TOTAL_MUTUAL`, `INST_ACC_TRAB`
- **Entidades**: IST, Mutual de Seguridad, ACHS
- **Cálculo complejo**: Considera tasas básicas y adicionales

### G. APV (Ahorro Previsional Voluntario)
**Tipo de Entidad: 'G'**

#### G.1 APV en AFP
- **Proceso**: 3 (Depósitos convenidos)
- **Campo cotización**: `traafp_cot_vol`

#### G.2 APV en Otras Entidades
- **Tablas consultadas**: `tra_apv`, `entidad_previsional`
- **Campo cotización**: `apv_cot_vol`

### I. Conceptos Adicionales CCAF (Opcional)
**Tipo de Entidad: 'I'** - Solo si @parametro3 = '1'

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
- **Tipos 0,1,2**: Join estándar por entidad
- **Tipo 3**: Join adicional por sucursal
- **Tipo 4**: Join adicional por usuario

## Tablas de Base de Datos Consultadas

### Tablas Principales
1. **empresa**: Datos de la empresa empleadora
2. **trabajador**: Información del trabajador y remuneraciones
3. **sucursal**: Datos de sucursales
4. **pago**: Información de pagos y timbres

### Tablas de Entidades Previsionales
1. **afps**: Administradoras de Fondos de Pensiones
2. **isapres**: Instituciones de Salud Previsional
3. **cajas**: Cajas de Compensación
4. **inp**: Instituto de Normalización Previsional
5. **entidad_previsional**: Otras entidades previsionales

### Tablas de Cotizaciones
1. **trab_afp**: Cotizaciones AFP del trabajador
2. **tra_inp**: Cotizaciones INP del trabajador
3. **tra_isapre**: Cotizaciones ISAPRE del trabajador
4. **tra_ccaf**: Cotizaciones CCAF del trabajador
5. **tra_apv**: Cotizaciones APV del trabajador
6. **TOTAL_MUTUAL**: Totales de cotizaciones mutuales
7. **INST_ACC_TRAB**: Instituciones de accidentes del trabajo

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

## Conclusión

El stored procedure `sp_certCot_trab` es una herramienta integral para la generación de certificados de cotizaciones previsionales que:

### Funcionalidad Principal
1. **Consolida información previsional** de múltiples entidades (AFP, ISAPRE, CCAF, INP, Mutuales, etc.)
2. **Genera certificados detallados** de cotizaciones por trabajador y período
3. **Maneja diferentes tipos de consulta** (individual, por sucursal, masiva)
4. **Procesa múltiples tipos de cotizaciones** (obligatorias, voluntarias, seguros, etc.)

### Características Técnicas
1. **Manejo temporal complejo**: Aplica diferentes lógicas según períodos históricos
2. **Flexibilidad de consulta**: Soporta múltiples criterios de filtrado
3. **Integridad de datos**: Valida estados de pago y procesos habilitados
4. **Optimización**: Usa tablas virtuales para mejorar rendimiento

### Casos de Uso
1. **Certificación laboral**: Generación de certificados para trabajadores
2. **Auditorías previsionales**: Verificación de cotizaciones pagadas
3. **Reportes gerenciales**: Análisis de cotizaciones por período
4. **Cumplimiento legal**: Documentación para organismos fiscalizadores

### Complejidad y Mantenimiento
- **Alta complejidad**: Maneja múltiples entidades y reglas de negocio
- **Dependencias extensas**: Requiere múltiples tablas del sistema
- **Lógica temporal**: Considera cambios normativos históricos
- **Mantenimiento crítico**: Cambios requieren análisis exhaustivo de impacto

Este procedimiento es fundamental para el sistema de gestión previsional, proporcionando una vista consolidada y certificada de las cotizaciones de los trabajadores a través de diferentes entidades y períodos.
