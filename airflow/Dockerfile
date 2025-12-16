FROM apache/airflow:2.7.3-python3.11

USER root

# Install ODBC driver for SQL Server connections
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        unixodbc \
        unixodbc-dev \
        curl \
        gnupg2 \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow

# Install Azure providers (NOT docker provider)
RUN pip install --no-cache-dir \
    apache-airflow-providers-microsoft-azure==10.0.0 \
    azure-identity==1.15.0 \
    azure-mgmt-containerinstance==10.1.0

# Copy DAGs and plugins (baked into image)
COPY --chown=airflow:root dags/ /opt/airflow/dags/
COPY --chown=airflow:root plugins/ /opt/airflow/plugins/

CMD ["airflow", "webserver"]
