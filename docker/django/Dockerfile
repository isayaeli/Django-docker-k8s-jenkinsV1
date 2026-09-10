# Multi-stage build for smaller images
FROM python:3.11-slim as builder

WORKDIR /app

ENV PIP_DEFAULT_TIMEOUT=120 \
    PIP_RETRY=5

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements/prod.txt .
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r prod.txt

# Final stage
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    APP_HOME=/app \
    PIP_DEFAULT_TIMEOUT=120 \
    PIP_RETRY=5

WORKDIR $APP_HOME

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/*

# Copy wheels and install
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/prod.txt .
RUN python -m pip install --no-cache-dir --retries 5 --timeout 120 /wheels/*

# Copy application
COPY safarichap/ $APP_HOME/
COPY docker/django/entrypoint.sh /entrypoint.sh
COPY docker/django/start.sh /start.sh

RUN chmod +x /entrypoint.sh /start.sh

# Create user
RUN groupadd -r django && useradd -r -g django django
RUN chown -R django:django $APP_HOME
USER django

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]