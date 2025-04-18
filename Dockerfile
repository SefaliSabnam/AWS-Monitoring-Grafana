FROM grafana/grafana-oss:10.2.3

# Optional: enable metrics
ENV GF_METRICS_ENABLED=true

# Provisioning files
COPY provisioning/datasources /etc/grafana/provisioning/datasources
COPY provisioning/dashboards /etc/grafana/provisioning/dashboards
#Expose port 3000 for accessing Grafana web interface
EXPOSE 3000
