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

if (params.RS3 == true) {
    simpleNode('windows.10.amd64.serverrs3.open', buildImages)
} else {
    simpleNode('Windows_2016', 'latest-docker', buildImages)
}
