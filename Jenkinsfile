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
        stage('Create Tomcat Image') {
            agent {
                label 'ubuntu-slave'
            }
            steps {

                copyArtifacts filter: '**/*.war', fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER)
                echo "Building docker image"
                sh '''
                original_pwd=$(pwd -P)
                docker build -t localtomcatimg:$BUILD_NUMBER .
                cd $original_pwd
                '''
            }
        }
        stage('Deploy to Staging') {
            agent {
                label 'ubuntu-slave'
            
            }
            steps{
                echo "Running app on staging env"
                 sh '''
                docker stop tomcatInstanceStaging || true
                docker rm tomcatInstanceStaging || true
                docker run -itd --name tomcatInstanceStaging -p 8082:8080 localtomcatimg:$BUILD_NUMBER
                '''
            }

        }
        stage('Deploy production environment'){
            agent {
                label 'ubuntu-slave'

            }
            steps{
                timeout(time:1, unit: 'DAYS'){
                    input message: 'Approve PRODUCTION Deployment?'
                }
                echo " Running app on Prod env"
                sh '''
                docker stop tomcatInstanceProd || true
                docker rm tomcatInstanceProd || true
                docker run -itd --name tomcatInstanceProd -p 8083:8080 localtomcatimg:$BUILD_NUMBER
                '''
            }
        }
    }
}
    