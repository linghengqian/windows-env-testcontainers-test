# windows-env-testcontainers-test

- For https://github.com/apache/shardingsphere/issues/35052 .
- Execute the following command on the `Windows 11 Home 24H2` instance with `PowerShell/PowerShell`,
  `version-fox/vfox`, `git-for-windows/git` and `docker/cli` installed. 
  **Note that these commands are usually used in Github Actions' `windows-latest` runner or in a virtual machine that supports nested virtualization.**

```shell
# Enter PowerShell 7 in Windows 11
wsl --install
wsl --install Ubuntu-24.04
wsl --set-default Ubuntu-24.04

# Enter bash in the Ubuntu-24.04 Linux distribution
sudo apt-get update
sudo apt-get remove docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo sed -i 's|-H fd://|-H fd:// -H tcp://127.0.0.1:12375|' /usr/lib/systemd/system/docker.service
sudo systemctl daemon-reload
sudo systemctl restart docker.service

# Enter PowerShell 7 in Windows 11
$Env:DOCKER_HOST = 'tcp://127.0.0.1:12375'
docker run hello-world:linux
vfox add java
vfox install java@21.0.7-ms
vfox use --global java@21.0.7-ms
git clone git@github.com:linghengqian/windows-env-testcontainers-test.git
cd ./windows-env-testcontainers-test
./mvnw clean test
```

- The log is as follows.

```shell
```
