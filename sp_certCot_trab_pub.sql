CREATE procedure sp_certCot_trab_pub @fec_ini datetime, @fec_ter datetime, @emp_rut numeric(9),
				@convenio numeric(3),@rut_tra numeric(9), @tipoCon numeric,
				@Parametro varchar(10) = Null,
				@parametro2 varchar(10) = Null,
                                                     @parametro3 varchar(1) = Null
as 

SET NOCOUNT ON

declare @tipoImp numeric(1)
declare @periodo datetime 
declare @nomTra varchar(40)
declare @apeTra varchar(40)

--Creación de tablas virtuales
-- VOS agrego rem_imp_afp numeric(8),
declare @vir_tra table(
	rec_periodo datetime not null,
	con_rut numeric(9) not null,
	con_correl numeric(3) not null,
	rpr_proceso numeric(1) not null,
	nro_comprobante numeric(7) not null,
	suc_cod varchar(6) collate SQL_Latin1_General_CP1_CI_AS not null,
	usu_codigo varchar(6) collate SQL_Latin1_General_CP1_CI_AS not null,
	tra_rut numeric(9) not null,
	tra_dig varchar(1) collate SQL_Latin1_General_CP1_CI_AS,
	tra_nombre varchar(40) collate SQL_Latin1_General_CP1_CI_AS ,
	tra_ape varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	rem_impo numeric(8),
             rem_imp_afp numeric(8),
	rem_impo_inp numeric(8),
	rem_impo_fc numeric(8),
	rem_impo_depconv numeric(8),
	dias_trab numeric(5),
	prevision numeric(2),
	salud numeric(2),
	ent_afc numeric(2),
	tipo_impre numeric(1),
	fec_pago datetime,
	ccaf_adh numeric(2),
	mut_adh numeric(2),
	tasa_cot_mut numeric(6,3),
	tasa_adic_mut numeric(6,3),
	raz_soc varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	tra_isa_dest numeric(2),
	tra_tipo_apv numeric(2),
	tra_ins_apv numeric(2),
        usu_pago_retroactivo varchar(1) collate SQL_Latin1_General_CP1_CI_AS,
        rem_impo_ccaf numeric(8),
       	rem_impo_isa  numeric(8),
        rem_impo_mutual numeric(8)
)

-- VOS agrego rem_imp_afp numeric(8),
declare @vir_tra2 table(
	rec_periodo datetime not null,
	con_rut numeric(9) not null,
	con_correl numeric(3) not null,
	rpr_proceso numeric(1) not null,
	nro_comprobante numeric(7) not null,
	suc_cod varchar(6)  collate SQL_Latin1_General_CP1_CI_AS not null,
	usu_codigo varchar(6) collate SQL_Latin1_General_CP1_CI_AS not null,
	tra_rut numeric(9) not null,
	tra_dig varchar(1) collate SQL_Latin1_General_CP1_CI_AS ,
	tra_nombre varchar(40) collate SQL_Latin1_General_CP1_CI_AS ,
	tra_ape varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	rem_impo numeric(8),
	rem_imp_afp numeric(8),
        rem_impo_inp numeric(8),
	rem_impo_fc numeric(8),
	rem_impo_depconv numeric(8),
	dias_trab numeric(5),
	prevision numeric(2),
	salud numeric(2),
	ent_afc numeric(2),
	tipo_impre numeric(1),
	fec_pago datetime,
	ccaf_adh numeric(2),
	mut_adh numeric(2),
	tasa_cot_mut numeric(6,3),
	tasa_adic_mut numeric(6,3),
	raz_soc varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	tra_isa_dest numeric(2),
	tra_tipo_apv numeric(2),
	tra_ins_apv numeric(2),
        usu_pago_retroactivo varchar(1) collate SQL_Latin1_General_CP1_CI_AS,
        rem_impo_ccaf numeric(8),
       	rem_impo_isa  numeric(8),
        rem_impo_mutual numeric(8)
)

