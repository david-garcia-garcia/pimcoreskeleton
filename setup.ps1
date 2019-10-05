$location=Get-Location;

# Deploy using Chef
Invoke-ChefAppDeployPath $location mypimcoresite -Install;

$deployment = (Invoke-ChefAppGetDeployment mypimcoresite).DeploymentActive;
$runtimePath = $deployment.runtimePath;

# Bring in the application's php runtime
&"$runtimePath\include_path\setenv.ps1";

#Remove symlnks and web.config before first install
Remove-Item "$location\mypimcoresite" -Force -Recurse;

# Install pimcore from composer
$Env:COMPOSER_MEMORY_LIMIT=-1;
composer create-project pimcore/demo-ecommerce mypimcoresite;

Copy-Item -Path "$location/web.config" -Destination "$location/mypimcoresite/web/web.config";



