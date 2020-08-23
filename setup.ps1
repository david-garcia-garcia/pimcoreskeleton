param([string]$name="mypimcoresite")

$location=(Get-Location).Path;

# Deploy using Chef
Invoke-ChefAppDeployPath $location $name -Install;

# Bring in the application's php runtime
$runtimePath = $(Invoke-ChefAppGetDeployment mypimcoresite).DeploymentActive.runtimePath;
&"$runtimePath\include_path\setenv.ps1";

#Remove symlnks and web.config before first install
echo "Remove directory : " + "$location\mypimcoresite" 
Remove-Item "$location\mypimcoresite" -Force -Recurse;

# Install pimcore from composer
Set-Location $location
$Env:COMPOSER_MEMORY_LIMIT=-1;
composer create-project pimcore/skeleton mypimcoresite;

Copy-Item -Path "$location/web.config" -Destination "$location/mypimcoresite/web/web.config";

# Redeploy to recover the symlinks
Invoke-ChefAppRedeploy $name -Force

# Bring in the application's php runtime (changed after redeploy)
$runtimePath = $(Invoke-ChefAppGetDeployment $name).DeploymentActive.runtimePath;
&"$runtimePath\include_path\setenv.ps1";

# Run installer
&.\"mypimcoresite/vendor/bin/pimcore-install"

