pipeline { 
    agent {
        label 'ubuntu-slave'
    }
    environment {
        scannerHome = tool 'sonar6.2'
        dockerhub_credentail_id = '	Dockerhub-credentials'
        DOCKER_HUB_REPO = "urgentamang/localtomcatimg"
        terraform_workdir = '/terraform'
        aws_credentials_id = 'AKIAXZ5NFYJPPW3X3MIT'

        // registry = "urgentamang/localtomcatimg"
        // registryCredential = 'Dockerhub-credentials'
        // dockerImage = 'localtomcatimg:$BUILD_NUMBER'
        // dockerhub_credential = credentials('dockerhub')
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
        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=java-tomcat-sample \
                        -Dsonar.projectName=java-tomcat-sample \
                        -Dsonar.projectVersion=4.0 \
                        -Dsonar.sources=src/ \
                        -Dsonar.junit.reportsPath=target/surefire-reports/ \
                        -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                        -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }
        stage("UploadArtifact") {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: '192.168.56.31:8081',
                    groupId: 'devopstesting',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: 'devops-morning-application',
                    credentialsId: 'nexuslogin',
                    artifacts: [
                        [artifactId: 'java-tomcat-sample',
                         classifier: '',
                         file: 'target/java-tomcat-maven-example.war',
                         type: 'war']
                    ]
                )
            }
        }     
        stage('Docker login ') {
            agent {
                label 'ubuntu-slave'
            }
            steps {
             
                     withCredentials([usernamePassword(credentialsId: "$dockerhub_credentail_id", usernameVariable: 'DOCKER_HUB_USERNAME', passwordVariable: 'DOCKER_HUB_PASSWORD')]) {
                       sh 'echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin'
                    
                 
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
                docker build -t ${DOCKER_HUB_REPO}:$BUILD_NUMBER .
                docker push "${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
                docker rmi "${DOCKER_HUB_REPO}:${BUILD_NUMBER}"
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
                docker run -itd --name tomcatInstanceStaging -p 8082:8080 "${DOCKER_HUB_REPO}":$BUILD_NUMBER
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
                 dir("${terraform_workdir}"){
                    echo " Running app on Prod env"
                    sh '''
                    terraform init
                    terraform plan
                    terraform apply --auto-approve 
                    docker stop tomcatInstanceProd || true
                    docker rm tomcatInstanceProd || true              
                    docker run -itd --name tomcatInstanceProd -p 8083:8080 "${DOCKER_HUB_REPO}":$BUILD_NUMBER
                 '''
                 }
                
            }
        }
    }
        post {
            always {
                mail to: 'urgentamang0909@gmail.com',
                subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) is waiting for input",
                body: "Please go to ${BUILD_URL} and verify the build"

            }
            success {
            mail bcc: '', body: """Hi Team,

                 Build #$BUILD_NUMBER is successful, please go through the url

                $BUILD_URL

                and verify the details.

                Regards,
                DevOps Team""", cc: '', from: '', replyTo: '', subject: 'BUILD SUCCESS NOTIFICATION', to: 'urgentamang0909@gmail.com'}
            failure{
            mail bcc: '', body: """Hi Team,
            
                Build #$BUILD_NUMBER is unsuccessful, please go through the url

                $BUILD_URL

                and verify the details.

                Regards,
                DevOps Team""", cc: '', from: '', replyTo: '', subject: 'BUILD FAILED NOTIFICATION', to: 'urgentamang0909@gmail.com'}


    }   
}


    