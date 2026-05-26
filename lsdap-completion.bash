_lsdap_completions() {
    local cur prev opts objects
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"  # Palabra actual que el usuario está escribiendo
    prev="${COMP_WORDS[COMP_CWORD-1]}" # Palabra anterior

    # 1. Lista de opciones principales
    opts="-ls -new -mv -rm -ssh -ad -menu -uninstall -h"
    
    # 2. Lista de objetos válidos
    objects="ou user group"

    # Si la palabra anterior requiere un objeto, sugerimos: ou, user, group
    case "${prev}" in
        -ls|-new|-mv|-rm)
            COMPREPLY=( $(compgen -W "${objects}" -- "${cur}") )
            return 0
            ;;
    esac

    # Si está escribiendo una opción principal (empieza por -) o es el primer argumento
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        return 0
    fi
}

# Registrar la función para el comando lsdap
complete -F _lsdap_completions lsdap