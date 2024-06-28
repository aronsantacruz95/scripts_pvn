clear all
set more off
set rmsg on, permanently

glo ruta_input "D:\Usuarios\sanalisisopp6\Documents\Data\"
*glo ruta_input "D:\Usuarios\sanalisisopp6\Documents\Data\SIAF Años anteriores"
glo ruta_output "D:\Usuarios\sanalisisopp6\Documents\Data\"

// salto
glo salto 50000
// archivo
glo archivo "BD_PDA_PVN_2024_180624"
*glo archivo "PPTO_0138_GL_2023 -190224"

*glo delimitador "|" // OE
glo delimitador "," // Datos Abiertos MEF o OE 2016

// base vacia
import delimited using "${ruta_input}\\${archivo}", clear varnames(1) delimiters("${delimitador}") stringcols(_all)
*destring monto_pia-monto_girado_anual, replace
export excel using "${ruta_input}\\${archivo}.xlsx", replace first(var) sheet(BD)

// *collapse (sum) monto_pim, by(sec_ejec ejecutora ejecutora_nombre producto_proyecto rubro)
// destring producto_proyecto monto_pia monto_pim monto_certificado monto_comprometido_anual monto_comprometido monto_devengado monto_girado, replace
// order tipo_act_proy_nombre, after(tipo_act_proy)
// export excel using "${ruta_input}\\${archivo}.xlsx", replace first(var) sheet(BD)
