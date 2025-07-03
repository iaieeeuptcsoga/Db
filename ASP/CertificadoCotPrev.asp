<%@ Language=VBScript %>
<%
'+-----------------------------------------------------------------------------------------------+
'|					C E R T I F I C A D O   D E   C O T I Z A C I O N E S  V . 2
'|Fecha: 10-11-2005
'|Desarrollo: IPA
'|Descripcion: Versi�n 2 del certificado de cotizaciones. Este utiliza procedimiento almacenado
'|sp_CertCot_trab. Esto con el objetivo de optimizar la generaci�n del comprobante.
'+-----------------------------------------------------------------------------------------------+

'===============================================
'Fecha ultima modificacion: 24-11-2011
'-----------------------------------------------

'Fecha Modificacion: 24-11-2011 por VOS
'Descripcion: Incorporacion Mes retroactivo empresas publicas
'comentario modificacion: VOS20111124
'==================================================


'Fecha Modificacion: 02-11-2011 por VOS
'Descripcion: Parametro para impresion de conceptos CCAF
'comentario modificacion: VOS20111102
'==================================================


'Fecha Modificacion: 06-06-2011 por VOS
'Descripcion: Contabilizar los certificados emitidos
'comentario modificacion: VOS20110606
'==================================================


'<!-- #include file="../../../../../SQLConnection.cls"-->

'== VOS20151130 ==
'<!-- #include file="../../../../../PruebaPDF/include/funciones.asp" -->

%>
<!-- #include file="../layaut/layaout_Certificado.asp" -->
<!-- #include file="../sql/sql_certificado.asp"-->

<!-- #include file="../../data.inc" -->
<!-- #include file="../../../adovbs.inc"-->
<!-- #include file="../../../../Utilitarios/funciones_fechas.asp"-->
<!-- #include file="../../../../../SQLConnection.cls" -->
<!-- #include file="../../../../Utilitarios/utilitarios.asp" -->

<!-- #include file="../../../../../PruebaPDF/include/funciones.asp" -->
<%


Server.ScriptTimeout = 3600

'----------------------------------
' Variables
'----------------------------------
dim A,B,C,n
Dim objDoc, objPage,ConnBd,rsx

Dim rsxBdPrev
Dim rsxBdSegCes
Dim rsxBdCCAF
Dim rsxBdSal

Dim csqlx ,csqlx0,csqlx1,csqlx2,csqlx3,csqlx4 ,rsw,csqlx5,csqlx6
dim CondINP,CondAFP,CondISA,CondFON,CondCAJA,CondMUT

DIM nReg,xReg
dim xfecha,xfecha1
dim xdia,xmes ,xano
dim Ndias,Nombre,Pers_rut 
dim EmpRut,Per_Rut,Per_Desde,Per_Hasta
dim msError 
Dim proc
DIM DDesde,MDesde,ADesde,DHasta,MHasta,AHasta,Fmes

dim nRegx,NumPag,xNumPag,nPag,nEncabezado,RegHasta 

Dim cnvCta
Dim selOp 
Dim anio
Dim nMes 'VOS 11/04/2008
Dim flag 

Dim resto,div,div2
dim periodoAnt
dim regPer
'--------------------------------

'=== VOS Cert por Proc 20091007 ===
Dim anioHasta
Dim mesHasta
'=== Fin VOS Cert por Proc 20091007 ===


'=== VOS20110606 ===
Dim sFechaCreaPdf
Dim sqlStrCant

Dim bEsEmpresaPublica 'VOS20111124

Dim impCCAF  'VOS20111102

'== VOS20151130 ==
Dim sPeriodoConfuturo
Dim sAnioConfuturo
Dim sMesConfuturo
'== Fin VOS20151130 ==


sFechaCreaPdf = Now()
sFechaCreaPdf = Year(sFechaCreaPdf) & Right("00" & Month(sFechaCreaPdf),2) & Right("00" & day(sFechaCreaPdf),2)
'=== Fin VOS20110606 ===


'== VOS20151130 ==
sPeriodoConfuturo = GetPerIniCambioNomAPV_Confuturo()
sAnioConfuturo = Mid(sPeriodoConfuturo,1,4)
sMesConfuturo = Mid(sPeriodoConfuturo,5,2)
'== Fin VOS20151130 ==

'+-----------------------------------------------------------------
'| Definici�n de objetos
'+-----------------------------------------------------------------
Set objDoc = Server.CreateObject("DPDF_Gen.Document")
if not isObject(objDoc) then
	msgError = "Error al crear objeto documento. <br>"
	msgError = msgError & "Descripci�n : " & Err.Description 
	Err.Clear 
	Response.Redirect "error.asp?msgError=" & msgError
	Response.End 
end if

set ConnBd = Server.CreateObject("ADODB.Connection")
if not isObject(ConnBd) then
	set objDoc = nothing
	msgError = "Error al crear objeto Conecci�n. <br>"
	msgError = msgError & "Descripci�n : " & Err.Description 
	Err.Clear 
	Response.Redirect "error.asp?msgError=" & msgError
	Response.End 
end if
ConnBd.CommandTimeout = 3600 
ConnBd.ConnectionTimeout = 3600
ConnBd.CursorLocation = adUseClient 
'ConnBd.Open Application("DSN")
ConnBd.Open SQLConnectionString

set rsx=Server.CreateObject("ADODB.recordset")
if not isObject(rsx) then
	set objDoc = nothing
	set ConnBd = nothing
	msgError = "Error al recordset. <br>"
	 msgError = msgError & "Descripci�n : " & Err.Description 
	Err.Clear 
	Response.Redirect "error.asp?msgError=" & msgError
	Response.End 
end if



