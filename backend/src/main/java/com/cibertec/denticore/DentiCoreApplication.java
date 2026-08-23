package com.cibertec.denticore;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class DentiCoreApplication { 

    public static void main(String[] args) {
        DatabaseUrlAdapter.applyFromEnvironment();
        SpringApplication.run(DentiCoreApplication.class, args);
    }
}
