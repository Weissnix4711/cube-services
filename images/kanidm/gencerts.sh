#!/bin/sh

echo "cleaning..."
rm -f certs/*

echo "creating (ca)key.pem..."
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out certs/cakey.pem
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 -out certs/key.pem

echo "creating ca.pem..."
openssl req -x509 -key certs/cakey.pem -config certs.cnf -section req_ca -out certs/ca.pem
echo "creating csr..."
openssl req -new -key certs/key.pem -config certs.cnf -section req_server -out certs/csr
echo "creating cert.pem..."
openssl req -x509 -in certs/csr -CA certs/ca.pem -CAkey certs/cakey.pem -config certs.cnf -section req_server -out certs/cert.pem
rm certs/csr

echo "creating chain.pem..."
cat certs/cert.pem certs/ca.pem > certs/chain.pem

echo "validating..."
diff <(openssl ec -in certs/key.pem -pubout | openssl sha1) <(openssl x509 -in certs/chain.pem -noout -pubkey | openssl sha1)
openssl verify -CAfile certs/chain.pem certs/chain.pem
