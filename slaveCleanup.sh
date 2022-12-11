#!/bin/bash
#This script should be located on each jenkins slave, and the jenkins user should have permission to run it with sudo

MOUNTPOINTS="/"
THRESHOLD1=3
THRESHOLD2=5

while true
do

CURRENT=$(df ${MOUNTPOINTS} | grep / | awk '{ print $5 }' | sed 's/%//g')

        if [ "${CURRENT}" gt "${THRESHOLD1}" ] ; then

                docker system prune -a --filter "until=1h" --force

                critical=$(("$THRESHOLD2" > "$CURRENT"))

                if [[ $critical == 1 ]]; then

                        #### Attemps to cleanly stop and remove all container, volume and images

                        docker ps -q | xargs --no-run-if-empty docker stop
                        docker ps -q -a | xargs --no-run-if-empty docker rm --force --volumes
                        docker volume ls -q | xargs --no-run-if-empty docker volume rm
                        docker images -a -q | xargs --no-run-if-empty docker rmi -filter

                        #### Stop the docker service, unmounts all docker-related mounts, removes the entrie docker directory, and start docker again.

                        systemctl stop docker
                        echo "Deleting content of /jenkinsmasters/docker"
                        rm -rf /jenkinsmasters/docker/*
                        systemctl start docker

                        else

                        result=$( docker ps -q )

                        if [[ -n "$result" ]] ; then

                            sleep 10

                            else

                            #### Attemps to cleanly stop and remove all container, volume and images

                            docker ps -q | xargs --no-run-if-empty docker stop
                            docker ps -q -a | xargs --no-run-if-empty docker rm --force --volumes
                            docker volume ls -q | xargs --no-run-if-empty docker volume rm
                            docker images -a -q | xargs --no-run-if-empty docker rmi -filter

                            #### Stop the docker service, unmounts all docker-related mounts, removes the entrie docker directory, and start docker again.

                            systemctl stop docker
                            echo "Deleting content of /jenkinsmasters/docker"
                            rm -rf /jenkinsmasters/docker/*
                            systemctl start docker

                        fi
                
                sleep 10

                fi

            sleep 10

        fi

    sleep 1

done