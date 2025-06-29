package io.github.linghengqian;

import org.junit.jupiter.api.Test;
import org.testcontainers.containers.GenericContainer;

import static org.junit.jupiter.api.Assertions.assertNotNull;

public class SimpleTest {

    @SuppressWarnings("rawtypes")
    @Test
    void testContainers() {
        try (GenericContainer<?> mysqlContainer = new GenericContainer("mysql:9.1.0-oraclelinux9")
                .withEnv("MYSQL_ROOT_PASSWORD", "example")
                .withExposedPorts(3306)) {
            mysqlContainer.start();
            assertNotNull(mysqlContainer.getMappedPort(3306));
        }
    }
}
