pipeline {
  agent any
  environment {
    IMAGE = "esha0629/emart-site"   // your Docker Hub repo
    TAG   = "${env.BUILD_ID}"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Info') {
      steps {
        echo "Running on: ${env.NODE_NAME}"
        sh 'docker --version || true'
      }
    }

    stage('Build & Push (CLI)') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            set -eux
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker build -t ${IMAGE}:${TAG} .
            docker tag ${IMAGE}:${TAG} ${IMAGE}:latest
            docker push ${IMAGE}:${TAG}
            docker push ${IMAGE}:latest
            docker logout || true
          '''
        }
      }
    }

    stage('Cleanup') {
      steps { sh 'docker image prune -f || true' }
    }
  }

  post {
    always { cleanWs() }
  }
}
