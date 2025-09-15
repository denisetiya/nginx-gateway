# Rate Limiting Configuration

This document explains how rate limiting is configured in the Nginx API Gateway.

## How It Works

Rate limiting in Nginx is implemented using the `limit_req_zone` and `limit_req` directives:

1. `limit_req_zone` defines a shared memory zone for storing request states
2. `limit_req` applies the rate limiting to specific locations

## Configuration Details

### Zone Definition

In [nginx.conf](./nginx.conf):
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
```

- `$binary_remote_addr`: Uses the client's IP address as the key
- `zone=api:10m`: Creates a 10MB shared memory zone named "api"
- `rate=10r/s`: Allows 10 requests per second per IP

### Rate Limit Application

In each service configuration ([service-template.conf](./conf.d/service-template.conf)):
```nginx
limit_req zone=api burst=20 nodelay;
limit_req_status 429;
```

- `zone=api`: Uses the "api" zone defined above
- `burst=20`: Allows up to 20 requests to queue when the rate limit is exceeded
- `nodelay`: Processes queued requests immediately when possible
- `limit_req_status 429`: Returns HTTP 429 (Too Many Requests) when rate limit is exceeded

## Memory Requirements

The memory required for the zone is calculated as:
```
Memory = Number of IPs × 64 bytes
```

A 10MB zone can handle approximately 160,000 unique IP addresses.

## Customization Options

### Different Rate Limits for Different Services

To set different rate limits for different services, create separate zones:

```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth:10m rate=1r/s;
```

Then apply them in specific service configurations:
```nginx
# Regular API requests
limit_req zone=api burst=20 nodelay;

# Authentication requests (stricter)
limit_req zone=auth burst=5 nodelay;
```

### Whitelisting IPs

To whitelist specific IPs from rate limiting:
```nginx
geo $limited_ip {
    default      1;
    127.0.0.1    0;
    10.0.0.0/8   0;
}

map $limited_ip $limited_ip_key {
    0 '';
    1 $binary_remote_addr;
}

limit_req_zone $limited_ip_key zone=api:10m rate=10r/s;
```

This configuration exempts localhost and private network IPs from rate limiting.

## Monitoring

To monitor rate limiting, check the Nginx logs:
```bash
docker-compose logs nginx | grep "limiting requests"
```

## Testing

To test rate limiting, you can use tools like `ab` (Apache Bench):
```bash
ab -n 100 -c 20 http://your-domain/api/endpoint
```

This sends 100 requests with 20 concurrent connections, which should trigger rate limiting.