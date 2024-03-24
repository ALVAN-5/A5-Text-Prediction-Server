FROM python:3.12
COPY . /app
WORKDIR /app
RUN pip install --upgrade pip --no-cache-dir
RUN pip install -r requirements.txt
RUN python install_nltk.py
ARG A5TPS_ENV
ENV A5TPS_ENV=${A5TPS_ENV}
ARG A5TPS_ALLOWED_IPS_URL=https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/text-prediction-server-allowed-ips.json
ENV A5TPS_ALLOWED_IPS_URL=${A5TPS_ALLOWED_IPS_URL}
ARG A5TPS_INTENTS_URL=https://raw.githubusercontent.com/ALVAN-5/A5-Static-Content/master/backend/intents.json
ENV A5TPS_INTENTS_URL=${A5TPS_INTENTS_URL}
ARG A5TPS_HOST_IP
ENV A5TPS_HOST_IP=${A5TPS_HOST_IP}
ARG A5TPS_HOST_PORT
ENV A5TPS_HOST_PORT=${A5TPS_HOST_PORT}
WORKDIR /app/src

CMD ["python", "main.py"]

# Put 192.168.2.69 in the ip override list the run the following:
# docker network create --subnet 192.168.2.0/24 al-net # This only has to be run once
# docker build -t a5-text-prediction-server:0.0.0.SNAPSHOT . --build-arg A5TPS_ENV=PROD --build-arg A5TPS_HOST_IP="0.0.0.0" --build-arg A5TPS_HOST_PORT=80
# docker run --network=al-net --ip 192.168.2.2 -p 80:80 -p 5000:5000 a5-text-prediction-server:0.0.0.SNAPSHOT

# Testing Container
# docker run -ti --network=al-net --ip 192.168.2.69 --rm ubuntu:20.04 /bin/bash
# Then in the container run: apt update && apt install lsb-core