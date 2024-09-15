pipeline {
    agent {
        label 'ubuntu-slave'
    }
    stages {
        stage('Build') {
           steps {
            sh 'mvn -f pom.xml clean package'
           }
           post {
            success {
                echo "Archiving the Artifact...... Congrats"
                archiveArtifacts artifacts: '**/*.war'
            }
           }
    }
    }
}
    