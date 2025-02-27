#!/bin/bash

# Prompt user for email
read -p "Enter your email address (for Certbot notifications): " user_email

# Prompt user for domains
read -p "Enter the number of domains: " n
domains=()
for ((i=1; i<=n; i++)); do
    read -p "Enter domain $i: " domain
    domains+=("$domain")
done

# Prompt user for the proxy port
read -p "Enter the local port Nginx should proxy to (default: 8080): " proxy_port
proxy_port=${proxy_port:-8080}

# Get the current username
username=$(whoami)

# Change folder to the user's home directory
cd /home/$username

# Update and install dependencies
sudo apt-get update -y
sudo apt-get install apt-utils ufw certbot python3-certbot-nginx -y
sudo apt-get upgrade -y

# Test and reload Nginx
sudo nginx -t
sudo systemctl reload nginx

# Prepare Certbot domain arguments
certbot_domains=""
nginx_server_name=""
for domain in "${domains[@]}"; do
    certbot_domains="$certbot_domains -d $domain"
    nginx_server_name="$nginx_server_name $domain"
done

# Obtain SSL certificates
sudo certbot --nginx $certbot_domains --non-interactive --agree-tos --email $user_email

# Test and dry-run renew
sudo certbot renew --dry-run

# Create/rewrite /etc/nginx/sites-available/default
nginx_config="/etc/nginx/sites-available/default"
sudo bash -c "cat > $nginx_config" <<EOL
server {
    $(for domain in "${domains[@]}"; do
        echo "if (\$host = $domain) {"
        echo "    return 301 https://\$host\$request_uri;"
        echo "} # managed by Certbot"
        echo
    done)

    listen 80;
    server_name$nginx_server_name;
    # Redirect all HTTP traffic to HTTPS
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name$nginx_server_name;

    ssl_certificate /etc/letsencrypt/live/${domains[0]}/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/${domains[0]}/privkey.pem; # managed by Certbot

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Proxy all requests to localhost:$proxy_port
    location / {
        proxy_pass http://127.0.0.1:$proxy_port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Reload Nginx
sudo nginx -t
sudo systemctl reload nginx

# Configure UFW
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
echo "y" | sudo ufw enable

echo "Setup complete for domains: ${domains[*]}"
