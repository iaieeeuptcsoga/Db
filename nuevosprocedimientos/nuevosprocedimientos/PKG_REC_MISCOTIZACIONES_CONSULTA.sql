-------------------------------DECLARACION PAQUETE-----------------------------------------------
CREATE OR REPLACE PACKAGE X0DESPFA.PKG_REC_MISCOTIZACIONES_CONSULTA AS
    
PROCEDURE PRC_REC_CERTCOT_SIL (
    p_fec_ini   IN DATE,
    p_fec_ter   IN DATE,
    p_emp_rut   IN NUMBER,
    p_convenio  IN NUMBER,
    p_rut_tra   IN NUMBER,
    p_cursor    OUT SYS_REFCURSOR
    );

	PROCEDURE PRC_REC_CCAF_SIL (
	    p_anio          IN NUMBER,
	    p_mes           IN NUMBER,
	    p_cnvcta        IN NUMBER,
	    p_procemp       IN NUMBER,
	    p_numcomp       IN NUMBER,
	    p_rutent        IN NUMBER,
	    p_tipocorte     IN NUMBER,
	    p_tipoimp       IN NUMBER,
	    p_rutemp        IN NUMBER,
	    p_cabecera      OUT SYS_REFCURSOR,
	    p_detalle       OUT SYS_REFCURSOR
	);
	
	PROCEDURE PRC_REC_CCAF_REMUGRATI (
    p_anio             IN NUMBER,
    p_mes              IN NUMBER,
    p_con_rut          IN NUMBER,
    p_con_correl       IN NUMBER,
    p_rpr_proceso      IN NUMBER,
    p_nro_comprobante  IN NUMBER,
    p_tipo_corte       IN NUMBER,
    p_cod_corte        IN NUMBER,
    p_ent_rut          IN NUMBER,
    p_cursor_cabecera  OUT SYS_REFCURSOR,
    p_cursor_detalle   OUT SYS_REFCURSOR
);

END PKG_REC_MISCOTIZACIONES_CONSULTA;


-------------------------------------------CUERPO PAQUETE-------------------------------------------------


CREATE OR REPLACE PACKAGE BODY X0DESPFA.PKG_REC_MISCOTIZACIONES_CONSULTA AS

    PROCEDURE PRC_REC_CERTCOT_SIL (
    p_fec_ini   IN DATE,
    p_fec_ter   IN DATE,
    p_emp_rut   IN NUMBER,
    p_convenio  IN NUMBER,
    p_rut_tra   IN NUMBER,
    p_cursor    OUT SYS_REFCURSOR
)
IS

    v_tipoImp   NUMBER(1);
    v_periodo   DATE;
    v_numComp   NUMBER(7);

    CURSOR tra_cursor IS
        SELECT DISTINCT rec_periodo, tipo_impre, nro_comprobante FROM GTT_REC_CERT_DET;
