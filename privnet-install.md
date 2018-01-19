
These instructions assume you start from a working [neo-private-docker](https://github.com/CityOfZion/neo-privatenet-docker)

```
./docker_run
docker exec -it neo-privnet /bin/bash
```

Now let's set up NeonDB. First we need to copy the sample private network config
```
cp .env-privnet-local .env
```

Build and start up the container
```
docker-compose build && docker-compose up
```

We need to add a network and make it so the neo-privnet and neon-wallet-db containers can communicate
```
docker network create privnet
docker network connect privnet neo-privnet
docker network connect privnet neon-wallet-db
```

Wait a few seconds for it to connect to the nodes now that it can.

You can now confirm it's working
```
root@69f0fde7af50:/# curl http://127.0.0.1:5000/v2/network/nodes
{
  "net": "private",
  "nodes": [
    {
      "block_height": 70,
      "status": true,
      "time": 0.013408660888671875,
      "url": "http://neo-privnet:30333"
    },
    {
      "block_height": 70,
      "status": true,
      "time": 0.008440256118774414,
      "url": "http:/neo-privnet:30334"
    },
    {
      "block_height": 70,
      "status": true,
      "time": 0.02714824676513672,
      "url": "http://neo-privnet:30335"
    },
    {
      "block_height": 70,
      "status": true,
      "time": 0.007632017135620117,
      "url": "http://neo-privnet:30336"
    }
  ]
}
```

### Note1:
If you have a client connecting to NeonDB and then using the seeds directly, with hostname `neo-privnet`, you'll may need to add a line to your hosts file.

### Note2:
When trying to run this on a VPS you'll have to reconsider how to expose the nodes. By default they'll point to http://127.0.0.1:[30333-30336] when accessing the `/v2/network/nodes` and `/v2/network/best_node` endpoints.
