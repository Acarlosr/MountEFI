#!/bin/bash

# функция отладки ###############################################
demo1="0"
deb=1

DEBUG(){
if [[ ! $deb = 0 ]]; then
printf '\n\n Останов '"$stop"'  :\n\n'
printf '............................................................\n'

#echo "pik = "$pik
#echo "locale = "$locale
echo "passl = "$passl

printf '............................................................\n\n'
sleep 0.5
read  -n1 demo1
fi
}
#########################################################################################################################################

par="$1"

MyTTY1=`tty | tr -d " dev/\n"`
term=`ps`;  MyTTYc=`echo $term | grep -Eo $MyTTY1 | wc -l | tr - " \t\n"`

# Возвращает в переменной TTYcount 0 если наш терминал один
CHECK_TTY_C(){
term=`ps`
AllTTYc=`echo $term | grep -Eo ttys[0-9][0-9][0-9] | wc -l | tr - " \t\n"`
let "TTYc=AllTTYc-MyTTYc"
}

# Выход из программы с проверкой - выгружать терминал из трея или нет
EXIT_PROG(){
CHECK_TTY_C	
if [[ ${TTYc} = 0  ]]; then  sleep 0.5; osascript -e 'quit app "terminal.app"' & exit
	else
    sleep 1.2; osascript -e 'tell application "Terminal" to close first window' & exit
fi
}

#########################################################




# MountEFI версия скрипта настройек 1.1 master


clear && printf "\033[0;0H"

cd $(dirname $0)


SET_LOCALE(){

if [[ -f ${HOME}/.MountEFIconf.plist ]] ; then
        locale=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Locale" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        if [[ ! $locale = "ru" ]] && [[ ! $locale = "en" ]]; then loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
            else
                loc=`echo ${locale}`
        fi
    else   
        loc=`locale | grep LANG | sed -e 's/.*LANG="\(.*\)_.*/\1/'`
fi
            if [[ $loc = "ru" ]]; then
if [[ $locale = "ru" ]]; then loc_set="русский"; loc_corr=6; fi
if [[ $locale = "en" ]]; then loc_set="английский"; loc_corr=3; fi
if [[ $locale = "auto" ]]; then loc_set="автовыбор"; loc_corr=4; fi
            else
if [[ $locale = "ru" ]]; then loc_set="russian"; loc_corr=23; fi
if [[ $locale = "en" ]]; then loc_set="english"; loc_corr=23; fi
if [[ $locale = "auto" ]]; then loc_set="auto"; loc_corr=26; fi
            fi

}

GET_MENUE(){
menue=0
HasMenue=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Menue" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
if [[ $HasMenue = "always" ]]
    then 
    menue=1
        if [[ $loc = "ru" ]]; then
    menue_set="всегда"; menue_corr=17
        else
    menue_set="always"; menue_corr=30
        fi
    else
            if [[ $loc = "ru" ]]; then
        menue_set="автовыбор"; menue_corr=14 
            else
        menue_set="auto"; menue_corr=32
            fi
fi

}

GET_OPENFINDER(){
OpenFinder=1
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "OpenFinder</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then OpenFinder=0
            if [[ $loc = "ru" ]]; then
        OpenFinder_set="Нет"; of_corr=7
            else
        OpenFinder_set="No"; of_corr=19
            fi
    else
            if [[ $loc = "ru" ]]; then
        OpenFinder_set="Да"; of_corr=8
            else
        OpenFinder_set="Yes"; of_corr=18
            fi
fi
}

