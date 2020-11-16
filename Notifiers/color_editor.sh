#!/bin/bash

#  Created by Андрей Антипов on 14.11.2020.#  Copyright © 2020 gosvamih. All rights reserved.

############################################################################## Mount EFI Color Mode Editor #######################################################################################################
prog_vers="1.8.0"
edit_vers="061"
serv_vers="008"
##################################################################################################################################################################################################################
# https://github.com/Andrej-Antipov/MountEFI/releases

col=94; lines=50; hints=0
clear && printf '\e[8;45;94t' && printf '\e[3J' && printf "\033[H"

presetName="$1"

CONFPATH="${HOME}/.MountEFIconf.plist"

SAVE_COLOR_MODE_PRESET(){
 if [[ $(echo "${MountEFIconf}" | grep -o "ColorModeData</key>") = "" ]]; then plutil -insert ColorModeData -xml  '<dict/>'   "${CONFPATH}"; fi
 cm_string=""; for i in ${!cm_ptr[@]}; do cm_string+="${cm[i]}+"; done; cm_string="${cm_string%?}"
# cm_ptr_string=""; for i in ${!cm_ptr[@]}; do cm_ptr_string+="${cm_ptr[i]}+"; done; cm_ptr_string="${cm_ptr_string%?}"
 plutil -replace ColorModeData."$presetName" -string "$cm_string" "${CONFPATH}"
# plutil -replace ColorModeStruct -string "$cm_ptr_string" "${CONFPATH}"; MountEFIconf=$( cat "${CONFPATH}" )
}

GET_COLOR_STRUCTURE(){
cm_ptr=( head_ast head_str head_os head_X head_sch head_upd_sch head_upd_sch_num head_upd_sch_br head_upd_sch_sp head_num_sch head_sch_br head_pls \
head_pls_str head_pls_qts head_sata head_usb dots_line1 dots_line2 dots_line3 num_sata num_sata_br num_usb num_usb_br mount_pls mount_dot dn_sata dn_usb dn_bsd_sata pn_size_sata \
pn_size_msata dn_bsd_usb pn_size_usb pn_size_musb sata_bsd sata_bsp usb_bsd usb_bsp rv0 kh_str curs_str curs_num_1 curs_num_2 ld_unrec ld_oc ld_cl \
ld_wn ld_rf ld_gb ld_oth cl_Q cl_P cl_U cl_E cl_A cl_S cl_I cl_V cl_C cl_O cl_L cl_ast cl_str cl_conf ld_srch ld_srch_sp ld_srch_bt rv1 rv2 rv3 clr dark)
for i in ${!cm_ptr[@]}; do export ${cm_ptr[i]}=$i; done
}

