@Library('dotnet-ci') _

simpleNode ('Ubuntu16.04', 'latest-or-auto-docker') {
    stage ('Stub') {
        sh 'echo "Hello world"'
    }
}
