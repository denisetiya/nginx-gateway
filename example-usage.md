# Example Usage

This is an example of how to use the Nginx API Gateway with your services.

## Sample docker-compose.yml

```yaml
version: '3.8'

services:
  # Your services
  user-service:
    image: my-user-service:latest
    ports:
      - "3000:3000"
  
  order-service:
    image: my-order-service:latest
    ports:
      - "3001:3000"
  
  product-service:
    image: my-product-service:latest
    ports:
      - "3002:3000"
  
  # API Gateway
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf.d:/etc/nginx/conf.d
      - ./ssl:/etc/nginx/ssl
      - ./logs:/var/log/nginx
      - ./www:/var/www
    depends_on:
      - user-service
      - order-service
      - product-service
      - certbot
    restart: unless-stopped

  certbot:
    image: certbot/certbot
    volumes:
      - ./ssl:/etc/nginx/ssl
      - ./www:/var/www
    command: certonly --webroot --webroot-path=/var/www --email admin@example.com --agree-tos --no-eff-email -d example.com
```

## Adding Services

1. **Using the script (Windows):**
   ```cmd
   add-service.bat user-service 3000 /api/users example.com
   add-service.bat order-service 3001 /api/orders example.com
   add-service.bat product-service 3002 /api/products example.com
   ```

2. **Manual configuration:**
   Copy the [service-template.conf](./conf.d/service-template.conf) file and modify it for each service:
   ```bash
   cp conf.d/service-template.conf conf.d/user-service.conf
   # Edit the file to replace placeholders
   ```

## Service Endpoints

After configuration, your services will be available at:
- User Service: `https://example.com/api/users/`
- Order Service: `https://example.com/api/orders/`
- Product Service: `https://example.com/api/products/`

## Rate Limiting

The default rate limit is 10 requests per second per IP address with a burst of 20 requests. You can adjust this in [nginx.conf](./nginx.conf):
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
```

## SSL Configuration

SSL certificates are automatically managed by Certbot. Make sure to:
1. Update the domain name in [docker-compose.yml](./docker-compose.yml)
2. Update the email address for certificate notifications
3. Ensure your domain points to your server's IP address

## Testing

To test your setup:
1. Start all services: `docker-compose up -d`
2. Add your service configurations
3. Restart Nginx: `docker-compose restart nginx`
4. Access your services through the gateway