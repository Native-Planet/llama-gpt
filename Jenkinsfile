pipeline {
    agent any
        environment {
            dockerpw = credentials('Dockerhub PW')
            versionauth = credentials('VersionAuth')
        }
    parameters {
        choice(
            choices: ['build' , 'push'],
            description: 'Select "push" to push to repo',
            name: 'BUILD_ACTION')
    }
    stages {
        stage('Build') {
            steps {
                sh (
                    script: '''
                        docker login --username=nativeplanet --password=$dockerpw
                        docker build -t nativeplanet/llama-gpt:latest .
                    ''',
                returnStdout: true
                )
            }
        }
        stage('Push') {
            when {
                expression { params.BUILD_ACTION == 'push' }
            }
            steps {
                sh (
                    script: '''
                        docker push nativeplanet/llama-gpt:latest
                    ''',
                returnStdout: true
                )
            }
        }
    }
        post {
            always {
                cleanWs deleteDirs: true, notFailBuild: true
            }
        }

}