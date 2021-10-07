pipeline {

  environment {
    PROJECT_DIR = "/app"
    REGISTRY = "mohammedali100/calculator_rest_api"
    DOCKER_CREDENTIALS = "docker_auth"
    DOCKER_IMAGE = ""
  }

  agent any

  options {
    skipStagesAfterUnstable()
  }

  stages {

    stage('Cloning The Code from GIT') {
      steps {
        git 'https://github.com/mohammedabidali/calculator_rest_api_terraform_ansible'
      }
    }

    stage('Build-Image') {
      steps {
        script {
          DOCKER_IMAGE = docker.build REGISTRY
        }
      }
    }
  }

}
