FROM grafana/grafana-oss:10.2.3-alpine

ENV GF_INSTALL_PLUGINS=grafana-cloudwatch-datasource
ENV GF_METRICS_ENABLED=true
# Removed the potentially sensitive ENV to pass at runtime instead

COPY provisioning/datasources /etc/grafana/provisioning/datasources
COPY provisioning/dashboards /etc/grafana/provisioning/dashboards
COPY dashboards /var/lib/grafana/dashboards

EXPOSE 3000
