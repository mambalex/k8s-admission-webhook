#!/usr/bin/env bash

# if the server name is undefined, lets default to 'webhook-server'
SERVER="${SERVER:-webhook-server}"

CORPORATION=My-Corp
GROUP=My-Corporate-Group
CITY=Sydney
STATE=NSW
COUNTRY=AU

CERT_AUTH_PASS=`openssl rand -base64 32`
echo $CERT_AUTH_PASS > cert_auth_password
CERT_AUTH_PASS=`cat cert_auth_password`


# Create the certificate authority
openssl \
  req \
  -subj "/CN=$SERVER.ca/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY" \
  -new \
  -x509 \
  -passout pass:$CERT_AUTH_PASS \
  -keyout ca.key \
  -out ca.crt \
  -days 36500

# create client private key (used to decrypt the cert we get from the CA)
openssl genrsa -out $SERVER.key

# create the CSR(Certitificate Signing Request)
openssl \
  req \
  -new \
  -subj "/CN=$SERVER/OU=$GROUP/O=$CORPORATION/L=$CITY/ST=$STATE/C=$COUNTRY" \
  -sha256 \
  -key $SERVER.key \
  -out $SERVER.csr \
  -days 36500

# sign the certificate with the certificate authority
openssl \
  x509 \
  -req \
  -days 36500 \
  -in $SERVER.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -out $SERVER.crt \
  -extfile extfile.cnf \
  -extensions SAN \
  -passin pass:$CERT_AUTH_PASS
