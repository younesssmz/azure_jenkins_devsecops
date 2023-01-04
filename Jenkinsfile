pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar'
            }
        }
      stage('Unit Tests - JUnit and Jacoco') {
          steps {
            sh "mvn test"
          }
          post {
            always {
              junit 'target/surefire-reports/*.xml'
              jacoco execPattern: 'target/jacoco.exec'
            }
          }   
      }

      stage('Docker Build and Push'){
        steps {
          withDockerRegistry([credentialsId: "DockerHub", url: ""]){
            sh 'printenv'
            sh 'docker build -t younesssmz/node-service:""$GIT_COMMIT"" .'
            sh 'docker push younesssmz/node-service:""$GIT_COMMIT""'
          }
        }
      }
      stage('Kubernetes deployment - DEV'){
        steps {
          withKubeConfig([credentialsId: "kubeconfig"]){
            sh "sed -i 's#replace#younesssmz/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
  }
}