'===============================================
'Funcion para obtener el ultimo dia de un mes
'===============================================
Function UltimoDiaDeMes(iMonth, iYear)
	Dim sDate
	Dim MesSiguiente

	sDate = DateSerial(iYear, iMonth, "01")
	MesSiguiente = DateAdd("m", 1, SDate)
	UltimoDiaDeMes = Day(DateAdd("d", -1, MesSiguiente))

End Function





'=========================================================================================
'	Funcion que determina las fechas de inicio y termino de los periodos para los 
'	�ltimos 12 meses.
'=========================================================================================
sub ult12(byVal conBd,byVal rutPer,byRef perDesde, byRef perHasta)

	Dim sqlStr
	Dim rs
	Dim miDesde
	Dim miHasta
	
	
	set rs = Server.CreateObject("Adodb.Recordset")
	
	sqlStr = "EXECUTE sp_determinaPeriodo " & rutPer
	
	rs.Open sqlStr,conBd
	
	Dim i
	Dim totReg
	if rs.eof or rs.bof then
		miDesde = ""
		miHasta = ""
	else

		miDesde = trim(rs("rec_periodo"))
'		miHasta = trim(rs("fecTer"))

		rs.MoveFirst
		miDesde = trim(rs("rec_periodo"))
		do while not rs.EOF 
			miHasta = trim(rs("rec_periodo"))
			rs.MoveNext 
		loop
		perDesde = year(cDate(miDesde)) & "-" & month(cDate(miDesde)) & "-" & day(cDate(miDesde))
		perHasta = year(cDate(miHasta)) & "-" & month(cDate(miHasta)) & "-" & day(cDate(miHasta))
	end if

	rs.close
	set rs = nothing

end sub 'Fin ult12 


'==== VOS20111124 ===
Function EsEmpresaPublica(byVal conBd,byVal rutEmp,ByVal con_correl, byVal perDesde, byVal perHasta)

	Dim sqlStr
	Dim rs
	Dim totCant

	EsEmpresaPublica = False
	
	set rs = Server.CreateObject("Adodb.Recordset")
	
	sqlStr = "SELECT count(*) as cant from empresa where " & _
             " empresa.con_rut = " & rutEmp & _
             " and empresa.con_correl = " & con_correl & _
             " and empresa.rpr_proceso = 2 " & _
             " and empresa.EMP_TIPO_GRATIF = 2 " & _
			 " and empresa.EMP_ORDEN_INP = 4 " & _
             " and empresa.rec_periodo between '" & perDesde & "' and '" & perHasta & "'"

	rs.Open sqlStr,conBd
	
	totCant = 0

	if Not rs.eof then
		totCant = rs("cant")
	end if

	If totCant > 0 Then
		EsEmpresaPublica = True
	End if

	rs.close
	set rs = nothing

End Function
'=== Fin VOS20111124 ===


'Obtiene el rut de la empresa
EmpRut =CStr(trim(Session("RutEmp")))

if EmpRut ="" then  EmpRut=Request.QueryString("EmpRut")  

'=========================================================================================
'Determina el tipo de certificado a imprimir
'=========================================================================================
if not isNull(Request.QueryString("rutTra")) and Request.QueryString("rutTra") <> ""  then
	'originales
	Per_Rut= trim(Request.QueryString("rutTra"))
	cnvCta= trim(Request.QueryString("cnvCta"))
	selOp = cInt(trim(Request.QueryString("selOp")))
	anio = trim(Request.QueryString("anio"))
	nMes = trim(Request.QueryString("mes"))  'VOS 04/11/2008

	
	'=== VOS Cert por Proc 20091007 ===
	anioHasta = trim(Request.QueryString("anioHasta"))
	mesHasta = trim(Request.QueryString("mesHasta"))
	'=== Fin VOS Cert por Proc 20091007 ===

	
	impCCAF = trim(Request.QueryString("impCCAF"))  'VOS20111102
	
else
	Per_Rut= trim(Request.Form("rutTra"))
	cnvCta= trim(Request.Form("cnvCta"))
	selOp = cInt(trim(Request.Form("selOp")))
	anio = trim(Request.Form("anio"))
	nMes = trim(Request.Form("mes")) 'VOS 04/11/2008

	'=== VOS Cert por Proc 20091007 ===
	anioHasta = trim(Request.Form("anioHasta"))
	mesHasta = trim(Request.Form("mesHasta"))
	'=== Fin VOS Cert por Proc 20091007 ===
	
	impCCAF = trim(Request.Form("impCCAF"))  'VOS20111102

end if




'EmpRut = Request.Form("empRut")
'Per_Rut = Request.Form("per_rut") 
'cnvCta = Request.Form("cnvcta")
'selOp = Request.Form("selop")
'anio = Request.Form("anio")


select case selOp
	case 1 'Busca un a�o especifico
		Per_Desde = anio & "-01-31"		
		Per_Hasta = anio & "-12-31"

		'+------------------------------------------------------------------------
		'| Llamado a la funcion para establecer la conexi�n a la base de datos
		'| Como es por un a�o especifico, el parametro mes se deja fijo. 
		'+------------------------------------------------------------------------
		'ConnBd.Open conectar(anio,Null,Null,Null)
		'+------------------------------------------------------------------------

	case 2 'Determina los ultimos 12 meses

		'ConnBd.Open Application("DSN")
		if err.number <> 0 then

			set objDoc = nothing
			set ConnBd = nothing
			set rsx = nothing
			set rsw = nothing

			msgError = "Error al conectar. <br>"
			msgError = msgError & "Descripci�n : " & Err.Description 
			Err.Clear 
			Response.Redirect "error.asp?msgError=" & msgError
			Response.End 
		end if
		
		call ult12(ConnBd,Per_Rut, Per_Desde, Per_Hasta)
		
	'=== VOS 11/04/2008 ====
	case 4 'Busca un a�o y mes especifico
		Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)	
		Per_Hasta = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)
	'=== Fin VOS 11/04/2008 ====
	

	'=== VOS Cert por Proc 20091007 ===
	case 5 'Busca un periodo especifico
		Per_Desde = anio & "-" & nMes & "-" & UltimoDiaDeMes(nMes,anio)	
		Per_Hasta = anioHasta & "-" & mesHasta & "-" & UltimoDiaDeMes(mesHasta,anioHasta)
	
	'=== Fin VOS Cert por Proc 20091007 ===
		
