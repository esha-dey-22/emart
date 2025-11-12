pipeline {
  agent any
  environment {
    IMAGE = "esha0629/emart-site"
    TAG = "${env.BUILD_ID}"
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Prepare') {
      steps {
        echo 'Preparing static site (no build step configured)'
        sh 'echo "Running on: $(hostname)"; docker --version || true'
      }
    }

    stage('Docker Build & Push (CLI)') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            set -e
            echo "Logging into Docker Hub as $DOCKER_USER"
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

            echo "Building image ${IMAGE}:${TAG}"
            docker build -t ${IMAGE}:${TAG} .

            echo "Tagging latest"
            docker tag ${IMAGE}:${TAG} ${IMAGE}:latest

            echo "Pushing tags"
            docker push ${IMAGE}:${TAG}
            docker push ${IMAGE}:latest

            docker logout || true
          '''
        }
      }
    }

    stage('Cleanup Images') {
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
