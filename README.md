# Basic Server Installation

This script automates the setup of a web server with Nginx and Let's Encrypt SSL certificates on a clean Ubuntu Linux server. It handles the configuration of multiple domains and sets up a secure reverse proxy environment.

## Prerequisites

Before running this script, ensure you have:

1. A domain with DNS configured:
   - Create an **A record** in your DNS zone to point your server's name and the internal service(s) you want to access to your server's public IP address.

   For example:
   - Server: `server.yourdomain.com`
   - Subdomain for your service: `service.yourdomain.com`

2. Access to a Linux server with sudo privileges.

## Steps for Configuration

### 1. Log in as root and create a new user for administration

Run the following commands to create a user:

```bash
ssh root@server.yourdomain.com
adduser yourusername
usermod -aG sudo yourusername
exit
```

### 2. Log in as the new user

Log in as the newly created user:

```bash
ssh yourusername@server.yourdomain.com
```

### 3. Download and execute the setup script

Install git and clone this repository:

```bash
# Install git if not already installed
sudo apt install git -y

# Clone the repository
git clone https://github.com/jpfranca-br/basic-server-installation.git
cd basic-server-installation

# Make the script executable and run it
chmod +x server-setup.sh
./server-setup.sh
```

### 4. Enter the required data

The script will prompt you to enter the following information:

- **Email Address**: Used for Certbot notifications about SSL certificate renewals.
- **Number of Domains**: The number of domains you want to configure.
- **Domain Names**: Enter each domain name one by one.
- **Proxy Port**: The local port to which Nginx should proxy requests (default: 8080).

#### Example Inputs:

```text
Enter your email address (for Certbot notifications): youremail@example.com
Enter the number of domains: 2
Enter domain 1: server.yourdomain.com
Enter domain 2: service.yourdomain.com
Enter the local port Nginx should proxy to (default: 8080): 3000
```

### 5. Wait for the script to complete

The script will perform all necessary configurations and display the following message upon successful completion:

```text
Setup complete for domains: server.yourdomain.com service.yourdomain.com
```

## What the Script Does

1. **System Updates and Dependencies**: Installs required packages such as `certbot`, `nginx`, and `apt-utils`.
2. **SSL Configuration**: Obtains Let's Encrypt certificates for the specified domains.
3. **Nginx Configuration**: 
   - Configures Nginx to proxy traffic securely to your internal service on the specified port.
   - Sets up SSL with proper security parameters.
   - Redirects HTTP traffic to HTTPS.
4. **Firewall Setup**:
   - Configures UFW (Uncomplicated Firewall) to allow HTTP (80), HTTPS (443), and SSH (22) traffic.

## Troubleshooting

- **Domain Resolution Issues**: Ensure your DNS A records are correctly configured to point to the server's IP.
- **Port Accessibility**: Ensure your application is running on the port you specified for the proxy.
- **SSL Certificate Issues**: Check that your domains resolve correctly and Certbot can verify ownership.

## Customization

You can modify the script to fit your needs. Some potential customizations:
- Add additional Nginx configuration options
- Configure different SSL parameters
- Add more sophisticated firewall rules

## License

This project is licensed under the MIT License - see the LICENSE file for details.
