```markdown
# Grafana EC2 Monitoring with Jenkins Pipeline

##  Overview
This project builds and deploys a Grafana Docker image that auto-configures CloudWatch for visualizing EC2 metrics.

## Tech Stack
- Jenkins
- Docker
- Grafana
- AWS EC2
- CloudWatch

##  Steps

### 1. Jenkins Pipeline
- Deploys to EC2 only after merging to `main` branch
- Builds Docker image
- Pushes to DockerHub
- SSH into EC2
- Pulls and runs container

### 2. EC2 Setup
- Install Docker
- Assign IAM Role with CloudWatch read access

```bash
sudo apt update && sudo apt install -y docker.io
sudo usermod -aG docker $USER
```

### 3. Jenkins Credentials
- `dockerhub-credentials`: DockerHub username/password
- `ec2-ssh-key`: EC2 private SSH key
- Git credentials/token should be configured for access

### 4. Grafana Access
Visit `http://<EC2_IP>:3000`

Default login: `admin/admin`

### 5. Dashboards
Automatically loaded with EC2 metrics (customize instance ID in `ec2-dashboard.json`).

---

##  Outcome
- Automated deployment of Grafana
- EC2 metrics visualized
- CloudWatch preconfigured

---

##  Example Panel
- CPU Utilization
- NetworkIn / NetworkOut
- DiskReadBytes / DiskWriteBytes
```
