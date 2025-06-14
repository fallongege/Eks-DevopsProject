### Build Pipeline
```
pipeline {
    agent any

    parameters {
        string(name: 'DOCKER_REPO', defaultValue: 'amazon-prime', description: 'Enter repository name')

    }

      tools {
        jdk 'JDK17'
        nodejs 'NodeJS16'
    }

    environment {
        SONAR_HOME = tool 'SonarQubeScanner'

    }

    stages {
        stage('1. Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/fallongege/Eks-DevopsProject.git'
            }
        }

        stage('2. Sonar Scan') {
            steps {
                withSonarQubeEnv ('SonarQube') {
                    sh """
                    $SONAR_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=amazon-prime \
                    -Dsonar.projectKey=amazon-prime
                    """
                }
            } 
        }

        stage('3. Sonar Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
            }
        }

        stage('4. NPM Install') {
            steps {
                sh "npm install"
            }
        }

       stage('5. Trivy Scan') {
            steps {
                sh "trivy fs . > trivy.txt"
            }
        }

      stage('6. Docker Image Build && Tag') {
            steps {
                sh """
                docker build -t ${params.DOCKER_REPO} .
                docker tag ${params.DOCKER_REPO} ${params.DOCKER_REPO}:${BUILD_NUMBER}
                docker tag ${params.DOCKER_REPO} ${params.DOCKER_REPO}:latest
                """
            }
        }
      stage('7. Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerHubCredentials', passwordVariable: 'dockerPassword', usernameVariable: 'dockerUsername')]) {
                sh "docker login -u ${env.dockerUsername} -p ${env.dockerPassword}"
                sh 'docker push ${params.DOCKER_REPO}:${BUILD_NUMBER}'
                sh 'docker push ${params.DOCKER_REPO}:latest'
                }
            }
        }
     stage('8 Docker Cleanup Images') {
            steps {
                sh """
                docker rmi ${params.DOCKER_REPO} ${params.DOCKER_REPO}:${BUILD_NUMBER}
                docker rmi ${params.DOCKER_REPO} ${params.DOCKER_REPO}:latest
                """

            }

     }

    }

    post {
           always {
               sh 'docker logout'
           }
       }
}

```