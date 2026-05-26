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
    (g) --> Create a new Grupe.
    (s) --> Search objects in LDAP domain.
    (rm) --> Delete an objet.
    (md) --> Modify an object
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
                    confirmation=""
                    read -p "[#] The OU you want to eliminate is inside into any OU? (N/Y) --> " ins
            
                    if [ "$ins" = "N" ] || [ "$ins" = "n" ]; then
                        ./lsdap/ou.sh
                        read -p "[#] Name of the OU you want to eliminate --> " ou1
                        ou1="ou=$ou1"
                        echo ""
                    elif [ "$ins" = "Y" ] || [ "$ins" = "y" ]; then
                        ./lsdap/ou.sh
                        read -p "[#] Name of the OU who contain OU you want to eliminate --> " ou1
                        read -p "[#] Name of OU you want to eliminate --> " ou2
                        ou1=",ou=$ou1"
                        ou2="ou=$ou2"
                        echo ""
                    fi
                    echo "[!]THIS ACTION WILL ALSO ELIMINATE EVERYTHING "$ou1" CONTAINS [!]"
                    read -p "- Are you sure?(Y/N)" confirmation
                    echo ""
                    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
                        ldapdelete -x -r -W -D "cn=admin,dc=$dc1,dc=$dc2" "$ou2$ou1,dc=$dc1,dc=$dc2"
                        echo "COMMAND --> ldapdelete -x -r -W -D "cn=admin,dc=$dc1,dc=$dc2" "$ou2$ou1,dc=$dc1,dc=$dc2""
                        echo "[#] "$ou2$ou1,dc=$dc1,dc=$dc2" has been eliminated [#]"
                        read -p "Press enter to continue" x
                    else 
                        echo "[#] ABORTING [#]"
                    fi
                    
                elif [ "$deleteoption" = "2" ]; then
                    read -p "[#] The user you want to eliminate is inside into any OU? (N/1/2) --> " ins
                    lsdap -ls user
                    if [ "$ins" = "1" ]; then
                        read -p "[#] Name of OU who contain the user you want to elimenate --> " ou1
                        ou1=",ou=$ou1"
                    elif [ "$ins" = "2" ]; then
                        read -p "[#] Name of higher OU who contain the user you want to eliminate --> " ou1
                        read -p "[#] Name of the OU who contain the user you want to eliminate --> " ou2
                        ou1=",ou=$ou1"
                        ou2=",ou=$ou2"
                    elif [ "$ins" = "n" ] || [ "$ins" = "N" ]; then
                        pwd >> /dev/null
                    else
                        echo "[!] You must introduce a valid value"
                        exit
                    fi

                    read -p "[#] Name of user you want to eliminate --> " rmuser
                    echo ""
                    echo "[!]THIS ACTION WILL ELIMINATE THE USER "$rmuser"[!]"
                    read -p "- Are you sure?(Y/N)" confirmation

                    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
                        ldapdelete -x -W -D "cn=admin,dc=$dc1,dc=$dc2" "cn=$rmuser$ou2$ou1,dc=$dc1,dc=$dc2"
                        echo ""
                        echo "COMMAND --> ldapdelete -x -W -D "cn=admin,dc=$dc1,dc=$dc2" "cn=$rmuser$ou2$ou1,dc=$dc1,dc=$dc2""
                        echo "[#] $rmuser has been elimated [#]"
                        echo "" 
                        read -p "Press enter to continue" x
                    else 
                        echo "[#] ABORTING [#]"
                    fi
            

                elif [ "$deleteoption" = "3" ]; then
                    read -p "[#] The group you want to eliminate is inside into any OU? (N/1/2) --> " ins
                    ./lsdap/pablo.sh
                    if [ "$ins" = "1" ]; then
                        read -p "[#] Name of OU who contains the group you want to eliminate --> " ou1
                        ou1=",ou=$ou1"
                    elif [ "$ins" = "2" ]; then
                        ./lsdap/pablo.sh
                        read -p "[#] Name of higher OU who contain the user you want to eliminate --> " ou1
                        read -p "[#] Name of the OU who contain the user you want to eliminate --> " ou2
                        ou1=",ou=$ou1"
                        ou2=",ou=$ou2"
                    elif [ "$ins" = "n" ] || [ "$ins" = "N" ]; then
                        pwd >> /dev/null
                    else
                        echo "[!] You must introduce a valid value"
                        exit
                    fi

                    read -p "[#] Name of group you want to eliminate --> " rmgroup
                    echo ""
                    echo "[!]THIS ACTION WILL ELIMINATE THE GROUP "$rmgroup"[!]"
                    read -p "- Are you sure?(Y/N)" confirmation

                    if [ "$confirmation" = "Y" ] || [ "$confirmation" = "y" ]; then
                        ldapdelete -x -W -D "cn=admin,dc=$dc1,dc=$dc2" "cn=$rmgroup$ou2$ou1,dc=$dc1,dc=$dc2"
                        echo ""
                        echo "COMMAND --> ldapdelete -x -W -D "cn=admin,dc=$dc1,dc=$dc2" "cn=$rmgroup$ou2$ou1,dc=$dc1,dc=$dc2""
                        echo "[#] $rmgroup has been elimated [#]"
                        echo "" 
                        read -p "Press enter to continue" x
                    else 
                        echo "[#] ABORTING [#]"
                    fi
                fi
                    
            done
        elif [ "$option" = "md" ] || [ "$option" = "MD" ]; then
             echo ""
            echo -n "[-   What do you want to modify?   -]"
            echo ""
            echo "  (1) - User."  
            echo "  (2) - Group"
            echo "  (3) - Ou"
            echo "  (e) - Go Back."
            echo ""
            read -p "[#] Choose your option --> " modifychoption
            echo ""

        
        
        elif [ "$option" = "mv" ] || [ "$option" = "MV" ]; then
            echo ""


        fi
    done
}

menu