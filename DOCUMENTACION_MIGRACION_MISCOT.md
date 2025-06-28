# Documentación de Migración - Sistema Mis Cotizaciones
## SQL Server a Oracle Database

### Información General
- **Sistema Origen**: SQL Server
- **Sistema Destino**: Oracle Database
- **Procedimiento Migrado**: `sp_certCot_trab` → `PRC_CERTCOT_MISCOT_TRAB`
- **Fecha de Migración**: 2025-06-28

### Convenciones de Nomenclatura Aplicadas

#### Prefijos de Objetos Oracle
- **PRC_**: Procedimientos almacenados
- **PKG_**: Packages
- **FNC_**: Funciones
- **TRG_**: Triggers
- **SEC_**: Secuencias
- **VIS_**: Vistas
- **IND_**: Índices
- **TBL_**: Tablas
- **CON_**: Constraints
- **TYP_**: Tipos de datos

#### Estructura de Nombres
- **Sistema**: MISCOT (8 caracteres máximo)
- **Tablas**: SISTEMA_NOMBRE (ej: REC_EMPRESA)
- **Campos**: PREFIJOTABLA_NOMBRE (ej: EMP_RAZ_SOC)

### Mapeo de Tablas SQL Server → Oracle

| SQL Server | Oracle | Descripción |
|------------|--------|-------------|
| EMPRESA | REC_EMPRESA | Datos de empresas |
| PAGO | REC_PAGO | Información de pagos |
| TOTAL_CCAF | REC_TOTALCCAF | Totales CCAF |
| PLANILLA | REC_PLANILLA | Planillas |
| REGION | GEN_UBICGEO | Ubicación geográfica |
| TRABAJADOR | REC_TRABAJADOR | Datos de trabajadores |
| TRA_CCAF | REC_TRACCAF | Trabajador-CCAF |
| SUCURSAL | REC_SUCURSAL | Sucursales |
| DET_CTA_USU | X | Eliminada/No migrada |
| TRAB_AFP | REC_TRAAFP | Trabajador-AFP |
| TRA_INP | REC_TRAINP | Trabajador-INP |
| TRA_ISAPRE | REC_TRAISA | Trabajador-ISAPRE |
| TOTAL_MUTUAL | REC_TOTALSUC | Total mutual |
| TRA_APV | REC_TOTALAPV | APV trabajador |
| ENTIDAD_PREVISIONAL | REC_ENTPREV | Entidades previsionales |
| DATO_USUARIO | REC_DATOUSU | Datos de usuario |
| CERTCOT_GENERADOS | X | Eliminada/No migrada |
| TRA_INPCCAF | REC_TRAINPCCAF | Trabajador INP-CCAF |

### Principales Cambios en la Migración

#### 1. Estructura de Datos
- **SQL Server**: Uso de variables de tabla (`@vir_tra table`)
- **Oracle**: Uso de tipos de objeto y colecciones PL/SQL (`TYP_MISCOT_TAB_TRABAJADOR`)

#### 2. Sintaxis de Funciones
- **SQL Server**: `ISNULL(campo, 0)`
- **Oracle**: `NVL(campo, 0)`

#### 3. Manejo de Fechas
- **SQL Server**: `year(fecha)`, `month(fecha)`
- **Oracle**: `EXTRACT(YEAR FROM fecha)`, `EXTRACT(MONTH FROM fecha)`

#### 4. Collation
- **SQL Server**: `collate SQL_Latin1_General_CP1_CI_AS`
- **Oracle**: Configuración a nivel de base de datos (NLS_SORT, NLS_COMP)

#### 5. Variables de Tabla vs Colecciones
- **SQL Server**: Variables de tabla temporales en memoria
- **Oracle**: Colecciones PL/SQL con tipos definidos

### Archivos Generados

1. **PRC_CERTCOT_MISCOT_TRAB.sql**
   - Procedimiento principal migrado
   - Implementa la lógica de certificados de cotizaciones
   - Usa colecciones PL/SQL en lugar de variables de tabla

2. **TBL_MISCOT_ESTRUCTURAS.sql**
   - Definiciones de tipos de objeto Oracle
   - Tablas temporales globales
   - Índices para optimización
   - Comentarios de documentación

3. **DOCUMENTACION_MIGRACION_MISCOT.md**
   - Este archivo de documentación
   - Mapeo de tablas y cambios principales

### Consideraciones de Implementación

#### Tablas Faltantes
- **DET_CTA_USU**: Marcada como "X" en el mapeo. Se requiere definir si:
  - Se crea una tabla equivalente
  - Se modifica la lógica para no depender de esta tabla
  - Se implementa una solución alternativa

#### Optimizaciones Oracle
1. **Uso de BULK COLLECT**: Para mejorar rendimiento en procesamiento de grandes volúmenes
2. **Índices**: Creados en tablas temporales para optimizar consultas
3. **Hints de Oracle**: Se pueden agregar para optimización específica

#### Tipos de Datos
- **NUMERIC**: Migrado a **NUMBER**
- **VARCHAR**: Migrado a **VARCHAR2**
- **DATETIME**: Migrado a **DATE**

### Funcionalidades Implementadas

#### Procesamiento de Cotizaciones
1. **AFP Gratificaciones**: Proceso 2, períodos específicos
2. **AFP Remuneraciones**: Antes y después de julio 2009
3. **INP**: Cotizaciones previsionales
4. **FONASA**: Cotizaciones de salud
5. **ISAPRE**: Cotizaciones privadas de salud
6. **CCAF**: Cajas de compensación
7. **Seguro de Cesantía**: Fondo de cesantía
8. **Trabajo Pesado**: Cotizaciones especiales
9. **Accidentes del Trabajo**: Mutuales
10. **APV**: Ahorro previsional voluntario

#### Parámetros del Procedimiento
- `p_fec_ini`: Fecha inicio del período
- `p_fec_ter`: Fecha término del período
- `p_emp_rut`: RUT de la empresa
- `p_convenio`: Código de convenio
- `p_rut_tra`: RUT del trabajador
- `p_tipoCon`: Tipo de consulta (1=individual, 2=por usuario, 3=por sucursal)
- `p_parametro`: Parámetro adicional (RUT usuario o código sucursal)
- `p_parametro2`: Código de usuario específico
- `p_parametro3`: Flag para conceptos adicionales CCAF

### Próximos Pasos

1. **Validación de Datos**: Verificar que todas las tablas Oracle existan
2. **Testing**: Ejecutar pruebas con datos reales
3. **Optimización**: Ajustar índices y hints según volumen de datos
4. **Documentación Técnica**: Completar documentación de campos y relaciones
5. **Capacitación**: Entrenar al equipo en las diferencias Oracle vs SQL Server

### Notas Importantes

- El procedimiento mantiene la lógica original pero adaptada a Oracle
- Se requiere validar que todas las tablas referenciadas existan
- Los tipos de datos definidos deben ser creados antes del procedimiento
- Se recomienda realizar pruebas exhaustivas antes de producción
- Considerar el uso de packages para agrupar procedimientos relacionados

### Contacto y Soporte

Para consultas sobre esta migración, contactar al equipo de desarrollo de base de datos.