end select


'== VOS20111124  ===
'aca se debe preguntar si es empresa publica
'bEsEmpresaPublica = False
bEsEmpresaPublica = EsEmpresaPublica(ConnBd,EmpRut,cnvCta,Per_Desde,Per_Hasta)
'== Fin VOS20111124  ===

'=========================================================================================

Dim tipoCon

AddPages objDoc,objPage 
n=133

nRegx=0
xNumPag=1
nPag =0
nEncabezado = 0

IF Session("USU_COD_PER") = "SI" THEN  
	tipoCon = 2
else
	tipoCon = 1
end if

'obtiene los datos de cotizaciones del trabajador
'=== VOS20111102 ===
'SQL_TRA_DET ConnBd,rsx,per_desde,per_hasta,EmpRut,cnvCta,Per_Rut,tipoCon,0,Null

'== VOS20111124  ===
'SQL_TRA_DET ConnBd,rsx,per_desde,per_hasta,EmpRut,cnvCta,Per_Rut,tipoCon,0,Null,impCCAF
If bEsEmpresaPublica = False Then
	SQL_TRA_DET ConnBd,rsx,per_desde,per_hasta,EmpRut,cnvCta,Per_Rut,tipoCon,0,Null,impCCAF
else
	SQL_TRA_DET_PUB ConnBd,rsx,per_desde,per_hasta,EmpRut,cnvCta,Per_Rut,tipoCon,0,Null,impCCAF
End if
'== Fin VOS20111124  ===
'=== Fin VOS20111102 ===


'Verifica si recupera datos
if rsx.EOF or rsx.BOF then
	rsx.Close 
	ConnBd.Close 
	set rsx = nothing
	set ConnBd = nothing
	Response.Write "<br><br>"
	Response.Write "<link rel=""stylesheet"" href=""../../../include/Stl_misCot.css"" type=""text/css"">"
	Response.Write "<div align=""center""><b>La persona no esta asociada a la empresa. </b></div>"
	Response.Write "<br><br>"
	Response.Write "<div align=""center""><a href=""javascript:window.close()"">Cerrar</a></div>"
	Response.End 
end if

'cuenta los registros recuperados
'do while not rsx.EOF  
'	nRegx = nRegx + 1
'	rsx.MoveNext 
'loop

 

nRegx = rsx.RecordCount 

numPag = numPer(ConnBd, anio,EmpRut,cnvCta,Per_Desde,Per_Hasta,Per_rut,nregx)

'if   Int(nregx) <= 30 then RegHasta = 36
'if   Int(nregx) > 30 then RegHasta = 42


'=== VOS  14/04/2008 ===
'rsx.sort = "ENT_NOMBRE, REM_IMPO"
'=== Fin VOS 14/04/2008 ==

regPer = 0
npag = 0
rsx.MoveFirst 
periodoAnt = trim(rsx("rec_periodo"))

