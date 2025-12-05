FROM python:3.11-slim

WORKDIR /dbt

ARG DB_SERVER
ARG DB_SCHEMA
ARG DB_USER
ARG DBT_PASSWORD

ENV DB_SERVER=${DB_SERVER}
ENV DB_SCHEMA=${DB_SCHEMA}
ENV DB_USER=${DB_USER}
ENV DBT_PASSWORD=${DBT_PASSWORD}


USER root

# Install ODBC driver for SQL Server
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg2 \
        unixodbc \
        unixodbc-dev \
        git \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/ms.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/msprod.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install dbt
RUN pip install --no-cache-dir \
    dbt-core==1.8.7 \
    dbt-sqlserver==1.8.7

# Copy DBT project
COPY . /dbt/

ENV DBT_PROFILES_DIR=/dbt

# Run dbt deps if packages.yml exists
RUN dbt deps || true

CMD ["dbt", "run"]