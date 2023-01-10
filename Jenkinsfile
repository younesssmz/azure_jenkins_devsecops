pipeline {
  agent any

  environment{
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "younesssmz/numeric-app:${GIT_COMMIT}"
    applicationURL="http://devsecops-test.francecentral.cloudapp.azure.com/"
    aplicationURI="/increment/99"
  }

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
    }

    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
    }

    stage('SonarQube - SAST') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh "mvn sonar:sonar -Dsonar.projectKey=numeric-app -Dsonar.host.url=http://devsecops-test.francecentral.cloudapp.azure.com:9000"
        }
        timeout(time: 2, unit: 'MINUTES') {
          script {
            waitForQualityGate abortPipeline: true
          }
        }
      }
    }

    stage('Vulnerability Scan - Docker ') {
      steps {
        parallel(
          "Dependency Scan":{
            sh "mvn dependency-check:check"
          },
          "Trivy Scan":{
            sh "bash trivy-docker-image-scan.sh"
          },
          "OPA Conftest":{
            sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
          }
        )
      }
    }
  

    stage('Docker Build and Push') {
      steps {
        withDockerRegistry([credentialsId: "DockerHub", url: ""]) {
          sh 'printenv'
          sh 'sudo docker build -t younesssmz/numeric-app:""$GIT_COMMIT"" .'
          sh 'docker push younesssmz/numeric-app:""$GIT_COMMIT""'
        }
      }
    }

    stage('Vulnerability Scan - Kubernetes'){
      steps {
        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
      }
    }

    stage('Kubernetes Deployment - DEV') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
          sh "bash k8s-deployment.sh"
          sh "bash k8s-deployment-rollout-status.sh"
        }
      }
    }
    
  }

  post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }
      }

}