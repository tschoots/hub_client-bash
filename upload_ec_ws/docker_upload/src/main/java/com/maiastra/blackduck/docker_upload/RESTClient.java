package com.maiastra.blackduck.docker_upload;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;


public class RESTClient {

	public static void main(String[] args) throws UnsupportedEncodingException, ClientProtocolException, IOException {
		String begin_time = String.format("%s", new SimpleDateFormat("dd-MM-yyy HH:mm:ss").format(new Date()));
		System.out.println(String.format("begin time : %s", begin_time));
		
		if (args.length != 5){
			System.out.println("not enough parameters usage : <hubServer url> <port> <user> <password> <path json file>");
			System.exit(1);
		}
		
		String hubServer = args[0];
		String port = args[1];
		String user = args[2];
		String password = args[3];
		String jsonFilePath = args[4];
		
		
		String url =  String.format("%s/j_spring_security_check", hubServer);
		CloseableHttpClient client = HttpClients.createDefault();
		login(url, client, user , password);
		
		// now we are logged in get the json file and post it.
		byte[] encoded = Files.readAllBytes(Paths.get(jsonFilePath));
		String jsonString = new String(encoded, StandardCharsets.UTF_8);
		System.out.println(jsonString);
		
		
		// http://eng-hub-docker-01.blackducksoftware.com:80/api/v1/rpm-bom
		String restUrl = String.format("%s:%s/api/v1/rpm-bom", hubServer, port);
		System.out.println(restUrl);
		HttpPost httpPost = new HttpPost(restUrl);
		
		
		
		StringEntity se = new StringEntity(jsonString);
		se.setContentType( "application/json");
		httpPost.setEntity(se);
		
		
		
		CloseableHttpResponse response = client.execute(httpPost);
		if (response.getStatusLine().getStatusCode() == 200){
			System.out.println("yes");
		}
		System.out.println(response.getStatusLine().getReasonPhrase());
		System.out.println(response.getStatusLine().getStatusCode());
		response.close();
		
		
		client.close();

	}
	
	private static void login(String url, CloseableHttpClient client, String user, String password)
			throws UnsupportedEncodingException, IOException,
			ClientProtocolException {
		HttpPost httpPost = new HttpPost(url);
		

		
		List<NameValuePair> params = new ArrayList<NameValuePair>();

		params.add(new BasicNameValuePair("j_username", user));
		params.add(new BasicNameValuePair("j_password", password));
		httpPost.setEntity(new UrlEncodedFormEntity(params));
		
		CloseableHttpResponse response = client.execute(httpPost);
		if (response.getStatusLine().getStatusCode() == 200){
			System.out.println("yes");
		}
		System.out.println(response.getStatusLine().getReasonPhrase());
		System.out.println(response.getStatusLine().getStatusCode());
		response.close();
	}

}
