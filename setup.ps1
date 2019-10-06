$location=Get-Location;

# Deploy using Chef
Invoke-ChefAppDeployPath $location mypimcoresite -Install;

# Bring in the application's php runtime
$runtimePath = $(Invoke-ChefAppGetDeployment mypimcoresite).DeploymentActive.runtimePath;
&"$runtimePath\include_path\setenv.ps1";

#Remove symlnks and web.config before first install
Remove-Item "$location\mypimcoresite" -Force -Recurse;

# Install pimcore from composer
$Env:COMPOSER_MEMORY_LIMIT=-1;
composer create-project pimcore/demo-ecommerce mypimcoresite;

Copy-Item -Path "$location/web.config" -Destination "$location/mypimcoresite/web/web.config";

# Redeploy to recover the symlinks
Invoke-ChefAppRedeploy mypimcoresite -Force

# Bring in the application's php runtime (changed after redeploy)
$runtimePath = $(Invoke-ChefAppGetDeployment mypimcoresite).DeploymentActive.runtimePath;
&"$runtimePath\include_path\setenv.ps1";

# Run installer
&.\"mypimcoresite/vendor/bin/pimcore-install"

