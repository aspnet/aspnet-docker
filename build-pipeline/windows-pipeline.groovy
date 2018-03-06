@Library('dotnet-ci') _

def buildImages = {
    stage ('Stub') {
        bat 'echo Hello world'
    }
}

if (params.RS3 == true) {
    simpleNode('windows.10.amd64.serverrs3.open', buildImages)
} else {
    simpleNode('Windows_2016', 'latest-docker', buildImages)
}
