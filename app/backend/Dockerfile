FROM python:3.11-slim
WORKDIR /app
RUN addgroup --system app && adduser --system --group app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
USER app
EXPOSE 5000
CMD ["python", "run.py"]