--create table @cert_detalle(
-- VOS20090928 agrego monto_sis numeric(8)
declare @cert_detalle table (
	rec_periodo datetime not null,
	nro_comprobante numeric(7) not null,
	tipo_Impre numeric(1) not null,
	suc_cod varchar(6)   collate SQL_Latin1_General_CP1_CI_AS not null,
	usu_cod varchar(6) collate SQL_Latin1_General_CP1_CI_AS  not null,
	tipo_ent varchar(1) collate SQL_Latin1_General_CP1_CI_AS  not null,
	ent_rut numeric(9) not null,
	ent_nombre varchar(255) collate SQL_Latin1_General_CP1_CI_AS,
	tra_rut numeric(9) not null,
	tra_dig varchar(1) collate SQL_Latin1_General_CP1_CI_AS,
	tra_nombre varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	tra_ape varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	dias_trab numeric(5),
	rem_impo numeric(8),
	monto_cotizado numeric(8),
	fec_pago datetime,
	folio_planilla numeric(10),
	raz_soc varchar(40) collate SQL_Latin1_General_CP1_CI_AS,
	salud numeric(2),
        monto_sis numeric(8),
        usu_pago_retroactivo varchar(1) collate SQL_Latin1_General_CP1_CI_AS
)

--create table @planilla(
declare @planilla table (
	rec_periodo datetime not null,
	nro_comprobante numeric(7) not null,
	ent_rut numeric(9) not null,
	pla_nro_serie numeric(10),
	suc_cod varchar(6)  collate SQL_Latin1_General_CP1_CI_AS not null,
	usu_cod varchar(6) collate SQL_Latin1_General_CP1_CI_AS not null
)


declare @sucursales table(
	codSuc varchar(7) collate SQL_Latin1_General_CP1_CI_AS
)
--Fin Creación de tablas virtuales


if @tipoCon = 2
begin
	--consulta por impresion por sucursal
	insert into @sucursales
	SELECT DET_CTA_USU.COD_SUC 
	FROM DET_CTA_USU 
	WHERE DET_CTA_USU.CON_RUT =  @emp_rut 
	 AND DET_CTA_USU.CON_CORREL = @convenio 
	 AND DET_CTA_USU.USR_RUT = cast(@Parametro as numeric)
end
else 
begin
	--consulta por impresion masiva por sucursal
	if @tipoCon = 3
	begin
		insert into @sucursales
		select @Parametro
	end 
end 


--Obtiene los datos del trabajador
if @convenio >= 600 and @convenio <= 699 
begin
	if @tipoCon = 1
	  -- VOS agrego  trabajador.tra_rem_imp_afp,
          -- 20091117 VOS agrego or (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90)  
          -- ya que cuando reg salud = 90 y Reg Prev = 90 no consideraba los apv
          -- VOS 20100908 (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90)
          -- VOS 20110426 se sacaron las siguientes condiciones, porque no imprimia el trabajador
          -- cuando solo tenia mutual
          -- and (trabajador.tra_reg_sal <> 90 or trabajador.tra_reg_prev <> 90 or 
          -- (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90) or
          -- (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90)) 
          -- ============================================================ 
                begin
		insert into @vir_tra2
		select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
		        trabajador.tra_rem_imp_afp,
			trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			sucursal.suc_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc,
			trabajador.tra_isa_dest,
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                        '0' as usu_pago_retroactivo,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual  
		from  empresa, sucursal, pago, trabajador
		where 	empresa.rec_periodo     between @fec_ini and @fec_ter
			and empresa.con_rut         = @emp_rut
			and empresa.con_correl      = @convenio
			and empresa.rpr_proceso     in (1,3,4)
			and pago.pag_hab_serv       = 1 
			and pago.ret_pago           = 5
			and trabajador.tra_rut      = @rut_tra
			and empresa.rec_periodo     = sucursal.rec_periodo 
			and empresa.con_rut 	    = sucursal.con_rut
			and empresa.con_correl      = sucursal.con_correl
			and empresa.rpr_proceso     = sucursal.rpr_proceso
			and empresa.nro_comprobante = sucursal.nro_comprobante
			and empresa.rec_periodo     = pago.rec_periodo
			and empresa.con_rut         = pago.con_rut
			and empresa.con_correl 	    = pago.con_correl         
			and empresa.rpr_proceso     = pago.rpr_proceso        
			and empresa.nro_comprobante = pago.nro_comprobante    
			and empresa.rec_periodo     = trabajador.rec_periodo 
			and empresa.con_rut         = trabajador.con_rut
			and empresa.con_correl      = trabajador.con_correl
			and empresa.rpr_proceso     = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
			and trabajador.suc_cod      = sucursal.suc_cod
		UNION ALL
                select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
		        trabajador.tra_rem_imp_afp,
			trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			sucursal.suc_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc,
			trabajador.tra_isa_dest,
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                                        CASE
                                                WHEN (year(empresa.rec_periodo) >= 2013) OR (year(empresa.rec_periodo) = 2012 AND month(empresa.rec_periodo) >= 5) 
                                                THEN isnull(dato_usuario.usu_pago_retroactivo,'0')  
                                                ELSE  '0' 
                                        END,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual  
                          from  empresa, sucursal, dato_usuario, pago, trabajador
		where 	empresa.rec_periodo     between @fec_ini and @fec_ter
			and empresa.con_rut         = @emp_rut
			and empresa.con_correl      = @convenio
			and empresa.rpr_proceso     = 2
			and pago.pag_hab_serv       = 1 
			and pago.ret_pago           = 5
			and trabajador.tra_rut      = @rut_tra
			and empresa.rec_periodo     = sucursal.rec_periodo 
			and empresa.con_rut 	    = sucursal.con_rut
			and empresa.con_correl      = sucursal.con_correl
			and empresa.rpr_proceso     = sucursal.rpr_proceso
			and empresa.nro_comprobante = sucursal.nro_comprobante
                        and empresa.rec_periodo     = dato_usuario.rec_periodo 
			and empresa.con_rut 	    = dato_usuario.con_rut
			and empresa.con_correl      = dato_usuario.con_correl
			and empresa.rpr_proceso     = dato_usuario.rpr_proceso
			and empresa.nro_comprobante = dato_usuario.nro_comprobante
			and empresa.rec_periodo     = pago.rec_periodo
			and empresa.con_rut         = pago.con_rut
			and empresa.con_correl 	    = pago.con_correl         
			and empresa.rpr_proceso     = pago.rpr_proceso        
			and empresa.nro_comprobante = pago.nro_comprobante    
			and empresa.rec_periodo     = trabajador.rec_periodo 
			and empresa.con_rut         = trabajador.con_rut
			and empresa.con_correl      = trabajador.con_correl
			and empresa.rpr_proceso     = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
			and trabajador.suc_cod      = sucursal.suc_cod
                        and trabajador.usu_codigo   = dato_usuario.usu_codigo
		order by trabajador.rec_periodo, trabajador.suc_cod, trabajador.usu_codigo

	end 
	else
	begin
                -- VOS agrego  trabajador.tra_rem_imp_afp, 
                -- 20091117 VOS agrego or (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90)  
                -- ya que cuando reg salud = 90 y Reg Prev = 90 no consideraba los apv
                -- VOS 20100908 (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90)                        
		-- VOS 20110426 se sacaron las siguientes condiciones, porque no imprimia el trabajador
                -- cuando solo tenia mutual
                -- and (trabajador.tra_reg_sal <> 90 or trabajador.tra_reg_prev <> 90 or 
                -- (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90) or
                -- (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90))
                insert into @vir_tra2
		select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
                        trabajador.tra_rem_imp_afp,
			trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,	
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			sucursal.suc_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc,
			trabajador.tra_isa_dest, 
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                        '0' as usu_pago_retroactivo,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual 
		from  empresa, sucursal, pago, trabajador
		where empresa.rec_periodo = sucursal.rec_periodo 
			and empresa.con_rut = sucursal.con_rut
			and empresa.con_correl = sucursal.con_correl
			and empresa.rpr_proceso = sucursal.rpr_proceso
			and empresa.nro_comprobante = sucursal.nro_comprobante
		        and empresa.rec_periodo = pago.rec_periodo  
			and empresa.con_rut  = pago.con_rut
			and empresa.con_correl =pago.con_correl  
			and empresa.rpr_proceso = pago.rpr_proceso 
			and empresa.nro_comprobante = pago.nro_comprobante 
			and empresa.rec_periodo = trabajador.rec_periodo 
			and empresa.con_rut = trabajador.con_rut
			and empresa.con_correl = trabajador.con_correl
			and empresa.rpr_proceso = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
			and trabajador.suc_cod = sucursal.suc_cod
			and empresa.rec_periodo between @fec_ini and @fec_ter
			and empresa.con_rut = @emp_rut
			and empresa.con_correl = @convenio
			and empresa.rpr_proceso in (1,3,4)
			and pago.pag_hab_serv = 1 
			and pago.ret_pago = 5
			and trabajador.tra_rut = @rut_tra
			and trabajador.suc_cod in (select codsuc from @sucursales)
		UNION ALL
                select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
                        trabajador.tra_rem_imp_afp,
			trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,	
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			sucursal.suc_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc,
			trabajador.tra_isa_dest, 
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                                         CASE
                                                WHEN (year(empresa.rec_periodo) >= 2013) OR (year(empresa.rec_periodo) = 2012 AND month(empresa.rec_periodo) >= 5) 
                                                THEN isnull(dato_usuario.usu_pago_retroactivo,'0')  
                                                ELSE  '0' 
                                        END,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual 
		from  empresa, sucursal, dato_usuario, pago, trabajador
		where empresa.rec_periodo = sucursal.rec_periodo 
			and empresa.con_rut = sucursal.con_rut
			and empresa.con_correl = sucursal.con_correl
			and empresa.rpr_proceso = sucursal.rpr_proceso
			and empresa.nro_comprobante = sucursal.nro_comprobante
                        and empresa.rec_periodo     = dato_usuario.rec_periodo 
			and empresa.con_rut 	    = dato_usuario.con_rut
			and empresa.con_correl      = dato_usuario.con_correl
			and empresa.rpr_proceso     = dato_usuario.rpr_proceso
			and empresa.nro_comprobante = dato_usuario.nro_comprobante
			and empresa.rec_periodo = pago.rec_periodo  
			and empresa.con_rut  = pago.con_rut
			and empresa.con_correl =pago.con_correl  
			and empresa.rpr_proceso = pago.rpr_proceso 
			and empresa.nro_comprobante = pago.nro_comprobante 
			and empresa.rec_periodo = trabajador.rec_periodo 
			and empresa.con_rut = trabajador.con_rut
			and empresa.con_correl = trabajador.con_correl
			and empresa.rpr_proceso = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
			and trabajador.suc_cod = sucursal.suc_cod
			and empresa.rec_periodo between @fec_ini and @fec_ter
			and empresa.con_rut = @emp_rut
			and empresa.con_correl = @convenio
			and empresa.rpr_proceso = 2
			and pago.pag_hab_serv = 1 
			and pago.ret_pago = 5
			and trabajador.tra_rut = @rut_tra
			and trabajador.suc_cod in (select codsuc from @sucursales)
                        and trabajador.usu_codigo   = dato_usuario.usu_codigo
                  order by trabajador.rec_periodo, trabajador.suc_cod, trabajador.usu_codigo

	end 

end 
else
begin
	if @tipoCon = 1
	begin
		-- VOS agrego  trabajador.tra_rem_imp_afp,
                -- 20091117 VOS agrego or (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90)  
                -- ya que cuando reg salud = 90 y Reg Prev = 90 no consideraba los apv
                -- VOS 20100908 (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90)
                -- VOS 20110426 se sacaron las siguientes condiciones, porque no imprimia el trabajador
                -- cuando solo tenia mutual
                -- and (trabajador.tra_reg_sal <> 90 or trabajador.tra_reg_prev <> 90 or 
                -- (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90) or
                -- (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90))
                insert into @vir_tra2
		select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
			trabajador.tra_rem_imp_afp,
                                        trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			empresa.emp_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc, 
			trabajador.tra_isa_dest, 
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                        '0' as usu_pago_retroactivo,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual 
		from empresa, pago, trabajador 
		where		
			empresa.rec_periodo between @fec_ini and @fec_ter
			and empresa.con_rut = @emp_rut
			and empresa.con_correl = @convenio
			and empresa.rpr_proceso in (1,3,4)
			and trabajador.tra_rut = @rut_tra
			and pago.pag_hab_serv = 1 
			and pago.ret_pago = 5
			and empresa.rec_periodo = pago.rec_periodo 
			and empresa.con_rut = pago.con_rut 
			and empresa.con_correl = pago.con_correl 
			and empresa.rpr_proceso = pago.rpr_proceso
			and empresa.nro_comprobante = pago.nro_comprobante
			and empresa.rec_periodo = trabajador.rec_periodo 
			and empresa.con_rut = trabajador.con_rut
			and empresa.con_correl = trabajador.con_correl
			and empresa.rpr_proceso = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
		UNION ALL
                select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
			trabajador.tra_rem_imp_afp,
                        trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			empresa.emp_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc, 
			trabajador.tra_isa_dest, 
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                                        CASE
                                                WHEN (year(empresa.rec_periodo) >= 2013) OR (year(empresa.rec_periodo) = 2012 AND month(empresa.rec_periodo) >= 5) 
                                                THEN isnull(dato_usuario.usu_pago_retroactivo,'0')  
                                                ELSE  '0' 
                                        END,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual 
 	             from empresa, dato_usuario, pago, trabajador 
		where		
			empresa.rec_periodo between @fec_ini and @fec_ter
			and empresa.con_rut = @emp_rut
			and empresa.con_correl = @convenio
			and empresa.rpr_proceso = 2
			and trabajador.tra_rut = @rut_tra
			and pago.pag_hab_serv = 1 
			and pago.ret_pago = 5
			and empresa.rec_periodo     = dato_usuario.rec_periodo 
			and empresa.con_rut 	    = dato_usuario.con_rut
			and empresa.con_correl      = dato_usuario.con_correl
			and empresa.rpr_proceso     = dato_usuario.rpr_proceso
			and empresa.nro_comprobante = dato_usuario.nro_comprobante 
                                        and empresa.rec_periodo = pago.rec_periodo 
			and empresa.con_rut = pago.con_rut 
			and empresa.con_correl = pago.con_correl 
			and empresa.rpr_proceso = pago.rpr_proceso
			and empresa.nro_comprobante = pago.nro_comprobante
			and empresa.rec_periodo = trabajador.rec_periodo 
			and empresa.con_rut = trabajador.con_rut
			and empresa.con_correl = trabajador.con_correl
			and empresa.rpr_proceso = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
                                       and trabajador.usu_codigo   = dato_usuario.usu_codigo
               order by trabajador.rec_periodo, trabajador.suc_cod, trabajador.usu_codigo

	end 
	else
	begin
                -- VOS agrego  trabajador.tra_rem_imp_afp,
                -- 20091117 VOS agrego or (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90)  
                -- ya que cuando reg salud = 90 y Reg Prev = 90 no consideraba los apv
                -- VOS 20100908 (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90)
		-- VOS 20110426 se sacaron las siguientes condiciones, porque no imprimia el trabajador
                -- cuando solo tenia mutual
                -- and (trabajador.tra_reg_sal <> 90 or trabajador.tra_reg_prev <> 90 or 
                -- (trabajador.tra_ins_apv <> 0 and trabajador.tra_ins_apv <> 90) or
                -- (trabajador.tra_adm_fondo_ces <> 0 and trabajador.tra_adm_fondo_ces <> 90))
                insert into @vir_tra2
		select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
			trabajador.tra_rem_imp_afp,
                        trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			empresa.emp_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc, 
			trabajador.tra_isa_dest,
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                        '0' as usu_pago_retroactivo,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual  
		from empresa, pago,trabajador 
		where empresa.rec_periodo between @fec_ini and @fec_ter
			and empresa.con_rut = @emp_rut
			and empresa.con_correl = @convenio
			and empresa.rpr_proceso in (1,3,4)
			and trabajador.tra_rut = @rut_tra
			and (pago.pag_hab_serv = 1) 
			and pago.ret_pago = 5
			and trabajador.suc_cod in (select codsuc from @sucursales)
			and empresa.rec_periodo = pago.rec_periodo
			and empresa.con_rut = pago.con_rut
			and empresa.con_correl = pago.con_correl
			and empresa.rpr_proceso = pago.rpr_proceso
			and empresa.nro_comprobante = pago.nro_comprobante
                                        and empresa.rec_periodo = trabajador.rec_periodo 
			and empresa.con_rut = trabajador.con_rut
			and empresa.con_correl = trabajador.con_correl
			and empresa.rpr_proceso = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
	        UNION ALL
                select 
			trabajador.rec_periodo,
			trabajador.con_rut,
			trabajador.con_correl,
			trabajador.rpr_proceso,
			trabajador.nro_comprobante,
			trabajador.suc_cod,
			trabajador.usu_codigo,
			trabajador.tra_rut,
			trabajador.tra_dig,
			trabajador.tra_nom_tra,
			trabajador.tra_ape_tra,
			trabajador.tra_rem_impo,
			trabajador.tra_rem_imp_afp,
                                        trabajador.tra_remimp_inpccaf,
			trabajador.tra_rem_imponible_fc,
			trabajador.tra_rem_imp_depcon,
			trabajador.tra_nro_dias_trab,
			trabajador.tra_reg_prev,
			trabajador.tra_reg_sal,
			trabajador.tra_adm_fondo_ces,
			empresa.emp_orden_inp,
			pago.pag_fec_timbre as pag_fec_pag,
			empresa.emp_ccaf_adh,
			empresa.emp_mut_adh,
			empresa.emp_tasa_cot_mut,
			empresa.emp_cot_adic_mut,
			empresa.emp_raz_soc, 
			trabajador.tra_isa_dest,
			trabajador.tra_tipo_ins_apv,
			trabajador.tra_ins_apv,
                                         CASE
                                                WHEN (year(empresa.rec_periodo) >= 2013) OR (year(empresa.rec_periodo) = 2012 AND month(empresa.rec_periodo) >= 5) 
                                                THEN isnull(dato_usuario.usu_pago_retroactivo,'0')  
                                                ELSE  '0' 
                                        END,
                        trabajador.tra_rem_ccaf,
                        trabajador.tra_rem_isapre,
                        trabajador.tra_rem_mutual
		from empresa, dato_usuario, pago,trabajador 
		where empresa.rec_periodo between @fec_ini and @fec_ter
			and empresa.con_rut = @emp_rut
			and empresa.con_correl = @convenio
			and empresa.rpr_proceso = 2
			and trabajador.tra_rut = @rut_tra
			and (pago.pag_hab_serv = 1) 
			and pago.ret_pago = 5
			and trabajador.suc_cod in (select codsuc from @sucursales)
                        and trabajador.usu_codigo   = dato_usuario.usu_codigo
			and empresa.rec_periodo     = dato_usuario.rec_periodo 
			and empresa.con_rut 	    = dato_usuario.con_rut
			and empresa.con_correl      = dato_usuario.con_correl
			and empresa.rpr_proceso     = dato_usuario.rpr_proceso
			and empresa.nro_comprobante = dato_usuario.nro_comprobante
                        and empresa.rec_periodo = pago.rec_periodo
			and empresa.con_rut = pago.con_rut
			and empresa.con_correl = pago.con_correl
			and empresa.rpr_proceso = pago.rpr_proceso
			and empresa.nro_comprobante = pago.nro_comprobante 
                        and empresa.rec_periodo = trabajador.rec_periodo 
			and empresa.con_rut = trabajador.con_rut
			and empresa.con_correl = trabajador.con_correl
			and empresa.rpr_proceso = trabajador.rpr_proceso
			and empresa.nro_comprobante = trabajador.nro_comprobante
		order by trabajador.rec_periodo, trabajador.suc_cod, trabajador.usu_codigo

	end
end

--si el tipo de consulta es > a 1, traspasa los datos a la trabla @vir_tra
if @parametro2 is not Null
begin
	--cuando es agrupado por dato usuario
	insert into @vir_tra
	select * from @vir_tra2
	where usu_codigo = @parametro2
	order by rec_periodo, suc_cod, usu_codigo
end 
else
begin
	--cuando es agrupado por sucursal
	insert into @vir_tra
	select * from @vir_tra2
	order by rec_periodo, suc_cod, usu_codigo
end

/* Obtiene el nombre del trabajador correspondiente al ultimo periodo 
registrado*/
select top 1 @nomTra = ltrim(rtrim(tra_nombre)), @apeTra = ltrim(rtrim(tra_ape))
from @vir_tra
order by rec_periodo desc

update @vir_tra
set tra_nombre = @nomTra,
tra_ape = @apeTra
/*****************************************/

--Cotizacion AFP: Gratificaciones
-- VOS, por incorporacion de Rem_imp_AFP
--- Se deja este solo para el proceso de Gratificaciones
--- VOS2090928 agrego isnull(trab_afp.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'A' as tipo_ent,
	afps.ent_rut,
	afps.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	rem_impo =
        CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN vt.rem_imp_afp    
           ELSE vt.rem_impo
	END,		
	traafp_cot_obl,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        isnull(trab_afp.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.prevision = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 2
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

-- Cotizacion AFP: Remuneraciones antes de Julio 2009
-- VOS, por incorporacion de Rem_imp_AFP
--- Se agrega para el proceso de remuneraciones que lea del campo Rem_impo 
--- para peridos menores a Julio del 2009
--- VOS2090928 agrego isnull(trab_afp.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'A' as tipo_ent,
	afps.ent_rut,
	afps.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_impo,	
	traafp_cot_obl,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        isnull(trab_afp.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre,
        vt.usu_pago_retroactivo  
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.prevision = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and (year(vt.rec_periodo) < 2009 or (year(vt.rec_periodo) = 2009 and month(vt.rec_periodo) < 7) )
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 1
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

-- Cotizacion AFP: Remuneraciones Despues de Julio 2009
-- VOS, por incorporacion de Rem_imp_AFP
--- Se agrega para el proceso de remuneraciones que lea del campo Rem_imp_afp 
--- para peridos Mayores o iguales a Julio del 2009
--- VOS2090928 agrego isnull(trab_afp.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre

insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'A' as tipo_ent,
	afps.ent_rut,
	afps.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_imp_afp,	
	traafp_cot_obl,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
             isnull(trab_afp.afp_seg_inv_sobre, 0) as afp_seg_inv_sobre,
            vt.usu_pago_retroactivo
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.prevision = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and (year(vt.rec_periodo) > 2009 or (year(vt.rec_periodo) = 2009 and month(vt.rec_periodo) >= 7) )
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 1
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


--cotizacion INP: 
--- VOS2090928 agrego 0
--- VOS 20100125 por UF 64,7 se incorporo AND (year(vt.rec_periodo) >= 2010)
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'A' as tipo_ent,
	inp.ent_rut,
	inp.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
        rem_impo =
        CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN vt.rem_impo_inp
           WHEN vt.rpr_proceso = 1 
                AND (year(vt.rec_periodo) >= 2010)
                THEN vt.rem_impo_inp   
           ELSE vt.rem_impo
	END,	
	trainp_cot_prev,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join tra_inp on 
		vt.rec_periodo = tra_inp.rec_periodo
		and vt.con_rut = tra_inp.con_rut
		and vt.con_correl = tra_inp.con_correl
		and vt.nro_comprobante = tra_inp.nro_comprobante
		and vt.suc_cod = tra_inp.suc_cod
		and vt.usu_codigo = tra_inp.usr_cod
		and vt.tra_rut = tra_inp.tra_rut
	inner join inp on 
		vt.prevision = inp.ent_codificacion
		and tra_inp.ent_rut = inp.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso in (1,2)
and vt.tra_rut = @rut_tra
and vt.prevision = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo






--Cotizacion Fonasa
--- VOS2090928 agrego 0
--- VOS 20100125 por UF 64,7 se incorporo AND (year(vt.rec_periodo) >= 2010)
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'B' as tipo_ent,
	tra_inp.ent_rut,
	isapres.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	rem_impo =
        CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN vt.rem_impo_inp
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision = 0  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_impo_inp   
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision <> 90
                AND vt.prevision <> 0 
                AND vt.prevision IS NOT NULL  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_imp_afp   
            ELSE vt.rem_impo
	END,
	trainp_cot_Fon,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join tra_inp on 
		vt.rec_periodo = tra_inp.rec_periodo
		and vt.con_rut = tra_inp.con_rut
		and vt.con_correl = tra_inp.con_correl
		and vt.nro_comprobante = tra_inp.nro_comprobante
		and vt.suc_cod = tra_inp.suc_cod
		and vt.usu_codigo = tra_inp.usr_cod
		and vt.tra_rut = tra_inp.tra_rut
	inner join isapres on 
		vt.salud = isapres.ent_codificacion
		--and tra_inp.ent_rut = isapres.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso in (1,2)
and vt.tra_rut = @rut_tra
and vt.salud = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo
	

--Cotizacion en isapre
--- VOS2090928 agrego 0
--- VOS 20100125 por UF 64,7 se incorporo AND (year(vt.rec_periodo) >= 2010)
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'B' as tipo_ent,
	isapres.ent_rut,
	isapres.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
        rem_impo =
        CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN vt.rem_impo_isa
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision = 0  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_impo_inp   
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision <> 90
                AND vt.prevision <> 0 
                AND vt.prevision IS NOT NULL  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_imp_afp   
            ELSE vt.rem_impo
	END,
	traisa_cot_apagar,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	vt.tra_isa_dest,
        0,
        vt.usu_pago_retroactivo 
from @vir_tra vt
	inner join tra_isapre on 
		vt.rec_periodo = tra_isapre.rec_periodo
		and vt.con_rut = tra_isapre.con_rut
		and vt.con_correl = tra_isapre.con_correl
		and vt.nro_comprobante = tra_isapre.nro_comprobante
		and vt.suc_cod = tra_isapre.suc_cod
		and vt.usu_codigo = tra_isapre.usr_cod
		and vt.tra_rut = tra_isapre.tra_rut
	inner join isapres on 
		vt.salud = isapres.ent_codificacion
		and tra_isapre.ent_rut = isapres.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso in (1,2)
and vt.tra_rut = @rut_tra
and vt.salud > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

--Cotizacion en CCAF
--- VOS2090928 agrego 0
--- VOS 20100125 por UF 64,7 se incorporo AND (year(vt.rec_periodo) >= 2010)
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'C' as tipo_ent,
	cajas.ent_rut,
	ent_nom =
        		CASE 
           		WHEN cajas.ent_codificacion = 1 
                		THEN 'LOS ANDES 0.6%'   
          		WHEN cajas.ent_codificacion = 2 
                		THEN 'LOS HEROES 0.6%'   
	   		WHEN cajas.ent_codificacion = 3 
                		THEN 'LA ARAUCANA 0.6%'   
	   		WHEN cajas.ent_codificacion = 4 
               			THEN 'GABRIELA M.  0.6%'   
	   		WHEN cajas.ent_codificacion = 5 
                		THEN 'JAVIERA C.  0.6%'   
	   		WHEN cajas.ent_codificacion = 6 
                		THEN '18 SEP.  0.6%'   
	   		ELSE ''
		END,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
        rem_impo =
        CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN vt.rem_impo_ccaf
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision = 0  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_impo_inp   
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision <> 90
                AND vt.prevision <> 0 
                AND vt.prevision IS NOT NULL  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_imp_afp   
            ELSE vt.rem_impo
	END,
	traccaf_salud,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join tra_ccaf on 
		vt.rec_periodo = tra_ccaf.rec_periodo
		and vt.con_rut = tra_ccaf.con_rut
		and vt.con_correl = tra_ccaf.con_correl
		and vt.nro_comprobante = tra_ccaf.nro_comprobante
		and vt.suc_cod = tra_ccaf.suc_cod
		and vt.usu_codigo = tra_ccaf.usr_cod
		and vt.tra_rut = tra_ccaf.tra_rut
	inner join cajas on 
		vt.ccaf_adh = cajas.ent_codificacion
		and tra_ccaf.ent_rut = cajas.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso in (1,2)
and vt.tra_rut = @rut_tra
and vt.salud = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo



--Seguro de cesantia
--- VOS2090928 agrego 0

insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'D' as tipo_ent,
	afps.ent_rut,
	'SEG. CES.',
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_impo_fc,
	TRAAFP_FONDO_CESANTIA,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
--		vt.ent_afc = afps.ent_codificacion
		trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso in (1,2)
and vt.tra_rut = @rut_tra
AND vt.rem_impo_fc >= 0 
AND vt.rem_impo_fc IS NOT NULL
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo 




--Cotizacion AFP - Trabajo pesado
--- VOS2090928 agrego 0

insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'E' as tipo_ent,
	afps.ent_rut,
	'TRAB.PES. ' + left(ltrim(rtrim(afps.ent_nom)),20),
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_impo,	
	traafp_mto_tra_pes,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo 
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.prevision = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter

and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 4
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


--Cotizacion Accidente del trabajo
--- VOS2090928 agrego 0
--- VOS 20100125 por UF 64,7 se incorporo AND (year(vt.rec_periodo) >= 2010)
--- VOS 20100204 por solicitud de FR se agrego lo sgte
--- and (TOTAL_MUTUAL.TMUT_NUM_TRAB > 0  or
--- TOTAL_MUTUAL.TMUT_REM_IMP > 0 or 
--- TOTAL_MUTUAL.TMUT_TOT_COTIZ > 0)
insert into @cert_detalle
select  distinct
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'F' as tipo_ent,
	iat.ent_rut,
	ent_nom = 
		case iat.ent_codificacion
			when 4 then 'IST' 
			when 2 then 'MUTUAL DE SEGURIDAD'
			when 3 then 'ACHS'
	end ,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	rem_impo =
        CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN vt.rem_impo_mutual
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision = 0  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_impo_inp   
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision <> 90
                AND vt.prevision <> 0 
                AND vt.prevision IS NOT NULL  
                AND year(vt.rec_periodo) >= 2010)
                THEN vt.rem_imp_afp   
            ELSE vt.rem_impo
	END,
        cotizacion = 
	CASE 
           WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                or (year(vt.rec_periodo) >= 2014))
                THEN (vt.rem_impo_mutual * (tasa_cot_mut + tasa_adic_mut)) / 100
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision = 0  
                AND year(vt.rec_periodo) >= 2010)
                THEN (vt.rem_impo_inp * (tasa_cot_mut + tasa_adic_mut)) / 100  
           WHEN (vt.rpr_proceso = 1 
                AND vt.prevision <> 90
                AND vt.prevision <> 0 
                AND vt.prevision IS NOT NULL  
                AND year(vt.rec_periodo) >= 2010)
                THEN   (vt.rem_imp_afp * (tasa_cot_mut + tasa_adic_mut)) / 100 
           ELSE (vt.rem_impo * (tasa_cot_mut + tasa_adic_mut)) / 100
	END,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	INNER JOIN TOTAL_MUTUAL ON 
		vt.REC_PERIODO = TOTAL_MUTUAL.REC_PERIODO 
		AND vt.CON_RUT = TOTAL_MUTUAL.CON_RUT 
		AND vt.CON_CORREL = TOTAL_MUTUAL.CON_CORREL 
		AND vt.RPR_PROCESO = TOTAL_MUTUAL.RPR_PROCESO 
		AND vt.NRO_COMPROBANTE = TOTAL_MUTUAL.NRO_COMPROBANTE 
	INNER JOIN INST_ACC_TRAB iat ON 
		vt.MUT_ADH = iat.ENT_CODIFICACION
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso in (1,2)
and vt.tra_rut = @rut_tra
and vt.mut_adh > 0 
and (TOTAL_MUTUAL.TMUT_NUM_TRAB > 0  or
TOTAL_MUTUAL.TMUT_REM_IMP > 0 or 
TOTAL_MUTUAL.TMUT_TOT_COTIZ > 0)
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


--Cotizacion APV - Entidades AFP
--- VOS2090928 agrego 0

insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'G' as tipo_ent,
	afps.ent_rut,
	left(ltrim(rtrim(afps.ent_nom)),20) + ' (APV)',
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_impo_depconv,	
	traafp_cot_vol,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.tra_ins_apv = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 3
and vt.tra_rut = @rut_tra 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


--Cotizacion APV - Entidades <> a las AFP
--- VOS2090928 agrego 0

insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'G' as tipo_ent,
	entidad_previsional.ent_rut,
	left(ltrim(rtrim(entidad_previsional.ent_nom)),19) + ' (APV)',
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_impo_depconv,	
	tra_apv.apv_cot_vol,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join tra_apv on 
		vt.rec_periodo = tra_apv.rec_periodo
		and vt.con_rut = tra_apv.con_rut
		and vt.con_correl = tra_apv.con_correl
		and vt.nro_comprobante = tra_apv.nro_comprobante
		and vt.suc_cod = tra_apv.suc_codigo
		and vt.usu_codigo = tra_apv.usu_codigo
		and vt.tra_rut = tra_apv.tra_rut
	inner join entidad_previsional on 
		vt.tra_ins_apv = entidad_previsional.ent_codificacion
		and tra_apv.ent_rut = entidad_previsional.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 3
and vt.tra_rut = @rut_tra
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo
--and vt.prevision > 0 


-- Nuevo Conceptos CCAF

if @parametro3 is not Null
begin

	if @parametro3 = '1'
	begin

		-- Nuevo VOS20110630 Creditos CCAF
		insert into @cert_detalle
		select 
		vt.rec_periodo,
		vt.nro_comprobante,
		vt.tipo_impre,
		vt.suc_cod,
		vt.usu_codigo,
		'I' as tipo_ent,
		cajas.ent_rut,
		ent_nom =
        	CASE 
           		 WHEN cajas.ent_codificacion = 1 
                		THEN 'LOS ANDES CREDITOS'   
          		WHEN cajas.ent_codificacion = 2 
                		THEN 'LOS HEROES CREDITOS'   
	   		WHEN cajas.ent_codificacion = 3 
                		THEN 'LA ARAUCANA CREDITOS'   
	   		WHEN cajas.ent_codificacion = 4 
               			THEN 'GABRIELA M. CREDITOS'   
	   		WHEN cajas.ent_codificacion = 5 
                		THEN 'JAVIERA C. CREDITOS'   
	   		WHEN cajas.ent_codificacion = 6 
                		THEN '18 SEP. CREDITOS'   
	   		ELSE ''
		END,
		vt.tra_rut ,
		vt.tra_dig ,
		vt.tra_nombre,
		vt.tra_ape,
		vt.dias_trab,
       		rem_impo =
        	CASE 
           		WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                       		or (year(vt.rec_periodo) >= 2014))
                		THEN vt.rem_impo_ccaf
                        WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision = 0  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_impo_inp   
           		WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision <> 90
                		AND vt.prevision <> 0 
                		AND vt.prevision IS NOT NULL  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_imp_afp   
            		ELSE vt.rem_impo
		END,
        	tra_ccaf.traccaf_mto_cred,
        	vt.fec_pago,
		Null,
		vt.raz_soc,
		Null,
        	0,
                vt.usu_pago_retroactivo
		from @vir_tra vt
		inner join tra_ccaf on 
			vt.rec_periodo = tra_ccaf.rec_periodo
			and vt.con_rut = tra_ccaf.con_rut
			and vt.con_correl = tra_ccaf.con_correl
			and vt.nro_comprobante = tra_ccaf.nro_comprobante
			and vt.suc_cod = tra_ccaf.suc_cod
			and vt.usu_codigo = tra_ccaf.usr_cod
			and vt.tra_rut = tra_ccaf.tra_rut
		inner join cajas on 
			vt.ccaf_adh = cajas.ent_codificacion
			and tra_ccaf.ent_rut = cajas.ent_rut
		where vt.rec_periodo between @fec_ini and @fec_ter
		and vt.con_rut = @emp_rut
		and vt.con_correl = @convenio
		and vt.rpr_proceso = 1
		and vt.tra_rut = @rut_tra
		and tra_ccaf.traccaf_mto_cred > 0 
		order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


		-- Nuevo VOS20110630 Ahorro CCAF
		insert into @cert_detalle
		select 
		vt.rec_periodo,
		vt.nro_comprobante,
		vt.tipo_impre,
		vt.suc_cod,
		vt.usu_codigo,
		'I' as tipo_ent,
		cajas.ent_rut,
		ent_nom =
        	CASE 
           		WHEN cajas.ent_codificacion = 1 
                		THEN 'LOS ANDES AHORRO'   
          		WHEN cajas.ent_codificacion = 2 
                		THEN 'LOS HEROES AHORRO'   
	   		WHEN cajas.ent_codificacion = 3 
                		THEN 'LA ARAUCANA AHORRO'   
	   		WHEN cajas.ent_codificacion = 4 
               			THEN 'GABRIELA M. AHORRO'   
	   		WHEN cajas.ent_codificacion = 5 
                		THEN 'JAVIERA C. AHORRO'   
	   		WHEN cajas.ent_codificacion = 6 
                		THEN '18 SEP. AHORRO'   
	   		ELSE ''
			END,
		vt.tra_rut ,
		vt.tra_dig ,
		vt.tra_nombre,
		vt.tra_ape,
		vt.dias_trab,
       		rem_impo =
        	CASE 
           		WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                       		or (year(vt.rec_periodo) >= 2014))
                		THEN vt.rem_impo_ccaf
                        WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision = 0  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_impo_inp   
          		WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision <> 90
                		AND vt.prevision <> 0 
                		AND vt.prevision IS NOT NULL  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_imp_afp   
            		ELSE vt.rem_impo
		END,
        	tra_ccaf.traccaf_mto_leas,
        	vt.fec_pago,
		Null,
		vt.raz_soc,
		Null,
        	0,
                vt.usu_pago_retroactivo
		from @vir_tra vt
		inner join tra_ccaf on 
			vt.rec_periodo = tra_ccaf.rec_periodo
			and vt.con_rut = tra_ccaf.con_rut
			and vt.con_correl = tra_ccaf.con_correl
			and vt.nro_comprobante = tra_ccaf.nro_comprobante
			and vt.suc_cod = tra_ccaf.suc_cod
			and vt.usu_codigo = tra_ccaf.usr_cod
			and vt.tra_rut = tra_ccaf.tra_rut
		inner join cajas on 
			vt.ccaf_adh = cajas.ent_codificacion
			and tra_ccaf.ent_rut = cajas.ent_rut
		where vt.rec_periodo between @fec_ini and @fec_ter
		and vt.con_rut = @emp_rut
		and vt.con_correl = @convenio
		and vt.rpr_proceso = 1
		and vt.tra_rut = @rut_tra
		and tra_ccaf.traccaf_mto_leas > 0 
		order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


		-- Nuevo VOS20110630 Seguro de Vida CCAF
		insert into @cert_detalle
		select 
		vt.rec_periodo,
		vt.nro_comprobante,
		vt.tipo_impre,
		vt.suc_cod,
		vt.usu_codigo,
		'I' as tipo_ent,
		cajas.ent_rut,
		ent_nom =
        	CASE 
           		WHEN cajas.ent_codificacion = 1 
                		THEN 'LOS ANDES SEG. VIDA'   
          		WHEN cajas.ent_codificacion = 2 
                		THEN 'LOS HEROES SEG. VIDA'   
	   		WHEN cajas.ent_codificacion = 3 
                		THEN 'LA ARAUCANA SEG. VIDA'   
	   		WHEN cajas.ent_codificacion = 4 
               			 THEN 'GABRIELA M. SEG. VIDA'   
	   		WHEN cajas.ent_codificacion = 5 
                		THEN 'JAVIERA C. SEG. VIDA'   
	   		WHEN cajas.ent_codificacion = 6 
                		THEN '18 SEP. SEG. VIDA'   
	   		ELSE ''
		END,
		vt.tra_rut ,
		vt.tra_dig ,
		vt.tra_nombre,
		vt.tra_ape,
		vt.dias_trab,
       	 	rem_impo =
        	CASE 
           		WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                       		or (year(vt.rec_periodo) >= 2014))
                		THEN vt.rem_impo_ccaf
                        WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision = 0  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_impo_inp   
           		WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision <> 90
                		AND vt.prevision <> 0 
                		AND vt.prevision IS NOT NULL  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_imp_afp   
            		ELSE vt.rem_impo
		END,
        	tra_ccaf.traccaf_mto_seg,
       		vt.fec_pago,
		Null,
		vt.raz_soc,
		Null,
             	0,
                vt.usu_pago_retroactivo
		from @vir_tra vt
		inner join tra_ccaf on 
			vt.rec_periodo = tra_ccaf.rec_periodo
			and vt.con_rut = tra_ccaf.con_rut
			and vt.con_correl = tra_ccaf.con_correl
			and vt.nro_comprobante = tra_ccaf.nro_comprobante
			and vt.suc_cod = tra_ccaf.suc_cod
			and vt.usu_codigo = tra_ccaf.usr_cod
			and vt.tra_rut = tra_ccaf.tra_rut
		inner join cajas on 
			vt.ccaf_adh = cajas.ent_codificacion
			and tra_ccaf.ent_rut = cajas.ent_rut
		where vt.rec_periodo between @fec_ini and @fec_ter
			and vt.con_rut = @emp_rut
			and vt.con_correl = @convenio
			and vt.rpr_proceso = 1
			and vt.tra_rut = @rut_tra
			and tra_ccaf.traccaf_mto_seg > 0 
			order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo



		-- Nuevo VOS20110630 Servicios Leg.Prepagados CCAF
		insert into @cert_detalle
		select 
		vt.rec_periodo,
		vt.nro_comprobante,
		vt.tipo_impre,
		vt.suc_cod,
		vt.usu_codigo,
		'I' as tipo_ent,
		cajas.ent_rut,
		ent_nom =
        	CASE 
           		WHEN cajas.ent_codificacion = 1 
                		THEN 'LOS ANDES SERV.LEG.PREPAG.'   
          		WHEN cajas.ent_codificacion = 2 
                		THEN 'LOS HEROES SERV.LEG.PREPAG.'   
	   		WHEN cajas.ent_codificacion = 3 
                		THEN 'LA ARAUCANA SERV.LEG.PREPAG.'   
	   		WHEN cajas.ent_codificacion = 4 
               			THEN 'GABRIELA M. SERV.LEG.PREPAG.'   
	   		WHEN cajas.ent_codificacion = 5 
                		THEN 'JAVIERA C. SERV.LEG.PREPAG.'   
	   		WHEN cajas.ent_codificacion = 6 
                		THEN '18 SEP. SERV.LEG.PREPAG.'   
	   		ELSE ''
		END,
		vt.tra_rut ,
		vt.tra_dig ,
		vt.tra_nombre,
		vt.tra_ape,
		vt.dias_trab,
        	rem_impo =
        	CASE 
           		WHEN ((year(vt.rec_periodo) = 2013 and month(vt.rec_periodo) >=11)
                       		or (year(vt.rec_periodo) >= 2014))
                		THEN vt.rem_impo_ccaf
                        WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision = 0  
                		AND year(vt.rec_periodo) >= 2010)
                		THEN vt.rem_impo_inp   
           		WHEN (vt.rpr_proceso = 1 
                		AND vt.prevision <> 90
                		AND vt.prevision <> 0 
                		AND vt.prevision IS NOT NULL  
                		AND year(vt.rec_periodo) >= 2010)
                	THEN vt.rem_imp_afp   
            		ELSE vt.rem_impo
		END,
        	tra_ccaf.traccaf_mto_otro,
       		vt.fec_pago,
		Null,
		vt.raz_soc,
		Null,
             	0,
                vt.usu_pago_retroactivo
		from @vir_tra vt
		inner join tra_ccaf on 
			vt.rec_periodo = tra_ccaf.rec_periodo
			and vt.con_rut = tra_ccaf.con_rut
			and vt.con_correl = tra_ccaf.con_correl
			and vt.nro_comprobante = tra_ccaf.nro_comprobante
			and vt.suc_cod = tra_ccaf.suc_cod
			and vt.usu_codigo = tra_ccaf.usr_cod
			and vt.tra_rut = tra_ccaf.tra_rut
		inner join cajas on 
			vt.ccaf_adh = cajas.ent_codificacion
			and tra_ccaf.ent_rut = cajas.ent_rut
		where vt.rec_periodo between @fec_ini and @fec_ter
		and vt.con_rut = @emp_rut
		and vt.con_correl = @convenio
		and vt.rpr_proceso = 1
		and vt.tra_rut = @rut_tra
		and tra_ccaf.traccaf_mto_otro > 0 
		order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

	end