GET_SHOWKEYS(){
ShowKeys=1
strng=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "ShowKeys</key>" | grep false | tr -d "<>/"'\n\t'`
if [[ $strng = "false" ]]; then ShowKeys=0
            if [[ $loc = "ru" ]]; then
        ShowKeys_set="Нет"; sk_corr=3
            else
        ShowKeys_set="No"; sk_corr=22
            fi
    else
            if [[ $loc = "ru" ]]; then
        ShowKeys_set="Да"; sk_corr=4
            else
        ShowKeys_set="Yes"; sk_corr=21
            fi
fi
}

strng=`cat ${HOME}/.MountEFIconf.plist | grep -e "<key>ShowKeys</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\t\n'`
if [[ ! $strng = "ShowKeys" ]]; then plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist; fi

GET_PRESETS_COUNTS(){
pcount=0
#pcount=`cat ${HOME}/.MountEFIconf.plist | grep -A 1  -e "<key>PresetsCounts</key>" | grep integer | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
pstring=`cat ${HOME}/.MountEFIconf.plist | grep  -e "<key>BackgroundColor</key>" | sed -e 's/.*>\(.*\)<.*/\1/' | tr ' \n' ';'`
IFS=';'; slist=($pstring); unset IFS;
pcount=${#slist[@]}
unset slist
unset pstring
}

GET_PRESETS_NAMES(){
pstring=`cat ${HOME}/.MountEFIconf.plist | grep  -B 2 -e "<key>BackgroundColor</key>" | grep key | sed -e 's/.*>\(.*\)<.*/\1/' | sed 's/BackgroundColor/;/g' | tr -d '\n'`
IFS=';'; plist=($pstring); unset IFS
unset pstring
}

GET_THEME(){
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
HasTheme=`cat ${HOME}/.MountEFIconf.plist | grep -E "<key>Theme</key>" | grep -Eo Theme | tr -d '\n'`
    if [[ $HasTheme = "Theme" ]]; then
theme=`cat ${HOME}/.MountEFIconf.plist |  grep -A 1 -e  "<key>Theme</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
fi
if [[ $theme = "system" ]]; then 
                if [[ $loc = "ru" ]]; then
            theme_set="системная"; theme_corr=14
                else
            theme_set="system"; theme_corr=30
                fi
    else
                if [[ $loc = "ru" ]]; then
            theme_set="встроенная"; theme_corr=13
                else
            theme_set="built-in"; theme_corr=28
                fi
fi
        
itheme_set=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
        
GET_PRESETS_COUNTS

tlenth=`echo ${#itheme_set}`
if [[ $loc = "ru" ]]; then
let "btheme_corr=18-tlenth"
btspc_corr=19
else
let "btheme_corr=23-tlenth"
fi

}


SET_THEMES(){

HasTheme=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "Theme"  | tr -d '\n'`
if [[ ! $HasTheme = "Theme" ]]; then
plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
else
 theme=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "Theme" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
   if [[ $theme = "system" ]]; then 
                GET_PRESETS_COUNTS
                CUSTOM_SET
 #               if [[ ! $pcount = 1 ]]; then
                plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist
                GET_PRESETS_NAMES
                current=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
 
                var3=$pcount
                num=0
                while [[ ! $var3 = 0 ]]; do 
                    if [[ "$current" = "${plist[$num]}" ]]; then 
                            let "var3=0"
                               else
                            let "num++" 
                            let "var3--"
                     fi

                done  
                var2=1 
                let "pik=pcount-1"            
                while [[  $var2 = 1  ]]; do
                current=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
                    printf "\r\033[1A"
                    printf '                                                          \n'
                    if [[ $loc = "ru" ]]; then
                printf 'Встроенных тем: '$pcount'                                           \n'
                printf 'Текущий выбор - тема: '"${plist[$num]}"'                             \n'
                printf 'N - выбрать следующую тему и S для применения :  '
                        else
                printf 'There is '$pcount' themes.                                             \n'
                printf ' Current preset choose: '"${plist[$num]}"'                            \n'
                printf 'N for next theme and S to confirm :  '
                    fi
                demo="~"; unset demo
                if [[ ! $pcount = 1 ]]; then 
                read -sn1 demo
                if [[ ! $demo =~ ^[sSnN]$ ]]; then unset demo; fi
                else
                    printf '\r'
                    if [[ $loc = "ru" ]]; then
                printf 'Нажмите любую клавишу для продолжения ...             '
                        else
                printf 'Press any key to continue ....                        '
                    fi
                    read -sn1 
                    demo="s"
                fi
                if [[ $demo = [nN] ]]; then 
                    if [[ $num = $pik ]]; then let "num=0"; else let "num++"; fi
                    plutil -replace CurrentPreset -string "${plist[$num]}" ${HOME}/.MountEFIconf.plist
                    unset demo
                    CUSTOM_SET
                fi
                   printf "\r\033[2A"
               
                
if [[ $demo = [sS] ]]; then let "var2=0"; fi

                
                done
 
        else
            plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "включена системная тема. выполните перезапуск программы" 
                echo "нажмите любую клавишу для возврата в меню..."
                        else
                echo "set up system theme. restart required. "
                echo "press any key return to menu ...."
                    fi
                read -n 1 demo 
    fi
fi            

}

GET_CURRENT_SET(){

current=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 -e "<key>CurrentPreset</key>" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_background=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "BackgroundColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_foreground=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "TextColor" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontname=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontName" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
current_fontsize=`cat ${HOME}/.MountEFIconf.plist | grep -A 10 -E "<key>$current</key>" | grep -A 1 "FontSize" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`

}


CUSTOM_SET(){

GET_CURRENT_SET

set_background_color $current_background
set_foreground_color $current_foreground
set_font "$current_fontname" $current_fontsize

}

# Определение функций кастомизации интерфейса #############################################
############################################################################################
# Colors for Apple Terminal
#

function grep_apple_color {
    grep "$*" colors.csv
}

function get_apple_color {
    egrep "(^|,)$*(,|\t)" colors.csv | cut -f 6
}

function set_foreground_color {
    color=$(get_apple_color $*)
    if [ "$color" != "" ] ; then
        osascript -e "tell application \"Terminal\" to set normal text color of window 1 to ${color}"
#        echo "Normal test color set to: $*: $color"
    fi
}    

function set_background_color {
    color=$(get_apple_color $*)
    if [ "$color" != "" ] ; then
        osascript -e "tell application \"Terminal\" to set background color of window 1 to ${color}"
#        echo "Background color set to: $*: $color"
    fi
}    
  

function set_font {
    osascript -e "tell application \"Terminal\" to set the font name of window 1 to \"$1\""
    osascript -e "tell application \"Terminal\" to set the font size of window 1 to $2"
}
##################################################################################################################################################



# Установка/удаление пароля для sudo через конфиг
SET_USER_PASSWORD(){
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
login=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
                printf '\n\n'
                if [[ $loc = "ru" ]]; then
                echo "удалить сохранённый пароль из программы?"
                        else
                echo "delete saved password from this programm?"
                    fi
                read -p "(y/N) " -n 1 -r -s
                if [[ $REPLY =~ ^[yY]$ ]]; then
                plutil -remove LoginPassword ${HOME}/.MountEFIconf.plist
                if [[ $loc = "ru" ]]; then
                echo "пароль удалён. нажмите любую клавишу для продолжения ..."
                        else
                echo "password removed. press any key to continue...."
                    fi
                read -n 1 demo
                fi
        else
                
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "введите ваш пароль для постоянного хранения:"
                        else
                echo "enter password to save it into this programm:"
                    fi
                printf '\n'
                read -s mypassword
                if [[ $mypassword = "" ]]; then mypassword="?"; fi
                if echo $mypassword | sudo -Sk printf '' 2>/dev/null; then
                plutil -replace LoginPassword -string $mypassword ${HOME}/.MountEFIconf.plist
                printf "\r\033[1A"
                if [[ $loc = "ru" ]]; then
                printf '\nпароль '$mypassword' сохранён. нажмите любую клавишу для продолжения ...'
                        else
                printf '\n password '$mypassword' saved. press any key to continue....'
                    fi
                read -n 1 demo
                else
                printf "\r\033[1A"
                    if [[ $loc = "ru" ]]; then
                printf '\nНе верный пароль '$mypassword' не сохранён.\n'
                printf 'нажмите любую клавишу для продолжения ...'
                        else
                printf '\nWrong password '$mypassword' not saved. \n'
                printf 'press any key to continue....'
                    fi
                read -n 1 demo
        fi
    fi
fi
}

#Получение пароля для sudo из конфига
GET_USER_PASSWORD(){
mypassword="0"
if [[ -f ${HOME}/.MountEFIconf.plist ]]; then
login=`cat ${HOME}/.MountEFIconf.plist | grep -Eo "LoginPassword"  | tr -d '\n'`
    if [[ $login = "LoginPassword" ]]; then
mypassword=`cat ${HOME}/.MountEFIconf.plist | grep -A 1 "LoginPassword" | grep string | sed -e 's/.*>\(.*\)<.*/\1/' | tr -d '\n'`
    fi
fi

if [[ $mypassword = 0 ]]
         then 
                    if [[ $loc = "ru" ]]; then
               mypassword_set="нет пароля"; pass_corr=9
                    else
               mypassword_set="not saved"; pass_corr=24
                    fi
    else 
        #mypassword_set="пароль: "
        #mypassword_set+=`echo ${mypassword}`
        mypassword_set=`echo ${mypassword}`
        passl=`echo ${#mypassword}`
        if [[ $loc = "ru" ]]; then
        let "pass_corr=19-passl"
        else
        let "pass_corr=33-passl"
        fi
        
fi
}

SET_INPUT(){

layout_name=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr -d "\n"`
xkbs=1
#stop="перед проверкой раскладки"; DEBUG
case ${layout_name} in
 "Russian"          ) xkbs=2 ;;
 "RussianWin"       ) xkbs=2 ;;
 "Russian-Phonetic" ) xkbs=2 ;;
 "Ukrainian"        ) xkbs=2 ;;
 "Ukrainian-PC"     ) xkbs=2 ;;
 "Byelorussian"     ) xkbs=2 ;;
 esac
#stop="после проверки раскладки"; DEBUG
if [[ $xkbs = 2 ]]; then 
cd $(dirname $0)
    if [[ -f "./xkbswitch" ]]; then 
declare -a layouts_names
layouts=`defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleEnabledInputSources | egrep -w 'KeyboardLayout Name' | sed -E 's/.+ = "?([^"]+)"?;/\1/' | tr  '\n' ';'`
IFS=";"; layouts_names=($layouts); unset IFS; num=${#layouts_names[@]}
keyboard="0"
#stop="после проверки наличия xkbswitch"; DEBUG
while [ $num != 0 ]; do 
case ${layouts_names[$num]} in
 "ABC"                ) keyboard=${layouts_names[$num]} ;;
 "US Extended"        ) keyboard="USExtended" ;;
 "USInternational-PC" ) keyboard=${layouts_names[$num]} ;;
 "U.S."               ) keyboard="US" ;;
 "British"            ) keyboard=${layouts_names[$num]} ;;
 "British-PC"         ) keyboard=${layouts_names[$num]} ;;
esac
#stop="после поиска английской раскладки"; DEBUG
        if [[ ! $keyboard = "0" ]]; then num=1; fi
let "num--"
done

if [[ ! $keyboard = "0" ]]; then ./xkbswitch -se $keyboard; fi
   else
        if [[ $loc = "ru" ]]; then
printf '\n\n                          ! Смените раскладку на латиницу !'
            else
printf '\n\n                          ! Change layout to UTF-8 ABC, US or EN !'
        fi
 printf "\r\n\033[3A\033[46C" ; if [[ $order = 3 ]]; then printf "\033[3C"; fi   fi
fi
}

GET_INPUT(){
unset inputs
while [[ ! ${inputs} =~ ^[0-7qQ]+$ ]]; do

                if [[ $loc = "ru" ]]; then
printf '  Введите число от 0 до 7 (или Q - выход ):   ' ; printf '                             '
			else
printf '  Enter a number from 0 to 7 (or Q - exit ):   ' ; printf '                           '
                fi
printf "%"80"s"'\n'"%"80"s"'\n'"%"80"s"'\n'"%"80"s"
printf "\033[4A"
printf "\r\033[45C"
IFS="±"; read -n 1 inputs ; unset IFS 
if [[ ${inputs} = "" ]]; then printf "\033[1A"; fi
printf "\r"
done

}

SET_SCREEN(){
            if [[ $loc = "ru" ]]; then
printf ' 1) Язык интерфейса программы = "'$loc_set'"'"%"$loc_corr"s"'(автовыбор, английский, русский) \n'
printf ' 2) Показывать меню = "'"$menue_set"'"'"%"$menue_corr"s"'(автовыбор, всегда)             \n'
printf ' 3) Пароль пользователя = "'"$mypassword_set"'"'"%"$pass_corr"s"'(пароль, нет пароля)            \n'
printf ' 4) Открывать папку EFI в Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Да, Нет)                       \n'
printf ' 5) Установки темы =  "'$theme_set'"'"%"$theme_corr"s"'(системная, встроенная)         \n'
printf ' 6) Пресет "'$itheme_set'" из '$pcount' встроенных'"%"$btheme_corr"s"'(имя пресета)'"%"$btspc_corr"s"'\n'
printf ' 7) Показывать подсказки по клавишам = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Да, Нет)                        \n'
#printf ' 8) Редактировать встроенные пресеты                                     \n'

            else
printf ' 1) Program language = "'$loc_set'"'"%"$loc_corr"s"'(auto, russian, english) \n'
printf ' 2) Show menue = "'"$menue_set"'"'"%"$menue_corr"s"'(auto, always)\n'
printf ' 3) Save password = "'"$mypassword_set"'"'"%"$pass_corr"s"'(password, not saved)\n'
printf ' 4) Open EFI folder in Finder = "'$OpenFinder_set'"'"%"$of_corr"s"'(Yes, No) \n'
printf ' 5) Set theme =  "'$theme_set'"'"%"$theme_corr"s"'(system, built-in) \n'
printf ' 6) Theme preset "'$itheme_set'" of '$pcount' presets'"%"$btheme_corr"s"'(preset name) \n'
printf ' 7) Show binding keys help = "'$ShowKeys_set'"'"%"$sk_corr"s"'(Yes, No)                \n'
#printf ' 8) Edit built-in themes presets                                                \n'

            fi

}

UPDATE_SCREEN(){
        GET_THEME
        if [[ $theme = "built-in" ]]; then CUSTOM_SET; fi

        SET_LOCALE

                    if [[ $loc = "ru" ]]; then
        printf '******                   Программа настройки MountEFI                    *******\n'
			else
        printf '******                This is setup program for MountEFI                 *******\n'
	                 fi
        printf '.%.0s' {1..80}
        printf '\n\n'
        

        GET_MENUE
        GET_USER_PASSWORD
        GET_OPENFINDER
        GET_THEME
        GET_SHOWKEYS
        SET_SCREEN
    


        printf '\n'
        printf '.%.0s' {1..80}
        printf '\n\n'
}

SHOW_EFIs(){
printf '\e[8;'${lines}';80t' && printf '\e[3J' && printf "\033[0;0H" 


                        if [[ $loc = "ru" ]]; then
        printf '\n******    Программа монтирует EFI разделы в Mac OS (X.11 - X.14)    *******\n\n'
			else
        printf '\n******    This program mounts EFI partitions on Mac OS (X.11 - X.14)    *******\n\n'
	                 fi

var0=$pos; num1=0 ; ch=0

macos=`sw_vers -productVersion`
macos=`echo ${macos//[^0-9]/}`
macos=${macos:0:4}
if [[ "$macos" = "1014" ]] || [[ "$macos" = "1013" ]] || [[ "$macos" = "1012" ]]; then
        vmacos="Disk Size:"
    else
        vmacos="Total Size:"
fi

if [[ $loc = "ru" ]]; then
	printf '\n  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n'

	printf '\n\n      0)  поиск разделов .....  '
		else
	printf '\n   Mount (open folder) EFI partitions:  (  +  already mounted) \n'

	printf '\n\n      0)  updating partitions list .....  '
        fi

spin='-\|/'
i=0

while [ $var0 != 0 ] 
do 
	let "ch++"

    let "i++"
	i=$(( (i+1) %4 ))
	printf "\b$1${spin:$i:1}"

	strng=`echo ${slist[$num1]}`

    dstrng=`echo $strng | rev | cut -f2-3 -d"s" | rev`
		dlnth=`echo ${#dstrng}`
		let "corr=9-dlnth"

        let "i++"
	    i=$(( (i+1) %4 ))
	    printf "\b$1${spin:$i:1}"

		drv=`diskutil info /dev/${dstrng} | grep "Device / Media Name:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
		dcorr=`echo ${#drv}`
		if [[ ${dcorr} -gt 30 ]]; then dcorr=30; drv=`echo ${drv:0:29}`; fi
		let "dcorr=30-dcorr"

	dsze=`diskutil info /dev/${strng} | grep "$vmacos" | sed -e 's/.*Size:\(.*\)Bytes.*/\1/' | cut -f1 -d"(" | rev | sed 's/[ \t]*$//' | rev`

    		scorr=`echo ${#dsze}`
    		let "scorr=scorr-5"
    		let "scorr=6-scorr"

             let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"

	mcheck=`diskutil info /dev/${strng}| grep "Mounted:" | cut -d":" -f2 | rev | sed 's/[ \t]*$//' | rev`
#          вывод подготовленного формата строки в файл "буфер экрана"
	if [[ ! $mcheck = "Yes" ]]; then
			printf '\n      '$ch') ...   '"$drv""%"$dcorr"s"${strng}"%"$corr"s"'  '"%"$scorr"s""$dsze"  >> ~/.SetupMountEFItemp.txt
		else
			printf '\n      '$ch')   +   '"$drv""%"$dcorr"s"${strng}"%"$corr"s"'  '"%"$scorr"s""$dsze"  >> ~/.SetupMountEFItemp.txt
		fi

            let "i++"
	         i=$(( (i+1) %4 ))
	         printf "\b$1${spin:$i:1}"    

	let "num1++"
	let "var0--"
done 

printf "\n\r\n\033[5A"



		if [[ $loc = "ru" ]]; then
	printf '  Подключить (открыть) EFI разделы: (  +  уже подключенные) \n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n\n      0)  повторить поиск разделов\n' 
		else
	printf '   Mount (open folder) EFI partitions:  (  +  already mounted) \n' 
	printf '     '
	printf '.%.0s' {1..68} 
	printf '\n\n      0)  update EFI partitions list             \n' 
        fi


cat  -v ~/.SetupMountEFItemp.txt


printf '\n\n\n     '
	printf '.%.0s' {1..68}
printf '\n\n     '

}

SHOW_COLOR_TUNING(){
if [[ -f colors.csv ]]; then
GET_CURRENT_SET
printf ' 1) Текущий пресет темы = '$current'\n'
printf '      2) Цвет фона           = '$current_background'\n'
printf '      3) Цвет текста         = '$current_foreground'\n'
printf '      4) Набор шрифтов       = '$current_fontname
printf '\n      5) Размер шрифтов      = '$current_fontsize'\n'
fi

}

SETUP_THEMES(){

strng=`diskutil list | grep EFI | grep -oE '[^ ]+$' | xargs | tr ' ' ';'`
IFS=';' ; slist=($strng); unset IFS; pos=${#slist[@]}
lines=25; let "lines=lines+pos"
rm -f   ~/.SetupMountEFItemp.txt
clear
SHOW_EFIs
SHOW_COLOR_TUNING
read -n1
rm -f   ~/.SetupMountEFItemp.txt 

}

theme="system"
var4=0
while [ $var4 != 1 ] 
do
printf '\e[3J' && printf "\033[0;0H" 
UPDATE_SCREEN
SET_INPUT
GET_INPUT
# ВЫБОР ЛОКАЛИ ##################################################################
if [[ $inputs = 1 ]]; then 
    if [[ $locale = "ru" ]]; then locale="en"
        else
            if [[ $locale = "en" ]]; then locale="auto"
                else
                    if [[ $locale = "auto" ]]; then locale="ru"
                fi
        fi
    fi
  plutil -replace Locale -string $locale ${HOME}/.MountEFIconf.plist
fi
#############################################################################

# ПОКАЗ МЕНЮ ################################################################
if [[ $inputs = 2 ]]; then 
   if [[ $menue = 0 ]]; then menue="always"
        else
            menue="auto"
        fi
  plutil -replace Menue -string $menue ${HOME}/.MountEFIconf.plist
fi
##############################################################################

# ПАРОЛЬ ПОЛЬЗОВАТЕЛЯ #########################################################
if [[ $inputs = 3 ]]; then SET_USER_PASSWORD; fi
###############################################################################

# Открывать папку в Finder ###################################################
if [[ $inputs = 4 ]]; then 
   if [[ $OpenFinder = 1 ]]; then 
  plutil -replace OpenFinder -bool NO ${HOME}/.MountEFIconf.plist
 else 
  plutil -replace OpenFinder -bool YES ${HOME}/.MountEFIconf.plist
  fi
fi  
###############################################################################

# Установка темы ##############################################################
if [[ $inputs = 5 ]]; then 
    if [[ $theme = "built-in" ]]; then 
        plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist
                printf '\n\n'
                    if [[ $loc = "ru" ]]; then
                echo "включена системная тема. выполните перезапуск программы" 
                echo "нажмите любую клавишу для возврата в меню..."
                        else
                echo "set up system theme. restart required. "
                echo "press any key return to menu ...."
                    fi
                read -n 1 demo
        else
          plutil -replace Theme -string built-in ${HOME}/.MountEFIconf.plist
    fi
fi 

#################################################################################
 if [[ $inputs = 6 ]]; then 
    if [[ $theme = "built-in" ]]; then plutil -replace Theme -string system ${HOME}/.MountEFIconf.plist; fi
SET_THEMES
fi
      

# Показывать подсказку по клавишам управления  ################################
if [[ $inputs = 7 ]]; then 
   if [[ $ShowKeys = 1 ]]; then 
  plutil -replace ShowKeys -bool NO ${HOME}/.MountEFIconf.plist
 else 
  plutil -replace ShowKeys -bool YES ${HOME}/.MountEFIconf.plist
  fi
fi  
###############################################################################

#if [[ $inputs = 8 ]]; then SETUP_THEMES; clear SET_SCREEN; fi
           
if [[ $inputs = [qQ] ]]; then var4=1; printf '\n'; fi

done
if [[ $par = "-r" ]]; then exit 1; else EXIT_PROG; fi