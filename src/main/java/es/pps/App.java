package es.pps;

import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;

public final class App {
    private static final int PORT = 8080;
    private static final String NAME = "Marcos";

    public static void main(String[] args) throws IOException {
        byte[] body = ("<!doctype html><html lang=\"es\"><head><meta charset=\"utf-8\">"
                + "<title>" + NAME + "</title></head><body><h1>" + NAME + "</h1></body></html>")
                .getBytes(StandardCharsets.UTF_8);

        HttpServer server = HttpServer.create(new InetSocketAddress(PORT), 0);
        server.createContext("/", exchange -> {
            exchange.getResponseHeaders().set("Content-Type", "text/html; charset=utf-8");
            exchange.sendResponseHeaders(200, body.length);
            try (var out = exchange.getResponseBody()) {
                out.write(body);
            }
        });
        server.start();
    }
}
