# RideForce Zuul Service

When using RideShare with a local database with over 20 users in the User table:

If an issue occurs with Gateway Service when trying to View All Users as Admin
or when using the endpoint <http://localhost:2222/users>
it may say in the console log of the rideforce-gateway-service: 

```
Caused by: java.net.SocketTimeoutException: Read timed out
```

If so, include this

```yaml
user-service:
  ribbon:
    NIWSServerListClassName: com.netflix.loadbalancer.ConfigurationBasedServerList
    listOfServers: http://localhost:5555
    ConnectTimeout: 1000
    ReadTimeout: 30000		# Increased time out to handle requests that may take too long
    MaxTotalHttpConnections: 500
    MaxConnectionsPerHost: 100
```

> Note: make sure to remove the above lines from Zuul when merging to dev branch!

> Also: you can ignore the, unknown property 'matching-service' warnings in the application.yml file