'=== VOS20111124 ===
If bEsEmpresaPublica = False Then
'=== Fin  VOS20111124 ===

	DO WHILE  NOT  rsx.EOF 
   
		if nEncabezado = 0 then 
		
			Encabezado rsx 
		end if
    
		nEncabezado = 1

		flag = false
	
		if npag <= RegHasta then
     	
			'+-----------------------------------------------------------------------
			'| Cambios realizados el 16-12-2003
			'| Debido a que deja de existir las isapres Vida Plena y Cigna Salud
			'| aplicado solo al periodo 11-2003
			'+-----------------------------------------------------------------------
			If year(rsx("rec_periodo")) = "2003" and month(rsx("rec_periodo")) = "11" then			
				IF Len(rsx("salud")) > 0 THEN
					'indica que cotiza en Vida Plena o en Cigna
					flag = true
				else
					flag = false
				END IF
			else
				flag = false
			end if 
			'-------------------------------------------------------------------------
	
			if periodoAnt <> trim(rsx("rec_periodo")) then
				'objPage.Addrectangle -20,n,540,10,"FFFFFF","000000",,,3
				objPage.Addrectangle -30,n,557,10,"FFFFFF","000000",,,3
				n=n+10
				npag = npag + 1
			end if
							
			'Institucion de Prevision
			'objPage.Addrectangle -20,n,120,10,"FFFFFF","000000",,,3
			objPage.Addrectangle -30,n,120,10,"FFFFFF","000000",,,3
		
			'Mes y A�o de Renta
			'objPage.Addrectangle 100,n,55,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 90,n,47,10,"FFFFFF","000000",,,3
		
			'Dias Trabajados
			'objPage.Addrectangle 155,n,40,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 137,n,25,10,"FFFFFF","000000",,,3
	
	
			'Remuneracion Imponible					 
			'objPage.Addrectangle 195,n,65,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 162,n,55,10,"FFFFFF","000000",,,3
		
		
			'Monto Cotizado
			'objPage.Addrectangle 255,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 217,n,45,10,"FFFFFF","000000",,,3
		
		
			'Monto SIS
			objPage.Addrectangle 262,n,45,10,"FFFFFF","000000",,,3
		
		
			'Fecha Pago
			'objPage.Addrectangle 300,n,50,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 307,n,50,10,"FFFFFF","000000",,,3
		
			'Folio Planilla
			'objPage.Addrectangle 350,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 357,n,45,10,"FFFFFF","000000",,,3
	
		
			'Empleador
			'objPage.Addrectangle 395,n,125,10,"FFFFFF","000000",,,3 
			objPage.Addrectangle 402,n,125,10,"FFFFFF","000000",,,3  
		
			'Hubica los datos del trabajador------------------------------
			if flag then 'si cotiza en Cigna o Vida Plena
				'objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
				objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
		
			else
				
				If (Trim(rsx("ENT_RUT")) = "98000000" _
					and (YEAR(rsx("rec_periodo")) < 2008 or (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) then 
					if len(rsx("ENT_NOMBRE")) > 0 then 
						If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
							objPage.addtextarea  "SANTA MARIA"  ,-27, n, 504, 12,1,7,8,"000000"
						else
							objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
						end if
					end if
				
				'== VOS20151130 ==
                elseIf (Trim(rsx("ENT_RUT")) = "96571890" _
				    and (YEAR(rsx("rec_periodo")) < CInt(sAnioConfuturo) or (YEAR(rsx("rec_periodo")) = CInt(sAnioConfuturo) and MONTH(rsx("rec_periodo")) < CInt(sMesConfuturo)))) then 
					
				    if len(rsx("ENT_NOMBRE")) > 0 then 
						objPage.addtextarea  "VIDA CORP CIA DE SEGUROS"  ,-27, n, 504, 12,1,7,8,"000000"
					end if 
				'== Fin VOS20151130 ==
			
				else
					if len(rsx("ENT_NOMBRE")) > 0 then objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
				end if
		
			end if 
	
			'objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,110, n, 504, 12,,7,8,"000000"
			objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,94, n, 504, 12,,7,8,"000000"
								 
			'objPage.addtextarea  rsx("DIAS_TRAB") ,180, n, 10, 12,2,7,8,"000000"
			objPage.addtextarea  rsx("DIAS_TRAB") ,144, n, 10, 12,2,7,8,"000000"
		
								 
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,200, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,162, n, 52, 12,2,7,8,"000000"
	    
	    
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),245, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),207, n, 52, 12,2,7,8,"000000"
		
		
			'Monto SIS
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_sis"),0),",","."),252, n, 52, 12,2,7,8,"000000"
		
			'Fecha Pago
			'objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),295, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),302, n, 52, 12,2,7,8,"000000"
		
		
			'Folio Planilla
			if len(rsx("folio_planilla")) > 0 then 
				'objPage.addtextarea  rsx("folio_planilla"),340, n, 52, 12,2,7,8,"000000"
				objPage.addtextarea  rsx("folio_planilla"),347, n, 52, 12,2,7,8,"000000"
			end if
		
			'Empleador
			'objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),400, n, 352, 12,1,7,8,"000000"
			objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),407, n, 352, 12,1,7,8,"000000"

			n=n+10
			
			npag = npag + 1
						
		ELSE
			objPage.addtextarea "_____________________________",-20, 680, 604, 12,,,10,"000000"
			objPage.addtextarea "_____________________________",-18, 680, 604, 12,,,10,"000000"
			objPage.addtextarea "Certificado jur�dicamente v�lido para cumplir con la exigencia contenida en el Art�culo  31 del D.F.L. N� 2, de 1967, Ley Org�nica de la Direcci�n del Trabajo (ORD. N� 2460 del 27 Junio de 2003)" ,-20, 690, 604, 12,,,5,"000000"
			
			objPage.addtextarea "P�gina: " & xNumPag & " de " &  numpag ,473, -25, 604, 12,,,7,"000000"
			    
			AddPages objDoc,objPage 
	        
			nx=0
	        
			'Institucion de Prevision
			'objPage.Addrectangle -20,nX,120,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Instituci�n de Previsi�n",-3,nX+5, 504, 12,,7,7,"000000"
			objPage.Addrectangle -30,nX,120,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Instituci�n de Previsi�n",-13,nX+5, 504, 12,,7,7,"000000"
		
		
		
			'Mes y a�o de Renta
			'objPage.Addrectangle 100,nX,55,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Mes y a�o",110,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Remuneraciones",101,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 90,nX,47,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Mes y a�o",96,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Renta",101,nX+10, 506, 12,,7,7,"000000"
		
			'Dias Trabajados	   
			'objPage.Addrectangle 155,nx,40,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Dias",164,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Trabajados",157,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 137,nx,25,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Dias",140,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Trab.",140,nX+10, 504, 12,,7,7,"000000"
		
			   
			'Remuneracion Imponible
			'objPage.Addrectangle 195,nX,65,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Remuneraci�n",202,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Imponible",207,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 162,nX,55,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Remuneraci�n",166,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Imponible",172,nX+10, 504, 12,,7,7,"000000"
		
			  
			'Monto Cotizado
			'objPage.Addrectangle 255,nX,45,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Monto",265,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Cotizado",262,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 217,nX,45,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Monto",227,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Cotizado",224,nX+10, 504, 12,,7,7,"000000"
		
	
			'Monto SIS
			objPage.Addrectangle 262,nX,45,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Monto",277,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "S.I.S.",278,nX+10, 504, 12,,7,7,"000000"
		
		
			'Fecha Pago	   
			'objPage.Addrectangle 300,nX,50,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Fecha",313,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "de pago",311,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 307,nX,50,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Fecha",320,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "de pago",320,nX+10, 504, 12,,7,7,"000000"
		
		
			'Folio Planilla
			'objPage.Addrectangle 350,nX,45,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "N� folio",357,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "planilla",357,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 357,nX,45,20,"FFFFFF","000000",,,3
			objPage.addtextarea "N� folio",364,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "planilla",364,nX+10, 504, 12,,7,7,"000000"
		
		
			'Empleador
			'objPage.Addrectangle 395,nX,125,20,"FFFFFF","000000",,,3 
			'objPage.addtextarea "Empleador",405,nX+5, 504, 12,,7,7,"000000"
			objPage.Addrectangle 402,nX,125,20,"FFFFFF","000000",,,3 
			objPage.addtextarea "Empleador",412,nX+5, 504, 12,,7,7,"000000" 
				        
		

			xNumPag= xNumPag +1
			N = 20 
			nPag =0	 
				    
			'+-----------------------------------------------------------------------
			'| Cambios realizados el 16-12-2003
			'| Debido a que deja de existir las isapres Vida Plena y Cigna Salud
			'| aplicado solo al periodo 11-2003
			'+-----------------------------------------------------------------------
			If year(rsx("rec_periodo")) = "2003" and month(rsx("rec_periodo")) = "11" then			
				IF Len(rsx("salud")) > 0 THEN
					'indica que cotiza en Vida Plena o en Cigna
					flag = true
				else
					flag = false
				END IF
			else
				flag = false
			end if 
			'-------------------------------------------------------------------------
			
			'Institucion de Prevision
			'objPage.Addrectangle -20,n,120,10,"FFFFFF","000000",,,3
			objPage.Addrectangle -30,n,120,10,"FFFFFF","000000",,,3
		
			'Mes y A�o de Renta
			'objPage.Addrectangle 100,n,55,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 90,n,47,10,"FFFFFF","000000",,,3
		
			'Dias Trabajados
			'objPage.Addrectangle 155,n,40,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 137,n,25,10,"FFFFFF","000000",,,3
	
			'Remuneracion Imponible				 
			'objPage.Addrectangle 195,n,65,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 162,n,55,10,"FFFFFF","000000",,,3
		
			'Monto Cotizado
			'objPage.Addrectangle 255,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 217,n,45,10,"FFFFFF","000000",,,3
		
			'Monto SIS
			objPage.Addrectangle 262,n,45,10,"FFFFFF","000000",,,3
		
		
			'Fecha Pago
			'objPage.Addrectangle 300,n,50,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 307,n,50,10,"FFFFFF","000000",,,3
		
		
			'Folio Planilla
			'objPage.Addrectangle 350,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 357,n,45,10,"FFFFFF","000000",,,3
	
		
			'Empleador
			'objPage.Addrectangle 395,n,125,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 402,n,125,10,"FFFFFF","000000",,,3  

			'Hubica los datos del trabajador------------------------------
			if flag then 'si cotiza en Cigna o Vida Plena
				'objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
				objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
			else
				'=== VOS 02/05/2008 SANTA MARIA ===
			
				If (Trim(rsx("ENT_RUT")) = "98000000" _
					and (YEAR(rsx("rec_periodo")) < 2008 or (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) then 
					if len(rsx("ENT_NOMBRE")) > 0 then 
						If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
							objPage.addtextarea  "SANTA MARIA"  ,-27, n, 504, 12,1,7,8,"000000"
						else
							objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
						end if
					end if
				'== VOS20151130 ==
                elseIf (Trim(rsx("ENT_RUT")) = "96571890" _
				    and (YEAR(rsx("rec_periodo")) < CInt(sAnioConfuturo) or (YEAR(rsx("rec_periodo")) = CInt(sAnioConfuturo) and MONTH(rsx("rec_periodo")) < CInt(sMesConfuturo)))) then 
					
				    if len(rsx("ENT_NOMBRE")) > 0 then 
							objPage.addtextarea  "VIDA CORP CIA DE SEGUROS"  ,-27, n, 504, 12,1,7,8,"000000"
					end if 
				'== Fin VOS20151130 ==
				
				else
					if len(rsx("ENT_NOMBRE")) > 0 then objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
				end if
		
				'=== Fin VOS 02/05/2008 SANTA MARIA ===
		
			end if 

			''objPage.addtextarea  mid(trim(rsx("ENT_NOMbre")),1,26)  ,-17, n, 504, 12,1,7,8,"000000"
		
			'objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,110, n, 504, 12,,7,8,"000000"
			objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,94, n, 504, 12,,7,8,"000000"
		
							 
			'objPage.addtextarea  rsx("DIAS_TRAB") ,180, n, 10, 12,2,7,8,"000000"
			objPage.addtextarea  rsx("DIAS_TRAB") ,144, n, 10, 12,2,7,8,"000000"
							 
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,200, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,162, n, 52, 12,2,7,8,"000000"
        
			'
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),245, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),207, n, 52, 12,2,7,8,"000000"
		
		
			'Monto SIS
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_sis"),0),",","."),252, n, 52, 12,2,7,8,"000000"
		
		
			'Fecha Pago
			'objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),295, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),302, n, 52, 12,2,7,8,"000000"
		
		
			'Folio Planilla
			if len(rsx("folio_planilla")) > 0 then 
				'objPage.addtextarea  rsx("folio_planilla"),340, n, 52, 12,2,7,8,"000000"
				objPage.addtextarea  rsx("folio_planilla"),347, n, 52, 12,2,7,8,"000000"
			end if
		
		
			'Empleador
			'objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),400, n, 352, 12,1,7,8,"000000"
			objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),407, n, 352, 12,1,7,8,"000000"

			n=n+10
				
			npag = npag + 1
		    
		END IF

		periodoAnt = trim(rsx("rec_periodo"))

		RSx.MOVENEXT

	LOOP