BEGIN
    -- Inserta en GTT_REC_TRA
    INSERT INTO GTT_REC_TRA
    SELECT 
        t.rec_periodo,
        t.con_rut,
        t.con_correl,
        t.rpr_proceso,
        t.nro_comprobante,
        t.SUC_CODIGO,
        t.usu_codigo,
        t.tra_rut,
        t.TRA_DIGITO,
        t.TRA_NOMTRA,
        t.TRA_APETRA,
        t.TRA_REM_IMPONIBLE,
        t.tra_rem_imponible_fc,
        t.tra_nro_dias_trab,
        t.tra_fecinisub,
        t.tra_fectersub,
        t.TRA_REG_PREVIS,
        t.TRA_REG_SALUD,
        e.EMP_ORDEN_IMP,
        p.PAG_FECPAG,
        e.emp_ccaf_adh,
        e.EMP_RAZSOC,
        t.TRA_ISADES
    FROM rec_trabajador t
    JOIN rec_empresa e ON e.rec_periodo = t.rec_periodo AND e.con_rut = t.con_rut AND e.con_correl = t.con_correl AND e.rpr_proceso = t.rpr_proceso AND e.nro_comprobante = t.nro_comprobante
    JOIN rec_pago p ON p.rec_periodo = e.rec_periodo AND p.con_rut = e.con_rut AND p.con_correl = e.con_correl AND p.rpr_proceso = e.rpr_proceso AND p.nro_comprobante = e.nro_comprobante
    WHERE t.rec_periodo BETWEEN p_fec_ini AND p_fec_ter
      AND t.con_rut = p_emp_rut
      AND t.con_correl = p_convenio
      AND t.rpr_proceso = 5
      AND t.tra_rut = p_rut_tra
      AND (t.TRA_REG_SALUD <> 90 OR t.TRA_REG_PREVIS <> 90)
      AND p.PAG_TRASPASO = 1
      AND p.RET_ESTADO = 5;

    -- AFP
    INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'A', a.ent_rut, a.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, taf.AFP_COT_OBLIGATORIA, vt.fec_pago, NULL, vt.raz_soc, NULL, 0
    FROM GTT_REC_TRA vt
    JOIN rec_traafp taf ON vt.rec_periodo = taf.rec_periodo AND vt.con_rut = taf.con_rut AND vt.con_correl = taf.con_correl
                     AND vt.nro_comprobante = taf.nro_comprobante AND vt.suc_cod = taf.USU_CODIGO AND vt.usu_codigo = taf.usu_codigo AND vt.tra_rut = taf.tra_rut
    JOIN VIS_REC_AFPS a ON vt.prevision = a.ent_codificacion AND taf.ent_rut = a.ent_rut
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.prevision > 0;

    -- INP
    INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'A', i.ent_rut, i.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, tinp.INP_COT_PREV, vt.fec_pago, NULL, vt.raz_soc, NULL, 0
    FROM GTT_REC_TRA vt
    JOIN REC_TRAINP tinp ON vt.rec_periodo = tinp.rec_periodo AND vt.con_rut = tinp.con_rut AND vt.con_correl = tinp.con_correl
                     AND vt.nro_comprobante = tinp.nro_comprobante AND vt.suc_cod = tinp.SUC_CODIGO AND vt.usu_codigo = tinp.USU_CODIGO AND vt.tra_rut = tinp.tra_rut
    JOIN VIS_REC_INP i ON vt.prevision = i.ent_codificacion AND tinp.ent_rut = i.ent_rut
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.prevision = 0;

    -- INPCCAF
    INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'A', i.ent_rut, i.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, tinpc.inc_cot_prev, vt.fec_pago, NULL, vt.raz_soc, NULL, 0
    FROM GTT_REC_TRA vt
    JOIN REC_TRAINPCCAF tinpc ON vt.rec_periodo = tinpc.rec_periodo AND vt.con_rut = tinpc.con_rut AND vt.con_correl = tinpc.con_correl
                          AND vt.nro_comprobante = tinpc.nro_comprobante AND vt.suc_cod = tinpc.SUC_CODIGO AND vt.usu_codigo = tinpc.USU_CODIGO AND vt.tra_rut = tinpc.tra_rut
    JOIN VIS_REC_INP i ON vt.prevision = i.ent_codificacion AND tinpc.ent_rut = i.ent_rut
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.prevision = 0;

    -- FONASA
    INSERT INTO GTT_REC_CERT_DET
     SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'B', tinp.ent_rut, isap.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, tinp.INP_COT_FONASA, vt.fec_pago, NULL, vt.raz_soc, NULL, vt.salud
    FROM GTT_REC_TRA vt
    JOIN REC_TRAINP tinp ON vt.rec_periodo = tinp.rec_periodo AND vt.con_rut = tinp.con_rut AND vt.con_correl = tinp.con_correl
                     AND vt.nro_comprobante = tinp.nro_comprobante AND vt.suc_cod = tinp.SUC_CODIGO AND vt.usu_codigo = tinp.USU_CODIGO AND vt.tra_rut = tinp.tra_rut
    JOIN VIS_REC_ISAPRES isap ON vt.salud = isap.ent_codificacion
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.salud = 0;

    -- ISAPRE (con INPCCAF)
    INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'B', tinpc.ent_rut, isap.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, tinpc.inc_cot_fonasa, vt.fec_pago, NULL, vt.raz_soc, NULL, vt.salud
    FROM GTT_REC_TRA vt
    JOIN REC_TRAINPCCAF tinpc ON vt.rec_periodo = tinpc.rec_periodo AND vt.con_rut = tinpc.con_rut AND vt.con_correl = tinpc.con_correl
                          AND vt.nro_comprobante = tinpc.nro_comprobante AND vt.suc_cod = tinpc.SUC_CODIGO AND vt.usu_codigo = tinpc.USU_CODIGO AND vt.tra_rut = tinpc.tra_rut
    JOIN VIS_REC_ISAPRES isap ON vt.salud = isap.ent_codificacion
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.salud = 0;

    -- ISAPRE con destino
    INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'B', isap.ent_rut, isap.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, tra.ISA_COT_APAGAR, vt.fec_pago, NULL, vt.raz_soc, vt.tra_isa_dest, vt.salud
    FROM GTT_REC_TRA vt
    JOIN REC_TRAISA  tra ON vt.rec_periodo = tra.rec_periodo AND vt.con_rut = tra.con_rut AND vt.con_correl = tra.con_correl
                        AND vt.nro_comprobante = tra.nro_comprobante AND vt.suc_cod = tra.SUC_CODIGO AND vt.usu_codigo = tra.USU_CODIGO AND vt.tra_rut = tra.tra_rut
    JOIN VIS_REC_ISAPRES isap ON vt.salud = isap.ent_codificacion AND tra.ent_rut = isap.ent_rut
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.salud > 0;

    -- CCAF
     INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'C', c.ent_rut, c.ENT_NOMBRE,
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, tccaf.CCAF_SALUD, vt.fec_pago, NULL, vt.raz_soc, NULL, 0
    FROM GTT_REC_TRA vt
    JOIN REC_TRACCAF tccaf ON vt.rec_periodo = tccaf.rec_periodo AND vt.con_rut = tccaf.con_rut AND vt.con_correl = tccaf.con_correl
                        AND vt.nro_comprobante = tccaf.nro_comprobante AND vt.suc_cod = tccaf.SUC_CODIGO AND vt.usu_codigo = tccaf.USU_CODIGO AND vt.tra_rut = tccaf.tra_rut
    JOIN VIS_REC_CAJAS c ON tccaf.ent_rut = c.ent_rut
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra;

    -- Cesantía
    INSERT INTO GTT_REC_CERT_DET
    SELECT vt.rec_periodo, vt.nro_comprobante, vt.tipo_impre, vt.suc_cod, vt.usu_codigo, 'D', a.ent_rut, 'SEG. CES.',
           vt.tra_rut, vt.tra_dig, vt.tra_nombre, vt.tra_ape, vt.dias_trab, vt.fec_inisub, vt.fec_tersub,
           vt.rem_impo, taf.AFP_FONDO_CESANTIA, vt.fec_pago, NULL, vt.raz_soc, NULL, 0
    FROM GTT_REC_TRA vt
    JOIN REC_TRAAFP taf ON vt.rec_periodo = taf.rec_periodo AND vt.con_rut = taf.con_rut AND vt.con_correl = taf.con_correl
                     AND vt.nro_comprobante = taf.nro_comprobante AND vt.suc_cod = taf.SUC_CODIGO AND vt.usu_codigo = taf.USU_CODIGO AND vt.tra_rut = taf.tra_rut
    JOIN VIS_REC_AFPS a ON vt.prevision = a.ent_codificacion AND taf.ent_rut = a.ent_rut
    WHERE vt.rec_periodo BETWEEN p_fec_ini AND p_fec_ter AND vt.con_rut = p_emp_rut AND vt.con_correl = p_convenio
      AND vt.rpr_proceso = 5 AND vt.tra_rut = p_rut_tra AND vt.rem_impo_fc IS NOT NULL AND vt.rem_impo_fc <> 0;

    -- Cursor y lógica
    OPEN tra_cursor;
    LOOP
        FETCH tra_cursor INTO v_periodo, v_tipoImp, v_numComp;
        EXIT WHEN tra_cursor%NOTFOUND;

        IF v_tipoImp IN (0, 1, 2) THEN
            INSERT INTO GTT_REC_PLANILLA
            SELECT vt.rec_periodo, vt.nro_comprobante, pl.ent_rut, pl.pla_nro_serie, vt.suc_cod, vt.usu_cod
            FROM REC_PLANILLA pl
            JOIN GTT_REC_CERT_DET vt ON pl.rec_periodo = vt.rec_periodo AND pl.nro_comprobante = vt.nro_comprobante AND pl.ent_rut = vt.ent_rut
            WHERE vt.rec_periodo = v_periodo AND vt.tipo_impre = v_tipoImp AND vt.nro_comprobante = v_numComp;

        ELSIF v_tipoImp = 3 THEN
            INSERT INTO GTT_REC_PLANILLA
            SELECT vt.rec_periodo, vt.nro_comprobante, pl.ent_rut, pl.pla_nro_serie, vt.suc_cod, vt.usu_cod
            FROM REC_PLANILLA pl
            JOIN GTT_REC_CERT_DET vt ON pl.rec_periodo = vt.rec_periodo AND pl.nro_comprobante = vt.nro_comprobante AND pl.suc_codigo = vt.suc_cod AND pl.ent_rut = vt.ent_rut
            WHERE vt.rec_periodo = v_periodo AND vt.tipo_impre = v_tipoImp AND vt.nro_comprobante = v_numComp;

        ELSIF v_tipoImp = 4 THEN
            INSERT INTO GTT_REC_PLANILLA
            SELECT vt.rec_periodo, vt.nro_comprobante, pl.ent_rut, pl.pla_nro_serie, vt.suc_cod, vt.usu_cod
            FROM REC_PLANILLA pl
            JOIN GTT_REC_CERT_DET vt ON pl.rec_periodo = vt.rec_periodo AND pl.nro_comprobante = vt.nro_comprobante AND pl.usu_codigo = vt.usu_cod AND pl.ent_rut = vt.ent_rut
            WHERE vt.rec_periodo = v_periodo AND vt.tipo_impre = v_tipoImp AND vt.nro_comprobante = v_numComp;
        END IF;
    END LOOP;
    CLOSE tra_cursor;

    -- Actualización
    UPDATE GTT_REC_CERT_DET cd
    SET folio_planilla = (
        SELECT p.pla_nro_serie
        FROM GTT_REC_PLANILLA p
        WHERE p.rec_periodo = cd.rec_periodo
          AND p.nro_comprobante = cd.nro_comprobante
          AND p.ent_rut = cd.ent_rut
          AND p.suc_cod = cd.suc_cod
          AND p.usu_cod = cd.usu_cod
    );

 OPEN p_cursor FOR
    SELECT *
    FROM GTT_REC_CERT_DET
    ORDER BY rec_periodo, tipo_ent, suc_cod, usu_cod;
