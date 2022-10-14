#!/bin/bash
# luizjr8 <luiz@lzjr.com.br>
# Varre Route53 em busca de domínios que compartilham o ip informado

function awsip(){
	# Parâmetros
	ipAddress=$1

	# Checa se aws está instalado
	if ! [ -x "$(command -v aws)" ]; then
		echo 'Error: aws cli não instalado.' >&2
  	exit 1
	fi

	# Caso não tenha parâmetro enviado
	if [ -z $ipAddress ]; then
		cat <<eom
Retorna todos os domínios do seu AWS (Route53) que usam esse IP
usage: $exe ip
ex: $exe 54.11.11.1

eom
	exit 1
	fi

	# Baixa todas as zonas
	zoneids=$(aws route53 --output json list-hosted-zones | jq '.HostedZones[] | "\(.Id)" | ltrimstr("/hostedzone/")' | sed 's/[^0-9|A-Z]//g')

	# Loop por Zonas
	for zone in $zoneids
	do
		# Localiza registro pelo IP
		#
		recordsnames=$(aws route53 list-resource-record-sets --output json --hosted-zone-id ${zone} --query "ResourceRecordSets[?ResourceRecords[?Value == '${ipAddress}']]" | jq '.[] | .Name' | sed 's/\"//g')

		# Loop por Registros encontrados
		for record in $recordsnames
		do
			# Exibe o domínio que possui esse IP
			echo "${record}"
		done
	done
}

awsip "$@"
exit $?