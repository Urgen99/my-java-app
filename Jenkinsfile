pipeline {
    agent {
        label 'ubuntu-slave'
    }
    stages {
        stage('Build') {
           steps {
            sh 'mvn -f home/vagrant/pom.xml clean package'
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
    