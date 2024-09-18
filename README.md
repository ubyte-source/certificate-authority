
# Docker Container for Secure Nginx and Certificate Management

This Docker setup uses Alpine Linux with Nginx, fcgiwrap, and OpenSSL to provide a secure web server that also manages SSL certificate generation.

## Features

- **Automated Certificate Management:** Generates and renews SSL certificates automatically.
- **Nginx Web Server:** Configured to handle both standard and secure ports.
- **Security Enhancements:** Runs under a non-root user and employs secure directories for storing certificates.
- **Integrated Health Checks:** Ensures the web server is always operational.

## Prerequisites

- Docker must be installed on your machine.
- Basic knowledge of Docker commands and principles.
- DNS must be configured to point to the host that is running Docker to allow certificate generation by accessing `https://<^[a-z0-9-]{8,}$>.domain.lan/generate`.

## Getting Started

### 1. Build the Docker Image

Navigate to the directory containing the Dockerfile and execute:

```bash
docker build .
```

### 2. Prepare the Environment File

Create an environment file `env.list` with the following content:

| Key               | Value                          | Description                                      |
|-------------------|--------------------------------|--------------------------------------------------|
| CA                | mydomain.local                 | Main domain of the Certification Authority       |
| CA_PASSWORD       | my4L86FztQHZsfc9gLbDHj         | Password for accessing the Certification Authority |
| RSA_KEY_SIZE      | 2048                           | Size of the RSA key in bits                      |
| DOMAIN            | mydomain.local                 | Domain for which the certificate will be generated |
| EXPIRE            | 30                             | Validity of the certificate in days              |
| COUNTRY           | IT                             | ISO country code                                 |
| STATE             | Veneto                         | State or province                                |
| LOCALITY          | Vicenza                        | Locality                                         |
| ORGANIZATION      | uByte                          | Name of the organization                         |
| ORGANIZATION_UNIT | Network                        | Organizational unit                              |
| SAN               | DNS:*.mydomain.local,DNS:mydomain.local | Subject Alternative Name for the certificate     |


### 3. Run the Container with the Environment File

To start the container using the environment file, use:

```bash
docker run -dit --name cartificate-authority -p 80:8080 -p 443:8443 --env-file env.list ubyte/cartificate-authority
```

This will run the container in detached mode, map the necessary ports, and load configurations from the `env.list` file.

### 4. Verify Installation

Check the health of the container with:

```bash
docker inspect --format='{{json .State.Health}}' cartificate-authority
```

## Usage

### Accessing the Web Server

You can access the server by navigating to `http://localhost` or `https://localhost` in your web browser. This will direct you to the main page hosted on your local web server.

### Generating a New Certificate

To generate a new certificate, you need to simulate a domain name within your local network. Here are the steps to follow:

1. **Modify your hosts file:**
   - On Windows, this file is located at `C:\Windows\System32\drivers\etc\hosts`.
   - On macOS and Linux, it is located at `/etc/hosts`.
   - Add the following line to this file:
     ```
     127.0.0.1    abcdefgh.mydomain.local
     ```
   Replace `abcdefgh` with any 8 characters of your choice. This step makes your computer think that `abcdefgh.mydomain.local` is hosted on your local machine.

2. **Access the domain:**
   - Open your web browser and navigate to `http://abcdefgh.mydomain.local/generate`.
   - This URL points to the local instance of your web server configured to respond with a newly generated certificate for the domain specified.

By following these steps, the request to the domain will be routed to your local web server, which can then handle it correctly based on the Host header to generate a domain-specific certificate.

## Security

- The server runs as a non-root user.
- Directories containing sensitive information have restricted access permissions.

Refer to the [Docker security documentation](https://docs.docker.com/engine/security/) for more detailed information about security configurations.

## Troubleshooting

Start by checking the Docker logs to identify any issues:

```bash
docker logs certificate-authority
```

Look for any errors in the logs and follow the suggestions provided by the wrapper script or Nginx.

For a robust management of operational log generation, logs are saved in `/var/log/generation.log`. To read this file, you can use the following command:

```bash
docker exec certificate-authority cat /var/log/generation.log
```

## Built With

* [Docker](https://www.docker.com/) - Get Started with Docker
* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [OpenSSL](https://www.openssl.org/) - OpenSSL
* [cURL](https://curl.se/) - cURL

## Versioning

We use [SemVer](https://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/ubyte-source/certificate-authority/tags). 

## Authors

* **Paolo Fabris** - *Initial work* - [ubyte.it](https://ubyte.it/)

See also the list of [contributors](https://github.com/ubyte-source/certificate-authority/blob/main/CONTRIBUTORS.md) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
