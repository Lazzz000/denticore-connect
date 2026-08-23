package com.cibertec.denticore.security.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Profile("demo")
@RequiredArgsConstructor
public class DemoPatientBootstrapRunner implements CommandLineRunner {

    private final DemoPatientBootstrapService bootstrapService;

    @Value("${app.demo.patient-dni:}")
    private String dni;

    @Value("${app.demo.patient-email:}")
    private String email;

    @Value("${app.demo.patient-password:}")
    private String password;

    @Override
    public void run(String... args) {
        if (dni.isBlank() || email.isBlank() || password.isBlank()) {
            log.warn("No se creó el paciente demo: faltan variables DEMO_PATIENT_*.");
            return;
        }

        bootstrapService.createPatientIfMissing(dni.trim(), email.trim(), password);
    }
}
