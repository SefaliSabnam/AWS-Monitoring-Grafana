# EC2 Monitoring with Custom Dockerized Grafana Deployed via Jenkins

##  Project Requirement

A containerized monitoring application must be deployed on the virtual machine to visualize key metrics such as CPU utilization, memory usage, and disk activity. The container image should be pulled and run directly on the instance. The deployment process must be automated, with only minimal manual configuration required for customizing the monitoring dashboard. The solution should enable easy access to the metrics data sourced from the cloud monitoring service and support consistent, repeatable deployments.

---

##  Project Overview

This project demonstrates the deployment of Grafana on an EC2 instance using a Docker container. Grafana is configured to pull real-time metrics (like CPU utilization) from AWS CloudWatch for monitoring the EC2 instance itself. The objective is to visualize EC2 health and performance metrics in a user-friendly dashboard.

---

##  Prerequisites

### Software Requirements

| Software     | Version         | Purpose                            |
|--------------|------------------|------------------------------------|
| Amazon EC2   | t2.micro or higher | Host for Docker & Grafana          |
| Docker       | Latest            | Container runtime for Grafana      |
| Grafana      | OSS 10.2.3        | Dashboard and monitoring            |
| AWS CLI      | Latest            | IAM & CloudWatch setup             |
| Jenkins      | Latest            | CI/CD Pipeline                     |

---

##  Project Architecture

> _A monitoring solution with CI/CD pipeline automates the deployment of a Docker-based Grafana container on EC2, visualizing CloudWatch metrics._
![Architecture Diagram](docker%20with%20grafana.drawio.png)


---

##  Project Artifacts

- `Dockerfile` – Custom build with plugin & provisioning
- `/provisioning/datasources` – Data source config for CloudWatch
- `/provisioning/dashboards` – JSON dashboard(s)
- `Jenkinsfile` – CI/CD pipeline for:
  - Pulling repo
  - Building & pushing Docker image
  - Deploying Grafana container to EC2
- `grafana.ini` or environment variables – Plugin settings

---

##  Account Requirements

- **AWS IAM Role/User** with the following policies:
  - `AmazonEC2FullAccess`
  - `CloudWatchReadOnlyAccess`
  - `AmazonGrafanaCloudWatchAccess`

- **Docker Hub credentials** for pushing the Docker image

- **Jenkins Credentials**:
  - SSH key for EC2 (`ec2-ssh-key`)
  - AWS credentials (`AWS-DOCKER-CREDENTIALS`)
  - Docker Hub token (`DOCKER_HUB_TOKEN`)
  - `AmazonEC2FullAccess` (only during deployment)

---

##  Access Permissions

The EC2 instance should have either:
- An attached IAM role with the required policies
- Or AWS credentials securely configured if roles are not used

---

##  Procedure

### 1. Docker Setup
- Dockerfile installs the `grafana-cloudwatch-datasource` plugin
- Provisioning files (`datasources/` and `dashboards/`) are copied to Grafana's config path
- Image is tagged as `sefali26/grafana-ec2`

### 2. Jenkins Pipeline Execution
Jenkins stages:
- Clean Workspace
- Checkout Code
- Build Docker Image
- Push Image to Docker Hub
- Deploy to EC2 _(on main branch only)_

### 3. EC2 Deployment
- Jenkins connects to the EC2 instance
- Stops and removes any existing Grafana container
- Runs the new container exposing port `3000`

### 4. Grafana Dashboard Configuration (Manual)
- Open `http://<EC2_PUBLIC_IP>:3000`
- Add CloudWatch as a data source (already provisioned)
- Create a new dashboard panel with:
  - **Namespace**: `AWS/EC2`
  - **Metric Name**: `CPUUtilization`
  - **Dimension**: `InstanceId = i-xxxxxxxxxxxx`
  - **Statistic**: `Average`
  - **Period**: `1m`

---

##  Output

- Grafana dashboard running successfully on EC2
- Real-time visualization of EC2 metrics like `CPUUtilization`
![Dashboard Result 1](result.jpg)  

![Dashboard Result 2](resultt.jpg)
- Metrics fetched securely from CloudWatch using IAM access

---

##  Conclusion

This project demonstrates a CI/CD pipeline that builds and deploys a Dockerized Grafana instance to an AWS EC2 server and integrates CloudWatch to monitor EC2 metrics. It provides a scalable, repeatable, and efficient infrastructure monitoring setup with minimal manual effort.

---

