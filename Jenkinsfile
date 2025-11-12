pipeline {
  agent any
  environment {
    IMAGE = "yourdockerhubusername/emart-site"
    TAG = "${env.BUILD_ID}"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Artifact (optional)') {
      steps {
        // If you had a build step (e.g. webpack) do it here. For static site, no build required.
        sh 'echo "static site - no build step"'
      }
    }
    stage('Docker Build') {
      steps {
        script {
          docker.withRegistry('', 'dockerhub-creds') { // configure credentials id in Jenkins: dockerhub-creds
            def img = docker.build("${IMAGE}:${TAG}")
            img.push()
            // tag latest
            sh "docker tag ${IMAGE}:${TAG} ${IMAGE}:latest"
            img.push('latest')
          }
        }
      }
    }
    stage('Cleanup') {
      steps {
        sh "docker image prune -f || true"
      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}
