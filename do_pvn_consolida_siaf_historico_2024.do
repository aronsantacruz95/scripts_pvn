clear all
set more off

glo data "D:\Usuarios\sanalisisopp6\Documents\Data\"
glo fileHistorico "BD_PDA_PVN_2012-2023.xlsx"

glo fileSIAF2024  "ReporteGasto_pvn_250624_0900"
local hoy=substr("${fileSIAF2024}",18,11)
di "`hoy'"

import excel using "${data}\${fileHistorico}", clear first
keep ano_eje programa_ppto programa_ppto_nombre tipo_act_proy producto_proyecto producto_proyecto_nombre actividad_accion_obra actividad_accion_obra_nombre funcion funcion_nombre division_funcional division_funcional_nombre grupo_funcional grupo_funcional_nombre sec_func meta finalidad meta_nombre departamento_meta departamento_meta_nombre fuente_financiamiento fuente_financiamiento_nombre categoria_gasto categoria_gasto_nombre generica generica_nombre subgenerica subgenerica_nombre subgenerica_det subgenerica_det_nombre especifica especifica_nombre especifica_det especifica_det_nombre monto_pia monto_pim monto_certificado_anual monto_comprometido_anual monto_devengado_enero monto_devengado_febrero monto_devengado_marzo monto_devengado_abril monto_devengado_mayo monto_devengado_junio monto_devengado_julio monto_devengado_agosto monto_devengado_septiembre monto_devengado_octubre monto_devengado_noviembre monto_devengado_diciembre monto_devengado_anual monto_girado_anual

replace programa_ppto="0138" if programa_ppto=="138"
replace programa_ppto="0061" if programa_ppto=="61"
gen programa_pptal=programa_ppto+"."+programa_ppto_nombre
gen tipo_prod_proy="2.PROYECTO" if substr(producto_proyecto,1,1)=="2"
replace tipo_prod_proy="3.PRODUCTO" if substr(producto_proyecto,1,1)=="3"
replace producto_proyecto=producto_proyecto+"."+producto_proyecto_nombre
gen activ_obra_accinv=actividad_accion_obra+"."+actividad_accion_obra_nombre
replace funcion=funcion+"."+funcion_nombre
gen division_fn=division_funcional+"."+division_funcional_nombre
gen grupo_fn=grupo_funcional+"."+grupo_funcional_nombre
destring sec_func meta, replace
replace finalidad=finalidad+"."+meta_nombre
replace departamento_meta=departamento_meta+"."+departamento_meta_nombre
gen fuente_financ=fuente_financiamiento+"."+fuente_financiamiento_nombre
replace categoria_gasto=categoria_gasto+"."+categoria_gasto_nombre
gen clasif="2."+generica+"."+subgenerica+"."+subgenerica_det+"."+especifica+"."+especifica_det
replace generica=generica+"."+generica_nombre
replace subgenerica=subgenerica+"."+subgenerica_nombre
replace subgenerica_det=subgenerica_det+"."+subgenerica_det_nombre
replace especifica=especifica+"."+especifica_nombre
replace especifica_det=especifica_det+"."+especifica_det_nombre

collapse (sum) monto_pia monto_pim monto_certificado_anual monto_comprometido_anual monto_devengado_enero monto_devengado_febrero monto_devengado_marzo monto_devengado_abril monto_devengado_mayo monto_devengado_junio monto_devengado_julio monto_devengado_agosto monto_devengado_septiembre monto_devengado_octubre monto_devengado_noviembre monto_devengado_diciembre monto_devengado_anual monto_girado_anual, by(ano_eje programa_pptal tipo_prod_proy producto_proyecto activ_obra_accinv funcion division_fn grupo_fn sec_func finalidad departamento_meta fuente_financ categoria_gasto clasif generica subgenerica subgenerica_det especifica especifica_det)

drop if monto_pia==0 & monto_pim==0

save "${data}\tmp_2012_2023.dta", replace

import excel using "${data}\${fileSIAF2024}", clear first sheet(SheetGasto)

drop if mto_pia==0 & mto_pim==0
ren mto_pia monto_pia
ren mto_pim monto_pim
ren mto_certificado monto_certificado_anual
ren mto_compro_anual monto_comprometido_anual
ren (mto_devenga_01 mto_devenga_02 mto_devenga_03 mto_devenga_04 mto_devenga_05 mto_devenga_06 mto_devenga_07 mto_devenga_08 mto_devenga_09 mto_devenga_10 mto_devenga_11 mto_devenga_12) (monto_devengado_enero monto_devengado_febrero monto_devengado_marzo monto_devengado_abril monto_devengado_mayo monto_devengado_junio monto_devengado_julio monto_devengado_agosto monto_devengado_septiembre monto_devengado_octubre monto_devengado_noviembre monto_devengado_diciembre)
egen double monto_devengado_anual=rowtotal(monto_devengado_enero monto_devengado_febrero monto_devengado_marzo monto_devengado_abril monto_devengado_mayo monto_devengado_junio monto_devengado_julio monto_devengado_agosto monto_devengado_septiembre monto_devengado_octubre monto_devengado_noviembre monto_devengado_diciembre)
egen double monto_girado_anual=rowtotal(mto_girado_01 mto_girado_02 mto_girado_03 mto_girado_04 mto_girado_05 mto_girado_06 mto_girado_07 mto_girado_08 mto_girado_09 mto_girado_10 mto_girado_11 mto_girado_12)

