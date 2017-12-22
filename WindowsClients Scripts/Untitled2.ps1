Function Create-PuppetStack
(
[switch] $artifactoryapp,
[switch] $artifactorydb,
[switch] $puppetmaster,
[switch] $puppetdb,
[switch] $puppetconsole,
[switch] $gitclient
)
{
Function Uninstall-Puppet
{
@"
cd /opt/puppet/bin
echo Y | ./puppet-enterprise-uninstaller
"@
}

Function Create-ARTDB(
$artapp_fqdn,
$artdb_apppassword,
$artdb_rootpassword
)
{
@"
yum-config-manager --disable base extras updates;
iptables -I INPUT -p tcp --dport 3306 -j ACCEPT -m comment --comment "Allow connections to the Artifactory database";
service iptables save;
sqlquery=;
rpm -ivh MySQL-shared-compat-5.6.23-1.el6.x86_64.rpm;
echo y | yum --disablerepo=* remove mysql-libs;
rpm -ivh MySQL-server-5.6.23-1.el6.x86_64.rpm;
rpm -ivh MySQL-client-5.6.23-1.el6.x86_64.rpm;
sqlpassfilecontent=``cat .mysql_secret``;
IFS=":";
sqlpassfilearr=(`$sqlpassfilecontent);
sqlpasswithwhitespace=`${sqlpassfilearr[3]};
sqlpass=`${sqlpasswithwhitespace// /};
unset IFS;
service mysql start;
echo y | cp /usr/bin/mysql_secure_installation /usr/bin/mysql_secure_installation.bk;
sed -i "155s/.*/   my \`$password = \"`$sqlpass\";/"  /usr/bin/mysql_secure_installation.bk;
sed -i "174s/.*/    \`$password1 = \"$artdb_rootpassword\";/" /usr/bin/mysql_secure_installation.bk;
sed -i '181,186s/.*/ /' /usr/bin/mysql_secure_installation.bk;
sed -i "300,305s/.*/ /" /usr/bin/mysql_secure_installation.bk;
sed -i "307,313s/.*/ /" /usr/bin/mysql_secure_installation.bk;
sed -i "300s/.*/set_root_password();/" /usr/bin/mysql_secure_installation.bk;
sed -i "330,335s/.*/ /" /usr/bin/mysql_secure_installation.bk;
sed -i "330s/.*/remove_anonymous_users();/" /usr/bin/mysql_secure_installation.bk;
sed -i "350,355s/.*/ /" /usr/bin/mysql_secure_installation.bk;
sed -i "350s/.*/remove_remote_root();/" /usr/bin/mysql_secure_installation.bk;
sed -i "371,376s/.*/ /" /usr/bin/mysql_secure_installation.bk;
sed -i "371s/.*/remove_test_database();/" /usr/bin/mysql_secure_installation.bk;
sed -i "391,396s/.*/ /" /usr/bin/mysql_secure_installation.bk;
sed -i "391s/.*/reload_privilege_tables();/" /usr/bin/mysql_secure_installation.bk;
/usr/bin/mysql_secure_installation.bk;
echo max_allowed_packet=8M >> /usr/my.cnf;
echo innodb_file_per_table >> /usr/my.cnf;
echo tmp_table_size=512M >> /usr/my.cnf;
echo max_heap_table_size=512M >> /usr/my.cnf;
echo innodb_log_file_size=256M >> /usr/my.cnf;
service mysql restart;
mysql --user=root --password=$artdb_rootpassword -e "CREATE DATABASE artdb CHARACTER SET utf8 COLLATE utf8_bin;";
mysql --user=root --password=$artdb_rootpassword -e "GRANT ALL on artdb.* TO 'artifactory'@'$artapp_fqdn' IDENTIFIED BY '$artdb_apppassword';";
mysql --user=root --password=$artdb_rootpassword -e "FLUSH PRIVILEGES;";
"@
}
Function Create-ARTAPP(
$artdb_fqdn,
$artdb_apppassword
)
{
@"
yum-config-manager --disable base extras updates;
iptables -I INPUT -p tcp --dport 8081 -j ACCEPT -m comment --comment "Allow connections to the Artifactory application";
service iptables save;
rpm -ivh java-1.7.0-openjdk-1.7.0.75-2.5.4.0.el5_11.src.rpm;
rpm -ivh artifactory-powerpack-rpm-3.5.3.rpm;
tar -xvf mysql-connector-java-5.1.34.tar.gz;
cp /root/mysql-connector-java-5.1.34/mysql-connector-java-5.1.34-bin.jar /opt/jfrog/artifactory/tomcat/lib;
echo y | cp /opt/jfrog/artifactory/misc/db/mysql.properties /etc/opt/jfrog/artifactory/storage.properties;
sed -i "3s/.*//" /etc/opt/jfrog/artifactory/storage.properties;
sed -i "3s/.*/url=jdbc:mysql:\/\/$artdb_fqdn`:3306\/artdb?characterEncoding=UTF-8\&elideSetAutoCommits=true/" /etc/opt/jfrog/artifactory/storage.properties;
sed -i "5s/.*//" /etc/opt/jfrog/artifactory/storage.properties;
sed -i "5s/.*/password=$artdb_apppassword/" /etc/opt/jfrog/artifactory/storage.properties;
service artifactory start;
"@
}
Function Create-PuppetConsole (
$puppetconsole_fqdn,
$art_repo
)
{
if ($art_repo -match '@') {
    $local_repo = $($art_repo.split('@')[1]).replace('http://','').replace('/','_').replace(':','_') + '.repo'
    }
    else 
    {
    $local_repo = $($art_repo).replace('http://','').replace('/','_').replace(':','_') + '.repo'
    }
@"
yum-config-manager --disable base extras updates;
rm -f /etc/yum.repos.d/$local_repo;
echo '[$local_repo]' >> /etc/yum.repos.d/$local_repo;
echo 'name=added from: $art_repo' >> /etc/yum.repos.d/$local_repo;
echo 'baseurl=$art_repo' >> /etc/yum.repos.d/$local_repo;
echo 'enabled=1' >> /etc/yum.repos.d/$local_repo;
echo 'gpgcheck=0' >> /etc/yum.repos.d/$local_repo;
iptables -I INPUT -p tcp -m multiport --destination-ports 443,8140,4433,4435 -j ACCEPT -m comment --comment "Allows connections to the Puppet Console and API Endpoints ";
service iptables save;
echo y | yum install apr*;
echo y | yum install libtool-ltdl.x86_64;
echo y | yum install unixODBC.x86_64;
#wget $art_repo/puppet-enterprise-3.7.1-el-6-x86_64.tar.gz;
#tar -xvf /root/puppet-enterprise-3.7.1-el-6-x86_64.tar.gz;
./puppet-enterprise-3.7.1-el-6-x86_64/puppet-enterprise-installer -a $puppetconsole_fqdn.answers;
"@
}
Function Create-PuppetDB (
$puppetdb_fqdn,
$art_repo
)
{
if ($art_repo -match '@') {
    $local_repo = $($art_repo.split('@')[1]).replace('http://','').replace('/','_').replace(':','_') + '.repo'
    }
    else 
    {
    $local_repo = $($art_repo).replace('http://','').replace('/','_').replace(':','_') + '.repo'
    }
@"
yum-config-manager --disable base extras updates;
rm -f /etc/yum.repos.d/$local_repo;
echo '[$local_repo]' >> /etc/yum.repos.d/$local_repo;
echo 'name=added from: $art_repo' >> /etc/yum.repos.d/$local_repo;
echo 'baseurl=$art_repo' >> /etc/yum.repos.d/$local_repo;
echo 'enabled=1' >> /etc/yum.repos.d/$local_repo;
echo 'gpgcheck=0' >> /etc/yum.repos.d/$local_repo;
iptables -I INPUT -p tcp -m multiport --destination-ports 5432,8081 -j ACCEPT -m comment --comment "Allows connections to the Puppet DB and API Endpoint";
service iptables save;
echo y | yum install apr*;
echo y | yum install libtool-ltdl.x86_64;
echo y | yum install unixODBC.x86_64;
#wget $art_repo/puppet-enterprise-3.7.1-el-6-x86_64.tar.gz;
#tar -xvf /root/puppet-enterprise-3.7.1-el-6-x86_64.tar.gz;
./puppet-enterprise-3.7.1-el-6-x86_64/puppet-enterprise-installer -a $puppetdb_fqdn.answers;
"@
}



Function Create-PuppetMaster (
$puppetmaster_fqdn,
$art_repo
) 
{
if ($art_repo -match '@') {
    $local_repo = $($art_repo.split('@')[1]).replace('http://','').replace('/','_').replace(':','_') + '.repo'
    }
    else 
    {
    $local_repo = $($art_repo).replace('http://','').replace('/','_').replace(':','_') + '.repo'
    }
@"
yum-config-manager --disable base extras updates;
rm -f /etc/yum.repos.d/$local_repo;
echo '[$local_repo]' >> /etc/yum.repos.d/$local_repo;
echo 'name=added from: $art_repo' >> /etc/yum.repos.d/$local_repo;
echo 'baseurl=$art_repo' >> /etc/yum.repos.d/$local_repo;
echo 'enabled=1' >> /etc/yum.repos.d/$local_repo;
echo 'gpgcheck=0' >> /etc/yum.repos.d/$local_repo;
iptables -I INPUT -p tcp --dport 3000 -j ACCEPT -m comment --comment "Allow connections to the Puppet Enterprise Installer";
iptables -I INPUT -p tcp -m multiport --destination-ports 8140,61613 -j ACCEPT -m comment --comment "Allows connections to the PuppetMaster and MCollective";
service iptables save;
echo y | yum install apr*;
echo y | yum install libtool-ltdl.x86_64;
echo y | yum install unixODBC.x86_64;
#wget $art_repo/puppet-enterprise-3.7.1-el-6-x86_64.tar.gz;
#tar -xvf /root/puppet-enterprise-3.7.1-el-6-x86_64.tar.gz;
./puppet-enterprise-3.7.1-el-6-x86_64/puppet-enterprise-installer -a $puppetmaster_fqdn.answers;
"@
}
Function Create-GitClient ($art_repo) 
{
$local_repo = $art_repo.replace('http://','').replace('/','_').replace(':','_') + '.repo'
$repo_server = $art_repo.replace('http://','') -replace (':.+','*')
@"
echo y | rm /etc/yum.repos.d/$repo_server
yum-config-manager --disable base extras updates;
yum-config-manager --add-repo $art_repo;
echo 'gpgcheck=0' >> /etc/yum.repos.d/$local_repo;
echo y | yum install cloog-ppl.x86_64;
echo y | yum install cpp.x86_64;
echo y | yum install gcc.x86_64;
echo y | yum install glib*;
echo y | yum install kernel-devel.x86_64;
echo y | yum install mpfr.x86_64;
echo y | yum install ppl.x86_64;
echo y | yum install zlib-devel.x86_64;
wget $art_repo-cache/git-2.3.5.tar.xz;
tar fx git-2.3.5.tar.xz;
cd git-2.3.5;
./configure --prefix=/usr --with-gitconfig=/etc/gitconfig;
make -i NO_TCLTK=YesPlease NO_OPENSSL=YesPlease NO_CURL=YesPlease NO_EXPAT=YesPlease;
make install;
"@
}
Function random-password ($length)
{
    $digits = 48..57
    $letters = 65..90 + 97..122

    # Thanks to
    # https://blogs.technet.com/b/heyscriptingguy/archive/2012/01/07/use-pow
    $password = get-random -count $length `
        -input ($digits + $letters) |
            % -begin { $aa = $null } `
            -process {$aa += [char]$_} `
            -end {$aa}

    return $password
}
Function Create-MasterAnswer (
$puppetmaster_fqdn,
$puppetdb_fqdn,
$puppetconsole_fqdn
)
{
if (!(test-path "$PSScriptRoot\AnswerFiles")){New-Item -Path "$PSScriptRoot\AnswerFiles" -ItemType Directory}
"q_puppetagent_certname='$puppetmaster_fqdn'
q_puppetagent_server='$puppetmaster_fqdn'
q_puppetdb_hostname='$puppetdb_fqdn'
q_puppetmaster_certname='$puppetmaster_fqdn'
q_puppetmaster_enterpriseconsole_hostname='$puppetconsole_fqdn'
q_all_in_one_install='n'
q_fail_on_unsuccessful_master_lookup='y'
q_install='y'
q_pe_check_for_updates='n'
q_puppet_cloud_install='y'
q_puppet_enterpriseconsole_install='n'
q_puppetagent_install='y'
q_puppetdb_install='n'
q_puppetdb_port='8081'
q_puppetmaster_dnsaltnames='puppet'
q_puppetmaster_enterpriseconsole_port='443'
q_puppetmaster_install='y'
q_skip_backup='y'
q_skip_master_verification='n'
q_vendor_packages_install='n'
" | Out-File "$PSScriptRoot\AnswerFiles\$puppetmaster_fqdn.answers" -Encoding ascii
Write-Host "Generated Puppet Master answer file at $PSScriptRoot\AnswerFiles\$puppetmaster_fqdn.answers"
}
Function Create-DBAnswer(
$activity_db_password,
$classifier_db_password,
$puppetdb_fqdn,
$puppetdb_root_password,
$console_db_password,
$puppetmaster_fqdn,
$puppetdb_password,
$rbac_db_password
)
{
if (!(test-path "$PSScriptRoot\AnswerFiles")){New-Item -Path "$PSScriptRoot\AnswerFiles" -ItemType Directory}
"q_activity_database_password='$activity_db_password'
q_classifier_database_password='$classifier_db_password'
q_database_host='$puppetdb_fqdn'
q_database_root_password='$puppetdb_root_password'
q_puppet_enterpriseconsole_database_password='$console_db_password'
q_puppetagent_certname='$puppetdb_fqdn'
q_puppetagent_server='$puppetmaster_fqdn'
q_puppetdb_database_password='$puppetdb_password'
q_puppetdb_hostname='$puppetdb_fqdn'
q_puppetmaster_certname='$puppetmaster_fqdn'
q_rbac_database_password='$rbac_db_password'
q_activity_database_name='pe-activity'
q_activity_database_user='pe-activity'
q_classifier_database_name='pe-classifier'
q_classifier_database_user='pe-classifier'
q_database_install='y'
q_database_port='5432'
q_database_root_user='root'
q_fail_on_unsuccessful_master_lookup='y'
q_install='y'
q_pe_database='y'
q_puppet_cloud_install='y'
q_puppet_enterpriseconsole_database_name='console'
q_puppet_enterpriseconsole_database_user='console'
q_puppet_enterpriseconsole_install='n'
q_puppetagent_install='y'
q_puppetdb_database_name='pe-puppetdb'
q_puppetdb_database_user='pe-puppetdb'
q_puppetdb_install='y'
q_puppetdb_plaintext_port='8080'
q_puppetdb_port='8081'
q_puppetmaster_install='n'
q_rbac_database_name='pe-rbac'
q_rbac_database_user='pe-rbac'
q_skip_backup='y'
q_skip_master_verification='n'
q_vendor_packages_install='n'
" | Out-File "$PSScriptRoot\AnswerFiles\$puppetdb_fqdn.answers" -Encoding ascii
Write-Host "Generated PuppetDB answer file at $PSScriptRoot\AnswerFiles\$puppetdb_fqdn.answers"
}
Function Create-ConsoleAnswer (
$activity_db_password,
$classifier_db_password,
$puppetdb_fqdn,
$puppetconsole_fqdn,
$console_admin_password,
$console_db_password,
$puppetmaster_fqdn,
$puppetdb_db_password,
$rbac_db_password
)
{
if (!(test-path "$PSScriptRoot\AnswerFiles")){New-Item -Path "$PSScriptRoot\AnswerFiles" -ItemType Directory}
"q_activity_database_password='$activity_db_password'
q_classifier_database_password='$classifier_db_password'
q_database_host='$puppetdb_fqdn'
q_public_hostname='$puppetconsole_fqdn'
q_puppet_enterpriseconsole_auth_password='$console_admin_password'
q_puppet_enterpriseconsole_database_password='$console_db_password'
q_puppet_enterpriseconsole_master_hostname='$puppetmaster_fqdn'
q_puppetagent_certname='$puppetconsole_fqdn'
q_puppetagent_server='$puppetmaster_fqdn'
q_puppetdb_database_password='$puppetdb_db_password'
q_puppetdb_hostname='$puppetdb_fqdn'
q_puppetmaster_certname='$puppetmaster_fqdn'
q_rbac_database_password='$rbac_db_password'
q_activity_database_name='pe-activity'
q_activity_database_user='pe-activity'
q_classifier_database_name='pe-classifier'
q_classifier_database_user='pe-classifier'
q_database_port='5432'
q_fail_on_unsuccessful_master_lookup='y'
q_install='y'
q_pe_database='y'
q_puppet_cloud_install='y'
q_puppet_enterpriseconsole_database_name='console'
q_puppet_enterpriseconsole_database_user='console'
q_puppet_enterpriseconsole_httpd_port='443'
q_puppet_enterpriseconsole_install='y'
q_puppetagent_install='y'
q_puppetdb_database_name='pe-puppetdb'
q_puppetdb_database_user='pe-puppetdb'
q_puppetdb_install='n'
q_puppetdb_port='8081'
q_puppetmaster_install='n'
q_rbac_database_name='pe-rbac'
q_rbac_database_user='pe-rbac'
q_skip_backup='y'
q_skip_master_verification='n'
q_vendor_packages_install='n'
" | Out-File "$PSScriptRoot\AnswerFiles\$puppetconsole_fqdn.answers" -Encoding ascii
Write-Host "Generated Puppet Console answer file at $PSScriptRoot\AnswerFiles\$puppetconsole_fqdn.answers"
}
Function Run-SSHCommands ($server, $folder, $command, $cred) 
{
"Running on $server"
if ($folder) {Set-SCPFile -ComputerName $server -Credential $cred -Port 22 -LocalFile "$PSScriptRoot\AnswerFiles\$server.answers" -RemotePAth '/root/'}
$session = New-SSHSession -ComputerName "$server" -Credential $cred -Port 22
Invoke-SSHCommand -Command $command -SSHSession $session -TimeOut 1000
Remove-SSHSession -SessionId 0

}
Function Get-LocalVariables (
        [switch] $artdbfqdn,
        [switch] $artdbip,
        [switch] $artappfqdn,
        [switch] $artappip,
        [switch] $artdbrootpassword,
        [switch] $puppetmasterfqdn,
        [switch] $puppetdbfqdn,
        [switch] $puppetconsolefqdn,
        [switch] $consoleadminpassword,
        [switch] $folderparam,
        [switch] $gitclientfqdn,
        [switch] $artrepo
        )
{
            $artadb_fqdn = $null
            $artdb_ip = $null
            $artapp_fqdn = $null
            $artapp_ip = $null
            $artdb_apppassword = $null
            $artdb_rootpassword = $null
            $puppetmaster_fqdn = $null
            $puppetdb_fqdn = $null
            $puppetconsole_fqdn = $null
            $console_admin_password = $null
            $folder = $null
            $art_repo = $null
            $git_client_fqdn = $null
            
            if ($artdbfqdn) {$artadb_fqdn = $(read-host 'What is the FQDN of the Artifactory DB Server').ToLower()}
            if ($artdbip){$artdb_ip = read-host 'What is the IP address of the Artifactory DB server'}
            if ($artappfqdn){$artapp_fqdn = $(read-host 'What is the FQDN of the Artifactory APP Server').ToLower()}
            if ($artappip){$artapp_ip = read-host 'What is the IP address of the Artifactory APP server'}
            if ($artdbrootpassword){$artdb_rootpassword = read-host 'What would you like the root password for the Artifactory DB'}
            if ($puppetmasterfqdn){ $puppetmaster_fqdn = $(read-host 'What is the FQDN of the Puppet Master')}
            if ($puppetdbfqdn){$puppetdb_fqdn = $(read-host 'What is the FQDN of the Puppet DB').ToLower()}
            if ($puppetconsolefqdn){$puppetconsole_fqdn = $(read-host 'What is the FQDN of the Puppet Console').ToLower()}
            if ($consoleadminpassword){$console_admin_password = read-host 'What is the required Puppet Console Password'}
            if ($folderparam) {$folder = read-host 'Where is the location Repo that rpms are located'}
            if ($artrepo){$art_repo = read-host 'Where is the repo location for puppet stack'}
            if ($gitclientfqdn) {$git_client_fqdn = read-host 'What is the Git Client FQDN'}
            $returnarr = New-Object PSObject -Property @{
                artdb_fqdn = "$artadb_fqdn".Trim()
                artdb_ip = "$artdb_ip".Trim()
                artapp_fqdn = "$artapp_fqdn".Trim()
                artapp_ip = "$artapp_ip".Trim()
                artdb_apppassword = "$artdb_apppassword".Trim()
                artdb_rootpassword = "$artdb_rootpassword".Trim()
                puppetmaster_fqdn = "$puppetmaster_fqdn".Trim()
                puppetdb_fqdn = "$puppetdb_fqdn".Trim()
                puppetconsole_fqdn = "$puppetconsole_fqdn".Trim()
                console_admin_password = "$console_admin_password".Trim()
                folder = $folder 
                art_repo = "$art_repo".Trim()
                git_client_fqdn = "$git_client_fqdn".Trim()
                }
            Return $returnarr
        }
    $neededvarstemp = @()
    $localvararr = @()
    $command = @()
    $neededvarsarr = @()
    $passwordLength = 22
    if ($(get-command).ModuleName -notcontains 'Posh-SSH') {iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")}
    
    $passwordarr = New-Object PSObject -Property @{
        activity_db_password = $(random-password($passwordLength))
        classifier_db_password = $(random-password($passwordLength))
        puppetdb_root_password = $(random-password($passwordLength))
        console_db_password = $(random-password($passwordLength))
        puppetdb_password = $(random-password($passwordLength))
        rbac_db_password = $(random-password($passwordLength))
        puppetdb_db_password = $(random-password($passwordLength))
        artdb_apppassword = $(random-password($passwordLength))
    }

    if(!($cred)) {$cred = Get-Credential -Message "What is the root password" -UserName 'root'}
    if ($artifactoryapp){$neededvarsarr += @('artappfqdn','artdbfqdn','artdbapppassword') }
    if ($artifactorydb) {$neededvarsarr += @('artappfqdn','artdbfqdn','artdbapppassword','artdbrootpassword')}
    if ($puppetmaster) {$neededvarsarr += @('puppetmasterfqdn','artrepo','puppetdbfqdn','puppetconsolefqdn','artrepo')}
    if ($puppetdb) {$neededvarsarr += @('puppetmasterfqdn','artrepo','puppetdbfqdn','puppetconsolefqdn','artrepo','consoleadminpassword')}
    if ($puppetconsole) {$neededvarsarr += @('puppetmasterfqdn','artrepo','puppetdbfqdn','puppetconsolefqdn','artrepo', 'consoleadminpassword')}
    if ($gitclient) {$neededvarsarr += @('gitclientfqdn','artrepo')}
    $neededvarstemp = $($neededvarsarr | sort | Get-Unique) -join ' -'
    $neededvarstemp = '-' + $neededvarstemp
    $localvararr = invoke-expression "Get-LocalVariables $neededvarstemp"

    if ($artifactorydb) {
    $command = Create-ARTDB -artapp_fqdn $($localvararr.artapp_fqdn) -artdb_apppassword $($passwordarr.artdb_apppassword) -artdb_rootpassword $($localvararr.artdb_rootpassword)
    Run-SSHCommands -server $($localvararr.artdb_fqdn) -command $command -folder "$PSScriptRoot\ART_SQL" -cred $cred
    }
    if ($artifactoryapp){
    $command = Create-ARTAPP -artdb_fqdn $($localvararr.artdb_fqdn) -artdb_apppassword $($passwordarr.artdb_apppassword)
    Run-SSHCommands -server $($localvararr.artapp_fqdn) -command $command -folder "$PSScriptRoot\ART_APP" -cred $cred
    }

   if ($puppetmaster) {
        $scriptblock +=
@"

        Create-MasterAnswer -puppetmaster_fqdn $($localvararr.puppetmaster_fqdn) -puppetdb_fqdn $($localvararr.puppetdb_fqdn) -puppetconsole_fqdn $($localvararr.puppetconsole_fqdn);
        `$command = Create-PuppetMaster -puppetmaster_fqdn $($localvararr.puppetmaster_fqdn) -art_repo $($localvararr.art_repo);
        Run-SSHCommands -server $($localvararr.puppetmaster_fqdn) -command `$command -cred `$cred -folder "$PSScriptRoot\AnswerFiles";
"@
    }

   if ($puppetdb) {
        $scriptblock +=
@"

        Create-DBAnswer -activity_db_password $($passwordarr.activity_db_password) -classifier_db_password $($passwordarr.classifier_db_password) -puppetdb_root_password $($passwordarr.puppetdb_root_password) -puppetdb_password $($passwordarr.puppetdb_password) -rbac_db_password $($passwordarr.rbac_db_password) -puppetdb_fqdn $($localvararr.puppetdb_fqdn) -puppetmaster_fqdn $($localvararr.puppetmaster_fqdn) -console_db_password $($passwordarr.console_db_password);
        `$command = Create-PuppetDB -puppetdb_fqdn $($localvararr.puppetdb_fqdn) -art_repo $($localvararr.art_repo);
        Run-SSHCommands -server $($localvararr.puppetdb_fqdn) -command `$command -cred `$cred -folder "$PSScriptRoot\AnswerFiles";
"@
    }


   if ($puppetconsole) {
        $scriptblock +=
@"

        Create-ConsoleAnswer -activity_db_password $($passwordarr.activity_db_password) -classifier_db_password $($passwordarr.classifier_db_password) -puppetdb_db_password $($passwordarr.puppetdb_root_password) -rbac_db_password $($passwordarr.rbac_db_password) -puppetdb_fqdn $($localvararr.puppetdb_fqdn) -puppetconsole_fqdn $($localvararr.puppetconsole_fqdn) -puppetmaster_fqdn $($localvararr.puppetmaster_fqdn) -console_db_password $($passwordarr.console_db_password) -console_admin_password $($localvararr.console_admin_password);
        `$command = Create-PuppetDB -puppetdb_fqdn $($localvararr.puppetdb_fqdn) -art_repo $($localvararr.art_repo);
        Run-SSHCommands -server $($localvararr.puppetconsole_fqdn) -command `$command -cred `$cred -folder "$PSScriptRoot\AnswerFiles";
"@
        }

    if ($gitclient) {
        $scriptblock +=
@"

         `$command = Create-GitClient -art_repo $($localvararr.art_repo)
         Run-SSHCommands -server $($localvararr.git_client_fqdn) -command `$command -cred `$cred
"@
         }  

            $scriptblockconvert = [scriptblock]::Create($scriptblock)
            Invoke-Command -ScriptBlock $scriptblockconvert
}

 