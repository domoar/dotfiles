<#
.SYNOPSIS
Removes stopped Docker containers using Docker's prune command.

.USAGE
DockerContainerPrune
dcp
#>
function DockerContainerPrune { docker container prune }
Export-ModuleMember -Function DockerContainerPrune -Alias dcp

#####################################################################

<#
.SYNOPSIS
Removes unused Docker images using Docker's prune command.

.USAGE
DockerImagePrune
dip
#>
function DockerImagePrune { docker image prune }
Export-ModuleMember -Function DockerImagePrune -Alias dip

#####################################################################

<#
.SYNOPSIS
Stops and removes containers, networks, and default resources for the current Docker Compose project.

.USAGE
DockerComposeDown
dcd
#>
function DockerComposeDown { docker compose down }
Export-ModuleMember -Function DockerComposeDown -Alias dcd

#####################################################################

<#
.SYNOPSIS
Starts the current Docker Compose project.

.USAGE
DockerComposeUp
dcu
#>
function DockerComposeUp { docker compose up }
Export-ModuleMember -Function DockerComposeUp -Alias dcu

#####################################################################

<#
.SYNOPSIS
Starts Docker Desktop.

.USAGE
DockerDesktopStart
dockerstart
#>
function DockerDesktopStart { docker desktop start }
Export-ModuleMember -Function DockerDesktopStart -Alias dockerstart

#####################################################################

<#
.SYNOPSIS
Stops Docker Desktop.

.USAGE
DockerDesktopStop
dockerstop
#>
function DockerDesktopStop { docker desktop stop }
Export-ModuleMember -Function DockerDesktopStop -Alias dockerstop

#####################################################################
