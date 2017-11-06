function Get-SolutionProjects
{
	Add-Type -Path (${env:ProgramFiles(x86)} + '\Reference Assemblies\Microsoft\MSBuild\v14.0\Microsoft.Build.dll')
												
	$solutionsFile =(Get-ChildItem('*.sln')).FullName | Select -First 1
	$solution = [Microsoft.Build.Construction.SolutionFile] $solutionsFile

	return $solution.ProjectsInOrder |
		Where-Object {$_.ProjectType -eq 'KnownToBeMSBuildFormat' } |
		ForEach-Object {
			$isWebProject = (Select-String -pattern "<UseIISExpress>.+</UseIISExpress>" -path $_.AbsolutePath) -ne $null
			@{
				Path = $_.AbsolutePath;
				Name =  $_.ProjectName;
				Directory = "$(Split-Path -Path $_.AbsolutePath -Resolve)";
				IsWebProject = $isWebProject;

			}
		}
}

function Get-PackagePath($packageId, $projectPath) {
		if(!(Test-Path "$projectPath\packages.config")) {
			throw "Could not find packages.config file at $project"
		}
	[xml]$packagesXml = Get-Content "$projectPath\packages.config"
	$package = $packagesXml.packages.package | Where {$_.id -eq $packageId }
		if (!$package) {
		return $null
	}
		return "packages\$($package.id).$($package.version)"
}


function Get-Version($projectPath) 
{
	$line =  Get-Content "$projectPath\Properties\AssemblyInfo.cs" | Where {$_.Contains("AssemblyVersion")}
	if(!$line) {
		throw "Couldn't find an AssemblyVersion attribute"
	}
	Write-Host("In function $line")
	$version = $line.Split('"')[1]

	$isLocal =[String]::IsNullOrEmpty($env:BUILD_SERVER)
	Write-Host ("Verion line $line version $version and $isLocal")
	if ($isLocal) {
		Write-Host ("Is local $isLocal")
		$preRelease = $(Get-Date).ToString("yyMMDDHHmmss")
		$version = "$($version.Replace("*" ,0))-pre$preRelease"
		Write-Host "After version $version"
	}else {
		$version = $version.Replace("*", $env:BUILD_NUMBER)
		Write-Host ("Remote $version")
	}
	return $version
}