gen _gen=substr(generica,1,2)
gen _subgen=substr(subgenerica,1,2)
gen _subgendet=substr(subgenerica_det,1,2)
gen _esp=substr(especifica,1,2)
gen _espdet=substr(especifica_det,1,2)
destring _gen _subgen _subgendet _esp _espdet, replace
tostring _gen _subgen _subgendet _esp _espdet, replace
gen clasif="2."+_gen+"."+_subgen+"."+_subgendet+"."+_esp+"."+_espdet

keep ano_eje monto_pia monto_pim monto_certificado_anual monto_comprometido_anual monto_devengado_enero monto_devengado_febrero monto_devengado_marzo monto_devengado_abril monto_devengado_mayo monto_devengado_junio monto_devengado_julio monto_devengado_agosto monto_devengado_septiembre monto_devengado_octubre monto_devengado_noviembre monto_devengado_diciembre monto_devengado_anual monto_girado_anual programa_pptal tipo_prod_proy producto_proyecto activ_obra_accinv funcion division_fn grupo_fn sec_func finalidad departamento_meta fuente_financ categoria_gasto clasif generica subgenerica subgenerica_det especifica especifica_det

order ano_eje programa_pptal tipo_prod_proy producto_proyecto activ_obra_accinv funcion division_fn grupo_fn sec_func finalidad departamento_meta fuente_financ categoria_gasto clasif generica subgenerica subgenerica_det especifica especifica_det clasif

append using "${data}\tmp_2012_2023.dta"