END PRC_REC_CERTCOT_SIL;



PROCEDURE PRC_REC_CCAF_SIL (
	    p_anio          IN NUMBER,
	    p_mes           IN NUMBER,
	    p_cnvcta        IN NUMBER,
	    p_procemp       IN NUMBER,
	    p_numcomp       IN NUMBER,
	    p_rutent        IN NUMBER,
	    p_tipocorte     IN NUMBER,
	    p_tipoimp       IN NUMBER,
	    p_rutemp        IN NUMBER,
	    p_cabecera      OUT SYS_REFCURSOR,
	    p_detalle       OUT SYS_REFCURSOR
	)
	IS
BEGIN
    -- Cursor para la CABECERA (solo una fila)
    OPEN p_cabecera FOR
        

SELECT 
       REC_PLANILLA.pla_nro_serie,
       TO_NUMBER(TO_CHAR(REC_PAGO.rec_periodo, 'MM')) AS mes,
       TO_NUMBER(TO_CHAR(REC_PAGO.rec_periodo, 'YYYY')) AS ano,
       REC_EMPRESA.emp_rut,
       REC_EMPRESA.EMP_DIGITO,
       REC_EMPRESA.EMP_ACTECO,
       REC_EMPRESA.EMP_RAZSOC,
       REC_EMPRESA.EMP_DIRECC || ' ' || REC_EMPRESA.EMP_NUMERO || ' ' || REC_EMPRESA.EMP_LOCAL AS EMP_DIRECC,
       REC_EMPRESA.EMP_TELEFONO,
       REC_EMPRESA.EMP_RUT_REPR,
       REC_EMPRESA.EMP_DIGITO_REPR,
       REC_EMPRESA.EMP_APE_REPR,
       REC_EMPRESA.EMP_NOM_REPR,
       REC_EMPRESA.emp_numero,
       REC_EMPRESA.emp_local,
       REC_EMPRESA.emp_comuna,
       REC_EMPRESA.emp_ciudad,
       REC_EMPRESA.EMP_MUTUAL_ADH,
       VIS_REC_CAJAS.ENT_NOMBRE,
       CASE WHEN p_tipoimp = 3 THEN REC_PLANILLA.suc_codigo ELSE NULL END AS suc_codigo,
       CASE WHEN p_tipoimp = 4 THEN REC_PLANILLA.usu_codigo ELSE NULL END AS usu_codigo
