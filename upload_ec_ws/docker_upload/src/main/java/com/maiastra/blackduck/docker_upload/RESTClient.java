package com.maiastra.blackduck.docker_upload;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
//import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
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
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;


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
		
		//remove trailing slash
		hubServer = hubServer.replaceAll("/$", "");
		
		String bomUrlFilePath = jsonFilePath.replaceAll(".json$", ".url");
		String htmlUrlFilePath = jsonFilePath.replaceAll(".json$", ".html");
		String htmlUrlCompFilePath = jsonFilePath.replaceAll(".json$", "_comp.html");
		
		
		
		
		
		String url =  String.format("%s/j_spring_security_check", hubServer);
		CloseableHttpClient client = HttpClients.createDefault();
		login(url, client, user , password);
		
		// now we are logged in get the json file and post it.
		byte[] encoded = Files.readAllBytes(Paths.get(jsonFilePath));
		String jsonString = new String(encoded, StandardCharsets.UTF_8);
		System.out.println(jsonString);
		
		//get the number of components
		JSONObject jsonObj = new JSONObject(jsonString);
		JSONArray jsonComps = jsonObj.getJSONArray("ossComponentsToMatch");
		int numberOfComponents = jsonComps.length();
		
		String htmlComponentPage = getHtmlPage(jsonComps, numberOfComponents);
		
		
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
		String responseBody = EntityUtils.toString(response.getEntity());
		
		responseBody = responseBody.replaceAll("\"", "");
		
		String bomUrl = String.format("%s/#versions/id:%s/view:bom", hubServer, responseBody );
		System.out.println(responseBody);
		System.out.println(bomUrl);
		
		//Files.write(Paths.get(bomUrlFilePath), bomUrl.getBytes(), StandardOpenOption.CREATE);
		// don't use option default behaviour CREATE, TRUNCATE_EXISTING, WRITE
		Files.write(Paths.get(bomUrlFilePath), bomUrl.getBytes());
		
		
				
		
		String htmlTestPage = String.format("<!DOCTYPE html>" 
								+ "<html>"
								+ "<head>"
								+ "<style>"
								+ "*{margin:0;padding:0}"
								+ "html, body {height:100%%;width:100%%;overflow:hidden}"
								+ "table {height:100%%;width:100%%;table-layout:static;border-collapse:collapse}"
								+ "iframe {height:100%%;width:100%%}"
								
								+ ".header {border-bottom:1px solid #000}"
								+ ".content {height:100%%}"
								+ "</style>"
								+ "<title>Page Title</title>"
								+ "</head>"
								+ "<body style=\"margin:0; width:100%%; height:100%%\">"
								
								+ "<h1>Components found by scanner</h1>"
								+ "<p>number of components : %d</p>"
								
								+ "<table>"
								+ "<tr><td class=\"header\"><div><h1>Header</h1></div></td></tr>"
								  + "<tr><td class=\"content\">"
								+ "<iframe id=\"foo\" name=\"foo\" height=\"100%%\" width=\"100%%\" frameborder=\"0\" src=\"%s\"></iframe>"
								+ "</table>"
								+ "</body>"
								+ "</html>", numberOfComponents, bomUrl) ;
		Files.write(Paths.get(htmlUrlFilePath), htmlTestPage.getBytes()); //, StandardOpenOption.CREATE);
		Files.write(Paths.get(htmlUrlCompFilePath), htmlComponentPage.getBytes()); //, StandardOpenOption.CREATE);
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
	
	private static String getHtmlPage(JSONArray jsonComps, int numberOfComponents) {
		String htmlTestPage = "<!DOCTYPE html>" 
				+ "<html>"
				+ "<head>"
				+ "<body>"
				+ "<style>"
				+ "white-space: pre-line;"
				+ "</style>";
		
		
		
		ArrayList<String> componentList = new ArrayList<String>();
		for(int i=0; i< numberOfComponents; i++){
			JSONObject obj = jsonComps.getJSONObject(i);
			System.out.println(String.format("name : %s   , versioAn : %s", obj.get("name") , obj.get("version")));
			String test = String.format("%-35s : %-15s", obj.get("name"), obj.get("version"));
			//componentList.add((String) obj.get("name"));
			componentList.add(test);
		}
		
		Collections.sort(componentList);
		
		for(String com : componentList){
			System.out.println(com);
			htmlTestPage+="<br>" + com;
		}
		
		htmlTestPage += "</body>"
				+ "</html>";
		return htmlTestPage;
	}

}
