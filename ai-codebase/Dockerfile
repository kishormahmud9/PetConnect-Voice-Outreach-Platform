# ─────────────────────────────────────────────────────────────────────────────
# Stage 1 — Builder
# Install Python dependencies into a virtual environment in isolation.
# ─────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build tools only in this stage
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only the dependency manifest first (layer-cache friendly)
COPY requirements.txt .

# Create a venv and install all deps into it
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt


# ─────────────────────────────────────────────────────────────────────────────
# Stage 2 — Runtime
# Minimal production image — no build tools, non-root user.
# ─────────────────────────────────────────────────────────────────────────────
FROM python:3.11-slim AS runtime

# Security: run as a non-root user
RUN groupadd --gid 1001 vetpay && \
    useradd --uid 1001 --gid vetpay --shell /bin/bash --create-home vetpay

WORKDIR /app

# Copy the venv from the builder stage
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application source
COPY --chown=vetpay:vetpay . .

# Create required runtime directories and set ownership
RUN mkdir -p audio output_results && \
    chown -R vetpay:vetpay /app

# Copy and prepare the entrypoint script
COPY --chown=vetpay:vetpay docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Expose the application port
EXPOSE 8000

# Switch to the non-root user
USER vetpay

# Health check — verifies the login page loads (no auth required)
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/login')" || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