FROM REC_TRABAJADOR
JOIN REC_EMPRESA ON REC_TRABAJADOR.rec_periodo = REC_EMPRESA.rec_periodo
                AND REC_TRABAJADOR.con_rut = REC_EMPRESA.con_rut
                AND REC_TRABAJADOR.con_correl = REC_EMPRESA.con_correl
                AND REC_TRABAJADOR.rpr_proceso = REC_EMPRESA.rpr_proceso
                AND REC_TRABAJADOR.nro_comprobante = REC_EMPRESA.nro_comprobante
JOIN REC_PAGO ON REC_EMPRESA.rec_periodo = REC_PAGO.rec_periodo
             AND REC_EMPRESA.nro_comprobante = REC_PAGO.nro_comprobante
             AND REC_EMPRESA.con_rut = REC_PAGO.con_rut
             AND REC_EMPRESA.con_correl = REC_PAGO.con_correl
             AND REC_EMPRESA.rpr_proceso = REC_PAGO.rpr_proceso
JOIN REC_PLANILLA ON REC_TRABAJADOR.rec_periodo = REC_PLANILLA.rec_periodo
                 AND REC_TRABAJADOR.nro_comprobante = REC_PLANILLA.nro_comprobante
JOIN VIS_REC_CAJAS ON REC_PLANILLA.ent_rut = VIS_REC_CAJAS.ent_rut
         AND REC_TRABAJADOR.tra_codigo_ccaf = VIS_REC_CAJAS.ent_codificacion
