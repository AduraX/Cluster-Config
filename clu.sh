#! /bin/bash
if test "`echo -e`" = "-e" ; then ECHO=echo ; else ECHO="echo -e" ; fi 

function Main # ************* Determining if the installation is on the master node ***
{
Indx=0
while [ $Indx -lt 3 ]
do
	Indx=$(( Indx+1 ))
	$ECHO "\nIs \"$HOSTNAME\" the master node? \nType \"y\" for yes or \"n\" for no and press [ENTER]:"
	read Yn
	if [ $Yn = "y" ] || [ $Yn = "Y" ]; then
	ConfMaster
	break
	elif [ $Yn = "n" ] || [ $Yn = "N" ]; then
	ConfSlave
	break
	else	
		if [ $Indx -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
		else
		$ECHO "Invalid input try again.\n"
		fi
	fi
done
exit
}

function ConfMaster #*************** Configuring the master node
{
PreInstall # pre-install relevant software packages for this cluster

if test ! -f $clubin/nodesno; then 
 $ECHO "\nConfiguring \"$HOSTNAME\" as the master node..."
 ConfFile
else
 Ndh=`head -1 $clubin/ConfSteps`
 if [ $Ndh = "0" ]; then  
  $ECHO "\nThere were errors in the first attempt and the configuration of \"$HOSTNAME\" as the master node will be restarted..."
  $ECHO "\nUndoing the cluster configuration @ stage 0.."
  $ECHO "Do you want to undo the configuration by reverting the network files ..."
  $ECHO "Type \"y\" for yes or no \"n\" for no press [ENTER]:"
  read Yn1
  if [ $Yn1 = "y" ] || [ $Yn1 = "Y" ]; then  UndoMaster0 ; else exit ; fi
  if test ! -d bin ; then   mkdir -p bin ; fi
  ConfFile
 elif [ $Ndh = "1" ]; then
  $ECHO "\nUndoing the cluster configuration @ stage 1 .."
  $ECHO "Do you want to undo the configuration by unstalling Torque..."
  $ECHO "Type \"y\" for yes or no \"n\" for no press [ENTER]:"
  read Yn1
  if [ $Yn1 = "y" ] || [ $Yn1 = "Y" ]; then  UndoMaster1 ; else exit ; fi
  cd $clubin
  cd ..
  ConfTorQues 
  Ynt=`head -1 $clubin/TorqYn`
  if [ $Ynt = "y" ] || [ $Ynt = "Y" ]; then ConfTorqueMasterStep2 ; fi
 elif [ $Ndh = "2" ]; then
 ConfMasterStep3 
 ConfMaui
 $ECHO "\n--- End of Installation ...\n"
 else #[ $Ndh = "3" ]; then
  Inda=0
  while [ $Inda -lt 3 ]
  do
	Indx=$(( Inda+1 ))
	$ECHO "This master node \"$HOSTNAME\" has already been configured for the cluster."
	$ECHO "Do you want to add more slave nodes?"
	$ECHO "Type \"y\" for yes if you want to add more slaves nodes or \n\"n\" for no if want to undo the configuration and press [ENTER]:"
	read Yna
	if [ $Yna = "y" ] || [ $Yna = "Y" ]; then
		AdaSlavYn=`head -1 $clubin/AddSlave`	
		if [ $AdaSlavYn = "Yes" ]; then 
			ConfMasterStep3
		else
			AddMoreSlaveNode
		fi
		break
	elif [ $Yna = "n" ] || [ $Yna = "N" ]; then
	UndoMasterconf
	break
	else	
		if [ $Inda -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
		else
		$ECHO "Invalid input try again.\n"
		fi
	fi
  done
 fi
fi
}

function ConfFile #*************** Creating the necessary files
{
 touch $clubin/nodesno 
 touch $clubin/ConfSteps
 touch $clubin/Torqfile 
 touch $clubin/TorqYn
 touch $clubin/AddSlave
 #touch $clubin/GlusterFs
 touch $clubin/MasterNode 
 
 $ECHO "\nThere are 3 steps involved in the configuration of the master node of this cluster..."
 $ECHO "$HOSTNAME" > $clubin/MasterNode
 $ECHO "0" > $clubin/ConfSteps
 $ECHO "0" > $clubin/nodesno 
 ConfMasterStep1
 #ConfGluster
 ConfTorQues 
 Ynt=`head -1 $clubin/TorqYn`
 if [ $Ynt = "y" ] || [ $Ynt = "Y" ]; then ConfTorqueMasterStep2 ; fi
 
$ECHO "\nType in a storage media directory to copy the working directory of the cluster installation to:"
$ECHO "Example: \"/media/pems0/Lexar\" "
MedDir="/media/$USER/ADUREX"  # read MedDir
$ECHO "\nCopying the working directory of the cluster installation into a storage media \"$MedDir\" ..."
if test -d $MedDir/$clu/Backup-bin; then rm -rf $MedDir/$clu/Backup-bin ; fi
if test -d $MedDir/$clu/bin; then mv $MedDir/$clu/bin $MedDir/$clu/Backup-bin ; fi
cp -r $clubin $MedDir/$clu/bin
$ECHO "\nTake the storage media to a slave node to continue the configuration of the cluster."
}

function ConfSlave #*************** Configuring a slave node
{
if test ! -f $clubin/$HOSTNAME-hosts; then 
 PreInstall
 ConfSlaveStep1
else
 Indz=0
 while [ $Indz -lt 3 ]
 do
	Indx=$(( Indz+1 ))
	$ECHO "\nYou have already done the necessary configuration on this node. Do you want to undo the configuration?" 
	$ECHO "Type \"y\" for yes or \"n\" for no and press [ENTER]:"
	read Ynz
	if [ $Ynz = "y" ] || [ $Ynz = "Y" ]; then
	UndoSlaveConf
	break
	elif [ $Ynz = "n" ] || [ $Ynz = "N" ]; then
	$ECHO "Thank you. Exiting ...\n"
	exit
	else	
		if [ $Indz -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
		else
		$ECHO "Invalid input try again.\n"
		fi
	fi
 done
fi 
}

function PreInstall #*************** Pre-install the relevant  software
{
Ins=0
while [ $Ins -lt 3 ]
do
	Ins=$(( Ins+1 ))
	$ECHO "\nWould you like to install some relevant software packages from the internet or offline from the accompanied packages?"
	$ECHO "Type \'I\' for internet, \n\'O\' for offline locally or \n\'T\' for thanks not needed \nand press [ENTER]:"
	read Yns
	if [ $Yns = "I" ] || [ $Yns = "i" ]; then
	$ECHO "Installing packages ...\n"
	apt -y dist-upgrade --auto-remove --purge
	#$ECHO "Thank you. Installation from internet not yet available ..."
	exit
	elif [ $Yns = "O" ] || [ $Yns = "o" ]; then
	   Arch=$(uname -m)
	   if [[ $Arch = i*86 ]]; then Arch="32"; else Arch="64" ; fi   	
	   $ECHO "Installing packages ...\n"
	   for i in `cat pacx-$Arch.dat`
	   do 
	   sudo dpkg -i pacx-$Arch/$i 
	   done
	   $ECHO "\nInstallation complete...\n"
	   break
	elif [ $Yns = "T" ] || [ $Yns = "t" ]; then
	   $ECHO "Thanks not needed! ok ..."
	   break
	else	
		if [ $Ins -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
		else
		$ECHO "Invalid input try again.\n"
		fi
	fi
done
}

function ConfMasterStep1 #*************** Configuring the master node Step1
{
$ECHO "\nStarting the first step of the cluster configuration on master node \"$HOSTNAME\" ..."

# 1. ----------Configuring the network set-up by editing /etc/host ---------------------
$ECHO "Configuring the network set-up of master node \"$HOSTNAME\" by editing host & interfaces files ..."
cp /etc/hosts $clubin/aa-hosts
cp /etc/hosts $clubin/$HOSTNAME-hosts
$ECHO "Type in the password of \"$USER\" user on $HOSTNAME if needed."
sudo sed -i '2 c\192.168.1.10  '$HOSTNAME'' $clubin/aa-hosts

# 2. ----------Configuring the network set-up by editing /etc/network/interfaces ---------------------
cp /etc/network/interfaces $clubin/aa-interfaces
cp /etc/network/interfaces $clubin/$HOSTNAME-interfaces
$ECHO "\n# primary network interface" >> $clubin/aa-interfaces
$ECHO "auto eth0" >> $clubin/aa-interfaces
$ECHO "iface eth0 inet static" >> $clubin/aa-interfaces
$ECHO "address 192.168.1.10" >> $clubin/aa-interfaces
$ECHO "netmask 255.255.255.0" >> $clubin/aa-interfaces
$ECHO "gateway 192.168.1.1" >> $clubin/aa-interfaces
$ECHO "dns-nameservers 8.8.8.8.8.8.4.4" >> $clubin/aa-interfaces
sudo cp $clubin/aa-interfaces /etc/network/interfaces 

cp /etc/exports $clubin/aa-exports
cp /etc/exports $clubin/$HOSTNAME-exports
$ECHO "\n# Modification for cluster configuration" >> $clubin/aa-exports

$ECHO "\nCreating a common user for all the nodes on Master node ..."
sudo adduser mpiu --home /home/mpiu --shell /bin/bash --uid 1010
$ECHO "Creating shared directory \"/mirror/mpiu\" for all nodes for nfs ..." 
sudo mkdir -p /mirror/mpiu
$ECHO "Changing the owner and group of \"/mirror/mpiu\" directory to mpiu ..."
sudo chown -R mpiu:mpiu /mirror/mpiu

$ECHO "1" > $clubin/ConfSteps
}

function ConfGluster # *********** GlusterFS [Optional] and configuration **
{
Idx=0
while [ $Indx -lt 3 ] 
do
  Idx=$(( Idx+1 ))
  $ECHO "\nWould like to install optional \"GlusterFS\" to improve NFS performance? \nType \'y\' for yes or \'n\' for no and press [ENTER]:"
  read Yna 
  $ECHO "$Yna" > $clubin/GlusterFs
  if [ $Yna = "y" ] || [ $Yna = "Y" ]; then	
	$ECHO "Configuring GlusterFS on master node \"$HOSTNAME\" ..."
	#sudo gluster volume create mpi transport tcp /mirror/mpiu 
	#sudo gluster volume start mpi
	#sudo gluster volume info mpi	
	$ECHO "Sorry, not yet finished ..."
     	$ECHO "n" > $clubin/GlusterFs 
	break
  elif [ $Yna = "n" ] || [ $Yna = "N" ]; then
	$ECHO "ok ...\n"
	break
  else	
	   if [ $Idx -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
	   else
		$ECHO "Invalid input try again.\n"
	   fi
  fi
done
} # *********************************************************************************************

function ConfTorQues # ********** Installing  PBS Torque on nodes ********
{
Idt=0
while [ $Idt -lt 3 ] 
do
  Idt=$(( Idt+1 ))
  $ECHO "\nWould like to install \"Torque\" to improve submission? \nType \"y\" for yes or \"n\" for no and press [ENTER]:"
  read Ynt 
  $ECHO "$Ynt" > $clubin/TorqYn
  if [ $Ynt = "y" ] || [ $Ynt = "Y" ]; then      
	$ECHO "\n---- Installing PBS Torque on node \"$HOSTNAME\" ---------------"
	InstallTorque
	break
  elif [ $Ynt = "n" ] || [ $Ynt = "N" ]; then
	$ECHO "ok, Torque will not be installed...\n"
	break
  else	
	   if [ $Idt -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
	   else
		$ECHO "Invalid input try again.\n"
	   fi
  fi
done
}

function InstallTorque # ********** InstallTorque Installing  PBS Torque on nodes ********
{
$ECHO "\nEnter the directory where to copy Torque:"
Arch=$(uname -m)
if [[ $Arch = i*86 ]]; then Arch="32"; else Arch="64" ; fi
Dirx=pacx-$Arch # read Dirx

	
if test ! -d $TorqDir ; then sudo  mkdir -p $TorqDir ; fi
$ECHO "Enter the name of \"Torque-version\" without the \".tar.gz\" file:"
TorqFile=torque-4.2.9 # read TorqFile
$ECHO "$TorqFile" > $clubin/Torqfile
sudo cp $Dirx/$TorqFile.tar.gz $TorqDir
if test -d $TorqDir; then sudo mkdir $TorqDir ; fi
cd $TorqDir
sudo tar xvfz $TorqFile.tar.gz
sudo rm $TorqFile.tar.gz
cd $TorqFile 

sudo ./configure --enable-server --enable-clients --with-scp --enable-mom
$ECHO "\nPress any key to continue and execute \"make\" command..."
read 
sudo make 

$ECHO "\nPress any key to continue and execute \"make install\" command..." 
read 
sudo make install

$ECHO "\nPress any key to continue and check if most files are created ..."
read 
$ECHO "\nChecking for the binaries if they are installed proeprly and in the right directories:"
which pbs_demux
which pbs_server
which pbs_mom
which pbs_sched

$ECHO "\nPress any key to continue and execute trqauthd daemon..."
read
$ECHO "Configure the trqauthd daemon..."
sudo cp contrib/init.d/debian.trqauthd /etc/init.d/trqauthd
sudo update-rc.d trqauthd defaults
sudo $ECHO /usr/local/lib > /etc/ld.so.conf.d/torque.conf
sudo ldconfig
sudo service trqauthd start #service trqauthd start/stop

$ECHO "\nInstallation of Torque-PBS successfully completed on \"$HOSTNAME\" ..."
$ECHO "Press any key to continue ...\n"
read
}

function ConfTorqueMasterStep2  # **********  configuring PBS Torque on master node ********
{
$ECHO "\nStarting the configuration of Torque-PBS on master node: \"$HOSTNAME\" ..."
$ECHO "Executing make packages..."
sudo make packages
libtool --finish /usr/local/lib
$ECHO "Press any key to continue ..."
read 

sudo $ECHO "$HOSTNAME" > $clubin/server_name
sudo cp $clubin/server_name /var/spool/torque

# 13. Add nodes to the /var/spool/torque/server_priv/nodes file
$ECHO "\nAdding compute nodes to the /var/spool/torque/server_priv/nodes file..."
$ECHO "# compute nodes listing" > $clubin/aa-nodes
$ECHO "$HOSTNAME np=`grep proc /proc/cpuinfo | wc -l`" >> $clubin/aa-nodes

# 14. ************** copy the packges to shared mirror folder then to other nodes and install ***************
$ECHO "\nCreating a config file on all the compute nodes ..."
cp torque-package-mom-linux*.sh $clubin/
cp torque-package-clients-linux*.sh $clubin/

$ECHO "\$usecp $HOSTNAME:/mirror/mpiu /mirror/mpiu" > $clubin/config
sudo cp $clubin/config /var/spool/torque/mom_priv/

$ECHO "0" > $clubin/nodesno
$ECHO "2" > $clubin/ConfSteps
$ECHO "\nSecond step Configuration has been successfully done on the master node \"$HOSTNAME\" .... "
}

function AddMoreSlaveNode #*************** Configuring the master node
{
$ECHO "\nType in a storage media directory to copy the working directory of the cluster installation to:"
$ECHO "Example: \"/media/pems0/Lexar\" "
MedDir="/media/$USER/ADUREX"  # read MedDir
$ECHO "\nCopying the working directory of the cluster installation into a storage media \"$MedDir\" ..."
if test -d $MedDir/$clu/Backup-bin; then rm -rf $MedDir/$clu/Backup-bin ; fi
if test -d $MedDir/$clu/bin; then mv $MedDir/$clu/bin $MedDir/$clu/Backup-bin ; fi
CluDir="/$HOME/mpiu" 
cp -r $CluDir/$HOSTNAME-Cluster $MedDir/$clu/bin
$ECHO "\nTake the storage media to a slave node to continue the configuration of the cluster."
}

function ConfSlaveStep #*************** Configuring the master node Step1
{
$ECHO "\nStarting the cluster configuration on a slave node: \"$HOSTNAME\" ..."
if test ! -f $clubin/slauser.list; then touch $clubin/slauser.list ; fi

# ********** Getting details of a slave node *********************************
Nd=`head -1 $clubin/nodesno`
$ECHO "$HOSTNAME $USER" >> $clubin/slauser.list

if [ $Nd != "0" ]; then  
$ECHO "\nThese are the details of the compute nodes already in the cluster or about to be included:"
head -$Nd $clubin/slauser.list
fi

$ECHO "Details of this compute node you want included are:"
$ECHO "Computer: $HOSTNAME    Username: $USER \n"

$ECHO "Creating a common user for all the nodes on \"$HOSTNAME\" node ..."
$ECHO "Type in the password of \"$USER\" user on $HOSTNAME if needed."
sudo adduser mpiu --home /home/mpiu --shell /bin/bash --uid 1010
$ECHO "Creating shared directory \"/mirror/mpiu\" on \"$HOSTNAME\" node for nfs ..."
sudo mkdir -p /mirror/mpiu
$ECHO "Changing the owner and group of \"/mirror/mpiu\" directory to mpiu on \"$HOSTNAME\" ..."
sudo chown -R mpiu:mpiu /mirror/mpiu

#*************** Configuring the network set-up of $HOSTNAME node by editing host **************
$ECHO "Configuring the network set-up of $HOSTNAME node by editing host & interfaces files ..."
cp /etc/hosts $clubin/$HOSTNAME-hosts
Nx=$(( Nd+3 ))
Nk=$(( Nd+1 ))
$ECHO "Type in the password of \"$USER\" user on $HOSTNAME if needed."
sed -i ''$Nx' i\192.168.1.1'$Nk'  '$HOSTNAME'' $clubin/aa-hosts
sudo cp $clubin/aa-hosts /etc/hosts

# 2. ----------Configuring the network set-up by editing /etc/network/interfaces -------------
cp /etc/network/interfaces $clubin/$HOSTNAME-interfaces 
Ng=$(( Nd+1 ))
sed -i '/address/ c\address 192.168.1.1'$Ng'' $clubin/aa-interfaces
sudo cp $clubin/aa-interfaces /etc/network/interfaces 
$ECHO "Need to Restart Master node \"$HOSTNAME\" network server. \nIt will be done by rebooting the system later..."

cp /etc/fstab $clubin/$HOSTNAME-fstab
Hnode=`head -1 $clubin/MasterNode`
sudo $ECHO "\n# Modification for cluster configuration" >> /etc/fstab
sudo $ECHO "$Hnode:/mirror/mpiu /mirror/mpiu nfs rw,async,tcp 0 0" >> /etc/fstab
$ECHO "$HOSTNAME np=`grep proc /proc/cpuinfo | wc -l`" >> $clubin/aa-nodes

Yna=`head -1 $clubin/GlusterFs`
if [ $Yna = "y" ] || [ $Yna = "Y" ]; then
 $ECHO "Configuring GlusterFS on slave node \"$HOSTNAME\" ..."  
 sudo mount -t glusterfs $Hnode:/mpi /mirror/mpiu
fi

# Installing Torque on slave nodes ConfTorque ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Ynt=`head -1 $clubin/TorqYn`
if [ $Ynt = "y" ] || [ $Ynt = "Y" ]; then InstallTorque ; fi 


$ECHO "\nStarting the configuration of Torque-PBS on slave node: \"$HOSTNAME\" ..."
sudo cp $clubin/server_name /var/spool/torque
sudo cp $clubin/config /var/spool/torque/mom_priv/
sudo sh $clubin/torque-package-mom-linux*.sh --install
sudo sh $clubin/torque-package-clients-linux*.sh --install 

$ECHO "\n--Enabling TORQUE as a service..."  
sudo cp contrib/init.d/debian.pbs_mom /etc/init.d/pbs_mom
sudo update-rc.d pbs_mom defaults
	
Nn=$(( Nd+1 ))
$ECHO "$Nn" > $clubin/nodesno
$ECHO "Yes" > $clubin/AddSlave
$ECHO "\nConfiguration has been successfully done on the slave node \"$HOSTNAME\" .... "

$ECHO "\nType in a storage media directory to copy the working directory of the cluster installation to:"
$ECHO "Example: \"/media/pems0/Lexar\" " 
MedDir="/media/$USER/ADUREX"  # read MedDir
$ECHO "\nCopying the working directory of the cluster installation into a storage media \"$MedDir\" ..."
if test -d $MedDir/$clu/Backup-bin; then rm -rf $MedDir/$clu/Backup-bin ; fi
mv $MedDir/$clu/bin $MedDir/$clu/Backup-bin
cp -r $clubin $MedDir/$clu/bin
$ECHO "\nTake the storage media to another slave node or the master node to complete the configuration of the cluster."

$ECHO "\nNeed to reboot the system for the changes to take effect .."
$ECHO "Press any key to continue ..."
read 
$ECHO "Rebooting ...\n"
sudo reboot
}

function ConfMasterStep3 #*************** Configuring the master node
{
$ECHO "\nType in a storage media directory to copy the working directory of the cluster installation from:"
MedDir="/media/$USER/ADUREX"  # read MedDir
$ECHO "\nCopying the working directory of the cluster installation from a storage media \"$MedDir\" ..."
if test -d Backup-bin; then rm -rf Backup-bin ; fi
if test -d bin; then mv bin Backup-bin ; fi
cp -r $MedDir/$clu/bin bin

# ********** Getting details of Compute nodes *********************************
$ECHO "\nStarting the third step of the cluster configuration on master node \"$HOSTNAME\" ..."
Nd=`head -1 $clubin/nodesno`
$ECHO "\nThese are the details of the compute nodes already included or about to be included in the cluster:"
head -$Nd $clubin/slauser.list

$ECHO "Type in the password of \"$USER\" user on $HOSTNAME if needed."
if test -f $clubin/slauser.list; then 
  IFS=$'\n'  
  for i in `cat $clubin/slauser.list`
  do
	Hostx=`$i| awk '{print $1}'`
	$ECHO "/mirror/mpiu $Hostx(rw,async,subtree_check,nohide)" >> $clubin/aa-exports
  done 
  sudo cp $clubin/aa-exports /etc/exports 
  
  sudo cp $clubin/aa-hosts /etc/hosts 
  sudo cp $clubin/aa-nodes /var/spool/torque/server_priv/nodes
  for i in `cat $clubin/slauser.list`
  do
	Hostx=`$i| awk '{print $1}'`	
	Userx=`$i| awk '{print $2}'`
	sudo scp $clubin/aa-hosts $Userx@$Hostx:/etc/hosts 
	sudo scp $clubin/aa-nodes $Userx@$Hostx:/var/spool/torque/server_priv/nodes 	
	
	$ECHO "\nNeed to reboot the system for the changes to take effect .."
	$ECHO "Press any key to continue ..."
	read 
	$ECHO "Rebooting ...\n"
	sudo ssh $Userx@$Hostx /sbin/reboot
  done
  unset IFS
  
  $ECHO "Restarting Master node \"$HOSTNAME\" network server ..."
  sudo ifdown eth0 && sudo ifup eth0  
  $ECHO "Restarting nfs server ..."
  sudo /etc/init.d/nfs-kernel-server restart 
  
  # 4. ------- Changing user to mpiu to configure Openssh server -----------------------
  sudo cp $clubin/slauser.list /home/mpiu
  $ECHO "\nChange user to mpiu to configure Openssh server by following these instructions:\n"
  $ECHO "1. Enter the password of \"mpiu\" user."
  $ECHO "2. Copy and enter the following one after the other into the terminal"
  $ECHO ""
  $ECHO " ssh-keygen -t rsa "
  $ECHO " for i in \`cat slauser.list\`; do Hostx=`echo $i| awk '{print $1}'`; ssh-copy-id -i /home/mpiu/.ssh/id_rsa.pub mpiu@\$Hostx; done "

  $ECHO " exit "
  su - mpiu 
  $ECHO "\nUser changed to \"$USER\" ..."  
  sudo rm /home/mpiu/slauser.list 
  
  # Initialize serverdb by executing the torque.setup script.
  TorqV=`head -1 $clubin/Torqfile`
  cd $TorqDir/$TorqV
  
  $ECHO "changing to root user"
  $ECHO "Type in \" ./torque.setup root \""
  $ECHO "Then type in  \" exit \" after execution...\n"
  sudo -s   
  $ECHO "\nUser changed to \"$USER\" ..."
  
  sudo qterm
  sudo pbs_server
  $ECHO "\n--- Sanity Check..."  
  pbsnodes -a
  
  # 15. ************** Enabling TORQUE as a service ****************************
  $ECHO "\n--Enabling TORQUE as a service..."  
  sudo cp contrib/init.d/debian.pbs_mom /etc/init.d/pbs_mom
  sudo update-rc.d pbs_mom defaults
  sudo cp contrib/init.d/debian.pbs_server /etc/init.d/pbs_server
  sudo update-rc.d pbs_server defaults
fi

$ECHO "3" > $clubin/ConfSteps
$ECHO "No" > $clubin/AddSlave
#rm $clubin/slauser.list

$ECHO "\nThird step Configuration is successfully done on the master node: \"$HOSTNAME\" .... "

$ECHO "\nSaving the working directory of the cluster installation in the home of \"mpiu@$HOSTNAME\" .... "
Time=`date '+ %d%m%y-%H%M%S'` 
CluDir="/$HOME/mpiu"  # read MedDir
if test -d $CluDir/$HOSTNAME-Cluster; then 
	mv $CluDir/$HOSTNAME-Cluster $CluDir/$HOSTNAME-Cluster-$Time 
else 
	mkdir -p $CluDir/$HOSTNAME-Cluster   
fi
cp -r $clubin $CluDir/$HOSTNAME-Cluster

$ECHO "\nType in a storage media directory to copy the working directory of the cluster installation to:"
$ECHO "Example: \"/media/pems0/Lexar\" " 
MedDir="/media/$USER/ADUREX"  # read MedDir
$ECHO "\nCopying the working directory of the cluster installation into a storage media \"$MedDir\" ..."
if test -d $MedDir/$clu/Backup-bin; then rm -rf $MedDir/$clu/Backup-bin ; fi
mv $MedDir/$clu/bin $MedDir/$clu/Backup-bin
cp -r $clubin $MedDir/$clu/bin

$ECHO "\nNeed to reboot the system for the changes to take effect .."
$ECHO "Press any key to continue ..."
read 
$ECHO "Rebooting ...\n"
sudo reboot
}

function ConfMaui # *********** Maui [Optional] installation and configuration **
{
Idx=0
while [ $Indx -lt 3 ]
do
  Idx=$(( Idx+1 ))
  $ECHO "\nWould like to install optional \"Maui\" to improve PBS performance? \nType \"y\" for yes or \"n\" for no and press [ENTER]:"
  read Yna
  if [ $Yna = "y" ] || [ $Yna = "Y" ]; then	
     cd $clubin
	 cd ..
	 $ECHO "Configuring Maui on master node \"$HOSTNAME\" ..."
	 $ECHO "\nEnter the directory where to copy Maui:"

	 Arch=$(uname -m)
	 if [[ $Arch = i*86 ]]; then Arch="32"; else Arch="64" ; fi   
	 Diry=pacx-$Arch # read Dirx
	 
	 $ECHO "Enter the name of \"Maui-version\" without the \".tar.gz\" file:"
	 MauiFile=maui-3.3.1 # read TorqFile
	 sudo cp $Diry/$MauiFile.tar.gz $TorqDir
	 cd $TorqDir
	 sudo tar xvfz $MauiFile.tar.gz
	 sudo rm $MauiFile.tar.gz
	 cd $MauiFile 
	 sudo ./configure
	 sudo make
	 sudo make install 	 #/usr/local/maui/sbin/maui
	 break
  elif [ $Yna = "n" ] || [ $Yna = "N" ]; then
	$ECHO "ok ...\n"
	break
  else	
	if [ $Idx -eq 3 ]; then
		$ECHO "Invalid input exiting after the third attempt...\n"
		exit
		else
		$ECHO "Invalid input try again.\n"
	fi
  fi
done
} # *********************************************************************************************

function UndoSlaveConf
{
# not sure > ssh-keygen -t rsa
TorqV=`head -1 $clubin/Torqfile`
cd $TorqDir/$TorqV
sudo make uninstall
sudo rm -rf /var/spool/torque
cd .. 
sudo rm -rf $TorqDir/$TorqV
cd .. $clubin
# GlusterFS not sure yet
sudo cp $clubin/$HOSTNAME-fstab /etc/fstab
sudo cp $clubin/$HOSTNAME-interfaces /etc/network/interfaces 
sudo cp $clubin/$HOSTNAME-hosts /etc/hosts
sudo -rf /mirror/mpiu
sudo deluser mpiu --remove-home
}

function UndoMasterconf
{
sudo cp $clubin/$HOSTNAME-exports /etc/exports
sudo cp $clubin/$HOSTNAME-hosts /etc/hosts
UndoMaster2
UndoMaster1
UndoMaster0
}

function UndoMaster1
{
TorqV=`head -1 $clubin/Torqfile`
cd $TorqDir/$TorqV
sudo make uninstall
sudo rm -rf /var/spool/torque
cd .. 
sudo rm -rf $TorqDir/$TorqV
cd $clubin
# GlusterFS not sure yet
}

function UndoMaster0
{
sudo rm -rf /mirror/mpiu
sudo deluser mpiu --remove-home 
sudo cp $clubin/$HOSTNAME-interfaces /etc/network/interfaces 
rm -rf $clubin 
}

#**** Run the script from here *********************
if test ! -d bin ; then   mkdir -p bin ; fi
clu="${PWD##*/}"
clubin=$(pwd)/bin
TorqDir=/usr/local/src
Main
