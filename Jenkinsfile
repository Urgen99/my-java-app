pipeline {
    agent {
        label 'ubuntu-slave'
    }
    stages {
        stage('Build') {
           steps {
            sh 'mvn -f /var/lib/jenkins/workspace/javaapp/pom.xml clean package'
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
    