GET_COLOR_MODE_PRESET(){
cm=()
if [[ ! $(echo "${MountEFIconf}" | grep -o "ColorModeData</key>") = "" ]]; then
    i=1
    while true; do if [[ $(echo "${MountEFIconf}" | grep -A$((i-1))  "ColorModeData</key>" | grep -ow "</dict>" ) = "" ]]; then let "i++"; else break; fi; done
    if [[ ! $(echo "${MountEFIconf}" | grep -A$((i-1)) -o "$presetName</key>") = "" ]]; then
        cm_string=$(echo "${MountEFIconf}" | grep -A$i "ColorModeData</key>" | grep -ow -A1 "$presetName</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/')
        IFS='+'; cm=($cm_string); unset IFS
        GET_COLOR_STRUCTURE
    fi
fi
if [[ "${cm[@]}" = "" ]]; then INIT_COLOR_STRUCT; fi
}

INIT_COLOR_STRUCT(){ 
InterfaceStyle=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
InitValue="\e[0m\e[97m"
if [[ "${presetName}" = "Basic" ]]; then if [[ $InterfaceStyle = "Dark" ]]; then InitValue="\e[0m\e[97m"; else InitValue="\e[0m\e[30m"; fi; fi
if [[ "${presetName}" = "Novel" ]]; then InitValue="\e[0m\e[38;5;237m"; fi
for i in ${!cm_ptr[@]}; do cm[i]="$InitValue"; done; cm[clr]="\e[0m"
}

SET_SYSTEM_THEME(){
profile=`echo "$MountEFIconf" |  grep -A 1 -e  "<key>ThemeProfile</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ "$profile" = "default" ]]; then
system_default=$(plutil -p /Users/$(whoami)/Library/Preferences/com.apple.Terminal.plist | grep "Default Window Settings" | tr -d '"' | cut -f2 -d '>' | xargs)
osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$system_default"'"'
else osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$profile"'"'
fi
}

GET_THEME(){
HasTheme=`echo "$MountEFIconf"  | grep -E "<key>Theme</key>" | grep -Eo Theme | tr -d '\n'`
if [[ $HasTheme = "Theme" ]]; then theme=`echo "$MountEFIconf"  |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`; fi
}

GET_THEME_NAMES(){
plist=()
pcount=$(echo "$MountEFIconf" | grep  -e "<key>BackgroundColor</key>" | wc -l | xargs)
N0=0; N1=2; N2=3
for ((i=0; i<$pcount; i++)); do
plist+=( "$(echo "$MountEFIconf" | grep -A "$N1" Presets | awk '(NR == '$N2')' | sed -e 's/.*>\(.*\)<.*/\1/')" )
let "N1=N1+11"; let "N2=N2+11"; done
plist+=(Basic Grass Homebrew "Man Page" Novel Ocean Pro "Red Sands"  "Silver Aerogel"  "Solid Colors")
plcount=${#plist[@]}; file_list=""
for ((i=0;i<$plcount;i++)) do pl_string="${plist[i]}"; file_list+='"'${pl_string}'"' ; if [[ ! $i = $(($plcount-1)) ]]; then file_list+=","; fi ; done
}

WINDOW_UP(){
osascript -e 'tell application "Terminal" to set frontmost of (every window whose name contains "color_editor.sh")  to true' 2>/dev/null
osascript -e 'tell application "Terminal" to activate' 2>/dev/null
}


ASK_COLOR_MODE_PRESET(){
if [[ $loc = "ru" ]]; then
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Пресеты встроенных и системных тем."  with prompt "Выберите один:" OK button name {"Выбрать"} cancel button name {"Выход"}
end tell
EOD
else
osascript <<EOD
tell application "System Events"    activate
set ThemeList to {$file_list}
set FavoriteThemeAnswer to choose from list ThemeList with title "Presets for built-in and system themes." with prompt "Select one:" OK button name {"Select"} cancel button name {"Exit"}
end tell
EOD
fi
WINDOW_UP
}

REM_MODE(){ plutil -remove ColorModeData."$presetName" "${CONFPATH}" >> /dev/null 2>/dev/null; init=2; }

DELETE_OR_TAKE_NEW_PRESET(){
if [[ $loc = "ru" ]]; then
answer=$(osascript -e 'display dialog "Выберите что сделать? " '"${icon_string}"' buttons {"Удалить мод", "Сохранить и выбрать", "Отмена" } default button "Отмена" ' 2>/dev/null)
else
answer=$(osascript -e 'display dialog "Choose what to do?" '"${icon_string}"' buttons {"Remove mode", "Save and choose", "Cancel" } default button "Cancel" ' 2>/dev/null)
fi
answer=$(echo "${answer}"  | cut -f2 -d':' )
         case "$answer" in
            "Удалить мод"           ) REM_MODE   ; init=2 ;;
            "Remove mode"           ) REM_MODE   ; init=2 ;;
            "Save and choose"       ) inputs="Q" ; init=3 ;;
            "Сохранить и выбрать"   ) inputs="Q" ; init=3 ;;
         esac
}

GET_SET_PRESET(){
if [[ ! $(echo "$presetName" | egrep -ow "Basic|Grass|Homebrew|Man Page|Novel|Ocean|Pro|Red Sands|Silver Aerogel|Solid Colors") = "" ]]; then
 osascript -e 'tell application "Terminal" to  set current settings of window 1 to settings set "'"$presetName"'"' 
else
    GET_CUSTOM_SET
osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background" 
osascript -e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground" 
osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$current_fontname\"" 
osascript -e "tell application \"Terminal\" to set the font size of window 1 to $current_fontsize"
fi
if [[ $(osascript -e 'tell application "Terminal" to get {properties of tab 1} of window 1' | tr  ',' '\n' | grep -A1 "selected:true" | egrep -o "size:[0-9]{1,2}" | cut -f2 -d:) -gt 12 ]]; then
 osascript -e "tell application \"Terminal\" to set the font size of window 1 to 12"
fi
clear && printf '\e[8;45;94t' && printf '\e[3J' && printf "\033[H"
}

GET_CUSTOM_SET(){
######## GET_CURRENT_SET
preset_num=$(echo "$MountEFIconf"  | grep "<key>BackgroundColor</key>" | wc -l | bc)
current=`echo "$MountEFIconf" | grep -A$((preset_num*11)) -ow "<key>Presets</key>" | grep -A 1 -e "<key>${presetName}</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/'`
current_background=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`echo "$MountEFIconf"  | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
########################
}

CLR_UNUSED_STR(){
printf '\033[1f'; printf ' %.0s' {1..94}
printf '\033[3f'; printf ' %.0s' {1..94}
printf '\033[5f'; printf ' %.0s' {1..94}
printf '\033[7f'; printf ' %.0s' {1..94}
printf '\033[9f'; printf ' %.0s' {1..94}
printf '\033[11f'; printf ' %.0s' {1..94}
printf '\033[13f'; printf ' %.0s' {1..94}
printf '\033[20f'; printf ' %.0s' {1..94}
}


UPDATE_GUI(){
bbuf=(); bufStruct=()
for i in 0 1 2 3 4 5 6; do SET_STRUCT_1 $i; done
StructHints[0]="звёздочки заголовка;текст строки заголовка;римская цифра версии мак ос;арабские цифры версии мак ос;"
StructHints[1]="цифра 0;скобка после цифры;текст обновления списка разделов;кавычки вокруг +;плюс;текст строки обозначающий плюсом подключенные разделы;"
StructHints[2]="первый сверху ряд точек;заголовок SATA;"
StructHints[4]="второй сверху ряд точек;заголовок USB;"
StructHints[6]="третий сверху ряд точек;"
UPDATE_BOTTOM
}

UPDATE_BOTTOM(){
for i in 7 8 9 10 11 12; do SET_STRUCT_2 $i; done
case $hints in
    0)  StructHints[7]="буква E;цвет всех строк подсказок по клавишам;"
        StructHints[8]="буква U;цвет всех строк подсказок по клавишам;"    
        StructHints[9]="буква A;цвет всех строк подсказок по клавишам;"
        StructHints[10]="буква I;цвет всех строк подсказок по клавишам;"
        StructHints[11]="буква Q;цвет всех строк подсказок по клавишам;"
        StructHints[12]="строка перед кусором;первое число строки;второе число строки;буква P;буква S;"
        ;;
    1)  StructHints[7]="буква C;цвет всех строк подсказок по клавишам;"
        StructHints[8]="буква O;цвет всех строк подсказок по клавишам;"
        StructHints[9]="буква S;цвет всех строк подсказок по клавишам;"
        StructHints[10]="буква P;цвет всех строк подсказок по клавишам;"
        StructHints[11]="буква V;цвет всех строк подсказок по клавишам;"
        StructHints[12]="строка перед кусором;первое число строки;второе число строки;буква I;"
        ;;
    2)  StructHints[7]="буква O;цвет всех строк подсказок по клавишам;"
        StructHints[8]="буква C;цвет всех строк подсказок по клавишам;"
        StructHints[9]="первое число строки;второе число строки;строка перед кусором;"
        StructHints[10]="буква L;цвет всех строк подсказок по клавишам;"
        StructHints[11]="звёздочки сноски;текст сноски;"
        StructHints[12]="строка перед кусором;текст config.plist;"
        ;;                
esac 
}

SET_STRUCT_1(){
case $1 in
    0)  bbuf[0]=$(printf '\033[2;0f'${cm[head_ast]}'*********           '${cm[head_str]}'Программа монтирует EFI разделы в Mac OS ('${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'11 '${cm[head_str]}'- '${cm[head_X]}'X'${cm[head_str]}'.'${cm[head_os]}'15'${cm[head_str]}')           '${cm[head_ast]}'*********'${cm[clr]}'')
        bufStruct[0]="2 head_ast,0 head_str,20 head_X,62 head_os,64"
        ;;
    1)  bbuf[1]=$(printf '\033[4;0f      '${cm[head_num_sch]}'0'${cm[head_sch_br]}')  '${cm[head_sch]}'повторить поиск разделов                            '${cm[head_pls_qts]}'"'${cm[head_pls]}'+'${cm[head_pls_qts]}'"'${cm[head_pls_str]}' - подключенные  '${cm[clr]}'          ')
        bufStruct[1]="4 head_num_sch,6 head_sch_br,7 head_sch,10 head_pls_qts,62 head_pls,63 head_pls_str,68"
        ;;
    2)  bbuf[2]=$(printf '\033[6;0f    '${cm[dots_line1]}......................................${cm[head_sata]}' SATA '${cm[dots_line1]}......................................${cm[clr]}'      ')
        bufStruct[2]="6 dots_line1,4 head_sata,43"
        ;;
    3)  drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
        bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch')   +   '${cm[dn_sata]}''"$drive"'                       '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'           '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]}$dmsize"'     '${cm[clr]}' ')
        bufStruct[3]="8 num_sata,6 dn_sata,15 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,79 pn_size_msata,84"
        StructHints[3]="числа нумерации для sata;имя диска или псевдоним;имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
        ;;
    4)  bbuf[4]=$(printf '\033[10;0f    '${cm[dots_line2]}''.......................................''${cm[head_usb]}' USB '${cm[dots_line2]}......................................'      ')
        bufStruct[4]="10 dots_line2,4 head_usb,44"
        ;;
    5)  drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
        bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch') ...   '${cm[dn_usb]}''"$drive"'                            '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'           '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]}$dmsize"'     '${cm[clr]}' ')
        bufStruct[5]="12 num_usb,6 dn_usb,15 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,80 pn_size_musb,84"
        StructHints[5]="числа нумерации для USB;имя диска или псевдоним;имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);" 
        ;;
    6)  bbuf[6]=$(printf '\033[14;0f    '${cm[dots_line3]}...................................................................................${cm[clr]}'     ')
        bufStruct[6]="14 dots_line3,4"
        ;;
esac
}

############## строки подсказок по клавишам #############################
SET_STRUCT_2(){
if [[ $hints = 0 ]]; then
           case $1 in
        7)  bbuf[7]=$(printf '\033[15;1f'${cm[cl_E]}'      E  '${cm[kh_str]}'-   подключить EFI диска этой системы     '${cm[clr]}'')
            bufStruct[7]="15 cl_E,6 kh_str,13"
            ;;
	    8)  bbuf[8]=$(printf '\033[16;1f'${cm[cl_U]}'      U  '${cm[kh_str]}'-   отключить ВСЕ подключенные разделы EFI  '${cm[clr]}'')
            bufStruct[8]="16 cl_U,6 kh_str,13"
            ;;
        9)  bbuf[9]=$(printf '\033[17;1f'${cm[cl_A]}'      A  '${cm[kh_str]}'-   настроить авто-подключение EFI          '${cm[clr]}'')
            bufStruct[9]="17 cl_A,6 kh_str,13"
            ;;
       10)  bbuf[10]=$(printf '\033[18;1f'${cm[cl_I]}'      I  '${cm[kh_str]}'-   дополнительное меню                     '${cm[clr]}'')
            bufStruct[10]="18 cl_I,6 kh_str,13"
            ;;
	   11)  bbuf[11]=$(printf '\033[19;1f'${cm[cl_Q]}'      Q  '${cm[kh_str]}'-   закрыть окно и выход из программы     '${cm[clr]}'')
            bufStruct[11]="19 cl_Q,6 kh_str,13"
            ;; 
       12)  bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}'3'${cm[curs_str]}' ( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_U]}'U'${cm[curs_str]}','${cm[cl_E]}'E'${cm[curs_str]}','${cm[cl_A]}'A'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}' или '${cm[cl_Q]}'Q'${cm[curs_str]}' ):  '${cm[clr]}'            ')
            bufStruct[12]="21 curs_str,2 curs_num_1,19 curs_num_2,24 cl_P,28 cl_S,36"
            ;;
           esac
elif [[ $hints = 1 ]]; then
           case $1 in
       7)   bbuf[7]=$(printf '\033[15;1f'${cm[cl_C]}'      C  '${cm[kh_str]}'-   найти и подключить EFI с загрузчиком Clover '${cm[clr]}'')
            bufStruct[7]="15 cl_C,6 kh_str,13"
            ;;
	   8)   bbuf[8]=$(printf '\033[16;1f'${cm[cl_O]}'      O  '${cm[kh_str]}'-   найти и подключить EFI с загрузчиком Open Core'${cm[clr]}'')
            bufStruct[8]="16 cl_O,6 kh_str,13"
            ;;
	   9)   bbuf[9]=$(printf '\033[17;1f'${cm[cl_S]}'      S  '${cm[kh_str]}'-   вызвать экран настройки MountEFI '${cm[clr]}'')
            bufStruct[9]="17 cl_S,6 kh_str,13"
            ;;
      10)   bbuf[10]=$(printf '\033[18;1f'${cm[cl_P]}'      P  '${cm[kh_str]}'-   открыть config.plist с EFI раздела            '${cm[clr]}'')
            bufStruct[10]="18 cl_P,6 kh_str,13"
            ;; 
      11)   bbuf[11]=$(printf '\033[19;1f'${cm[cl_V]}'      V  '${cm[kh_str]}'-   посмотреть версию программы    '${cm[clr]}'')
            bufStruct[11]="19 cl_V,6 kh_str,13"
            ;;
      12)   bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Введите число от '${cm[curs_num_1]}'0'${cm[curs_str]}' до '${cm[curs_num_2]}''3' '${cm[curs_str]}'( '${cm[cl_P]}'P'${cm[curs_str]}','${cm[cl_O]}'O'${cm[curs_str]}','${cm[cl_C]}'C'${cm[curs_str]}','${cm[cl_S]}'S'${cm[curs_str]}','${cm[cl_I]}'I'${cm[curs_str]}'  или  '${cm[cl_Q]}'Q'${cm[curs_str]}' ):   '${cm[clr]}'          ')
            bufStruct[12]="21 curs_str,2 curs_num_1,19 curs_num_2,24 cl_I,36"
            ;;
           esac
elif [[ $hints = 2 ]]; then 
           case $1 in      
       7)   bbuf[7]=$(printf '\033[15;1f'${cm[cl_O]}'      O  '${cm[kh_str]}'-  открыть первый по списку config.plist OpenCore      '${cm[clr]}'\n')
            bufStruct[7]="15 cl_O,6 kh_str,12"
            ;;  
	   8)   bbuf[8]=$(printf '\033[16;1f'${cm[cl_C]}'      C  '${cm[kh_str]}'-  открыть первый по списку config.plist Сlover        '${cm[clr]}'')
            bufStruct[8]="16 cl_C,6 kh_str,12"
            ;;
       9)   bbuf[9]=$(printf '\033[17;1f'${cm[curs_num_1]}'      0'${cm[kh_str]}'-'${cm[curs_num_2]}'2'${cm[kh_str]}' - открыть config.plist на разделе (томе) номер... '${cm[clr]}'')
            bufStruct[9]="17 curs_num_1,6 curs_num_2,8 kh_str,12"
            ;;
      10)   bbuf[10]=$(printf '\033[18;1f'${cm[cl_L]}'      L  '${cm[kh_str]}'-  открыть config.plist который был открыт ранее.        '${cm[clr]}'')
            bufStruct[10]="18 cl_L,6 kh_str,12"
            ;;
	  11)   bbuf[11]=$(printf '\033[19;1f'${cm[cl_ast]}'      ** '${cm[cl_str]}'возврат в главное меню через 5 сек или любой клавишей.  '${cm[clr]}'')
            bufStruct[11]="19 cl_ast,6 cl_str,9"
            ;;
      12)   bbuf[12]=$(printf '\033[21;1f'${cm[curs_str]}'  Открыть '${cm[cl_conf]}'config.plist'${cm[curs_str]}' ( номер EFI, '${cm[cl_O]}'O'${cm[curs_str]}', '${cm[cl_C]}'C'${cm[curs_str]}', '${cm[cl_L]}'L'${cm[curs_str]}' или Enter ):   '${cm[clr]}'    ')
            bufStruct[12]="21 curs_str,2 cl_conf,10"
            ;;
           esac
fi 
}

SET_LOADER_STRUCT(){
case "$1" in
        Clover )   drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                    bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch')   +   '${cm[dn_sata]}''"$drive"${cm[ld_cl]}'         Clover        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'           '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]}$dmsize"'     '${cm[clr]}' ')
                    bufStruct[3]="8 num_sata,6 dn_sata,15 ld_cl,47 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,79 pn_size_msata,84"
                    ;;
      OpenCore )   drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch') ...   '${cm[dn_usb]}''"$drive"${cm[ld_oc]}'             OpenCore       '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'           '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]}$dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 dn_usb,15 ld_oc,46 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,80 pn_size_musb,84"
                   ;;
      "Windows")   drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch')   +   '${cm[dn_sata]}''"$drive"${cm[ld_wn]}'        Windows        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'           '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]}$dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 dn_sata,15 ld_wn,46 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,79 pn_size_msata,84"
                   ;;
         Linux)    drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch') ...   '${cm[dn_usb]}''"$drive"${cm[ld_gb]}'              Linux         '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'           '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]}$dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 dn_usb,15 ld_gb,47 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,80 pn_size_musb,84"
                   ;;
        Refind)    drive="SanDisk SD8SBAT128G1122"; dsize="209.7"; dmsize="Mb"; bsd=0 ; bsp=1; ch=1
                   bbuf[3]=$(printf '\033[8;0f    '${cm[num_sata]}"  "$ch')   +   '${cm[dn_sata]}''"$drive"${cm[ld_rf]}'         Refind        '${cm[dn_bsd_sata]}disk${cm[sata_bsd]}${bsd}${cm[dn_bsd_sata]}s${cm[sata_bsp]}${bsp}'           '${cm[pn_size_sata]}''"$dsize${cm[pn_size_msata]}$dmsize"'     '${cm[clr]}' ')
                   bufStruct[3]="8 num_sata,6 dn_sata,15 ld_rf,47 dn_bsd_sata,61 sata_bsd,65 sata_bsp,67 pn_size_sata,79 pn_size_msata,84"
                   ;;
"Не распознан")    drive="TOSHIBA MK2555GSXF"; dsize=" 31.6"; dmsize="Gb"; bsd=1 ; bsp=2; ch=2
                   bbuf[5]=$(printf '\033[12;0f    '${cm[num_usb]}"  "$ch') ...   '${cm[dn_usb]}''"$drive"${cm[ld_unrec]}'           Не распознан     '${cm[dn_bsd_usb]}disk${cm[usb_bsd]}${bsd}${cm[dn_bsd_usb]}s${cm[usb_bsp]}${bsp}'           '${cm[pn_size_usb]}''"$dsize${cm[pn_size_musb]}$dmsize"'     '${cm[clr]}' ')
                   bufStruct[5]="12 num_usb,6 dn_usb,15 ld_unrec,44 dn_bsd_usb,61 usb_bsd,65 usb_bsp,67 pn_size_usb,80 pn_size_musb,84"
                   ;;
esac
StructHints[3]="числа нумерации для sata;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
StructHints[5]="числа нумерации для USB;имя диска или псевдоним;имя загрузчика (выбирается клавишей L);имя BSD диска;цифра номера диска;цифра номера раздела;размер раздела;измерение раздела (Mb/Gb);"
}

SET_STRUCT_3(){
case "$1" in
           1)  bbuf[1]=$(printf '\033[4;0f      '${cm[head_upd_sch_num]}'0'${cm[head_upd_sch_br]}')'${cm[head_upd_sch]}'  поиск разделов ..... '${cm[clr]}''"${cm[head_upd_sch_sp]}-\|/${cm[clr]}")
                bufStruct[1]="4 head_upd_sch_num,6 head_upd_sch_br,7 head_upd_sch,10 head_upd_sch_sp,31"
                StructHints[1]="цифра 0 строки поиска;скобка после цифры;текст поиск разделов;спинер;"
                ;;
           12)  bbuf[12]=$(printf '\033[21;0f  '${cm[ld_srch]}'Подождите. Ищем загрузочные разделы с '${cm[ld_srch_bt]}'BOOTx64.efi'${cm[ld_srch]}' ...  '${cm[clr]}''"${cm[ld_srch_sp]}-\|/${cm[clr]}")
                bufStruct[12]="21 ld_srch,2 ld_srch_bt,40 ld_srch_sp,57"
                StructHints[12]="текст строки поиска;bootx64.efi;спинер;"
                ;;
esac
}
CLEAR_BOTTOM(){ for i in 1 2 3 4 5 6 7; do printf '\033['$((14+i))';0;f                                                                           '; done; printf '\033[37;32;f'; }

BACKUP(){ old_cm=(); for i in ${!cm[@]}; do old_cm[i]=${cm[i]}; done ; }

COLOR_MODE(){
#######################################################################################################################################################
################################################### блок установки модификации цветного вывода ######################################################
# cm        # список модификаторов цвета
# cm_ptr   # список указателей на элементы списка модификаторов cm
cm=() 
cm_ptr=( head_ast head_str head_os head_X head_sch head_upd_sch head_upd_sch_num head_upd_sch_br head_upd_sch_sp head_num_sch head_sch_br head_pls \
head_pls_str head_pls_qts head_sata head_usb dots_line1 dots_line2 dots_line3 num_sata num_sata_br num_usb num_usb_br mount_pls mount_dot dn_sata dn_usb dn_bsd_sata pn_size_sata \
pn_size_msata dn_bsd_usb pn_size_usb pn_size_musb sata_bsd sata_bsp usb_bsd usb_bsp rv0 kh_str curs_str curs_num_1 curs_num_2 ld_unrec ld_oc ld_cl \
ld_wn ld_rf ld_gb ld_oth cl_Q cl_P cl_U cl_E cl_A cl_S cl_I cl_V cl_C cl_O cl_L cl_ast cl_str cl_conf ld_srch ld_srch_sp ld_srch_bt rv1 rv2 rv3 clr dark)
for i in ${!cm_ptr[@]}; do export ${cm_ptr[i]}=$i; done

Black="\e[0m\e[30m"  Cyan="\e[0m\e[36m"  LightBlue="\e[0m\e[94m" Red="\e[0m\e[31m" LightGray="\e[0m\e[37m" LightMagenta="\e[0m\e[95m"
Green="\e[0m\e[32m" DarkGray="\e[0m\e[90m" LightCyan="\e[0m\e[96m" Yellow="\e[0m\e[33m" LightRed="\e[0m\e[91m" White="\e[0m\e[97m"
Blue="\e[0m\e[34m" LightGreen="\e[0m\e[92m" Magenta="\e[0m\e[35m" LightYellow="\e[0m\e[93m"
BBlack="\e[0m\e[1;30m" BCyan="\e[0m\e[1;36m" BLightBlue="\e[0m\e[1;94m" BRed="\e[0m\e[1;31m" BLightGray="\e[0m\e[1;37m"
BLightMagenta="\e[0m\e[1;95m" BGreen="\e[0m\e[1;32m" BDarkGray="\e[0m\e[1;90m" BLightCyan="\e[0m\e[1;96m" BYellow="\e[0m\e[1;33m"
BLightRed="\e[0m\e[1;91m" BWhite="\e[0m\e[1;97m" BBlue="\e[0m\e[1;34m" BLightGreen="\e[0m\e[1;92m" BMagenta="\e[0m\e[1;35m" 
BLightYellow="\e[0m\e[1;93m" DBlack="\e[0m\e[2;30m" DCyan="\e[0m\e[2;36m" DLightBlue="\e[0m\e[2;94m" DRed="\e[0m\e[2;31m"
DLightGray="\e[0m\e[2;37m" DLightMagenta="\e[0m\e[2;95m" DGreen="\e[0m\e[2;32m" DDarkGray="\e[0m\e[2;90m" DLightCyan="\e[0m\e[2;96m"
DYellow="\e[0m\e[2;33m" DLightRed="\e[0m\e[2;91m" DWhite="\e[0m\e[2;97m" DBlue="\e[0m\e[2;34m" DLightGreen="\e[0m\e[2;92m" 
DMagenta="\e[0m\e[2;35m" DLightYellow="\e[0m\e[2;93m" cOFF="\e[0m" Dim="\e[0m\e[2m" Bright="\e[0m\e[1m" Orange="\e[38;5;222m" Limon="\e[38;5;116m"
ForSATA="\e[38;5;228m" 

cm[head_ast]="$DWhite"              # звёздочки заголовка
cm[head_str]="$Cyan"                # строка заголовка
cm[head_os]="$Green"                # версия мак ос арабскими
cm[head_X]="$LightMagenta"          # версия мак ос латинскими
cm[head_sch]="$LightGray"           # строка "повторить поиск раздела"
cm[head_upd_sch]="$LightGray"       # строка поиска (по клавише 0)
cm[head_upd_sch_num]="$BCyan"       # цифра ноль в строке поиса по 0
cm[head_upd_sch_br]="$LightGray"    # скобка строки поиска по 0
cm[head_upd_sch_sp]="$LightGray"    # спинер строки поиска по 0
cm[head_num_sch]="$BLightCyan"      # цифра 0 строки повторения поиска
cm[head_sch_br]="$LightGray"        # скобка у строки повторения поиска
cm[head_pls]="$cOFF"                # цвет + у строки "подключенные"
cm[head_pls_str]="$LightGray"       # цвет строки "подключенные"
cm[head_pls_qts]="$DCyan"           # кавычки строки "подключенные"
cm[head_sata]="$ForSATA"            # цвет слова SATA
cm[head_usb]="$Limon"               # цвет слова USB
cm[dots_line1]="$LightGray"         # первый сверху ряд точек
cm[dots_line2]="$LightGray"         # второй сверху ряд точек
cm[dots_line3]="$LightGray"         # третий сверху ряд точек
cm[num_sata]="$LightYellow"         # числа для sata
cm[num_sata_br]="$LightYellow"      # скобка после числа sata
cm[num_usb]="$LightCyan"            # числа для usb
cm[num_usb_br]="$LightCyan"         # скобка после числа usb
cm[mount_pls]="$Magenta"            # цвет плюса для примонтированных
cm[mount_dot]="$LightGray"          # цвет точек для отключенных
cm[dn_sata]="$LightYellow"          # имена дисков sata              
cm[dn_usb]="$LightCyan"             # имена дисков usb
cm[dn_bsd_sata]="$LightYellow"      # имя BSD для SATA
cm[pn_size_sata]="$Orange"          # размер раздела для SATA
cm[pn_size_msata]="$LightYellow"    # размерность раздела для SATA
cm[dn_bsd_usb]="$LightCyan"         # имя BSD для USB
cm[pn_size_usb]="$Limon"            # размер раздела для USB
cm[pn_size_musb]="$LightCyan"       # размерность раздела для USB
cm[sata_bsd]="$Orange"              # имя BSD номер диска SATA
cm[sata_bsp]="$Orange"              # имя BSD номер тома SATA
cm[usb_bsd]="$Limon"                # имя BSD номер диска USB
cm[usb_bsp]="$Limon"                # имя BSD номер тома USB
cm[rv0]="$cOFF"                     # резерв
cm[kh_str]="$LightGray"             # текст подсказок по клавишам
cm[curs_str]="$LightGray"           # строка подсказок перед кусором
cm[curs_num_1]="$BLightCyan"        # первое число строки подсказки
cm[curs_num_2]="$BLightYellow"      # втоое число строки подсказки
cm[ld_unrec]="$Red"                 # загрузчик не распознан
cm[ld_oc]="$Limon"                  # загрузчик OpenCore
cm[ld_cl]="$Green"                  # загрузчик Clover
cm[ld_wn]="$LightBlue"              # загрузчик Windows
cm[ld_rf]="$LightRed"               # загрузчик Refind
cm[ld_gb]="$LightYellow"            # загрузчик Grub
cm[ld_oth]="$LightMagenta"          # загрузчик из списка Other
cm[cl_Q]="$LightMagenta"            # цвет букв Q строки подсказки
cm[cl_P]="$BLightBlue"              # буква P
cm[cl_U]="$BCyan"                   # буква U
cm[cl_E]="$BLightYellow"            # буква E
cm[cl_A]="$BRed"                    # буква A
cm[cl_S]="$BLightMagenta"           # буква S
cm[cl_I]="$BLightGreen"             # буква I
cm[cl_V]="$BGreen"                  # буква V
cm[cl_C]="$BLightGreen"             # буква C
cm[cl_O]="$BLightCyan"              # буква O
cm[cl_L]="$BYellow"                 # буква L
cm[cl_ast]="$Yellow"                # цвет звёздочек подсказки функции P                   
cm[cl_str]="$Cyan"                  # цвет строки после звёздочек
cm[cl_conf]="$LightMagenta"         # цвет config,plist в строке функции P
cm[ld_srch]="$LightGray"            # строка поиска загрузчиков
cm[ld_srch_sp]="$LightGray"         # спинер поиска загрузчиков
cm[ld_srch_bt]="$LightMagenta"      # bootx64.efi в строке поиска загрузчиков
cm[rv1]="$cOFF"                     # резерв
cm[rv2]="$cOFF"                     # резерв
cm[rv3]="$cOFF"                     # резерв
cm[clr]="$cOFF"                     # конец применения цвета
cm[dark]="0"                        # флаг тёмной темы

current_background="{4064, 9400, 9977}"; current_foreground="{65535, 65535, 65535}"; current_fontname="SF Mono Regular"; current_fontsize="11"
osascript -e "tell application \"Terminal\" to set background color of window 1 to $current_background" \
-e "tell application \"Terminal\" to set normal text color of window 1 to $current_foreground" \
-e "tell application \"Terminal\" to set the font name of window 1 to \"$current_fontname\"" \
-e "tell application \"Terminal\" to set the font size of window 1 to $current_fontsize"

###########################################################################################################################################################
}

function Progress {
let _progress=(${1}*100/${2}*100)/100 2>/dev/null
let _done=(${_progress}*3)/10 2>/dev/null
let _left=30-$_done 2>/dev/null
_fill=$(printf "%${_done}s")
_empty=$(printf "%${_left}s")
printf "   |${_fill// /|}${_empty// / }|  code: ${1}  " 2>/dev/null
}

PROGRESSBAR(){ if [[ ! $code = "" ]]; then   printf '\033[33;26f          '; Progress ${code} 255; printf '\033[37;32f'; fi; }


COLOR_PARSER(){
IFS=';'; lcolor=($1); unset IFS; plcolor=${#lcolor[@]}; let "lpos=plcolor-1"
code=${lcolor[lpos]}
    cl_bold=0
    cl_dim=0
    cl_underl=0
    cl_blink=0
    cl_inv=0
    cl_bit=0
if [[ $lpos -ge 1 ]]; then
    cl_normal=0
for (( i=0; i<=(( $lpos-1 )); i++)) do
    case ${lcolor[i]} in
    1 ) cl_bold=1;;
    2 ) cl_dim=1;;
    4 ) cl_underl=1;;
    5 ) if [[ ! $cl_bit = 1 ]] && [[ ! $plcolor = 3 ]] && [[ ! $cl_normal = 1 ]]; then cl_blink=1 ; fi ;;
    7 ) cl_inv=1;;
    38 ) cl_bit=1;;              
    esac
    if [[ $cl_bit = 1 ]] && [[ $plcolor = 3 ]]; then cl_normal=1; fi
done
else 
    cl_normal=1
fi 
    
}

SHOW_TEXT_FLAGS(){
if [[ $cl_normal = 1 ]]; then printf '\033[26;25f''√' ;else printf '\033[26;25f'' '; fi
if [[ $cl_bold = 1 ]]; then printf '\033[27;25f''√' ;else printf '\033[27;25f'' '; fi
if [[ $cl_dim = 1 ]]; then printf '\033[28;25f''√' ;else printf '\033[28;25f'' '; fi
if [[ $cl_underl = 1 ]]; then printf '\033[29;25f''√'; else printf '\033[29;25f'' '; fi
if [[ $cl_blink = 1 ]]; then printf '\033[30;25f''√' ;else printf '\033[30;25f'' '; fi
if [[ $cl_inv = 1 ]]; then printf '\033[31;25f''√' ;else printf '\033[31;25f'' '; fi
if [[ $cl_bit = 1 ]]; then printf '\033[33;25f''√'; printf '\033[32;25f'' '; fi 
if [[ $cl_bit = 0 ]]; then printf '\033[32;25f''√'; printf '\033[33;25f'' '; fi
}

GET_POINTER_INPUT(){ 
             if [[ $init = 1 ]]; then printf '\033[2;1f'; SHOW_CURSOR; init=0
             elif [[ $inputs = [zZxXhHcCvVeE] ]]; then printf '\033[?25l\033[37;32;f                                                              ' 
             fi         
             while [[ ! ${inputs} =~ ^[0-7zZxXeEqQcCoOaAsSdDfFvVrRhHlLwWpPtT]+$ ]]; do
             read -s -r -n 1 inputs 
             if [[ "${inputs}" = $(printf '\033') ]]; then read -r -s -n 2 keys 
                      case "${inputs}" in
                '[A') inputs="R" ; break ;;
                '[B') inputs="V" ; break ;;
                '[D') inputs="D" break ;;
                '[C') inputs="F" break;;
            esac
             fi   
             if [[ ! $inputs = [0-7zZxXeEqQcCoOaAsSdDfFvVrRhHlLwWpPtT] ]]; then 
                        if [[ ${inputs} = "" ]]; then  unset inputs; fi 
                        
                        printf '\r'
                        
            fi
            printf '\r'
            done
}

SET_STRIP(){

posit=36; code2=40
if [[ ${cl_bit} = 0 ]]; then
for ((i=0;i<16;i++)) do 
#printf '\033[27;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[28;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[29;'$posit'f\e['$code2'm''   ''\e[0m'
printf '\033[30;'$posit'f\e['$code2'm''   ''\e[0m'
if [[ $code2 = 47 ]]; then code2=99; fi
let "code2++"; let "posit=posit+3"
done
strip=0
else
if [[ $strip = 0 ]]; then printf '\033[27;35f                                                  \033[31;35f                                                  '; strip=1; fi       
#printf '\033[27;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[28;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[29;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[30;36f\e['$rcol'm''                                                ''\e[0m'
printf '\033[37;32f'
fi
}

COLOR_TRANS(){
if [[ $cl_bit = 1 && $(echo $old_color | grep -o "38;5") = "" ]]; then code=$( echo $old_color | awk -F ';' '{print $NF}' )
if [[ $code -gt 29 && $code -lt 38 ]]; then code=$((code-30)); elif [[ $code -gt 89 && $code -lt 98 ]]; then code=$((code-82)); fi
old_color="38;5;"$code
fi
}

GET_ITEM_COLOR(){
oldItemColor=${cm[$(echo ${CurrStrList[ObjPtr]} | cut -f1 -d',')]}
old_color=$(echo "$oldItemColor" | sed s'/\\e\[0m//' |  sed s'/\\e\[//' | tr -d 'm')
#echo "old_color = $old_color" >> ~/Desktop/temp.txt
if [[ $cl_bit = 1 && $(echo $old_color | grep -o "38;5") = "" ]]; then code=$( echo $old_color | awk -F ';' '{print $NF}' ); 
if [[ $code -gt 29 && $code -lt 38 ]]; then old_color="38;5;"$((code-30)); elif [[ $code -gt 89 && $code -lt 98 ]]; then old_color="38;5;"$((code-82)); fi
fi
#echo "old_color2 = $old_color" >> ~/Desktop/temp.txt
if [[ ! $old_color = "" ]]; then COLOR_PARSER $old_color; fi
}

SHOW_ITEM_COLOR(){ # < $old_color $new_color
MAKE_COLOR
SHOW_TEXT_FLAGS
STRIP_POINTER OFF
if [[ ${cl_bit} = 0 ]]; then  
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "clptr=code-29"; fi
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "clptr=code-89"; fi
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
STRIP_POINTER ON
fi
SET_STRIP 
if [[ ${cl_bit} = 1 ]]; then
PROGRESSBAR
fi
}

SHOW_NEW_ITEM_COLOR(){
if [[ ! "$oldNewItemColor" = "$NewItemColor" ]]; then oldNewItemColor="$NewItemColor"; fi
if [[ ${inputs} = [rR] ]]; then NewItemColor="\e[0m"; else NewItemColor="\e[0m\e["$new_color"m"; fi
cm[$(echo ${CurrStrList[ObjPtr]} | cut -f1 -d',')]="${NewItemColor}"
if [[ $StrPtr -lt 7 ]]; then
    if [[ $StrPtr = 3 && ! $LoaderPointer1 = "" ]]; then SET_LOADER_STRUCT $LoaderPointer1
      elif [[ $StrPtr = 1 && $hidden = 1 ]]; then SET_STRUCT_3 1
         elif [[ $StrPtr = 5 && ! $LoaderPointer1 = "" ]]; then SET_LOADER_STRUCT $LoaderPointer2
            else SET_STRUCT_1 $StrPtr
    fi
elif [[ $StrPtr = 12 && $hidden = 1 ]]; then SET_STRUCT_3 12
    elif [[ $StrPtr -lt 12 && $ObjPtr -gt 1 ]]; then for i in 7 8 9 10 11; do SET_STRUCT_2 $i; done
        elif [[ StrPtr -lt 13 ]]; then SET_STRUCT_2 $StrPtr
fi
SET_SCREEN; printf '\033[37;32f'
}

MAKE_COLOR(){
unset new_color
if [[ $cl_normal = 1 ]]; then  cl_bold=0; cl_dim=0; cl_underl=0; cl_blink=0; cl_inv=0; fi
if [[ $cl_normal = 0 ]]; then
if [[ $cl_bold = 1 ]]; then new_color+="1;" ;fi
if [[ $cl_dim = 1 ]]; then new_color+="2;" ;fi
if [[ $cl_underl = 1 ]]; then new_color+="4;" ;fi
if [[ $cl_blink = 1 ]]; then new_color+="5;" ;fi
if [[ $cl_inv = 1 ]]; then new_color+="7;" ;fi
fi
if [[ $cl_bit = 1 ]]; then new_color+="38;5;"; fi 
rcol=$(echo $new_color | sed s'/38;5;/48;5;/' | sed s'/4;//' | sed s'/7;//')
new_color+="$code"; rcol+="$code"
#echo "new_color = $new_color" >> ~/Desktop/temp.txt
}

SET_SCREEN(){ CLR_UNUSED_STR; for i in "${!bbuf[@]}"; do echo "${bbuf[i]}";  done ; }
STRIP_POINTER(){ if [[ $1 = "ON" ]]; then yes "" | printf '\033[27;'$NN'f''•  \033[31;'$NN'f''•  \033[37;32f'; else  yes "" | printf '\033[27;'$NN'f''   \033[31;'$NN'f''   \033[37;32f'; fi ; }
SHOW_CURSOR(){ SET_SCREEN; printf '\033[23;36f                                                          \033[23;38f'"${HintWords[$((ObjPtr-1))]}"''; yes '' | printf '\033['$lnN';'$(echo ${CurrStrList[ObjPtr]} | cut -f2 -d',')'f'"\033[?25h"; } 

###############################################################
EDIT_COLORS(){

MountEFIconf=$( cat "${CONFPATH}" )

GET_THEME_NAMES
if [[ "$1" = "" ]]; then presetName=$(ASK_COLOR_MODE_PRESET); fi
if [[ ! "$presetName" = "false" ]]; then 

GET_SET_PRESET  
GET_COLOR_MODE_PRESET
#COLOR_MODE
BACKUP
UPDATE_GUI
SHOW_CURSOR  

ObjPtr=1; StrPtr=0; CurrStrList=(${bufStruct[0]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}
IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS; oldEdItem=""
lastEditItem=""; new_cm=(); unset inputs
loaderPonter1=""; loaderPointer2=""; hidden=0

printf '\033[22;1f\033[1m'; printf '–%.0s' {1..94}
printf '\033[23;1f[Редактор цветного мода]\033[0m   Элемент:'
printf '\033[24;1f\033[1m'; printf '–%.0s' {1..94}; printf '\033[0m'

                if [[ $loc = "ru" ]]; then
printf '                                                                                        \n'
printf '     0) Нормальный                   \n'  
printf '     1) Жирный/яркий                 \n'
printf '     2) Тусклый                      \n'
printf '     3) Подчёркнутый                 \n'
printf '     4) Мигающий                     \n'
printf '     5) Инверсный                    \n'
printf '     6) Цветов      16               \n'
printf '     7) Цветов     256               \n'
                    else
printf '                                                                                        \n'
printf '     0) Normal                       \n'  
printf '     1) Bold/Bright                  \n'
printf '     2) Dim                          \n'
printf '     3) Underlined                   \n'
printf '     4) Blink                        \n'
printf '     5) Inverse                      \n'
printf '     6) Colors      16               \n'
printf '     7) Colors     256               \n'
                    fi

COLOR_PARSER 37
SHOW_TEXT_FLAGS
if [[ ${cl_bit} = 0 ]]; then  
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "clptr=code-29"; fi
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "clptr=code-89"; fi
if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
STRIP_POINTER ON
else MAKE_COLOR; fi
SET_STRIP 
if [[ ! ${cl_bit} = 0 ]]; then
PROGRESSBAR
fi
printf '\033[35;5f'
printf '.%.0s' {1..88}
printf '\033[37;7f'
                                if [[ $loc = "ru" ]]; then
                        printf 'Выберите от 0 до 7 или :                                                           \n\n'
                        printf '           Z/X - изменить цвет шаг 1                     A/D - курсор влево/вправо            \n'
                        printf '           C/V - изменить цвет шаг 6 (256 цветов)        W/S - курсор вверх/вниз              \n'
                        printf '           E/E - отменить/возвратить изменение           H   - редактироать подсказки         \n'
                        printf '           T   - повторить последний цвет                R   - вставить отмену цвета          \n'
                        printf '           F   - споказать скрытые элементы              L   - названия загрузчиков           \n'
                        printf '           P   - управлять пресетами                     Q   - выход с сохранением            \n'
			                   else
                        printf 'Select from 1 to 7 or :                                                            \n\n'
                        printf '           Z/X - select color, step 1                     A/D - move cursor left/right         \n'
                        printf '           C/V - select color, step 6 (256 colors)        W/S - move cursor up/down            \n'
                        printf '           E/E - cancel/return the editing                H   - edit GUI key hints             \n'
                        printf '           T   - edit with last used color                R   - insert stop color code         \n'
                        printf '           F   - show hidden items                        L   - edit bootloader names          \n'
                        printf '           P   - preset  management                       Q   - quit saving result             \n'
                                fi
                    cvar=0; init=1
                    while [[ $cvar = 0 ]]; 
                    do

                    GET_POINTER_INPUT

                   if [[ ${inputs} = [dDaA] ]]; then
                        if [[ ${inputs} = [dD] ]]; then if [[ $ObjPtr -eq $((CurrStrSize-1)) ]]; then ObjPtr=1; else let "ObjPtr++"; fi; fi
                        if [[ ${inputs} = [aA] ]]; then if [[ $ObjPtr -eq 1 ]]; then ObjPtr=$((CurrStrSize-1)); else let "ObjPtr--"; fi; fi
                        SHOW_CURSOR
                        GET_ITEM_COLOR                    
                    fi
                    if [[ ${inputs} = [sSwW] ]]; then
                        if [[ ${inputs} = [sS] ]]; then  if [[ $StrPtr -eq 12 ]]; then StrPtr=0; else let "StrPtr++"; fi; fi
                        if [[ ${inputs} = [wW] ]]; then if [[ $StrPtr -eq 0 ]]; then StrPtr=12; else let "StrPtr--"; fi; fi
                        CurrStrList=(${bufStruct[StrPtr]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}; IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS
                        if [[ ${inputs} = [sS] && $StrPtr = 5 && $ObjPtr = 2 ]]; then let "ObjPtr++"
                            elif [[ ${inputs} = [sS] && $StrPtr = 3 && $ObjPtr = 2 ]]; then let "ObjPtr=3"
                                elif [[ ${inputs} = [wW] && $StrPtr = 3 && $ObjPtr = 2 ]]; then let "ObjPtr++"
                                    elif [[ ${inputs} = [wW] && $StrPtr = 1 && $ObjPtr = 2 ]]; then ObjPtr=4
                                        elif [[ $ObjPtr -gt $((CurrStrSize-1)) ]]; then ObjPtr=$((CurrStrSize-1)); fi
                        SHOW_CURSOR
                        GET_ITEM_COLOR
                    fi

                    if [[ ${inputs} = [hH] ]]; then let "hints++"; if [[ $hints = 3 ]]; then hints=0; fi; UPDATE_BOTTOM
                        CurrStrList=(${bufStruct[StrPtr]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}; IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS
                        if [[ $ObjPtr -gt $((CurrStrSize-1)) ]]; then ObjPtr=1; fi
                        CLEAR_BOTTOM; sleep 0.1; SET_SCREEN
                        SHOW_CURSOR
                        GET_ITEM_COLOR
                        if [[ $hidden = 1 ]]; then inputs="F"; fi
                    fi

                    if [[ ${inputs} = [0-7] ]]; then
                               
                               case ${inputs} in  
                             1)   if [[ $cl_bold = 1 ]]; then cl_bold=0; elif [[ $cl_bold = 0 ]]; then cl_bold=1; cl_normal=0; fi;;
                             2)   if [[ $cl_dim = 1 ]]; then cl_dim=0; elif [[ $cl_dim = 0 ]]; then cl_dim=1; cl_normal=0; fi;;
                             3)   if [[ $cl_underl = 1 ]]; then cl_underl=0; elif [[ $cl_underl = 0 ]]; then cl_underl=1; cl_normal=0; fi ;;
                             4)   if [[ $cl_blink = 1 ]]; then cl_blink=0; elif [[ $cl_blink = 0 ]]; then cl_blink=1; cl_normal=0; fi ;;
                             5)   if [[ $cl_inv = 1 ]]; then cl_inv=0; elif [[ $cl_inv = 0 ]]; then cl_inv=1; cl_normal=0; fi ;;
                             6)   if [[ $cl_bit = 1 ]]; then cl_bit=0; fi ; printf '\033[?25l'; MAKE_COLOR; SET_STRIP; printf '\033[33;36f'; printf ' %.0s' {1..48}; code=37; if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi ; STRIP_POINTER ON ;;  
                             7)   if [[ $cl_bit = 0 ]]; then cl_bit=1; fi ; printf '\033[?25l'; STRIP_POINTER OFF; code=7; PROGRESSBAR;;
                             0)   if [[ $cl_normal = 0 ]]; then cl_normal=1;  fi ;;
                               esac
                             if [[ $cl_bold = 0 ]] && [[ $cl_dim = 0 ]] && [[ $cl_underl = 0 ]] && [[ $cl_blink = 0 ]] && [[ $cl_inv = 0 ]]; then cl_normal=1; fi
                              
                             MAKE_COLOR
                             SHOW_NEW_ITEM_COLOR
                             SET_STRIP                          
                             SHOW_TEXT_FLAGS
                             SHOW_CURSOR
                            
                    fi

                if [[ $inputs = [lL] ]]; then
                    if [[ $LoaderPointer1 = "" ]]; then LoaderPointer1="Clover"; LoaderPointer2="OpenCore"; SET_LOADER_STRUCT $LoaderPointer1; SET_LOADER_STRUCT "$LoaderPointer2"
                        elif [[ $LoaderPointer1 = "Clover" ]]; then LoaderPointer1="Windows"; LoaderPointer2="Linux"; SET_LOADER_STRUCT $LoaderPointer1; SET_LOADER_STRUCT "$LoaderPointer2"
                            elif [[ $LoaderPointer1 = "Windows" ]]; then LoaderPointer1="Refind"; LoaderPointer2="Не распознан"; SET_LOADER_STRUCT $LoaderPointer1; SET_LOADER_STRUCT "$LoaderPointer2"
                                elif [[ $LoaderPointer1 = "Refind" ]]; then LoaderPointer1=""; LoaderPointer2="" ; SET_STRUCT_1 3; SET_STRUCT_1 5; fi

                    if [[ $LoaderPointer1 = "" ]]; then ObjPtr=1; else ObjPtr=3; fi
                    StrPtr=3; CurrStrList=(${bufStruct[StrPtr]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}
                    IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS
                    GET_ITEM_COLOR
                    SHOW_CURSOR
                fi

                
                if [[ $inputs = [fF] ]]; then 
                        if [[ $hidden = 0 ]]; then hidden=1; SET_STRUCT_3 1; SET_STRUCT_3 12; else hidden=0; SET_STRUCT_1 1; SET_STRUCT_2 12; fi
                        ObjPtr=1; StrPtr=1; CurrStrList=(${bufStruct[StrPtr]}); lnN=${CurrStrList[0]}; CurrStrSize=${#CurrStrList[@]}
                        IFS=';';HintWords=(${StructHints[StrPtr]}); unset IFS
                        GET_ITEM_COLOR
                        SHOW_CURSOR
                fi
                
           if [[ $inputs = [xX] ]] && [[ $cl_bit = 0 ]]; then
             if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then        
                STRIP_POINTER OFF
                
                if [[ ${code} = 37 ]]; then code=90 ; elif [[ ${code} = 97 ]]; then code=30
                    else
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 36 ]]; then let "code++"; fi
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 96 ]]; then let "code++"; fi
                    fi
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
 
                STRIP_POINTER ON
             else
                SHOW_ITEM_COLOR
             fi              
                MAKE_COLOR
                SHOW_NEW_ITEM_COLOR
                lastEditItem="$StrPtr,$ObjPtr"
                if [[ $strip = 1 ]]; then SET_STRIP; fi
               
         fi

         if [[ $inputs = [zZ] ]] && [[ $cl_bit = 0 ]]; then
            if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then          
                STRIP_POINTER OFF

                if [[ ${code} = 30 ]]; then code=97 ; elif [[ ${code} = 90 ]]; then code=37
                    else
                if [[ ${code} -ge 31 ]] && [[ ${code} -le 37 ]]; then let "code--"; fi
                if [[ ${code} -ge 91 ]] && [[ ${code} -le 97 ]]; then let "code--"; fi
                    fi
                if [[ ${code} -ge 30 ]] && [[ ${code} -le 37 ]]; then let "NN=(code-29)*3+34" ;fi 
                if [[ ${code} -ge 90 ]] && [[ ${code} -le 97 ]]; then let "NN=3*(code-89)+58"; fi
 
                STRIP_POINTER ON
            else
                SHOW_ITEM_COLOR
            fi              
                MAKE_COLOR
                SHOW_NEW_ITEM_COLOR
                lastEditItem="$StrPtr,$ObjPtr"
                if [[ $strip = 1 ]]; then SET_STRIP; fi                
         fi

              if [[ $inputs = [zZ] ]] && [[ $cl_bit = 1 ]]; then
                if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -gt 0 ]]; then let "code--"; else code=255; fi
                    PROGRESSBAR
                else
                    SHOW_ITEM_COLOR
                fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
              fi

                if [[ $inputs = [xX] ]] && [[ $cl_bit = 1 ]]; then
                  if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -lt 255 ]]; then let "code++"; else code=0; fi
                    PROGRESSBAR
                  else
                    SHOW_ITEM_COLOR
                  fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
                fi
                if [[ $inputs = [cC] ]] && [[ $cl_bit = 1 ]]; then
                  if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -gt 9 ]]; then let "code=code-6"; else code=255; fi
                    PROGRESSBAR
                  else
                      SHOW_ITEM_COLOR
                  fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
                fi

                if [[ $inputs = [vV] ]] && [[ $cl_bit = 1 ]]; then
                  if [[ "$lastEditItem" = "$StrPtr,$ObjPtr" ]]; then
                    if [[ $code -lt 245 ]]; then let "code=code+6"; else code=0; fi
                    PROGRESSBAR
                  else
                     SHOW_ITEM_COLOR
                  fi
                    MAKE_COLOR
                    SHOW_NEW_ITEM_COLOR
                    lastEditItem="$StrPtr,$ObjPtr"
                    SET_STRIP 
                fi

                if [[ $inputs = [eE] ]]; then 
                                    if [[ $cl_bit = 0 ]]; then STRIP_POINTER OFF; fi
                                    currentModeItem=$(echo ${CurrStrList[ObjPtr]} | cut -f1 -d',')
                                    if [[ ! ${new_cm[currentModeItem]} = "" ]]; then cm[currentModeItem]=${new_cm[currentModeItem]}; unset new_cm[currentModeItem]
                                        else
                                    new_cm[currentModeItem]=${cm[currentModeItem]};cm[currentModeItem]=${old_cm[currentModeItem]}
                                    fi
                                    GET_ITEM_COLOR
                                    MAKE_COLOR
                                    SHOW_NEW_ITEM_COLOR
                                    SHOW_ITEM_COLOR
                                    SHOW_CURSOR                                    
                fi

            if [[ ${inputs} = [tT] ]]; then NewItemColor="$oldNewItemColor"; SHOW_NEW_ITEM_COLOR; SHOW_CURSOR; fi

            if [[ ${inputs} = [rR] ]]; then SHOW_NEW_ITEM_COLOR; SHOW_CURSOR; fi

            if [[ ${inputs} = [pP] ]]; then DELETE_OR_TAKE_NEW_PRESET; fi
            
            if [[ $inputs = [qQ] || $init -gt 1 ]]; then 
                if [[ ! $presetName = "false" &&  $inputs = [qQ] ]] ; then SAVE_COLOR_MODE_PRESET; fi
                if [[ $init -gt 1 ]]; then unset presetName; fi
                if [[ $inputs = [qQ] && $init -lt 2 ]]; then presetName="false"; fi
                unset inputs; cvar=1; break
            fi
            if [[ $inputs = "" ]]; then printf "\033[2A"; break; fi
            read -s -n 1  inputs
           if [[ "${inputs}" = $(printf '\033') ]]; then read -r -s -n 2 keys 
           case "${inputs}" in
                '[A') inputs="R" ; break ;;
                '[B') inputs="V" ; break ;;
                '[D') inputs="D" break ;;
                '[C') inputs="F" break;;
            esac
             fi        
done

fi
}
loc=`defaults read -g AppleLocale | cut -d "_" -f1`
if [[ ! -f "${CONFPATH}" ]]; then
while true; do EDIT_COLORS "${presetName}"; if [[ "$presetName" = "false" ]]; then break; fi; done
printf "\e[0m\033[?25h"
else
    if [[ $loc = "ru" ]]; then
    error_message='"Это редактор для программы MountEFI.\nФайл конфигурации MountEFI не найден.\n\nВыполнение прекращено!"'
    osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "Прекратить" } default button "Прекратить" giving up after 10' >>/dev/null 2>/dev/null
    else
    error_message='"This is MountEFI GUI editor.\nMountEFI config file not found.\n\nExecution canceled!"'
    osascript -e 'display dialog '"${error_message}"'  with icon caution buttons { "Abort" } default button "Abort" giving up after 10' >>/dev/null /2>/dev/null
    fi
fi
clear && printf '\e[8;24;80t' && printf '\e[3J' && printf "\033[H"