package org.springframework.samples.petclinic.http;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;

public class HttpTests {

	@Test
	public void http_connect() throws IOException {
		URL url = new URL("http://www.google.com");
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.connect();
	}

	@Test
	public void http_responseCode() throws IOException {
		URL url = new URL("http://www.google.com");
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.getResponseCode();
	}

	@Test
	public void http_responseHeader() throws IOException {
		URL url = new URL("http://www.google.com");
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.getHeaderField(1);
	}

	@Test
	public void http_contentType() throws IOException {
		URL url = new URL("http://www.google.com");
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.getContentType();
	}

	@Test
	public void http() throws IOException {
		URL url = new URL("http://www.google.com");
		HttpURLConnection connection = (HttpURLConnection) url.openConnection();
		connection.connect();
		connection.getResponseCode();
		connection.getContentType();
	}

}
