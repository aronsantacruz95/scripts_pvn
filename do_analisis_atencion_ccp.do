clear all
set more off

glo fecha "15052024"

glo ruta_input  "D:\Usuarios\sanalisisopp6\Documents\Data\Data SGD\"
glo ruta_output "D:\Usuarios\sanalisisopp6\Documents\Data\"

// Lista de CCPs revisados (wsp js)

import excel using "${ruta_output}\CCP REVISADOS WSP JS.xlsx", clear first sheet(BD)
keep HR CCP
keep if CCP=="CCP"
duplicates drop
save "${ruta_output}\tmp_ccp_wsp_js.dta", replace
clear

// Respuestas OPP

import excel using "${ruta_input}\RespuestaOPP\ReporteExpedientes_opp_uo.xlsx", clear first
drop if inlist(AREADESTINO,"OFICINA DE PLANEAMIENTO Y PRESUPUESTO","PRESUPUESTO Y ENDEUDAMIENTO","PLANEAMIENTO E INFORMACION","GESTION ESTRATEGICA","MODERNIZACION INSTITUCIONAL","PLANEAMIENTO E INFORMACION")
keep EXPEDIENTE FECHADELLEGADA ARCHIVO
gen HR=substr(EXPEDIENTE,1,13)
gen _dia=substr(FECHADELLEGADA,1,2)
gen _mes=substr(FECHADELLEGADA,4,2)
gen _ano=substr(FECHADELLEGADA,7,4)
destring _dia _mes _ano, replace
gen fecha_salida_opp=mdy(_mes,_dia,_ano)
*replace fecha_llegada=fecha_llegada+21916
drop _dia _mes _ano
format fecha_salida_opp %td
drop EXPEDIENTE FECHADELLEGADA
duplicates drop HR fecha_salida_opp, force
ren ARCHIVO =_OPP
save "${ruta_output}\tmp_documentos_rpta_opp.dta", replace
clear

// Obtener fecha y hora actual

local fecha = subinstr("$S_DATE"," ","",.)
local hora = substr("$S_TIME",1,2)+substr("$S_TIME",4,2)
cd "${ruta_input}"
local files: dir . files "*.xlsx"
set obs 0
gen XXX=""
save "BD_EXPEDIENTES.dta", replace
foreach file in `files'{
	clear
	import excel using "`file'", clear allstring first
	append using "BD_EXPEDIENTES.dta"
	save "BD_EXPEDIENTES.dta", replace
}

use "BD_EXPEDIENTES.dta", clear
compress
format * %10s
gen HR=substr(EXPEDIENTE,1,13)

sort HR FECHADESALIDA

// 1. Identificar accion

gen MOVIMIENTO=""
replace MOVIMIENTO="1. UO -> j_OPP" if !inlist(AREAORIGEN,"OFICINA DE PLANEAMIENTO Y PRESUPUESTO","PRESUPUESTO Y ENDEUDAMIENTO") & ///
											(AREADESTINO=="OFICINA DE PLANEAMIENTO Y PRESUPUESTO" 	& substr(CARGODESTINO,1,3)=="JEF")
