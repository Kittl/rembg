# Use the official Python slim image as a base image
FROM python:3.10-slim

# Set the working directory
WORKDIR /home/appuser

# Install pip and system dependencies in one layer to leverage caching
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# Copy only the requirements file to leverage Docker cache
COPY requirements.txt .

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Install the application
RUN pip install --no-cache-dir ".[cli]"

# Create a non-root user and group with specific IDs, and give permissions
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -m appuser && \
    chown -R appuser:appgroup /home/appuser

# Expose the port the app runs on
EXPOSE 7000

# Switch to the non-root user
USER 1001

# Define the entrypoint and default command
ENTRYPOINT ["rembg"]
CMD ["--help"]
