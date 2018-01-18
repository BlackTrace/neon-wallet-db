FROM python:3.5

RUN apt-get update && apt-get install -y \
   git-core \
   git \
   mongodb \
   redis-server \
   python3-venv

RUN wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh

RUN cd /opt/ && git clone https://github.com/ixje/neon-wallet-db.git
WORKDIR /opt/neon-wallet-db

RUN pip install -r requirements.txt

CMD /etc/init.d/mongodb start && \
    /etc/init.d/redis-server start && \
    export $(cat .env | grep -v ^# | xargs) && \
    echo "PRIVNET_SEEDS = ['http://$NEOIP:30333','http://$NEOIP:30334','http://$NEOIP:30335','http://$NEOIP:30336']" >> api/util.py && \
    python init.py && \
    heroku local