WHERE REC_EMPRESA.con_rut = p_rutemp
  AND REC_EMPRESA.con_correl = p_cnvcta
  AND REC_EMPRESA.rpr_proceso = p_procemp
  AND REC_TRABAJADOR.rec_periodo BETWEEN TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD')
                                     AND LAST_DAY(TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD'))
  AND VIS_REC_CAJAS.ent_rut = p_rutent
  AND REC_TRABAJADOR.TRA_REG_SALUD = 0
  AND (
    (p_tipoimp = 3 AND REC_TRABAJADOR.SUC_CODIGO = p_tipocorte)
    OR p_tipoimp != 3
  )
FETCH FIRST 1 ROWS ONLY;

    -- Cursor para el DETALLE de trabajadores (varias filas)
    OPEN p_detalle FOR
        SELECT 
    T.tra_rut,
    T.TRA_DIGITO,
    T.TRA_APETRA || ' ' || T.TRA_NOMTRA AS nom_tra,
    T.tra_des_nacionalidad AS nac,
    T.TRA_REM_IMPONIBLE,
    T.TRA_REG_SALUD,
    CCAF.CCAF_SALUD,
    T.tra_nro_dias_trab AS dias,
    T.tra_nro_car_sim AS cs,
    T.tra_nro_car_inv AS ci,
    T.tra_nro_car_mat AS cm,
    T.tra_mto_asig_fam,
    TO_CHAR(T.tra_fecinisub, 'DD/MM/YYYY') AS tra_fecinisub,
    TO_CHAR(T.tra_fectersub, 'DD/MM/YYYY') AS tra_fectersub
FROM REC_TRABAJADOR T
JOIN REC_TRACCAF CCAF ON T.rec_periodo = CCAF.rec_periodo
                     AND T.con_rut = CCAF.con_rut
                     AND T.con_correl = CCAF.con_correl
                     AND T.tra_rut = CCAF.tra_rut
                     AND T.SUC_CODIGO = CCAF.SUC_CODIGO
                     AND T.rpr_proceso = CCAF.rpr_proceso
                     AND T.nro_comprobante = CCAF.nro_comprobante
                     AND T.usu_codigo = CCAF.USU_CODIGO
JOIN REC_EMPRESA E ON T.rec_periodo = E.rec_periodo
                  AND T.con_rut = E.con_rut
                  AND T.con_correl = E.con_correl
                  AND T.rpr_proceso = E.rpr_proceso
                  AND T.nro_comprobante = E.nro_comprobante
JOIN REC_PLANILLA P ON T.rec_periodo = P.rec_periodo
                   AND T.nro_comprobante = P.nro_comprobante
JOIN VIS_REC_CAJAS C ON P.ent_rut = C.ent_rut
            AND T.tra_codigo_ccaf = C.ent_codificacion
WHERE E.con_rut = p_rutemp
  AND E.con_correl = p_cnvcta
  AND E.rpr_proceso = p_procemp
  AND T.rec_periodo BETWEEN TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD')
                        AND LAST_DAY(TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD'))
  AND C.ent_rut = p_rutent
  AND T.TRA_REG_SALUD = 0
  AND (
    (p_tipoimp = 3 AND T.SUC_CODIGO = p_tipocorte)
    OR p_tipoimp != 3
  ) AND T.TRA_RUT='17717840'
ORDER BY T.TRA_APETRA, T.TRA_NOMTRA, T.tra_fecinisub;
      
END PRC_REC_CCAF_SIL;


 PROCEDURE PRC_REC_CCAF_REMUGRATI (
    p_anio             IN NUMBER,
    p_mes              IN NUMBER,
    p_con_rut          IN NUMBER,
    p_con_correl       IN NUMBER,
    p_rpr_proceso      IN NUMBER,
    p_nro_comprobante  IN NUMBER,
    p_tipo_corte       IN NUMBER,
    p_cod_corte        IN NUMBER,
    p_ent_rut          IN NUMBER,
    p_cursor_cabecera  OUT SYS_REFCURSOR,
    p_cursor_detalle   OUT SYS_REFCURSOR
)
IS
    v_periodo DATE;
    v_multi_ccaf NUMBER;
    v_per_sucdu VARCHAR2(10);
    v_per_new_rem VARCHAR2(10);
    v_anio_sucdu VARCHAR2(4);
    v_mes_sucdu VARCHAR2(2);
    v_anio_new_rem VARCHAR2(4);
    v_mes_new_rem VARCHAR2(2);
BEGIN
    v_periodo := TO_DATE(p_anio || '-' || p_mes || '-01', 'YYYY-MM-DD');

    -- Determinar si es MultiCCAF
    SELECT NVL(EMP_MULTICCAF, 0)
    INTO v_multi_ccaf
    FROM REC_EMPRESA
    WHERE REC_PERIODO = LAST_DAY(v_periodo)
      AND CON_RUT = p_con_rut
      AND CON_CORREL = p_con_correl
      AND RPR_PROCESO = p_rpr_proceso
      AND NRO_COMPROBANTE = p_nro_comprobante;

    -- Obtener periodos de configuración
    --v_per_sucdu := get_per_ini_una_pla_sucdu();
    --v_per_new_rem := get_per_ini_nuevas_remu();
    
    v_per_sucdu := '201206';
    v_per_new_rem := '';

    v_anio_sucdu := SUBSTR(v_per_sucdu, 1, 4);
    v_mes_sucdu  := SUBSTR(v_per_sucdu, 5, 2);
    v_anio_new_rem := SUBSTR(v_per_new_rem, 1, 4);
    v_mes_new_rem  := SUBSTR(v_per_new_rem, 5, 2);

    -- Cursor cabecera
    OPEN p_cursor_cabecera FOR
        SELECT E.EMP_RAZSOC AS razon_social,
           E.CON_RUT AS rut_empleador,
           E.CON_CORREL AS convenio,
           TO_CHAR(E.REC_PERIODO, 'MM-YYYY') AS periodo,
           C.ENT_NOMBRE AS caja_nombre,
           P.PLA_NRO_SERIE AS folio
    FROM REC_EMPRESA E
    JOIN REC_PLANILLA P ON P.REC_PERIODO = E.REC_PERIODO
                   AND P.NRO_COMPROBANTE = E.NRO_COMPROBANTE
    JOIN VIS_REC_CAJAS C ON C.ENT_RUT = P.ENT_RUT
    WHERE E.REC_PERIODO = LAST_DAY(v_periodo)
      AND E.CON_RUT = p_con_rut
      AND E.CON_CORREL = p_con_correl
      AND E.NRO_COMPROBANTE = p_nro_comprobante;

   
    -- Cursor detalle según si es MultiCCAF
    IF v_multi_ccaf = 0 THEN
        p_cursor_detalle := X0DESPFA.FNC_DET_CCAF(
            p_anio, p_mes, p_con_rut, p_con_correl, p_rpr_proceso,
            p_nro_comprobante, p_tipo_corte, p_cod_corte,
            v_anio_sucdu, v_mes_sucdu,
            v_anio_new_rem, v_mes_new_rem
        );
    ELSE
        p_cursor_detalle := X0DESPFA.FNC_DET_CCAF_MULTICCAF(
            p_anio, p_mes, p_con_rut, p_con_correl, p_rpr_proceso,
            p_nro_comprobante, p_tipo_corte, p_cod_corte,
            v_anio_sucdu, v_mes_sucdu,
            v_anio_new_rem, v_mes_new_rem, p_ent_rut
        );
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        OPEN p_cursor_cabecera FOR SELECT NULL AS razon_social FROM dual;
        OPEN p_cursor_detalle FOR SELECT NULL AS detalle FROM dual WHERE 1=0;
END PRC_REC_CCAF_REMUGRATI;


END PKG_REC_MISCOTIZACIONES_CONSULTA;