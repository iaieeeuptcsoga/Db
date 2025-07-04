CREATE OR REPLACE PROCEDURE PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV (
    p_rut_tra           IN NUMBER,
    p_emp_rut           IN NUMBER,
    p_cnv_cta           IN NUMBER,
    p_sel_op            IN NUMBER,
    p_anio              IN NUMBER,
    p_mes               IN NUMBER DEFAULT NULL,
    p_anio_hasta        IN NUMBER DEFAULT NULL,
    p_mes_hasta         IN NUMBER DEFAULT NULL,
    p_imp_ccaf          IN VARCHAR2 DEFAULT 'N',
    p_tipo_con          IN NUMBER DEFAULT 1,

    -- CURSORS DE SALIDA ESTRUCTURADOS PARA PDF
    p_cursor_datos      OUT SYS_REFCURSOR,  -- Datos principales del certificado
    p_cursor_encabezado OUT SYS_REFCURSOR,  -- Datos del encabezado
    p_cursor_metadatos  OUT SYS_REFCURSOR,  -- Metadatos para paginación

    -- PARÁMETROS DE SALIDA ORIGINALES
    p_num_registros     OUT NUMBER,
    p_num_paginas       OUT NUMBER,
    p_es_empresa_pub    OUT VARCHAR2,
    p_periodo_desde     OUT DATE,
    p_periodo_hasta     OUT DATE,
    p_mensaje_error     OUT VARCHAR2,
    p_codigo_retorno    OUT NUMBER
) IS

    v_per_desde             DATE;
    v_per_hasta             DATE;
    v_es_empresa_publica    VARCHAR2(1);
    v_fecha_crea_pdf        VARCHAR2(8);
    v_periodo_confuturo     VARCHAR2(6);
    v_anio_confuturo        VARCHAR2(4);
    v_mes_confuturo         VARCHAR2(2);
    v_num_registros         NUMBER;
    v_num_paginas           NUMBER;
    v_registros_por_pagina  NUMBER;
    v_ultimo_dia_mes        NUMBER;
    v_fecha_temp            DATE;
    v_count_empresa         NUMBER;
    v_count_trabajador      NUMBER;
    v_error_code            NUMBER;
    v_error_message         VARCHAR2(4000);
    v_min_periodo           DATE;
    v_max_periodo           DATE;
    v_count_periodos        NUMBER;

    -- Variables de control de paginación (migradas del ASP)
    -- regPer = 0, npag = 0, periodoAnt = trim(rsx("rec_periodo"))
    v_reg_per               NUMBER;
    v_npag                  NUMBER;
    v_periodo_ant           VARCHAR2(20);

