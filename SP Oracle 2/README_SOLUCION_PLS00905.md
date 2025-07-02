# Solución al Error PLS-00905 en PRC_CERTCOT_TRAB_PUB

## Problema Identificado

El error `PLS-00905: el objeto OPS$ANDES.PRC_CERTCOT_TRAB_PUB no es válido` ocurre cuando:

1. **El procedimiento aparece como VALID** en `USER_OBJECTS`
2. **Pero Oracle detecta dependencias inválidas** al intentar ejecutarlo
3. **Esto es una "validación diferida"** - Oracle no verifica todas las dependencias hasta la ejecución

## Causas Más Comunes

### 1. Tablas GTT (Global Temporary Tables) Faltantes
El procedimiento `PRC_CERTCOT_TRAB_PUB` requiere estas tablas temporales:
- `GTT_REC_VIR_TRA`
- `GTT_REC_VIR_TRA2`
- `GTT_REC_CERT_DETALLE`
- `GTT_REC_PLANILLA`
- `GTT_REC_SUCURSALES`

### 2. Dependencias Inválidas
- Otros objetos (funciones, procedimientos) que están marcados como INVALID
- Tablas principales que no existen o están corruptas

### 3. Problemas de Compilación
- Errores de sintaxis no detectados en la compilación inicial
- Referencias a objetos que no existen

## Scripts de Solución Proporcionados

### 1. `DIAGNOSTICO_PRC_CERTCOT_TRAB_PUB.sql`
**Propósito**: Identificar la causa exacta del problema

**Qué hace**:
- Verifica el estado del procedimiento
- Muestra errores de compilación específicos
- Verifica existencia de tablas GTT y principales
- Identifica objetos inválidos
- Intenta recompilación y muestra resultados

**Cuándo usar**: Ejecutar PRIMERO para entender el problema específico

### 2. `SOLUCION_PRC_CERTCOT_TRAB_PUB.sql`
**Propósito**: Resolver automáticamente los problemas más comunes

**Qué hace**:
- Crea las tablas GTT si no existen
- Recompila objetos inválidos
- Recompila el procedimiento específico
- Verifica el estado final
- Ejecuta una prueba simple

**Cuándo usar**: Después del diagnóstico, para resolver problemas automáticamente

### 3. `PRUEBA_PRC_CERTCOT_TRAB_PUB.sql` (Modificado)
**Propósito**: Prueba completa con diagnóstico integrado

**Qué hace**:
- Incluye diagnóstico inicial
- Ejecuta el procedimiento con parámetros de prueba
- Muestra resultados detallados
- Proporciona consultas de ayuda

## Pasos de Resolución Recomendados

### Paso 1: Diagnóstico
```sql
@DIAGNOSTICO_PRC_CERTCOT_TRAB_PUB.sql
```

### Paso 2: Aplicar Solución
```sql
@SOLUCION_PRC_CERTCOT_TRAB_PUB.sql
```

### Paso 3: Prueba Final
```sql
@PRUEBA_PRC_CERTCOT_TRAB_PUB.sql
```

## Verificaciones Manuales Adicionales

### 1. Verificar Estado del Procedimiento
```sql
SELECT OBJECT_NAME, STATUS FROM USER_OBJECTS 
WHERE OBJECT_NAME = 'PRC_CERTCOT_TRAB_PUB';
```

### 2. Ver Errores de Compilación
```sql
SELECT LINE, POSITION, TEXT FROM USER_ERRORS 
WHERE NAME = 'PRC_CERTCOT_TRAB_PUB'
ORDER BY SEQUENCE;
```

### 3. Verificar Dependencias
```sql
SELECT REFERENCED_NAME, REFERENCED_TYPE, DEPENDENCY_TYPE
FROM USER_DEPENDENCIES 
WHERE NAME = 'PRC_CERTCOT_TRAB_PUB';
```

### 4. Recompilar Manualmente
```sql
ALTER PROCEDURE PRC_CERTCOT_TRAB_PUB COMPILE;
```

## Problemas Específicos y Soluciones

### Error: "Table or view does not exist"
**Causa**: Faltan tablas GTT o principales
**Solución**: Ejecutar `CREATE_GTT_TABLES_CERTCOT.sql` y verificar tablas principales

### Error: "Invalid identifier"
**Causa**: Nombres de columnas incorrectos o tablas con estructura diferente
**Solución**: Verificar estructura de tablas contra el código del procedimiento

### Error: "Object is invalid"
**Causa**: Dependencias circulares o objetos inválidos
**Solución**: Recompilar todos los objetos inválidos en orden

## Notas Importantes

1. **Las tablas GTT son específicas de sesión** - se crean vacías y se llenan durante la ejecución
2. **El procedimiento requiere datos en las tablas principales** para funcionar correctamente
3. **Los parámetros de prueba deben corresponder a datos reales** en las tablas
4. **El error PLS-00905 es diferente a errores de compilación** - indica problemas de dependencias

## Contacto y Soporte

Si después de ejecutar todos los scripts el problema persiste:

1. Revisar los logs de error específicos
2. Verificar permisos de usuario en las tablas
3. Contactar al administrador de base de datos
4. Considerar recrear el procedimiento desde cero

## Archivos Relacionados

- `PRC_CERTCOT_TRAB_PUB.sql` - Código fuente del procedimiento
- `CREATE_GTT_TABLES_CERTCOT.sql` - Creación de tablas GTT
- `tablasAndes/` - Definiciones de tablas principales
- `Documentacion_sp_certCot_trab_pub.md` - Documentación técnica completa