replace MOVIMIENTO="2. j_OPP -> j_APE" if 	(AREAORIGEN =="OFICINA DE PLANEAMIENTO Y PRESUPUESTO" 	& substr(CARGOORIGEN,1,3) =="JEF") & ///
											(AREADESTINO=="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGODESTINO,1,3)=="JEF")
replace MOVIMIENTO="3. j_APE -> e_APE" if 	(AREAORIGEN =="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGOORIGEN,1,3) =="JEF") & ///
											(AREADESTINO=="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGODESTINO,1,3)!="JEF")
replace MOVIMIENTO="3. j_APE -> e_APE" if 	 ORIGEN=="ROMERO ESPINOZA NERY ESTHER" & DESTINO=="FRANCIS ARON SANTA CRUZ DE LA CRUZ" & MOVIMIENTO==""
replace MOVIMIENTO="4. e_APE -> e_APE" if 	(AREAORIGEN =="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGOORIGEN,1,3) !="JEF") & ///
											(AREADESTINO=="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGODESTINO,1,3)!="JEF") & ///
											 ORIGEN!=DESTINO
replace MOVIMIENTO="5. e_APE -> j_APE" if 	(AREAORIGEN =="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGOORIGEN,1,3) !="JEF") & ///
											(AREADESTINO=="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGODESTINO,1,3)=="JEF")
replace MOVIMIENTO="6. j_APE -> j_OPP" if 	(AREAORIGEN =="PRESUPUESTO Y ENDEUDAMIENTO" 			& substr(CARGOORIGEN,1,3) =="JEF") & ///
											(AREADESTINO=="OFICINA DE PLANEAMIENTO Y PRESUPUESTO" 	& substr(CARGODESTINO,1,3)=="JEF")
*
br if MOVIMIENTO==""

drop if inlist(AREAORIGEN,"PLANEAMIENTO E INFORMACION","GESTION ESTRATEGICA","MODERNIZACION INSTITUCIONAL","PLANEAMIENTO E INFORMACION") & MOVIMIENTO==""
drop if ORIGEN=="MAGALY ARREDONDO BOHORQUEZ" & MOVIMIENTO==""
drop if DESTINO=="MAGALY ARREDONDO BOHORQUEZ" & MOVIMIENTO==""
drop if TIPODEMOVIMIENTO=="ARCHIVADO" & MOVIMIENTO==""
drop if MOVIMIENTO=="" & strpos(ACCIONES,"ATENCIÓN")==0 & strpos(ACCIONES,"CONTESTACIÓN")==0
drop if MOVIMIENTO=="" & ORIGEN==DESTINO

merge m:1 HR using "${ruta_output}\tmp_ccp_wsp_js.dta", keep(master matched) nogen
keep if CCP=="CCP"

gen _dia=substr(FECHADELLEGADA,1,2)
gen _mes=substr(FECHADELLEGADA,4,2)
gen _ano=substr(FECHADELLEGADA,7,4)
destring _dia _mes _ano, replace
gen fecha_llegada=mdy(_mes,_dia,_ano)
*replace fecha_llegada=fecha_llegada+21916
drop _dia _mes _ano
format fecha_llegada %td

gen _dia=substr(FECHADESALIDA,1,2)
gen _mes=substr(FECHADESALIDA,4,2)
gen _ano=substr(FECHADESALIDA,7,4)
destring _dia _mes _ano, replace
gen fecha_salida=mdy(_mes,_dia,_ano)
*replace fecha_salida=fecha_salida+21916
drop _dia _mes _ano
format fecha_salida %td

bys HR ARCHIVO: egen fecha_archivo=min(fecha_llegada)
format fecha_archivo %td

drop OBSERVACIONES FECHAARCHIVADO DESCRIPCIONDEVOLUCIÓN MOTIVOARCHIVADO USUARIO XXX

sort fecha_archivo HR MOVIMIENTO

bys HR: egen fecha_hr_min=min(fecha_archivo)
format fecha_hr_min %td

gen mov1=MOVIMIENTO=="1. UO -> j_OPP"
gen mov2=MOVIMIENTO=="2. j_OPP -> j_APE"
gen mov3=MOVIMIENTO=="3. j_APE -> e_APE"
gen mov4=MOVIMIENTO=="4. e_APE -> e_APE"
gen mov5=MOVIMIENTO=="5. e_APE -> j_APE"
gen mov6=MOVIMIENTO=="6. j_APE -> j_OPP"

forvalues x=1/6 {
	bys HR ARCHIVO: egen _mov`x'=max(mov`x')
}

drop if MOVIMIENTO=="1. UO -> j_OPP" & _mov1==1 & _mov2==0 & _mov3==0 & _mov4==0 & _mov5==0 & _mov6==0

duplicates tag HR ARCHIVO MOVIMIENTO, gen(dup)
fre MOVIMIENTO if dup>0

gen ESP=DESTINO if inlist(MOVIMIENTO,"3. j_APE -> e_APE","4. e_APE -> e_APE")
bys HR ARCHIVO (MOVIMIENTO fecha_llegada): gen nro=_n if ESP!=""
replace ESP=ESP[_n-1]+"->"+ESP if nro>nro[_n-1] & nro<.
gen largo_esp=length(ESP)
sort HR ARCHIVO largo_esp
bys HR ARCHIVO (largo_esp): replace ESP=ESP[_N] if largo_esp[_n]<largo_esp[_N]

drop nro largo_esp

sort fecha_hr_min HR fecha_archivo MOVIMIENTO fecha_llegada
drop mov1 mov2 mov3 mov4 mov5 mov6 _mov1 _mov2 _mov3 _mov4 _mov5 _mov6 dup

export excel using "${ruta_output}\BD_HR_CCP_WSP_JS_${fecha}.xlsx", replace first(var) sheet(BD_RAW)

**

collapse (min) fecha_llegada (max) fecha_salida, by(HR ARCHIVO MOVIMIENTO ESP)
encode MOVIMIENTO, gen(_Mov)
drop MOVIMIENTO
reshape wide fecha_llegada fecha_salida, i(HR ARCHIVO) j(_Mov)

egen fecha_Eape_Jape=rowmax(fecha_salida3 fecha_salida4)
format fecha_Eape_Jape %td
order fecha_Eape_Jape, before(fecha_salida3)

drop fecha_llegada2 fecha_llegada3 fecha_llegada4 fecha_llegada5 fecha_llegada6 fecha_salida3 fecha_salida4

ren (fecha_llegada1 fecha_salida1 fecha_salida2 fecha_salida5 fecha_salida6) ///
	(fecha_entra_opp fecha_opp_Jape fecha_Jape_Eape fecha_Jape_opp fecha_salida_opp)
*

gen durac_opp_Jape	=""
gen durac_Jape_Eape =""
gen durac_Eape_Jape =""
gen durac_Jape_opp	=""
gen durac_opp_uo  	=""
gen durac_total     =""
order durac_*, after(fecha_salida_opp)

gen ANALISIS="ANALISIS" if fecha_opp_Jape<. & fecha_Jape_Eape<. & fecha_Eape_Jape<. & fecha_Jape_opp<. & fecha_salida_opp<. // solo expedientes atendidos
keep if ANALISIS=="ANALISIS"
drop ANALISIS

bys HR (ARCHIVO): gen Nro=_n
*drop ARCHIVO

order HR Nro
order ARCHIVO, last
lab var fecha_entra_opp  "Entrada a OPP"
lab var fecha_opp_Jape 	 "JOPP -> JAPE"
lab var fecha_Jape_Eape  "JAPE -> EAPE"
lab var fecha_Eape_Jape  "EAPE -> JAPE"
lab var fecha_Jape_opp 	 "JAPE -> JOPP"
lab var fecha_salida_opp "Salida de OPP"
lab var durac_opp_Jape	"(1) Deriva OPP->APE"
lab var durac_Jape_Eape "(2) Deriva APE->ESP"
lab var durac_Eape_Jape "(3) Deriva ESP->APE"
lab var durac_Jape_opp 	"(4) Deriva APE->OPP"
lab var durac_opp_uo 	"(5) Deriva OPP->UO"
lab var durac_total 	"Total Días Háb."
lab var ESP "Especialistas"

duplicates drop HR fecha_salida_opp, force
merge 1:1 HR fecha_salida_opp using "${ruta_output}\tmp_documentos_rpta_opp.dta", nogen keep(master matched)

gen _Link_Requerimiento_UO="https://sgdrepositorio.pvn.gob.pe/Archivos/"+ARCHIVO if ARCHIVO!=""
gen _Link_Respuesta_OPP="https://sgdrepositorio.pvn.gob.pe/Archivos/"+ARCHIVO_OPP if ARCHIVO_OPP!=""
drop ARCHIVO ARCHIVO_OPP
gen Link_Requerimiento_UO=""
gen Link_Respuesta_OPP=""

lab var Link_Requerimiento_UO "Link Requerimiento UO"
lab var Link_Respuesta_OPP "Link Respuesta OPP"

export excel using "${ruta_output}\BD_HR_CCP_WSP_JS_${fecha}.xlsx", first(varl) sheet(BD_OK, replace) cell(A2)
putexcel set "${ruta_output}\BD_HR_CCP_WSP_JS_${fecha}.xlsx", sheet(BD_OK) modify
putexcel C1 = "Fechas"
putexcel I1 = "Días Hábiles"
putexcel I3 = `"=SI(D3="";0;DIAS.LAB.INTL(C3;D3;1;{"1/01/2024";"28/03/2024";"29/03/2024";"1/05/2024";"7/06/2024";"29/06/2024";"23/07/2024";"28/07/2024";"29/07/2024";"6/08/2024";"30/08/2024";"8/10/2024";"1/11/2024";"8/12/2024";"9/12/2024";"25/12/2024"})-1)"'
putexcel N3 = "=SUMA(I3:M3)"
putexcel R3 = `"=SI(P3<>"";HIPERVINCULO(P3;"Requerimiento");"")"'
putexcel S3 = `"=SI(Q3<>"";HIPERVINCULO(Q3;"Respuesta"    );"")"'

cap erase "${ruta_output}\tmp_ccp_wsp_js.dta"
cap erase "${ruta_output}\tmp_documentos_rpta_opp.dta"