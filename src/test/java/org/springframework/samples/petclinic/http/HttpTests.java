package org.springframework.samples.petclinic.http;

import org.junit.Test;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpTests {

    @Test
    public void http_POC() throws IOException {
        URL url = new URL("http://www.google.com");
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.connect();
    }
}