Else
	'Empresas publicas
	DO WHILE  NOT  rsx.EOF 
   
		if nEncabezado = 0 then 
			
			Encabezado_Pub rsx
			
		end if
    
		nEncabezado = 1

		flag = false
	
		if npag <= RegHasta then
     
			'+-----------------------------------------------------------------------
			'| Cambios realizados el 16-12-2003
			'| Debido a que deja de existir las isapres Vida Plena y Cigna Salud
			'| aplicado solo al periodo 11-2003
			'+-----------------------------------------------------------------------
			If year(rsx("rec_periodo")) = "2003" and month(rsx("rec_periodo")) = "11" then			
				IF Len(rsx("salud")) > 0 THEN
					'indica que cotiza en Vida Plena o en Cigna
					flag = true
				else
					flag = false
				END IF
			else
				flag = false
			end if 
			'-------------------------------------------------------------------------
	
			if periodoAnt <> trim(rsx("rec_periodo")) then
				objPage.Addrectangle -30,n,557,10,"FFFFFF","000000",,,3
				n=n+10
				npag = npag + 1
			end if
							
			'Institucion de Prevision
			objPage.Addrectangle -30,n,120,10,"FFFFFF","000000",,,3
		
			'Mes y A�o de Renta
			'objPage.Addrectangle 90,n,47,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 90,n,42,10,"FFFFFF","000000",,,3
		

			'Dias Trabajados
			'objPage.Addrectangle 137,n,25,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 132,n,21,10,"FFFFFF","000000",,,3
	
	
			'Remuneracion Imponible					 
			'objPage.Addrectangle 162,n,55,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 153,n,55,10,"FFFFFF","000000",,,3
		
		
			'Monto Cotizado
			'objPage.Addrectangle 217,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 208,n,45,10,"FFFFFF","000000",,,3
		
		
			'Monto SIS
			'objPage.Addrectangle 262,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 253,n,45,10,"FFFFFF","000000",,,3
		
		
			'Fecha Pago
			'objPage.Addrectangle 307,n,50,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 298,n,50,10,"FFFFFF","000000",,,3
		
			'Folio Planilla
			'objPage.Addrectangle 357,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 348,n,45,10,"FFFFFF","000000",,,3
	
		
			'Empleador
			'objPage.Addrectangle 402,n,125,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 393,n,92,10,"FFFFFF","000000",,,3
		

			'Mes Retro
			objPage.Addrectangle 485,n,42,10,"FFFFFF","000000",,,3



			'Hubica los datos del trabajador------------------------------
			if flag then 'si cotiza en Cigna o Vida Plena
				objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
		
			else
				'=== VOS 02/05/2008 SANTA MARIA ===
			
				If (Trim(rsx("ENT_RUT")) = "98000000" _
					and (YEAR(rsx("rec_periodo")) < 2008 or (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) then 
					if len(rsx("ENT_NOMBRE")) > 0 then 
						If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
							objPage.addtextarea  "SANTA MARIA"  ,-27, n, 504, 12,1,7,8,"000000"
						else
							objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
						end if
					end if
				
				'== VOS20151130 ==
                 elseIf (Trim(rsx("ENT_RUT")) = "96571890" _
				    and (YEAR(rsx("rec_periodo")) < CInt(sAnioConfuturo) or (YEAR(rsx("rec_periodo")) = CInt(sAnioConfuturo) and MONTH(rsx("rec_periodo")) < CInt(sMesConfuturo)))) then 
					
				    if len(rsx("ENT_NOMBRE")) > 0 then 
							objPage.addtextarea  "VIDA CORP CIA DE SEGUROS"  ,-27, n, 504, 12,1,7,8,"000000"
					end if 
				'== Fin VOS20151130 ==

				else
					if len(rsx("ENT_NOMBRE")) > 0 then objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
				end if
		
			'=== Fin VOS 02/05/2008 SANTA MARIA ===
			end if 
	
			'objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,94, n, 504, 12,,7,8,"000000"
			objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,92, n, 504, 12,,7,8,"000000"
		
								 
			'objPage.addtextarea  rsx("DIAS_TRAB") ,144, n, 10, 12,2,7,8,"000000"
			objPage.addtextarea  rsx("DIAS_TRAB") ,137, n, 10, 12,2,7,8,"000000"
		
								 
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,162, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,153, n, 52, 12,2,7,8,"000000"
	    
	    
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),207, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),198, n, 52, 12,2,7,8,"000000"
		
		
			'Monto SIS
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_sis"),0),",","."),252, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_sis"),0),",","."),243, n, 52, 12,2,7,8,"000000"
		
			'Fecha Pago
			'objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),302, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),293, n, 52, 12,2,7,8,"000000"
		
			'Folio Planilla
			if len(rsx("folio_planilla")) > 0 then 
				'objPage.addtextarea  rsx("folio_planilla"),347, n, 52, 12,2,7,8,"000000"
				objPage.addtextarea  rsx("folio_planilla"),338, n, 52, 12,2,7,8,"000000"
			end if
		
			'Empleador
			'objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),407, n, 352, 12,1,7,8,"000000"
			objPage.addtextarea  mid(rsx("RAZ_SOC"),1,18),398, n, 93, 12,1,7,8,"000000"
		
			'Mes Retro
			If CInt(rsx("usu_pago_retroactivo")) = 1 And CInt(rsx("tipo_impre")) = 4 Then
				'objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,487, n, 504, 12,,7,8,"000000"
				
				If Trim(rsx("usu_cod")) <> "" Then
				   If Len(Trim(rsx("usu_cod")))= 5 Then
					objPage.addtextarea  MES(CInt(Mid(rsx("usu_cod"),1,1)),CInt(Mid(rsx("usu_cod"),2,4))) ,487, n, 504, 12,,7,8,"000000"
			       Else
					objPage.addtextarea  MES(CInt(Mid(rsx("usu_cod"),1,2)),CInt(Mid(rsx("usu_cod"),3,4))) ,487, n, 504, 12,,7,8,"000000"
				   End if
			    End if
			End if

			n=n+10
			
			npag = npag + 1
						
		ELSE
			objPage.addtextarea "_____________________________",-20, 680, 604, 12,,,10,"000000"
			objPage.addtextarea "_____________________________",-18, 680, 604, 12,,,10,"000000"
			objPage.addtextarea "Certificado jur�dicamente v�lido para cumplir con la exigencia contenida en el Art�culo  31 del D.F.L. N� 2, de 1967, Ley Org�nica de la Direcci�n del Trabajo (ORD. N� 2460 del 27 Junio de 2003)" ,-20, 690, 604, 12,,,5,"000000"
			
			objPage.addtextarea "P�gina: " & xNumPag & " de " &  numpag ,473, -25, 604, 12,,,7,"000000"
			    
			AddPages objDoc,objPage 
	        
			nx=0
	        
			'Institucion de Prevision
			objPage.Addrectangle -30,nX,120,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Instituci�n de Previsi�n",-13,nX+5, 504, 12,,7,7,"000000"
		
		
			'Mes y a�o de Renta
			'objPage.Addrectangle 90,nX,47,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Mes y a�o",96,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Renta",101,nX+10, 506, 12,,7,7,"000000"
  			objPage.Addrectangle 90,nX,42,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Mes y a�o",94,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Renta",99,nX+10, 506, 12,,7,7,"000000"
		
		
			'Dias Trabajados
			'objPage.Addrectangle 137,nx,25,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Dias",140,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Trab.",140,nX+10, 504, 12,,7,7,"000000"
  			objPage.Addrectangle 132,nx,21,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Dias",134,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Trab.",134,nX+10, 504, 12,,7,7,"000000"
  

			'Remuneracion Imponible
			'objPage.Addrectangle 162,nX,55,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Remuneraci�n",166,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Imponible",172,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 153,nX,55,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Remuneraci�n",157,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Imponible",163,nX+10, 504, 12,,7,7,"000000"
  

			'Monto Cotizado
			'objPage.Addrectangle 217,nX,45,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Monto",227,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "Cotizado",224,nX+10, 504, 12,,7,7,"000000"
  			objPage.Addrectangle 208,nX,45,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Monto",218,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Cotizado",215,nX+10, 504, 12,,7,7,"000000"
   

		
			'Monto SIS
			'objPage.Addrectangle 262,nX,45,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Monto",277,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "S.I.S.",278,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 253,nX,45,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Monto",268,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "S.I.S.",269,nX+10, 504, 12,,7,7,"000000"

		
			'Fecha Pago
			'objPage.Addrectangle 307,nX,50,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "Fecha",320,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "de pago",320,nX+10, 504, 12,,7,7,"000000"
			objPage.Addrectangle 298,nX,50,20,"FFFFFF","000000",,,3
			objPage.addtextarea "Fecha",311,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "de pago",311,nX+10, 504, 12,,7,7,"000000"
  
		
			'N� folio Planilla
  			'objPage.Addrectangle 357,nX,45,20,"FFFFFF","000000",,,3
			'objPage.addtextarea "N� folio",364,nX+1, 504, 12,,7,7,"000000"
			'objPage.addtextarea "planilla",364,nX+10, 504, 12,,7,7,"000000"
  			objPage.Addrectangle 348,nX,45,20,"FFFFFF","000000",,,3
			objPage.addtextarea "N� folio",355,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "planilla",355,nX+10, 504, 12,,7,7,"000000"


			'Empleador
			'objPage.Addrectangle 402,nX,125,20,"FFFFFF","000000",,,3 
			'objPage.addtextarea "Empleador",412,nX+5, 504, 12,,7,7,"000000"
			objPage.Addrectangle 393,nX,92,20,"FFFFFF","000000",,,3 
			objPage.addtextarea "Empleador",416,nX+5, 504, 12,,7,7,"000000"


			'Mes Retro
			objPage.Addrectangle 485,nX,42,20,"FFFFFF","000000",,,3 
			objPage.addtextarea "Mes",497,nX+1, 504, 12,,7,7,"000000"
			objPage.addtextarea "Retro",497,nX+10, 504, 12,,7,7,"000000"


			xNumPag= xNumPag +1
			N = 20 
			nPag =0	 
				    
			'+-----------------------------------------------------------------------
			'| Cambios realizados el 16-12-2003
			'| Debido a que deja de existir las isapres Vida Plena y Cigna Salud
			'| aplicado solo al periodo 11-2003
			'+-----------------------------------------------------------------------
			If year(rsx("rec_periodo")) = "2003" and month(rsx("rec_periodo")) = "11" then			
				IF Len(rsx("salud")) > 0 THEN
					'indica que cotiza en Vida Plena o en Cigna
					flag = true
				else
					flag = false
				END IF
			else
				flag = false
			end if 
			'-------------------------------------------------------------------------
			
			'Institucion de Prevision
			objPage.Addrectangle -30,n,120,10,"FFFFFF","000000",,,3
		
			'Mes y A�o de Renta
			'objPage.Addrectangle 90,n,47,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 90,n,42,10,"FFFFFF","000000",,,3
		
			'Dias Trabajados
			'objPage.Addrectangle 137,n,25,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 132,n,21,10,"FFFFFF","000000",,,3
	
			'Remuneracion Imponible				 
			'objPage.Addrectangle 162,n,55,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 153,n,55,10,"FFFFFF","000000",,,3
		
			'Monto Cotizado
			'objPage.Addrectangle 217,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 208,n,45,10,"FFFFFF","000000",,,3

			'Monto SIS
			'objPage.Addrectangle 262,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 253,n,45,10,"FFFFFF","000000",,,3
		
		
			'Fecha Pago
			'objPage.Addrectangle 307,n,50,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 298,n,50,10,"FFFFFF","000000",,,3
		
		
			'Folio Planilla
			'objPage.Addrectangle 357,n,45,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 348,n,45,10,"FFFFFF","000000",,,3
	
		
			'Empleador
			'objPage.Addrectangle 402,n,125,10,"FFFFFF","000000",,,3
			objPage.Addrectangle 393,n,92,10,"FFFFFF","000000",,,3

		
			'Mes Retro
			objPage.Addrectangle 485,n,42,10,"FFFFFF","000000",,,3 


			'Hubica los datos del trabajador------------------------------
			if flag then 'si cotiza en Cigna o Vida Plena
				objPage.addtextarea  mid(nombreEntidad(trim(rsx("salud")),2),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
			else
				'=== VOS 02/05/2008 SANTA MARIA ===
			
				If (Trim(rsx("ENT_RUT")) = "98000000" _
					and (YEAR(rsx("rec_periodo")) < 2008 or (YEAR(rsx("rec_periodo")) = 2008 and MONTH(rsx("rec_periodo")) <= 3))) then 
					if len(rsx("ENT_NOMBRE")) > 0 then 
						If Trim(rsx("ENT_NOMBRE")) <> "SEG. CES." Then
							objPage.addtextarea  "SANTA MARIA"  ,-27, n, 504, 12,1,7,8,"000000"
						else
							objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
						end if
					end if
				
				'== VOS20151130 ==
                 elseIf (Trim(rsx("ENT_RUT")) = "96571890" _
				    and (YEAR(rsx("rec_periodo")) < CInt(sAnioConfuturo) or (YEAR(rsx("rec_periodo")) = CInt(sAnioConfuturo) and MONTH(rsx("rec_periodo")) < CInt(sMesConfuturo)))) then 
					
				    if len(rsx("ENT_NOMBRE")) > 0 then 
							objPage.addtextarea  "VIDA CORP CIA DE SEGUROS"  ,-27, n, 504, 12,1,7,8,"000000"
					end if 
				'== Fin VOS20151130 ==

				else
					if len(rsx("ENT_NOMBRE")) > 0 then objPage.addtextarea  mid(trim(rsx("ENT_NOMBRE")),1,26)  ,-27, n, 504, 12,1,7,8,"000000"
				end if
		
				'=== Fin VOS 02/05/2008 SANTA MARIA ===
		
			end if 

			'objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,94, n, 504, 12,,7,8,"000000"
			objPage.addtextarea  MES(MONTH(rsx("rec_periodo")),YEAR(rsx("rec_periodo"))) ,92, n, 504, 12,,7,8,"000000"
							 
			'objPage.addtextarea  rsx("DIAS_TRAB") ,144, n, 10, 12,2,7,8,"000000"
			objPage.addtextarea  rsx("DIAS_TRAB") ,137, n, 10, 12,2,7,8,"000000"
							 
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,162, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("REM_IMPO"),0),",",".")  ,153, n, 52, 12,2,7,8,"000000"

			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),207, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_COTizado"),0),",","."),198, n, 52, 12,2,7,8,"000000"

			'Monto SIS
			'objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_sis"),0),",","."),252, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  REPLACE(FormatCurrency( rsx("monto_sis"),0),",","."),243, n, 52, 12,2,7,8,"000000"

			'Fecha Pago
			'objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),302, n, 52, 12,2,7,8,"000000"
			objPage.addtextarea  formatFecha(rsx("FEC_PAGo")),293, n, 52, 12,2,7,8,"000000"

			'Folio Planilla
			if len(rsx("folio_planilla")) > 0 then 
				'objPage.addtextarea  rsx("folio_planilla"),347, n, 52, 12,2,7,8,"000000"
				objPage.addtextarea  rsx("folio_planilla"),338, n, 52, 12,2,7,8,"000000"
			end if
		
			'Empleador
			'objPage.addtextarea  mid(rsx("RAZ_SOC"),1,24),407, n, 352, 12,1,7,8,"000000"
			objPage.addtextarea  mid(rsx("RAZ_SOC"),1,18),398, n, 93, 12,1,7,8,"000000"

			
			'Mes Retro
			If CInt(rsx("usu_pago_retroactivo")) = 1 And CInt(rsx("tipo_impre")) = 4 Then
				'objPage.addtextarea  MES(CInt(Mid(rsx("usu_cod"),1,2)),CInt(Mid(rsx("usu_cod"),3,4))) ,487, n, 504, 12,,7,8,"000000"
				If Trim(rsx("usu_cod")) <> "" Then
				   If Len(Trim(rsx("usu_cod")))= 5 Then
					objPage.addtextarea  MES(CInt(Mid(rsx("usu_cod"),1,1)),CInt(Mid(rsx("usu_cod"),2,4))) ,487, n, 504, 12,,7,8,"000000"
			       Else
					objPage.addtextarea  MES(CInt(Mid(rsx("usu_cod"),1,2)),CInt(Mid(rsx("usu_cod"),3,4))) ,487, n, 504, 12,,7,8,"000000"
				   End if
			    End if
			End if
			 
		
			n=n+10
				
			npag = npag + 1
		    
		END IF

		periodoAnt = trim(rsx("rec_periodo"))

		RSx.MOVENEXT

	LOOP


End if


'llama al procedimiento pie
pie n

objPage.addtextarea "P�gina: " & xNumPag & " de " &  numpag ,473, -25, 604, 12,,,7,"000000"
			
objDoc.DrawToASP
Set objDoc = Nothing
Set objPage = Nothing
rsx.Close 

'=== VOS20110606 ===
sqlStrCant = "EXEC sp_actCertCot_generados '" & sFechaCreaPdf & "'" 
ConnBd.Execute sqlStrCant
'=== Fin VOS20110606 ===


ConnBd.Close 
'//Fin cuerpo funcion principal
 
 
if Err.number <> 0 then
	Response.Write "Existe un problema al generar el certificado."
	Response.End 
end if



%>