end

-- Cta Ahorro Prev. AFP: Remuneraciones antes de Julio 2009
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'J' as tipo_ent,
	afps.ent_rut,
        'CTA.AHO.PREV. ' + left(ltrim(rtrim(afps.ent_nom)),20),
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_impo,	
	traafp_cta_aho,
        vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo  
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.prevision = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and (year(vt.rec_periodo) < 2009 or (year(vt.rec_periodo) = 2009 and month(vt.rec_periodo) < 7) )
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 1
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
and trab_afp.traafp_cta_aho > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

-- Cta Ahorro Prev. AFP: Remuneraciones Despues de Julio 2009
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_Impre,
	vt.suc_cod,
	vt.usu_codigo,
	'J' as tipo_ent,
	afps.ent_rut,
	'CTA.AHO.PREV. ' + left(ltrim(rtrim(afps.ent_nom)),20),
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.rem_imp_afp,	
	traafp_cta_aho,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
        0,
        vt.usu_pago_retroactivo
from @vir_tra vt
	inner join trab_afp on 
		vt.rec_periodo = trab_afp.rec_periodo
		and vt.con_rut = trab_afp.con_rut
		and vt.con_correl = trab_afp.con_correl
		and vt.nro_comprobante = trab_afp.nro_comprobante
		and vt.suc_cod = trab_afp.suc_cod
		and vt.usu_codigo = trab_afp.usu_codigo
		and vt.tra_rut = trab_afp.tra_rut
	inner join afps on 
		vt.prevision = afps.ent_codificacion
		and trab_afp.ent_rut = afps.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and (year(vt.rec_periodo) > 2009 or (year(vt.rec_periodo) = 2009 and month(vt.rec_periodo) >= 7) )
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 1
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
and trab_afp.traafp_cta_aho > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo






