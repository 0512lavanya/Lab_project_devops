# ---- Stage 1: Build dependencies ----
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ---- Stage 2: Production image ----
FROM python:3.11-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy installed packages
COPY --from=builder /install /usr/local

# Copy project files
COPY . .

# Environment variables
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 5000

# Run app using gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "run:app"]