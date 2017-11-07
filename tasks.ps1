param (
	$outputDirectory = (property outputDirectory "artifacts"),
	$configuration = (property configuration "Release")
	)

	$absoluteOutputDirectory = "$((Get-Location).Path)\$outputDirectory"
	$projects = Get-SolutionProjects
	$octopusDeployServer ="http://localhost:8181"
	$octopusDeployApiKey = "API-JTBAGTU6EYLKLHA57BBPVMXFYQ"

	task Clean {
		if ((Test-Path $absoluteOutputDirectory)) 
		{
			Remove-Item "$absoluteOutputDirectory" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
		}
		New-Item $absoluteOutputDirectory -ItemType Directory | Out-Null
	
			$projects |
			ForEach-Object {
				Write-Host "Cleaning bin and obj folders for $($_.Directory)\bin"
				Remove-Item "$($_.Directory)\bin" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
				Remove-Item "$($_.Directory)\obj" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
			}
	}

	task Compile {
		use "14.0" MSBuild
		$projects |
			ForEach-Object {

				Write-Host "Is web project $($_.IsWebProject)"
				if($_.IsWebProject) 
				{
					$webOutDir = "$absoluteOutputDirectory\$($_.Name)"
					$outDir = "$absoluteOutputDirectory\$($_.Name)\bin"	

					Write-Host "Compiling $($_.Name) to $webOutDir"

					exec{MSBuild $($_.Path) /p:Configuration=$configuration /p:OutDir=$outDir /p:WebProjectOutputDir=$webOutDir `
									/nologo /p:DebugType=None /p:Platform=AnyCpu /verbosity:quiet}
				}else 
				{
					$outDir = "$absoluteOutputDirectory\$($_.Name)"	

					Write-Host "Compiling $($_.Name) to $outDir"

					exec{MSBuild $($_.Path) /p:Configuration=$configuration /p:OutDir=$outDir /p:WebProjectOutputDir=$webOutDir `
									/nologo /p:DebugType=None /p:Platform=AnyCpu /verbosity:quiet}
			
				}
	 	  }
	}


	task Test {
		$projects |
			ForEach-Object {
				$xunitPath = Get-PackagePath "xunit.runner.console" $($_.Directory)
				if ($xunitPath -eq $null) {
					Write-Host "xunit not found"
					return
				}
				$xunitRunner = "$xunitPath\tools\net452\xunit.console.exe"
				Write-Host " x unit runner $absoluteOutputDirectory"
				exec{ & $xunitRunner $absoluteOutputDirectory\$($_.Name)\$($_.Name).dll `
					 -xml "$absoluteOutputDirectory\xunit_$($_.Name).xml" `
					-html "$absoluteOutputDirectory\xunit_$($_.Name).html" `
					-nologo}
			}
	}

	task Pack{
			$projects |
			ForEach-Object {
				$octopusToolsPath = Get-PackagePath "OctopusTools" $($_.Directory)
				if ($octopusToolsPath -eq $null) {
					Write-Host "OctopusTools not found"
					return
				}
					Write-Host "Octopus tools path $octopusToolsPath"
			
				$version = Get-Version $_.Directory
				Write-Host "Version $version"
				exec{ & $octopusToolsPath\tools\Octo.exe pack `
												--basePath=$absoluteOutputDirectory\$($_.Name) `
												--outFolder=$absoluteOutputDirectory --id=$($_.PackageId) `
												--overwrite `
												--version=$version}
		}
	}
	
	task Push {
		Write-Host "Reached in Push $octopusDeployServer"
		$projects |
			ForEach-Object {
					$octopusToolsPath = Get-PackagePath "OctopusTools" $($_.Directory)
					if ($octopusToolsPath -eq $null) {
						return
					}
					$package = @(Get-ChildItem $absoluteOutputDirectory\$($_.PackageId)*.nupkg)
					exec{ NuGet push $package -Source "$octopusDeployServer/nuget/packages" `
											  -ApiKey $octopusDeployApiKey }
					
				}
	}

	task Release {
		$projects |
		ForEach-Object {
			$octopusToolsPath = Get-PackagePath "OctopusTools" $($_.Directory)

			if($octopusToolsPath -eq $null){
				return
			}
			$version = Get-Version $_.Directory
			Write-Host "Get version $version"
			exec { & $octopusToolsPath\tools\Octo.exe create-release `
			  --server="$octopusDeployServer" `
			  --apiKey="$octopusDeployApiKey" `
			  --project="$($_.PackageId)" `
			  --version="$version" `
			  --packageVersion="$version" `
			  --ignoreexisting }
	} 
}

task Deploy{
	$projects |
		ForEach-Object {
			$octopusToolsPath = Get-PackagePath "OctopusTools" $($_.Directory)
			if($octopusToolsPath -eq $null){
				return
			} 
			$version = Get-Version $_.Directory
				exec { & $octopusToolsPath\tools\Octo.exe deploy-release `
				--server="$octopusDeployServer" `
				--apiKey="$octopusDeployApiKey" `
				--project="$($_.PackageId)" `
				--version="$version" `
				--deployto="$env:environment" }
		}
}

	task dev clean, compile, test, pack
	task ci dev, push, release


	task Test{
		Write-Host "Applicatio Directory $octopusDeployServer"
	}