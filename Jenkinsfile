pipeline {
  agent any

  environment {
    IMAGE_NAME = "sefali26/grafana-ec2"
    EC2_HOST = "ec2-user@<EC2_PUBLIC_IP>" // EC2 IP not revealed
    DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
    SSH_KEY = 'ec2-ssh-key'
  }

  options {
    skipStagesAfterUnstable()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $IMAGE_NAME .'
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
          sh """
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME
          """
        }
      }
    }

    stage('Deploy to EC2') {
      when {
        branch 'main'
      }
      steps {
        sshagent([SSH_KEY]) {
          sh """
            ssh -o StrictHostKeyChecking=no $EC2_HOST << EOF
              docker pull $IMAGE_NAME
              docker stop grafana || true
              docker rm grafana || true
              docker run -d --name grafana -p 3000:3000 \\
                -e AWS_REGION=ap-south-1 \\
                $IMAGE_NAME
            EOF
          """
        }
      }
    }
  }

  post {
    success {
      echo ' Grafana deployed and EC2 metrics should be visible.'
    }
    failure {
      echo ' Deployment failed.'
    }
  }
}
