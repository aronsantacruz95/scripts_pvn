/*
Antes de correr este script, asegurarse que se han descargado todas las notas: APROBADO y VERIFICADO (PENDIENTE) del mes actual
Meses cerrados:
. 01. Enero
. 02. Febrero
. 03. Marzo
. 04. Abil
. 05. Mayo
. 06. Junio
. 07. Julio
*/

clear all
set more off
set rmsg on, permanently

*glo ruta_input "D:\Usuarios\sanalisisopp6\Documents\Data\Notas\Otras UE\UE001\Años anteriores\2023"
glo ruta_input "D:\Usuarios\sanalisisopp6\Documents\Data\Notas"
glo ruta_output "D:\Usuarios\sanalisisopp6\Documents\Data"

// Obtener fecha y hora actual

local fecha = subinstr("$S_DATE"," ","",.)
local hora = substr("$S_TIME",1,2)+substr("$S_TIME",4,2)

cd "${ruta_input}"
local files: dir . files "*.xls"
set obs 0
gen XXX=""
save "BD_NOTAS.dta", replace
foreach file in `files'{
	clear
	import excel using "`file'", clear allstring
	append using "BD_NOTAS.dta"
	save "BD_NOTAS.dta", replace
}

use "BD_NOTAS.dta", clear

drop A D G I J

gen sec_nota=substr(B,6,10) if substr(B,1,6)=="NOTA 0"
gen mes_eje=C if B=="MES:"
gen estado_nota=F if E=="ESTADO:"
gen fecha_solicitud=C if B=="FECHA DE SOLICITUD:"
gen fecha_aprobacion=F if E=="FECHA:"
gen tipo_modificacion=C if B=="TIPO MODIFICACIÓN:"
gen doc_aprobacion=F if E=="DOCUMENTO:"
gen des_texto=C if B=="JUSTIFICACIÓN:"

gen new_var = substr(B, 1, 26) + substr(B, length(B)-10, length(B)) if substr(B,5,1)==" " & substr(B,10,1)==" " & substr(B,18,1)==" " & substr(B,26,1)==" "
replace new_var=stritrim(strtrim(new_var))
split new_var, p(" ") g(tmp_)

