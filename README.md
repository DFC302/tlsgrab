# tlsgrab
Grab domains from TLS certificates and pretty print them to the screen.

# Requirements needed for tlsgrab to run
* nmap
* httpx
* jq

# installation
```
git clone https://github.com/DFC302/tlsgrab.git
```

# usage
```
echo <cidr> | bash tlsgrab.sh
or
cat <file-with-cidrs> | bash tlsgrab.sh
```
