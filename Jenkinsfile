pipeline {
    agent any
    stages {
        stage('Build') {
           steps {
            sh 'mvn -f jenkins/java-tomcat-sample/pom.xml clean package'
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
    