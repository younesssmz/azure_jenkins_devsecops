pipeline {
  agent any

  stages {

    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and JaCoCo') {
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

    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }

    stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('SonarQube'){
        sh "mvn sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://devsecops-test.francecentral.cloudapp.azure.com:9000 -Dsonar.login=4d9d72c8d023204cc7be81e1589fa5d822e353f8"
        }
        timeout(time: 2, unit 'MINUTES'){
          script {
            waitForQualityGate abortPipeline: true
          }

        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "DockerHub", url: ""]) {
          sh 'printenv'
          sh 'docker build -t younesssmz/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push younesssmz/numeric-app:""$GIT_COMMIT""'
        }
      }
    }

    stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "sed -i 's#replace#younesssmz/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
          sh "kubectl apply -f k8s_deployment_service.yaml"
        }
      }
    }
    
  }

}