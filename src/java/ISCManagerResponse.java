package com.palgle.nightdancea.utils;

import org.json.JSONException;
import org.json.JSONObject;

public interface ISCManagerResponse {
    public String scURL = null;

    void scPostResult(String tag, JSONObject asyncresult) throws JSONException;
}