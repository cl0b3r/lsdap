#!/bin/bash
# COLORS
    greenColour="\e[0;32m\033[1m"
    endColour="\033[0m\e[0m"
    redColour="\e[0;31m\033[1m"
    blueColour="\e[0;34m\033[1m"
    yellowColour="\e[0;33m\033[1m"
    purpleColour="\e[0;35m\033[1m"
    turquoiseColour="\e[0;36m\033[1m"
    grayColour="\e[0;37m\033[1m"
#---------------------------------------

# VARS
    lsdapdir="/usr/local/share/lsdap"
    localbins="./bins"
    lsdapbins="$lsdapdir/bins"
    lsdapdata="$lsdapdir/data.conf"
    lsdapfile="$lsdapdir/file.ldif"
#--------------------------------------

# WORK IN PROGRESS
#echo "Work in progress, this menu is not available yet, sorry for the inconvenience."
#exit

# Menu -----------------------------------------------------------------------------------------------------------------
menu() {
    until [ "$option" = "e" ]; do
        # VARIABLE CLEANER
        reconfigureoption=""
        searchoption=""
        useroption=""
        ou=""
        ins=""
        deleteoption=""
        specificsearch=""




        # VARIABLE
        dc1=$(cat $lsdapdata | grep "fqdn" | awk -F '=' '{print $2}' | awk -F '.' '{print $2}')
        dc2=$(cat $lsdapdata | grep "fqdn" | awk -F '=' '{print $2}' | awk -F '.' '{print $3}')
        clear
        # Saving Variables
        fqdn=$(cat $lsdapdata | grep "fqdn" | awk -F '=' '{print $2}')



        echo -n "[ - Choose the option you want to do (writte the letter) - ]

    (u) --> Create a new User.
    (o) --> Create a new Organizational Unit.
    (g) --> Create a new Group.
    (s) --> Search objects in LDAP domain.
    (rm) --> Delete an object.
    (mv) --> Move an object

    (e) --> Exit.

    [$dc1.$dc2]
    "
        read -p "
 [#] Choose your option --> " option

        if [ "$option" = "u" ] || [ "$option" = "U" ];then
            read -p "[#] Name of the user you want to create --> " username
            lsdap -new user $username
            read -p "Press enter to continue" x

            
        elif [ "$option" = "o" ] || [ "$option" = "O" ];then
            read -p "[#] Name of the OU you want to create --> " ou
            lsdap -new ou $ou
            read -p "Press enter to continue" x
        elif [ "$option" = "s" ] || [ "$option" = "S" ];then
            echo ""
            until [ "$searchoption" = "e" ]; do 
                echo ""
                echo -n "[-   What are you looking for?   -]"
                echo ""
                echo "  (1) - LDADP's tree."  
                echo "  (2) - Specific resource"
                echo "  (e) - Go Back."
                echo " "
                read -p "[#] Choose your option --> " searchoption
                echo ""

                if [ "$searchoption" = "1" ]; then
                    lsdap -ls 
                    read -p "Press enter to continue" x
                    clear
                elif [ "$searchoption" = "2" ]; then
                    until [ "$specificsearch" = "e" ] || [ "$specificsearch" = "E" ]; do
                        echo "[#] What are you looking for?"
                        echo "(1) - List OrganizatoinalUnits"
                        echo "(2) - List Users"
                        echo "(3) - List Groups"
                        echo "(e) - Go Back."
                        echo ""
                        read -p "[#] Choose your option --> " specificsearch
                        echo ""
                        clear
                        if [ "$specificsearch" = "1" ]; then
                        lsdap -ls ou
                        echo ""
                        read -p "Pres enter to continue" x
                        clear
                        elif [ "$specificsearch" = "2" ]; then
                        lsdap -ls user
                        echo ""
                        read -p "Pres enter to continue" x
                        clear
                        elif [ "$specificsearch" = "3" ]; then
                        lsdap -ls group
                        echo ""
                        read -p "Pres enter to continue" x
                        clear
                        fi
                    done
                    echo ""
                fi

            done
            

        elif [ "$option" = "rm" ] || [ "$option" = "RM" ]; then
            until [ "$deleteoption" = "e" ] || [ "$deleteoption" = "E" ]; do
            ou1=""
            ou2=""
                clear
                echo -n "[-   What do you want to delete?   -]
            "
                echo ""
                echo "  (1) - Organizational Units."  
                echo "  (2) - Users"
                echo "  (3) - Groups"
                echo "  (e) - Go Back."
                echo " "
                read -p "[#] Choose your option --> " deleteoption
                echo ""
                
                if [ "$deleteoption" = "1" ]; then
                    lsdap -ls ou
                    read -p "[#] Name of the OU you want to eliminate --> " ou1
                    echo ""
                    echo "[!]THIS ACTION WILL ALSO ELIMINATE EVERYTHING "$ou1" CONTAINS [!]"
                    read -p "- Are you sure?(Y/N)" confirmation
                    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
                        lsdap -rm ou $ou1
                    else
                        echo "[#] ABORTING [#]"
                    fi
                    
                elif [ "$deleteoption" = "2" ]; then
                    lsdap -ls user
                    read -p "[#] Name of the user you want to eliminate --> " rmuser
                    lsdap -rm user $rmuser

                elif [ "$deleteoption" = "3" ]; then
                    lsdap -ls group
                    read -p "[#] Name of the group you want to eliminate --> " rmgroup
                    lsdap -rm group $rmgroup
                fi
                    
            done
        elif [ "$option" = "mv" ] || [ "$option" = "MV" ]; then
            echo ""


        fi
    done
}

menu