FROM grafana/grafana-oss:main-ubuntu

ENV GF_INSTALL_PLUGINS=grafana-cloudwatch-datasource
ENV GF_METRICS_ENABLED=true
# Sensitive ENV values should be passed at runtime via environment variables

COPY provisioning/datasources /etc/grafana/provisioning/datasources
COPY provisioning/dashboards /etc/grafana/provisioning/dashboards
COPY dashboards /var/lib/grafana/dashboards

EXPOSE 3000
