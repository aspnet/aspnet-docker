@Library('dotnet-ci') _

def buildImages = {
    stage ('Checking out source') {
        checkout scm
    }
    stage ('Cleanup Docker') {
        bat 'docker system prune -a -f'
    }
    stage ('Build and test images') {
        bat "powershell -NoProfile -Command .\\ci-build.ps1 -Folder \"${params.folderFilter}\""
    }
    stage ('Cleanup') {
        bat 'docker system prune -a -f'
    }
}

if (params.os == 'sac2016') {
    simpleNode('Windows_2016', 'latest-docker', buildImages)
}
else {
    error 'Unrecognized variant of Windows'
}
