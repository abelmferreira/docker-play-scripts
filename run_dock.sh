#!/bin/bash
# vim: set ts=4 sts=4 sw=4 et:

#https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
#https://linuxconfig.org/bash-scripting-tutorial

EXTRASPARAMS=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -i|--interactive)
        [[ -n "$RUNMODE" ]] && { echo "Parametro -i (--interactive) e -d (--daemon) são exclusivos e não devem ser utilizados em conjunto" ; exit 1; }
        RUNMODE="-it"
        shift 					# past next argument
        ;;
    -d|--deamon)
        [[ -n "$RUNMODE" ]] && { echo "Parametro -i (--interactive) e -d (--daemon) são exclusivos e não devem ser utilizados em conjunto" ; exit 1; }
        RUNMODE="-d"
        shift
        ;;
    -p|--port)
        PORTA="$2"
        shift 					# past next argument
        shift 					# past next value
        ;;
    -r|--remove)
        [[ -n "$REMOVE" ]] && { echo "Parametro -r (--remove) e -nr (--notremove) são exclusivos e não devem ser utilizados em conjunto" ; exit 1; }
        REMOVE="--rm"
        shift
        ;;
    -nr|--notremove)
        [[ -n "$REMOVE" ]] && { echo "Parametro -r (--remove) e -nr (--notremove) são exclusivos e não devem ser utilizados em conjunto" ; exit 1; }
        REMOVE="false"
        shift
        ;;
    *) 						# unknown/extras options
        EXTRASPARAMS+=("$1") 	# save in array
        shift
        ;;
esac
done
set -- "${EXTRASPARAMS[@]}" # restore final extras parameters

## Valores Default para opções não informadas
#REMOVE
    # [[ -z "$REMOVE" ]] && echo "Utilizando REMOVE padrão --rm" ; REMOVE="--rm";
    if [[ -z "$REMOVE" ]]; then
        echo "Utilizando REMOVE padrão --rm" ;
        REMOVE="--rm";
    elif [ $REMOVE = false ]; then
        REMOVE="";
    else
        REMOVE=$REMOVE;
    fi

#IMAGE AND COMMANDS
    IMAGE=${EXTRASPARAMS[0]}
    COMMANDS=("${EXTRASPARAMS[@]:1}")

    if [ $COMMANDS = "bash" ] || [ $COMMANDS = "sh" ]; then
        RUNMODE="-it";
    fi

#RUNMODE
    [[ -z "$RUNMODE" ]] && { echo "Utilizando RUNMODE padrão -d" ; RUNMODE="-d"; }


#PRINT FOR DEBUGS
# echo RUNMODE     = "${RUNMODE}"
# echo PORTA		 = "${PORTA}"
# echo REMOVE      = "${REMOVE}"
# echo IMAGE       = "${IMAGE}"
# echo COMMANDS    = "${COMMANDS[@]}"
# echo EXTRASPARAMS  = "${EXTRASPARAMS[@]}"

if [ $# -lt 1 ]
then
        echo "Usage : $0 [options] {mysql|freeradius|all}";
        exit;
fi

if [ -z "$IMAGE" ]
then
        echo "Usage : $0 [options] {mysql|freeradius|all}";
        exit;
fi

case "$IMAGE" in
        mysql)
            docker run ${RUNMODE} ${REMOVE} --name $IMAGE \
				-e MYSQL_DATABASE=mydb \
				-e MYSQL_USER=mydbuser \
				-e MYSQL_PASSWORD=mydbuserpass \
				-e MYSQL_ROOT_PASSWORD=mydbrootpass \
				-v $(pwd)/data_db:/var/lib/mysql \
				-p 3306:3306/tcp \
				mysql/mysql-server:latest --character-set-server=utf8 --collation-server=utf8_general_ci
            ;;
         
        freeradius)
            [[ -z "$COMMANDS" ]] &&     { echo "Utilizando cmd padrão" ;    COMMANDS="freeradius -X"; }
            [[ -z "$PORTA" ]]    &&     { echo "Utilizando porta padrão" ;  PORTA="1812"; }
        	docker run ${RUNMODE} ${REMOVE} --name $IMAGE \
                -v $(pwd)/data_fr:/etc/freeradius \
				-p ${PORTA}:${PORTA}/udp \
				freeradius:samba $COMMANDS
        	;;
        	
        clear)
        	#docker rmi $(docker images | grep "^127.0.0.1:5000/nginx" | tr -s " " | grep " <none> " | cut -d' ' -f3 | tr '\n' ' ')
			docker rm $(docker ps -a -q)
        	;;
            
        all)
            $0 build
            $0 publish
            $0 deploy
            ;;
            
        *)
            echo "Usage : $0 [options] {mysql|freeradius|all}";
            exit 1
 
esac
