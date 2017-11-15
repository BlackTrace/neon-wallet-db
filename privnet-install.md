
These instructions assume you start from a working [neo-private-docker](https://github.com/CityOfZion/neo-privatenet-docker)

```
./docker_run
docker exec -it neo-privnet /bin/bash
```

in your docker image terminal install the required packages
```
apt-get update
apt-get -y install nano mongodb redis-server python3-venv git

wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh
```

enable rpc

```nano /opt/start_cli.sh```

change
```spawn dotnet neo-cli.dll```
to
```spawn dotnet neo-cli.dll /rpc```

save & exit (ctrl+o, ctrl+x)

put initial data in mongodb
```
/etc/init.d/mongodb start
mongo
db.meta.insert({"name":"lastTrustedBlock", "value":NumberInt(0)})
exit
````

install `neon-wallet-db`
```
cd /home/
git clone https://github.com/ixje/neon-wallet-db.git
cd neon-wallet-db
python3 -m venv venv
source venv/bin/activate
pip install wheel
pip install -r requirements.txt
```

back in your regular terminal
save the new image so you don't have to re-install everything
```
docker commit neo-privnet neo-privnet-rpc
docker stop neo-privnet
docker run -d --name neo-privnet-rpc -p 20333-20336:20333-20336/tcp -p 30333-30336:30333-30336 -h neo-privnet-rpc neo-privnet-rpc
```

login to your new image
```
docker exec -it neo-privnet-rpc /bin/bash
/etc/init.d/mongodb start
/etc/init.d/redis-server start
cd /home/neon-wallet-db
source venv/bin/activate
```

#start 
```
heroku local
```

first boot you'll see some errors like below, keep it running and ignore them for about 1 minute.

> 11:51:32 worker.1   |    File "/home/neon-wallet-db/api/blockchain.py", line 51, in get_highest_node
> 11:51:32 worker.1   |      nodes_data = blockchain_db['meta'].find_one({"name":"node_status"})["nodes"]
> 11:51:32 worker.1   |  TypeError: 'NoneType' object is not subscriptable


after that you'll see the something like the following and you're good to go
> 11:52:25 worker.1   |  11:52:25 default: Job OK (e87cd5d4-fc5c-4dd3-9710-aab7fc3a12bb)
> 11:52:25 worker.1   |  11:52:25 Result is kept for 500 seconds

you can now confirm it's working
```
root@69f0fde7af50:/# curl http://127.0.0.1:5000/v2/network/nodes
{
  "net": "private",
  "nodes": [
    {
      "block_height": 70,
      "status": true,
      "time": 0.013408660888671875,
      "url": "http://127.0.0.1:30333"
    },
    {
      "block_height": 70,
      "status": true,
      "time": 0.008440256118774414,
      "url": "http://127.0.0.1:30334"
    },
    {
      "block_height": 70,
      "status": true,
      "time": 0.02714824676513672,
      "url": "http://127.0.0.1:30335"
    },
    {
      "block_height": 70,
      "status": true,
      "time": 0.007632017135620117,
      "url": "http://127.0.0.1:30336"
    }
  ]
}
```

### Note1:
Don't forget to forward port 5000 on the docker image if you want to access `neon-wallet-db` outside of the docker image

### Note2:
When trying to run this on a VPS you'll have to reconsider how to expose the nodes. By default they'll point to http://127.0.0.1:[30333-30336] when accessing the `/v2/network/nodes` and `/v2/network/best_node` endpoints.