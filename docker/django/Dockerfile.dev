# Multi-stage build for smaller images
FROM python:3.11-slim as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY app/requirements/production.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r production.txt

# Final stage
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/app

WORKDIR $APP_HOME

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Copy wheels and install
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/production.txt .
RUN pip install --no-cache /wheels/*

# Copy application
COPY app/ $APP_HOME/
COPY docker/django/entrypoint.sh /entrypoint.sh
COPY docker/django/start.sh /start.sh

RUN chmod +x /entrypoint.sh /start.sh

# Create user
RUN groupadd -r django && useradd -r -g django django
RUN chown -R django:django $APP_HOME
USER django

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]