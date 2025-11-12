pipeline {
  agent any
  environment {
    IMAGE = "esha0629/emart-site"
    TAG = "${env.BUILD_ID}"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Prepare') {
      steps {
        // If you have any build step for frontend (webpack, etc.) add here.
        sh 'echo "Preparing static site (no build step configured)"'
      }
    }
    stage('Docker Build & Push') {
      steps {
        script {
          // The credential id below should be created in Jenkins (Username + Password for Docker Hub)
          docker.withRegistry('', 'dockerhub-creds') {
            def built = docker.build("${IMAGE}:${TAG}")
            built.push()
            // also push latest
            sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest || true"
            sh "docker push ${IMAGE}:latest || true"
          }
        }
      }
    }
    stage('Cleanup') {
      steps {
        sh 'docker image prune -f || true'
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}