declare @numComp numeric(7)

declare tra_cursor cursor for
select distinct rec_periodo,tipo_impre,nro_comprobante from @cert_detalle 
--order by rec_periodo, suc_cod, usu_cod

open tra_cursor
fetch next from tra_cursor
into @periodo, @tipoImp,@numComp

while @@fetch_status = 0
begin
	if (@tipoImp = 0 or @tipoImp = 1 or @tipoImp = 2)
	begin
		insert into @planilla
		select 
			vt.rec_periodo,
			vt.nro_comprobante,
			planilla.ent_rut,
			planilla.pla_nro_serie,
			vt.suc_cod,
			vt.usu_cod
		from planilla
		inner join @cert_detalle vt on
			planilla.rec_periodo = vt.rec_periodo
			and planilla.nro_comprobante = vt.nro_comprobante
			and planilla.ent_rut = vt.ent_rut
		where vt.rec_periodo = @periodo
		and vt.tipo_impre = @tipoImp
		and vt.nro_comprobante = @numComp
		order by VT.rec_periodo, vt.suc_cod, vt.usu_cod
	end 

	if (@tipoImp = 3)
	begin
		insert into @planilla
		select 
			vt.rec_periodo,
			vt.nro_comprobante,
			planilla.ent_rut,
			planilla.pla_nro_serie,
			vt.suc_cod,
			vt.usu_cod
		from planilla
		inner join @cert_detalle vt on
			planilla.rec_periodo = vt.rec_periodo
			and planilla.nro_comprobante = vt.nro_comprobante
			and planilla.suc_codigo = vt.suc_cod
			and planilla.ent_rut = vt.ent_rut
		where vt.rec_periodo = @periodo
		and vt.tipo_impre = @tipoImp
		and vt.nro_comprobante = @numComp
		order by VT.rec_periodo, vt.suc_cod, vt.usu_cod
	end 
		
	if (@tipoImp = 4)
	begin
		insert into @planilla
		select 
			vt.rec_periodo,
			vt.nro_comprobante,
			planilla.ent_rut,
			planilla.pla_nro_serie,			vt.suc_cod,
			vt.usu_cod
		from planilla
		inner join @cert_detalle vt on
			planilla.rec_periodo = vt.rec_periodo
			and planilla.nro_comprobante = vt.nro_comprobante
			and planilla.usu_codigo = vt.usu_cod
			and planilla.ent_rut = vt.ent_rut
		where vt.rec_periodo = @periodo
		and vt.tipo_impre = @tipoImp
		and vt.nro_comprobante = @numComp
		order by VT.rec_periodo, vt.suc_cod, vt.usu_cod
	end 

	fetch next from tra_cursor
	into @periodo, @tipoImp,@numComp
end 

close tra_cursor
deallocate tra_cursor	


update @cert_detalle
set folio_planilla = p.pla_nro_serie
from @cert_detalle cd
	inner join @planilla p on 
		cd.rec_periodo = p.rec_periodo
		and cd.nro_comprobante = p.nro_comprobante
		and cd.ent_rut = p.ent_rut
		and cd.suc_cod = p.suc_cod
		and cd.usu_cod = p.usu_cod


select * from @cert_detalle
order by rec_periodo,suc_cod,usu_cod,tipo_ent


/*drop table #planilla
drop table @vir_tra
drop table @cert_detalle*/

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO