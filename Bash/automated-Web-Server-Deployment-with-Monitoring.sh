#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Nginx and dependencies. This can also be done with Apache, but Nginx is more common for static sites.
echo "Installing Nginx and monitoring tools..."
sudo apt-get install -y nginx curl wget htop iotop nmon

# Allow HTTP/HTTPS traffic through firewall
echo "Configuring firewall for HTTP and HTTPS..."
sudo ufw allow 'Nginx Full'

# Start and enable Nginx service
echo "Starting Nginx..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Check Nginx service status
echo "Checking Nginx status..."
sudo systemctl status nginx

# Create a basic static HTML webpage
echo "Creating a basic static webpage..."
sudo mkdir -p /var/www/html
echo "<html><head><title>Welcome to My Web Server</title></head><body><h1>Hello, this is a static webpage hosted on Nginx!</h1></body></html>" | sudo tee /var/www/html/index.html

# Set correct permissions for Nginx to access the files
echo "Setting file permissions..."
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Configure Nginx to serve the static webpage
echo "Configuring Nginx to serve the static webpage..."
sudo cat <<EOF | sudo tee /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# Test Nginx configuration
echo "Testing Nginx configuration..."
sudo nginx -t

# Reload Nginx to apply the new configuration
echo "Reloading Nginx..."
sudo systemctl reload nginx

# Install monitoring tools
echo "Installing monitoring tools (htop, iotop, nmon)..."
sudo apt-get install -y htop iotop nmon

# Setup basic monitoring script
echo "Creating system monitoring script..."
cat <<EOF | sudo tee /usr/local/bin/system_monitor.sh
#!/bin/bash

echo "System Monitor - CPU, Memory, Disk Usage"

# Display disk usage
echo "Disk Usage:"
df -h

# Display CPU and Memory usage
echo "CPU and Memory Usage:"
top -n 1 | grep "Cpu(s)"
free -h

# Display Nginx server uptime
echo "Nginx Server Uptime:"
systemctl status nginx | grep "Active"

EOF

# Make the monitoring script executable
sudo chmod +x /usr/local/bin/system_monitor.sh

# Display completion message
echo "Nginx web server and monitoring setup is complete!"
echo "You can now access your web server by navigating to the server's IP address in a browser."

# Set up cron job for periodic monitoring
echo "Setting up a cron job for periodic monitoring..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/system_monitor.sh") | crontab -

echo "Cron job set up successfully! System monitoring will now run every 5 minutes."