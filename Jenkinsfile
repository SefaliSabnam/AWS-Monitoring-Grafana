pipeline {
  agent any

  environment {
    IMAGE_NAME = "sefali26/grafana-ec2"
    INSTANCE_NAME = "DOCKER WITH GRAFANA"
    REGION = "ap-south-1"
    DOCKER_HUB_CREDENTIALS = 'DOCKER_HUB_TOKEN'
    EC2_SSH_KEY = 'ec2-ssh-key'  // SSH Username with Private Key
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
        bat "docker build -t %IMAGE_NAME% ."
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat '''
            echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
            docker push %IMAGE_NAME%
          '''
        }
      }
    }

    stage('Deploy to EC2') {
      when {
        branch 'main'
      }
      steps {
        withCredentials([sshUserPrivateKey(credentialsId: "${EC2_SSH_KEY}", keyFileVariable: 'KEY_FILE', usernameVariable: 'EC2_USER')]) {
          script {
            def ec2_ip = bat(
              script: """
                aws ec2 describe-instances ^
                  --region ${env.REGION} ^
                  --filters "Name=tag:Name,Values=${env.INSTANCE_NAME}" "Name=instance-state-name,Values=running" ^
                  --query "Reservations[*].Instances[*].PublicIpAddress" ^
                  --output text
              """,
              returnStdout: true
            ).trim()

            if (!ec2_ip) {
              error("No running EC2 instance found with name '${INSTANCE_NAME}' in region '${REGION}'")
            }

            // Run remote commands using Git Bash or WSL
            bat """
              bash -c "chmod 400 $KEY_FILE && ssh -o StrictHostKeyChecking=no -i $KEY_FILE $EC2_USER@${ec2_ip} \\
              'docker pull ${IMAGE_NAME} && docker stop grafana || true && docker rm grafana || true && docker run -d --name grafana -p 3000:3000 ${IMAGE_NAME}'"
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo ' Grafana deployed successfully. You can access it via the EC2 public IP.'
    }
    failure {
      echo ' Deployment failed. Check Jenkins logs for details.'
    }
  }
}
