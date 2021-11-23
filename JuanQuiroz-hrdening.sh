#!/bin/sh
OS=$(. /etc/os-release; echo $ID)
VERSION=$(. /etc/os-release; echo $VERSION_ID)
ejecutar='systemctl start clam@scan'
echo $OS $VERSION

# checamos la  version
if [[ $OS == 'centos' ]]
then
	echo si es centos
	
	if [[ $VERSION == 8 ]] 
	then
		echo ademas es version 8

		# verificamos la instalacion de clamav
		#if ! command -v $ejecutar &> /dev/null
		if ! [[ $(command -v freshclam) ]]
		then
			echo 'no existe clamAV instalado'
			
			
			
			sudo dnf update -y
			
			
			echo 'instalando clamv esto puede tardar un poco...'
			sudo dnf install clamav -y

	

			echo 'instalando clamd esto puede tardar un poco'
			sudo dnf install clamd -y



			echo 'instalando paquetes de clam esto puede tardar un poco...'
			sudo dnf install clamav clamd clamav-scanner clamav-update -y



			echo 'habilitando escaneos'
			sudo setsebool -P antivirus_can_scan_system 1



			echo 'actualizando clam'
			sudo freshclam


			
			echo 'modificando archivo /etc/clamd.d/scan.conf'
			sudo sed -i 's/#LocalSocket \/run/LocalSocket \/run/g' /etc/clamd.d/scan.conf



			echo 'modificando /usr/lib/systemd/system/clamd@.service'
			sudo sed -i 's/scanner (%i) daemon/scanner daemon/g' /usr/lib/systemd/system/clamd@.service


	
			echo 'modificando /usr/lib/systemd/system/clamd@.service'
			sudo sed -i 's/\/etc\/clamd.d\/%i.conf/\/etc\/clamd.d\/scan.conf/g' /usr/lib/systemd/system/clamd@.service


			
			echo 'iniciando controles freshclam.service'
			sudo systemctl enable freshclam.service
			sudo systemctl start freshclam.service
			sudo systemctl status freshclam.service


			echo 'iniciando controles clamd@.service'
			sudo systemctl enable clamd@.service



			echo 'iniciando clamd@scan'
			sudo systemctl start clamd@scan
			sudo systemctl status clamd@scan



		else	
			echo 'si esta instalado'
			echo 'apagando servicios'
			sudo systemctl stop clamd@scan
			sudo systemctl stop clamd@.service
			sudo systemctl stop freshclam.service
			echo 'desinstalando'
			sudo yum autoremove clamav clamd clamav-update -y			
		fi

		
	elif [[ $VERSION == 7 ]]
	then
		echo ademas es version 7

		sudo yum update -y

		echo 'habilitando repositorios extra'

		echo 'instalando epel-release y habilitando repositorios extra'
		sudo yum -y install epel-release
		sudo yum clean all
		
		sudo yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd
		sudo setsebool -P antivirus_can_scan_system 1
		sudo setsebool -P clamd_use_jit 1

		sudo getsebool -a | grep antivirus
		
		sudo sed -i -e "s/^Example/#Example/" /etc/clamd.d/scan.conf




	fi
		
	

else
	echo no es centos, terminando programa

fi

echo 'finalizando programa...'
