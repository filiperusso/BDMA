FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y gcc python3-dev curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python packages
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]