#Check running containers
docker ps

# Check logs
docker-compose logs todo-api
docker-compose logs todo-frontend
#
# # Check container health
docker inspect todo-api | findstr Health