foreach var in producto_proyecto activ_obra_accinv finalidad generica subgenerica subgenerica_det especifica especifica_det {
	replace `var'=subinstr(`var',"ATENCIÃN","ATENCION",.)
	replace `var'=subinstr(`var',"Â°","°",.)
	replace `var'=subinstr(`var',"NIÃO","NIÑO",.)
	replace `var'=subinstr(`var',"PREVENCIÃ?N","PREVENCION",.)
	replace `var'=subinstr(`var',"DIAGNÃ?STICO","DIAGNOSTICO",.)
	replace `var'=subinstr(`var',"PROMOCIÃ?N","PROMOCION",.)
	replace `var'=subinstr(`var',"IMPLEMENTACIÃ?N","IMPLEMENTACION",.)
	replace `var'=subinstr(`var',"EJECUCIÃ?N","EJECUCION",.)
	replace `var'=subinstr(`var',"REACTIVACIÃ?N","REACTIVACION",.)
	replace `var'=subinstr(`var',"ECONÃ?MICA","ECONOMICA",.)
	replace `var'=subinstr(`var',"CAÃETE","CAÑETE",.)
	replace `var'=subinstr(`var',"INTERSECCIÃN","INTERSECCION",.)
	replace `var'=subinstr(`var',"CAMPIÃA","CAMPIÑA",.)
	replace `var'=subinstr(`var',"NIÃO","NIÑO",.)
	replace `var'=subinstr(`var',"DISEÃO","",.)
	replace `var'=subinstr(`var',"IÃAPARI","IÑAPARI",.)
	replace `var'=subinstr(`var',"CAÃ?ETE","CAÑETE",.)
	replace `var'=subinstr(`var',"CAMPIÃ?A","CAMPIÑA",.)
	replace `var'=subinstr(`var',"NIÃ?O","NIÑO",.)
	replace `var'=subinstr(`var',"IÃ?APARI","IÑAPARI",.)
	replace `var'=subinstr(`var',"DISEÃ?O","DISEÑO",.)
	replace `var'=subinstr(`var',"PÃ?SCOBAMBA","PISCOBAMBA",.)
	replace `var'=subinstr(`var',"CHAVIÃ?A","CHAVIÑA",.)
	replace `var'=subinstr(`var',"LOCACIÃ?N","LOCACION",.)
	replace `var'=subinstr(`var',"ENSEÃ?ANZA","ENSEÑANZA",.)
	replace `var'=subinstr(`var',"ENSEÃANZA","ENSEÑANZA",.)
	replace `var'=subinstr(`var',"LOCACIÃ?N","LOCACION",.)
	replace `var'=subinstr(`var',"ENSEÃ?ANZA","ENSEÑANZA",.)
	replace `var'=subinstr(`var',"ENSEÃANZA","ENSEÑANZA",.)
	replace `var'=subinstr(`var',"TÃ?CNICOS","TECNICOS",.)
	replace `var'=subinstr(`var',"JURÃ?DICAS","JURIDICAS",.)
	replace `var'=subinstr(`var',"DIFUSIÃ?N","DIFUSION",.)
	replace `var'=subinstr(`var',"NEGOCIACIÃ?N","NEGOCIACION",.)
	replace `var'=subinstr(`var',"OPERACIÃ?N","OPERACION",.)
	replace `var'=subinstr(`var',"REACTIVACIÃ?N","REACTIVACION",.)
	replace `var'=subinstr(`var',"ECONÃ?MICA","ECONOMICA",.)
	replace `var'=subinstr(`var',"INFORMACIÃ?N","INFORMACION",.)
	replace `var'=subinstr(`var',"ELABORACIÃ?N","ELABORACION",.)
	replace `var'=subinstr(`var',"ACTUALIZACIÃ?N","ACTUALIZACION",.)
	replace `var'=subinstr(`var',"PERIÃ?DICO","PERIODICO",.)
	replace `var'=subinstr(`var',"ASESORÃ?A","ASESORIA",.)
	replace `var'=subinstr(`var',"BONIFICACIÃ?N","BONIFICACION",.)
	replace `var'=subinstr(`var',"PÃ?BLICAS","PUBLICAS",.)
	replace `var'=subinstr(`var',"PUBLICACIÃ?N","PUBLICACION",.)
	
	replace `var'=subinstr(`var',"BAÃOS","BAÑOS",.)
	replace `var'=subinstr(`var',"BAÃOS","BAÑOS",.)
	replace `var'=subinstr(`var',"DAÃADOS","DAÑADOS",.)
	replace `var'=subinstr(`var',"ZUÃIGA","ZUÑIGA",.)
	replace `var'=subinstr(`var',"PERIÃDICO","PERIODICO",.)
	replace `var'=subinstr(`var',"ENCAÃADA","ENCAÑADA",.)
	replace `var'=subinstr(`var',"MAÃAZO","MAÑAZO",.)
	replace `var'=subinstr(`var',"SEÃALIZACION","SEÑALIZACION",.)
	replace `var'=subinstr(`var',"QUIÃOTA","QUIÑOTA",.)
	replace `var'=subinstr(`var',"MAÃ?AZO","MAÑAZO",.)
	replace `var'=subinstr(`var',"QUIÃ?OTA","QUIÑOTA",.)
	replace `var'=subinstr(`var',"CONSTRUCCIÃ?N","CONSTRUCCION",.)
	replace `var'=subinstr(`var',"INTEROCEÃ?NICO","INTEROCEANICO",.)
	replace `var'=subinstr(`var',"PERÃ?","PERU",.)
	replace `var'=subinstr(`var',"SUPERVISIÃ?N","SUPERVISION",.)
	replace `var'=subinstr(`var',"VÃ?A","VIA",.)
	replace `var'=subinstr(`var',"BAÃ?OS","BAÑOS",.)
	replace `var'=subinstr(`var',"ZUÃ?IGA","ZUÑIGA",.)
	replace `var'=subinstr(`var',"DAÃ?ADOS","DAÑADOS",.)
	replace `var'=subinstr(`var',"CAÃ?ON","CAÑON",.)
	replace `var'=subinstr(`var',"DAÃ?ADOS","DAÑADOS",.)
	replace `var'=subinstr(`var',"TINGUIÃ?A","TINGUIÑA",.)
	replace `var'=subinstr(`var',"Ã?URO","ÑURO",.)
	replace `var'=subinstr(`var',"MAÃ?AZO","MAÑAZO",.)
	replace `var'=subinstr(`var',"PIÃ?UTA","PIÑUTA",.)

	replace `var'=strtrim(stritrim(`var'))
}

gen cui=substr(producto_proyecto,1,7)
gen _pro=producto_proyecto if ano_eje==2024
sort cui _pro
bys cui (_pro): replace _pro=_pro[_N]
replace _pro=producto_proyecto if _pro==""
replace producto_proyecto=_pro

drop cui _pro

gen aao=substr(activ_obra_accinv,1,7)
gen _aao=activ_obra_accinv if ano_eje==2024
sort aao _aao
bys aao (_aao): replace _aao=_aao[_N]
replace _aao=activ_obra_accinv if _aao==""
replace activ_obra_accinv=_aao

drop aao _aao

gen cui=substr(producto_proyecto,1,7)
destring cui, replace
order cui, before(producto_proyecto)

sort ano_eje programa_pptal producto_proyecto activ_obra_accinv clasif

export excel using "${data}\BD_PDA_PVN_2012-2023_SIAFOL_`hoy'.xlsx", replace first(var) sheet(BD)

cap erase "${data}\tmp_2012_2023.dta"