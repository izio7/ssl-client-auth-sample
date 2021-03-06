# generate public keys for client/server respectively

keytool -genkeypair -alias serverkey -keyalg RSA -dname "CN=cxz.asuscomm.com,OU=R&D,O=Hyper.no,L=OSLO,S=OSLO,C=NO" -keypass password -keystore server.jks -storepass password -validity 3650
keytool -genkeypair -alias changkey -keyalg RSA -dname "CN=chang,OU=R&D,O=Hyper.no,L=OSLO,S=OSLO,C=NO" -keypass password -storepass password -keystore chang.jks -validity 3650

# export client certificate 
keytool -exportcert -alias changkey -file chang-public.cer -keystore chang.jks -storepass password

# In context of tomcat using, jks is expected
keytool  -importcert -file chang-public.cer -keystore trusted-keystore.jks -alias "chang"
keytool -list -keystore trusted-keystore.jks -storepass password
 
# export server certificate DER format
keytool -exportcert -alias serverkey -file server-public.cer -keystore server.jks -storepass password

# PKCS12 keystore is commonly used in Windows & Android.
keytool -importkeystore -srckeystore chang.jks -srcstoretype JKS -srcstorepass password -destkeystore chang.pfx -deststoretype PKCS12 -deststorepass password

=========================Script to generated a CA, use the CA to provision the key====================================

# Create a root CA
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -days 3650 -out rootCA.pem.crt

# import this rootCA.pem.crt As a root CA to Android device

# Generate keystore
keytool -genkey -alias tomcat -keyalg RSA -keystore server.jks

# Generate a certificate signing request (a.k.a. CSR)
keytool -certreq -alias tomcat -keystore tomcat.jks -file tomcat.csr

# Sign the CSR with root CA
openssl x509 -req -in tomcat.csr -CA ~/key/key3-ca/chang-root-CA.pem.crt -CAkey ~/key/key3-ca/chang-root-CA.key -CAcreateserial -out tomcat.pem.crt -days 3650

# Import the ROOT/Intermediate trusted CA certificate
keytool -import -trustcacerts -alias root -file ~/key/key3-ca/chang-root-CA.pem.crt -keystore tomcat.jks

# Then we can imported the Certificate by our own root CA
keytool -import -trustcacerts -alias tomcat -file tomcat.pem.crt -keystore tomcat.jks

# All done! enjoy!
