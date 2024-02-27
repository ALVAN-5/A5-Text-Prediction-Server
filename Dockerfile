FROM python:3.12
COPY . /app
WORKDIR /app
RUN pip install --upgrade pip --no-cache-dir
RUN pip install -r requirements.txt
ARG A5TPS_ENV=DEV
ARG A5TPS_ALLOWED_IPS_URL=https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/text-prediction-server-allowed-ips.json
ARG A5TPS_INTENTS_URL=https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/intents.json
ARG A5TPS_HOST_IP=127.0.0.1
ARG A5TPS_HOST_PORT=80
WORKDIR /app/src
CMD ["python", "main.py"]