gen borra=(length(tmp_1)!=4 | length(tmp_2)!=4 | length(tmp_3)!=7 | length(tmp_4)!=7 | length(tmp_5)!=2 | length(tmp_6)!=3 | length(tmp_7)!=4)
replace new_var="" if borra==1
forvalues x=1/7 {
	replace tmp_`x'="" if borra==1
}
drop new_var borra
ren (tmp_1 tmp_2 tmp_3 tmp_4 tmp_5 tmp_6 tmp_7) (sec_func programa_presupuestal producto_proyecto acc_obra_actividad funcion division_funcional grupo_funcional)
gen meta=substr(B,7,5) if substr(B,1,5)=="Meta:"
gen finalidad=substr(B,15,7) if substr(B,1,5)=="Meta:"
gen fuente_financ=B if inlist(B,"00 RECURSOS ORDINARIOS","09 RECURSOS DIRECTAMENTE RECAUDADOS","13 DONACIONES Y TRANSFERENCIAS","19 RECURSOS POR OPERACIONES OFICIALES DE CREDITO")
gen categoria_gasto=B if inlist(B,"5  GASTOS CORRIENTES","6  GASTOS DE CAPITAL")
gen clasificador=B if substr(B,1,1)=="2"

gen monto_credito=H if clasificador!=""
gen monto_anulacion=F if clasificador!=""

foreach x of varlist sec_nota-clasificador {
	replace `x'=`x'[_n-1] if missing(`x')
}

replace mes_eje="01. Enero" if mes_eje=="ENERO"
replace mes_eje="02. Febrero" if mes_eje=="FEBRERO"
replace mes_eje="03. Marzo" if mes_eje=="MARZO"
replace mes_eje="04. Abril" if mes_eje=="ABRIL"
replace mes_eje="05. Mayo" if mes_eje=="MAYO"
replace mes_eje="06. Junio" if mes_eje=="JUNIO"
replace mes_eje="07. Julio" if mes_eje=="JULIO"
replace mes_eje="08. Agosto" if mes_eje=="AGOSTO"
replace mes_eje="09. Setiembre" if mes_eje=="SETIEMBRE"
replace mes_eje="10. Octubre" if mes_eje=="OCTUBRE"
replace mes_eje="11. Noviembre" if mes_eje=="NOVIEMBRE"
replace mes_eje="12. Diciembre" if mes_eje=="DICIEMBRE"

keep if monto_credito!="" | monto_anulacion!=""
keep sec_nota-clasificador monto_credito monto_anulacion

gen tipo_pro=substr(producto_proyecto,1,1)
order tipo_pro, before(producto_proyecto)

destring sec_nota sec_func producto_proyecto tipo_pro meta, replace

gen tipo_doc_aprob=""
replace tipo_doc_aprob="016.CONVENIO SUSCRITO" if substr(doc_aprobacion,1,3)=="016"
replace tipo_doc_aprob="108.RESOLUCION MINISTERIAL" if substr(doc_aprobacion,1,3)=="108"
replace tipo_doc_aprob="109.RESOLUCION EJECUTIVA" if substr(doc_aprobacion,1,3)=="109"
replace tipo_doc_aprob="110.RESOLUCION DIRECTORAL" if substr(doc_aprobacion,1,3)=="110"
replace tipo_doc_aprob="111.RESOLUCION PRESIDENCIAL" if substr(doc_aprobacion,1,3)=="111"
replace tipo_doc_aprob="112.RESOLUCION EJECUTIVA PRESIDENCIAL" if substr(doc_aprobacion,1,3)=="112"
replace tipo_doc_aprob="113.RESOLUCION SECRETARIA GENERAL" if substr(doc_aprobacion,1,3)=="113"
replace tipo_doc_aprob="219.RESOLUCIÓN RECTORAL" if substr(doc_aprobacion,1,3)=="219"
order tipo_doc_aprob, before(doc_aprobacion)
replace doc_aprobacion=substr(doc_aprobacion,7,100)

// gen _dia=substr(fecha_solicitud,1,2)
// gen _mes=substr(fecha_solicitud,4,2)
// gen _año=substr(fecha_solicitud,7,4)
// destring _dia _mes _año, replace
// gen tmp = mdy(_mes,_dia,_año)
// drop _dia _mes _año

// gen tmp=date(fecha_solicitud,"DMY",1900)
// order tmp, after(fecha_solicitud)
// drop fecha_solicitud
// ren tmp fecha_solicitud

// gen _dia=substr(fecha_aprobacion,1,2)
// gen _mes=substr(fecha_aprobacion,4,2)
// gen _año=substr(fecha_aprobacion,7,4)
// destring _dia _mes _año, replace
// gen tmp = mdy(_mes,_dia,_año)
// drop _dia _mes _año

// gen tmp=date(fecha_aprobacion,"DMY",1900)
// order tmp, after(fecha_aprobacion)
// drop fecha_aprobacion
// ren tmp fecha_aprobacion

destring monto_credito monto_anulacion, replace
recode monto_credito monto_anulacion (.=0)

gen double modificacion=monto_credito-monto_anulacion
sort sec_nota modificacion

ren mes_eje mes_soli
gen mes_aprob=substr(fecha_aprobacion,4,2)
replace mes_aprob="01. Enero" if mes_aprob=="01"
replace mes_aprob="02. Febrero" if mes_aprob=="02"
replace mes_aprob="03. Marzo" if mes_aprob=="03"
replace mes_aprob="04. Abril" if mes_aprob=="04"
replace mes_aprob="05. Mayo" if mes_aprob=="05"
replace mes_aprob="06. Junio" if mes_aprob=="06"
replace mes_aprob="07. Julio" if mes_aprob=="07"
replace mes_aprob="08. Agosto" if mes_aprob=="08"
replace mes_aprob="09. Setiembre" if mes_aprob=="09"
replace mes_aprob="10. Octubre" if mes_aprob=="10"
replace mes_aprob="11. Noviembre" if mes_aprob=="11"
replace mes_aprob="12. Diciembre" if mes_aprob=="12"
order mes_aprob, after(mes_soli)

cap erase "BD_NOTAS.dta"

export excel using "${ruta_output}\notas_al_`fecha'_`hora'.xlsx", replace sheet(BD) first(var)