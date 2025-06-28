 sp_certCot_SILCREATE procedure sp_certCot_SIL @fec_ini datetime, @fec_ter datetime, @emp_rut numeric(9),
				@convenio numeric(3),@rut_tra numeric(9)
as 

SET NOCOUNT ON

declare @tipoImp numeric(1)
declare @periodo datetime 

--Creación de tablas virtuales
--create table @vir_tra(
declare @vir_tra table(
	rec_periodo datetime not null,
	con_rut numeric(9) not null,
	con_correl numeric(3) not null,
	rpr_proceso numeric(1) not null,
	nro_comprobante numeric(7) not null,
	suc_cod varchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS,
	usu_codigo varchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_rut numeric(9)not null,
	tra_dig varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_nombre varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_ape varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	rem_impo numeric(8),
	rem_impo_fc numeric(8),
	dias_trab numeric(5),
	fec_iniSub datetime,
	fec_terSub datetime,
	prevision numeric(2),
	salud numeric(2),
	tipo_impre numeric(1),
	fec_pago datetime,
	ccaf_adh numeric(2),
	raz_soc varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_isa_dest numeric(2)
)


--create table @cert_detalle(
declare @cert_detalle table (
	rec_periodo datetime not null,
	nro_comprobante numeric(7) not null,
	tipo_Impre numeric(1) not null,
	suc_cod varchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS ,
	usu_cod varchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS ,
	tipo_ent varchar(1)COLLATE SQL_Latin1_General_CP1_CI_AS,
	ent_rut numeric(9) not null,
	ent_nombre varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_rut numeric(9)not null,
	tra_dig varchar(1) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_nombre varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	tra_ape varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	dias_trab numeric(5),
	fec_inisub datetime,
	fec_tersub datetime,
	rem_impo numeric(8),
	monto_cotizado numeric(8),
	fec_pago datetime,
	folio_planilla numeric(10),
	raz_soc varchar(40) COLLATE SQL_Latin1_General_CP1_CI_AS,
	salud numeric(2),
	tra_reg_sal numeric
)

--create table @planilla(
declare @planilla table (
	rec_periodo datetime not null,
	nro_comprobante numeric(7) not null,
	ent_rut numeric(9) not null,
	pla_nro_serie numeric(10),
	suc_cod varchar(6)  COLLATE SQL_Latin1_General_CP1_CI_AS,
	usu_cod varchar(6) COLLATE SQL_Latin1_General_CP1_CI_AS
)

--Fin Creación de tablas virtuales


--Obtiene los datos del trabajador
insert into @vir_tra
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
	trabajador.tra_rem_imponible_fc,
	trabajador.tra_nro_dias_trab,
	trabajador.tra_fecinisub,
	trabajador.tra_fectersub,
	trabajador.tra_reg_prev,
	trabajador.tra_reg_sal,
	empresa.emp_orden_inp,
	pago.pag_fec_pag,
	empresa.emp_ccaf_adh,
	empresa.emp_raz_soc, 
	trabajador.tra_isa_dest 
from trabajador 
	inner join empresa  on 
		empresa.rec_periodo = trabajador.rec_periodo 
		and empresa.con_rut = trabajador.con_rut
		and empresa.con_correl = trabajador.con_correl
		and empresa.rpr_proceso = trabajador.rpr_proceso
		and empresa.nro_comprobante = trabajador.nro_comprobante
	inner join pago on 
		pago.rec_periodo = empresa.rec_periodo 
		and pago.con_rut = empresa.con_rut
		and pago.con_correl = empresa.con_correl
		and pago.rpr_proceso = empresa.rpr_proceso
		and pago.nro_comprobante = empresa.nro_comprobante
where trabajador.rec_periodo between @fec_ini and @fec_ter
and trabajador.con_rut = @emp_rut
and trabajador.con_correl = @convenio
and trabajador.rpr_proceso = 5
and trabajador.tra_rut = @rut_tra
and (TRABAJADOR.tra_reg_sal <> 90 OR trabajador.tra_reg_prev <> 90) 
AND (PAGO.PAG_HAB_SERV = 1) 
and pago.ret_pago = 5
order by trabajador.rec_periodo, trabajador.suc_cod, trabajador.usu_codigo

--Cotizacion AFP
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
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,	
	traafp_cot_obl,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	0
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
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
and vt.prevision > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

--cotizacion INP
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
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,	
	trainp_cot_prev,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	0
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
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
and vt.prevision = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


--Cotizacion INPCCAF
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
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,	
	inc_cot_prev,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	0
from @vir_tra vt
	inner join tra_inpccaf on 
		vt.rec_periodo = tra_inpccaf.rec_periodo
		and vt.con_rut = tra_inpccaf.con_rut
		and vt.con_correl = tra_inpccaf.con_correl
		and vt.nro_comprobante = tra_inpccaf.nro_comprobante
		and vt.suc_cod = tra_inpccaf.suc_codigo
		and vt.usu_codigo = tra_inpccaf.usu_codigo
		and vt.tra_rut = tra_inpccaf.tra_rut
	inner join inp on 
		vt.prevision = inp.ent_codificacion
		and tra_inpccaf.ent_rut = inp.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
and vt.prevision = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo


--Cotizacion Fonasa 
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
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,
	trainp_cot_Fon,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	vt.salud
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
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
and vt.salud = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

	
--Fonasa (con INPCCAF)
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'B' as tipo_ent,
	tra_inpccaf.ent_rut,
	isapres.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,
	inc_cot_Fonasa,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	vt.salud
from @vir_tra vt
	inner join tra_inpccaf on 
		vt.rec_periodo = tra_inpccaf.rec_periodo
		and vt.con_rut = tra_inpccaf.con_rut
		and vt.con_correl = tra_inpccaf.con_correl
		and vt.nro_comprobante = tra_inpccaf.nro_comprobante
		and vt.suc_cod = tra_inpccaf.suc_codigo
		and vt.usu_codigo = tra_inpccaf.usu_codigo
		and vt.tra_rut = tra_inpccaf.tra_rut
	inner join isapres on 
		vt.salud = isapres.ent_codificacion
		--and tra_inp.ent_rut = isapres.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
and vt.salud = 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo



--Cotizacion en isapre
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
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,
	traisa_cot_apagar,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	vt.tra_isa_dest,
	vt.salud
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
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
and vt.salud > 0 
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

--Cotizacion en CCAF
insert into @cert_detalle
select 
	vt.rec_periodo,
	vt.nro_comprobante,
	vt.tipo_impre,
	vt.suc_cod,
	vt.usu_codigo,
	'C' as tipo_ent,
	cajas.ent_rut,
	cajas.ent_nom,
	vt.tra_rut ,
	vt.tra_dig ,
	vt.tra_nombre,
	vt.tra_ape,
	vt.dias_trab,
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,
	traccaf_salud,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	0
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
		tra_ccaf.ent_rut = cajas.ent_rut
where vt.rec_periodo between @fec_ini and @fec_ter
and vt.con_rut = @emp_rut
and vt.con_correl = @convenio
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo

--Seguro de cesantia
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
	vt.fec_inisub,
	vt.fec_tersub,
	vt.rem_impo,
	TRAAFP_FONDO_CESANTIA,
	vt.fec_pago,
	Null,
	vt.raz_soc,
	Null,
	0
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
and vt.rpr_proceso = 5
and vt.tra_rut = @rut_tra
AND vt.rem_impo_fc <> 0 
AND vt.rem_impo_fc IS NOT NULL
order by vt.rec_periodo, vt.suc_cod, vt.usu_codigo 


declare @numComp numeric(7)

declare tra_cursor cursor for
select distinct rec_periodo,tipo_impre,nro_comprobante from @cert_detalle 

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
			planilla.pla_nro_serie,

			vt.suc_cod,
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
order by rec_periodo,tipo_ent,suc_cod,usu_cod





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO