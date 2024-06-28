import time
import pandas as pd
import numpy as np
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from bs4 import BeautifulSoup
from datetime import datetime

# para contabilizar tiempo de demora
start = time.time() # inicia toma de tiempo

current_datetime = datetime.now().strftime("%d%m%Y_%H%M")

# si es prueba colocar "_prueba", de lo contrario dejar en blanco
#sufijo = '_MODIFDAN2601'
sufijo = '_actf12b260624'

# ----------------- MODIFICABLE
#
# ruta de entrada
PATH_INPUT = 'D:/Usuarios/sanalisisopp6/Documents/Data/'
# ruta de salida
PATH_OUTPUT = 'D:/Usuarios/sanalisisopp6/Documents/Data/'
# nombre del archivo output
FILE_OUTPUT1 = 'infoF12B_{}{}.xlsx'.format(current_datetime,sufijo)
# FILE_OUTPUT2 = 'infoF12BSSIPMICAT_{}{}.xlsx'.format(d1,sufijo)
# nombre del archivo con CUIs
FILE_CUI = 'cuis{}.xlsx'.format(sufijo)
# tiempo que deja cargar cada página
timesleep=1
#
# ----------------- MODIFICABLE

service = Service(executable_path="D:/Usuarios/sanalisisopp6/Desktop/instalaPython/chromedriver.exe")
options = webdriver.ChromeOptions()
options.add_argument("--start-maximized")
driver = webdriver.Chrome(service=service, options=options)
#driver = webdriver.Chrome(chrome_options=options)
BBDD = pd.DataFrame()

# Ncui = "2309055"

## INICIA BUCLE

file_xlsx = PATH_INPUT + FILE_CUI # ruta y nombre de listado id_entidad
df_xlsx = pd.read_excel(file_xlsx) # lee el excel con el listado id_entidad
cuis = df_xlsx['CUIS'].tolist() # convierte la columna 'id_entidad' en una lista

for Ncui in cuis:

    # F12B
    # ====
    
    web1 = "https://ofi5.mef.gob.pe/invierte/seguimiento/verFichaSeguimiento/"
    web = web1+str(Ncui)
    print(Ncui)
    
    driver.get(web)
    
    #time.sleep(0.5)
    
    pageHTML = driver.page_source
    soup = BeautifulSoup(pageHTML, 'lxml')
    
    alerta = ''
    try:
        tmp = soup.findAll(attrs={"class": "col-md-12"})[0]
        alerta = tmp.get_text()
    except:
        pass
   
    if alerta=='':
        fum = ''
        try:
            celda1 = soup.findAll(attrs={"class": "form-group"})[1]
            fum = celda1.get_text()
        except:
            fum = ''
        fum = fum.strip()
        fum = fum[0:10:1]
        i = 0
        if (fum==''):
            while (fum=='') and (i < 5):
                driver.get(web)
                time.sleep(i)
                pageHTML = driver.page_source
                soup = BeautifulSoup(pageHTML, 'lxml')
                try:
                    celda1 = soup.findAll(attrs={"class": "form-group"})[1]
                    fum = celda1.get_text()
                except:
                    fum = ''
                fum = fum.strip()
                fum = fum[0:10:1]
                i += 1
                print(i)
        if (i==5):
            fum = ''
            proyecto = ''
            # costo = ''
            pim23 = ''
            devacum = ''
            dev23 = ''
            devacum22 = ''
            uei = ''
            f12b_01 = ''
            f12b_02 = ''
            f12b_03 = ''
            f12b_04 = ''
            f12b_05 = ''
            f12b_06 = ''
            f12b_07 = ''
            f12b_08 = ''
            f12b_09 = ''
            f12b_10 = ''
            f12b_11 = ''
            f12b_12 = ''
            progf12b = ''
            dev_01 = ''
            dev_02 = ''
            dev_03 = ''
            dev_04 = ''
            dev_05 = ''
            dev_06 = ''
            dev_07 = ''
            dev_08 = ''
            dev_09 = ''
            dev_10 = ''
            dev_11 = ''
            dev_12 = ''
            devf12b = ''
        
        if (i<5):
            celda10 = soup.findAll(attrs={"class": "form-group"})[10]
            uei = ''
            uei = celda10.get_text()
            uei = uei.strip()
            
            celda2 = soup.findAll(attrs={"class": "form-group"})[2]
            proyecto = celda2.get_text()
            proyecto = proyecto.strip()
            
            # celda3 = soup.findAll(attrs={"class": "form-group"})[3]
            # costo = celda3.get_text()
            # costo = costo.strip()
            # costo = costo.replace('S/','')
            # costo = costo.replace(',','')
            # costo = float(costo)
            
            celda4 = soup.findAll(attrs={"class": "form-group"})[4]
            pim23 = celda4.get_text()
            pim23 = pim23.strip()
            pim23 = pim23.replace('S/','')
            pim23 = pim23.replace(',','')
            pim23 = float(pim23)
            
            celda5 = soup.findAll(attrs={"class": "form-group"})[5]
            devacum = celda5.get_text()
            devacum = devacum.strip()
            devacum = devacum.replace('S/','')
            devacum = devacum.replace(',','')
            devacum = float(devacum)
            
            celda6 = soup.findAll(attrs={"class": "form-group"})[6]
            dev23 = celda6.get_text()
            dev23 = dev23.strip()
            dev23 = dev23.replace('S/','')
            dev23 = dev23.replace(',','')
            dev23 = float(dev23)
            
            devacum22 = devacum-dev23
            
            # Busca todas las tablas en la página
            tablas = soup.find_all('table')
            
            # Encuentra la tabla que contiene el texto "Programación financiera actualizada"
            tabla_objetivo = None
            for tabla in tablas:
                if "Programación financiera actualizada" in tabla.get_text():
                    tabla_objetivo = tabla
                    break
            
            df = pd.read_html(str(tabla_objetivo))[0]
            
            df.columns= ['v1','v2','mes','progf12b','v5','devf12b']
            df = df[['mes','progf12b','devf12b']]
            
            df['progf12b'] = df['progf12b'].str.replace('S/. ','')
            df['progf12b'] = df['progf12b'].str.replace('S/.','0.')
            df['progf12b'] = df['progf12b'].str.replace('S/','')
            df['progf12b'] = df['progf12b'].str.replace(',','')
            #df['progf12b'] = df['progf12b'].astype(float)
            
            df['devf12b'] = df['devf12b'].str.replace('S/. ','')
            df['devf12b'] = df['devf12b'].str.replace('S/.','0.')
            df['devf12b'] = df['devf12b'].str.replace('S/','')
            df['devf12b'] = df['devf12b'].str.replace(',','')
            
            f12b_01 = df['progf12b'].values[-13]
            f12b_02 = df['progf12b'].values[-12]
            f12b_03 = df['progf12b'].values[-11]
            f12b_04 = df['progf12b'].values[-10]
            f12b_05 = df['progf12b'].values[-9]
            f12b_06 = df['progf12b'].values[-8]
            f12b_07 = df['progf12b'].values[-7]
            f12b_08 = df['progf12b'].values[-6]
            f12b_09 = df['progf12b'].values[-5]
            f12b_10 = df['progf12b'].values[-4]
            f12b_11 = df['progf12b'].values[-3]
            f12b_12 = df['progf12b'].values[-2]
            progf12b = df['progf12b'].values[-1]
            
            dev_01 = df['devf12b'].values[-13]
            dev_02 = df['devf12b'].values[-12]
            dev_03 = df['devf12b'].values[-11]
            dev_04 = df['devf12b'].values[-10]
            dev_05 = df['devf12b'].values[-9]
            dev_06 = df['devf12b'].values[-8]
            dev_07 = df['devf12b'].values[-7]
            dev_08 = df['devf12b'].values[-6]
            dev_09 = df['devf12b'].values[-5]
            dev_10 = df['devf12b'].values[-4]
            dev_11 = df['devf12b'].values[-3]
            dev_12 = df['devf12b'].values[-2]
            devf12b = df['devf12b'].values[-1]
            
            #df['devf12b'] = df['devf12b'].astype(float)
            
            pendiente = ''
            deficitf12b = ''
            maxhabilitar = ''
            
            _infoF12B = np.array([[0]])
            infoF12B = pd.DataFrame(_infoF12B)
            del _infoF12B
            infoF12B['fum'] = fum
            infoF12B["cui"] = Ncui
            infoF12B["proyecto"] = proyecto
            # infoF12B["costo"] = costo
            infoF12B["pim23"] = pim23
            infoF12B["devacum22"] = devacum22
            infoF12B["uei"] = uei
            
            infoF12B["f12b_01"] = f12b_01
            infoF12B["f12b_02"] = f12b_02
            infoF12B["f12b_03"] = f12b_03
            infoF12B["f12b_04"] = f12b_04
            infoF12B["f12b_05"] = f12b_05
            infoF12B["f12b_06"] = f12b_06
            infoF12B["f12b_07"] = f12b_07
            infoF12B["f12b_08"] = f12b_08
            infoF12B["f12b_09"] = f12b_09
            infoF12B["f12b_10"] = f12b_10
            infoF12B["f12b_11"] = f12b_11
            infoF12B["f12b_12"] = f12b_12
            infoF12B["progf12b"] = progf12b
            
            infoF12B["dev_01"] = dev_01
            infoF12B["dev_02"] = dev_02
            infoF12B["dev_03"] = dev_03
            infoF12B["dev_04"] = dev_04
            infoF12B["dev_05"] = dev_05
            infoF12B["dev_06"] = dev_06
            infoF12B["dev_07"] = dev_07
            infoF12B["dev_08"] = dev_08
            infoF12B["dev_09"] = dev_09
            infoF12B["dev_10"] = dev_10
            infoF12B["dev_11"] = dev_11
            infoF12B["dev_12"] = dev_12
            infoF12B["devf12b"] = devf12b
            
            infoF12B["pendiente"] = pendiente
            infoF12B["deficitf12b"] = deficitf12b
            infoF12B["maxhabilitar"] = maxhabilitar
            infoF12B["dev23"] = dev23
            
            BBDD = pd.concat([BBDD, infoF12B], axis=0, sort=False)
            del infoF12B

