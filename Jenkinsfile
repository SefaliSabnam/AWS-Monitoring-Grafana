pipeline {
  agent any

  environment {
    IMAGE_NAME = "sefali26/grafana-ec2"
    INSTANCE_NAME = "DOCKER WITH GRAFANA"
    REGION = "ap-south-1"
    DOCKER_HUB_CREDENTIALS = 'DOCKER_HUB_TOKEN'
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
          sh '''
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push $IMAGE_NAME
          '''
        }
      }
    }

    stage('Deploy to EC2') {
      when {
        branch 'main'
      }
      steps {
        sshagent([SSH_KEY]) {
          script {
            def ec2_ip = sh(
              script: '''
                aws ec2 describe-instances \
                  --region ${REGION} \
                  --filters "Name=tag:Name,Values=${INSTANCE_NAME}" "Name=instance-state-name,Values=running" \
                  --query "Reservations[*].Instances[*].PublicIpAddress" \
                  --output text
              ''',
              returnStdout: true
            ).trim()

            if (ec2_ip == "") {
              error("No running EC2 instance found with name '${INSTANCE_NAME}' in region '${REGION}'")
            }

            sh """
              ssh -o StrictHostKeyChecking=no ec2-user@${ec2_ip} << EOF
                docker pull $IMAGE_NAME
                docker stop grafana || true
                docker rm grafana || true
                docker run -d --name grafana -p 3000:3000 \\
                  -e AWS_REGION=$REGION \\
                  $IMAGE_NAME
              EOF
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo 'Grafana deployed and EC2 metrics should be visible.'
    }
    failure {
      echo 'Deployment failed.'
    }
  }
}
