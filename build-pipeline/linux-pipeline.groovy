@Library('dotnet-ci') _

simpleNode ('Ubuntu16.04', 'latest-or-auto-docker') {
    stage ('Checking out source') {
        checkout scm
    }
    stage ('Cleanup Docker') {
        sh 'docker system prune -a -f'
    }
    stage ('Install pwsh locally') {
        sh '''curl -fsSL https://github.com/PowerShell/PowerShell/releases/download/v6.0.1/powershell-6.0.1-linux-x64.tar.gz -o /tmp/powershell.tar.gz \\
            && mkdir -p $(pwd)/.powershell \\
            && tar xzf /tmp/powershell.tar.gz -C $(pwd)/.powershell'''
        sh 'rm /tmp/powershell.tar.gz || true'
    }
    stage ('Build and test images') {
        sh """export PATH=\"\$PATH:\$(pwd)/.powershell\" \\
            && ./ci-build.sh --folder-filter '${params.folderFilter}'"""
    }
    stage ('Cleanup') {
        sh 'docker system prune -a -f'
    }
}
