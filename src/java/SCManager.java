package com.palgle.utils;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.StatusLine;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.os.AsyncTask;
import android.util.Log;

// http://stackoverflow.com/questions/19624193/how-to-handle-return-value-from-asynctask
public class SCManager extends AsyncTask<String, String, String> {
	private static final String SERVER_URL	= "http://palgle.com/api/";
	private static final String TAG = "SCManager";
	
	public ISCManagerResponse _delegate	= null;
	private String _scURL	= null;
	private String _api	= null;
	private String _params	= null;
	private String _tag	= null;
	private Context _context;
	
	private static SharedPreferences _sharedPrefs;
	public static String SC_PREF_NAME	= "user_default";
	public static final String kSC_ACCESS_TOKEN	= "kSC_ACCESS_TOKEN";
	public static String _accessToken	= null;

	public SCManager(String api, String params, ISCManagerResponse delegate, Context ctx) {
    	_api	= api;
    	_params	= params;
    	_delegate	= delegate;
    	String urlParams	= _params == null? "" : "&" + _params;
    	if(SCManager._accessToken == null) {
        	_scURL	= SERVER_URL+_api+"?"+urlParams;
    	} else {
        	_scURL	= SERVER_URL+_api+"?token="+this.getAccessToken()+urlParams;
    	}
    	_tag	= _api;
    	_context	= ctx;
    	if(_context != null)
    		_sharedPrefs	= _context.getSharedPreferences(SCManager.SC_PREF_NAME, Context.MODE_PRIVATE);
    	
    	Log.e(TAG, _scURL);
    }
	
	public SCManager(String api, ISCManagerResponse delegate, Context ctx) {
		this(api, "", delegate, ctx);
    }

	public static void setAccessToken(String v, Context ctx) {
		SCManager._accessToken	= v;
		SharedPreferences sharedPreferences	= ctx.getSharedPreferences(SCManager.SC_PREF_NAME, Context.MODE_PRIVATE);
		sharedPreferences.edit().putString(SCManager.kSC_ACCESS_TOKEN, v);
		sharedPreferences.edit().commit();
	}
	
	private String getAccessToken() {
		if(SCManager._accessToken != null) {
			return SCManager._accessToken;
		}

		SCManager._accessToken	= SCManager._sharedPrefs.getString(SCManager.kSC_ACCESS_TOKEN, null);
		
		return SCManager._accessToken;
	}
	
    protected String doInBackground(String... uri) {
        HttpClient httpclient = new DefaultHttpClient();
        HttpResponse response;
        String responseString = null;
        try {
            response = httpclient.execute(new HttpGet(_scURL));
            StatusLine statusLine = response.getStatusLine();
            if(statusLine.getStatusCode() == HttpStatus.SC_OK){
                ByteArrayOutputStream out = new ByteArrayOutputStream();
                response.getEntity().writeTo(out);
                out.close();
                responseString = out.toString();
            } else{
                //Closes the connection.
                response.getEntity().getContent().close();
                throw new IOException(statusLine.getReasonPhrase());
            }
        } catch (ClientProtocolException e) {
            //TODO Handle problems..
        } catch (IOException e) {
            //TODO Handle problems..
        }
        return responseString;
    }

    @Override
    protected void onPostExecute(String result) {
        super.onPostExecute(result);

        if(result == null) {
        	return;
        }
        
        if(_delegate != null) {
        	JSONObject obj	= null;
		    try {
				obj = new JSONObject(result);
				final JSONObject response	= obj.getJSONObject("response");
				
				if(obj.has("service_user_id") == true) {
					int serviceUserId	= obj.getInt("service_user_id");
					if(UserManager.getInstance(_context).isLogin() && serviceUserId == -1) {
						UserManager.getInstance(_context).logout();
				        AlertDialog.Builder bld = new AlertDialog.Builder(_context);
				        bld.setTitle("Logout");
				        bld.setMessage("Logout because another device logined.");
				        bld.setPositiveButton("확인", new DialogInterface.OnClickListener() {
							@Override
							public void onClick(DialogInterface arg0, int arg1) {
								try {
									_delegate.scPostResult(_tag, response);
								} catch (JSONException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
							}
						});
				        bld.create().show();
					} else {
					    _delegate.scPostResult(_tag, response);
					}
				} else {
				    _delegate.scPostResult(_tag, response);
				}
				
			} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

        } else {
        	Log.e(TAG, "You have not assigned IApiAccessResponse delegate");
        }
    }
}