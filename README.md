flightmare edit

To set up Docker container for ROS+Flightros Packages Install:

1. Change mounts in docker-compose.yml file to link flightsim install path to home folder in container (/path/to/flightsim:/home/user/fm/flightmare)

2. To build ros_flightsim Docker image

```
cd /path_of_dockerfile
docker build -t ros_flightsim:0.6 . #builds image named as ros_flightsim:0.6
docker-compose up #creates docker compose

#in separate terminal
docker exec -it ros_fm bash  #creates iteractive container for ros_fm

docker stop ros_fm #stops container
docker restart ros_fm #restarts container
docker-compose down #closes docker containers
```