BBDD = BBDD[['cui','proyecto','uei','fum','devacum22','pim23','f12b_01','f12b_02','f12b_03','f12b_04','f12b_05','f12b_06','f12b_07','f12b_08','f12b_09','f12b_10','f12b_11','f12b_12','progf12b','dev_01','dev_02','dev_03','dev_04','dev_05','dev_06','dev_07','dev_08','dev_09','dev_10','dev_11','dev_12','devf12b']]

# Función para mover el guion al inicio de la cadena si está al final
def mover_guion_al_inicio(texto):
    if isinstance(texto, str) and texto.endswith('-'):  # Verificamos si el valor es una cadena y termina con "-"
        return '-' + texto[:-1]
    else:
        return texto
BBDD['dev_01'] = BBDD['dev_01'].apply(mover_guion_al_inicio)
BBDD['dev_02'] = BBDD['dev_02'].apply(mover_guion_al_inicio)
BBDD['dev_03'] = BBDD['dev_03'].apply(mover_guion_al_inicio)
BBDD['dev_04'] = BBDD['dev_04'].apply(mover_guion_al_inicio)
BBDD['dev_05'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_06'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_07'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_08'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_09'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_10'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_11'] = BBDD['dev_05'].apply(mover_guion_al_inicio)
BBDD['dev_12'] = BBDD['dev_05'].apply(mover_guion_al_inicio)

BBDD[['devacum22','pim23','f12b_01','f12b_02','f12b_03','f12b_04','f12b_05','f12b_06','f12b_07','f12b_08','f12b_09','f12b_10','f12b_11','f12b_12','progf12b','dev_01','dev_02','dev_03','dev_04','dev_05','dev_06','dev_07','dev_08','dev_09','dev_10','dev_11','dev_12','devf12b']] = BBDD[['devacum22','pim23','f12b_01','f12b_02','f12b_03','f12b_04','f12b_05','f12b_06','f12b_07','f12b_08','f12b_09','f12b_10','f12b_11','f12b_12','progf12b','dev_01','dev_02','dev_03','dev_04','dev_05','dev_06','dev_07','dev_08','dev_09','dev_10','dev_11','dev_12','devf12b']].apply(pd.to_numeric)
BBDD.to_excel('{}{}'.format(PATH_OUTPUT,FILE_OUTPUT1),sheet_name='BD',index=False)

driver.close()

print("Ini: ", current_datetime)
print("Fin: ", datetime.now().strftime("%d%m%Y_%H%M"))

# para contabilizar tiempo de demora
end = time.time() # fin de toma de tiempo
nseconds = end-start # calcula tiempo (segundos)
nseconds=int(nseconds) # se pasa a enteros
print('Segundos transcurridos:',nseconds) # imprime segundos de demora