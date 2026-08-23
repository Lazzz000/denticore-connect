package com.cibertec.denticore;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

final class DatabaseUrlAdapter {

    private DatabaseUrlAdapter() {
    }

    static void applyFromEnvironment() {
        String databaseUrl = System.getenv("DATABASE_URL");
        if (databaseUrl == null || databaseUrl.isBlank()) {
            return;
        }

        URI uri = URI.create(databaseUrl);
        String[] credentials = uri.getRawUserInfo().split(":", 2);

        setIfMissing("DB_HOST", uri.getHost());
        setIfMissing("DB_PORT", String.valueOf(uri.getPort() > 0 ? uri.getPort() : 5432));
        setIfMissing("DB_NAME", uri.getPath().replaceFirst("^/", ""));
        setIfMissing("DB_USER", decode(credentials[0]));
        setIfMissing("DB_PASSWORD", credentials.length > 1 ? decode(credentials[1]) : "");
    }

    private static String decode(String value) {
        return URLDecoder.decode(value, StandardCharsets.UTF_8);
    }

    private static void setIfMissing(String key, String value) {
        if (System.getProperty(key) == null && System.getenv(key) == null) {
            System.setProperty(key, value);
        }
    }
}
