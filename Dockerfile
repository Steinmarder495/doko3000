# Builder stage
# Pin to Python 3.14.1 and install uv so the venv interpreter matches runtime.
FROM python:3.14.1-alpine AS builder

# Install build dependencies
RUN apk update && apk add --no-cache \
    gcc \
    g++ \
    git \
    libc-dev

# Install uv (Python package manager)
RUN python -m pip install --no-cache-dir uv

# Set working directory
WORKDIR /doko3000

# Copy dependency files first (for better layer caching)
# Include README.md since it's referenced in pyproject.toml
COPY pyproject.toml uv.lock README.md ./

# Install dependencies only (without the package itself)
RUN uv sync --frozen --no-dev --no-install-project

# Copy source code (needed to install the package)
COPY . .

# Now install the package itself
RUN uv sync --frozen --no-dev

# Generate git info
RUN git log --max-count 1 --decorate=short | head -n 1 > git_info

# Remove .git to save space in final image
RUN rm -rf .git

# Final stage
# Pin to Python 3.14.1 so the runtime matches the builder's interpreter.
FROM python:3.14.1-alpine

LABEL maintainer=henri.wahl@mailbox.org

RUN apk update && apk add --no-cache \
    libgcc \
    libstdc++

WORKDIR /doko3000

# Copy virtual environment from builder
COPY --from=builder /doko3000/.venv /doko3000/.venv

# Add venv to PATH
ENV PATH="/doko3000/.venv/bin:$PATH"

# Copy application code
COPY --from=builder /doko3000 /doko3000

# Create unprivileged runtime user
RUN adduser -D doko3000

# Ensure .venv/bin files are executable by all users
RUN chmod -R +x /doko3000/.venv/bin || true

# Change ownership of /doko3000 to doko3000 user for proper permissions
RUN chown -R doko3000:doko3000 /doko3000

# Setup entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run as unprivileged user by default (least privilege)
USER doko3000

ENTRYPOINT ["/entrypoint.sh"]
