nginx 1.10.2 and 1.11.6 on Ubuntu 16.04 and Debian Stretch will corrupt the
first 32 bytes of a POST request body exceeding 8192 bytes when proxying from
a HTTP/2 client and also using an auth_request.

Using HTTP/1.1 instead of HTTP/2 stops the corruption.

Removing the auth_request configuration also stops the corruption.

POST request bodies of exactly 8192 bytes or less are not corrupted.

HTTP/2 clients tested include nghttp2 1.16, Chrome 55 for Windows, and
Firefox 51.0 for Windows. The client-side HTTP/2 over TLS traffic has been
captured, decrypted, and verified to contain the uncorrupted POST request body.

1. Build the docker image with `sudo docker build --tag repro /.`
1. Run the image with `sudo docker run repro` to see the issue reproduced.

A sample of the output produced by running the image is also included in the repository.
