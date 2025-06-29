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
[INFO] 
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running io.github.linghengqian.SimpleTest
07:56:30.661 [main] INFO  org.testcontainers.images.PullPolicy - Image pull policy will be performed by: DefaultPullPolicy()
07:56:30.677 [main] INFO  org.testcontainers.utility.ImageNameSubstitutor - Image name substitution will be performed by: DefaultImageNameSubstitutor (composite of 'ConfigurationFileImageNameSubstitutor' and 'PrefixingImageNameSubstitutor')
07:56:30.724 [main] INFO  org.testcontainers.DockerClientFactory - Testcontainers version: 1.21.2
07:56:30.943 [main] WARN  org.testcontainers.dockerclient.DockerClientProviderStrategy - DOCKER_HOST tcp://127.0.0.1:12375 is not listening
java.net.ConnectException: Connection refused: connect
	at java.base/sun.nio.ch.Net.connect0(Native Method)
	at java.base/sun.nio.ch.Net.connect(Net.java:589)
	at java.base/sun.nio.ch.Net.connect(Net.java:578)
	at java.base/sun.nio.ch.NioSocketImpl.connect(NioSocketImpl.java:583)
	at java.base/java.net.SocksSocketImpl.connect(SocksSocketImpl.java:327)
	at java.base/java.net.Socket.connect(Socket.java:751)
	at java.base/java.net.Socket.connect(Socket.java:686)
	at org.testcontainers.dockerclient.DockerClientProviderStrategy.lambda$test$3(DockerClientProviderStrategy.java:214)
	at org.testcontainers.shaded.org.awaitility.core.AssertionCondition.lambda$new$0(AssertionCondition.java:53)
	at org.testcontainers.shaded.org.awaitility.core.ConditionAwaiter$ConditionPoller.call(ConditionAwaiter.java:248)
	at org.testcontainers.shaded.org.awaitility.core.ConditionAwaiter$ConditionPoller.call(ConditionAwaiter.java:235)
	at java.base/java.util.concurrent.FutureTask.run(FutureTask.java:317)
	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1144)
	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:642)
	at java.base/java.lang.Thread.run(Thread.java:1583)
07:56:31.161 [main] INFO  org.testcontainers.dockerclient.DockerClientProviderStrategy - Found Docker environment with local Npipe socket (npipe:////./pipe/docker_engine)
07:56:31.161 [main] WARN  org.testcontainers.dockerclient.DockerClientProviderStrategy - windows is currently not supported
07:56:31.176 [main] INFO  org.testcontainers.dockerclient.DockerMachineClientProviderStrategy - docker-machine executable was not found on PATH ([C:\Program Files\PowerShell\7, C:\hostedtoolcache\windows\Java_Microsoft_jdk\21.0.2\x64\bin, D:\a\_temp\wsl-shell-wrapper, C:\Program Files\MongoDB\Server\5.0\bin, C:\aliyun-cli, C:\vcpkg, C:\Program Files (x86)\NSIS\, C:\tools\zstd, C:\Program Files\Mercurial\, C:\hostedtoolcache\windows\stack\3.5.1\x64, C:\cabal\bin, C:\\ghcup\bin, C:\mingw64\bin, C:\Program Files\dotnet, C:\Program Files\MySQL\MySQL Server 8.0\bin, C:\Program Files\R\R-4.4.2\bin\x64, C:\SeleniumWebDrivers\GeckoDriver, C:\SeleniumWebDrivers\EdgeDriver\, C:\SeleniumWebDrivers\ChromeDriver, C:\Program Files (x86)\sbt\bin, C:\Program Files (x86)\GitHub CLI, C:\Program Files\Git\bin, C:\Program Files (x86)\pipx_bin, C:\npm\prefix, C:\hostedtoolcache\windows\go\1.24.4\x64\bin, C:\hostedtoolcache\windows\Python\3.9.13\x64\Scripts, C:\hostedtoolcache\windows\Python\3.9.13\x64, C:\hostedtoolcache\windows\
07:56:31.176 [main] ERROR org.testcontainers.dockerclient.DockerClientProviderStrategy - Could not find a valid Docker environment. Please check configuration. Attempted configurations were:
	NpipeSocketClientProviderStrategy: failed with exception InvalidConfigurationException (windows containers are currently not supported)As no valid configuration was found, execution cannot continue.
See https://java.testcontainers.org/on_failure.html for more details.
Error:  Tests run: 1, Failures: 0, Errors: 1, Skipped: 0, Time elapsed: 0.703 s <<< FAILURE! -- in io.github.linghengqian.SimpleTest
Error:  io.github.linghengqian.SimpleTest.testContainers -- Time elapsed: 0.687 s <<< ERROR!
java.lang.IllegalStateException: Could not find a valid Docker environment. Please see logs and check configuration
	at org.testcontainers.dockerclient.DockerClientProviderStrategy.lambda$getFirstValidStrategy$7(DockerClientProviderStrategy.java:274)
	at java.base/java.util.Optional.orElseThrow(Optional.java:403)
	at org.testcontainers.dockerclient.DockerClientProviderStrategy.getFirstValidStrategy(DockerClientProviderStrategy.java:265)
	at org.testcontainers.DockerClientFactory.getOrInitializeStrategy(DockerClientFactory.java:154)
	at org.testcontainers.DockerClientFactory.client(DockerClientFactory.java:196)
	at org.testcontainers.DockerClientFactory$1.getDockerClient(DockerClientFactory.java:108)
	at com.github.dockerjava.api.DockerClientDelegate.authConfig(DockerClientDelegate.java:109)
	at org.testcontainers.containers.GenericContainer.start(GenericContainer.java:321)
	at io.github.linghengqian.SimpleTest.testContainers(SimpleTest.java:16)
	at java.base/java.lang.reflect.Method.invoke(Method.java:580)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1596)
	at java.base/java.util.ArrayList.forEach(ArrayList.java:1596)
[INFO] 
[INFO] Results:
[INFO] 
Error:  Errors: 
Error:    SimpleTest.testContainers:16 � IllegalState Could not find a valid Docker environment. Please see logs and check configuration
[INFO] 
Error:  Tests run: 1, Failures: 0, Errors: 1, Skipped: 0
[INFO] 
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  10.818 s
[INFO] Finished at: 2025-06-29T07:56:31Z
[INFO] ------------------------------------------------------------------------
Error:  Failed to execute goal org.apache.maven.plugins:maven-surefire-plugin:3.2.5:test (default-test) on project windows-env-testcontainers-test: 
Error:  
Error:  Please refer to D:\a\windows-env-testcontainers-test\windows-env-testcontainers-test\target\surefire-reports for the individual test results.
Error:  Please refer to dump files (if any exist) [date].dump, [date]-jvmRun[N].dump and [date].dumpstream.
Error:  -> [Help 1]
Error:  
Error:  To see the full stack trace of the errors, re-run Maven with the -e switch.
Error:  Re-run Maven using the -X switch to enable full debug logging.
Error:  
Error:  For more information about the errors and possible solutions, please read the following articles:
Error:  [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoFailureException
Error: Process completed with exit code 1.
```