BEGIN
    p_codigo_retorno := 0;
    p_mensaje_error := NULL;
    p_num_registros := 0;
    p_num_paginas := 0;
    p_es_empresa_pub := 'N';

    v_fecha_crea_pdf := TO_CHAR(SYSDATE, 'YYYYMMDD');

    -- Validación de parámetros de entrada (migrado del ASP)
    -- Obtiene el rut de la empresa y valida parámetros
    -- Validar RUT del trabajador
    IF p_rut_tra IS NULL OR p_rut_tra = 0 THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'RUT del trabajador es requerido';
        RETURN;
    END IF;

    -- Validar RUT de la empresa
    IF p_emp_rut IS NULL OR p_emp_rut = 0 THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'RUT de la empresa es requerido';
        RETURN;
    END IF;

    -- Validar convenio/cuenta
    IF p_cnv_cta IS NULL THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Convenio/Cuenta es requerido';
        RETURN;
    END IF;

    -- Validar operación seleccionada
    IF p_sel_op IS NULL OR p_sel_op NOT IN (1, 2, 4, 5) THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Operacion seleccionada no valida (debe ser 1, 2, 4 o 5)';
        RETURN;
    END IF;

    -- Validar año
    IF p_anio IS NULL OR p_anio < 1900 OR p_anio > EXTRACT(YEAR FROM SYSDATE) + 1 THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Ano no valido';
        RETURN;
    END IF;

    -- Validar mes (si se proporciona)
    IF p_mes IS NOT NULL AND (p_mes < 1 OR p_mes > 12) THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Mes no valido (debe estar entre 1 y 12)';
        RETURN;
    END IF;

    -- Validar año hasta (si se proporciona)
    IF p_anio_hasta IS NOT NULL AND (p_anio_hasta < 1900 OR p_anio_hasta > EXTRACT(YEAR FROM SYSDATE) + 1) THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Ano hasta no valido';
        RETURN;
    END IF;

    -- Validar mes hasta (si se proporciona)
    IF p_mes_hasta IS NOT NULL AND (p_mes_hasta < 1 OR p_mes_hasta > 12) THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Mes hasta no valido (debe estar entre 1 y 12)';
        RETURN;
    END IF;

    -- Validar tipo de contrato
    IF p_tipo_con IS NOT NULL AND p_tipo_con NOT IN (1, 2) THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Tipo de contrato no valido (debe ser 1 o 2)';
        RETURN;
    END IF;

    -- Validar impresión CCAF
    IF p_imp_ccaf IS NOT NULL AND p_imp_ccaf NOT IN ('S', 'N') THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'Parametro impresion CCAF no valido (debe ser S o N)';
        RETURN;
    END IF;

    -- Configuración de período confuturo (valores por defecto)
    v_periodo_confuturo := '201511';
    v_anio_confuturo := '2015';
    v_mes_confuturo := '11';

    -- Determina el tipo de certificado a imprimir (migrado del ASP)
    -- select case selOp
    CASE p_sel_op
        WHEN 1 THEN
            -- case 1 'Busca un año específico
            -- Per_Desde = anio & "-01-31"
            -- Per_Hasta = anio & "-12-31"
            v_per_desde := TO_DATE(p_anio || '-01-31', 'YYYY-MM-DD');
            v_per_hasta := TO_DATE(p_anio || '-12-31', 'YYYY-MM-DD');

        WHEN 2 THEN
            -- case 2 'Determina los ultimos 12 meses
            -- call ult12(ConnBd,Per_Rut, Per_Desde, Per_Hasta)
            BEGIN
                SELECT COUNT(*), MIN(REC_PERIODO), MAX(REC_PERIODO)
                INTO v_count_periodos, v_min_periodo, v_max_periodo
                FROM (
                    SELECT DISTINCT REC_PERIODO
                    FROM REC_TRABAJADOR
                    WHERE TRA_RUT = p_rut_tra
                    ORDER BY REC_PERIODO DESC
                    FETCH FIRST 12 ROWS ONLY
                );

                IF v_count_periodos > 0 THEN
                    v_per_desde := v_min_periodo;
                    v_per_hasta := v_max_periodo;
                ELSE
                    v_per_desde := NULL;
                    v_per_hasta := NULL;
                END IF;
            END;

        WHEN 4 THEN
            -- case 4 'Busca un año y mes específico (VOS 11/04/2008)
            -- Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
            -- Per_Hasta = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
            v_fecha_temp := TO_DATE(p_anio || '-' || LPAD(p_mes, 2, '0') || '-01', 'YYYY-MM-DD');
            v_ultimo_dia_mes := EXTRACT(DAY FROM (ADD_MONTHS(v_fecha_temp, 1) - 1));
            v_per_desde := TO_DATE(p_anio || '-' || LPAD(p_mes, 2, '0') || '-' || v_ultimo_dia_mes, 'YYYY-MM-DD');
            v_per_hasta := v_per_desde;

        WHEN 5 THEN
            -- case 5 'Busca un periodo específico (VOS Cert por Proc 20091007)
            -- Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
            -- Per_Hasta = anioHasta & "-" & mesHasta & "-" & UltimoDiaDeMes(mesHasta,anioHasta)
            v_fecha_temp := TO_DATE(p_anio || '-' || LPAD(p_mes, 2, '0') || '-01', 'YYYY-MM-DD');
            v_ultimo_dia_mes := EXTRACT(DAY FROM (ADD_MONTHS(v_fecha_temp, 1) - 1));
            v_per_desde := TO_DATE(p_anio || '-' || LPAD(p_mes, 2, '0') || '-' || v_ultimo_dia_mes, 'YYYY-MM-DD');

            v_fecha_temp := TO_DATE(p_anio_hasta || '-' || LPAD(p_mes_hasta, 2, '0') || '-01', 'YYYY-MM-DD');
            v_ultimo_dia_mes := EXTRACT(DAY FROM (ADD_MONTHS(v_fecha_temp, 1) - 1));
            v_per_hasta := TO_DATE(p_anio_hasta || '-' || LPAD(p_mes_hasta, 2, '0') || '-' || v_ultimo_dia_mes, 'YYYY-MM-DD');

        ELSE
            p_codigo_retorno := -1;
            p_mensaje_error := 'Tipo de operacion no valido. Valores permitidos: 1, 2, 4, 5';
            RETURN;
    END CASE;

    IF v_per_desde IS NULL OR v_per_hasta IS NULL THEN
        p_codigo_retorno := -1;
        p_mensaje_error := 'No se pudieron determinar los periodos de consulta';
        RETURN;
    END IF;

    p_periodo_desde := v_per_desde;
    p_periodo_hasta := v_per_hasta;

    -- Determinar si es empresa pública (VOS20111124)
    -- Función EsEmpresaPublica migrada del ASP
    SELECT COUNT(*) INTO v_count_empresa
    FROM REC_EMPRESA
    WHERE CON_RUT = p_emp_rut
      AND CON_CORREL = p_cnv_cta
      AND RPR_PROCESO = 2
      AND EMP_TIPO_GRATIF = 2
      AND EMP_ORDEN_IMP = 4
      AND REC_PERIODO BETWEEN v_per_desde AND v_per_hasta;

    IF v_count_empresa > 0 THEN
        v_es_empresa_publica := 'S';
        p_es_empresa_pub := 'S';
    ELSE
        v_es_empresa_publica := 'N';
        p_es_empresa_pub := 'N';
    END IF;

    -- Determinar tipo de contrato y obtener datos (migrado del ASP)
    -- VOS20111124 - Determina si llamar a SQL_TRA_DET o SQL_TRA_DET_PUB
    -- Determinar tipo de contrato basado en parámetro
    -- IF Session("USU_COD_PER") = "SI" THEN tipoCon = 2 else tipoCon = 1
    -- En Oracle usamos el parámetro p_tipo_con (default 1)

    -- Inicializar contadores para paginación
    v_num_registros := 0;
    v_num_paginas := 0;
    v_registros_por_pagina := 30; -- Equivalente a n=133 en ASP

    -- ============================================================================
    -- NUEVA SECCIÓN: LLAMAR A STORED PROCEDURES ORACLE SEGÚN TIPO DE EMPRESA
    -- Llama a PRC_REC_CERTCOT_TRAB o PRC_CERTCOT_TRAB_PUB según corresponda
    -- ============================================================================

    DECLARE
        v_cursor_datos_sp   SYS_REFCURSOR;  -- Cursor que retorna el SP llamado
    BEGIN
    -- Llamar al SP correspondiente según tipo de empresa
    IF v_es_empresa_publica = 'N' THEN
        -- Empresa privada: llamar a PRC_REC_CERTCOT_TRAB
        PRC_REC_CERTCOT_TRAB(
            p_fec_ini    => v_per_desde,
            p_fec_ter    => v_per_hasta,
            p_emp_rut    => p_emp_rut,
            p_convenio   => p_cnv_cta,
            p_rut_tra    => p_rut_tra,
            p_tipoCon    => p_tipo_con,
            p_parametro  => NULL,
            p_parametro2 => NULL,
            p_parametro3 => p_imp_ccaf,
            p_cursor     => v_cursor_datos_sp
        );
    ELSE
        -- Empresa pública: llamar a PRC_CERTCOT_TRAB_PUB
        PRC_CERTCOT_TRAB_PUB(
            p_fec_ini    => v_per_desde,
            p_fec_ter    => v_per_hasta,
            p_emp_rut    => p_emp_rut,
            p_convenio   => p_cnv_cta,
            p_rut_tra    => p_rut_tra,
            p_tipoCon    => p_tipo_con,
            p_Parametro  => NULL,
            p_parametro2 => NULL,
            p_parametro3 => p_imp_ccaf,
            p_cursor     => v_cursor_datos_sp
        );
    END IF;

        -- Contar registros del cursor retornado para validar si hay datos
        -- Nota: Manejamos diferentes estructuras de cursor según el tipo de empresa
        DECLARE
            v_rec_periodo           DATE;
            v_nro_comprobante       NUMBER(7);
            v_tipo_impre            NUMBER(1);
            v_suc_cod               VARCHAR2(6);
            v_usu_cod               VARCHAR2(6);
            v_tipo_ent              VARCHAR2(1);
            v_ent_rut               NUMBER(9);
            v_ent_nombre            VARCHAR2(255);
            v_tra_rut               NUMBER(9);
            v_tra_dig               VARCHAR2(1);
            v_tra_nombre            VARCHAR2(100);  -- Aumentado de 40 a 100 para evitar ORA-06502
            v_tra_ape               VARCHAR2(100);  -- Aumentado de 40 a 100 para evitar ORA-06502
            v_dias_trab             NUMBER(5);
            v_rem_impo              NUMBER(8);
            v_monto_cotizado        NUMBER(8);
            v_fec_pago              DATE;
            v_folio_planilla        NUMBER(10);
            v_raz_soc               VARCHAR2(100);  -- Aumentado de 40 a 100 para evitar ORA-06502
            v_salud                 NUMBER(2);
            v_monto_sis             NUMBER(8);
            v_usu_pago_retroactivo  VARCHAR2(1);  -- Solo para empresas públicas
        BEGIN
            v_num_registros := 0;

            -- Procesar cursor y contar registros según tipo de empresa
            IF v_es_empresa_publica = 'N' THEN
                -- Empresa privada: PRC_REC_CERTCOT_TRAB retorna 20 campos (sin USU_PAGO_RETROACTIVO)
                LOOP
                    FETCH v_cursor_datos_sp INTO
                        v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
                        v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig,
                        v_tra_nombre, v_tra_ape, v_dias_trab, v_rem_impo, v_monto_cotizado,
                        v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis;

                    EXIT WHEN v_cursor_datos_sp%NOTFOUND;
                    v_num_registros := v_num_registros + 1;
                END LOOP;
            ELSE
                -- Empresa pública: PRC_CERTCOT_TRAB_PUB retorna 21 campos (con USU_PAGO_RETROACTIVO)
                LOOP
                    FETCH v_cursor_datos_sp INTO
                        v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
                        v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig,
                        v_tra_nombre, v_tra_ape, v_dias_trab, v_rem_impo, v_monto_cotizado,
                        v_fec_pago, v_folio_planilla, v_raz_soc, v_salud, v_monto_sis,
                        v_usu_pago_retroactivo;

                    EXIT WHEN v_cursor_datos_sp%NOTFOUND;
                    v_num_registros := v_num_registros + 1;
                END LOOP;
            END IF;

            -- Cerrar el cursor
            CLOSE v_cursor_datos_sp;

        END; -- Fin del bloque DECLARE anidado para contar registros

        -- Verificar si no hay datos
        IF v_num_registros = 0 THEN
            p_codigo_retorno := -2;
            p_mensaje_error := 'La persona no esta asociada a la empresa.';
            p_num_registros := 0;
            p_num_paginas := 0;

            -- Abrir cursors vacíos
            OPEN p_cursor_datos FOR SELECT NULL FROM DUAL WHERE 1=0;
            OPEN p_cursor_encabezado FOR SELECT NULL FROM DUAL WHERE 1=0;
            OPEN p_cursor_metadatos FOR SELECT NULL FROM DUAL WHERE 1=0;
            RETURN;
        END IF;

        -- Calcular paginación (igual que el ASP)
        IF v_num_registros <= 30 THEN
            v_registros_por_pagina := 36;
        ELSE
            v_registros_por_pagina := 42;
        END IF;

        v_num_paginas := CEIL(v_num_registros / v_registros_por_pagina);

        p_num_registros := v_num_registros;
        p_num_paginas := v_num_paginas;

        -- Volver a llamar al SP para obtener los datos formateados para el cursor principal
        IF v_es_empresa_publica = 'N' THEN
            -- Empresa privada: llamar a PRC_REC_CERTCOT_TRAB
            PRC_REC_CERTCOT_TRAB(
                p_fec_ini    => v_per_desde,
                p_fec_ter    => v_per_hasta,
                p_emp_rut    => p_emp_rut,
                p_convenio   => p_cnv_cta,
                p_rut_tra    => p_rut_tra,
                p_tipoCon    => p_tipo_con,
                p_parametro  => NULL,
                p_parametro2 => NULL,
                p_parametro3 => p_imp_ccaf,
                p_cursor     => v_cursor_datos_sp
            );
        ELSE
            -- Empresa pública: llamar a PRC_CERTCOT_TRAB_PUB
            PRC_CERTCOT_TRAB_PUB(
                p_fec_ini    => v_per_desde,
                p_fec_ter    => v_per_hasta,
                p_emp_rut    => p_emp_rut,
                p_convenio   => p_cnv_cta,
                p_rut_tra    => p_rut_tra,
                p_tipoCon    => p_tipo_con,
                p_Parametro  => NULL,
                p_parametro2 => NULL,
                p_parametro3 => p_imp_ccaf,
                p_cursor     => v_cursor_datos_sp
            );
        END IF;

        -- 1. CURSOR DE DATOS PRINCIPALES - Usar datos del SP con formateo para PDF
        -- Migra toda la lógica de formateo del bucle DO WHILE NOT rsx.EOF del ASP
        -- IMPORTANTE: Usar directamente los datos de los SPs Oracle usando GTT

        -- Limpiar GTT antes de usar
        DELETE FROM GTT_REC_CERT_DETALLE;

        -- Variables para procesar el cursor del SP
        DECLARE
            v_rec_periodo           DATE;
            v_nro_comprobante       NUMBER(7);
            v_tipo_impre            NUMBER(1);
            v_suc_cod               VARCHAR2(6);
            v_usu_cod               VARCHAR2(6);
            v_tipo_ent              VARCHAR2(1);
            v_ent_rut               NUMBER(9);
            v_ent_nombre            VARCHAR2(100);  -- Según TBL_MISCOT_ESTRUCTURAS.sql
            v_tra_rut               NUMBER(9);
            v_tra_dig               VARCHAR2(1);
            v_tra_nombre            VARCHAR2(100); -- Según TBL_MISCOT_ESTRUCTURAS.sql
            v_tra_ape               VARCHAR2(100); -- Según TBL_MISCOT_ESTRUCTURAS.sql
            v_dias_trab             NUMBER(5);
            v_rem_impo              NUMBER(8);
            v_monto_cotizado        NUMBER(8);
            v_fec_pago              DATE;
            v_folio_planilla        NUMBER(10);
            v_raz_soc               VARCHAR2(40);
            v_salud                 NUMBER(2);
            v_monto_sis             NUMBER(8);
            v_usu_pago_retroactivo  VARCHAR2(1);

        BEGIN
            -- Cargar datos del cursor del SP en la GTT
            IF v_es_empresa_publica = 'N' THEN
                -- Empresa privada: PRC_REC_CERTCOT_TRAB retorna 20 campos (sin USU_PAGO_RETROACTIVO)
                LOOP
                    FETCH v_cursor_datos_sp INTO
                        v_rec_periodo, v_nro_comprobante, v_tipo_impre,
                        v_suc_cod, v_usu_cod, v_tipo_ent,
                        v_ent_rut, v_ent_nombre, v_tra_rut,
                        v_tra_dig, v_tra_nombre, v_tra_ape,
                        v_dias_trab, v_rem_impo, v_monto_cotizado,
                        v_fec_pago, v_folio_planilla, v_raz_soc,
                        v_salud, v_monto_sis;

                    EXIT WHEN v_cursor_datos_sp%NOTFOUND;

                    -- Para empresas privadas, establecer USU_PAGO_RETROACTIVO como 'N'
                    v_usu_pago_retroactivo := 'N';

                    -- Insertar en GTT (sin USU_PAGO_RETROACTIVO ya que la GTT no lo tiene)
                    INSERT INTO GTT_REC_CERT_DETALLE (
                        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
                        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
                        RAZ_SOC, SALUD, MONTO_SIS
                    ) VALUES (
                        v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
                        v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig, v_tra_nombre, v_tra_ape,
                        v_dias_trab, v_rem_impo, v_monto_cotizado, v_fec_pago, v_folio_planilla,
                        v_raz_soc, v_salud, v_monto_sis
                    );
                END LOOP;
            ELSE
                -- Empresa pública: PRC_CERTCOT_TRAB_PUB retorna 21 campos (con USU_PAGO_RETROACTIVO)
                LOOP
                    FETCH v_cursor_datos_sp INTO
                        v_rec_periodo, v_nro_comprobante, v_tipo_impre,
                        v_suc_cod, v_usu_cod, v_tipo_ent,
                        v_ent_rut, v_ent_nombre, v_tra_rut,
                        v_tra_dig, v_tra_nombre, v_tra_ape,
                        v_dias_trab, v_rem_impo, v_monto_cotizado,
                        v_fec_pago, v_folio_planilla, v_raz_soc,
                        v_salud, v_monto_sis, v_usu_pago_retroactivo;

                    EXIT WHEN v_cursor_datos_sp%NOTFOUND;

                    -- Insertar en GTT (sin USU_PAGO_RETROACTIVO ya que la GTT no lo tiene)
                    INSERT INTO GTT_REC_CERT_DETALLE (
                        REC_PERIODO, NRO_COMPROBANTE, TIPO_IMPRE, SUC_COD, USU_COD,
                        TIPO_ENT, ENT_RUT, ENT_NOMBRE, TRA_RUT, TRA_DIG, TRA_NOMBRE, TRA_APE,
                        DIAS_TRAB, REM_IMPO, MONTO_COTIZADO, FEC_PAGO, FOLIO_PLANILLA,
                        RAZ_SOC, SALUD, MONTO_SIS
                    ) VALUES (
                        v_rec_periodo, v_nro_comprobante, v_tipo_impre, v_suc_cod, v_usu_cod,
                        v_tipo_ent, v_ent_rut, v_ent_nombre, v_tra_rut, v_tra_dig, v_tra_nombre, v_tra_ape,
                        v_dias_trab, v_rem_impo, v_monto_cotizado, v_fec_pago, v_folio_planilla,
                        v_raz_soc, v_salud, v_monto_sis
                    );
                END LOOP;
            END IF;

            -- Cerrar el cursor
            CLOSE v_cursor_datos_sp;

            -- Abrir cursor principal con datos formateados para PDF usando GTT
            OPEN p_cursor_datos FOR
                SELECT
                    -- DATOS DE IDENTIFICACIÓN
                    d.REC_PERIODO,
                    d.TRA_RUT,
                    d.TRA_DIG,
                    TRIM(d.TRA_NOMBRE || ' ' || d.TRA_APE) AS TRABAJADOR_NOMBRE_COMPLETO,
                    d.ENT_RUT,
                    d.ENT_NOMBRE,
                    d.RAZ_SOC AS EMPRESA_RAZON_SOCIAL,

                    -- DATOS FINANCIEROS
                    d.DIAS_TRAB,
                    d.REM_IMPO,
                    d.MONTO_COTIZADO,
                    d.MONTO_SIS,
                    d.FEC_PAGO,
                    d.FOLIO_PLANILLA,
                    d.SALUD,

                    -- FORMATEO LISTO PARA PDF (igual que el ASP)
                    -- Mes formateado como "ENE-2023" (migra lógica del ASP)
                    CASE EXTRACT(MONTH FROM d.REC_PERIODO)
                        WHEN 1 THEN 'ENE-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 2 THEN 'FEB-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 3 THEN 'MAR-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 4 THEN 'ABR-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 5 THEN 'MAY-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 6 THEN 'JUN-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 7 THEN 'JUL-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 8 THEN 'AGO-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 9 THEN 'SEP-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 10 THEN 'OCT-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 11 THEN 'NOV-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                        WHEN 12 THEN 'DIC-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                    END AS MES_ANIO_FORMATEADO,

                    -- Nombres de entidad formateados (migra lógica especial del ASP)
                    CASE
                        -- Lógica especial Santa María (del ASP líneas ~400)
                        WHEN TRIM(TO_CHAR(d.ENT_RUT)) = '98000000'
                             AND (EXTRACT(YEAR FROM d.REC_PERIODO) < 2008
                                  OR (EXTRACT(YEAR FROM d.REC_PERIODO) = 2008 AND EXTRACT(MONTH FROM d.REC_PERIODO) <= 3))
                             AND TRIM(d.ENT_NOMBRE) != 'SEG. CES.'
                        THEN 'SANTA MARIA'

                        -- Lógica especial Vida Corp (del ASP VOS20151130)
                        WHEN TRIM(TO_CHAR(d.ENT_RUT)) = '96571890'
                             AND (EXTRACT(YEAR FROM d.REC_PERIODO) < TO_NUMBER(v_anio_confuturo)
                                  OR (EXTRACT(YEAR FROM d.REC_PERIODO) = TO_NUMBER(v_anio_confuturo)
                                      AND EXTRACT(MONTH FROM d.REC_PERIODO) < TO_NUMBER(v_mes_confuturo)))
                        THEN 'VIDA CORP CIA DE SEGUROS'

                        -- Caso normal - truncar a 26 caracteres como el ASP
                        ELSE SUBSTR(TRIM(d.ENT_NOMBRE), 1, 26)
                    END AS ENTIDAD_NOMBRE_FORMATEADO,

                    -- Montos formateados (reemplaza FormatCurrency del ASP)
                    TO_CHAR(d.REM_IMPO, 'FM999,999,999') AS REM_IMPO_FORMATEADO,
                    TO_CHAR(d.MONTO_COTIZADO, 'FM999,999,999') AS MONTO_COTIZADO_FORMATEADO,
                    TO_CHAR(d.MONTO_SIS, 'FM999,999,999') AS MONTO_SIS_FORMATEADO,

                    -- Fecha formateada
                    TO_CHAR(d.FEC_PAGO, 'DD/MM/YYYY') AS FECHA_PAGO_FORMATEADA,

                    -- CAMPOS ESPECÍFICOS PARA EMPRESAS PÚBLICAS
                    -- Como GTT no tiene USU_PAGO_RETROACTIVO, usamos la variable de empresa pública
                    CASE WHEN v_es_empresa_publica = 'S' THEN 'S' ELSE 'N' END AS USU_PAGO_RETROACTIVO,
                    d.TIPO_IMPRE,
                    d.USU_COD,

                    -- Mes retroactivo formateado (para empresas públicas)
                    CASE
                        WHEN v_es_empresa_publica = 'S' THEN
                            CASE EXTRACT(MONTH FROM d.REC_PERIODO)
                                WHEN 1 THEN 'ENE-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 2 THEN 'FEB-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 3 THEN 'MAR-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 4 THEN 'ABR-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 5 THEN 'MAY-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 6 THEN 'JUN-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 7 THEN 'JUL-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 8 THEN 'AGO-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 9 THEN 'SEP-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 10 THEN 'OCT-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 11 THEN 'NOV-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                                WHEN 12 THEN 'DIC-' || EXTRACT(YEAR FROM d.REC_PERIODO)
                            END
                        ELSE NULL
                    END AS MES_RETROACTIVO_FORMATEADO,

                    -- CONTROL DE PAGINACIÓN (migra variables del ASP: regPer, npag, periodoAnt)
                    ROW_NUMBER() OVER (ORDER BY d.REC_PERIODO, d.ENT_NOMBRE, d.REM_IMPO) AS NUMERO_FILA,

                    -- Detectar cambio de período para separadores (equivale a periodoAnt del ASP)
                    CASE
                        WHEN LAG(d.REC_PERIODO) OVER (ORDER BY d.REC_PERIODO, d.ENT_NOMBRE, d.REM_IMPO) != d.REC_PERIODO
                        THEN 'S'
                        ELSE 'N'
                    END AS ES_CAMBIO_PERIODO,

                    -- Información de página (migra lógica de paginación del ASP)
                    CASE
                        WHEN v_num_registros <= 30 THEN 36  -- RegHasta = 36
                        ELSE 42                             -- RegHasta = 42
                    END AS REGISTROS_POR_PAGINA,

                    -- Número de página actual
                    CEIL(ROW_NUMBER() OVER (ORDER BY d.REC_PERIODO, d.ENT_NOMBRE, d.REM_IMPO) /
                         CASE WHEN v_num_registros <= 30 THEN 36 ELSE 42 END) AS NUMERO_PAGINA

                FROM GTT_REC_CERT_DETALLE d
                ORDER BY d.REC_PERIODO, d.ENT_NOMBRE, d.REM_IMPO;

        END; -- Fin del bloque DECLARE para manejo de datos del cursor

        -- 2. CURSOR DE ENCABEZADO - Datos para el header del PDF (migra Encabezado y Encabezado_Pub del ASP)
        OPEN p_cursor_encabezado FOR
            SELECT
                -- DATOS DEL TRABAJADOR
                p_rut_tra AS TRABAJADOR_RUT,
                -- Obtener datos del trabajador desde las tablas base en lugar de GTT
                (SELECT TRA_DIGITO FROM REC_TRABAJADOR WHERE TRA_RUT = p_rut_tra AND ROWNUM = 1) AS TRABAJADOR_DV,
                (SELECT TRIM(TRA_NOMTRA || ' ' || TRA_APETRA) FROM REC_TRABAJADOR WHERE TRA_RUT = p_rut_tra AND ROWNUM = 1) AS TRABAJADOR_NOMBRE,

                -- DATOS DE LA EMPRESA
                p_emp_rut AS EMPRESA_RUT,
                (SELECT EMP_DIGITO FROM REC_EMPRESA WHERE CON_RUT = p_emp_rut AND CON_CORREL = p_cnv_cta AND ROWNUM = 1) AS EMPRESA_DV,
                (SELECT EMP_RAZSOC FROM REC_EMPRESA WHERE CON_RUT = p_emp_rut AND CON_CORREL = p_cnv_cta AND ROWNUM = 1) AS EMPRESA_RAZON_SOCIAL,

                -- PERÍODOS
                TO_CHAR(v_per_desde, 'DD/MM/YYYY') AS PERIODO_DESDE_FORMATEADO,
                TO_CHAR(v_per_hasta, 'DD/MM/YYYY') AS PERIODO_HASTA_FORMATEADO,

                -- TIPO DE CERTIFICADO (migra lógica del ASP)
                CASE p_sel_op
                    WHEN 1 THEN 'CERTIFICADO ANUAL ' || p_anio
                    WHEN 2 THEN 'CERTIFICADO ULTIMOS 12 MESES'
                    WHEN 4 THEN 'CERTIFICADO MENSUAL ' ||
                                CASE p_mes
                                    WHEN 1 THEN 'ENERO'
                                    WHEN 2 THEN 'FEBRERO'
                                    WHEN 3 THEN 'MARZO'
                                    WHEN 4 THEN 'ABRIL'
                                    WHEN 5 THEN 'MAYO'
                                    WHEN 6 THEN 'JUNIO'
                                    WHEN 7 THEN 'JULIO'
                                    WHEN 8 THEN 'AGOSTO'
                                    WHEN 9 THEN 'SEPTIEMBRE'
                                    WHEN 10 THEN 'OCTUBRE'
                                    WHEN 11 THEN 'NOVIEMBRE'
                                    WHEN 12 THEN 'DICIEMBRE'
                                    ELSE TO_CHAR(p_mes)
                                END || ' ' || p_anio
                    WHEN 5 THEN 'CERTIFICADO PERIODO ESPECIFICO'
                    ELSE 'CERTIFICADO DE COTIZACIONES'
                END AS TITULO_CERTIFICADO,

                -- FLAGS DE CONFIGURACIÓN
                v_es_empresa_publica AS ES_EMPRESA_PUBLICA,
                p_imp_ccaf AS IMPRIMIR_CCAF,
                p_tipo_con AS TIPO_CONTRATO,

                -- FECHA ACTUAL
                TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS FECHA_EMISION,
                v_fecha_crea_pdf AS FECHA_ARCHIVO,

                -- TEXTO LEGAL (del ASP - migra texto de validación jurídica)
                'Certificado juridicamente valido para cumplir con la exigencia contenida en el Articulo 31 del D.F.L. N 2, de 1967, Ley Organica de la Direccion del Trabajo (ORD. N 2460 del 27 Junio de 2003)' AS TEXTO_LEGAL
            FROM DUAL;

        -- 3. CURSOR DE METADATOS - Información para paginación y control (migra variables del ASP)
        OPEN p_cursor_metadatos FOR
            SELECT
                v_num_registros AS TOTAL_REGISTROS,
                v_num_paginas AS TOTAL_PAGINAS,
                CASE WHEN v_num_registros <= 30 THEN 36 ELSE 42 END AS REGISTROS_POR_PAGINA,
                v_es_empresa_publica AS ES_EMPRESA_PUBLICA,

                -- COLUMNAS PARA EMPRESA PÚBLICA vs PRIVADA (migra diferencias de layout del ASP)
                CASE WHEN v_es_empresa_publica = 'S' THEN 'S' ELSE 'N' END AS MOSTRAR_COLUMNA_MES_RETRO,

                -- ANCHOS DE COLUMNAS (migrado del ASP - diferentes layouts)
                CASE WHEN v_es_empresa_publica = 'S' THEN
                    '120,42,21,55,45,45,50,45,92,42'  -- Empresa pública con columna Mes Retro
                ELSE
                    '120,47,25,55,45,45,50,45,125'    -- Empresa privada sin Mes Retro
                END AS ANCHOS_COLUMNAS,

                -- HEADERS DE COLUMNAS (migra headers del ASP)
                CASE WHEN v_es_empresa_publica = 'S' THEN
                    'Institucion de Prevision|Mes y ano Renta|Dias Trab.|Remuneracion Imponible|Monto Cotizado|Monto S.I.S.|Fecha de pago|N folio planilla|Empleador|Mes Retro'
                ELSE
                    'Institucion de Prevision|Mes y ano Renta|Dias Trab.|Remuneracion Imponible|Monto Cotizado|Monto S.I.S.|Fecha de pago|N folio planilla|Empleador'
                END AS HEADERS_COLUMNAS,

                -- CONFIGURACIÓN DE FORMATO PDF (migra configuración del ASP)
                'Arial' AS FUENTE_DATOS,
                8 AS TAMAÑO_FUENTE_DATOS,
                'Arial' AS FUENTE_HEADERS,
                9 AS TAMAÑO_FUENTE_HEADERS,
                'Arial Bold' AS FUENTE_TITULO,
                12 AS TAMAÑO_FUENTE_TITULO,

                -- COLORES (migra configuración visual del ASP)
                'RGB(0,0,0)' AS COLOR_TEXTO,
                'RGB(192,192,192)' AS COLOR_LINEAS,
                'RGB(255,255,255)' AS COLOR_FONDO,

                -- MÁRGENES Y DIMENSIONES
                20 AS MARGEN_IZQUIERDO,
                20 AS MARGEN_DERECHO,
                30 AS MARGEN_SUPERIOR,
                20 AS MARGEN_INFERIOR,

                -- INFORMACIÓN ADICIONAL
                'CAJA LOS ANDES' AS NOMBRE_INSTITUCION,
                'Sistema de Certificados de Cotizaciones' AS NOMBRE_SISTEMA
            FROM DUAL;

        -- ACTUALIZAR CONTADOR DE CERTIFICADOS GENERADOS (migra del ASP)
        -- Equivale a: sqlStrCant = "EXEC sp_actCertCot_generados '" & sFechaCreaPdf & "'"
        -- COMENTADO: La tabla REC_CERTIFICADOS_GENERADOS no existe en Oracle
        /*
        UPDATE REC_CERTIFICADOS_GENERADOS
        SET CANTIDAD = CANTIDAD + 1,
            FECHA_ULT_ACTUALIZACION = SYSDATE
        WHERE FECHA_GENERACION = TO_DATE(v_fecha_crea_pdf, 'YYYYMMDD');

        IF SQL%ROWCOUNT = 0 THEN
            INSERT INTO REC_CERTIFICADOS_GENERADOS (FECHA_GENERACION, CANTIDAD, FECHA_ULT_ACTUALIZACION)
            VALUES (TO_DATE(v_fecha_crea_pdf, 'YYYYMMDD'), 1, SYSDATE);
        END IF;
        */

        COMMIT;

    -- Si llegamos aquí, todo fue exitoso
    p_codigo_retorno := 0;
    p_mensaje_error := NULL;

    END; -- Fin del BEGIN interno del bloque DECLARE

END PRC_GENERAR_CERTCOT_CERTIFICADOCOTPREV;
